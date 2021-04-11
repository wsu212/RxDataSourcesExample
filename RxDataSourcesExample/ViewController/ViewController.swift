//
//  ViewController.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/9/21.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    // MARK: - UI Properties
    
    private let addButton = UIBarButtonItem()
    private let doneButton = UIBarButtonItem()
    private let tableView = UITableView()
    
    // MARK: = Non-UI Properties
    
    private let viewModel: ViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Initializer
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        
        doneButton
            .rx
            .tap
            .bind { [weak self] in self?.tableView.setEditing(false, animated: true) }
            .disposed(by: disposeBag)

        let initialState = TableViewState(
            sections: [
                Section(id: "0", items: [])
            ]
        )
                
        let addCommand = Observable.of(addButton
                                        .rx
                                        .tap
                                        .asObservable())
            .merge()
            .map(TableViewEditingCommand.addRandomItem)

        let deleteCommand = tableView
            .rx
            .itemDeleted
            .asObservable()
            .map(TableViewEditingCommand.delete)

        let movedCommand = tableView
            .rx
            .itemMoved
            .map(TableViewEditingCommand.move)

        let commands = Observable.of(
            addCommand,
            deleteCommand,
            movedCommand
        )
        .merge()
        
        let tableViewState = commands
            .scan(initialState) { state, command in state.execute(command: command) }
            .startWith(initialState)
        
        let sections = tableViewState
            .map(\.sections)
            .share(replay: 1)
        
        sections
            .bind(to: tableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setEditing(true, animated: true)
    }
    
    // MARK: - Private helper methods
    
    private func configureSubviews() {
        addButton.title = "Add"
        doneButton.title = "Done"
        self.navigationItem.leftBarButtonItem = addButton
        self.navigationItem.rightBarButtonItem = doneButton
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
}
