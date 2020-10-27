//
//  CustomLabel.swift
//  MancalaClient
//
//  Created by Mateus Sales on 27/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {
    init(title: String, width: CGFloat, height: CGFloat, sizeFont: CGFloat) {
        super.init(frame: .zero)
        
        self.font = UIFont.boldSystemFont(ofSize: sizeFont)
        self.textColor = .white
        self.text = title
        self.textAlignment = .center
        self.setDimensions(width: width, height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
