//
//  StockStatsViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/1/21.
//
import Foundation
import UIKit
import Charts
class StockStatsViewController: UIViewController, UINavigationControllerDelegate{
    
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
   
    var yValues: [ChartDataEntry] = []
    var selectedStockTicker: String = "WMT" //{
    var selectedStockArray: [Stock] = []{
        willSet{
            yValues = []
            DispatchQueue.main.async{
                var increment = 0.0
                for stock in self.selectedStockArray{
                    let entry = ChartDataEntry(x: increment, y: Double(stock.price!) ?? 0.0)
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
        let buyButton = UIButton()
        let sellButton = UIButton()
        
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
        stockScrollView.addSubview(lineChartView)
        stockScrollView.addSubview(stockCurrentPriceLabel)
        
        //stockStatView
        stockStatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stockStatView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stockStatView.heightAnchor.constraint(equalToConstant: self.view.frame.height/3),
        ])
        
        //buyButton
        buyButton.backgroundColor = .systemGreen
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.setTitle("Buy", for: .normal)
        buyButton.titleLabel?.font = UIFont(name: (buyButton.titleLabel?.font.fontName)!, size: 30)
        buyButton.clipsToBounds = true
        buyButton.layer.cornerRadius = 20
        buyButton.addTarget(self, action: #selector(buyButtonAction), for: .touchUpInside)
        NSLayoutConstraint.activate([
            buyButton.heightAnchor.constraint(equalToConstant: purchaseStackView.frame.height/2.5),
        ])
        //sellButton
        sellButton.backgroundColor = .systemRed
        sellButton.setTitleColor(.white, for: .normal)
        sellButton.titleLabel?.font = UIFont(name: (sellButton.titleLabel?.font.fontName)!, size: 30)
        sellButton.clipsToBounds = true
        sellButton.layer.cornerRadius = 20
        NSLayoutConstraint.activate([
            sellButton.heightAnchor.constraint(equalToConstant: purchaseStackView.frame.height/2.5),
        ])
        sellButton.setTitle("Sell", for: .normal)
        
        
        //purchaseStackView
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
        //lineChartView
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.backgroundColor = UIColor.black
        NSLayoutConstraint.activate([
            lineChartView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            lineChartView.heightAnchor.constraint(equalToConstant: self.view.frame.height/2),
            lineChartView.bottomAnchor.constraint(equalTo: purchaseStackView.topAnchor),
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
                self.selectedStockArray = stockData
            }catch{
                print ("Error in decoding JSON" + error.localizedDescription)
            }
            
        }//end of task
        task.resume()
    }//end of getStockData function
}

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
        purchaseViewController.ticker = selectedStockTicker
        if let floatStockPrice = selectedStock.price{
            purchaseViewController.sharePrice = Float(floatStockPrice) ?? 0.00
            navigationController?.pushViewController(purchaseViewController, animated: true)

        }
    }
}
