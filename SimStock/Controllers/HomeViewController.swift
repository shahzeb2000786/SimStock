//
//  ViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 12/19/20.
//

import UIKit
import Firebase
class HomeViewController: UIViewController{
    private let constants = K()
    private let db = Firestore.firestore()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private weak var purchasedStocksTableView: UITableView!
    private weak var totalUserEquityLabel: UILabel!


    private var totalUserEquity: Float = 0.00 {
        willSet{
            DispatchQueue.main.async{
                self.totalUserEquityLabel.text = String(self.totalUserEquity)
            }//dispatchqueue
        }//willSet
    }//end of observed property

    //the initial stock put into the listOfUserStocks will set the title columns for tableview
    private var listOfUserStocks: [Stock] = [Stock(ticker: "Ticker", price: "Price", quantity: "quantity", change: "↑↓"  )]{
        willSet{
            DispatchQueue.main.async{
                self.purchasedStocksTableView.reloadData()
            }//dispatchqueue
        }//willSet
    }//end of observed property

    override func loadView(){
        super.loadView()
        let firebaseFunctions = FirebaseFunctions()
        Auth.auth().createUser(withEmail: "shahzeb2000786@gmail.com", password: "random") { authResult, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        //instantiation of UI elements for view
        self.view.backgroundColor = UIColor.black
        let bottomBar = Bundle.main.loadNibNamed("BottomBar", owner: nil, options: nil)?.first as! BottomBar//UINib(nibName: "BottomBar", bundle: Bundle.main) as! BottomBar
        let tickerSearchButton = bottomBar.tickerSearchButton
        tickerSearchButton?.addTarget(self, action: #selector (tickerSearchButtonAction), for: .touchUpInside)
        let purchasedStocksTableView = UITableView(frame: .zero)
        let amountOfUserStockGrowthLabel = UILabel()
        let totalUserEquityLabel = UILabel()
        let tickerSearchBar = UISearchBar()

        //adding ui elements to main view
        self.view.addSubview(bottomBar)
        self.view.addSubview((purchasedStocksTableView))
        self.view.addSubview(totalUserEquityLabel)
        self.view.addSubview(amountOfUserStockGrowthLabel)
        self.view.addSubview(tickerSearchBar)

        //bottomBar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            bottomBar.heightAnchor.constraint(equalToConstant: self.view.frame.height/10.5),
            bottomBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        //purchaseStocksTableView
        purchasedStocksTableView.translatesAutoresizingMaskIntoConstraints = false
        purchasedStocksTableView.separatorColor = UIColor.gray
        purchasedStocksTableView.dataSource = self
        purchasedStocksTableView.delegate = self
        purchasedStocksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "stockCell")
        purchasedStocksTableView.backgroundColor = UIColor.black
       // purchasedStocksTableView.tableHeaderView = UITableViewHeaderFooterView(
        NSLayoutConstraint.activate([
            purchasedStocksTableView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            purchasedStocksTableView.heightAnchor.constraint(equalToConstant: self.view.frame.height/1.9),
            purchasedStocksTableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)

        ])
        purchasedStocksTableView.register(UINib(nibName: "StockInfoCell" , bundle: nil), forCellReuseIdentifier: "StockInfoCell")


        //amountOfUserStockGrowthLabel
        amountOfUserStockGrowthLabel.textAlignment = .center
        amountOfUserStockGrowthLabel.text = "+ $5.67"
        amountOfUserStockGrowthLabel.textColor = UIColor.green
        amountOfUserStockGrowthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            amountOfUserStockGrowthLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width/1.5),
            amountOfUserStockGrowthLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height/15),
            amountOfUserStockGrowthLabel.bottomAnchor.constraint(equalTo: purchasedStocksTableView.topAnchor, constant: -15),
            amountOfUserStockGrowthLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])


        //totalMoneyEarnedLabel
        totalUserEquityLabel.textAlignment = .center
        totalUserEquityLabel.font = UIFont(name: totalUserEquityLabel.font.fontName, size: 50)
        totalUserEquityLabel.minimumScaleFactor = 0.3
        totalUserEquityLabel.adjustsFontSizeToFitWidth = true
        totalUserEquityLabel.text = "-"
        totalUserEquityLabel.backgroundColor = UIColor.clear
        totalUserEquityLabel.textColor = UIColor.white
        totalUserEquityLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalUserEquityLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width/1.5),
            totalUserEquityLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height/11),
            totalUserEquityLabel.bottomAnchor.constraint(equalTo: amountOfUserStockGrowthLabel.topAnchor),
            totalUserEquityLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])

        tickerSearchBar.placeholder = "Enter ticker symbol"
        tickerSearchBar.barTintColor = UIColor.black
        tickerSearchBar.barStyle = UIBarStyle(rawValue: 2)!
        tickerSearchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tickerSearchBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            tickerSearchBar.heightAnchor.constraint(equalToConstant: self.view.frame.height/14),
            tickerSearchBar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor)
        ])

        self.totalUserEquityLabel = totalUserEquityLabel
        self.purchasedStocksTableView = purchasedStocksTableView
        firebaseFunctions.setUserBalanceLabel(labelToUpdate: self.totalUserEquityLabel)

    }

    override func viewDidLoad() {
        getUsersStock()
        super.viewDidLoad()
        navigationItem.hidesBackButton = false
        //getStockData(ticker: "ibm")
    }



}

