//
//  ChatMessagesViewController.swift
//  BitmojiSDKSample
//
//  Created by David Xia on 2018-02-05.
//  Copyright © 2018 Bitmoji. All rights reserved.
//

import UIKit

class ChatMessagesViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private static let imageCellReuseId = "image"
    private static let textCellReuseId = "text"
    private static let insets = UIEdgeInsets(top: 64, left: 10, bottom: 58, right: 10)
    private static let maxWidthPct: CGFloat = 0.7
    
    private var messages: [ChatMessage] = []
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        
        self.init(collectionViewLayout: layout)
        
        collectionView?.register(
            ChatImageMessageViewCell.self,
            forCellWithReuseIdentifier: ChatMessagesViewController.imageCellReuseId)
        collectionView?.register(
            ChatTextMessageViewCell.self,
            forCellWithReuseIdentifier: ChatMessagesViewController.textCellReuseId)
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.contentInset = ChatMessagesViewController.insets
        collectionView?.showsVerticalScrollIndicator = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        adjustTopInset()
    }
    
    func add(_ message: ChatMessage) {
        messages.append(message)
        
        guard let collectionView = collectionView else {
            return
        }
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [IndexPath(row: messages.count - 1, section: 0)])
        }, completion: { _ in
            self.adjustTopInset()
            collectionView.setContentOffset(
                CGPoint(x: -collectionView.contentInset.left,
                        y: collectionView.contentSize.height + collectionView.contentInset.bottom - self.view.bounds.height),
                animated: true)
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard 0..<messages.count ~= indexPath.item else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatMessagesViewController.imageCellReuseId, for: indexPath)
        }
       
        switch messages[indexPath.item] {
        case let message as ChatImageURLMessage:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatMessagesViewController.imageCellReuseId, for: indexPath) as! ChatImageMessageViewCell
            cell.isFromMe = message.isFromMe
            cell.image = message.image
            cell.imageURL = message.imageURL
            return cell
        case let message as ChatImageMessage:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatMessagesViewController.imageCellReuseId, for: indexPath) as! ChatImageMessageViewCell
            cell.isFromMe = message.isFromMe
            cell.image = message.image
            return cell
        case let message as ChatTextMessage:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatMessagesViewController.textCellReuseId, for: indexPath) as! ChatTextMessageViewCell
            cell.maxWidthPct = ChatMessagesViewController.maxWidthPct
            cell.isFromMe = message.isFromMe
            cell.text = message.text
            return cell
        default:
            assertionFailure("Unknown message type!")
        }
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: ChatMessagesViewController.imageCellReuseId, for: indexPath)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard 0..<messages.count ~= indexPath.item else {
            return CGSize()
        }
        let width = view.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right;
        let message = messages[indexPath.item]
        switch message.cellType {
        case .image:
            return CGSize(width: width, height: ChatImageMessageViewCell.imageSize)
        case .text:
            let text = (message as? ChatTextMessage)?.text ?? ""
            let textSize = ChatTextMessageViewCell.size(
                text: text,
                maxWidth: ChatMessagesViewController.maxWidthPct * width)
            return CGSize(width: width, height: textSize.height)
        }
    }
    
    private func adjustTopInset() {
        guard let collectionView = collectionView else {
            return
        }
        
        let topInset: CGFloat
        if #available(iOS 11.0, *) {
            topInset = view.safeAreaInsets.top
        } else {
            topInset = 0
        }
        
        collectionView.contentInset.top = max(
            view.bounds.height - collectionView.contentSize.height - collectionView.contentInset.bottom, topInset + ChatMessagesViewController.insets.top)
    }
}
