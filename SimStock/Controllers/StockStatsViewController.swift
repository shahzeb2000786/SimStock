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
    
    var selectedStock: Stock = Stock(open: "0", high: "0", low: "0", price: "0" , volume: "0", date: "0", previousClose: "0", change: "0", changePercent: "0", exchange: "0", sector: "0", industry: "0", fiftyTwoHigh: "0", fiftyTwoLow: "0", peRatio: "0", marketCap: "0", dividendYield: "0", fiftyDayMovingAverage: "0", description: "0"){
        willSet{
            DispatchQueue.main.async {
                self.stockCurrentPriceLabel?.text = self.selectedStock.price
            }
        }
        didSet{
            
        }
    }
    
    override func loadView(){
        super.loadView()
        
        //instantiation of ui elements
        self.view.backgroundColor = UIColor.black
        let bottomBar = Bundle.main.loadNibNamed("BottomBar", owner: nil, options: nil)?.first as! BottomBar//UINib(nibName: "BottomBar", bundle: Bundle.main) as! BottomBar
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
        stockCurrentPriceLabel.textAlignment = .center
        stockCurrentPriceLabel.font = UIFont(name: stockCurrentPriceLabel.font.fontName, size: 50)
        stockCurrentPriceLabel.minimumScaleFactor = 0.5
        stockCurrentPriceLabel.adjustsFontSizeToFitWidth = true
        stockCurrentPriceLabel.backgroundColor = UIColor.clear
        stockCurrentPriceLabel.textColor = UIColor.white
        stockCurrentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        stockCurrentPriceLabel.text = selectedStock.price!
        NSLayoutConstraint.activate([
            stockCurrentPriceLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width/1.5),
            stockCurrentPriceLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height/15),
            stockCurrentPriceLabel.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
           // stockCurrentPriceLabel.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -15),
            stockCurrentPriceLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            //stockCurrentPriceLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)

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
                print(data)
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

