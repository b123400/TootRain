//
//  SlackStatus.swift
//  TootRain
//
//  Created by b123400 on 2026/10/30.
//

import Foundation
import Cocoa

/// Who wrote a message, as far as the workspace cache knows.
///
/// A message carries its author's id and nothing else, and the name and picture
/// that go with it were fetched when the workspace was last refreshed — so
/// somebody who joined since is shown by their id until the next launch brings
/// the cache up to date.
@objc(SlackUser)
class SlackUser: User {

    /// `id` is missing on a message with no person behind it, a workspace's own
    /// bot being the usual one. The workspace itself is then the nearest thing
    /// to an author there is.
    init(id: String?, account: TootRainSlackAccount) {
        let cached = id.flatMap { SlackInfoCache.shared.user(id: $0, teamId: account.teamId) }
        let name = cached?.preferredName ?? id ?? account.teamName
        super.init()
        userID = id ?? account.teamId
        username = cached?.name ?? id ?? account.teamName
        screenName = name
        profileImageURL = cached?.avatarURL
    }
}

/// One Slack message, as the status the rest of the app knows how to show.
///
/// Nothing here waits on the network — an emoji's image is asked for as the
/// text goes up and lands in place when it comes. Slack has nothing behind the
/// detail view's reply, favourite and boost buttons, so those stay as `Status`
/// leaves them, which is hidden.
@objc(SlackStatus)
class SlackStatus: Status {

    /// `ts` is Slack's id for the message and its time at once.
    @objc init(text: String,
               ts: String,
               userId: String?,
               channelId: String,
               account: TootRainSlackAccount) {
        super.init()
        statusID = "tootrain-slack:\(account.teamId):\(channelId):\(ts)"
        createdAt = SlackStatus.dateFromTimestamp(ts)
        self.text = text
        attributedText = SlackMessageText.attributedStringForText(text, teamId: account.teamId)
        user = SlackUser(id: userId, account: account)
        url = SlackStatus.permalinkURL(teamDomain: account.teamDomain,
                                       channelId: channelId,
                                       ts: ts)
    }

    /// A `ts` is seconds since the epoch with microseconds after the point:
    /// `1793330594.626479`.
    private static func dateFromTimestamp(_ ts: String) -> Date? {
        guard let seconds = Double(ts) else { return nil }
        return Date(timeIntervalSince1970: seconds)
    }

    /// The address Slack's own Copy link gives: the workspace's host, the
    /// channel, and the `ts` with its point taken out. Without a host there is
    /// nowhere to point at, and the detail view hides the button rather than
    /// offering a dead one.
    private static func permalinkURL(teamDomain: String?,
                                     channelId: String,
                                     ts: String) -> URL? {
        guard let teamDomain = teamDomain, !teamDomain.isEmpty else { return nil }
        let stamp = ts.replacingOccurrences(of: ".", with: "")
        guard !stamp.isEmpty, stamp.allSatisfy({ $0.isNumber }) else { return nil }
        return URL(string: "https://\(teamDomain)/archives/\(channelId)/p\(stamp)")
    }
}
