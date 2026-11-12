//
//  SlackMembershipRemoval.swift
//  TootRain
//
//  Created by b123400 on 2026/11/01.
//

import Foundation

/// A channel of one Slack workspace this session has stopped hearing: the
/// TootRain bot taken out of it, the channel archived or deleted, or the app's
/// own asking.
///
/// The server has already let the membership go by the time this arrives, so
/// there is nothing to ask it for and nothing to undo.
struct SlackMembershipRemoval {

    /// What the event is called, after the `slack:` that says whose it is.
    static let eventName = "membership_removed"

    let teamId: String
    let channelId: String

    init?(event: TootRainStreamProviderEvent) {
        guard event.provider == "slack",
              event.event == SlackMembershipRemoval.eventName else {
            return nil
        }
        let json = event.providerData
        guard let teamId = json["team_id"] as? String, !teamId.isEmpty,
              let channelId = json["channel_id"] as? String, !channelId.isEmpty else {
            return nil
        }
        self.teamId = teamId
        self.channelId = channelId
    }
}
