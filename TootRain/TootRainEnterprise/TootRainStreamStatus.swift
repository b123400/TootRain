//
//  TootRainStreamStatus.swift
//  TootRain
//
//  Created by b123400 on 2026/11/01.
//

import Foundation
import Cocoa

/// A message from a service this version of the app knows nothing about.
///
/// The envelope keeps `text` outside the provider's own half precisely so there
/// is always something to show. Nothing is read out of the words, since
/// whatever syntax they are written in is that service's own, and who wrote it,
/// when and where to find it are in the half this version cannot read.
@objc(TootRainStreamStatus)
class TootRainStreamStatus: Status {

    @objc init(provider: String, text: String) {
        super.init()
        // Nothing in the shared half of the envelope names a message, and the
        // flood window remembers what it has shown by the id.
        statusID = "tootrain-stream:\(provider):\(UUID().uuidString)"
        createdAt = Date()
        self.text = text
        attributedText = NSAttributedString(string: text)
        user = TootRainStreamStatus.authorForProvider(provider)
    }

    /// The service's own name, for want of the writer's: a drop shows the
    /// author beside the words, and the detail view asks for one as well.
    private static func authorForProvider(_ provider: String) -> User {
        let author = User()
        author.userID = provider
        author.username = provider
        author.screenName = provider
        return author
    }
}
