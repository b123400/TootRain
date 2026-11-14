//
//  TootRainEnterpriseClient.swift
//  TootRain
//
//  Created by b123400 on 2026/10/17.
//

import Foundation
import Cocoa
import SwiftCentrifuge

/// The app's one connection to the TootRain server.
///
/// There is at most one, however many Slack workspaces are linked, which is what
/// keeps the server's load down. It is a Centrifugo connection: the app opens the
/// bidirectional WebSocket with the app session token in the `Authorization`
/// header, Centrifugo asks the server who is connecting through its connect
/// proxy, and the server answers with the channels this session may hear. The
/// app never subscribes to anything itself: the channels come with the
/// connection, and the server adds and drops them on a live one as the session's
/// channel memberships change.
@objc(TootRainEnterpriseClient)
class TootRainEnterpriseClient: NSObject {

    @objc static let shared = TootRainEnterpriseClient()

    private let environment: TootRainServerEnvironment
    private let session: TootRainAppSession

    private var centrifuge: CentrifugeClient?
    /// The token the live connection was opened with, so a changed session
    /// rebuilds the client instead of reusing a connection the server no longer
    /// recognises.
    private var connectedToken: String?
    /// Set while a connection update is waiting for the next turn of the main
    /// queue, so the run of `startStreaming(with:)` calls every launch makes
    /// opens one connection rather than one per workspace.
    private var hasScheduledConnectionUpdate = false
    /// A session the server closed the connection on for good, kept so nothing
    /// reopens a socket that would only be refused again.
    private var refusedToken: String?

    /// Whether the user has been told that this session is gone. The server can
    /// say so twice over — the connection refused and the next request answered
    /// 401 — and that is one piece of news. Cleared when there is a session to
    /// open a connection with again.
    private var hasSaidTheSessionIsGone = false
    /// Channels this session has lost and not told the user about yet, by
    /// workspace, and whether an alert about them is already on its way. Only
    /// touched on the main queue.
    private var lostChannelNames: [String: [String]] = [:]
    private var hasScheduledLossAlert = false

    /// Only for diagnostics; written on the main queue because the library's
    /// callbacks arrive on its own.
    @objc private(set) var isConnected = false

    override init() {
        self.environment = .current
        self.session = .shared
        super.init()
    }

    // MARK: - Launch

    /// Whether the add-account menu offers Slack. Accounts already added stay either way.
    @objc var isSlackEnabled: Bool { TootRainSystemConstants.slackEnabled }

    /// Asks the server what the saved session still is, brings the workspace
    /// caches up to date, and opens the connection if there is a workspace
    /// switched on — all in the background, so a launch with nothing linked
    /// opens no socket at all.
    @objc func applicationDidFinishLaunching() {
        TootRainSystemConstants.refreshInBackground()
        refreshSessionInBackground()
        refreshSlackInfoInBackground()
        scheduleConnectionUpdate()
    }

    /// Checks the saved session against the server's own view of it. What comes
    /// back says which Slack accounts the session still holds, and the accounts
    /// it does not name are the ones an administrator has logged out — they are
    /// marked as needing authentication. See `handleSessionRequestFailure(_:)`
    /// for a session that cannot be read.
    @objc func refreshSessionInBackground() {
        guard !TootRainSlackAccount.allAccounts().isEmpty else { return }
        guard session.hasToken else {
            // Workspaces with no session to reach the server by. Whatever became
            // of the token, they can only be authorised again.
            TootRainSlackAccount.markAllNeedingAuthentication()
            return
        }
        Task {
            do {
                let overview = try await TootRainServerAPI.shared.session()
                await MainActor.run {
                    NSLog("TootRain: the server holds %ld Slack account(s) on this session",
                          overview.slack.linkages.count)
                    self.syncAccountsWithOverviewAndTellUser(overview)
                    // Now that every workspace is named by a linkage id and has
                    // the channels the server holds for it, the app can say
                    // what it means to be listening to — which is not the same
                    // thing, since a workspace switched off is in the first and
                    // not in the second.
                    TootRainChannelSubscriptions.shared.scheduleSync()
                }
            } catch {
                NSLog("TootRain: could not ask the server about this session: %@",
                      String(describing: error))
                await MainActor.run { self.handleSessionRequestFailure(error) }
            }
        }
    }

