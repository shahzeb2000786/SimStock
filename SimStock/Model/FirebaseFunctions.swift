//
//  FirebaseFunctions.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/18/21.
//

import Foundation
import Firebase

struct FirebaseFunctions{
    private let db = Firestore.firestore()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func addStockToUser(tickerSymbol: String, quantity: Float, stockPrice: Float) {
        print("function started")
        let userDoc = db.collection("Users").document(appDelegate.email)
        userDoc.getDocument { (document, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }//optional bind of error
            if let document = document{
                guard var userCurrentBalance = document.get("currentBalance") as? Float else{return}
                let amountDueForPayment = quantity * stockPrice
                let updatedUserBalance = userCurrentBalance - amountDueForPayment

                guard let currentStocks = document.get("stocks") as? NSDictionary else {
                    print(error?.localizedDescription)
                    return}
                for (tickerKey, stockObject) in currentStocks{
                    guard let tickerKey = tickerKey as? String else{return}
                    print (tickerKey == tickerSymbol)
                    if  tickerKey == tickerSymbol{
                        guard let stockObject = stockObject as? NSDictionary else{
                            print("Could not convert stock object")
                            return}
                        guard let previouslyPurchasedStock = stockObject as? NSDictionary else{ return}
                        guard var totalSpentOnStock = previouslyPurchasedStock["totalAmountPaid"] as? Float else{return}
                        guard var currentNumOfStockOwned = previouslyPurchasedStock["quantity"] as? Float else{return}
                        totalSpentOnStock += amountDueForPayment
                        currentNumOfStockOwned += quantity
                        print(currentNumOfStockOwned)
                        let stockToAdd = ["ticker": tickerSymbol, "quantity": currentNumOfStockOwned, "totalAmountPaid": totalSpentOnStock] as [String : Any]
                        userDoc.updateData(["stocks." + tickerSymbol : stockToAdd, "currentBalance": updatedUserBalance])
                        return
                    }
                }
                let stockToAdd = ["ticker": tickerSymbol, "quantity": quantity, "totalAmountPaid": amountDueForPayment] as [String : Any]
                userDoc.updateData(["stocks." + tickerSymbol : stockToAdd, "currentBalance": updatedUserBalance])
            }//optional bind of document
            print("successfully added stock")
        }//end of closure
        
    }//end of addStockToUser function
    
    func addPreviouslyPurchasedStock(){
        
    }
    
}
