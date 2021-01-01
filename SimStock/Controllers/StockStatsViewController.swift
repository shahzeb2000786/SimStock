//
//  StockStatsViewController.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/1/21.
//

import Foundation
import UIKit
class StockStatsViewController: UIViewController{
    
    override func loadView(){
        super.loadView()
        
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
        

        //assigning UI elements to class variables

        
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

    
    


