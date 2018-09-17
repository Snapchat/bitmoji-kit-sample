//
//  ViewController.swift
//  BitmojiSDKSample
//
//  Created by Luke Zhao on 2017-10-24.
//  Copyright © 2017 Bitmoji. All rights reserved.
//

import UIKit
import SCSDKLoginKit
import SCSDKBitmojiKit

fileprivate let externalIdQuery = "{me{externalId}}"

class ChatViewController: UIViewController {
    
    var stickerViewHeight: CGFloat {
        if !bitmojiSearchHasFocus {
            return 250
        }
        let availableHeight = view.frame.height - inputBar.frame.height - keyboardHeight
        return availableHeight * 0.9
    }

    let inputBar = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "send_inactive"), for: .disabled)
        button.setImage(#imageLiteral(resourceName: "send_active"), for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        button.sizeToFit()
        
        return button
    }()
    let messagesVC = ChatMessagesViewController()
    private(set) lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 18
        textField.placeholder = "Message"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        textField.rightView = sendButton
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        return textField
    }()
    let stickerVC = SCSDKBitmojiStickerPickerViewController()
    private(set) lazy var unlinkButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Unlink", style: .plain, target: self, action: #selector(unlink))
        item.tintColor = .red
        
        return item
    }()
    private(set) lazy var friendmojiButton = UIBarButtonItem(title: "Friendmoji", style: .plain, target: self, action:#selector(toggleFriendmoji))

    var bottomConstraint: NSLayoutConstraint!
    var stickerPickerTopConstraint: NSLayoutConstraint!
    var bitmojisSent = 0
    
    var isStickerViewVisible = true {
        didSet {
            guard isStickerViewVisible != oldValue else {
                return
            }
            stickerVC.view.isHidden = !isStickerViewVisible
            stickerPickerTopConstraint.constant = isStickerViewVisible ? -stickerViewHeight : 0
        }
    }
    var keyboardHeight: CGFloat = 0
    var bitmojiSearchHasFocus = false {
        didSet {
            guard bitmojiSearchHasFocus != oldValue else {
                return
            }
            updateAndAnimateLayoutContstraints(duration: 0.3, options: [.beginFromCurrentState])
        }
    }
    var externalId: String? {
        didSet {
            navigationItem.rightBarButtonItems =
                externalId == nil ? [unlinkButton] : [unlinkButton, friendmojiButton]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        addChildViewController(messagesVC)
        view.addSubview(messagesVC.view)
        messagesVC.didMove(toParentViewController: self)
        messagesVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        stickerVC.view.translatesAutoresizingMaskIntoConstraints = false
        stickerVC.delegate = self
        self.addChildViewController(stickerVC)
        view.addSubview(stickerVC.view)
        stickerVC.didMove(toParentViewController: self)
        
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)

        navigationItem.rightBarButtonItems = [unlinkButton]
        navigationItem.title = "BFF 🤘"

        let bitmojiButton = SCSDKBitmojiIconView()
        bitmojiButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleStickerViewVisible)))
        bitmojiButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bitmojiButton)
        view.addSubview(textField)
        
        let bottomAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
        } else {
            bottomAnchor = view.bottomAnchor
        }
        
        bottomConstraint = stickerVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        stickerPickerTopConstraint = stickerVC.view.topAnchor.constraint(equalTo: bottomAnchor,
                                                                      constant: -stickerViewHeight)
        
        NSLayoutConstraint.activate([
            messagesVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messagesVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            messagesVC.view.bottomAnchor.constraint(equalTo: stickerVC.view.topAnchor),
            inputBar.bottomAnchor.constraint(equalTo: stickerVC.view.topAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.heightAnchor.constraint(equalToConstant: 48),
            bitmojiButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            bitmojiButton.heightAnchor.constraint(equalTo: textField.heightAnchor),
            bitmojiButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            bitmojiButton.widthAnchor.constraint(equalTo: textField.heightAnchor),
            textField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 36),
            textField.leadingAnchor.constraint(equalTo: bitmojiButton.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stickerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stickerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            stickerPickerTopConstraint
            ])

        SCSDKLoginClient.addLoginStatusObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)),
                                               name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        if SCSDKLoginClient.isUserLoggedIn {
            loadExternalId()
        }
    }
    
    override func loadView() {
        let view = TouchInterceptingView()
        view.delegate = self
        self.view = view
    }

    @objc func keyboardWillChangeFrame(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let rawAnimationCurveValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).uintValue
        let animationCurve = UIViewAnimationOptions(rawValue: rawAnimationCurveValue)
        let animationOptions: UIViewAnimationOptions = [animationCurve, .beginFromCurrentState]
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let bottomInset: CGFloat
        
        if #available(iOS 11.0, *) {
            bottomInset = view.safeAreaInsets.bottom
        } else {
            bottomInset = 0
        }
        
        keyboardHeight = max(0, view.bounds.height - bottomInset - keyboardViewEndFrame.minY)
        
        updateAndAnimateLayoutContstraints(duration: animationDuration, options: animationOptions)
    }
    
    @objc func textChanged() {
        sendButton.isEnabled = !(textField.text?.isEmpty ?? true)
    }
    
    @objc func send() {
        guard let text = textField.text, !text.isEmpty else {
            return
        }
        messagesVC.add(ChatTextMessage(isFromMe: true, text: text))
        sendButton.isEnabled = false
        textField.text = nil
    }
    
    @objc func unlink() {
        SCSDKLoginClient.unlinkCurrentSession(completion: nil)
    }
    
    @objc func toggleFriendmoji() {
        guard let externalId = externalId else {
            return
        }
        stickerVC.setFriendUserId(externalId)
    }
    
    @objc func toggleStickerViewVisible() {
        isStickerViewVisible = !isStickerViewVisible
        textField.endEditing(true)
    }
    
    private func updateAndAnimateLayoutContstraints(duration: TimeInterval, options: UIViewAnimationOptions) {
        bottomConstraint.constant = -keyboardHeight
        stickerPickerTopConstraint.constant = -keyboardHeight - (isStickerViewVisible ? stickerViewHeight : 0)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func loadExternalId() {
        SCSDKLoginClient.fetchUserData(
            withQuery: externalIdQuery,
            variables: nil,
            success: { resp in
                guard let resp = resp as? [String : Any],
                    let data = resp["data"] as? [String : Any],
                    let me = data["me"] as? [String : Any],
                    let externalId = me["externalId"] as? String else {
                        return
                }
                DispatchQueue.main.async {
                    self.externalId = externalId
                }
        }, failure: { _, _ in
            // handle error
        })
    }
}

