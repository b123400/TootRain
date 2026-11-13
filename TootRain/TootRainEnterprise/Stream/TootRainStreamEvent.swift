//
//  TootRainStreamEvent.swift
//  TootRain
//
//  Created by b123400 on 2026/10/30.
//

import Foundation

/// Something that has happened rather than something to show: to this app
/// session, or in one of the services behind it. Each has gone at the server's
/// end by the time it arrives, so there is nothing to ask it for and nothing
/// to undo.
enum TootRainStreamEvent {
    /// A channel of one Slack workspace this session has stopped hearing.
    case slackMembershipRemoved(teamId: String, channelId: String)
    case linkageRemoved(linkageId: Int)
    /// The last thing the connection will carry.
    case sessionRemoved

    /// Nil for an event this version does not know, or one that does not say
    /// what it is about.
    init?(json: [String: Any]) {
        switch json["event"] as? String {
        case "slack:membership_removed":
            let slack = json["slack"] as? [String: Any]
            guard let teamId = slack?["team_id"] as? String, !teamId.isEmpty,
                  let channelId = slack?["channel_id"] as? String, !channelId.isEmpty else {
                return nil
            }
            self = .slackMembershipRemoved(teamId: teamId, channelId: channelId)
        case "linkage_removed":
            // Always a number, as the server's own ids are everywhere else.
            guard let linkageId = (json["linkage_id"] as? NSNumber)?.intValue else { return nil }
            self = .linkageRemoved(linkageId: linkageId)
        case "session_removed":
            self = .sessionRemoved
        default:
            return nil
        }
    }
}
