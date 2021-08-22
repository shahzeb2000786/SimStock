//
//  StockStatsViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/1/21.
//
import Foundation
import UIKit
import Charts
import FirebaseFirestore
class StockStatsViewController: UIViewController, UINavigationControllerDelegate{
    private let constants = K()
    lazy var lineChartView: LineChartView = {
        let chartView  = LineChartView()
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.zoomIn()
        chartView.zoomOut()
        //chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInOutSine)
        chartView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height/2)
        //let yAxis = chartView.leftAxis
       // yAxis.labelFont = .boldSystemFont(ofSize: 12.0)
       // yAxis.labelTextColor = .white
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12.0)
        chartView.xAxis.labelTextColor = .white
        chartView.xAxis.labelPosition = .bottom
        return chartView
    }()
    
    weak var stockCurrentPriceLabel: UILabel!
    weak var stockStatView: StockStatView!
    
    weak var dailyStockButton: UIButton!
    weak var weeklyStockButton: UIButton!
    weak var monthlyStockButton: UIButton!
    weak var threeMonthlyStockButton: UIButton!
    weak var yearlyStockButton: UIButton!
    weak var fiveYearlyStockButton: UIButton!
    weak var twentyYearlyStockButton: UIButton!
    
    var yValues: [ChartDataEntry] = []
    var selectedStockTicker: String = "WMT" //{
    var selectedStockTotalDataArray: [Stock] = []
    var selectedStockArray: [Stock] = []{
        willSet{
            yValues = []
            DispatchQueue.main.async{
                var increment = 0.0
                for stock in self.selectedStockArray{
                    let entry = ChartDataEntry(x: increment, y: Double(stock.price!) ?? 10.00)
                    self.yValues.append(entry)
                    increment += 1
                }
                self.setData()
            }
        }
    }
    var selectedStockPrice: String = ""{
        willSet{
            DispatchQueue.main.async{
                self.stockCurrentPriceLabel?.text = "$" + self.selectedStockPrice
            }
        }
    }
    var selectedStock: Stock = Stock(open: "0", high: "0", low: "0", price: "0" , volume: "0", date: "0", previousClose: "0", change: "0", changePercent: "0", exchange: "0", sector: "0", industry: "0", fiftyTwoHigh: "0", fiftyTwoLow: "0", peRatio: "0", marketCap: "0", dividendYield: "0", fiftyDayMovingAverage: "0", description: "0"){
        willSet{
            let optionalDollarSign: String? = "$"
            DispatchQueue.main.async{
                self.navigationItem.title = self.selectedStock.ticker
                self.stockCurrentPriceLabel?.text = "$" + (self.selectedStock.price ?? "0.00")
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
    }
    
    
    
    override func loadView(){
        super.loadView()
        setUpUI()
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        navigationController?.delegate = self
        setData()
        lineChartView.delegate = self
        getSelectedStock(ticker: selectedStockTicker)
        getDailySelectedStock(ticker: selectedStockTicker)
    }
}
extension StockStatsViewController{
    fileprivate func setUpUI() {
        self.edgesForExtendedLayout = []//makes items which are put into the view appear under the navigation bar
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        //instantiation of ui elements
        let bottomBar = Bundle.main.loadNibNamed("BottomBar", owner: nil, options: nil)?.first as! BottomBar
        let stockScrollView = UIScrollView()
        let stockStatView = Bundle.main.loadNibNamed("StockStatView", owner: nil, options: nil)?.first as! StockStatView
        let stockCurrentPriceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/1.25, height: self.view.frame.height/12))
        
        let purchaseStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/7))
        let datedStockIntervalsStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/10))
        
        self.view.addSubview(bottomBar)
        self.view.addSubview(stockScrollView)
        
        //bottomBar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomBar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            bottomBar.heightAnchor.constraint(equalToConstant: self.view.frame.height/10.5),
            bottomBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        
        //stockScrollView
        stockScrollView.showsHorizontalScrollIndicator = false
        stockScrollView.translatesAutoresizingMaskIntoConstraints = false
        stockScrollView.backgroundColor = UIColor.clear
        NSLayoutConstraint.activate([
            stockScrollView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stockScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            stockScrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
        
        //adding UI elements to scrollview
        stockScrollView.addSubview(stockStatView)
        stockScrollView.addSubview(purchaseStackView)
        stockScrollView.addSubview(datedStockIntervalsStackView)
        stockScrollView.addSubview(lineChartView)
        stockScrollView.addSubview(stockCurrentPriceLabel)
        
        //stockStatView
        stockStatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stockStatView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stockStatView.heightAnchor.constraint(equalToConstant: self.view.frame.height/3),
        ])
        
        let buyButton = UIButton()
        let sellButton = UIButton()
        //buyButton
        buyButton.backgroundColor = .systemGreen
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.setTitle("Buy", for: .normal)
        buyButton.titleLabel?.font = UIFont(name: (buyButton.titleLabel?.font.fontName)!, size: 30)
        buyButton.clipsToBounds = true
        buyButton.layer.cornerRadius = 20
        buyButton.addTarget(self, action: #selector(buyButtonAction), for: .touchUpInside)
        //sellButton
        sellButton.backgroundColor = .systemRed
        sellButton.setTitleColor(.white, for: .normal)
        sellButton.titleLabel?.font = UIFont(name: (sellButton.titleLabel?.font.fontName)!, size: 30)
        sellButton.clipsToBounds = true
        sellButton.layer.cornerRadius = 20
        sellButton.addTarget(self, action: #selector(sellButtonAction), for: .touchUpInside)
        sellButton.setTitle("Sell", for: .normal)
        
        
        
        //purchaseStackView which contains buy and sell button
        purchaseStackView.translatesAutoresizingMaskIntoConstraints = false
        purchaseStackView.axis = .horizontal
        purchaseStackView.alignment = .center
        purchaseStackView.spacing = 40.0
        purchaseStackView.backgroundColor = .clear
        purchaseStackView.distribution = .fillEqually
        purchaseStackView.addArrangedSubview(buyButton)
        purchaseStackView.addArrangedSubview(sellButton)

        NSLayoutConstraint.activate([
            purchaseStackView.heightAnchor.constraint(equalToConstant: self.view.frame.height/7),
            purchaseStackView.widthAnchor.constraint(equalToConstant: self.view.frame.width/1.25),
            purchaseStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            purchaseStackView.bottomAnchor.constraint(equalTo: stockStatView.topAnchor),
        ])
        
//-----------------------------dated stock interval buttons-----------------------------
        let dailyStockButton = UIButton()
        let weeklyStockButton = UIButton()
        let monthlyStockButton = UIButton()
        let threeMonthlyStockButton = UIButton()
        let yearlyStockButton = UIButton()
        let fiveYearlyStockButton = UIButton()
        let twentyYearlyStockButton = UIButton()
    
        var stockIntervalButtons = [UIButton]()
        stockIntervalButtons.append(dailyStockButton)
        stockIntervalButtons.append(weeklyStockButton)
        stockIntervalButtons.append(monthlyStockButton)
        stockIntervalButtons.append(threeMonthlyStockButton)
        stockIntervalButtons.append(yearlyStockButton)
        stockIntervalButtons.append(fiveYearlyStockButton)
        stockIntervalButtons.append(twentyYearlyStockButton)
        
        let stockIntervalButtonTitles = ["1D", "1W","1M","3M","1Y","5Y","20Y"]

        //purchaseStackView which contains buy and sell button
        datedStockIntervalsStackView.translatesAutoresizingMaskIntoConstraints = false
        datedStockIntervalsStackView.axis = .horizontal
        datedStockIntervalsStackView.alignment = .center
        datedStockIntervalsStackView.spacing = 5.0
        datedStockIntervalsStackView.backgroundColor = .clear
        datedStockIntervalsStackView.distribution = .fillEqually
     
        for i in 0 ..< stockIntervalButtons.count{
            let button = stockIntervalButtons[i]
            let buttonTitle = stockIntervalButtonTitles[i]
            button.backgroundColor = .black
            button.setTitleColor(.green, for: .normal)
            button.titleLabel?.font = UIFont(name: (sellButton.titleLabel?.font.fontName)!, size: 20)
            button.addTarget(self, action: #selector(dateStockIntervalButtonAction), for: .touchUpInside)
            button.setTitle(buttonTitle, for: .normal)
            datedStockIntervalsStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            datedStockIntervalsStackView.heightAnchor.constraint(equalToConstant: self.view.frame.height/18),
            datedStockIntervalsStackView.widthAnchor.constraint(equalToConstant: self.view.frame.width/1.25),
            datedStockIntervalsStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            datedStockIntervalsStackView.bottomAnchor.constraint(equalTo: purchaseStackView.topAnchor),
        ])
        
//-----------------------------dated stock interval buttons-----------------------------

        
        //lineChartView
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.backgroundColor = UIColor.black
        NSLayoutConstraint.activate([
            lineChartView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            lineChartView.heightAnchor.constraint(equalToConstant: self.view.frame.height/2),
            lineChartView.bottomAnchor.constraint(equalTo: datedStockIntervalsStackView.topAnchor),
        ])
        
        //stockCurrentPriceLabel
        stockCurrentPriceLabel.textAlignment = .center
        stockCurrentPriceLabel.font = UIFont(name: stockCurrentPriceLabel.font.fontName, size: 35)
        stockCurrentPriceLabel.minimumScaleFactor = 0.5
        stockCurrentPriceLabel.adjustsFontSizeToFitWidth = true
        stockCurrentPriceLabel.backgroundColor = UIColor.clear
        stockCurrentPriceLabel.textColor = UIColor.white
        stockCurrentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        stockCurrentPriceLabel.text = ""
        
        stockCurrentPriceLabel.text = selectedStock.price!
        NSLayoutConstraint.activate([
            stockCurrentPriceLabel.bottomAnchor.constraint(equalTo: lineChartView.topAnchor),
            stockCurrentPriceLabel.topAnchor.constraint(equalTo: stockScrollView.topAnchor),
            stockCurrentPriceLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        //setting content size for stock scroll view by adding heights of all subviews
        var subViewsHeight = CGFloat(0)
        for views in stockScrollView.subviews{
            subViewsHeight += views.frame.height
        }
        stockScrollView.contentSize = CGSize(width: self.view.frame.width, height:subViewsHeight)
        
        //assigning UI elements to class variables
        self.stockCurrentPriceLabel = stockCurrentPriceLabel
        self.stockStatView = stockStatView
    }
}

//extension for any api calls needed for the view controller
extension StockStatsViewController{
    func getSelectedStock(ticker: String){
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
                self.selectedStock = stockData
            }catch{
                fatalError("Error in decoding JSON" + error.localizedDescription)

            }
            
        }//end of task
        task.resume()
    }//end of getStockData function
    
    //function calls daily stock get route which returns an array stock objects from the past n number of days
    func getDailySelectedStock(ticker: String){
        let urlString = constants.requestURL + "daily/" + ticker + "/" + "29200"
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
                let stockData = try decoder.decode([Stock].self, from: data!)
                self.selectedStockTotalDataArray = stockData
                self.selectedStockArray = Array(stockData[0...7])
            }catch{
                fatalError("Error in decoding JSON" + error.localizedDescription)
            }
            
        }//end of task
        task.resume()
    }//end of getStockData function
}