extension ChatViewController: SCSDKLoginStatusObserver {

    func scsdkLoginLinkDidSucceed() {
        loadExternalId()
    }
}

extension ChatViewController: SCSDKBitmojiStickerPickerViewControllerDelegate {
    func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController,
                                            didSelectBitmojiWithURL bitmojiURL: String,
                                            image: UIImage?) {
        handleBitmojiSend(imageURL: bitmojiURL, image: image)
    }
    
    func bitmojiStickerPickerViewController(_ stickerPickerViewController: SCSDKBitmojiStickerPickerViewController, searchFieldFocusDidChangeWithFocus hasFocus: Bool) {
        bitmojiSearchHasFocus = hasFocus
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        send()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isStickerViewVisible = false
    }
}

extension ChatViewController: TouchInterceptingViewDelegate {
    func touchIntercepted(point: CGPoint) {
        let stickerPoint = view.convert(point, to: stickerVC.view)
        if stickerVC.view.hitTest(stickerPoint, with: nil) == nil {
            stickerVC.view.endEditing(true)
        }
    }
}

extension ChatViewController {
    func handleBitmojiSend(imageURL: String, image: UIImage?) {
        messagesVC.add(ChatImageURLMessage(isFromMe: true, imageURL: imageURL, image: image))
        
        if bitmojisSent == 0 {
            sendMessagesFromFriend()
        } else if bitmojisSent == 1 {
            partyTime()
        } else if bitmojisSent == 2 {
            lol()
        } else if bitmojisSent == 14 {
            chill()
        }
        bitmojisSent += 1
    }
    
    func sendMessagesFromFriend() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.messagesVC.add(ChatTextMessage(isFromMe: false, text: "Woah, nice Bitmoji!"))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.messagesVC.add(ChatImageMessage(isFromMe: false, image: #imageLiteral(resourceName: "looking_good")))
        }
    }
    
    func partyTime() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.messagesVC.add(ChatImageMessage(isFromMe: false, image: #imageLiteral(resourceName: "party_time")))
        }
    }
    
    func lol() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.messagesVC.add(ChatTextMessage(isFromMe: false, text: "lol"))
        }
    }
    
    func chill() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.messagesVC.add(ChatImageMessage(isFromMe: false, image: #imageLiteral(resourceName: "chill")))
        }
    }
}
