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
    
    var selectedStockTicker: String = "WMT" //{
    
    var selectedStock: Stock = Stock(open: "0",high: "0",low: "0",close: "0",volume: "0",date: "0") {
        willSet{
            DispatchQueue.main.async {
                self.stockCurrentPriceLabel?.text = self.selectedStock.close
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
        self.view.addSubview(stockCurrentPriceLabel)
        
        //bottomBar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            bottomBar.heightAnchor.constraint(equalToConstant: self.view.frame.height/10.5),
            bottomBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        //stockCurrentPriceLabel
        stockCurrentPriceLabel.backgroundColor = UIColor.gray
        stockCurrentPriceLabel.text = selectedStock.close
        NSLayoutConstraint.activate([
            stockCurrentPriceLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stockCurrentPriceLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height/10),
            stockCurrentPriceLabel.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
        //assigning UI elements to class variables
        self.stockCurrentPriceLabel = stockCurrentPriceLabel
        
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        getSelectedStock(ticker: selectedStockTicker)
    }
}


//extension for any api calls needed for the view controller
extension StockStatsViewController{
    func getSelectedStock(ticker: String){
        let urlString = "http://localhost:3000/current/" + ticker
        print(urlString)
        print("The fjsl;fj is " + ticker)
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil || data == nil{
                print(error?.localizedDescription)
                print("There was an error in retreiving information from the Alpha Vantage Api")
                fatalError("There was an error in retreiving information from the Alpha Vantage Api")
                
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode)else{
                print("Error in server")
                fatalError("Error in getting response from server")
            }
            do{
                let decoder = JSONDecoder()
                let stockData = try decoder.decode(Stock.self, from: data!)
                print(stockData)
                print(ticker)
                self.selectedStock = stockData
            }catch{
                print ("Error in decoding JSON" + error.localizedDescription)
            }
            
        }//end of task
        task.resume()
    }//end of getstockData function
}


