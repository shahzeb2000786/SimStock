//
//  ViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 12/19/20.
//

import UIKit
import Firebase
class HomeViewController: UIViewController {
    private let db = Firestore.firestore()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private weak var purchasedStocksTableView: UITableView!
    private weak var totalMoneyEarnedLabel: UILabel!

    private var currentStockPrice: String = ""{
        willSet{
//            DispatchQueue.main.async{
//                self.totalMoneyEarnedLabel.text = self.currentStockPrice
//            }
        }didSet{}
    
    }

    private var listOfUserStocks: [Stock] = [Stock()]{
        willSet{
            DispatchQueue.main.async{
                self.purchasedStocksTableView.reloadData()
            }
        }
        didSet{}
    }
 
    override func loadView(){
        super.loadView()
        let firebaseFunctions = FirebaseFunctions()
        Auth.auth().createUser(withEmail: "shahzeb2000786@gmail.com", password: "random") { authResult, error in
            if let error = error {
                print(error.localizedDescription)
            } else{
                print( authResult)
            }
        }
        //instantiation of UI elements for view
        self.view.backgroundColor = UIColor.black
        let bottomBar = Bundle.main.loadNibNamed("BottomBar", owner: nil, options: nil)?.first as! BottomBar//UINib(nibName: "BottomBar", bundle: Bundle.main) as! BottomBar
        let tickerSearchButton = bottomBar.tickerSearchButton
        tickerSearchButton?.addTarget(self, action: #selector (tickerSearchButtonAction), for: .touchUpInside)
        let purchasedStocksTableView = UITableView(frame: .zero)
        let amountOfUserStockGrowthLabel = UILabel()
        let totalMoneyEarnedLabel = UILabel()
        let tickerSearchBar = UISearchBar()
        
        //adding ui elements to main view
        self.view.addSubview(bottomBar)
        self.view.addSubview((purchasedStocksTableView))
        self.view.addSubview(totalMoneyEarnedLabel)
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
        totalMoneyEarnedLabel.textAlignment = .center
        totalMoneyEarnedLabel.font = UIFont(name: totalMoneyEarnedLabel.font.fontName, size: 50)
        totalMoneyEarnedLabel.minimumScaleFactor = 0.5
        totalMoneyEarnedLabel.adjustsFontSizeToFitWidth = true
        totalMoneyEarnedLabel.text = "$10000.00"
        totalMoneyEarnedLabel.backgroundColor = UIColor.clear
        totalMoneyEarnedLabel.textColor = UIColor.white
        totalMoneyEarnedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalMoneyEarnedLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width/1.5),
            totalMoneyEarnedLabel.heightAnchor.constraint(equalToConstant: self.view.frame.height/11),
            totalMoneyEarnedLabel.bottomAnchor.constraint(equalTo: amountOfUserStockGrowthLabel.topAnchor),
            totalMoneyEarnedLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
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
        print(self.view.safeAreaInsets.top)

        self.totalMoneyEarnedLabel = totalMoneyEarnedLabel
        self.purchasedStocksTableView = purchasedStocksTableView
        firebaseFunctions.setUserBalanceLabel(labelToUpdate: self.totalMoneyEarnedLabel)

    }
    
    override func viewDidLoad() {
        getUsersStock()
        super.viewDidLoad()
        navigationItem.hidesBackButton = false
        //getStockData(ticker: "ibm")
    }
    


}

extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listOfUserStocks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentStock = self.listOfUserStocks[indexPath.row]
        let cell = purchasedStocksTableView.dequeueReusableCell(withIdentifier: "StockInfoCell") as! StockInfoCell
        cell.amountGrownLabel.font = UIFont(name: cell.amountGrownLabel.font.fontName, size: 25)
        cell.amountGrownLabel.textColor = UIColor.white
        
        if indexPath.row == 0{
            print(indexPath.row)
            cell.tickerLabel.text = "Ticker"
            cell.stockValueLabel.text = "Price"
            cell.quantityLabel.text = "Qty"
            cell.amountGrownLabel.text = "↑↓"
           // cell.growthImageView.image
        }else{
            cell.tickerLabel.text = currentStock.ticker
            cell.stockValueLabel.text = currentStock.price
            cell.quantityLabel.text = "1"
            cell.amountGrownLabel.text = "↑↓"
        }
        cell.awakeFromNib()
        return cell
    }
}

//extension for URL requests
extension HomeViewController{
    func getStockData(ticker: String){
        let urlString = "http://localhost:3000/current/ibm"
        
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
                self.currentStockPrice = stockData.high!
            }catch{
                print ("Error in decoding JSON" + error.localizedDescription)
            }
        }//end of task
        task.resume()
    }//end of getstockData function
}

//extension to handle button actions
extension HomeViewController{
    @objc
    func tickerSearchButtonAction(sender: UIButton!){
        let tickerView = TickerSearchViewController()
        navigationController?.pushViewController(tickerView, animated: true)
    }
}

//extension to handle firebase calls
extension HomeViewController{
    func getUsersStock(){
        let userDoc = db.collection("Users").document(appDelegate.email)
        var arrayOfStocks: [Stock] = []
        
        userDoc.getDocument { (document, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let document = document{
               // let updatedUserBalance = userCurrentBalance - amountDueForPayment//
                guard let currentStocks = document.get("stocks") as? NSDictionary else {
                    print(error?.localizedDescription ?? "Could not get stocks as NSdictioanry")
                    return}
                
                for (tickerKey, stockObject) in currentStocks{
                    var stockToAppend = Stock()
                    guard let tickerKey = tickerKey as? String else{continue}
                    guard let stockObject = stockObject as? NSDictionary else{continue}
                    guard let currentNumOfStockOwned = stockObject["quantity"] as? Float else{continue}
                    
                    stockToAppend.ticker = tickerKey
                    stockToAppend.price = "1000"
                    arrayOfStocks.append(stockToAppend)
                }//for loop
                self.listOfUserStocks = arrayOfStocks
             //   tickerArrayToSet = arrayOfStocks
            }//optional bind of document
        }//getDocument closure
        
    }//end of function
}
