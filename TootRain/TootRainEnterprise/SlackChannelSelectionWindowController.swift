//
//  SlackChannelSelectionWindowController.swift
//  TootRain
//
//  Created by b123400 on 2026/10/27.
//

import Foundation
import Cocoa

/// Picks which channels of one workspace the app listens to.
///
/// The channels come from Slack (`conversations.list`), and only the ones the
/// user is in are offered: the TootRain server grants a channel on Slack's word
/// that they are a member of it, so a tick on anything else could only be
/// refused.
///
/// Nothing is sent while the ticking is going on. Done states the whole set in
/// one request — the server holds one set per session, so that request carries
/// the other workspaces' channels as well — and Cancel closes the picker having
/// said nothing, which is all it takes to put the ticks back. Both buttons are
/// out of reach while a request is in flight: there is nothing to say Done to
/// before the list arrives, and nothing to take back until the set has either
/// been accepted or refused.
@objc(SlackChannelSelectionWindowController)
class SlackChannelSelectionWindowController: NSWindowController {

    private struct Row {
        let channelId: String
        /// A channel the user has picked that Slack did not list — one they have
        /// since left, say — is named by what the server last knew it as, or by
        /// its id when nothing knows a name, so that it can be unticked.
        let name: String
        let isPrivate: Bool
        let isListedBySlack: Bool

        var title: String {
            isPrivate ? "🔒 \(name)" : "# \(name)"
        }
    }

    /// The channels the picker opens with ticked, and what to call the ones
    /// Slack does not list.
    private struct Picked {
        let channelIds: Set<String>
        let names: [String: String]
    }

    private let account: TootRainSlackAccount
    private let subscriptions: TootRainChannelSubscriptions
    private let serverAPI: TootRainServerAPI

    /// Every channel on offer, and the ones the filter field leaves of them.
    private var allRows: [Row] = []
    private var rows: [Row] = []
    /// What the ticks say now, and what they said when the picker opened. Done
    /// compares the two, so a picker closed without a change says nothing to
    /// the server at all.
    private var selectedChannelIds: Set<String> = []
    private var openedWithChannelIds: Set<String> = []
    private var filterQuery = ""
    /// A request is in flight: the list on the way in, or the set on the way
    /// out.
    private var isBusy = false
    /// A list that failed to load takes the picker with it, so whatever goes
    /// wrong after that has nowhere to be shown and is only logged.
    private var hasFailedToLoad = false

    private var tableView: NSTableView!
    private var statusLabel: NSTextField!
    private var loadingIndicator: NSProgressIndicator!
    private var filterField: NSSearchField!
    private var doneButton: NSButton!
    private var cancelButton: NSButton!