//extension for the chart cocoapod library calls that are needed for this view controller
extension StockStatsViewController: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let indexOfEntry = yValues.firstIndex(of: entry)
        //lineChartView.lineData?.entryForHighlight(highlight)
        let selectedPriceAtDate = (selectedStockArray[indexOfEntry!].price)
        selectedStockPrice = selectedPriceAtDate!
    }
    
    func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: "Stock Graph")
        set1.drawValuesEnabled = true
        set1.drawCirclesEnabled = false
        set1.setColor(.systemGreen)
        let lineChartData = LineChartData(dataSet: set1)
        lineChartView.data = lineChartData
    }
}

//extension to handle button actions
extension StockStatsViewController{
    @objc
    func buyButtonAction(sender: UIButton!){
        let purchaseViewController = PurchaseViewController()
        if let floatStockPrice = selectedStock.price{
            purchaseViewController.ticker = selectedStockTicker
            purchaseViewController.sharePrice = Float(floatStockPrice) ?? 0.00
            navigationController?.pushViewController(purchaseViewController, animated: true)
        }
    }
    
    
    @objc
    func dateStockIntervalButtonAction(sender: UIButton!){
        switch(sender.currentTitle){
        case "1D":
            self.selectedStockArray = Array(self.selectedStockTotalDataArray[0...1].reversed())
        case "1W":
            self.selectedStockArray = Array(self.selectedStockTotalDataArray[0...7].reversed())
        case "1M":
            self.selectedStockArray = Array(self.selectedStockTotalDataArray[0...30].reversed())
        case "3M":
            self.selectedStockArray = Array(self.selectedStockTotalDataArray[0...90].reversed())
        case "1Y":
            self.selectedStockArray = Array(self.selectedStockTotalDataArray[0...365].reversed())
        case "5Y":
            self.selectedStockArray = Array(self.selectedStockTotalDataArray[0...7200].reversed())
        case "20Y":
            self.selectedStockArray = Array(self.selectedStockTotalDataArray[0...29100].reversed())
        default:
            self.selectedStockArray = Array(self.selectedStockTotalDataArray[0...30].reversed())
        }
        
        if (sender.currentTitle == "3M"){
            self.selectedStockArray = Array(self.selectedStockTotalDataArray[0...90].reversed())
        }
    }
    
