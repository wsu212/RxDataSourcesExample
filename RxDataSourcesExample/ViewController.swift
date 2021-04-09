//
//  ViewController.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/9/21.
//

import UIKit

class ViewController: UIViewController {
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