    init(account: TootRainSlackAccount,
         subscriptions: TootRainChannelSubscriptions = .shared,
         serverAPI: TootRainServerAPI = .shared) {
        self.account = account
        self.subscriptions = subscriptions
        self.serverAPI = serverAPI

        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 460, height: 470),
                              styleMask: [.titled, .resizable],
                              backing: .buffered,
                              defer: false)
        window.title = String(format: NSLocalizedString("Channels of %@", comment: "channel picker title"),
                              account.teamName)
        super.init(window: window)
        buildContentView()
        reload()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func buildContentView() {
        guard let window = window else { return }
        let content = ChannelSelectionContentView(frame: window.contentLayoutRect)
        content.onEscape = { [weak self] in self?.escapePressed() }

        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        // A status line too long for the sheet is truncated rather than allowed
        // to widen it: a label holds on to its text harder than a window holds
        // on to its width, so without this the sheet would change size as the
        // status changes.
        label.setContentCompressionResistancePriority(
            NSLayoutConstraint.Priority(rawValue: NSLayoutConstraint.Priority.windowSizeStayPut.rawValue - 1),
            for: .horizontal)
        statusLabel = label

        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.controlSize = .small
        indicator.isDisplayedWhenStopped = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator = indicator

        let filter = NSSearchField()
        filter.placeholderString = NSLocalizedString("Filter channels", comment: "channel picker filter")
        filter.delegate = self
        // The clear button changes the text without a keystroke, so the action
        // is here to keep the list in step with it as well.
        filter.target = self
        filter.action = #selector(filterChanged(_:))
        filter.translatesAutoresizingMaskIntoConstraints = false
        filterField = filter

        let table = NSTableView()
        table.headerView = nil
        table.rowHeight = 24
        table.allowsEmptySelection = true
        table.allowsMultipleSelection = false
        table.dataSource = self
        table.delegate = self
        table.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier("channel")))
        tableView = table

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        scrollView.documentView = table
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let done = NSButton(title: NSLocalizedString("Done", comment: "channel picker close button"),
                            target: self,
                            action: #selector(donePressed(_:)))
        done.bezelStyle = .rounded
        // Return sends the set; Esc is the content view's doing, so that one
        // keystroke can clear the filter before it reaches Cancel.
        done.keyEquivalent = "\r"
        done.translatesAutoresizingMaskIntoConstraints = false
        doneButton = done

        let cancel = NSButton(title: NSLocalizedString("Cancel", comment: "channel picker cancel button"),
                              target: self,
                              action: #selector(cancelPressed(_:)))
        cancel.bezelStyle = .rounded
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton = cancel

        content.addSubview(label)
        content.addSubview(indicator)
        content.addSubview(filter)
        content.addSubview(scrollView)
        content.addSubview(cancel)
        content.addSubview(done)

        let views: [String: Any] = [
            "status": label,
            "spinner": indicator,
            "filter": filter,
            "list": scrollView,
            "cancel": cancel,
            "done": done,
        ]
        NSLayoutConstraint.activate(
            NSLayoutConstraint.standardSpaced([
                "H:|-[status]-[spinner]-|",
                "H:|-[filter]-|",
                "H:|-[list]-|",
                "H:[cancel]-[done]-|",
                "V:|-[status]-[filter]-[list]-[done]-|",
            ], views: views)
            + [indicator.centerYAnchor.constraint(equalTo: label.centerYAnchor),
               cancel.centerYAnchor.constraint(equalTo: done.centerYAnchor)])

        window.contentView = content
    }

    // MARK: - Loading

    private func reload() {
        // Read on the main queue, where the account's own state is written, and
        // read back from where it is saved rather than from this instance,
        // which was made before the last set was stated.
        let isListening = TootRainChannelSubscriptions.isListening(to: account)
        let remembered = TootRainSlackAccount.account(teamId: account.teamId)?.channels ?? [:]

        // What the last fetch left cached goes up at once, so there is a list to
        // read and filter while Slack is asked for it again. The ticks on it are
        // the channels the app remembers picking, which is a good guess and not
        // an answer: what a workspace that is switched on is listening to is the
        // server's to say, and until it has said, there is nothing to press Done
        // on either.
        let cached = SlackInfoCache.shared.channels(teamId: account.teamId)
        if cached.isEmpty {
            setBusy(true, status: NSLocalizedString("Loading channels…", comment: "channel picker status"))
        } else {
            setBusy(true, status: NSLocalizedString("Updating channels…", comment: "channel picker status"))
            present(channels: cached,
                    picked: Picked(channelIds: Set(remembered.keys), names: remembered),
                    isFinal: false)
        }

        Task {
            do {
                guard let client = SlackAPIClient(account: account) else {
                    throw SlackAPIError.missingAccessToken
                }
                let channels = try await client.conversations()
                // Slack has just said what this workspace's channels are, so the
                // next picker, and the next message with a channel in it, can
                // open on that rather than on what the last launch saw.
                SlackInfoCache.shared.update(channels: channels, teamId: account.teamId)
                let picked = try await self.pickedChannelsFromServerAndSaveThem(
                    isListening: isListening, remembered: remembered)
                await MainActor.run { self.present(channels: channels, picked: picked, isFinal: true) }
            } catch {
                await MainActor.run { self.presentLoadingFailure(error) }
            }
        }
    }

    /// What the ticks start as: for a workspace switched on, what the server
    /// actually holds, which can be less than the app wrote down; for one
    /// switched off, what the app remembers, the server holding nothing of it.
    ///
    /// The answer is written down here too — Cancel never undid more than the
    /// ticks.
    private func pickedChannelsFromServerAndSaveThem(isListening: Bool,
                                                     remembered: [String: String])
        async throws -> Picked {
        guard isListening else {
            return Picked(channelIds: Set(remembered.keys), names: remembered)
        }
        let memberships = try await serverAPI.channelMemberships(teamId: account.teamId)
        let channels = await MainActor.run { () -> [String: String] in
            // Read back from where the account is saved: this picker was made
            // before the last statement of the set.
            let saved = TootRainSlackAccount.account(teamId: self.account.teamId)
            // A workspace can be linked twice on one session, by two Slack
            // users, and this listing is by workspace — so the other linkage's
            // channels are neither this picker's to show nor its to write down.
            let linkageId = saved?.linkageId?.intValue
            var channels: [String: String] = [:]
            for membership in memberships
            where linkageId == nil || membership.linkageId == linkageId {
                let name = membership.name ?? ""
                channels[membership.channelId] = name.isEmpty ? membership.channelId : name
            }
            if let saved = saved {
                self.subscriptions.saveChannelsFromServer(channels, for: saved)
            }
            return channels
        }
        return Picked(channelIds: Set(channels.keys), names: channels)
    }

    /// Puts a list of channels on screen. `isFinal` says this one is Slack's
    /// answer rather than the cached list shown while waiting for it: only then
    /// do the ticks say what the server holds, which is what Done compares
    /// against before it sends anything, and only then is the picker ready to
    /// be used at all.
    private func present(channels: [SlackChannel], picked: Picked, isFinal: Bool) {
        selectedChannelIds = picked.channelIds
        if isFinal {
            openedWithChannelIds = picked.channelIds
        }

        var rows = channels
            .filter { $0.isMember }
            .map { Row(channelId: $0.id, name: $0.name, isPrivate: $0.isPrivate, isListedBySlack: true) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

        let listedIds = Set(rows.map { $0.channelId })
        let unlisted = picked.channelIds
            .subtracting(listedIds)
            .map { Row(channelId: $0,
                       name: picked.names[$0] ?? $0,
                       isPrivate: false,
                       isListedBySlack: false) }
        rows.append(contentsOf: unlisted.sorted { $0.name < $1.name })

        allRows = rows
        if isFinal {
            setBusy(false)
        }
        applyFilter()
    }

    /// There is nothing to pick without the list, so a request that fails on the
    /// way to it closes the picker and says why. Only the first one does: a
    /// second — the other of the two requests — would be an alert about a window
    /// that is already gone, so it goes to the log.
    ///
    /// The alert belongs to the window the picker was a sheet of, not to the
    /// picker itself. An alert attached to a sheet that is then dismissed from
    /// inside the alert's own completion leaves both on screen — the alert with
    /// a dead OK button, the picker stranded as a window of its own — because
    /// the picker is torn out from under a sheet that has not finished going.
    /// Dismissing the picker first has none of that: AppKit holds the alert back
    /// until the window it is attached to is free again.
    private func presentLoadingFailure(_ error: Error) {
        allRows = []
        rows = []
        setBusy(false)
        tableView.reloadData()

        guard !hasFailedToLoad else {
            NSLog("TootRain: the channel list failed again: %@", String(describing: error))
            return
        }
        hasFailedToLoad = true

        let parent = window?.sheetParent
        dismissWindow()

        let alert = NSAlert(error: error)
        if let parent = parent {
            alert.beginSheetModal(for: parent)
        } else {
            alert.runModal()
        }
    }

    // MARK: - Status

    /// The table shows what the filter leaves; the count keeps speaking of every
    /// channel, since that is what the ticks are about. A request in flight has
    /// the status line to itself.
    private func applyFilter() {
        filterQuery = filterField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        rows = filterQuery.isEmpty
            ? allRows
            : allRows.filter { $0.name.localizedCaseInsensitiveContains(filterQuery) }
        updateStatusLabel()
        tableView.reloadData()
    }

    private func updateStatusLabel() {
        guard !isBusy else { return }
        if rows.isEmpty, !filterQuery.isEmpty {
            statusLabel.stringValue = NSLocalizedString("No channel matches this filter.",
                                                        comment: "channel picker status")
            return
        }
        let format = NSLocalizedString("Checked channels are shown as comments. %ld of %ld selected.",
                                        comment: "channel picker status")
        statusLabel.stringValue = String(format: format, selectedChannelIds.count, allRows.count)
    }

    /// Both buttons and every tick are out of reach while a request is in
    /// flight, and the spinner in the corner is what says so.
    private func setBusy(_ busy: Bool, status: String? = nil) {
        isBusy = busy
        if let status = status {
            statusLabel.stringValue = status
        }
        doneButton.isEnabled = !busy
        cancelButton.isEnabled = !busy
        if busy {
            loadingIndicator.startAnimation(nil)
        } else {
            loadingIndicator.stopAnimation(nil)
        }
        tableView.reloadData()
    }

    // MARK: - Actions

    @objc private func filterChanged(_ sender: Any?) {
        applyFilter()
    }

    @objc private func checkboxToggled(_ sender: NSButton) {
        let row = sender.tag
        guard rows.indices.contains(row) else { return }
        let channel = rows[row]
        if sender.state == .on {
            selectedChannelIds.insert(channel.channelId)
        } else {
            selectedChannelIds.remove(channel.channelId)
        }
        updateStatusLabel()
    }

    /// Says what this session listens to, with this workspace's channels as the
    /// ticks now have them. One request, whatever was ticked and unticked, and
    /// the picker stays where it is until the server has answered.
    @objc private func donePressed(_ sender: Any?) {
        guard !isBusy else { return }
        let wanted = selectedChannelIds
        guard wanted != openedWithChannelIds else {
            dismissWindow()
            return
        }
        // The names go up with the ids: the accounts pane shows what the user
        // picked, and asking Slack for the names again to show four of them
        // would be a round trip for nothing.
        let picks = Dictionary(uniqueKeysWithValues: allRows
            .filter { wanted.contains($0.channelId) }
            .map { ($0.channelId, $0.name) })
        setBusy(true, status: NSLocalizedString("Saving channels…", comment: "channel picker status"))
        Task {
            do {
                let update = try await subscriptions.apply(channels: picks, to: account)
                await MainActor.run { self.finishSaving(update, wanted: wanted) }
            } catch {
                await MainActor.run {
                    self.setBusy(false)
                    self.applyFilter()
                    self.presentSaveFailure(error)
                }
            }
        }
    }

    /// Cancel says nothing to the server, which is all it takes to put the ticks
    /// back: the set the server holds is still the one it held when the picker
    /// opened.
    @objc private func cancelPressed(_ sender: Any?) {
        guard !isBusy else { return }
        dismissWindow()
    }

    /// Esc empties the filter before it closes the picker, the way a search
    /// field's own Esc would, so one keystroke never throws away both what was
    /// typed and the window it was typed in.
    private func escapePressed() {
        guard !isBusy else { return }
        guard filterField.stringValue.isEmpty else {
            filterField.stringValue = ""
            applyFilter()
            return
        }
        dismissWindow()
    }

    private func finishSaving(_ update: TootRainChannelMembershipUpdate?, wanted: Set<String>) {
        // What the server holds afterwards is what the ticks are: it may be less
        // than was asked for. A workspace that is switched off was not in the
        // request at all — its channels are only written down — so there the
        // ticks are what was picked.
        if let update = update, let linkageId = account.linkageId?.intValue {
            selectedChannelIds = update.channelIds(linkageId: linkageId)
            openedWithChannelIds = selectedChannelIds
            let rejected = update.rejections(linkageId: linkageId)
            if !rejected.isEmpty {
                setBusy(false)
                applyFilter()
                presentRejections(rejected)
                return
            }
        } else {
            selectedChannelIds = wanted
            openedWithChannelIds = wanted
        }
        dismissWindow()
    }

    /// A channel the server would not grant does not take the rest of the set
    /// with it — the others are being listened to, and the ticks have already
    /// gone back to what the server actually holds — so the picker stays where
    /// it is and says which ones did not happen, as its own sheet.
    private func presentRejections(_ rejections: [TootRainChannelMembershipRejection]) {
        guard let window = window else { return }
        let format = NSLocalizedString("%@: %@",
                                       comment: "channel picker rejection, a channel and why it was refused")
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = NSLocalizedString("Some channels could not be added.",
                                              comment: "channel picker rejection")
        alert.informativeText = rejections
            .map { String(format: format, title(ofChannelId: $0.channelId), $0.reason.localizedDescription) }
            .joined(separator: "\n")
        alert.beginSheetModal(for: window)
    }

    /// The whole set failed rather than one channel of it, so nothing has
    /// changed and the picker stays open to be tried again.
    private func presentSaveFailure(_ error: Error) {
        guard !hasFailedToLoad, let window = window else {
            NSLog("TootRain: the channel set was not saved: %@", String(describing: error))
            return
        }
        NSAlert(error: error).beginSheetModal(for: window)
    }

    private func title(ofChannelId channelId: String) -> String {
        allRows.first { $0.channelId == channelId }?.title ?? channelId
    }

    private func dismissWindow() {
        guard let window = window else { return }
        if let parent = window.sheetParent {
            parent.endSheet(window)
        } else {
            window.close()
        }
    }
}

// MARK: - Filter field

extension SlackChannelSelectionWindowController: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        applyFilter()
    }
}

