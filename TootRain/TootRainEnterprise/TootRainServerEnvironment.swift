//
//  TootRainServerEnvironment.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation

/// Which TootRain server this app talks to: the staging one while the app is
/// being worked on, the production one in what is shipped. It follows the build
/// configuration rather than anything the running app can be told, so a release
/// build cannot be pointed at staging by accident.
///
/// Either one's URLs can still be replaced for local development, with the
/// `tootRainServerURL` / `tootRainCentrifugoURL` user defaults.
enum TootRainServerEnvironment {
    case production
    case staging

    static var current: TootRainServerEnvironment {
        #if DEBUG
        return .staging
        #else
        return .production
        #endif
    }

    var serverURL: URL {
        if let override = TootRainServerEnvironment.overrideURL(forKey: "tootRainServerURL") {
            return override
        }
        switch self {
        case .production:
            return URL(string: "https://tootrain.b123400.net")!
        case .staging:
            return URL(string: "https://tootrain-staging.b123400.net")!
        }
    }

    var centrifugoURL: URL {
        if let override = TootRainServerEnvironment.overrideURL(forKey: "tootRainCentrifugoURL") {
            return override
        }
        switch self {
        case .production:
            return URL(string: "https://tootrain-stream.b123400.net")!
        case .staging:
            return URL(string: "https://tootrain-staging-stream.b123400.net")!
        }
    }

    /// The bidirectional WebSocket endpoint of the Centrifugo server. Server-side
    /// subscriptions arrive on this connection, the connect proxy decides which.
    var centrifugoWebSocketURL: URL {
        var components = URLComponents(url: centrifugoURL, resolvingAgainstBaseURL: false)!
        components.scheme = components.scheme == "http" ? "ws" : "wss"
        components.path = "/connection/websocket"
        components.query = nil
        return components.url!
    }

    var logInWithSlackURL: URL {
        serverURL.appendingPathComponent("users").appendingPathComponent("log-in-with-slack")
    }

    func apiURL(path: String, queryItems: [URLQueryItem] = []) -> URL {
        var components = URLComponents(url: serverURL, resolvingAgainstBaseURL: false)!
        components.path = path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url!
    }

    /// The keychain identity every TootRain server secret is filed under.
    var keychainServer: String {
        serverURL.host ?? "tootrain.b123400.net"
    }

    private static func overrideURL(forKey key: String) -> URL? {
        guard let string = UserDefaults.standard.string(forKey: key), !string.isEmpty else {
            return nil
        }
        return URL(string: string)
    }
}