    /// Every caller comes through here rather than through the account's own
    /// sync, so that learning a workspace is gone and saying so are never
    /// separated.
    @MainActor
    func syncAccountsWithOverviewAndTellUser(_ overview: TootRainSessionOverview) {
        let lost = TootRainSlackAccount.syncWithOverviewAndGetLostAccounts(overview)
        showLostAccountsAlert(accounts: lost)
    }

    /// Only the server's own word that it has no such session is taken as the
    /// session being gone. Anything else — no network, a server not answering —
    /// leaves everything to be asked about again rather than throwing away a
    /// token that is almost certainly still good.
    @MainActor
    private func handleSessionRequestFailure(_ error: Error) {
        guard case TootRainServerError.unauthorized = error else {
            NSLog("TootRain: leaving this session alone until the server can be asked again")
            return
        }
        NSLog("TootRain: the server does not know this session, every workspace needs authorising again")
        TootRainSlackAccount.forgetSession()
        showSessionIsGoneAlert()
    }

    @objc func refreshSlackInfoInBackground() {
        let accounts = TootRainSlackAccount.allAccounts()
        guard !accounts.isEmpty else { return }
        Task {
            for account in accounts {
                do {
                    try await SlackInfoCache.shared.refresh(account: account)
                } catch {
                    NSLog("TootRain: could not refresh Slack info for %@: %@",
                          account.teamName, String(describing: error))
                }
            }
        }
    }

    // MARK: - Which accounts are the server's

    /// Whether this account is streamed by the TootRain server rather than by
    /// one of the app's own stream handles. The one place that knows which kind
    /// of account that is, so the rest of the app can ask instead of testing a
    /// class of its own.
    @objc static func isAccountUsingTootRainServer(_ account: Account?) -> Bool {
        account is TootRainSlackAccount
    }

    /// Whether the server has stopped recognising this account, which leaves
    /// nothing to be done with it until the user authorises it again.
    @objc static func accountNeedsAuthentication(_ account: Account?) -> Bool {
        (account as? TootRainSlackAccount)?.needsAuthentication ?? false
    }

    // MARK: - Connection

    /// Where the settings pane's Connect button arrives, by way of
    /// `StreamController`. It takes an `Account` rather than the Slack one, so a
    /// caller routing an account here does not have to know what kind it is;
    /// anything else is ignored.
    ///
    /// Switching a workspace on opens no connection of its own — there is only
    /// ever the one — but it is the user asking for that one, so a refusal the
    /// app was sitting on is worth another attempt. What it does do is put the
    /// workspace's channels back into the set this session listens to, which is
    /// the whole of what "connected" means here.
    @objc(startStreamingWithAccount:)
    func startStreaming(with account: Account) {
        guard TootRainEnterpriseClient.isAccountUsingTootRainServer(account) else { return }
        refusedToken = nil
        TootRainChannelSubscriptions.shared.scheduleSync()
        scheduleConnectionUpdate()
    }

    /// Switching a workspace off takes its channels out of the set: the server
    /// has no notion of a linkage being off for a while, so what it is told is
    /// that this session is listening to everything except that workspace. The
    /// channels to put back are kept on the account, and the connection itself
    /// only closes if nothing is left switched on.
    @objc(stopStreamingWithAccount:)
    func stopStreaming(with account: Account) {
        guard TootRainEnterpriseClient.isAccountUsingTootRainServer(account) else { return }
        TootRainChannelSubscriptions.shared.scheduleSync()
        scheduleConnectionUpdate()
    }

    /// The user switched a workspace on or off themselves, rather than the app
    /// restoring at launch what they left switched on. The difference is only
    /// in who is told when the statement does not reach the server.
    @objc(accountStreamingStateChangedWithAccount:)
    func accountStreamingStateChanged(with account: Account) {
        guard TootRainEnterpriseClient.isAccountUsingTootRainServer(account) else { return }
        TootRainChannelSubscriptions.shared.scheduleSync(askedFor: true)
    }

