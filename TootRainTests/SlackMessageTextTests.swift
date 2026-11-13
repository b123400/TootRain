//
//  SlackMessageTextTests.swift
//  TootRainTests
//

import XCTest
@testable import TootRain

/// Slack's mrkdwn as the renderer puts it on screen. Nothing is cached for this
/// team, so every id is named by the message's own label or left as the id.
final class SlackMessageTextTests: XCTestCase {

    private let teamId = "T-TOOTRAIN-TESTS"

    private func html(_ text: String) -> String {
        SlackMessageText.htmlForText(text, teamId: teamId)
    }

    func testMentions() {
        XCTAssertEqual(html("hi <@U1>"), "hi @U1")
        XCTAssertEqual(html("<#C1|general> <#C2>"), "#general #C2")
        XCTAssertEqual(html("<!subteam^S1|@devs> <!subteam^S2>"), "@devs @S2")
        XCTAssertEqual(html("<!here> <!channel|@channel> <!everyone>"), "@here @channel @everyone")
    }

    func testLinks() {
        XCTAssertEqual(html("see <https://example.com|the site>"),
                       #"see <a href="https://example.com">the site</a>"#)
        XCTAssertEqual(html("<https://a.example/?x=1&amp;y=2>"),
                       #"<a href="https://a.example/?x=1&amp;y=2">https://a.example/?x=1&amp;y=2</a>"#)
        // Nowhere a click could go, so only the words.
        XCTAssertEqual(html("<example.com|site>"), "site")
    }

    /// Slack sends &, < and > escaped, and they go out escaped for HTML.
    func testEscaping() {
        XCTAssertEqual(html("1 &lt; 2 &amp;&amp; 3 &gt; 2"), "1 &lt; 2 &amp;&amp; 3 &gt; 2")
        XCTAssertEqual(html("<oops"), "&lt;oops")
        XCTAssertEqual(html("line\nbreak"), "line<br>break")
    }

    func testDateShowsItsFallback() {
        XCTAssertEqual(html("<!date^1392734382^{date} at {time}|Feb 18th, 2014 at 6:39 AM>"),
                       "Feb 18th, 2014 at 6:39 AM")
        XCTAssertEqual(html("<!date^1392734382^{date_num}^https://example.com|2014-02-18 &amp; on>"),
                       "2014-02-18 &amp; on")
        XCTAssertEqual(html("<!date^1392734382^{date}>"), "")
    }

    /// Only a workspace's own emoji has an image; a skin tone never does.
    func testEmojiWithoutAnImage() {
        XCTAssertEqual(html(":smile::skin-tone-2: at 10:30:45"), ":smile: at 10:30:45")
    }

    func testAttributedString() {
        let rendered = SlackMessageText.attributedStringForText("a <@U1> &amp; <https://example.com|b>",
                                                                teamId: teamId)
        XCTAssertEqual(rendered.string.trimmingCharacters(in: .whitespacesAndNewlines), "a @U1 & b")
        let label = (rendered.string as NSString).range(of: "b", options: .backwards)
        let link = rendered.attribute(.link, at: label.location, effectiveRange: nil)
        XCTAssertEqual((link as? URL)?.absoluteString, "https://example.com")
    }
}
