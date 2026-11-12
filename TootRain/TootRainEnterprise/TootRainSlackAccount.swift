//
//  TootRainSlackAccount.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation
import Cocoa

/// One Slack workspace linked through the TootRain server.
///
/// The app keeps one of these per workspace the user authorised, each with its
/// own Slack access token, and they all share the single app session token held
/// by `TootRainAppSession`. The channels the user picked are kept here as well:
/// the server holds only what is being listened to right now, and a workspace
/// switched off is listening to nothing, so what to put back when it is
/// switched on again is the app's to remember. See
/// `TootRainChannelSubscriptions`.
@objc(TootRainSlackAccount)
class TootRainSlackAccount: Account {

    static let defaultsKey = "TootRainSlackAccount"

    /// Posted when what is saved here changes in a way the settings pane shows —
    /// a workspace the server no longer has, or has again.
    @objc static let accountsChangedNotificationName = "TootRainSlackAccountsChanged"

    @objc let teamId: String
    @objc var teamName: String
    @objc var teamDomain: String?
    @objc var slackUserId: String
    @objc var slackUserName: String?

    /// The server's own id for this account on the session, and the only id here
    /// that is not Slack's: it is what names this one when two accounts of the
    /// same workspace are on one session. It comes from the session overview, so
    /// it is missing until the app has asked for that once.
    @objc var linkageId: NSNumber?

    /// The channels of this workspace the user has picked: Slack's own channel
    /// ids, and what each channel was called when it was picked, which is what
    /// the accounts pane names them by without asking Slack again.
    ///
    /// What the set is for is `TootRainChannelSubscriptions`, which states it
    /// to the server and takes the server's answer as what it ended up being.
    ///
    /// `nil` for an account that has never had a set of its own, which is not
    /// the same as one that has an empty set: the first takes the server's own
    /// channels when the session is first asked about, the second is a
    /// workspace with every channel unticked.
    var channels: [String: String]?

    var channelIds: Set<String>? {
        channels.map { Set($0.keys) }
    }

