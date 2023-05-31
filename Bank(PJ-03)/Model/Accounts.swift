//
//  Accounts.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 17/04/2023.
//

import Foundation
import RealmSwift

class Accounts: Object, Codable {
    @objc dynamic var name: String = ""
    @objc dynamic var totalSum: Double = 0.00
}
