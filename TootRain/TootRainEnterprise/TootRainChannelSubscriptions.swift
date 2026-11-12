//
//  TootRainChannelSubscriptions.swift
//  TootRain
//
//  Created by b123400 on 2026/10/29.
//

import Foundation
import Cocoa

/// What this app session is listening to, stated as one set.
///
/// The server holds one set per session rather than one per workspace, and the
/// app states the whole of it in a single request: `PUT
/// /api/slack/channel_memberships` carries every pair of a Slack account and
/// one of its channels, and the server works out the difference from what it
/// holds. So every change comes through here, which is the one place that knows
/// the whole set — a workspace switched on or off, and the channels the picker
/// leaves ticked.
///
/// Switching a workspace off is that set with its pairs left out. The server
/// has no notion of a linkage being off for a while, so it is this app's doing,
/// and what to put back when the workspace is switched on again is kept on the
/// account rather than on the server.
@objc(TootRainChannelSubscriptions)
final class TootRainChannelSubscriptions: NSObject {

    @objc static let shared = TootRainChannelSubscriptions()

    /// Posted when a statement starts and when it ends, so the accounts pane
    /// can show that one is in flight.
    @objc static let didChangeNotificationName = "TootRainChannelSubscriptionsDidChange"

    /// One workspace's channels, as the user has just picked them, which stand
    /// in for what is saved on the account while the set is being stated.
    private struct Change {
        let teamId: String
        let channels: [String: String]
    }

    private let serverAPI = TootRainServerAPI.shared
    /// Set while a statement is waiting for the next turn of the main queue, so
    /// the run of calls a launch makes states the set once rather than once per
    /// workspace. Only touched on the main queue, as is everything below it.
    private var hasScheduledSync = false
    /// Whether the user asked for the statement that is being waited for. They
    /// are owed an answer when it does not reach the server; a statement the
    /// app made of its own accord is not worth interrupting them for.
    private var scheduledSyncWasAskedFor = false
    private var statementsInFlight = 0

    /// Whether a statement is in flight, which is what the Connect button shows
    /// as a workspace being switched on or off.
    @objc var isStating: Bool {
        statementsInFlight > 0
    }

    // MARK: - Stating the set

    /// Brings the server's set into line with what the app wants, on the next
    /// turn of the main queue.
    ///
    /// Where a workspace switched on or off arrives: the account's own flag has
    /// usually only just been written when this is called, and the next turn of
    /// the queue is after that.
    ///
    /// `askedFor` is the user waiting on it — the Connect button, rather than a
    /// launch or a session the app refreshed by itself. A statement nobody is
    /// waiting on is only logged when it fails: what the app wants is written
    /// down either way, and the next statement carries it up.
    @objc(scheduleSyncAskedFor:)
    func scheduleSync(askedFor: Bool = false) {
        scheduledSyncWasAskedFor = scheduledSyncWasAskedFor || askedFor
        guard !hasScheduledSync else { return }
        hasScheduledSync = true
        DispatchQueue.main.async {
            self.hasScheduledSync = false
            let askedFor = self.scheduledSyncWasAskedFor
            self.scheduledSyncWasAskedFor = false
            Task {
                do {
                    try await self.sync()
                } catch {
                    NSLog("TootRain: could not tell the server what to listen to: %@",
                          String(describing: error))
                    if askedFor {
                        await MainActor.run { self.report(error) }
                    }
                }
            }
        }
    }

    /// States the set as it stands: every switched-on workspace's picked
    /// channels, and nothing of the ones switched off.
    @discardableResult
    func sync() async throws -> TootRainChannelMembershipUpdate {
        try await state(replacing: nil)
    }

    /// States the set with one workspace's channels replaced by what the user
    /// has just picked. Nothing is saved until the server has taken it, so a
    /// request that fails leaves the app where it was.
    ///
    /// Answers `nil` when there was nothing to say: a workspace that is
    /// switched off is not in the set either way, so the picks are only written
    /// down, to go up with the set when it is switched on again.
    @discardableResult
    func apply(channels: [String: String],
               to account: TootRainSlackAccount) async throws -> TootRainChannelMembershipUpdate? {
        guard TootRainChannelSubscriptions.isListening(to: account) else {
            await MainActor.run {
                account.channels = channels
                account.save()
                notifyDidChange()
            }
            return nil
        }
        return try await state(replacing: Change(teamId: account.teamId, channels: channels))
    }

