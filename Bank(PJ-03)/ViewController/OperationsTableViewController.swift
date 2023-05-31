//
//  OperationsTableViewController.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 11/04/2023.
//

import UIKit
import RealmSwift

class OperationsTableViewController: UITableViewController {
    let realm = try! Realm()
    var operations: Results<OperationsView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        operations = realm.objects(OperationsView.self)
        tableView.reloadData()
        title = "Operations"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OperationsTableViewCell") as! OperationsTableViewCell
        let operation = operations[indexPath.row]
        cell.operationsLabel.text = operation.name
        cell.operationsImage.image = UIImage(systemName: operation.image)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let operation = operations[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController")
        let navigation = UINavigationController(rootViewController: viewController)
        navigation.modalPresentationStyle = .fullScreen
        
        DetailViewController.operation = operation.name
        MainViewController.isPresenting.toggle()
        
        dismissAndPresent(navigation, animated: true, completion: nil)
    }

    func dismissAndPresent(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        guard let presentingViewController = presentingViewController else { return }
            dismiss(animated: animated) {
                presentingViewController.present(viewController, animated: animated, completion: completion)
            }
    }

}
