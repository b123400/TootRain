//
//  SettingAccountDetailSlackView.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation
import Cocoa

/// The accounts pane's detail view for a Slack workspace linked through the
/// TootRain server. Built in code rather than in the settings nib, so the nib
/// keeps only the account types that were always there. It is laid out on Auto
/// Layout's standard spacings, with the nib's own 90pt label column, so the
/// panes line up as the user clicks down the account list.
@objc(SettingAccountDetailSlackView)
class SettingAccountDetailSlackView: NSView {

    /// The label column the nib's own detail views use, so the value columns
    /// of all of them start in the same place.
    private static let labelColumnWidth: CGFloat = 90

    private let workspaceValue = SettingAccountDetailSlackView.makeValueLabel()
    private let teamIdValue = SettingAccountDetailSlackView.makeValueLabel()
    private let userValue = SettingAccountDetailSlackView.makeValueLabel()
    private let channelsValue = SettingAccountDetailSlackView.makeChannelsLabel()

    private var channelsButton: NSButton!
    private var reauthenticateButton: NSButton!

    private var account: TootRainSlackAccount?
    /// Held so the sheet is not deallocated while the user has it open.
    private var channelSelectionController: SlackChannelSelectionWindowController?
    /// The same, for the log-in window.
    private var authController: TootRainEnterpriseAuthWindowController?

