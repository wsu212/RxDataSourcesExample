//
//  ViewController.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/9/21.
//

import UIKit
import RxSwift
import RxDataSources

class ViewController: UIViewController {
    private let tableView = UITableView()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        configureDataSource()
    }
    
    private func setupSubviews() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureDataSource() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Item \(item.id): \(item.title)"
            return cell
        }
        canEditRowAtIndexPath: { _, _ in return true }
        canMoveRowAtIndexPath: { _, _ in return true }
        
        let sections = [
          SectionOfCustomData(items: [CustomData(id: "0",
                                                 title: "First Item"),
                                      CustomData(id: "1",
                                                 title: "Second Item"),
                                      CustomData(id: "2",
                                                 title: "Third Item")])
        ]
        
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

