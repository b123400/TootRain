//
//  TootRainStreamEvent.swift
//  TootRain
//
//  Created by b123400 on 2026/10/30.
//

import Foundation

/// Something that has happened rather than something to show: to this app
/// session, or in one of the services behind it.
enum TootRainStreamEvent {
    /// Nil when the event did not say which linkage, which leaves nothing to go
    /// on but asking the server again.
    case linkageRemoved(linkageId: Int?)
    /// The last thing the connection will carry.
    case sessionRemoved
    case provider(TootRainStreamProviderEvent)
    /// Something a later server knows about and this app does not.
    case unknown(String)

    init?(json: [String: Any]) {
        guard let event = json["event"] as? String, !event.isEmpty else { return nil }
        switch event {
        case "linkage_removed":
            // Always a number, as the server's own ids are everywhere else.
            self = .linkageRemoved(linkageId: (json["linkage_id"] as? NSNumber)?.intValue)
        case "session_removed":
            self = .sessionRemoved
        default:
            if let providerEvent = TootRainStreamProviderEvent(name: event, json: json) {
                self = .provider(providerEvent)
            } else {
                self = .unknown(event)
            }
        }
    }
}

/// One service's own news, named `<provider>:<event>`, with what it carries
/// under that service's own key exactly as a message's is.
/// `SlackMembershipRemoval` reads Slack's.
struct TootRainStreamProviderEvent {
    let provider: String
    /// What happened, with the provider and the colon taken off the front.
    let event: String
    let providerData: [String: Any]

    /// Nil for a name that is not a service's: no colon, or nothing either side
    /// of it.
    init?(name: String, json: [String: Any]) {
        guard let colon = name.firstIndex(of: ":") else { return nil }
        let provider = String(name[name.startIndex..<colon])
        let event = String(name[name.index(after: colon)...])
        guard !provider.isEmpty, !event.isEmpty else { return nil }
        self.provider = provider
        self.event = event
        self.providerData = json[provider] as? [String: Any] ?? [:]
    }
}
