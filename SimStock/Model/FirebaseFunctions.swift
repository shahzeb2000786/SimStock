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
                    }//end of if statement
                }//end of for loop
                let stockToAdd = ["ticker": tickerSymbol, "quantity": quantity, "totalAmountPaid": amountDueForPayment] as [String : Any]
                userDoc.updateData(["stocks." + tickerSymbol : stockToAdd, "currentBalance": updatedUserBalance])
            }//optional bind of document
            print("successfully added stock")
        }//end of closure
        
    }//end of addStockToUser function
    
    func sellUserStock(tickerSymbol: String, quantity: Float, stockPrice: Float){
        let userDoc = db.collection("Users").document(appDelegate.email)
        let stockSellAmount = quantity * stockPrice
        userDoc.getDocument { (document, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let document = document{
                guard var userCurrentBalance = document.get("currentBalance") as? Float else{return}
               // let updatedUserBalance = userCurrentBalance - amountDueForPayment//
                guard let currentStocks = document.get("stocks") as? NSDictionary else {
                    print(error?.localizedDescription ?? "Could not get stocks as NSdictioanry")
                    return}
                print("made it past guards")
                for (tickerKey, stockObject) in currentStocks{
                    guard let tickerKey = tickerKey as? String else{return}
                    if tickerKey == tickerSymbol{
                        print("There wa a hit")
                        guard let previouslyPurchasedStock = stockObject as? NSDictionary else{ return}

                        guard let currentNumOfStockOwned = previouslyPurchasedStock["quantity"] as? Float else{return}
                        print("break point")
                        //checks if user tried to purhase more stock than they owned
                        if (currentNumOfStockOwned < quantity){
                            return
                        }
                        userCurrentBalance += stockSellAmount
                        let updatedQuantity = currentNumOfStockOwned - quantity
                        let updatedSoldStock = ["ticker": tickerSymbol, "quantity": updatedQuantity, "totalAmountPaid": userCurrentBalance] as [String : Any]
                        userDoc.updateData(["stocks." + tickerSymbol : updatedSoldStock, "currentBalance": userCurrentBalance])
                    }
                }//for loop
            }//optional bind of document
            print("successfully deleted stock")
        }//end of closure
    }//end of function
    

    
    
    
    
    func setUserBalanceLabel(labelToUpdate: UILabel){
        let userDoc = db.collection("Users").document(appDelegate.email)
        userDoc.getDocument { (document, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            if let document = document{
                guard var userCurrentBalance = document.get("currentBalance") as? Float else{return}
                print(userCurrentBalance)
                DispatchQueue.main.async{
                    labelToUpdate.text = String(userCurrentBalance)
                    return
                }//DispatchQueue
            }//optional bind of document
        }//getDocument
        DispatchQueue.main.async{
            labelToUpdate.text = "-"
        }
    }//getUserbalance
    
    
    
    
    
    
    
    
    
    mutating func getUsersStock(tickerArrayToSet: [Stock]){
        let userDoc = db.collection("Users").document(appDelegate.email)
        var arrayOfStocks = tickerArrayToSet
        arrayOfStocks.removeAll()
        
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
             //   tickerArrayToSet = arrayOfStocks
            }//optional bind of document
        }//getDocument closure
        
    }//end of function
    
}
