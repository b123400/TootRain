//
//  TootRainEnterpriseAuthWindowController.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation
import Cocoa
import WebKit

enum TootRainAuthError: LocalizedError {
    case missingTokens
    /// A log-in the server turned down. The code is for the app to act on; the
    /// message is the sentence the person would have read on the page they are
    /// taken off the moment it loads.
    case refused(code: String, message: String?)

    var errorDescription: String? {
        switch self {
        case .missingTokens:
            return NSLocalizedString("The TootRain server did not send back a Slack token.", comment: "auth error")
        case .refused(let code, let message):
            if let message = message, !message.isEmpty {
                return message
            }
            let format = NSLocalizedString("The TootRain server refused the log-in: %@", comment: "auth error")
            return String(format: format, code)
        }
    }
}

/// Links a Slack workspace by letting the user through the server's own Slack
/// log-in in a web view.
///
/// The server does the OAuth and redirects to
/// `tootrain://auth?id=…&slack_access_token=…&token=…`, which this window catches.
/// The `token` is the app session: an existing one is passed up in the request so
/// the server reuses it and hands the same one back, and when none is sent the
/// server makes a new session. `id` is the linkage's, which is what the app needs
/// to give the account up again later.
///
/// A log-in that did not work comes back the same way, as
/// `tootrain://auth?error=<code>&message=<text>`. All of those are the person's
/// to read except `invalid_app_session`, which says the session the app sent up
/// is not one the server has: that one the app answers itself by throwing the
/// session away and starting over, which makes a new one.
///
/// Nothing is saved, and nothing connects, until the workspace's users and emoji
/// have been fetched.
@objc(TootRainEnterpriseAuthWindowController)
class TootRainEnterpriseAuthWindowController: NSWindowController, WKNavigationDelegate {

    private static let callbackScheme = "tootrain"
    /// The server's word for "the session you sent me is gone".
    private static let invalidAppSessionCode = "invalid_app_session"

    private let environment: TootRainServerEnvironment
    /// The workspace to authorise again, when this is a second visit for one the
    /// server has let go. Slack is asked for that team by name, so the user is
    /// not left picking the right workspace out of the ones they are in.
    private let teamId: String?
    private let completion: (TootRainSlackAccount?, Error?) -> Void
    private var webView: WKWebView!
    private var hasFinished = false
    /// So a server that keeps refusing the session cannot put the log-in into a
    /// loop: the second attempt carries no session at all.
    private var hasStartedOver = false

    /// Shows the log-in window. `completion` runs on the main thread with the
    /// newly linked workspace, or with an error, or with neither when the user
    /// just closed the window.
    @objc(beginLogInWithCompletion:)
    static func beginLogIn(completion: @escaping (TootRainSlackAccount?, Error?) -> Void)
        -> TootRainEnterpriseAuthWindowController {
        beginLogIn(teamId: nil, completion: completion)
    }

    /// The same, for a workspace that has to be authorised again.
    @objc(beginLogInWithTeamId:completion:)
    static func beginLogIn(teamId: String?,
                           completion: @escaping (TootRainSlackAccount?, Error?) -> Void)
        -> TootRainEnterpriseAuthWindowController {
        let controller = TootRainEnterpriseAuthWindowController(teamId: teamId, completion: completion)
        controller.showWindow(nil)
        controller.window?.makeKeyAndOrderFront(nil)
        return controller
    }

