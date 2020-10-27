//
//  CustomButtonAction.swift
//  MancalaClient
//
//  Created by Mateus Sales on 27/10/20.
//  Copyright © 2020 Mateus Sales. All rights reserved.
//

import UIKit

class CustomButtonAction: UIButton {
    init(title: String, width: CGFloat, height: CGFloat, sizeFont: CGFloat) {
        super.init(frame: .zero)
        
        self.layer.cornerRadius = height / 2
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: sizeFont)
        self.backgroundColor = .systemOrange
        self.setDimensions(width: width, height: height)
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