    @objc
    func sellButtonAction(sender: UIButton!){
        canUserSellStock(tickerSymbol: selectedStockTicker)
    }
    
}


//extension for display UI in response to a user action such as pressing the buy or sell button or displaying an error if they can't sell or buy a stock
extension StockStatsViewController{
    func showPurchaseScreen(){
        let purchaseViewController = PurchaseViewController()
        if let floatStockPrice = (selectedStock.price){
            purchaseViewController.ticker = selectedStockTicker
            purchaseViewController.sharePrice = Float(floatStockPrice) ?? 00
            purchaseViewController.isPurchaseStockState = false
            navigationController?.pushViewController(purchaseViewController, animated: true)
        }//optional bind of stockPrice
    }//end of function
    
    func canUserSellStock(tickerSymbol: String){
        var canSellStock = false
        let db = Firestore.firestore()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userDoc = db.collection("Users").document(appDelegate.email)
        userDoc.getDocument { (document, error) in
            if let error = error{
                print(error.localizedDescription)
                self.userStockAlertMessage(errorMessage: "Error: Account data retrieval failed")
                return
            }
            if let document = document{
               // let updatedUserBalance = userCurrentBalance - amountDueForPayment//
                guard let currentStocks = document.get("stocks") as? NSDictionary else {
                    print(error?.localizedDescription ?? "Could not get stocks as NSdictioanry")
                    self.userStockAlertMessage(errorMessage: "There was an error in retrieving the list of stocks you own")
                    return}
                for (tickerKey, stockObject) in currentStocks{
                    guard let tickerKey = tickerKey as? String else{return}
                    if tickerKey == tickerSymbol{
                        guard let previouslyPurchasedStock = stockObject as? NSDictionary else{
                            self.userStockAlertMessage(errorMessage: "There was an error in retrieving this stock's information from you transaction history")
                            return}

                        guard let currentNumOfStockOwned = previouslyPurchasedStock["quantity"] as? Float else{
                            self.userStockAlertMessage(errorMessage: "There was an error in retrieving the quantity of shares you own of this stock")
                            return}
                        //checks if user has enough stock to sell
                        if (currentNumOfStockOwned <= 0){
                            self.userStockAlertMessage(errorMessage: "You have no shares of this stock to sell")
                            return
                        }
                        canSellStock = true
                        self.showPurchaseScreen()
                        return
                    }
                }//for loop
                if canSellStock == false{
                    self.userStockAlertMessage(errorMessage: "You have no shares of this stock to sell")
                }
            }//optional bind of document
        }//end of closure
    }//end of function
    
    func userStockAlertMessage(errorMessage: String?){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        if let errorMessage = errorMessage{
            alert.title = "Error"
            alert.message = errorMessage
            alert.present(alert, animated: false, completion: nil)
        }
    }//end of function
    
}//end of view controller class
