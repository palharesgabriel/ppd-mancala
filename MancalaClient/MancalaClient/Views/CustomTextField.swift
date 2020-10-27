//
//  CustomTextField.swift
//  MancalaClient
//
//  Created by Mateus Sales on 27/10/20.
//  Copyright © 2020 Mateus Sales. All rights reserved.
//

import UIKit


class CustomTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.placeholder = placeholder
        self.layer.cornerRadius = 30
        self.setDimensions(width: 500, height: 60)
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 30)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
