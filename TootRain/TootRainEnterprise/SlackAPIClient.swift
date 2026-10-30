//
//  SlackAPIClient.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation

struct SlackIdentity {
    let teamId: String
    let teamName: String
    let userId: String
    let userName: String?
    let url: URL?
}

struct SlackCachedUser: Codable, Equatable {
    let id: String
    let name: String
    let realName: String?
    let displayName: String?
    let avatarURL: URL?

    /// What a rain drop should be labelled with: the name the user chose for
    /// themselves, falling back to their real name and then their handle.
    var preferredName: String {
        if let displayName = displayName, !displayName.isEmpty { return displayName }
        if let realName = realName, !realName.isEmpty { return realName }
        return name
    }
}

struct SlackCachedEmoji: Codable, Equatable {
    let name: String
    let url: URL
}

struct SlackChannel: Equatable {
    let id: String
    let name: String
    let isPrivate: Bool
    /// Whether the Slack account the app logged in with is in the channel. The
    /// TootRain server only grants a channel to someone who is in it, so one
    /// that is false here is not a channel the app can be given.
    let isMember: Bool
}

enum SlackAPIError: LocalizedError {
    case missingAccessToken
    case api(String)
    case http(status: Int)
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .missingAccessToken:
            return NSLocalizedString("This Slack workspace has no access token, please log in again.", comment: "slack error")
        case .api(let code):
            let format = NSLocalizedString("Slack refused the request: %@", comment: "slack error")
            return String(format: format, code)
        case .http(let status):
            let format = NSLocalizedString("Slack answered with %ld.", comment: "slack error")
            return String(format: format, status)
        case .malformedResponse:
            return NSLocalizedString("Slack sent a response TootRain could not read.", comment: "slack error")
        }
    }
}

/// The slice of Slack's Web API the app needs: who it is talking as, and the
/// workspace information a rain drop has to be rendered with.
final class SlackAPIClient {

    private static let pageSize = 200

    private let accessToken: String
    private let urlSession: URLSession

    init(accessToken: String, urlSession: URLSession = .shared) {
        self.accessToken = accessToken
        self.urlSession = urlSession
    }

    convenience init?(account: TootRainSlackAccount) {
        guard let token = account.accessToken, !token.isEmpty else { return nil }
        self.init(accessToken: token)
    }

    // MARK: - Methods

    func identity() async throws -> SlackIdentity {
        let json = try await get("auth.test")
        guard let teamId = json["team_id"] as? String,
              let userId = json["user_id"] as? String else {
            throw SlackAPIError.malformedResponse
        }
        return SlackIdentity(teamId: teamId,
                             teamName: json["team"] as? String ?? teamId,
                             userId: userId,
                             userName: json["user"] as? String,
                             url: (json["url"] as? String).flatMap(URL.init(string:)))
    }

    func users() async throws -> [SlackCachedUser] {
        var users: [SlackCachedUser] = []
        var cursor: String?
        repeat {
            var query = [URLQueryItem(name: "limit", value: String(SlackAPIClient.pageSize))]
            if let cursor = cursor {
                query.append(URLQueryItem(name: "cursor", value: cursor))
            }
            let json = try await get("users.list", query: query)
            for member in json["members"] as? [[String: Any]] ?? [] {
                if let user = SlackAPIClient.user(from: member) {
                    users.append(user)
                }
            }
            cursor = SlackAPIClient.nextCursor(in: json)
        } while cursor != nil
        return users
    }

    func emoji() async throws -> [SlackCachedEmoji] {
        let json = try await get("emoji.list")
        guard let raw = json["emoji"] as? [String: String] else {
            throw SlackAPIError.malformedResponse
        }
        return SlackAPIClient.resolveEmojiAliases(raw)
    }

    func conversations() async throws -> [SlackChannel] {
        var channels: [SlackChannel] = []
        var cursor: String?
        repeat {
            var query = [
                URLQueryItem(name: "limit", value: String(SlackAPIClient.pageSize)),
                URLQueryItem(name: "types", value: "public_channel,private_channel"),
                URLQueryItem(name: "exclude_archived", value: "true"),
            ]
            if let cursor = cursor {
                query.append(URLQueryItem(name: "cursor", value: cursor))
            }
            let json = try await get("conversations.list", query: query)
            for channel in json["channels"] as? [[String: Any]] ?? [] {
                guard let id = channel["id"] as? String,
                      let name = channel["name"] as? String else { continue }
                channels.append(SlackChannel(id: id,
                                             name: name,
                                             isPrivate: channel["is_private"] as? Bool ?? false,
                                             isMember: channel["is_member"] as? Bool ?? true))
            }
            cursor = SlackAPIClient.nextCursor(in: json)
        } while cursor != nil
        return channels
    }

    // MARK: - Parsing

    private static func user(from member: [String: Any]) -> SlackCachedUser? {
        guard let id = member["id"] as? String else { return nil }
        let profile = member["profile"] as? [String: Any] ?? [:]
        let avatar = (profile["image_192"] as? String) ?? (profile["image_72"] as? String)
        let displayName = (profile["display_name"] as? String).flatMap { $0.isEmpty ? nil : $0 }
        return SlackCachedUser(id: id,
                               name: member["name"] as? String ?? id,
                               realName: member["real_name"] as? String ?? profile["real_name"] as? String,
                               displayName: displayName,
                               avatarURL: avatar.flatMap(URL.init(string:)))
    }

    /// `emoji.list` answers with either a URL or `alias:other-emoji`; follow the
    /// aliases so every name the app caches points at an image.
    static func resolveEmojiAliases(_ raw: [String: String]) -> [SlackCachedEmoji] {
        var resolved: [SlackCachedEmoji] = []
        for (name, value) in raw {
            var target = value
            var hops = 0
            while target.hasPrefix("alias:"), hops < 10 {
                let aliased = String(target.dropFirst("alias:".count))
                guard let next = raw[aliased] else { break }
                target = next
                hops += 1
            }
            guard !target.hasPrefix("alias:"), let url = URL(string: target) else { continue }
            resolved.append(SlackCachedEmoji(name: name, url: url))
        }
        return resolved.sorted { $0.name < $1.name }
    }

    private static func nextCursor(in json: [String: Any]) -> String? {
        let metadata = json["response_metadata"] as? [String: Any]
        guard let cursor = metadata?["next_cursor"] as? String, !cursor.isEmpty else {
            return nil
        }
        return cursor
    }

    // MARK: - Transport

    private func get(_ method: String, query: [URLQueryItem] = []) async throws -> [String: Any] {
        var components = URLComponents(string: "https://slack.com/api/\(method)")!
        components.queryItems = query.isEmpty ? nil : query
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded; charset=utf-8",
                         forHTTPHeaderField: "Content-Type")
        request.setValue(TootRainUserAgent.current, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await urlSession.tootRainData(for: request)
        guard (200..<300).contains(response.statusCode) else {
            throw SlackAPIError.http(status: response.statusCode)
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SlackAPIError.malformedResponse
        }
        guard json["ok"] as? Bool == true else {
            throw SlackAPIError.api(json["error"] as? String ?? "unknown")
        }
        return json
    }
}