    /// The statement itself, with the pane's "this is in flight" either side of
    /// it — asking the server what the session is counts, since that is part of
    /// the same wait.
    private func state(replacing change: Change?) async throws -> TootRainChannelMembershipUpdate {
        await began()
        do {
            let update = try await stateWholeSet(replacing: change)
            await ended()
            return update
        } catch {
            await ended()
            throw error
        }
    }

    private func stateWholeSet(replacing change: Change?) async throws -> TootRainChannelMembershipUpdate {
        var accounts = listeningAccounts()
        // The set names a Slack account by the server's own linkage id, which
        // is the one id here the app is not told until it asks what its session
        // is. A launch that states the set before that answer arrives asks for
        // it first rather than leaving an account out — and the same answer is
        // where a workspace with no set of its own yet gets one, which has to
        // happen before the whole set is stated or the statement would give up
        // the very channels it has not learned about.
        if accounts.contains(where: { $0.linkageId == nil || $0.channels == nil }) {
            try await refreshLinkageIds()
            accounts = listeningAccounts()
        }

        var pairs: [TootRainChannelMembershipPair] = []
        var named: Set<String> = []
        for account in accounts {
            guard let linkageId = account.linkageId?.intValue else {
                NSLog("TootRain: the server has no linkage for %@, leaving its channels out",
                      account.teamId)
                continue
            }
            named.insert(account.teamId)
            let channels: [String: String]
            if let change = change, change.teamId == account.teamId {
                channels = change.channels
            } else {
                channels = account.channels ?? [:]
            }
            pairs += channels.keys.sorted().map {
                TootRainChannelMembershipPair(linkageId: linkageId, channelId: $0)
            }
        }
        // Stating the set without the workspace the picks belong to would take
        // its channels away rather than add them, so that is not sent at all.
        if let change = change, !named.contains(change.teamId) {
            throw TootRainServerError.notLinked
        }

        let update = try await serverAPI.replaceChannelMemberships(pairs)
        await commit(update, to: accounts)
        return update
    }

    /// Takes the server's answer as what each workspace holds. It is the part
    /// to settle on: a channel the bot was never invited to is not in it,
    /// however firmly the app asked for it.
    @MainActor
    private func commit(_ update: TootRainChannelMembershipUpdate,
                        to accounts: [TootRainSlackAccount]) {
        for account in accounts {
            guard let linkageId = account.linkageId?.intValue else { continue }
            account.channels = update.channels(linkageId: linkageId)
            account.save()
        }
    }

    // MARK: - What the pane shows while a statement is in flight

    @MainActor
    private func began() {
        statementsInFlight += 1
        notifyDidChange()
    }

    @MainActor
    private func ended() {
        statementsInFlight = max(0, statementsInFlight - 1)
        notifyDidChange()
    }

    @MainActor
    private func notifyDidChange() {
        NotificationCenter.default.post(
            name: Notification.Name(TootRainChannelSubscriptions.didChangeNotificationName),
            object: nil)
    }

    /// A statement the user asked for and that did not reach the server. What
    /// they asked for is still written down and goes up with the next
    /// statement, so this says what did not happen rather than undoing it.
    @MainActor
    private func report(_ error: Error) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = NSLocalizedString("TootRain could not tell the server which channels to listen to.",
                                              comment: "channel set failure")
        alert.informativeText = error.localizedDescription
        if let window = NSApp.keyWindow {
            alert.beginSheetModal(for: window)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }

    // MARK: - Which workspaces are in the set

    /// The workspaces whose channels belong in the set: linked, and switched on.
    private func listeningAccounts() -> [TootRainSlackAccount] {
        TootRainSlackAccount.allAccounts().filter {
            !$0.needsAuthentication && TootRainChannelSubscriptions.isListening(to: $0)
        }
    }

    /// Whether this workspace is switched on, which is the same flag the
    /// accounts pane's Connect button writes. The one place that asks, so both
    /// sides of what "connected" means — the set stated to the server, and the
    /// socket it arrives on — read it the same way.
    @objc static func isListening(to account: TootRainSlackAccount) -> Bool {
        SettingManager.shared()?.isAccountStreaming(account) ?? false
    }

    /// Asks the server what the session is, which is what fills the linkage ids
    /// in. The answer also says which accounts it no longer holds, so an account
    /// left out of the set afterwards is one there is nothing to be said about.
    private func refreshLinkageIds() async throws {
        let overview = try await serverAPI.session()
        await MainActor.run { TootRainSlackAccount.reconcile(with: overview) }
    }
}
