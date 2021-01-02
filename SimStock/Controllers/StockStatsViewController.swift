//
//  StockStatsViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/1/21.
//

import Foundation
import UIKit
class StockStatsViewController: UIViewController{
    
    weak var stockCurrentPriceLabel: UILabel!
    
    var stock: StockStats = StockStats(open: "0",high: "0",low: "0",close: "0",volume: "0",date: "0") {
        willSet{
            DispatchQueue.main.async {
                print(self.stock)
                self.stockCurrentPriceLabel.text = self.stock.close
            }
        }
        didSet{
            
        }
    }
    
    override func loadView(){
        super.loadView()
        
        //instantiation of ui elements
        self.view.backgroundColor = UIColor.black
        let bottomBar = Bundle.main.loadNibNamed("BottomBar", owner: nil, options: nil)?.first as! BottomBar
        let stockCurrentPriceLabel = UILabel()
        
        //adding ui elements to main view
        self.view.addSubview(bottomBar)
        
        
        //bottomBar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            bottomBar.heightAnchor.constraint(equalToConstant: self.view.frame.height/10.5),
            bottomBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        //stockCurrentPriceLabel
        stockCurrentPriceLabel.backgroundColor = UIColor.gray
        stockCurrentPriceLabel.text = stock.close
        NSLayoutConstraint.activate([
            stockCurrentPriceLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stockCurrentPriceLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height/2),
            stockCurrentPriceLabel.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
        //assigning UI elements to class variables
        self.stockCurrentPriceLabel = stockCurrentPriceLabel
        
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        
    }
}


//extension for any api calls needed for the view controller
extension StockStatsViewController{
    func getStockData(){
        
    }
}

    
    


