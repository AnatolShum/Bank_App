//
//  Operations.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 11/04/2023.
//

import Foundation
import RealmSwift

class Operations: Object, Codable {
    @objc dynamic var date: String = ""
    @objc dynamic var operation: String = ""
    @objc dynamic var sum: Double = 0.00
    @objc dynamic var type: String = ""
    @objc dynamic var account: String = ""
}


