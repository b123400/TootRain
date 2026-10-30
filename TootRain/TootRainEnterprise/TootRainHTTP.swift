//
//  TootRainHTTP.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation

extension URLSession {
    /// `URLSession.data(for:)` only exists from macOS 12, and TootRain still runs
    /// on 10.15, so the callback API gets wrapped instead.
    func tootRainData(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let data = data, let response = response as? HTTPURLResponse else {
                    continuation.resume(throwing: TootRainHTTPError.invalidResponse)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
}

enum TootRainHTTPError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return NSLocalizedString("The server sent a response TootRain could not read.", comment: "network error")
        }
    }
}

enum TootRainUserAgent {
    /// What the app calls itself. The server records it on the session row, so
    /// it is sent with every request and with the Centrifugo handshake.
    static var current: String {
        "TootRain \(version)"
    }

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    }
}
