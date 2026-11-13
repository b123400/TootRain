//
//  TootRainServerAPI.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation

/// A channel this app session is listening to. `channel` is the Centrifugo
/// channel name — the server builds it and the app only ever passes it along,
/// never assembles or takes one apart.
struct TootRainChannelMembership: Decodable, Equatable {
    /// The Slack account that earned this channel, by the server's own id for
    /// it. The same vocabulary the app states its own set in, so an answer can
    /// be read straight back into the accounts it came from.
    let linkageId: Int
    let teamId: String
    let channelId: String
    /// What Slack last called the channel. The server keeps it so a listing can
    /// be shown without asking Slack again.
    let name: String?
    let channel: String

    enum CodingKeys: String, CodingKey {
        case linkageId = "linkage_id"
        case teamId = "team_id"
        case channelId = "channel_id"
        case name
        case channel
    }
}

/// One pair of the set the app states: a Slack account of this session, by the
/// server's own linkage id, and one channel of that account.
struct TootRainChannelMembershipPair: Encodable, Equatable, Hashable {
    let linkageId: Int
    let channelId: String

    enum CodingKeys: String, CodingKey {
        case linkageId = "linkage_id"
        case channelId = "channel_id"
    }
}

/// A pair the server would not grant. One of these does not fail the request:
/// a channel the bot was never invited to must not take the others down with
/// it, so each pair is settled on its own and the ones that did not happen come
/// back here.
struct TootRainChannelMembershipRejection: Decodable, Equatable {
    let linkageId: Int
    let channelId: String
    /// The server's code for why, read the same way as a refused request's.
    let error: String
    let detail: String?

    enum CodingKeys: String, CodingKey {
        case linkageId = "linkage_id"
        case channelId = "channel_id"
        case error
        case detail
    }

    /// Why this pair did not happen, in words for the user.
    var reason: TootRainServerError {
        TootRainServerError.named(code: error, detail: detail)
    }
}

/// What the server answers when the app has stated its whole set. `memberships`
/// is what the session holds afterwards and is the part to settle on: it may be
/// less than what was asked for, since `rejected` says what did not happen.
struct TootRainChannelMembershipUpdate: Decodable {
    let memberships: [TootRainChannelMembership]
    let added: [TootRainChannelMembership]
    let removed: [TootRainChannelMembership]
    let rejected: [TootRainChannelMembershipRejection]

    /// What one Slack account of the session is to keep: Slack's channel ids,
    /// and what Slack last called each of them. A channel the server knows no
    /// name for is named by its id, so there is always something to show.
    ///
    /// That is what it ended up holding, except where the server answered
    /// `upstream_error`: Centrifugo or Slack was out of reach, which says
    /// nothing about the channel, so it stays as `asked`, the channels the app
    /// stated for this account, has it — kept under that name if it was to be
    /// added, left out if it was to be taken away, though the server put its
    /// row back — and the next statement asks again.
    func channels(linkageId: Int, asked: [String: String]) -> [String: String] {
        var channels: [String: String] = [:]
        for membership in memberships where membership.linkageId == linkageId {
            let name = membership.name ?? ""
            channels[membership.channelId] = name.isEmpty ? membership.channelId : name
        }
        for rejection in rejections(linkageId: linkageId) {
            if case .upstream = rejection.reason {
                // nil for a channel that was not asked for, which takes it out.
                channels[rejection.channelId] = asked[rejection.channelId]
            }
        }
        return channels
    }

    func rejections(linkageId: Int) -> [TootRainChannelMembershipRejection] {
        rejected.filter { $0.linkageId == linkageId }
    }
}

/// Everything the server says this app session is: the Slack accounts on it,
/// and what each of them is listening to. Asked for at startup, which is also
/// how the app finds out that a session an administrator took away is gone —
/// that answer is a 401 rather than this.
struct TootRainSessionOverview: Decodable {

    struct Session: Decodable {
        let id: Int
        let userAgent: String?

        enum CodingKeys: String, CodingKey {
            case id
            case userAgent = "user_agent"
        }
    }

    /// One Slack account on the session. `id` is the server's own, and the only
    /// id here that is not Slack's: it is what names this account when the app
    /// gives it up, since a session can hold two accounts of one workspace.
    struct SlackLinkage: Decodable {

        struct Workspace: Decodable {
            let teamId: String
            let name: String?

            enum CodingKeys: String, CodingKey {
                case teamId = "team_id"
                case name
            }
        }

        struct Membership: Decodable {
            let channelId: String
            let name: String?
            let channel: String

            enum CodingKeys: String, CodingKey {
                case channelId = "channel_id"
                case name
                case channel
            }
        }

        let id: Int
        let slackUserId: String
        let displayName: String?
        let workspace: Workspace
        let memberships: [Membership]

        enum CodingKeys: String, CodingKey {
            case id
            case slackUserId = "slack_user_id"
            case displayName = "display_name"
            case workspace
            case memberships
        }
    }

    struct Slack: Decodable {
        let linkages: [SlackLinkage]
    }

