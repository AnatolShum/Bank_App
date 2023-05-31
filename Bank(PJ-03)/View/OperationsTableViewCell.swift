//
//  OperationsTableViewCell.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 13/04/2023.
//

import UIKit

class OperationsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var operationsLabel: UILabel!
    @IBOutlet weak var operationsImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
