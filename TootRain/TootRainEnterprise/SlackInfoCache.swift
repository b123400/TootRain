//
//  SlackInfoCache.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation

/// The workspace information a Slack message has to be rendered with: who wrote
/// it and what its custom emoji look like. A message arrives with ids only, so
/// this is fetched up front — once when a workspace is linked, before the app
/// connects, and again in the background on every launch. Lookups in between are
/// served from the copy on disk.
final class SlackInfoCache {

    static let shared = SlackInfoCache()

    private struct Snapshot: Codable {
        let teamId: String
        let updatedAt: Date
        let users: [SlackCachedUser]
        let emoji: [SlackCachedEmoji]
    }

    private struct Index {
        let usersById: [String: SlackCachedUser]
        let emojiByName: [String: URL]
        let updatedAt: Date
    }

    private let queue = DispatchQueue(label: "net.b123400.tootrain.slack-info-cache")
    private var indexes: [String: Index] = [:]
    private var loadedTeamIds: Set<String> = []

    // MARK: - Lookups

    func user(id: String, teamId: String) -> SlackCachedUser? {
        index(teamId: teamId)?.usersById[id]
    }

    func emojiURL(name: String, teamId: String) -> URL? {
        index(teamId: teamId)?.emojiByName[name]
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

    /// Fetches this workspace's users and emoji and replaces what is on disk.
    /// Callers that are about to connect should await it; the launch-time refresh
    /// does not, because the cached copy is good enough until it lands.
    func refresh(account: TootRainSlackAccount) async throws {
        guard let client = SlackAPIClient(account: account) else {
            throw SlackAPIError.missingAccessToken
        }
        let users = try await client.users()
        let emoji = try await client.emoji()
        let snapshot = Snapshot(teamId: account.teamId,
                                updatedAt: Date(),
                                users: users,
                                emoji: emoji)
        store(snapshot)
        NSLog("TootRain: cached %ld Slack users and %ld emoji for %@",
              users.count, emoji.count, account.teamName)
    }

    func removeCache(teamId: String) {
        queue.sync {
            indexes.removeValue(forKey: teamId)
            loadedTeamIds.remove(teamId)
        }
        try? FileManager.default.removeItem(at: SlackInfoCache.fileURL(teamId: teamId))
    }

    // MARK: - Storage

    private func index(teamId: String) -> Index? {
        queue.sync {
            if !loadedTeamIds.contains(teamId) {
                loadedTeamIds.insert(teamId)
                if let snapshot = SlackInfoCache.readSnapshot(teamId: teamId) {
                    indexes[teamId] = SlackInfoCache.makeIndex(snapshot)
                }
            }
            return indexes[teamId]
        }
    }

    private func store(_ snapshot: Snapshot) {
        queue.sync {
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
        return Index(usersById: usersById, emojiByName: emojiByName, updatedAt: snapshot.updatedAt)
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
