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
                    print(entry)
                    self.yValues.append(entry)
                    increment += 1
                }
                self.setData()
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
        self.edgesForExtendedLayout = []//makes items which are put into the view appear under the navigation bar
        //instantiation of ui elements
        self.view.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        //self.navigationItem?.
        let bottomBar = Bundle.main.loadNibNamed("BottomBar", owner: nil, options: nil)?.first as! BottomBar
        let stockScrollView = UIScrollView()
        
        let contentView = UIView()
        let stockStatView = Bundle.main.loadNibNamed("StockStatView", owner: nil, options: nil)?.first as! StockStatView
        let stockCurrentPriceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/1.25, height: self.view.frame.height/12))
        contentView.addSubview(stockCurrentPriceLabel)
        contentView.addSubview(lineChartView)
        contentView.addSubview(stockStatView)
        //adding ui elements to main view
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
        stockScrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            stockScrollView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stockScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            stockScrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
        
       
//        stockScrollView.addSubview(stockStatView)
//        stockScrollView.addSubview(lineChartView)
//        stockScrollView.addSubview(stockCurrentPriceLabel)

        //stockStatView
        stockStatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stockStatView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            stockStatView.heightAnchor.constraint(equalToConstant: self.view.frame.height/3),
        ])

        //lineChartView
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.backgroundColor = UIColor.black
        NSLayoutConstraint.activate([
            lineChartView.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            lineChartView.heightAnchor.constraint(equalToConstant: self.view.frame.height/2),
            lineChartView.bottomAnchor.constraint(equalTo: stockStatView.topAnchor),
        ])
        
        //stockCurrentPriceLabel
        stockCurrentPriceLabel.textAlignment = .center
        stockCurrentPriceLabel.font = UIFont(name: stockCurrentPriceLabel.font.fontName, size: 50)
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
        
        var subViewsHeight = CGFloat(0)
        for views in contentView.subviews{
            print(views.frame.height)
            subViewsHeight += views.frame.height
        }
        print(stockCurrentPriceLabel.frame.height)
        print(subViewsHeight)
        print (self.view.frame.height)
        stockScrollView.contentSize = CGSize(width: self.view.frame.width, height:subViewsHeight)

        //assigning UI elements to class variables
        self.stockCurrentPriceLabel = stockCurrentPriceLabel
        self.stockStatView = stockStatView
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
        //print(selectedStockArray[indexOfEntry!].date)
    }
    func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: "Stock Graph")
        set1.drawCirclesEnabled = false
        let lineChartData = LineChartData(dataSet: set1)
        lineChartView.data = lineChartData
    }
    
    
}
