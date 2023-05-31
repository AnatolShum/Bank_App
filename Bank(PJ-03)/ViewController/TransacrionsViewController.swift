//
//  TransacrionsViewController.swift
//  Bank(PJ-03)
//
//  Created by Anatolii Shumov on 11/04/2023.
//

import UIKit
import RealmSwift

class TransacrionsViewController: UIViewController {
   
    let realm = try! Realm()
    
    var model: Results<Operations>!
    
    var account: String
    var filteredModel: Results<Operations>!
    
    var sortedModel: [(title: String, data: [Operations])] {
        let groupedData = Dictionary(grouping: filteredModel) { model in
            return model.date
        }
        let sectionData = groupedData.sorted(by: { $0.key > $1.key }).map { (key, value) in
            let date = key
            return (title: date, data: value)
        }
        return sectionData
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = realm.objects(Operations.self)
        filterModel()
    
        title = account
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    init?(coder: NSCoder, account: String) {
        self.account = account
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func filterModel() {
       filteredModel = model.where {
           $0.account == account
        }
    }

}

extension TransacrionsViewController: UITableViewDelegate {
    
}

extension TransacrionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedModel.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedModel[section].data.count
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
        label.text = sortedModel[section].title
        label.font = .boldSystemFont(ofSize: 16)
        
        headerView.addSubview(label)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsTableViewCell") as! TransactionsTableViewCell
        
        let item = sortedModel[indexPath.section].data[indexPath.row]
        cell.transactionOperationLabel.text = item.operation
        cell.transactionSumLabel.text = "\(item.type) \(item.sum)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
}