    private func scheduleConnectionUpdate() {
        guard !hasScheduledConnectionUpdate else { return }
        hasScheduledConnectionUpdate = true
        DispatchQueue.main.async {
            self.hasScheduledConnectionUpdate = false
            self.updateConnection()
        }
    }

    /// Whether a connection is wanted at all: a workspace the server still
    /// knows about, and switched on. With every workspace off there is nothing
    /// in the session's set for the server to send, so there is nothing for a
    /// socket to carry either.
    private var wantsConnection: Bool {
        TootRainSlackAccount.allAccounts().contains {
            !$0.needsAuthentication && TootRainChannelSubscriptions.isListening(to: $0)
        }
    }

    /// Opens or closes the connection to match what is wanted now: a session
    /// token, and a workspace to listen to.
    @objc func updateConnection() {
        let token = session.token
        guard let token = token, !token.isEmpty, wantsConnection else {
            disconnect()
            return
        }
        if token == refusedToken {
            NSLog("TootRain: not connecting, the server turned this session away for good")
            return
        }
        if centrifuge != nil && connectedToken == token {
            return
        }
        disconnect()
        connect(token: token)
    }

    @objc func disconnect() {
        guard let centrifuge = centrifuge else { return }
        NSLog("TootRain: disconnecting from %@", environment.centrifugoWebSocketURL.absoluteString)
        centrifuge.disconnect()
        self.centrifuge = nil
        self.connectedToken = nil
        setConnected(false)
    }

    fileprivate func setConnected(_ connected: Bool) {
        DispatchQueue.main.async { self.isConnected = connected }
    }

    private func connect(token: String) {
        let endpoint = environment.centrifugoWebSocketURL.absoluteString
        // No Centrifugo token: the app session token in the header is what the
        // server's connect proxy authenticates, and it answers with the channels
        // this session may hear.
        let config = CentrifugeClientConfig(
            headers: [
                "Authorization": "Bearer \(token)",
                "User-Agent": TootRainUserAgent.current,
            ],
            name: "TootRain",
            version: TootRainUserAgent.version,
            useNativeWebSocket: true
        )
        let client = CentrifugeClient(endpoint: endpoint, config: config, delegate: self)
        centrifuge = client
        connectedToken = token
        // There is a session again, so the next one to go is news again.
        hasSaidTheSessionIsGone = false
        NSLog("TootRain: connecting to %@", endpoint)
        client.connect()
    }

    // MARK: - A connection that will not come back

    /// What a terminal disconnect leaves the app to do.
    private enum TerminalDisconnect {
        /// The server does not have this app session. Logging in again is the
        /// only way back.
        case sessionRefused
        /// Terminal for a reason logging in again would not change — a limit, or
        /// a server that is not serving right now.
        case other
    }

    /// The server's own code for a session it does not know. A proxy has to pick
    /// from 4000-4999, and the server takes it from the half of that range that
    /// means "do not come back".
    private static let serverRefusedSessionCode: UInt32 = 4501

    /// Centrifugo keeps the reconnect advice in the disconnect code itself:
    /// 3500-3999 and 4500-4999 are the ranges that say "do not come back", and
    /// SwiftCentrifuge honours them by giving up for good, which makes
    /// `onDisconnected` the last the app hears of that connection. Every other
    /// code it retries on its own, so only these need answering here.
    private static func terminalMeaning(ofCode code: UInt32) -> TerminalDisconnect? {
        switch code {
        // An invalid token, permission denied, and the server's own refusal.
        case 3500, 3507, serverRefusedSessionCode:
            return .sessionRefused
        case 3501..<4000, 4500..<5000:
            return .other
        default:
            return nil
        }
    }

