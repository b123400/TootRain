//
//  TootRainAppSession.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation

/// The one app session shared by every TootRain server linkage. The server hands
/// its token back from the Slack log-in redirect; everything the app asks of the
/// server afterwards authenticates with it, Centrifugo's connect proxy included.
///
/// There is at most one session, so at most one connection to the server.
final class TootRainAppSession {

    static let shared = TootRainAppSession()

    private static let keychainAccount = "app-session-token"

    private let environment: TootRainServerEnvironment

    init(environment: TootRainServerEnvironment = .current) {
        self.environment = environment
    }

    var token: String? {
        get {
            TootRainKeychain.string(server: environment.keychainServer,
                                    account: TootRainAppSession.keychainAccount)
        }
        set {
            TootRainKeychain.setString(newValue,
                                       server: environment.keychainServer,
                                       account: TootRainAppSession.keychainAccount)
        }
    }

    var hasToken: Bool {
        token?.isEmpty == false
    }

    /// Forgets the session locally. The server is not told yet — it has no
    /// endpoint for the app to call with the session it is giving up.
    func clear() {
        token = nil
    }
}
