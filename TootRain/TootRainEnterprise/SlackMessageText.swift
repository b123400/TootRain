//
//  SlackMessageText.swift
//  TootRain
//
//  Created by b123400 on 2026/10/30.
//

import Foundation
import Cocoa

/// Turns the `text` of a Slack message into something to put on screen:
/// Slack's mrkdwn in, plain text with the workspace's emoji and live links out,
/// and the names behind its ids from `SlackInfoCache`. The marks bold and
/// italic are written with stay as characters — taking them out would mangle
/// `2*3` and `some_var_name`.
///
/// The way there is HTML, as it is for the other services: an emoji is an
/// `<img>`, so the system fetches it, keeps it, and shows the words before the
/// picture arrives.
@objc(SlackMessageText)
final class SlackMessageText: NSObject {

    static func attributedStringForText(_ text: String, teamId: String) -> NSAttributedString {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]
        guard let data = htmlForText(text, teamId: teamId).data(using: .utf8),
              let rendered = try? NSAttributedString(data: data,
                                                     options: options,
                                                     documentAttributes: nil) else {
            // The message still reads, with its ids in place of the names.
            return NSAttributedString(string: unescapedFromSlack(text))
        }
        return rendered
    }

    // MARK: - The HTML a message turns into

    static func htmlForText(_ text: String, teamId: String) -> String {
        var html = ""
        // Text read and not yet written out. Writing it a character at a time
        // would mean escaping it a character at a time.
        var pending = ""

        func flushPending() {
            guard !pending.isEmpty else { return }
            html += htmlEscapedText(unescapedFromSlack(pending))
            pending = ""
        }

        var index = text.startIndex
        while index < text.endIndex {
            let character = text[index]
            if character == "<" {
                flushPending()
                if let entity = entityInsideBrackets(in: text, from: index) {
                    html += htmlForEntity(entity.inside, teamId: teamId)
                    index = entity.end
                } else {
                    html += "&lt;"
                    index = text.index(after: index)
                }
                continue
            }
            if character == ":",
               let emoji = emojiImageTag(in: text, from: index, teamId: teamId) {
                flushPending()
                html += emoji.html
                index = emoji.end
                continue
            }
            pending.append(character)
            index = text.index(after: index)
        }
        flushPending()
        return html
    }

    // MARK: - Emoji

    /// `:emoji_name:`, where the workspace has one of its own by that name.
    /// Anything else stays as the colons and letters it came in as, Slack's
    /// standard emoji included: `emoji.list` does not answer for those.
    ///
    /// A skin tone is dropped — it arrives as its own shortcode after the emoji
    /// it belongs to, `:wave::skin-tone-3:`, and has no image.
    private static func emojiImageTag(in text: String,
                                      from start: String.Index,
                                      teamId: String) -> (html: String, end: String.Index)? {
        var index = text.index(after: start)
        var name = ""
        while index < text.endIndex {
            let character = text[index]
            if character == ":" {
                let end = text.index(after: index)
                if isSkinToneName(name) {
                    return ("", end)
                }
                guard let url = SlackInfoCache.shared.emojiURL(name: name, teamId: teamId) else {
                    return nil
                }
                return ("<img src=\"\(htmlEscapedAttribute(url.absoluteString))\">", end)
            }
            guard name.count < 100,
                  character.isLetter || character.isNumber || "_+-'’".contains(character) else {
                return nil
            }
            name.append(character)
            index = text.index(after: index)
        }
        return nil
    }

    private static func isSkinToneName(_ name: String) -> Bool {
        name.hasPrefix("skin-tone-") && name.count == "skin-tone-".count + 1
    }

    // MARK: - Entities

    /// What stands between a `<` and the next `>`, when that can only be
    /// Slack's own. A `<` the person typed arrives as `&lt;`, so one that never
    /// closes, closes on nothing, or holds another `<` was theirs after all.
    private static func entityInsideBrackets(in text: String, from start: String.Index)
        -> (inside: String, end: String.Index)? {
        guard let close = text[start...].firstIndex(of: ">") else { return nil }
        let inside = text[text.index(after: start)..<close]
        guard !inside.isEmpty, !inside.contains("<") else { return nil }
        return (String(inside), text.index(after: close))
    }

    private static func htmlForEntity(_ inside: String, teamId: String) -> String {
        // `<thing|label>`: the label is Slack's own word for what the thing
        // reads as, and it beats anything that can be worked out here.
        let (spec, label) = splitSpecAndLabel(inside)
        switch spec.first {
        case "@":
            let id = String(spec.dropFirst())
            let name = label ?? SlackInfoCache.shared.user(id: id, teamId: teamId)?.preferredName
            return htmlEscapedText(mentionText(sigil: "@", name: name ?? id))
        case "#":
            let id = String(spec.dropFirst())
            let name = label ?? SlackInfoCache.shared.channel(id: id, teamId: teamId)?.name
            return htmlEscapedText(mentionText(sigil: "#", name: name ?? id))
        case "!":
            return htmlForCommand(String(spec.dropFirst()), label: label, teamId: teamId)
        default:
            return htmlForLink(spec, label: label)
        }
    }

    /// `<!…>`: a user group, a date, or one of the mentions that stands for a
    /// set of people rather than for a person.
    private static func htmlForCommand(_ command: String,
                                       label: String?,
                                       teamId: String) -> String {
        if command.hasPrefix("subteam^") {
            let id = String(command.dropFirst("subteam^".count))
            let group = SlackInfoCache.shared.userGroup(id: id, teamId: teamId)
            let name = label ?? group?.handle ?? group?.name
            return htmlEscapedText(mentionText(sigil: "@", name: name ?? id))
        }
        // shortcut: a date reads as the fallback Slack requires, in the writer's
        // time zone and words; format its `^` fields if dates from bots matter.
        if command.hasPrefix("date^") {
            return htmlEscapedText(unescapedFromSlack(label ?? ""))
        }
        // @here, @channel, @everyone, and whatever else Slack comes to send.
        return htmlEscapedText(mentionText(sigil: "@", name: label ?? command))
    }

    /// Slack's own labels sometimes carry the sigil already: `<!here|@here>`
    /// does, `<#C1|general>` does not.
    private static func mentionText(sigil: String, name: String) -> String {
        let name = unescapedFromSlack(name)
        return name.hasPrefix(sigil) ? name : sigil + name
    }

    // MARK: - Links

    /// A link is the one thing here that keeps anything of its formatting: the
    /// label Slack sent, or the address itself when it sent none, and the
    /// address behind it either way.
    private static func htmlForLink(_ target: String, label: String?) -> String {
        let address = unescapedFromSlack(target)
        let text = htmlEscapedText(label.map(unescapedFromSlack) ?? displayTextForAddress(address))
        guard let url = urlFromTarget(target) else { return text }
        return htmlAnchor(url: url, text: text)
    }

    private static func htmlAnchor(url: URL, text: String) -> String {
        "<a href=\"\(htmlEscapedAttribute(url.absoluteString))\">\(text)</a>"
    }

    /// A mail or telephone link reads without the scheme in front, the way
    /// Slack shows those.
    private static func displayTextForAddress(_ address: String) -> String {
        for scheme in ["mailto:", "tel:"] where address.hasPrefix(scheme) {
            return String(address.dropFirst(scheme.count))
        }
        return address
    }

    /// An address with no scheme is nowhere a click could go: `URL(string:)`
    /// takes it as a relative path and there is nothing here to be relative to.
    private static func urlFromTarget(_ target: String) -> URL? {
        guard let url = URL(string: unescapedFromSlack(target)), url.scheme != nil else {
            return nil
        }
        return url
    }

    // MARK: - Slack's own escaping, and HTML's

    /// `thing|label`, where everything after the first bar is the label: a
    /// date's own `^` fields come before it.
    private static func splitSpecAndLabel(_ inside: String) -> (spec: String, label: String?) {
        guard let bar = inside.firstIndex(of: "|") else { return (inside, nil) }
        let label = String(inside[inside.index(after: bar)...])
        return (String(inside[inside.startIndex..<bar]), label.isEmpty ? nil : label)
    }

    /// The three characters Slack escapes, put back. The ampersand goes last:
    /// undoing it first would turn `&amp;lt;` into a `<` that nobody wrote.
    private static func unescapedFromSlack(_ text: String) -> String {
        guard text.contains("&") else { return text }
        return text
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
    }

    /// A newline has to be said in HTML's own way or the parser reads it as one
    /// more space.
    private static func htmlEscapedText(_ text: String) -> String {
        var html = ""
        for character in text {
            switch character {
            case "&": html += "&amp;"
            case "<": html += "&lt;"
            case ">": html += "&gt;"
            case "\n": html += "<br>"
            default: html.append(character)
            }
        }
        return html
    }

    private static func htmlEscapedAttribute(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
