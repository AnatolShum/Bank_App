//
//  MainViewController.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 11/04/2023.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
   static let shared = MainViewController()
   
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    static var isPresenting = false
    
    var accounts: Results<Accounts>!
    var operationsModel: Results<Operations>!
    var operationsView = [OperationsView]()
    
    let barButtonItem = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Products"
        
        if !UserDefaults.standard.bool(forKey: "testData") {
            
        Network.shared.fetchModel { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    self.displayError(error, title: Settings.Errors.failedToFetchModel.identifier)
                }
            }
       
        Task.init{
                do {
                    operationsView = try await Network.shared.fetchOperations()
                    try realm.write {
                        realm.add(operationsView)
                    }
                   
                } catch {
                    displayError(error, title: Settings.Errors.failedToFetchOperations.identifier)
                }
            }

            UserDefaults.standard.set(true, forKey: "testData")
        }
        
        tableView.dataSource = self
        tableView.delegate = self
       
        accounts = realm.objects(Accounts.self)
        operationsModel = realm.objects(Operations.self)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(showOperations))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc func showOperations() {
        MainViewController.isPresenting.toggle()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "OperationsTableViewController")
        viewController.isModalInPresentation = true
        
        let navigation = UINavigationController(rootViewController: viewController)

        if let presentationController = navigation.sheetPresentationController {
            presentationController.detents = [.medium()]
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            presentationController.largestUndimmedDetentIdentifier = .medium
            presentationController.preferredCornerRadius = 30
        }
    
        if MainViewController.isPresenting {
            present(navigation, animated: true, completion: nil)
        } else {
            dismiss(animated: true)
        }
    }
    
    func displayError(_ error: Error, title: String) {
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

   
    @IBSegueAction func showTransactions(_ coder: NSCoder, sender: Any?) -> TransacrionsViewController? {
        guard let cell = sender as? MainTableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return nil }
        var account: String?
        switch indexPath.section {
        case 0:
            let personal = accounts.where {
                $0.name == Settings.Targets.personalAccount.identifier
            }
            let item = personal[indexPath.row]
            account = item.name
        case 1:
            let saving = accounts.where {
                $0.name == Settings.Targets.savingAccount.identifier
            }
            let item = saving[indexPath.row]
            account = item.name
        default:
            break
        }

        return TransacrionsViewController(coder: coder, account: account!)
    }
    
}

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = Settings.AccountType.allCases.count
        return count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: tableView.frame.size.width,
            height: 30))
        headerView.backgroundColor = .systemGray6
        
        let label = UILabel()
        label.frame = CGRect(
            x: 5,
            y: 5,
            width: headerView.frame.size.width-10,
            height: headerView.frame.size.height-10)
        label.font = .boldSystemFont(ofSize: 16)
        
        switch section {
                case 0:
            label.text = Settings.AccountType.basic.identifier
                case 1:
            label.text = Settings.AccountType.saving.identifier
                default:
                    return nil
                }
        
        headerView.addSubview(label)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            let personal = accounts.where { $0.name == Settings.Targets.personalAccount.identifier }
            return personal.count
        case 1:
            let saving = accounts.where { $0.name == Settings.Targets.savingAccount.identifier }
            return saving.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell") as! MainTableViewCell
        
        switch indexPath.section {
        case 0:
            let personal = accounts.where {
                $0.name == Settings.Targets.personalAccount.identifier
            }
            let item = personal[indexPath.row]
            cell.accountNameLabel.text = item.name
            cell.totalSumLabel.text = "€ \(item.totalSum)"
        case 1:
            let saving = accounts.where {
                $0.name == Settings.Targets.savingAccount.identifier
            }
            let item = saving[indexPath.row]
            cell.accountNameLabel.text = item.name
            cell.totalSumLabel.text = "€ \(item.totalSum)"
        default:
            return cell
        }
        
       return cell
    }
    
}

extension MainViewController: UITableViewDelegate {
    
}
