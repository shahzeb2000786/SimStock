//
//  TableViewCell.swift
//  SimStock
//
//  Created by Shahzeb Ahmed on 12/26/20.
//

import UIKit

class StockInfoCell: UITableViewCell {

    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var stockValueLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var growthImageView: UIImageView!
    @IBOutlet weak var amountGrownLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