    let session: Session
    let slack: Slack

    /// The account the app has saved for this workspace, as the server sees it.
    /// Nothing comes back when the server no longer has it — an administrator
    /// having removed the linkage — which is the app's cue to ask the user to
    /// authorise it again.
    func slackLinkage(teamId: String, slackUserId: String) -> SlackLinkage? {
        slack.linkages.first { $0.workspace.teamId == teamId && $0.slackUserId == slackUserId }
    }
}

/// What the server answers when the app gives up a Slack account. It says which
/// account went, by Slack's ids, and whether the session went with it — which it
/// does when that was the last account on it, there being nothing left for the
/// session to be.
struct TootRainLinkageRemoval: Decodable {

    struct Linkage: Decodable {
        let id: Int
        let teamId: String
        let slackUserId: String

        enum CodingKeys: String, CodingKey {
            case id
            case teamId = "team_id"
            case slackUserId = "slack_user_id"
        }
    }

    let linkage: Linkage
    let sessionDeleted: Bool

    enum CodingKeys: String, CodingKey {
        case linkage
        case sessionDeleted = "session_deleted"
    }
}

/// How the server answers a listing: `{"memberships": [...]}`.
private struct TootRainChannelMembershipList: Decodable {
    let memberships: [TootRainChannelMembership]
}

/// How the app states its set: `{"memberships": [{...}]}`, the whole of it.
private struct TootRainChannelMembershipRequest: Encodable {
    let memberships: [TootRainChannelMembershipPair]
}

/// How it answers a refusal: `{"error": "<code>"}`, with a `detail` when the
/// code alone does not say enough.
private struct TootRainServerErrorBody: Decodable {
    let error: String
    let detail: String?
}

enum TootRainServerError: LocalizedError {
    case noSession
    case unauthorized
    case unknownWorkspace
    case notLinked
    case notAMember
    case botNotInChannel
    case slackRefused(String?)
    case upstream
    /// A refusal the server named and this app has no words of its own for.
    case refused(code: String)
    /// Not one of the server's own answers at all.
    case http(status: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .noSession:
            return NSLocalizedString("Please log in to TootRain with Slack first.", comment: "server error")
        case .unauthorized:
            return NSLocalizedString("This TootRain session is no longer valid, please log in again.", comment: "server error")
        case .unknownWorkspace:
            return NSLocalizedString("The TootRain server does not know this Slack workspace.", comment: "server error")
        case .notLinked:
            return NSLocalizedString("This Slack workspace is not linked to this TootRain session, please log in again.", comment: "server error")
        case .notAMember:
            return NSLocalizedString("You are not a member of this Slack channel, please join it in Slack first.", comment: "server error")
        case .botNotInChannel:
            return NSLocalizedString("Please invite the TootRain bot to this channel first.", comment: "server error")
        case .slackRefused(let detail):
            let format = NSLocalizedString("Slack refused the request: %@", comment: "slack error")
            return String(format: format, detail ?? "unknown")
        case .upstream:
            return NSLocalizedString("The TootRain server could not reach Slack, please try again later.", comment: "server error")
        case .refused(let code):
            let format = NSLocalizedString("The TootRain server refused the request: %@", comment: "server error")
            return String(format: format, code)
        case .http(let status, let body):
            let format = NSLocalizedString("The TootRain server answered with %ld: %@", comment: "server error")
            return String(format: format, status, body)
        }
    }

    /// Reads one of the server's own codes. The code is the part to act on, so
    /// an answer this app does not recognise is still reported by name rather
    /// than as a bare status. The same codes name a refused request and a pair
    /// of a set the server would not grant, so both are read here.
    static func named(code: String, detail: String?) -> TootRainServerError {
        switch code {
        case "workspace_not_found":
            return .unknownWorkspace
        case "not_linked":
            return .notLinked
        case "not_a_member":
            return .notAMember
        case "bot_not_in_channel":
            return .botNotInChannel
        case "slack_error":
            return .slackRefused(detail)
        case "upstream_error":
            return .upstream
        default:
            // `missing_params` and `invalid_membership` are this app's own bug
            // rather than anything the user can do something about, and are
            // reported by name for want of anything better to say.
            return .refused(code: code)
        }
    }
}

/// The HTTP surface of the TootRain server. Everything here authenticates with
/// the app session token; the session itself is created by the Slack log-in
/// redirect rather than by this client.
final class TootRainServerAPI {

    static let shared = TootRainServerAPI()

    private let environment: TootRainServerEnvironment
    private let session: TootRainAppSession
    private let urlSession: URLSession

    init(environment: TootRainServerEnvironment = .current,
         session: TootRainAppSession = .shared,
         urlSession: URLSession = .shared) {
        self.environment = environment
        self.session = session
        self.urlSession = urlSession
    }

    // MARK: - The session

    /// What this session is, as the server has it. A 401 here means the session
    /// itself is gone, which `TootRainServerError.unauthorized` reports.
    func session() async throws -> TootRainSessionOverview {
        let request = try authorizedRequest(path: "/api/session", method: "GET")
        let data = try await perform(request)
        return try decode(TootRainSessionOverview.self, from: data)
    }

