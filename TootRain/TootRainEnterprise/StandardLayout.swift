//
//  StandardLayout.swift
//  TootRain
//
//  Created by b123400 on 2026/10/29.
//

import Foundation
import Cocoa

extension NSLayoutConstraint {

    /// Constraints read from visual formats, where every `-` is the system's own
    /// standard spacing rather than a number written down here: AppKit resolves
    /// it and keeps it symbolic (`NSSpace`), the same spacing the settings nib's
    /// "Standard" constraints are laid out with, so a pane built in code follows
    /// whatever the system says the spacing is.
    ///
    /// `constraint(equalToSystemSpacingAfter:)` says the same thing in anchors,
    /// and resolves to the same `NSSpace`, but it only exists from macOS 11
    /// while the app runs on 10.15.
    static func standardSpaced(_ formats: [String], views: [String: Any]) -> [NSLayoutConstraint] {
        formats.flatMap {
            constraints(withVisualFormat: $0, options: [], metrics: nil, views: views)
        }
    }
}
