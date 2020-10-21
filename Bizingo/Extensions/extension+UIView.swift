//
//  extension+UIView.swift
//  Bizingo
//
//  Created by Matheus Damasceno on 11/02/20.
//  Copyright © 2020 Matheus Damasceno. All rights reserved.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { (view) in
            addSubview(view)
        }
    }
    
}
