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
    
    private weak var numberOfSharesLabel: UILabel!
    private weak var sharePriceLabel: UILabel!
    private weak var totalPriceOwedLabel: UILabel!
    private weak var placeOrderButton: UIButton!
    
    var ticker: String = ""
    var sharePrice: Float = 0.00 {
        willSet{
            DispatchQueue.main.async{
                    self.sharePriceLabel.text = String(self.sharePrice) 

            }//DispatchQueue
        }//willSet
    }
    var quantity: Float = 0{
        willSet{
            DispatchQueue.main.async {
                self.numberOfSharesLabel.text = String(self.quantity)
                self.totalPriceOwedLabel.text = String(self.quantity * self.sharePrice)
            }
        }
    }
    override func loadView() {
        super.loadView()
        self.navigationItem.title = "Buy " + ticker
        self.view.backgroundColor = .black
        
        let numberOfSharesLabel = UILabel()
        //sharesAmountLabel.text = "0"
        numberOfSharesLabel.textAlignment = .right
        let sharesPriceLabel = UILabel()
        sharesPriceLabel.text = "$0.00"
        sharesPriceLabel.textAlignment = .right
        let totalPriceOwedLabel = UILabel()
        totalPriceOwedLabel.text = "$0.00"
        totalPriceOwedLabel.textAlignment = .right
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
        
        let purchaseStockLabelArray = [
            [sharesAmountIdentifier, numberOfSharesLabel],
            [sharesPriceIdentifier, sharesPriceLabel],
            [totalPriceOwedIdentifier, totalPriceOwedLabel]
        ]
        let purchaseStockStackArray = [sharesAmountStack, sharesPriceStack, totalPriceStack]
        for i in 0...purchaseStockStackArray.count - 1{
            
            let stack = purchaseStockStackArray[i]
            let labels = purchaseStockLabelArray[i]
            stack.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/1.1, height: self.view.frame.height/14)
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.spacing = 20
            stack.backgroundColor = .clear
            stack.distribution = .fillEqually
            var i = 0
            print(labels.count)
            for label in labels{

                label.textColor = .white
                label.font = UIFont(name: label.font.fontName, size: 20)
                stack.addArrangedSubview(label)
                NSLayoutConstraint.activate([label.widthAnchor.constraint(equalToConstant: stack.frame.width/2.2)])
            }
            var bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0, y: stack.frame.height - 1, width: stack.frame.width, height: 1)
            bottomBorder.backgroundColor = UIColor.darkGray.cgColor
            stack.layer.addSublayer(bottomBorder)
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
        placeOrderButton.isUserInteractionEnabled = true
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
        mainVerticalStockStack.axis = .vertical
        mainVerticalStockStack.alignment = .center
        mainVerticalStockStack.spacing = 5
        mainVerticalStockStack.distribution = .fillEqually
        mainVerticalStockStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainVerticalStockStack.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            mainVerticalStockStack.heightAnchor.constraint(equalToConstant: self.view.frame.height/4),
            mainVerticalStockStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
      
     //assigning ui elements to class variables
        self.numberOfSharesLabel = numberOfSharesLabel
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
        
        placeOrderButton.addTarget(self, action: #selector(placeOrderButtonPressed), for: .touchUpInside)
    }
}

//extension to handle button actions
extension PurchaseViewController{
    @objc
    func keyPressed(sender: UIButton!){
        if let sharesText = numberOfSharesLabel.text{
            numberOfSharesLabel.text = sharesText + (sender.titleLabel?.text)!

        }else{ numberOfSharesLabel.text = sender.titleLabel?.text}
        self.quantity = Float(numberOfSharesLabel.text!) ?? 0.00
    }
    
    @objc
    func deleteKeyPressed(sender: UIButton!){
        if var sharesText = numberOfSharesLabel.text{
            print(sharesText)
            if sharesText.count == 0{
                numberOfSharesLabel.text? = ""
                self.quantity = 0
            }
            else{
                print("delete hit")
                numberOfSharesLabel.text?.removeLast()
                print(numberOfSharesLabel.text)
                self.quantity = Float(numberOfSharesLabel.text!) ?? 0.00
            }
        }//end of optional bind
    }//end of function
    
    @objc
    func placeOrderButtonPressed(sender: UIButton!){
        
        let firebaseFuncs = FirebaseFunctions()
        if ticker != "" && quantity != 0 && sharePrice != 0{
            firebaseFuncs.addStockToUser(tickerSymbol: ticker, quantity: quantity, stockPrice: sharePrice)
        }
        
    }//end of function
}//end of extension