    @objc override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        buildSubviews()
        observeChannelChanges()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildSubviews()
        observeChannelChanges()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// The channels change under this pane rather than in it: the picker states
    /// them, and so does switching a workspace on, and what the server answers
    /// is what ends up saved.
    private func observeChannelChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(channelsChanged),
            name: Notification.Name(TootRainChannelSubscriptions.didChangeNotificationName),
            object: nil)
    }

    @objc private func channelsChanged() {
        DispatchQueue.main.async { self.updateChannels() }
    }

    @objc func setAccount(_ account: TootRainSlackAccount) {
        self.account = account
        // A workspace the server has let go can only be authorised again: there
        // is no session to ask about its channels with.
        channelsButton.isEnabled = !account.needsAuthentication
        reauthenticateButton.isHidden = !account.needsAuthentication
        workspaceValue.stringValue = account.teamName
        teamIdValue.stringValue = account.teamId
        if let userName = account.slackUserName, !userName.isEmpty {
            userValue.stringValue = "\(userName) (\(account.slackUserId))"
        } else {
            userValue.stringValue = account.slackUserId
        }
        updateChannels()
    }

    /// Read back from where the channels are saved rather than from the account
    /// this pane was handed, which was made before the last set was stated.
    private func updateChannels() {
        guard let account = account else { return }
        let names = TootRainSlackAccount.account(teamId: account.teamId)?.channelNames ?? []
        channelsValue.stringValue = names.isEmpty
            ? NSLocalizedString("None", comment: "slack account detail, no channels picked")
            : names.joined(separator: ", ")
    }

    // MARK: - Layout

    private func buildSubviews() {
        autoresizingMask = [.width, .height]

        let rows: [(String, NSTextField)] = [
            (NSLocalizedString("Workspace:", comment: "slack account detail"), workspaceValue),
            (NSLocalizedString("Team ID:", comment: "slack account detail"), teamIdValue),
            (NSLocalizedString("Slack user:", comment: "slack account detail"), userValue),
            (NSLocalizedString("Channels:", comment: "slack account detail"), channelsValue),
        ]

        let serviceRow = SettingAccountDetailSlackView.makeRow(
            title: NSLocalizedString("Service:", comment: "slack account detail"),
            value: SettingAccountDetailSlackView.makeValueLabel(
                text: NSLocalizedString("Slack (TootRain server)", comment: "slack account detail")))

        let rowViews = [serviceRow]
            + rows.map { SettingAccountDetailSlackView.makeRow(title: $0.0, value: $0.1) }
        let channelsRow = rowViews[rowViews.count - 1]

        let stack = NSStackView(views: rowViews)
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false

        let channels = NSButton(title: NSLocalizedString("Channels…", comment: "slack account detail"),
                                target: self,
                                action: #selector(channelsPressed(_:)))
        channels.bezelStyle = .rounded
        channels.translatesAutoresizingMaskIntoConstraints = false
        channelsButton = channels

        let reauthenticate = NSButton(title: NSLocalizedString("Re-authenticate", comment: "slack account detail"),
                                      target: self,
                                      action: #selector(reauthenticatePressed(_:)))
        reauthenticate.bezelStyle = .rounded
        reauthenticate.isHidden = true
        reauthenticate.translatesAutoresizingMaskIntoConstraints = false
        reauthenticateButton = reauthenticate

        // A hidden view is out of a stack view's layout, so the re-authenticate
        // button takes up no room until there is something to authorise.
        let buttons = NSStackView(views: [channels, reauthenticate])
        buttons.orientation = .horizontal
        buttons.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        addSubview(buttons)

        // The channels are the one value here that can be longer than the pane,
        // and a wrapping label cannot say how tall it is until it is told how
        // wide it may be. What the pane leaves it is the rows' own width, less
        // the label column and the gap the stack puts after it, so the lines it
        // wraps into are as many as `maximumNumberOfLines` allows and the rest
        // is an ellipsis — which is what keeps the buttons below in view
        // however many channels are picked.
        channelsValue.widthAnchor.constraint(
            equalTo: stack.widthAnchor,
            constant: -(SettingAccountDetailSlackView.labelColumnWidth + channelsRow.spacing)
        ).isActive = true

        let views: [String: Any] = ["rows": stack, "buttons": buttons]
        NSLayoutConstraint.activate(
            NSLayoutConstraint.standardSpaced([
                "H:|-[rows]-|",
                "V:|-[rows]-[buttons]",
            ], views: views)
            // The nib's other detail views hang their Options button off the
            // value column rather than the edge of the pane, so this one does
            // the same with the value label it sits under, and only keeps it
            // from running past the pane.
            + [buttons.leadingAnchor.constraint(equalTo: userValue.leadingAnchor),
               buttons.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)])
    }

    private static func makeRow(title: String, value: NSTextField) -> NSStackView {
        let label = NSTextField(labelWithString: title)
        label.alignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: labelColumnWidth).isActive = true
        // A row whose value wraps is as tall as that value, and the label reads
        // better beside its first line than halfway down it.
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let row = NSStackView(views: [label, value])
        row.orientation = .horizontal
        row.alignment = .firstBaseline
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }

    /// The value that holds the picked channels: as many lines as fit, and an
    /// ellipsis for the rest.
    private static func makeChannelsLabel() -> NSTextField {
        let field = makeValueLabel()
        field.maximumNumberOfLines = 3
        field.cell?.wraps = true
        field.cell?.truncatesLastVisibleLine = true
        return field
    }

    private static func makeValueLabel(text: String = "") -> NSTextField {
        let field = NSTextField(labelWithString: text)
        field.lineBreakMode = .byTruncatingTail
        field.isSelectable = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }

    // MARK: - Actions

    @objc private func channelsPressed(_ sender: Any?) {
        showChannelSelection()
    }

    /// Opens the channel picker as a sheet on the window this pane is in. The
    /// settings pane asks for this itself the moment a workspace is linked,
    /// since picking channels is what the user came to do and a workspace with
    /// none picked shows nothing at all.
    @objc func showChannelSelection() {
        guard let account = account, !account.needsAuthentication, let window = window else { return }
        let controller = SlackChannelSelectionWindowController(account: account)
        channelSelectionController = controller
        guard let sheet = controller.window else { return }
        window.beginSheet(sheet) { [weak self] _ in
            self?.channelSelectionController = nil
        }
    }

    /// Takes the user through the server's Slack log-in again, for this
    /// workspace: the log-in names the team, so they are not left picking it out
    /// of the ones they are in. What comes back is a fresh linkage on a session
    /// the server has, which is what clears the warning.
    @objc private func reauthenticatePressed(_ sender: Any?) {
        guard let account = account else { return }
        let button = sender as? NSButton
        button?.isEnabled = false
        authController = TootRainEnterpriseAuthWindowController.beginLogIn(teamId: account.teamId) {
            [weak self] linked, error in
            button?.isEnabled = true
            guard let self = self else { return }
            self.authController = nil
            if let linked = linked {
                self.setAccount(linked)
            } else if let error = error, let window = self.window {
                NSAlert(error: error).beginSheetModal(for: window)
            }
        }
    }
}
