//
//  DetailViewController.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 11/04/2023.
//

import UIKit
import RealmSwift

class DetailViewController: UITableViewController {
    
    let realm = try! Realm()
    let date = Date().formatted(date: .long, time: .omitted)
    
    @IBOutlet weak var cellFromChoose: UITableViewCell!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromImage: UIImageView!
    @IBOutlet weak var fromSumLabel: UILabel!
    
    @IBOutlet weak var cellFromPicker: UITableViewCell!
    @IBOutlet weak var fromPicker: UIPickerView!
    
    @IBOutlet weak var cellToChoose: UITableViewCell!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toImage: UIImageView!
    @IBOutlet weak var toSumLabel: UILabel!
    
    
    @IBOutlet weak var cellToPicker: UITableViewCell!
    @IBOutlet weak var toPicker: UIPickerView!
    
    @IBOutlet weak var sumTextField: UITextField!
    
    @IBOutlet weak var numberTextField: UITextField!
    
    @IBOutlet weak var payButton: UIButton!
    
    var isFromPickerVisible: Bool = false {
        didSet {
            fromPicker.isHidden = !isFromPickerVisible
        }
    }
    var isToPickerVisible: Bool = false {
        didSet {
            toPicker.isHidden = !isToPickerVisible
        }
    }
    let cellFromChooseIndexPath = IndexPath(row: 0, section: 0)
    let cellFromPickerIndexPath = IndexPath(row: 1, section: 0)
    
    let cellToChooseIndexPath = IndexPath(row: 0, section: 1)
    let cellToPickerIndexPath = IndexPath(row: 1, section: 1)
    
    static var operation: String = ""
    var fromTotalSum: Double = 0
    var toTotalSum: Double = 0
    var operationSum: Double = 0
    