/// The picker's content view, which is where Esc is caught. Return belongs to
/// the Done button, which has it as its key equivalent; Esc has no button of its
/// own. A key equivalent is looked for before the key reaches the first
/// responder, so taking Esc here is also what takes it from the search field —
/// hence the controller clearing the field itself.
private class ChannelSelectionContentView: NSView {

    var onEscape: (() -> Void)?

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.charactersIgnoringModifiers == "\u{1b}" {
            onEscape?()
            return true
        }
        return super.performKeyEquivalent(with: event)
    }
}

// MARK: - Table view

extension SlackChannelSelectionWindowController: NSTableViewDataSource, NSTableViewDelegate {

    func numberOfRows(in tableView: NSTableView) -> Int {
        rows.count
    }

    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        let identifier = NSUserInterfaceItemIdentifier("SlackChannelRow")
        let view = tableView.makeView(withIdentifier: identifier, owner: self) as? SlackChannelRowView
            ?? SlackChannelRowView(identifier: identifier)

        let channel = rows[row]
        let isPicked = selectedChannelIds.contains(channel.channelId)
        view.configure(title: channel.title,
                       isOn: isPicked,
                       // A channel Slack did not list can be unticked but not
                       // ticked again, there being no membership to grant it on.
                       isEnabled: !isBusy && (channel.isListedBySlack || isPicked),
                       row: row,
                       target: self,
                       action: #selector(checkboxToggled(_:)))
        return view
    }

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        false
    }
}

/// A channel's row: its tick and its name, the whole width of the list, so that
/// a long name truncates rather than running on and the row is a target the
/// width of the list rather than of its text.
private class SlackChannelRowView: NSView {

    private let checkbox: NSButton

    init(identifier: NSUserInterfaceItemIdentifier) {
        checkbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.lineBreakMode = .byTruncatingTail

        super.init(frame: .zero)
        self.identifier = identifier
        addSubview(checkbox)

        let views: [String: Any] = ["tick": checkbox]
        NSLayoutConstraint.activate(
            NSLayoutConstraint.standardSpaced(["H:|[tick]-|"], views: views)
            + [checkbox.centerYAnchor.constraint(equalTo: centerYAnchor)])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String,
                   isOn: Bool,
                   isEnabled: Bool,
                   row: Int,
                   target: AnyObject,
                   action: Selector) {
        checkbox.title = title
        checkbox.state = isOn ? .on : .off
        checkbox.tag = row
        checkbox.target = target
        checkbox.action = action
        checkbox.isEnabled = isEnabled
    }
}
