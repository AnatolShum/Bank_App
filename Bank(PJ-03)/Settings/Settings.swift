//
//  Settings.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 12/04/2023.
//

import Foundation
import UIKit

struct Settings {
    static var shared = Settings()
    
    enum Errors: String {
        case notEnoughFunds = "Not enough funds"
        case incorrectInput = "Enter amount"
        case incorrectNumber = "Enter phone number"
        case chooseAccount = "Choose account"
        case savingProblem = "Failed to save model data"
        case failedToFetchOperations = "Failed to fetch operations data"
        case failedToFetchModel = "Failed to fetch model data"
        
        var identifier: String {
            return rawValue
        }
    }
    
    enum AccountType: String, CaseIterable {
        case basic = "Card accounts"
        case saving = "Saving accounts"
        
        var identifier: String {
            return rawValue
        }
    }
    
    enum Targets: String {
        case personalAccount = "Personal account"
        case savingAccount = "Saving account"
        case userPhone = "Top up phone"
        case cash = "Cash"
        
        var identifier: String {
            return rawValue
        }
    }
    
    enum OperationType: String {
        case plus = "+"
        case minus = "-"
        
        var identifier: String {
            return rawValue
        }
    }
    
    enum OperationsString: String {
        case transfer = "Transfer"
        case withdrawal = "Withdrawal"
        case deposit = "Deposit"
        case byPhoneNumber = "By phone number"
        
        var identifier: String {
            return rawValue
        }
    }
    
    enum ButtonString: String {
        case transfer = "Transfer"
        case pay = "Pay"
        case deposit = "Deposit"
        case withdrawal = "Withdrawal"
        
        var identifier: String {
            return rawValue
        }
    }
    
}