    var accounts: Results<Accounts>!
    var model: Results<Operations>!
    var operationsModel: Results<OperationsView>!
    var operations: [String] = []
    var accountAndSum: [(account: String, sum: Double)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accounts = realm.objects(Accounts.self)
        model = realm.objects(Operations.self)
        operationsModel = realm.objects(OperationsView.self)
        
        filterOperations()
        
        title = DetailViewController.operation
        setButtonText()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backMainController))
        
        fromPicker.delegate = self
        fromPicker.dataSource = self
        fromPicker.tag = 0
        toPicker.delegate = self
        toPicker.dataSource = self
        toPicker.tag = 1
        
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
    }
    
    @objc func payButtonTapped() {
        switch DetailViewController.operation {
        case Settings.OperationsString.transfer.identifier:
            if checkAccount(labelText: fromLabel.text!) {
                if checkAccount(labelText: toLabel.text!) {
                    setSum()
                    if sumTextField.text != "" {
                        setSum()
                        if checkSum(totalSum: fromTotalSum, operationSum: operationSum) {
                            confirmAlert()
                        } else {
                            displayError(title: Settings.Errors.notEnoughFunds.identifier)
                        }
                    } else {
                        displayError(title: Settings.Errors.incorrectInput.identifier)
                    }
                } else {
                    displayError(title: Settings.Errors.chooseAccount.identifier)
                }
            } else {
                displayError(title: Settings.Errors.chooseAccount.identifier)
            }
        case Settings.OperationsString.withdrawal.identifier:
            if checkAccount(labelText: fromLabel.text!) {
                if sumTextField.text != "" {
                    setSum()
                    if checkSum(totalSum: fromTotalSum, operationSum: operationSum) {
                        confirmAlert()
                    } else {
                        displayError(title: Settings.Errors.notEnoughFunds.identifier)
                    }
                } else {
                    displayError(title: Settings.Errors.incorrectInput.identifier)
                }
            } else {
                displayError(title: Settings.Errors.chooseAccount.identifier)
            }
        case Settings.OperationsString.deposit.identifier:
            if checkAccount(labelText: toLabel.text!) {
                setSum()
                if sumTextField.text != "" {
                    confirmAlert()
                } else {
                    displayError(title: Settings.Errors.incorrectInput.identifier)
                }
            } else {
                displayError(title: Settings.Errors.chooseAccount.identifier)
            }
        case Settings.OperationsString.byPhoneNumber.identifier:
            if checkAccount(labelText: fromLabel.text!) {
                if sumTextField.text != "" {
                    setSum()
                    if checkSum(totalSum: fromTotalSum, operationSum: operationSum) {
                        if numberTextField.text != "" {
                            confirmAlert()
                        } else {
                            displayError(title: Settings.Errors.incorrectNumber.identifier)
                        }
                    } else {
                        displayError(title: Settings.Errors.notEnoughFunds.identifier)
                    }
                } else {
                    displayError(title: Settings.Errors.incorrectInput.identifier)
                }
            } else {
                displayError(title: Settings.Errors.chooseAccount.identifier)
            }
        default:
            break
        }
    }
    
    @objc func backMainController() {
        dismiss(animated: true)
    }
    
    func filterOperations() {
        operations = operationsModel.map({ operation in
            operation.name
        })
    }
    
    func confirmAlert() {
        let alert = UIAlertController(title: "Confirm the operation", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {_ in
            self.addNewOperation()
            self.backMainController()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addNewOperation() {
        switch DetailViewController.operation {
        case Settings.OperationsString.transfer.identifier:
            let fromNewOperation = Operations()
            let toNewOperation = Operations()
            
            newOperation(
                newOperation: fromNewOperation,
                operation: Settings.OperationsString.transfer.identifier,
                type: Settings.OperationType.minus.identifier,
                sum: sumTextField.text!,
                account: fromLabel.text!)
            
            newOperation(
                newOperation: toNewOperation,
                operation: Settings.OperationsString.deposit.identifier,
                type: Settings.OperationType.plus.identifier,
                sum: sumTextField.text!,
                account: toLabel.text!)
            
            saveModel(newOperation: fromNewOperation)
            saveModel(newOperation: toNewOperation)
            
            let fromNewSum = calculateNewSum(
                newOperation: fromNewOperation,
                totalSum: fromTotalSum,
                operationSum: operationSum)
            
            editModel(
                account: fromLabel.text!,
                newSum: fromNewSum)
            
            let toNewSum = calculateNewSum(
                newOperation: toNewOperation,
                totalSum: toTotalSum,
                operationSum: operationSum)
            
            editModel(
                account: toLabel.text!,
                newSum: toNewSum)
        case Settings.OperationsString.withdrawal.identifier:
            let fromNewOperation = Operations()
            
            newOperation(
                newOperation: fromNewOperation,
                operation: Settings.OperationsString.transfer.identifier,
                type: Settings.OperationType.minus.identifier,
                sum: sumTextField.text!,
                account: fromLabel.text!)
            
            saveModel(newOperation: fromNewOperation)
            
            let fromNewSum = calculateNewSum(
                newOperation: fromNewOperation,
                totalSum: fromTotalSum,
                operationSum: operationSum)
            
            editModel(
                account: fromLabel.text!,
                newSum: fromNewSum)
        case Settings.OperationsString.deposit.identifier:
            let toNewOperation = Operations()
            
            newOperation(
                newOperation: toNewOperation,
                operation: Settings.OperationsString.deposit.identifier,
                type: Settings.OperationType.plus.identifier,
                sum: sumTextField.text!,
                account: toLabel.text!)
            
            saveModel(newOperation: toNewOperation)
            
            let toNewSum = calculateNewSum(
                newOperation: toNewOperation,
                totalSum: toTotalSum,
                operationSum: operationSum)
            
            editModel(
                account: toLabel.text!,
                newSum: toNewSum)
        case Settings.OperationsString.byPhoneNumber.identifier:
            let fromNewOperation = Operations()
            
            newOperation(
                newOperation: fromNewOperation,
                operation: Settings.OperationsString.byPhoneNumber.identifier +
                " \(numberTextField.text ?? "")",
                type: Settings.OperationType.minus.identifier,
                sum: sumTextField.text!,
                account: fromLabel.text!)
            
            saveModel(newOperation: fromNewOperation)
            
            let fromNewSum = calculateNewSum(
                newOperation: fromNewOperation,
                totalSum: fromTotalSum,
                operationSum: operationSum)
            
            editModel(
                account: fromLabel.text!,
                newSum: fromNewSum)
        default:
            break
        }
    }
    
    func displayError(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setButtonText() {
        switch DetailViewController.operation {
        case Settings.OperationsString.transfer.identifier:
            payButton.setTitle(Settings.ButtonString.transfer.identifier, for: .normal)
        case Settings.OperationsString.withdrawal.identifier:
            payButton.setTitle(Settings.ButtonString.withdrawal.identifier, for: .normal)
        case Settings.OperationsString.deposit.identifier:
            payButton.setTitle(Settings.ButtonString.deposit.identifier, for: .normal)
        case Settings.OperationsString.byPhoneNumber.identifier:
            payButton.setTitle(Settings.ButtonString.pay.identifier, for: .normal)
        default:
            break
        }
    }
    
    func setSum() {
        operationSum = Double(sumTextField.text!) ?? 0
    }
    
    typealias NewSum = Double
    func calculateNewSum(newOperation: Operations, totalSum: Double, operationSum: Double) -> NewSum {
        switch newOperation.type {
        case Settings.OperationType.plus.identifier:
            let newSum = totalSum + operationSum
            return newSum
        case Settings.OperationType.minus.identifier:
            let newSum = totalSum - operationSum
            return newSum
        default:
            return 0
        }
    }
    
    func checkSum(totalSum: Double, operationSum: Double) -> Bool {
        totalSum >= operationSum
    }
    
    func checkAccount(labelText: String) -> Bool {
        labelText != "Choose account"
    }
    
    func newOperation(newOperation: Operations, operation: String, type: String, sum: String, account: String) {
        newOperation.date = date
        newOperation.operation = operation
        newOperation.type = type
        newOperation.sum = Double(sum) ?? 0
        newOperation.account = account
    }
    
    func saveModel(newOperation: Operations) {
        do {
            try realm.write{
                realm.add(newOperation)
            }
        } catch {
            MainViewController.shared.displayError(error, title: Settings.Errors.savingProblem.identifier)
        }
    }
    
    func editModel(account: String, newSum: Double) {
        let account = realm.objects(Accounts.self).filter("name = '\(account)'").first
        do {
            try realm.write{
                account?.totalSum = newSum
            }
        } catch {
            MainViewController.shared.displayError(error, title: Settings.Errors.savingProblem.identifier)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch DetailViewController.operation {
        case Settings.OperationsString.transfer.identifier:
            switch indexPath {
            case cellFromChooseIndexPath:
                return 40
            case cellFromPickerIndexPath where
                isFromPickerVisible == false:
                return 0
            case cellToChooseIndexPath:
                return 40
            case cellToPickerIndexPath where
                isToPickerVisible == false:
                return 0
            case IndexPath(row: 0, section: 2):
                return 40
            case IndexPath(row: 0, section: 3):
                return 0
            case IndexPath(row: 0, section: 4):
                return 40
            default:
                return UITableView.automaticDimension
            }
        case Settings.OperationsString.withdrawal.identifier:
            switch indexPath {
            case cellFromChooseIndexPath:
                return 40
            case cellFromPickerIndexPath where
                isFromPickerVisible == false:
                return 0
            case cellToChooseIndexPath:
                return 0
            case cellToPickerIndexPath:
                return 0
            case IndexPath(row: 0, section: 2):
                return 40
            case IndexPath(row: 0, section: 3):
                return 0
            case IndexPath(row: 0, section: 4):
                return 40
            default:
                return UITableView.automaticDimension
            }
        case Settings.OperationsString.deposit.identifier:
            switch indexPath {
            case cellFromChooseIndexPath:
                return 0
            case cellFromPickerIndexPath:
                return 0
            case cellToChooseIndexPath:
                return 40
            case cellToPickerIndexPath where
                isToPickerVisible == false:
                return 0
            case IndexPath(row: 0, section: 2):
                return 40
            case IndexPath(row: 0, section: 3):
                return 0
            case IndexPath(row: 0, section: 4):
                return 40
            default:
                return UITableView.automaticDimension
            }
        case Settings.OperationsString.byPhoneNumber.identifier:
            switch indexPath {
            case cellFromChooseIndexPath:
                return 40
            case cellFromPickerIndexPath where
                isFromPickerVisible == false:
                return 0
            case cellToChooseIndexPath:
                return 0
            case cellToPickerIndexPath:
                return 0
            case IndexPath(row: 0, section: 2):
                return 40
            case IndexPath(row: 0, section: 3):
                return 40
            case IndexPath(row: 0, section: 4):
                return 40
            default:
                return UITableView.automaticDimension
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch DetailViewController.operation {
        case Settings.OperationsString.transfer.identifier:
            switch indexPath {
            case cellFromChooseIndexPath:
                return 40
            case cellFromPickerIndexPath:
                return 100
            case cellToChooseIndexPath:
                return 40
            case cellToPickerIndexPath:
                return 100
            case IndexPath(row: 0, section: 2):
                return 40
            case IndexPath(row: 0, section: 3):
                return 0
            case IndexPath(row: 0, section: 4):
                return 40
            default:
                return UITableView.automaticDimension
            }
        case Settings.OperationsString.withdrawal.identifier:
            switch indexPath {
            case cellFromChooseIndexPath:
                return 40
            case cellFromPickerIndexPath:
                return 100
            case cellToChooseIndexPath:
                return 0
            case cellToPickerIndexPath:
                return 0
            case IndexPath(row: 0, section: 2):
                return 40
            case IndexPath(row: 0, section: 3):
                return 0
            case IndexPath(row: 0, section: 4):
                return 40
            default:
                return UITableView.automaticDimension
            }
        case Settings.OperationsString.deposit.identifier:
            switch indexPath {
            case cellFromChooseIndexPath:
                return 0
            case cellFromPickerIndexPath:
                return 0
            case cellToChooseIndexPath:
                return 40
            case cellToPickerIndexPath:
                return 100
            case IndexPath(row: 0, section: 2):
                return 40
            case IndexPath(row: 0, section: 3):
                return 0
            case IndexPath(row: 0, section: 4):
                return 40
            default:
                return UITableView.automaticDimension
            }
        case Settings.OperationsString.byPhoneNumber.identifier:
            switch indexPath {
            case cellFromChooseIndexPath:
                return 40
            case cellFromPickerIndexPath:
                return 100
            case cellToChooseIndexPath:
                return 0
            case cellToPickerIndexPath:
                return 0
            case IndexPath(row: 0, section: 2):
                return 40
            case IndexPath(row: 0, section: 3):
                return 40
            case IndexPath(row: 0, section: 4):
                return 40
            default:
                return UITableView.automaticDimension
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch DetailViewController.operation {
        case Settings.OperationsString.transfer.identifier:
            switch section {
            case 0:
                return 30
            case 1:
                return 30
            case 2:
                return 30
            case 3:
                return 0
            case 4:
                return 0
            default:
                return 0
            }
        case Settings.OperationsString.withdrawal.identifier:
            switch section {
            case 0:
                return 30
            case 1:
                return 0
            case 2:
                return 30
            case 3:
                return 0
            case 4:
                return 0
            default:
                return 0
            }
        case Settings.OperationsString.deposit.identifier:
            switch section {
            case 0:
                return 0
            case 1:
                return 30
            case 2:
                return 30
            case 3:
                return 0
            case 4:
                return 0
            default:
                return 0
            }
        case Settings.OperationsString.byPhoneNumber.identifier:
            switch section {
            case 0:
                return 30
            case 1:
                return 0
            case 2:
                return 30
            case 3:
                return 30
            case 4:
                return 0
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == cellFromChooseIndexPath {
            isFromPickerVisible.toggle()
            checkCellsImages()
            tableView.beginUpdates()
            tableView.endUpdates()
        } else if indexPath == cellToChooseIndexPath {
            isToPickerVisible.toggle()
            checkCellsImages()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func checkCellsImages() {
        if isFromPickerVisible == false {
            fromImage.image = UIImage(systemName: "chevron.down")
        } else if isFromPickerVisible == true {
            fromImage.image = UIImage(systemName: "chevron.up")
        } else if isToPickerVisible == false {
            toImage.image = UIImage(systemName: "chevron.down")
        } else if isToPickerVisible == true {
            toImage.image = UIImage(systemName: "chevron.up")
        }
    }
    
}

extension DetailViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return accounts.count
        case 1:
            return accounts.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 0:
            return accounts[row].name + " € \(accounts[row].totalSum)"
        case 1:
            return accounts[row].name + " € \(accounts[row].totalSum)"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            fromLabel.text = accounts[row].name
            fromSumLabel.text = "€ \(accounts[row].totalSum)"
            fromTotalSum = accounts[row].totalSum
        case 1:
            toLabel.text = accounts[row].name
            toSumLabel.text = "€ \(accounts[row].totalSum)"
            toTotalSum = accounts[row].totalSum
        default:
            break
        }
    }
    
}

extension DetailViewController: UIPickerViewDelegate {
    
}