    /// Gives up one Slack account of this session. Addressed by the server's own
    /// linkage id, which the session overview is where the app gets.
    @discardableResult
    func deleteLinkage(id: Int) async throws -> TootRainLinkageRemoval {
        let request = try authorizedRequest(path: "/api/slack/linkages/\(id)", method: "DELETE")
        let data = try await perform(request)
        return try decode(TootRainLinkageRemoval.self, from: data)
    }

    // MARK: - System constants

    /// The settings every app reads, as raw JSON. Needs no session, so this is
    /// the one request that goes out without a token.
    func systemConstants() async throws -> Data {
        var request = URLRequest(url: environment.apiURL(path: "/api/system_constants"))
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(TootRainUserAgent.current, forHTTPHeaderField: "User-Agent")
        let data = try await perform(request)
        guard (try? JSONSerialization.jsonObject(with: data)) is [String: Any] else {
            throw TootRainHTTPError.invalidResponse
        }
        return data
    }

    // MARK: - Slack channel memberships

    /// What the session is listening to, for one workspace or for all of them.
    func channelMemberships(teamId: String? = nil) async throws -> [TootRainChannelMembership] {
        let queryItems = teamId.map { [URLQueryItem(name: "team_id", value: $0)] } ?? []
        let request = try authorizedRequest(path: "/api/slack/channel_memberships",
                                            method: "GET",
                                            queryItems: queryItems)
        let data = try await perform(request)
        return try decode(TootRainChannelMembershipList.self, from: data).memberships
    }

    /// Makes this session's channels exactly this set, across every Slack
    /// account on it, and the server works out the difference from what it
    /// holds. The whole set and not a change to it, so an empty one gives
    /// everything up — which is also how a workspace is switched off, its pairs
    /// simply left out.
    ///
    /// A pair the server will not grant does not fail this: it comes back under
    /// `rejected`, and `memberships` is what the session holds afterwards.
    @discardableResult
    func replaceChannelMemberships(_ memberships: [TootRainChannelMembershipPair]) async throws
        -> TootRainChannelMembershipUpdate {
        var request = try authorizedRequest(path: "/api/slack/channel_memberships", method: "PUT")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder()
            .encode(TootRainChannelMembershipRequest(memberships: memberships))
        let data = try await perform(request)
        return try decode(TootRainChannelMembershipUpdate.self, from: data)
    }

    // MARK: - Requests

    private func authorizedRequest(path: String,
                                   method: String,
                                   queryItems: [URLQueryItem] = []) throws -> URLRequest {
        guard let token = session.token, !token.isEmpty else {
            throw TootRainServerError.noSession
        }
        var request = URLRequest(url: environment.apiURL(path: path, queryItems: queryItems))
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(TootRainUserAgent.current, forHTTPHeaderField: "User-Agent")
        return request
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.tootRainData(for: request)
        if (200..<300).contains(response.statusCode) {
            return data
        }
        throw TootRainServerAPI.refusal(status: response.statusCode, data: data)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw TootRainHTTPError.invalidResponse
        }
    }

    /// Reads one of the server's refusals, whose code is what the app acts on:
    /// the same codes name a pair of a set the server would not grant, so both
    /// are read by `TootRainServerError.named(code:detail:)`.
    private static func refusal(status: Int, data: Data) -> TootRainServerError {
        guard let body = try? JSONDecoder().decode(TootRainServerErrorBody.self, from: data) else {
            return .http(status: status, body: String(data: data, encoding: .utf8) ?? "")
        }
        // A dead session is answered with a sentence rather than a code, so
        // the status is what names that one.
        if status == 401 { return .unauthorized }
        return TootRainServerError.named(code: body.error, detail: body.detail)
    }
}

/// The server's system constants, as last fetched. Asked for at every launch
/// and saved, so a launch that cannot reach the server still has the last answer.
enum TootRainSystemConstants {

    private static let defaultsKey = "tootRainSystemConstants"

    static func refreshInBackground() {
        Task {
            do {
                // Saved as the raw JSON: user defaults cannot hold a JSON null.
                let data = try await TootRainServerAPI.shared.systemConstants()
                UserDefaults.standard.set(data, forKey: defaultsKey)
            } catch {
                NSLog("TootRain: could not fetch the system constants: %@", error.localizedDescription)
            }
        }
    }

    private static var saved: [String: Any] {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    /// `slack.oauth-user-agent`: what the Slack log-in web view calls itself.
    static var slackOAuthUserAgent: String? {
        let value = (saved["slack"] as? [String: Any])?["oauth-user-agent"] as? String
        return value?.isEmpty == false ? value : nil
    }

    /// `slack.enabled`: whether adding a Slack account is offered. Missing counts as false.
    static var slackEnabled: Bool {
        (saved["slack"] as? [String: Any])?["enabled"] as? Bool == true
    }
}