    /// Takes the connection down for good rather than letting a dead client sit
    /// in place looking connected.
    @MainActor
    private func handleTerminalDisconnect(_ meaning: TerminalDisconnect,
                                          client: CentrifugeClient,
                                          code: UInt32,
                                          reason: String) {
        // A client already replaced has nothing left to say.
        guard client === centrifuge else { return }
        centrifuge = nil
        refusedToken = connectedToken
        connectedToken = nil
        setConnected(false)
        NSLog("TootRain: the server will not take this connection back (%u %@)", code, reason)

        guard case .sessionRefused = meaning else { return }
        // The token is worth nothing now, so it goes: the next log-in makes a new
        // session instead of offering this one again.
        TootRainSlackAccount.forgetSession()
        refusedToken = nil
        showSessionIsGoneAlert()
    }

    /// Said wherever the app finds out that the session has gone: the
    /// connection refused, the event, or the server answering that it has no
    /// such session. Nothing else in the app would say so.
    ///
    /// Nothing is said when there is no workspace left to authorise, which is
    /// the user having just removed their last one — that takes the session
    /// with it, and they know.
    @MainActor
    private func showSessionIsGoneAlert() {
        guard !TootRainSlackAccount.allAccounts().isEmpty else { return }
        guard !hasSaidTheSessionIsGone else { return }
        hasSaidTheSessionIsGone = true
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = NSLocalizedString("TootRain stopped listening to Slack.",
                                              comment: "terminal disconnect")
        alert.informativeText = NSLocalizedString(
            "The TootRain server no longer knows this TootRain session. Please log in with Slack again.",
            comment: "terminal disconnect")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    /// One alert however many workspaces there are: a server giving up two of
    /// them in a breath should not cost the user two dialogs.
    @MainActor
    private func showLostAccountsAlert(accounts: [TootRainSlackAccount]) {
        guard !accounts.isEmpty else { return }
        let alert = NSAlert()
        alert.alertStyle = .warning
        if accounts.count == 1, let only = accounts.first {
            alert.messageText = String(
                format: NSLocalizedString("TootRain stopped showing comments from %@.",
                                          comment: "slack linkage removed"),
                only.teamName)
            alert.informativeText = NSLocalizedString(
                "The TootRain server no longer has this Slack workspace. Please log in with Slack again.",
                comment: "slack linkage removed")
        } else {
            alert.messageText = String(
                format: NSLocalizedString("TootRain stopped showing comments from %ld Slack workspaces.",
                                          comment: "slack linkage removed"),
                accounts.count)
            alert.informativeText = String(
                format: NSLocalizedString("%@ — the TootRain server no longer has these Slack workspaces. Please log in with Slack again.",
                                          comment: "slack linkage removed"),
                accounts.map { $0.teamName }.joined(separator: ", "))
        }
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
}

// MARK: - What arrives on the connection

extension TootRainEnterpriseClient {

    fileprivate func didReceiveData(_ data: Data, onChannel channel: String?) {
        guard let payload = TootRainStreamPayload(data: data) else {
            let text = String(data: data, encoding: .utf8) ?? data.base64EncodedString()
            NSLog("TootRain: could not read what arrived on %@: %@",
                  channel ?? "this connection", text)
            return
        }
        switch payload {
        case .event(let event):
            handleStreamEvent(event)
        case .message(let message):
            showMessage(message, carriedBy: channel)
        }
    }

    private func showMessage(_ message: TootRainStreamMessage, carriedBy channel: String?) {
        // A message whose words are somewhere this app does not look, a file
        // with nothing written with it being the usual one.
        guard !message.text.isEmpty else { return }
        guard let origin = SlackMessageOrigin(message: message) else {
            NSLog("TootRain: ignoring a message on %@ that does not say where it came from",
                  channel ?? "this connection")
            return
        }
        guard let account = TootRainSlackAccount.account(teamId: origin.teamId) else {
            NSLog("TootRain: ignoring a message from %@, which is not a workspace this app has",
                  origin.teamId)
            return
        }
        // A message already on its way when the user switched the workspace off.
        guard TootRainChannelSubscriptions.isListening(to: account) else { return }
        guard let controller = StreamController.shared() else { return }
        // Built and handed on here, on the connection's own callback, the way
        // the other services' statuses are: nothing in it waits on the network,
        // so a queue between a comment and the screen would only cost it time.
        // Two messages arriving together may land in either order.
        let status = SlackStatus(text: message.text,
                                 ts: origin.ts,
                                 userId: origin.userId,
                                 channelId: origin.channelId,
                                 account: account)
        // `-showStatus:`, whose window controller puts itself on the main queue.
        controller.show(status)
    }

    private func handleStreamEvent(_ event: TootRainStreamEvent) {
        switch event {
        case .slackMembershipRemoved(let teamId, let channelId):
            Task { @MainActor in self.handleMembershipRemoval(teamId: teamId, channelId: channelId) }
        case .linkageRemoved(let linkageId):
            Task { @MainActor in self.handleLinkageRemoval(linkageId: linkageId) }
        case .sessionRemoved:
            Task { @MainActor in self.handleSessionRemoval() }
        }
    }

    /// The server let the membership go before saying so, so what is left is to
    /// stop remembering the channel as picked — the next statement of the whole
    /// set would otherwise ask for it back — and to tell the user.
    ///
    /// It says this to every connection the session has, the one whose request
    /// caused it included, so each guard below keeps an alert from announcing
    /// what the user did a moment ago.
    @MainActor
    private func handleMembershipRemoval(teamId: String, channelId: String) {
        guard let account = TootRainSlackAccount.account(teamId: teamId) else {
            NSLog("TootRain: the server dropped %@ of %@, which is not a workspace this app has",
                  channelId, teamId)
            return
        }
        // Switched off: its pairs were taken off the server by this app, and
        // the picks are kept here to go back up when it is switched on again.
        guard TootRainChannelSubscriptions.isListening(to: account) else { return }
        NSLog("TootRain: %@ of %@ is no longer being listened to", channelId, teamId)
        // What it was called, while it is still written down. The cache is
        // asked second, since a channel picked under an older name is better
        // named by what the user picked than by what it is called now.
        let name = account.channels?[channelId]
            ?? SlackInfoCache.shared.channel(id: channelId, teamId: teamId)?.name
            ?? channelId
        // Already off what the app holds, so a set this app stated has settled.
        guard TootRainChannelSubscriptions.shared
            .removeSavedChannel(channelId: channelId, of: account) else {
            return
        }
        // The same echo arriving before the answer to the request that caused
        // it, which is in fact the usual order.
        guard !TootRainChannelSubscriptions.shared.isStating else { return }
        scheduleLostChannelsAlert(channelName: name, of: account)
    }

    /// Gathers what has been lost and alerts a moment later, so a workspace
    /// losing several channels at once — a linkage taken away drops every
    /// channel it held — costs one alert rather than a dialog apiece.
    @MainActor
    private func scheduleLostChannelsAlert(channelName: String,
                                           of account: TootRainSlackAccount) {
        lostChannelNames[account.teamId, default: []].append(channelName)
        guard !hasScheduledLossAlert else { return }
        hasScheduledLossAlert = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.showScheduledLostChannelsAlerts()
        }
    }

    @MainActor
    private func showScheduledLostChannelsAlerts() {
        hasScheduledLossAlert = false
        let lost = lostChannelNames
        lostChannelNames = [:]
        for (teamId, names) in lost {
            guard let account = TootRainSlackAccount.account(teamId: teamId) else { continue }
            // A workspace gone from the session drops every channel it held on
            // the way out, and the user has been told about the workspace.
            guard !account.needsAuthentication else { continue }
            showLostChannelsAlert(channelNames: names, of: account)
        }
    }

    @MainActor
    private func showLostChannelsAlert(channelNames: [String],
                                       of account: TootRainSlackAccount) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        if channelNames.count == 1, let only = channelNames.first {
            alert.messageText = String(
                format: NSLocalizedString("TootRain stopped showing comments from #%@.",
                                          comment: "slack membership removed"),
                only)
            alert.informativeText = String(
                format: NSLocalizedString("The TootRain bot is no longer in this channel of %@, or the channel itself is gone. It has been taken off this workspace's channels.",
                                          comment: "slack membership removed"),
                account.teamName)
        } else {
            alert.messageText = String(
                format: NSLocalizedString("TootRain stopped showing comments from %ld channels of %@.",
                                          comment: "slack membership removed"),
                channelNames.count, account.teamName)
            alert.informativeText = String(
                format: NSLocalizedString("%@ — the TootRain bot is no longer in these channels, or they are gone. They have been taken off this workspace's channels.",
                                          comment: "slack membership removed"),
                channelNames.map { "#\($0)" }.joined(separator: ", "))
        }
        if let window = NSApp.keyWindow {
            alert.beginSheetModal(for: window)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }

    /// A workspace the server has stopped holding, which can only be authorised
    /// again. On the main queue, where what is saved about an account is
    /// written.
    @MainActor
    private func handleLinkageRemoval(linkageId: Int) {
        let dropped = TootRainSlackAccount.allAccounts().first {
            $0.linkageId?.intValue == linkageId
        }
        guard let account = dropped else {
            // Usually the echo of this app's own removal. Otherwise, rather
            // than guess which workspace it was — an account waiting for its
            // first session overview has no id — ask what the session holds.
            NSLog("TootRain: the server dropped linkage %ld, which this app does not have",
                  linkageId)
            refreshSessionInBackground()
            return
        }
        NSLog("TootRain: the server has dropped %@, which has to be authorised again",
              account.teamName)
        account.needsAuthentication = true
        account.linkageId = nil
        account.save()
        TootRainSlackAccount.notifyAccountsChanged()
        if TootRainSlackAccount.allAccounts().contains(where: { !$0.needsAuthentication }) {
            updateConnection()
        } else {
            // The last linkage takes the session with it. session_removed comes
            // next on this connection, left open to hear it, and this says it.
            hasSaidTheSessionIsGone = true
        }
        showLostAccountsAlert(accounts: [account])
    }

    /// The last thing the connection will carry: the session itself is going.
    /// The token is worth nothing after this, and whatever is still linked can
    /// only be authorised on a new session.
    @MainActor
    private func handleSessionRemoval() {
        NSLog("TootRain: the server is giving up this session")
        disconnect()
        TootRainSlackAccount.forgetSession()
        showSessionIsGoneAlert()
    }
}

// MARK: - CentrifugeClientDelegate

extension TootRainEnterpriseClient: CentrifugeClientDelegate {

