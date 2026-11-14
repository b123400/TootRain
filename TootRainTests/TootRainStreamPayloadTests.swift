//
//  TootRainStreamPayloadTests.swift
//  TootRainTests
//

import XCTest
@testable import TootRain

/// What arrives on the connection, in the shapes the server's
/// `Tootrain.Centrifugo.Event` and `Tootrain.Centrifugo.Message` build.
final class TootRainStreamPayloadTests: XCTestCase {

    private func payload(_ json: String) -> TootRainStreamPayload? {
        TootRainStreamPayload(data: Data(json.utf8))
    }

    func testMembershipRemoved() {
        let json = #"{"type":"event","event":"slack:membership_removed","slack":{"team_id":"T1","channel_id":"C1"}}"#
        guard case .event(.slackMembershipRemoved(let teamId, let channelId))? = payload(json) else {
            return XCTFail("not read as a membership removal")
        }
        XCTAssertEqual(teamId, "T1")
        XCTAssertEqual(channelId, "C1")
    }

    func testLinkageRemoved() {
        guard case .event(.linkageRemoved(let linkageId))? =
                payload(#"{"type":"event","event":"linkage_removed","linkage_id":42}"#) else {
            return XCTFail("not read as a linkage removal")
        }
        XCTAssertEqual(linkageId, 42)
    }

    func testSessionRemoved() {
        guard case .event(.sessionRemoved)? = payload(#"{"type":"event","event":"session_removed"}"#) else {
            return XCTFail("not read as the session going")
        }
    }

    /// Each of these costs one payload, never the connection.
    func testWhatCannotBeReadIsDropped() {
        XCTAssertNil(payload(#"{"type":"event","event":"slack:membership_removed","slack":{"team_id":"T1"}}"#))
        XCTAssertNil(payload(#"{"type":"event","event":"slack:membership_removed"}"#))
        XCTAssertNil(payload(#"{"type":"event","event":"linkage_removed"}"#))
        XCTAssertNil(payload(#"{"type":"event","event":"linkage_removed","linkage_id":"42"}"#))
        XCTAssertNil(payload(#"{"type":"event","event":"something_new"}"#))
        XCTAssertNil(payload(#"{"type":"event"}"#))
        XCTAssertNil(payload(#"{"type":"something_new"}"#))
        XCTAssertNil(payload(#"[]"#))
        XCTAssertNil(payload("not json"))
    }

    func testSlackMessage() {
        let json = #"{"type":"message","provider":"slack","text":"hi <@U1>","slack":{"ts":"1793330594.626479","user":"U1","channel_id":"C1","team_id":"T1","client_msg_id":"9c145303"}}"#
        guard case .message(let message)? = payload(json),
              let origin = SlackMessageOrigin(message: message) else {
            return XCTFail("not read as a Slack message")
        }
        XCTAssertEqual(message.text, "hi <@U1>")
        XCTAssertEqual(origin.ts, "1793330594.626479")
        XCTAssertEqual(origin.userId, "U1")
        XCTAssertEqual(origin.channelId, "C1")
        XCTAssertEqual(origin.teamId, "T1")
    }

    /// The server sends every key, as null when Slack had nothing for it.
    func testSlackMessageWithNobodyBehindIt() {
        let json = #"{"type":"message","provider":"slack","text":"x","slack":{"ts":"1.2","user":null,"channel_id":"C1","team_id":"T1","client_msg_id":null}}"#
        guard case .message(let message)? = payload(json),
              let origin = SlackMessageOrigin(message: message) else {
            return XCTFail("not read as a Slack message")
        }
        XCTAssertNil(origin.userId)
    }

    func testMessageThatDoesNotSayWhereItCameFrom() {
        let json = #"{"type":"message","provider":"slack","text":"x","slack":{"ts":"1.2","user":"U1","channel_id":null,"team_id":"T1"}}"#
        guard case .message(let message)? = payload(json) else {
            return XCTFail("not read as a message")
        }
        XCTAssertNil(SlackMessageOrigin(message: message))
    }

    func testMessageFromAnotherService() {
        guard case .message(let message)? =
                payload(#"{"type":"message","provider":"other","text":"x","other":{}}"#) else {
            return XCTFail("not read as a message")
        }
        XCTAssertNil(SlackMessageOrigin(message: message))
    }
}
