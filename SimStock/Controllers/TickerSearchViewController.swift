//
//  TickerSearchViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 12/27/20.
//

import Foundation
import UIKit
class TickerSearchViewController: UIViewController{
    private let constants = K()
    private weak var tickerTableView: UITableView!
    private weak var tickerSearchBar: UISearchBar!
    
    private var tickersSymbolsList = [Ticker]()//this will contain a list of all the ticker symbols in the market
    private var tickersToBeDisplayed: [Ticker] = []{//this will be the ticker table view's data source and changes depending on the ticker search bar text.
        willSet{
            DispatchQueue.main.async{
                self.tickerTableView.reloadData()
            }
        }
        didSet{
        }
    }
    override func loadView(){
        super.loadView()
        getAllTickerSymbols()
        
        //instantiation of ui elements
        self.view.backgroundColor = UIColor.black
        let bottomBar = Bundle.main.loadNibNamed("BottomBar", owner: nil, options: nil)?.first as! BottomBar//UINib(nibName: "BottomBar", bundle: Bundle.main) as! BottomBar
        let tickerTableView = UITableView()
        let tickerSearchBar = UISearchBar()

        
        //adding ui elements to main view
        self.view.addSubview(bottomBar)
        self.view.addSubview(tickerTableView)
        self.view.addSubview(tickerSearchBar)
        
        
        //bottomBar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            bottomBar.heightAnchor.constraint(equalToConstant: self.view.frame.height/10.5),
            bottomBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        //tickerTableView
        tickerTableView.dataSource = self
        tickerTableView.delegate = self
        tickerTableView.backgroundColor = UIColor.black
        tickerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "tickerCell")
        tickerTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tickerTableView.heightAnchor.constraint(equalToConstant: self.view.frame.height - bottomBar.frame.height - tickerSearchBar.frame.height),
            tickerTableView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            tickerTableView.topAnchor.constraint(equalTo: tickerSearchBar.bottomAnchor),
            tickerTableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
        
        //tickerSearchBar
        tickerSearchBar.delegate = self
        tickerSearchBar.placeholder = "Enter ticker symbol"
        tickerSearchBar.barTintColor = UIColor.black
        let tickerSearchBarTextField = tickerSearchBar.value(forKey: "searchField") as? UITextField
        tickerSearchBarTextField?.textColor = UIColor.white
        tickerSearchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tickerSearchBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            tickerSearchBar.heightAnchor.constraint(equalToConstant: self.view.frame.height/14),
            tickerSearchBar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor)
        ])
        
       
        
        //assigning UI elements to class variables
        self.tickerTableView = tickerTableView
        self.tickerSearchBar = tickerSearchBar
        
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        
    }
}

//extension for UITableView DataSource
extension TickerSearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickersToBeDisplayed.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tickerTableView.dequeueReusableCell(withIdentifier: "tickerCell")!
        cell.textLabel?.text = tickersToBeDisplayed[indexPath.row].symbol + ": " + tickersToBeDisplayed[indexPath.row].description
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.black
        return cell
    }
}

//extension for UITableView Delegate
extension TickerSearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTickerSymbol = tickersToBeDisplayed[indexPath.row].displaySymbol
        
        let stockStatsViewController = StockStatsViewController()
        stockStatsViewController.selectedStockTicker = selectedTickerSymbol
       self.navigationController?.pushViewController(stockStatsViewController, animated: true)
    }
}

//extension for UISearchBar Delegate
extension TickerSearchViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchedTickerText = tickerSearchBar.text{
            if searchedTickerText == ""{
                tickersToBeDisplayed = tickersSymbolsList
            }else{
                let searchedText = tickerSearchBar.text?.uppercased()
                let filteredResults = tickersSymbolsList.filter{ $0.symbol.contains(searchedText!) || $0.description.contains(searchedText!)}
                tickersToBeDisplayed = filteredResults
            }
        }//end of optional bind
        
    }//end of textDidChange searchBar

}

//extension for URL requests
extension TickerSearchViewController{
    func getStockData(ticker: String){
        let urlString = constants.requestURL + "/current/" + ticker
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil || data == nil{
                print(error?.localizedDescription)
                fatalError("There was an error in retreiving information from the Alpha Vantage Api")
                
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode)else{
                fatalError("Error in getting response from server")
            }
            do{
                let decoder = JSONDecoder()
                let stockData = try decoder.decode(Stock.self, from: data!)
              //  self.currentStockPrice = stockData.high
            }catch{
                print ("Error in decoding JSON" + error.localizedDescription)
            }
            
        }//end of task
        task.resume()
    }//end of getstockData function
    
    
    func getAllTickerSymbols(){
        let urlString = constants.requestURL + "ticker-symbols"
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if (error != nil || data == nil){
                print(error?.localizedDescription)
                fatalError("There was an error, either the data was nil or there was an error in the request")
            }//if
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode)else{
                fatalError("There was an error in the response")
            }//guard let
            
            do{
                let decoder = JSONDecoder()
                let tickerDataArray = try decoder.decode([Ticker].self, from: data!)
                self.tickersSymbolsList = tickerDataArray
                self.tickersToBeDisplayed = tickerDataArray
            }catch{
                print (error.localizedDescription)
                fatalError("Error in convertiong the data into a swift object")
            }
        }//end of task
        task.resume()
    }//end of function

}
