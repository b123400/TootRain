//
//  SlackInfoCache.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation

/// The workspace information a Slack message has to be rendered with: who wrote
/// it, what its custom emoji look like, and the names behind the channel and
/// user group ids a message mentions. A message arrives with ids only, so this
/// is fetched up front — once when a workspace is linked, before the app
/// connects, and again in the background on every launch. Lookups in between are
/// served from the copy on disk.
///
/// The channels are kept for a second reason as well: the channel picker opens
/// on them, so that there is a list to read before Slack has answered.
final class SlackInfoCache {

    static let shared = SlackInfoCache()

    private struct Snapshot: Codable {
        let teamId: String
        let updatedAt: Date
        let users: [SlackCachedUser]
        let emoji: [SlackCachedEmoji]
        /// Both of these are missing from a cache written before they were
        /// kept, which reads as a workspace that has none of either; the next
        /// refresh fills them in.
        let channels: [SlackChannel]?
        let userGroups: [SlackUserGroup]?
    }

    private struct Index {
        let usersById: [String: SlackCachedUser]
        let emojiByName: [String: URL]
        let channelsById: [String: SlackChannel]
        let userGroupsById: [String: SlackUserGroup]
        let updatedAt: Date
    }

    private let queue = DispatchQueue(label: "net.b123400.tootrain.slack-info-cache")
    /// What was last read from or written to disk, which is what one part of it
    /// changing is written back around, and the lookup tables built from it.
    private var snapshots: [String: Snapshot] = [:]
    private var indexes: [String: Index] = [:]
    private var loadedTeamIds: Set<String> = []

    // MARK: - Lookups

    func user(id: String, teamId: String) -> SlackCachedUser? {
        index(teamId: teamId)?.usersById[id]
    }

    func emojiURL(name: String, teamId: String) -> URL? {
        index(teamId: teamId)?.emojiByName[name]
    }

    func channel(id: String, teamId: String) -> SlackChannel? {
        index(teamId: teamId)?.channelsById[id]
    }

    func userGroup(id: String, teamId: String) -> SlackUserGroup? {
        index(teamId: teamId)?.userGroupsById[id]
    }

    /// Every channel the last fetch could see, as Slack listed them. What the
    /// channel picker shows while it asks Slack for the list again.
    func channels(teamId: String) -> [SlackChannel] {
        snapshot(teamId: teamId)?.channels ?? []
    }

    func lastUpdated(teamId: String) -> Date? {
        index(teamId: teamId)?.updatedAt
    }

    func userCount(teamId: String) -> Int {
        index(teamId: teamId)?.usersById.count ?? 0
    }

    func emojiCount(teamId: String) -> Int {
        index(teamId: teamId)?.emojiByName.count ?? 0
    }

    // MARK: - Refreshing

    /// Fetches this workspace's users, emoji, channels and user groups and
    /// replaces what is on disk. Callers that are about to connect should await
    /// it; the launch-time refresh does not, because the cached copy is good
    /// enough until it lands.
    func refresh(account: TootRainSlackAccount) async throws {
        guard let client = SlackAPIClient(account: account) else {
            throw SlackAPIError.missingAccessToken
        }
        let users = try await client.users()
        let emoji = try await client.emoji()

        // The channels and the user groups are names to put to the ids in a
        // message, which is worth having but not worth losing the rest of the
        // workspace over: a token granted before the server asked for these
        // scopes is refused them, and so is a workspace on a Slack plan that
        // has no user groups at all. Whichever is refused is kept as it was,
        // and the rest of the workspace is cached either way.
        let cached = snapshot(teamId: account.teamId)
        var channels = cached?.channels ?? []
        do {
            channels = try await client.conversations()
        } catch {
            NSLog("TootRain: could not list the channels of %@, keeping the %ld cached: %@",
                  account.teamName, channels.count, String(describing: error))
        }
        var userGroups = cached?.userGroups ?? []
        do {
            userGroups = try await client.userGroups()
        } catch {
            NSLog("TootRain: could not list the user groups of %@, keeping the %ld cached: %@",
                  account.teamName, userGroups.count, String(describing: error))
        }

        let snapshot = Snapshot(teamId: account.teamId,
                                updatedAt: Date(),
                                users: users,
                                emoji: emoji,
                                channels: channels,
                                userGroups: userGroups)
        store(snapshot)
        NSLog("TootRain: cached %ld Slack users, %ld emoji, %ld channels and %ld user groups for %@",
              users.count, emoji.count, channels.count, userGroups.count, account.teamName)
    }

