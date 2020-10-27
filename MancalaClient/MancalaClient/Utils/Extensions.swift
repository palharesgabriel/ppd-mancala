//
//  UIView + Extensions.swift
//  MancalaClient
//
//  Created by Gabriel Palhares on 23/10/20.
//  Copyright © 2020 Gabriel Palhares. All rights reserved.
//

import UIKit

enum AlertType {
    case endGame
    case invalidMove
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant)
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setHeight(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
}

extension UIViewController {
    
    func configureNavigationBar(withTitle title: String, prefersLargeTitles: Bool) {
        let appearence = UINavigationBarAppearance()
        appearence.configureWithOpaqueBackground()
        appearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearence.backgroundColor = .systemPurple
        
        let navBar = navigationController?.navigationBar
        navBar?.compactAppearance = appearence
        navBar?.standardAppearance = appearence
        navBar?.scrollEdgeAppearance = appearence
        
        navBar?.prefersLargeTitles = prefersLargeTitles
        navigationItem.title = title
        navBar?.tintColor = .white
        navBar?.isTranslucent = true
        
        navBar?.overrideUserInterfaceStyle = .dark
        
    }
    
    func createAlert(title: String, message: String, type: AlertType) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        switch type {
        case .endGame:
            let playAgainAction = UIAlertAction(title: "Jogar Novamente", style: .default, handler: { _ in
                ClientManager.shared.restart()
            })
            let quitAction = UIAlertAction(title: "Sair", style: .destructive, handler: { _ in
                ClientManager.shared.quit()
            })
            
            alert.addAction(playAgainAction)
            alert.addAction(quitAction)
        case .invalidMove:
            let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
            
            alert.addAction(action)
        }
        
        present(alert, animated: true, completion: nil)
        return alert
    }
}
