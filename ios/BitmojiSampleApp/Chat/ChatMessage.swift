//
//  ChatMessage.swift
//  BitmojiSDKSample
//
//  Created by David Xia on 2018-02-06.
//  Copyright © 2018 Bitmoji. All rights reserved.
//

import UIKit

enum ChatMessageCellType {
    case image
    case text
}

protocol ChatMessage {
    var isFromMe: Bool { get }
    var cellType: ChatMessageCellType { get }
}

struct ChatImageURLMessage: ChatMessage {
    let isFromMe: Bool
    let imageURL: String
    let cellType = ChatMessageCellType.image
}

struct ChatImageMessage: ChatMessage {
    let isFromMe: Bool
    let image: UIImage
    let cellType = ChatMessageCellType.image
}

struct ChatTextMessage: ChatMessage {
    let isFromMe: Bool
    let text: String
    let cellType = ChatMessageCellType.text
}
