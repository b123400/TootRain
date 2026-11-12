//
//  SlackMessageOrigin.swift
//  TootRain
//
//  Created by b123400 on 2026/10/30.
//

import Foundation

/// Where a Slack message came from, read out of the provider's half of a
/// `TootRainStreamMessage`.
struct SlackMessageOrigin {
    /// Slack's id for the message and its time at once.
    let ts: String
    let channelId: String
    let teamId: String
    /// Missing on a message with nobody behind it, a workspace's own bot being
    /// the usual one.
    let userId: String?
    let clientMessageId: String?

    init?(message: TootRainStreamMessage) {
        guard message.provider == "slack" else { return nil }
        let json = message.providerData
        guard let ts = json["ts"] as? String, !ts.isEmpty,
              let channelId = json["channel_id"] as? String, !channelId.isEmpty,
              let teamId = json["team_id"] as? String, !teamId.isEmpty else {
            return nil
        }
        self.ts = ts
        self.channelId = channelId
        self.teamId = teamId
        self.userId = json["user"] as? String
        self.clientMessageId = json["client_msg_id"] as? String
    }
}
