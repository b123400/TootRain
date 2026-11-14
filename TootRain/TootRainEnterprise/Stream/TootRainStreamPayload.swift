//
//  TootRainStreamPayload.swift
//  TootRain
//
//  Created by b123400 on 2026/10/30.
//

import Foundation

/// What arrives on the connection, as the server's `docs/stream-schema.md` has
/// it: something to show, or something that has happened.
///
/// Nothing here is Slack's — a session and its linkages are the TootRain
/// server's own idea whatever service is behind them — and nothing is trusted
/// to be there: a `type` this version has never heard of costs one message
/// rather than the connection.
enum TootRainStreamPayload {
    case message(TootRainStreamMessage)
    case event(TootRainStreamEvent)

    init?(data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            return nil
        }
        switch json["type"] as? String {
        case "message":
            guard let message = TootRainStreamMessage(json: json) else { return nil }
            self = .message(message)
        case "event":
            guard let event = TootRainStreamEvent(json: json) else { return nil }
            self = .event(event)
        default:
            return nil
        }
    }
}

/// One message to show, in the part of its shape every provider shares.
/// `SlackMessageOrigin` reads Slack's own fields out of `providerData`.
struct TootRainStreamMessage {
    let provider: String
    let text: String
    let providerData: [String: Any]

    init?(json: [String: Any]) {
        guard let provider = json["provider"] as? String, !provider.isEmpty else { return nil }
        self.provider = provider
        self.text = json["text"] as? String ?? ""
        self.providerData = json[provider] as? [String: Any] ?? [:]
    }
}
