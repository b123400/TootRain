//
//  SlackStatusTests.swift
//  TootRainTests
//

import XCTest
@testable import TootRain

/// A Slack message as the status the flood window shows.
final class SlackStatusTests: XCTestCase {

    private func account(teamDomain: String?) -> TootRainSlackAccount {
        TootRainSlackAccount(teamId: "T-TOOTRAIN-TESTS",
                             teamName: "Acme",
                             teamDomain: teamDomain,
                             slackUserId: "U0",
                             slackUserName: nil)
    }

    func testStatus() {
        let status = SlackStatus(text: "hi",
                                 ts: "1793330594.626479",
                                 userId: "U1",
                                 channelId: "C1",
                                 account: account(teamDomain: "acme.slack.com"))
        // The id is what keeps a message carried twice from being shown twice.
        XCTAssertEqual(status.statusID, "tootrain-slack:T-TOOTRAIN-TESTS:C1:1793330594.626479")
        XCTAssertEqual(status.createdAt?.timeIntervalSince1970 ?? 0, 1793330594.626479, accuracy: 0.000001)
        XCTAssertEqual(status.url, URL(string: "https://acme.slack.com/archives/C1/p1793330594626479"))
        XCTAssertEqual(status.text, "hi")
        XCTAssertEqual(status.user?.userID, "U1")
        XCTAssertEqual(status.user?.screenName, "U1")
    }

    func testNoLinkWithoutTheWorkspaceHost() {
        let status = SlackStatus(text: "hi", ts: "1.2", userId: "U1", channelId: "C1",
                                 account: account(teamDomain: nil))
        XCTAssertNil(status.url)
    }

    func testNobodyBehindItIsTheWorkspace() {
        let status = SlackStatus(text: "hi", ts: "1.2", userId: nil, channelId: "C1",
                                 account: account(teamDomain: nil))
        XCTAssertEqual(status.user?.userID, "T-TOOTRAIN-TESTS")
        XCTAssertEqual(status.user?.screenName, "Acme")
    }

    /// A display name is not mrkdwn, so nothing in it is read as markup.
    func testScreenNameIsPlain() {
        let user = SlackUser(id: nil, account: TootRainSlackAccount(teamId: "T-TOOTRAIN-TESTS",
                                                                    teamName: "<Acme> & co",
                                                                    teamDomain: nil,
                                                                    slackUserId: "U0",
                                                                    slackUserName: nil))
        XCTAssertEqual(user.attributedScreenName().string, "<Acme> & co")
    }
}
