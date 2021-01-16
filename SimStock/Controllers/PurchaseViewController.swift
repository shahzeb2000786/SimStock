//
//  PurchaseViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/16/21.
//

import Foundation
import UIKit

class PurchaseViewController: UIViewController{
    override func loadView() {
        super.loadView()
        let numberPad = Bundle.main.loadNibNamed("NumberPad", owner: nil, options: nil)?.first as! NumberPad
        let placeOrderButton = UIButton()
        
        self.view.addSubview(numberPad)
        self.view.addSubview(placeOrderButton)
        
        //numberPad
        numberPad.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberPad.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            numberPad.heightAnchor.constraint(equalToConstant: self.view.frame.height/3),
            numberPad.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20)
        ])
        
        placeOrderButton.translatesAutoresizingMaskIntoConstraints = false
        placeOrderButton.backgroundColor = .systemGreen
        placeOrderButton.setTitle("Place Order", for: .normal)
        placeOrderButton.setTitleColor(.white, for: .normal)
        placeOrderButton.titleLabel?.font = UIFont(name: placeOrderButton.titleLabel!.font.fontName, size: 35)
        placeOrderButton.titleLabel?.font = UIFont(name: (placeOrderButton.titleLabel?.font.fontName)!, size: 30)
        NSLayoutConstraint.activate([
            placeOrderButton.widthAnchor.constraint(equalToConstant: self.view.frame.width/1.2),
            placeOrderButton.heightAnchor.constraint(equalToConstant: self.view.frame.height/15),
            placeOrderButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            placeOrderButton.bottomAnchor.constraint(equalTo: numberPad.topAnchor)
            
        ])
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
