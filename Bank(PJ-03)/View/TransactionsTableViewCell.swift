//
//  TransactionsTableViewCell.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 11/04/2023.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var transactionOperationLabel: UILabel!
    @IBOutlet weak var transactionSumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