    init(environment: TootRainServerEnvironment = .current,
         teamId: String? = nil,
         completion: @escaping (TootRainSlackAccount?, Error?) -> Void) {
        self.environment = environment
        self.teamId = teamId
        self.completion = completion

        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 520, height: 680),
                              styleMask: [.titled, .closable, .resizable],
                              backing: .buffered,
                              defer: false)
        window.title = NSLocalizedString("Log in with Slack", comment: "auth window title")
        window.center()
        super.init(window: window)

        let webView = WKWebView(frame: window.contentLayoutRect, configuration: WKWebViewConfiguration())
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        webView.customUserAgent = TootRainSystemConstants.slackOAuthUserAgent
            ?? "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/999.99 (KHTML, like Gecko) Chrome/999.0.0.0 Safari/999.99"
        window.contentView = webView
        self.webView = webView

        window.delegate = self
        webView.load(URLRequest(url: logInURL))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var logInURL: URL {
        var components = URLComponents(url: environment.logInWithSlackURL, resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []
        if let token = TootRainAppSession.shared.token, !token.isEmpty {
            queryItems.append(URLQueryItem(name: "token", value: token))
        }
        if let teamId = teamId, !teamId.isEmpty {
            queryItems.append(URLQueryItem(name: "team", value: teamId))
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.url!
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
              url.scheme == TootRainEnterpriseAuthWindowController.callbackScheme else {
            decisionHandler(.allow)
            return
        }
        decisionHandler(.cancel)
        handleCallback(url: url)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        finish(account: nil, error: error)
    }

    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        // A cancelled navigation is how the callback URL above is stopped.
        if (error as NSError).code == NSURLErrorCancelled { return }
        finish(account: nil, error: error)
    }

    // MARK: - Callback

    private func handleCallback(url: URL) {
        guard !hasFinished else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = components?.queryItems ?? []
        func value(_ name: String) -> String? {
            items.first { $0.name == name }?.value.flatMap { $0.isEmpty ? nil : $0 }
        }
        if let code = value("error") {
            handleFailure(code: code, message: value("message"))
            return
        }

        guard let slackAccessToken = value("slack_access_token"),
              let sessionToken = value("token") else {
            finish(account: nil, error: TootRainAuthError.missingTokens)
            return
        }
        // The linkage id is what lets the app give this account up again. An
        // answer without one still links the account; it just has to be asked
        // for again, by the session overview at the next launch.
        let linkageId = value("id").flatMap { Int($0) }
        if linkageId == nil {
            NSLog("TootRain: the log-in sent back no linkage id")
        }
        hasFinished = true
        Task {
            do {
                let account = try await TootRainEnterpriseAuthWindowController.link(
                    slackAccessToken: slackAccessToken,
                    sessionToken: sessionToken,
                    linkageId: linkageId)
                await MainActor.run { self.report(account: account, error: nil) }
            } catch {
                await MainActor.run { self.report(account: nil, error: error) }
            }
        }
    }

    /// The log-in did not work. Everything but a session the server cannot place
    /// is the person's to read, so it is handed to the caller as an error; that
    /// one the app answers itself, once, by starting the log-in over with no
    /// session at all.
    private func handleFailure(code: String, message: String?) {
        guard code == TootRainEnterpriseAuthWindowController.invalidAppSessionCode,
              !hasStartedOver,
              TootRainAppSession.shared.hasToken else {
            finish(account: nil, error: TootRainAuthError.refused(code: code, message: message))
            return
        }
        hasStartedOver = true
        NSLog("TootRain: the server does not know our app session, starting a new one")
        TootRainAppSession.shared.clear()
        webView.load(URLRequest(url: logInURL))
    }

    /// Saves both tokens, works out which workspace was authorised, and fills the
    /// caches the renderer will need before anything connects.
    private static func link(slackAccessToken: String,
                             sessionToken: String,
                             linkageId: Int?) async throws -> TootRainSlackAccount {
        let identity = try await SlackAPIClient(accessToken: slackAccessToken).identity()
        TootRainAppSession.shared.token = sessionToken

        let account = TootRainSlackAccount(teamId: identity.teamId,
                                           teamName: identity.teamName,
                                           teamDomain: identity.url?.host,
                                           slackUserId: identity.userId,
                                           slackUserName: identity.userName)
        account.linkageId = linkageId.map { NSNumber(value: $0) }
        account.accessToken = slackAccessToken
        // Saving a fresh row is also what clears any needs-authentication mark
        // this workspace was carrying, which is the point of logging in again.
        account.save()
        await MainActor.run { TootRainSlackAccount.notifyAccountsChanged() }

        try await SlackInfoCache.shared.refresh(account: account)
        return account
    }

    private func report(account: TootRainSlackAccount?, error: Error?) {
        hasFinished = true
        window?.delegate = nil
        window?.close()
        completion(account, error)
    }

    private func finish(account: TootRainSlackAccount?, error: Error?) {
        guard !hasFinished else { return }
        report(account: account, error: error)
    }
}

extension TootRainEnterpriseAuthWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard !hasFinished else { return }
        hasFinished = true
        completion(nil, nil)
    }
}
