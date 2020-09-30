//
//  UIViewController+Ext.swift
//
//  Created by Abdelrahman Sobhy
//


import UIKit


extension UIViewController {
    
  
    func alertWith(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "يلا", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
