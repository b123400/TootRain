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
}