//extension for tableview delegate
extension HomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if statement only executes if the title screen cell for the tableview is not clicked
        if indexPath.row != 0{
            let selectedTickerSymbol = self.listOfUserStocks[indexPath.row].ticker
            let stockStatsViewController = StockStatsViewController()
            stockStatsViewController.selectedStockTicker = selectedTickerSymbol ?? "MSFT"
            self.navigationController?.pushViewController(stockStatsViewController, animated: true)
        }//if

    }//end of function
}//end of extension

//extension for tableview datasource
extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listOfUserStocks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = purchasedStocksTableView.dequeueReusableCell(withIdentifier: "StockInfoCell") as! StockInfoCell
        cell.amountGrownLabel.font = UIFont(name: cell.amountGrownLabel.font.fontName, size: 25)
        cell.amountGrownLabel.textColor = UIColor.white
            let currentStock = self.listOfUserStocks[indexPath.row]

            cell.tickerLabel.text = currentStock.ticker
            cell.stockValueLabel.text = currentStock.price
            cell.quantityLabel.text = currentStock.quantity
            cell.amountGrownLabel.text = currentStock.change
        cell.awakeFromNib()
        return cell
    }
}

//extension to handle button actions
extension HomeViewController{
    @objc
    func tickerSearchButtonAction(sender: UIButton!){
        let tickerView = TickerSearchViewController()
        navigationController?.pushViewController(tickerView, animated: true)
    }
}
//extension for URL requests
extension HomeViewController{
    func getStockData(ticker: String, quantityOfStockOwned: Float){
        let urlString = constants.requestURL + "current/" + ticker
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

                if let stockPrice = (stockData.price) {
                    if let floatStockPrice = Float(stockPrice){
                        let totalStockValueOwned = floatStockPrice * quantityOfStockOwned
                        self.totalUserEquity += totalStockValueOwned
                    }//inner optional bind floatStockPrice
                    self.listOfUserStocks.append(stockData)//only appends stock if it has a price
                }//outer optional bind of stockPrice

            }catch{
                print ("Error in decoding JSON" + error.localizedDescription)
            }
        }//end of task
        task.resume()
    }//end of getstockData function
}
//extension to handle firebase calls
extension HomeViewController{
    func getUsersStock(){
        let userDoc = db.collection("Users").document(appDelegate.email)
        userDoc.getDocument { (document, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let document = document{
                guard var userCurrentBalance = document.get("currentBalance") as? Float else{return}
                guard let currentStocks = document.get("stocks") as? NSDictionary else {
                    print(error?.localizedDescription ?? "Could not get stocks as NSdictioanry")
                    return}
                self.totalUserEquity = userCurrentBalance
                for (tickerKey, stockObject) in currentStocks{
                    guard let tickerKey = tickerKey as? String else{continue}
                    guard let stockObject = stockObject as? NSDictionary else{continue}
                    guard let quantityOfStockOwned = stockObject["quantity"] as? Float else{continue}

                    self.getStockData(ticker: tickerKey, quantityOfStockOwned: quantityOfStockOwned)
                }//for loop
            }//optional bind of document
        }//getDocument closure
    }//end of function
}
