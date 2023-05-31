//
//  OperationsView.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 13/04/2023.
//

import Foundation
import RealmSwift

class OperationsView: Object, Codable {
    @objc dynamic var name: String = ""
    @objc dynamic var image: String = ""
}
