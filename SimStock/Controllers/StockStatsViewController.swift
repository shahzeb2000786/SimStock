//
//  StockStatsViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/1/21.
//
import Foundation
import UIKit
class StockStatsViewController: UIViewController, UINavigationControllerDelegate{
    
    weak var stockCurrentPriceLabel: UILabel!
    weak var stockStatView: StockStatView!
    
    var selectedStockTicker: String = "WMT" //{
    
    var selectedStockArray: [Stock] = []{
        willSet{
            DispatchQueue.main.async{
//                for stock in self.selectedStockArray{
//                    print(stock.date)
//                }
            }
        }
    }
    var selectedStock: Stock = Stock(open: "0", high: "0", low: "0", price: "0" , volume: "0", date: "0", previousClose: "0", change: "0", changePercent: "0", exchange: "0", sector: "0", industry: "0", fiftyTwoHigh: "0", fiftyTwoLow: "0", peRatio: "0", marketCap: "0", dividendYield: "0", fiftyDayMovingAverage: "0", description: "0"){
        willSet{
            print(selectedStock)
            DispatchQueue.main.async{
                self.stockCurrentPriceLabel?.text = self.selectedStock.price
                self.stockStatView.openPriceLabel.text = self.selectedStock.open
                self.stockStatView.highPriceLabel.text = self.selectedStock.high
                self.stockStatView.lowPriceLabel.text = self.selectedStock.low
                self.stockStatView.fiftyTwoWeekHighLabel.text = self.selectedStock.fiftyTwoHigh
                self.stockStatView.fiftyTwoWeekLowLabel.text = self.selectedStock.fiftyTwoLow
                self.stockStatView.volumeLabel.text = self.selectedStock.volume
                self.stockStatView.peRatioLabel.text = self.selectedStock.peRatio
                self.stockStatView.dividendYieldLabel.text = self.selectedStock.dividendYield
                self.stockStatView.marketCapLabel.text = self.selectedStock.marketCap
                self.stockStatView.fiftyDayMovingAverageLabel.text = self.selectedStock.fiftyDayMovingAverage

            }
        }
        didSet{

        }
    }
    
    override func loadView(){
        super.loadView()
        self.edgesForExtendedLayout = []//makes items which are put into the view appear under the navigation bar
        //instantiation of ui elements
        self.view.backgroundColor = UIColor.black
        let bottomBar = Bundle.main.loadNibNamed("BottomBar", owner: nil, options: nil)?.first as! BottomBar//UINib(nibName: "BottomBar", bundle: Bundle.main) as! BottomBar
        let stockScrollView = UIScrollView()
        stockScrollView.showsHorizontalScrollIndicator = false
        stockScrollView.contentSize = CGSize(width: self.view.frame.width, height: 2000)

        let stockStatView = Bundle.main.loadNibNamed("StockStatView", owner: nil, options: nil)?.first as! StockStatView
        let stockCurrentPriceLabel = UILabel()
//
//        //adding ui elements to main view
        self.view.addSubview(bottomBar)
        self.view.addSubview(stockScrollView)

        //bottomBar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            bottomBar.heightAnchor.constraint(equalToConstant: self.view.frame.height/10.5),
            bottomBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        stockScrollView.translatesAutoresizingMaskIntoConstraints = false
        stockScrollView.backgroundColor = UIColor.red
        stockScrollView.addSubview(stockStatView)
        stockScrollView.addSubview(stockCurrentPriceLabel)
        NSLayoutConstraint.activate([
            stockScrollView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stockScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            stockScrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
        
        //stockStatView
//        print("pizza")
//        print(stockScrollView.bottomAnchor)
        stockStatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stockStatView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stockStatView.heightAnchor.constraint(equalToConstant: self.view.frame.height/1.5),
        ])

        //stockCurrentPriceLabel
        stockCurrentPriceLabel.textAlignment = .center
        stockCurrentPriceLabel.font = UIFont(name: stockCurrentPriceLabel.font.fontName, size: 50)
        stockCurrentPriceLabel.minimumScaleFactor = 0.5
        stockCurrentPriceLabel.adjustsFontSizeToFitWidth = true
        stockCurrentPriceLabel.backgroundColor = UIColor.clear
        stockCurrentPriceLabel.textColor = UIColor.white
        stockCurrentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        stockCurrentPriceLabel.text = "Hello there"

       stockCurrentPriceLabel.text = selectedStock.price!
        NSLayoutConstraint.activate([
            stockCurrentPriceLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width/1.5),
            stockCurrentPriceLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height/15),
            stockCurrentPriceLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])

       
        
        

        
        //assigning UI elements to class variables
        self.stockCurrentPriceLabel = stockCurrentPriceLabel
        self.stockStatView = stockStatView
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        navigationController?.delegate = self
        getSelectedStock(ticker: selectedStockTicker)
        //getDailySelectedStock(ticker: selectedStockTicker)
    }
}


//extension for any api calls needed for the view controller
extension StockStatsViewController{
    func getSelectedStock(ticker: String){
        let urlString = "http://localhost:3000/current/" + ticker
        print(urlString)
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
    }//end of getStockData function
    
    //function calls daily stock get route which returns an array stock objects from the past 100 days
    func getDailySelectedStock(ticker: String){
        let urlString = "http://localhost:3000/daily/" + ticker
        print(urlString)
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
                let stockData = try decoder.decode([Stock].self, from: data!)
                print(ticker)
                self.selectedStockArray = stockData
            }catch{
                print ("Error in decoding JSON" + error.localizedDescription)
            }
            
        }//end of task
        task.resume()
    }//end of getStockData function
}