    /// The channels to show in the accounts pane, in the order they read best.
    var channelNames: [String] {
        (channels ?? [:]).values.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    /// Set when the server does not have this account on its session — an
    /// administrator having taken the session away, or removed the linkage.
    /// Nothing can be done with the workspace until the user authorises it
    /// again, and the settings pane says so instead of offering the rest.
    @objc var needsAuthentication = false

    private let environment: TootRainServerEnvironment

    @objc init(teamId: String,
               teamName: String,
               teamDomain: String?,
               slackUserId: String,
               slackUserName: String?) {
        self.teamId = teamId
        self.teamName = teamName
        self.teamDomain = teamDomain
        self.slackUserId = slackUserId
        self.slackUserName = slackUserName
        self.environment = .current
        super.init()
    }

    private init?(dictionary: [String: Any]) {
        guard let teamId = dictionary["teamId"] as? String,
              let slackUserId = dictionary["slackUserId"] as? String else {
            return nil
        }
        self.teamId = teamId
        self.teamName = dictionary["teamName"] as? String ?? teamId
        self.teamDomain = dictionary["teamDomain"] as? String
        self.slackUserId = slackUserId
        self.slackUserName = dictionary["slackUserName"] as? String
        self.linkageId = dictionary["linkageId"] as? NSNumber
        self.channels = dictionary["channels"] as? [String: String]
        self.needsAuthentication = dictionary["needsAuthentication"] as? Bool ?? false
        self.environment = .current
        super.init()
    }

    // MARK: - Access token

    /// The Slack token this workspace's API calls are made with. Kept in the
    /// keychain, never in the preferences.
    @objc var accessToken: String? {
        get {
            TootRainKeychain.string(server: environment.keychainServer,
                                    account: TootRainSlackAccount.keychainAccount(teamId: teamId))
        }
        set {
            TootRainKeychain.setString(newValue,
                                       server: environment.keychainServer,
                                       account: TootRainSlackAccount.keychainAccount(teamId: teamId))
        }
    }

    private static func keychainAccount(teamId: String) -> String {
        "slack-access-token|\(teamId)"
    }

    // MARK: - Storage

    @objc static func allAccounts() -> [TootRainSlackAccount] {
        let stored = UserDefaults.standard.dictionary(forKey: defaultsKey) ?? [:]
        return stored.keys.sorted().compactMap { teamId in
            guard let dictionary = stored[teamId] as? [String: Any] else { return nil }
            return TootRainSlackAccount(dictionary: dictionary)
        }
    }

    @objc static func account(teamId: String) -> TootRainSlackAccount? {
        allAccounts().first { $0.teamId == teamId }
    }

    @objc func save() {
        let defaults = UserDefaults.standard
        var stored = defaults.dictionary(forKey: TootRainSlackAccount.defaultsKey) ?? [:]
        stored[teamId] = dictionaryRepresentation
        defaults.set(stored, forKey: TootRainSlackAccount.defaultsKey)
        defaults.synchronize()
    }

    /// Forgets this workspace: its row in the preferences and its Slack token,
    /// plus the cached users and emoji that were only useful for it.
    ///
    /// The server is told too, so it stops holding channels for an account
    /// nobody is listening to. Its answer says whether the session went with the
    /// account — it does when that was the last one on it — and the app follows
    /// that, since a session the server has let go is worth nothing here either.
    /// The call authenticates with the session token, so it has to go out before
    /// the token is thrown away.
    override func delete() {
        let linkageId = self.linkageId?.intValue
        removeLocalData()

        guard let linkageId = linkageId else {
            // The app has never asked the server what this session is, so it has
            // no id to name the account by. All that is left is to forget it.
            if TootRainSlackAccount.allAccounts().isEmpty {
                TootRainSlackAccount.forgetSession()
            }
            return
        }

        let teamId = self.teamId
        Task {
            do {
                let removal = try await TootRainServerAPI.shared.deleteLinkage(id: linkageId)
                guard removal.sessionDeleted else { return }
                await MainActor.run { TootRainSlackAccount.forgetSession() }
            } catch {
                NSLog("TootRain: could not tell the server to drop %@: %@",
                      teamId, String(describing: error))
                if TootRainSlackAccount.allAccounts().isEmpty {
                    await MainActor.run { TootRainSlackAccount.forgetSession() }
                }
            }
        }
    }

    private func removeLocalData() {
        let defaults = UserDefaults.standard
        var stored = defaults.dictionary(forKey: TootRainSlackAccount.defaultsKey) ?? [:]
        stored.removeValue(forKey: teamId)
        defaults.set(stored, forKey: TootRainSlackAccount.defaultsKey)
        defaults.synchronize()

        accessToken = nil
        SlackInfoCache.shared.removeCache(teamId: teamId)
    }

    // MARK: - What the server says the session holds

    /// Brings what is saved here into line with the server's own view of the
    /// session. An account the server knows has its linkage id and its names
    /// refreshed; one the server does not know has to be authorised again,
    /// because that is what being logged out from the server's side looks like
    /// from here.
    static func reconcile(with overview: TootRainSessionOverview) {
        for account in allAccounts() {
            if let linkage = overview.slackLinkage(teamId: account.teamId,
                                                   slackUserId: account.slackUserId) {
                account.linkageId = NSNumber(value: linkage.id)
                account.needsAuthentication = false
                // An account saved before the app kept a set of its own, or
                // one linked on another computer: what the server already
                // holds for it is what the user picked, and taking it now is
                // what keeps the next statement of the whole set from giving
                // it all up.
                if account.channels == nil {
                    var channels: [String: String] = [:]
                    for membership in linkage.memberships {
                        let name = membership.name ?? ""
                        channels[membership.channelId] = name.isEmpty ? membership.channelId : name
                    }
                    account.channels = channels
                }
                if let name = linkage.workspace.name, !name.isEmpty {
                    account.teamName = name
                }
                if let displayName = linkage.displayName, !displayName.isEmpty {
                    account.slackUserName = displayName
                }
            } else {
                account.needsAuthentication = true
            }
            account.save()
        }
        notifyAccountsChanged()
    }

    /// Every workspace has to be authorised again: the session they were all on
    /// is gone.
    static func markAllNeedingAuthentication() {
        for account in allAccounts() {
            guard !account.needsAuthentication else { continue }
            account.needsAuthentication = true
            account.save()
        }
        notifyAccountsChanged()
    }

    /// Throws the session token away and leaves whatever is still linked here
    /// waiting to be authorised on a new one.
    static func forgetSession() {
        TootRainAppSession.shared.clear()
        for account in allAccounts() {
            account.linkageId = nil
            account.save()
        }
        markAllNeedingAuthentication()
        TootRainEnterpriseClient.shared.updateConnection()
    }

    /// Tells the settings pane that what is saved here has changed.
    static func notifyAccountsChanged() {
        NotificationCenter.default.post(
            name: Notification.Name(TootRainSlackAccount.accountsChangedNotificationName),
            object: nil)
    }

    private var dictionaryRepresentation: [String: Any] {
        var dictionary: [String: Any] = [
            "teamId": teamId,
            "teamName": teamName,
            "slackUserId": slackUserId,
        ]
        if let teamDomain = teamDomain {
            dictionary["teamDomain"] = teamDomain
        }
        if let slackUserName = slackUserName {
            dictionary["slackUserName"] = slackUserName
        }
        if let linkageId = linkageId {
            dictionary["linkageId"] = linkageId
        }
        if let channels = channels {
            dictionary["channels"] = channels
        }
        if needsAuthentication {
            dictionary["needsAuthentication"] = true
        }
        return dictionary
    }

    // MARK: - Account

    override func identifier() -> String {
        "tootrain-slack:\(teamId)"
    }

    override func displayName() -> String {
        "(Slack) \(teamName)"
    }

    override func shortDisplayName() -> String {
        teamName
    }

    override func serviceImage() -> NSImage {
        NSImage(named: "Slack") ?? NSImage()
    }
}
