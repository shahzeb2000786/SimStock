//
//  PurchaseViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/16/21.
//

import Foundation
import UIKit

class PurchaseViewController: UIViewController{
    private let numberPad = Bundle.main.loadNibNamed("NumberPad", owner: nil, options: nil)?.first as! NumberPad
    
    private weak var sharesAmountLabel: UILabel!
    private weak var sharePriceLabel: UILabel!
    private weak var totalPriceOwedLabel: UILabel!
    private weak var placeOrderButton: UIButton!
    override func loadView() {
        super.loadView()
        
        let sharesAmount = UILabel()
        let sharesPriceLabel = UILabel()
        let totalPriceOwedLabel = UILabel()
        let placeOrderButton = UIButton()
        
        let sharesAmountIdentifier = UILabel()
        sharesAmountIdentifier.text = "Shares Amount"
        let sharesPriceIdentifier = UILabel()
        sharesPriceIdentifier.text = "Share Price"
        let totalPriceOwedIdentifier = UILabel()
        totalPriceOwedIdentifier.text = "Total"
        
        let sharesAmountStack = UIStackView()
        let sharesPriceStack = UIStackView()
        let totalPriceStack = UIStackView()
        let mainVerticalStockStack = UIStackView()
        
        let rando = UILabel()
        let purchaseStockLabelArray = [
            [sharesAmountIdentifier, sharesAmount],
            [sharesPriceIdentifier, sharesPriceLabel],
            [totalPriceOwedIdentifier, totalPriceOwedLabel]
        ]
        let purchaseStockStackArray = [sharesAmountStack, sharesPriceStack, totalPriceStack]
        for i in 0...purchaseStockStackArray.count - 1{
            
            let stack = purchaseStockStackArray[i]
            let labels = purchaseStockLabelArray[i]
            stack.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/1.2, height: self.view.frame.height/14)
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.spacing = 50
            stack.backgroundColor = .clear
            stack.distribution = .fillEqually
            var i = 0
            print(labels.count)
            for label in labels{
                label.text = "random"
                label.textColor = .white
                label.backgroundColor = .green
                label.font = UIFont(name: label.font.fontName, size: 20)
                stack.addArrangedSubview(label)
            }
            mainVerticalStockStack.addArrangedSubview(stack)
        }

        
        self.view.addSubview(numberPad)
        self.view.addSubview(placeOrderButton)
        self.view.addSubview(mainVerticalStockStack)
        
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
        placeOrderButton.titleLabel?.font = UIFont(name: (placeOrderButton.titleLabel?.font.fontName)!, size: 20)
        NSLayoutConstraint.activate([
            placeOrderButton.widthAnchor.constraint(equalToConstant: self.view.frame.width/1.15),
            placeOrderButton.heightAnchor.constraint(equalToConstant: self.view.frame.height/18),
            placeOrderButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            placeOrderButton.bottomAnchor.constraint(equalTo: numberPad.topAnchor)
            
        ])
        
        //mainVerticalStockStack
        mainVerticalStockStack.backgroundColor = .clear
        mainVerticalStockStack.backgroundColor = .gray
        mainVerticalStockStack.axis = .vertical
        mainVerticalStockStack.alignment = .center
        mainVerticalStockStack.spacing = 5
        mainVerticalStockStack.distribution = .fillEqually
        mainVerticalStockStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainVerticalStockStack.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            mainVerticalStockStack.heightAnchor.constraint(equalToConstant: self.view.frame.height/4),
            mainVerticalStockStack.bottomAnchor.constraint(equalTo: placeOrderButton.topAnchor)
        ])
//        sharesAmountLabel.textColor = .white
//        sharesAmountLabel.backgroundColor = .black
//        sharesAmountLabel.font = UIFont(name: sharesAmountLabel.font.fontName, size: 35)
//        sharesAmountLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            sharesAmountLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width),
//            sharesAmountLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height/15),
//            sharesAmountLabel.bottomAnchor.constraint(equalTo: placeOrderButton.topAnchor)
//        ])
      
     //assigning ui elements to class variables
        self.sharesAmountLabel = sharesAmount
        self.sharePriceLabel = sharesPriceLabel
        self.totalPriceOwedLabel = totalPriceOwedLabel
        self.placeOrderButton = placeOrderButton

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        numberPad.oneKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.twoKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.threeKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.fourKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.fiveKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.sixKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.sevenKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.eightKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.nineKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.zeroKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        numberPad.deleteKey.addTarget(self, action: #selector(deleteKeyPressed), for: .touchUpInside)
        numberPad.decimalKey.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
    }
}

//extension to handle button actions
extension PurchaseViewController{
    @objc
    func keyPressed(sender: UIButton!){
        if let sharesText = sharesAmountLabel.text{
            sharesAmountLabel.text = sharesText + (sender.titleLabel?.text)!
        }else{ sharesAmountLabel.text = sender.titleLabel?.text}
    }
    
    @objc
    func deleteKeyPressed(sender: UIButton!){
        if var sharesText = sharesAmountLabel.text{
            sharesAmountLabel.text?.removeLast()
        }
    }
}


