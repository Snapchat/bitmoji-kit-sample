//
//  ChatImageMessageViewCell.swift
//  BitmojiSDKSample
//
//  Created by David Xia on 2018-02-05.
//  Copyright © 2018 Bitmoji. All rights reserved.
//

import UIKit

class ChatImageMessageViewCell : UICollectionViewCell {
    static let imageSize: CGFloat = 180
    
    private let spinner = UIActivityIndicatorView()
    private let imageView = UIImageView()
    
    var isFromMe = true {
        didSet {
            guard oldValue != isFromMe else {
                return
            }
            setNeedsLayout()
        }
    }
    
    var imageURL: String? {
        didSet {
            guard oldValue != imageURL,
                let imageURL = imageURL,
                let url = URL(string: imageURL) else {
                return
            }
            if image == nil {
                spinner.isHidden = false
                spinner.startAnimating()
            }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                DispatchQueue.main.async {
                    guard let data = data, imageURL == self.imageURL else { return }
                    self.spinner.isHidden = true
                    self.spinner.stopAnimating()
                    self.imageView.image = UIImage(data: data)
                }
                }.resume()
        }
    }
    
    var image: UIImage? {
        set {
            imageURL = nil
            imageView.image = newValue
        }
        get {
            return imageView.image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spinner.color = UIColor.gray
        
        addSubview(imageView)
        addSubview(spinner)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = bounds.height
        let x = isFromMe ? bounds.width - imageSize : 0
        
        imageView.frame = CGRect(x: x, y: 0, width: imageSize, height: imageSize)
        spinner.center = imageView.center
    }
}
