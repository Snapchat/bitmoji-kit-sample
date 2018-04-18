//
//  TouchInterceptingView.swift
//  BitmojiSDKSample
//
//  Created by David Xia on 2018-02-06.
//  Copyright © 2018 Bitmoji. All rights reserved.
//

import UIKit

protocol TouchInterceptingViewDelegate: class {
    func touchIntercepted(point: CGPoint)
}

class TouchInterceptingView: UIView {
    
    weak var delegate: TouchInterceptingViewDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event?.type == UIEventType.touches {
            delegate?.touchIntercepted(point: point)
        }
        return super.hitTest(point, with: event)
    }
}