    /// Keeps the cached channels in step with a list the channel picker has just
    /// fetched, so that the next picker opens on what Slack last said rather
    /// than on what the last launch saw. A workspace with nothing cached yet is
    /// left alone: the refresh that fills the rest in brings the channels too.
    func update(channels: [SlackChannel], teamId: String) {
        guard let current = snapshot(teamId: teamId) else { return }
        store(Snapshot(teamId: current.teamId,
                       updatedAt: current.updatedAt,
                       users: current.users,
                       emoji: current.emoji,
                       channels: channels,
                       userGroups: current.userGroups))
    }

    func removeCache(teamId: String) {
        queue.sync {
            snapshots.removeValue(forKey: teamId)
            indexes.removeValue(forKey: teamId)
            loadedTeamIds.remove(teamId)
        }
        try? FileManager.default.removeItem(at: SlackInfoCache.fileURL(teamId: teamId))
    }

    // MARK: - Storage

    private func index(teamId: String) -> Index? {
        queue.sync {
            load(teamId: teamId)
            return indexes[teamId]
        }
    }

    private func snapshot(teamId: String) -> Snapshot? {
        queue.sync {
            load(teamId: teamId)
            return snapshots[teamId]
        }
    }

    /// Reads the copy on disk, the first time anything asks about this
    /// workspace. Only ever called on `queue`.
    private func load(teamId: String) {
        guard !loadedTeamIds.contains(teamId) else { return }
        loadedTeamIds.insert(teamId)
        guard let snapshot = SlackInfoCache.readSnapshot(teamId: teamId) else { return }
        snapshots[teamId] = snapshot
        indexes[teamId] = SlackInfoCache.makeIndex(snapshot)
    }

    private func store(_ snapshot: Snapshot) {
        queue.sync {
            snapshots[snapshot.teamId] = snapshot
            indexes[snapshot.teamId] = SlackInfoCache.makeIndex(snapshot)
            loadedTeamIds.insert(snapshot.teamId)
        }
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(snapshot)
            let url = SlackInfoCache.fileURL(teamId: snapshot.teamId)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
        } catch {
            NSLog("TootRain: could not write the Slack cache for %@: %@",
                  snapshot.teamId, String(describing: error))
        }
    }

    private static func makeIndex(_ snapshot: Snapshot) -> Index {
        var usersById: [String: SlackCachedUser] = [:]
        for user in snapshot.users {
            usersById[user.id] = user
        }
        var emojiByName: [String: URL] = [:]
        for emoji in snapshot.emoji {
            emojiByName[emoji.name] = emoji.url
        }
        var channelsById: [String: SlackChannel] = [:]
        for channel in snapshot.channels ?? [] {
            channelsById[channel.id] = channel
        }
        var userGroupsById: [String: SlackUserGroup] = [:]
        for group in snapshot.userGroups ?? [] {
            userGroupsById[group.id] = group
        }
        return Index(usersById: usersById,
                     emojiByName: emojiByName,
                     channelsById: channelsById,
                     userGroupsById: userGroupsById,
                     updatedAt: snapshot.updatedAt)
    }

    private static func readSnapshot(teamId: String) -> Snapshot? {
        let url = fileURL(teamId: teamId)
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(Snapshot.self, from: data)
        } catch {
            NSLog("TootRain: could not read the Slack cache for %@: %@",
                  teamId, String(describing: error))
            return nil
        }
    }

    private static func fileURL(teamId: String) -> URL {
        return cacheDirectory.appendingPathComponent("\(teamId).json")
    }

    /// `~/Library/Caches`, not Application Support: every byte of this can be
    /// fetched from Slack again, and is, on the next launch — so the system is
    /// welcome to throw it away whenever it wants the space back. The directory
    /// itself is made on the way to writing a file, so it need not exist here.
    private static var cacheDirectory: URL {
        let name = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String ?? "TootRain"
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name, isDirectory: true)
            .appendingPathComponent("SlackCache", isDirectory: true)
    }
}
