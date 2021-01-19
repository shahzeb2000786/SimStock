//
//  FirebaseFunctions.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 1/18/21.
//

import Foundation
import Firebase

struct FirebaseFunctions{
    let db = Firestore.firestore()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func addStockToUser(tickerSymbol: String, quantity: Float, stockPrice: Float) {
        let userDoc = db.collection("Users").document(appDelegate.email)
        userDoc.getDocument { (document, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            }//optional bind of error
            if let document = document{
                guard let currentStocks = document.get("stocks") as? [NSDictionary] else {return}
                for stock in currentStocks{
                    if stock["ticker"] as! String == tickerSymbol{
                        return
                    }
                }
                let userCurrentBalance = document.get("currentBalance") as! Float
                let totalAmountPaid = quantity * stockPrice
                let updatedUserBalance = userCurrentBalance - totalAmountPaid
                let quantity = String(quantity)
                let stockToAdd = ["ticker": tickerSymbol, "quantity": quantity, "totalAmountPaid": totalAmountPaid] as [String : Any]
                userDoc.updateData(["stocks" : FieldValue.arrayUnion([stockToAdd]), "currentBalance": updatedUserBalance])
            }//optional bind of document
            print("successfully added stock")
        }//end of closure
        
    }//end of addStockToUser function
}