    func onConnected(_ client: CentrifugeClient, _ event: CentrifugeConnectedEvent) {
        setConnected(true)
        NSLog("TootRain: connected as %@", event.client)
    }

    func onConnecting(_ client: CentrifugeClient, _ event: CentrifugeConnectingEvent) {
        setConnected(false)
        NSLog("TootRain: connecting (%u %@)", event.code, event.reason)
    }

    func onDisconnected(_ client: CentrifugeClient, _ event: CentrifugeDisconnectedEvent) {
        setConnected(false)
        NSLog("TootRain: disconnected (%u %@)", event.code, event.reason)
        guard let meaning = TootRainEnterpriseClient.terminalMeaning(ofCode: event.code) else { return }
        Task { @MainActor in
            self.handleTerminalDisconnect(meaning, client: client, code: event.code, reason: event.reason)
        }
    }

    func onError(_ client: CentrifugeClient, _ event: CentrifugeErrorEvent) {
        NSLog("TootRain: connection error: %@", String(describing: event.error))
    }

    func onSubscribed(_ client: CentrifugeClient, _ event: CentrifugeServerSubscribedEvent) {
        NSLog("TootRain: listening to %@", event.channel)
    }

    func onUnsubscribed(_ client: CentrifugeClient, _ event: CentrifugeServerUnsubscribedEvent) {
        NSLog("TootRain: stopped listening to %@", event.channel)
    }

    func onSubscribing(_ client: CentrifugeClient, _ event: CentrifugeServerSubscribingEvent) {
        NSLog("TootRain: subscribing to %@", event.channel)
    }

    func onPublication(_ client: CentrifugeClient, _ event: CentrifugeServerPublicationEvent) {
        didReceiveData(event.data, onChannel: event.channel)
    }

    /// The server sends nothing this way — its events are publications on the
    /// session's own channel — but anything that does come is read the same.
    func onMessage(_ client: CentrifugeClient, _ event: CentrifugeMessageEvent) {
        didReceiveData(event.data, onChannel: nil)
    }
}
