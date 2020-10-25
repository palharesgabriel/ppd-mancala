//
//  CalaButton.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 23/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

enum TypeCala {
    case mainCala
    case commonCala
}

class CustomButton: UIButton {
    init(type: TypeCala, color: UIColor) {
        super.init(frame: .zero)
        switch type {
        case .commonCala:
            layer.cornerRadius = 10
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 42)
            backgroundColor = color
            setDimensions(width: 80, height: 80)
            setTitle("0", for: .normal)
            setTitleColor(.white, for: .normal)
        case .mainCala:
            layer.cornerRadius = 10
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 42)
            backgroundColor = color
            setDimensions(width: 100, height: 240)
            setTitle("0", for: .normal)
            setTitleColor(.white, for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
       
}
