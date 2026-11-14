//
//  TootRainChannelMembershipUpdateTests.swift
//  TootRainTests
//

import XCTest
@testable import TootRain

/// What a workspace keeps of the server's answer to `PUT
/// /api/slack/channel_memberships`, in the shape
/// `TootrainWeb.SlackMembershipController.update/2` builds.
final class TootRainChannelMembershipUpdateTests: XCTestCase {

    /// Linkage 1 asked for C1, C2 and C3 and left C4 out. C1 was granted, Slack
    /// could not be reached for C2, the user is not in C3, and Centrifugo
    /// refused to unsubscribe C4, so its row is back in `memberships`.
    func testUpstreamErrorLeavesThePairAsAsked() throws {
        let json = #"""
        {"memberships": [
           {"linkage_id": 1, "team_id": "T1", "channel_id": "C1", "name": "general", "channel": "slack:T1:C1"},
           {"linkage_id": 1, "team_id": "T1", "channel_id": "C4", "name": "random", "channel": "slack:T1:C4"},
           {"linkage_id": 2, "team_id": "T1", "channel_id": "C5", "name": "other", "channel": "slack:T1:C5"}],
         "added": [],
         "removed": [],
         "rejected": [
           {"linkage_id": 1, "channel_id": "C2", "error": "upstream_error"},
           {"linkage_id": 1, "channel_id": "C3", "error": "not_a_member"},
           {"linkage_id": 1, "channel_id": "C4", "error": "upstream_error"}]}
        """#
        let update = try JSONDecoder().decode(TootRainChannelMembershipUpdate.self,
                                              from: Data(json.utf8))
        let asked = ["C1": "general", "C2": "dev", "C3": "secret"]
        XCTAssertEqual(update.channels(linkageId: 1, asked: asked), ["C1": "general", "C2": "dev"])
    }

    /// Channels refused for the same reason are told as one, in the order the
    /// reasons first come up, with the help page the server sent for it.
    func testRejectionsAreGroupedByReason() throws {
        let json = #"""
        [{"linkage_id": 1, "channel_id": "C1", "error": "bot_not_in_channel", "help_url": "https://example.com/docs/show_messages#add-bot"},
         {"linkage_id": 1, "channel_id": "C2", "error": "not_a_member"},
         {"linkage_id": 1, "channel_id": "C3", "error": "bot_not_in_channel", "help_url": "https://example.com/docs/show_messages#add-bot"},
         {"linkage_id": 1, "channel_id": "C4", "error": "slack_error", "detail": "missing_scope", "help_url": "javascript:alert(1)"},
         {"linkage_id": 1, "channel_id": "C5", "error": "slack_error", "detail": "ratelimited"},
         {"linkage_id": 1, "channel_id": "C6", "error": "not_a_member"}]
        """#
        let rejections = try JSONDecoder().decode([TootRainChannelMembershipRejection].self,
                                                  from: Data(json.utf8))
        let groups = TootRainChannelMembershipRejection.grouped(rejections)
        XCTAssertEqual(groups.map { $0.code },
                       ["bot_not_in_channel", "not_a_member", "slack_error", "slack_error"])
        XCTAssertEqual(groups.map { $0.channelIds }, [["C1", "C3"], ["C2", "C6"], ["C4"], ["C5"]])
        // Only a web address is a help page.
        XCTAssertEqual(groups.map { $0.helpURL?.absoluteString },
                       ["https://example.com/docs/show_messages#add-bot", nil, nil, nil])
    }
}
