//
//  SlackMessageTextTests.swift
//  TootRainTests
//

import XCTest
@testable import TootRain

/// Slack's mrkdwn as the renderer puts it on screen, for two teams: one whose
/// users, groups, channels and emoji are cached as a refresh leaves them, and
/// one with nothing cached, where an id is named by the message's own label or
/// left as the id.
final class SlackMessageTextTests: XCTestCase {

    private let teamId = "T-TOOTRAIN-TESTS"
    private let cachedTeamId = "T-TOOTRAIN-TESTS-CACHED"

    override func setUp() {
        super.setUp()
        SlackInfoCache.shared.update(
            users: [SlackCachedUser(id: "U1", name: "alice", realName: "Alice Liddell",
                                    displayName: "Alice", avatarURL: nil),
                    SlackCachedUser(id: "U2", name: "bob", realName: "Bob Builder",
                                    displayName: "", avatarURL: nil)],
            emoji: [SlackCachedEmoji(name: "parrot",
                                     url: URL(string: "https://emoji.example/parrot.gif")!)],
            channels: [SlackChannel(id: "C1", name: "general", isPrivate: false, isMember: true)],
            userGroups: [SlackUserGroup(id: "S1", name: "Developers", handle: "devs"),
                         SlackUserGroup(id: "S2", name: "Design", handle: nil)],
            teamId: cachedTeamId)
    }

    override func tearDown() {
        SlackInfoCache.shared.removeCache(teamId: cachedTeamId)
        super.tearDown()
    }

    private func html(_ text: String) -> String {
        SlackMessageText.htmlForText(text, teamId: teamId)
    }

    private func cachedHTML(_ text: String) -> String {
        SlackMessageText.htmlForText(text, teamId: cachedTeamId)
    }

    /// As Slack shows them: a person by the name they chose, or else their real
    /// name, and a group by its handle, or else its title.
    func testMentionsNamedFromTheCache() {
        XCTAssertEqual(cachedHTML("hi <@U1> and <@U2>"), "hi @Alice and @Bob Builder")
        XCTAssertEqual(cachedHTML("<!subteam^S1> <!subteam^S2>"), "@devs @Design")
        XCTAssertEqual(cachedHTML("<#C1>"), "#general")
        // A label Slack sent beats the cache.
        XCTAssertEqual(cachedHTML("<#C1|old-name> <!subteam^S1|@team>"), "#old-name @team")
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

    /// The workspace's own emoji is an image, which the importer fetches; a skin
    /// tone has no image of its own and goes.
    func testEmojiWithAnImage() {
        XCTAssertEqual(cachedHTML("so :parrot:"), #"so <img src="https://emoji.example/parrot.gif">"#)
        XCTAssertEqual(cachedHTML(":parrot::skin-tone-2:!"), #"<img src="https://emoji.example/parrot.gif">!"#)
    }

    /// Slack's standard emoji are not in what emoji.list answers with.
    func testEmojiWithoutAnImage() {
        XCTAssertEqual(html(":smile::skin-tone-2: at 10:30:45"), ":smile: at 10:30:45")
        XCTAssertEqual(cachedHTML(":smile:"), ":smile:")
    }

    func testAttributedString() {
        // A path, since the importer gives a bare host a trailing slash.
        let rendered = SlackMessageText.attributedStringForText("a <@U1> &amp; <https://example.com/page|b>",
                                                                teamId: teamId)
        XCTAssertEqual(rendered.string.trimmingCharacters(in: .whitespacesAndNewlines), "a @U1 & b")
        let label = (rendered.string as NSString).range(of: "b", options: .backwards)
        let link = rendered.attribute(.link, at: label.location, effectiveRange: nil)
        XCTAssertEqual((link as? URL)?.absoluteString, "https://example.com/page")
    }
}
