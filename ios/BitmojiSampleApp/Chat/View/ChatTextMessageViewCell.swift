//
//  ChatTextMessageViewCell.swift
//  BitmojiSDKSample
//
//  Created by David Xia on 2018-02-06.
//  Copyright © 2018 Bitmoji. All rights reserved.
//

import UIKit

class ChatTextMessageViewCell: UICollectionViewCell {
    
    private static let horizontalPadding: CGFloat = 14
    private static let verticalPadding: CGFloat = 5
    private static let font = UIFont.systemFont(ofSize: 16)
    private static let green = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1)
    private static let grey = UIColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
    
    private let textView = UITextView()
    private let background = UIView()
    
    var isFromMe = true {
        didSet {
            guard oldValue != isFromMe else {
                return
            }
            textView.backgroundColor = isFromMe ?
                ChatTextMessageViewCell.grey : ChatTextMessageViewCell.green
            textView.textColor = isFromMe ? UIColor.black : UIColor.white
            setNeedsLayout()
        }
    }
    var text = "" {
        didSet {
            guard text != oldValue else { return }
            textView.text = text
            setNeedsLayout()
        }
    }
    var maxWidthPct: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textView.backgroundColor = ChatTextMessageViewCell.grey
        textView.font = ChatTextMessageViewCell.font
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.layer.cornerRadius = ChatTextMessageViewCell.horizontalPadding
        textView.textContainerInset = UIEdgeInsets(
            top: ChatTextMessageViewCell.verticalPadding,
            left: ChatTextMessageViewCell.horizontalPadding,
            bottom: ChatTextMessageViewCell.verticalPadding,
            right: ChatTextMessageViewCell.horizontalPadding)
        textView.textContainer.lineFragmentPadding = 0
        
        addSubview(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = ChatTextMessageViewCell.size(
            text: text, maxWidth: bounds.width * maxWidthPct)
        let x = isFromMe ? bounds.width - size.width : 0

        textView.frame.origin = CGPoint(x: x, y: 0)
        textView.frame.size = size
    }
    
    static func size(text: String, maxWidth: CGFloat) -> CGSize {
        var rect = text.boundingRect(
            with: CGSize(width: maxWidth, height: .infinity),
            options: .usesLineFragmentOrigin,
            attributes: [ NSAttributedStringKey.font: font ],
            context: nil)
        rect.size = CGSize(
            width: ceil(rect.size.width) + 2 * horizontalPadding,
            height: ceil(rect.size.height) + 2 * verticalPadding)
        return CGSize(width: min(rect.size.width, maxWidth), height: rect.size.height)
    }
}
