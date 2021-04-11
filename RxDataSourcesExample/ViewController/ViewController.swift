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
    
    private let addButton = UIBarButtonItem()
    private let tableView = UITableView()
    
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

        let sections: [Section] = [Section(header: "Section 1", numbers: [], updated: Date()),
                                   Section(header: "Section 2", numbers: [], updated: Date()),
                                   Section(header: "Section 3", numbers: [], updated: Date())]

        let initialState = TableViewState(sections: sections)
        
        let add3ItemsAddStart = Observable.of((), (), ())
        let addCommand = Observable.of(addButton.rx.tap.asObservable(), add3ItemsAddStart)
            .merge()
            .map(TableViewEditingCommand.addRandomItem)

        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .map(TableViewEditingCommand.delete)

        let movedCommand = tableView.rx.itemMoved
            .map(TableViewEditingCommand.move)

        Observable.of(addCommand, deleteCommand, movedCommand)
            .merge()
            .scan(initialState) { (state: TableViewState, command: TableViewEditingCommand) -> TableViewState in
                return state.execute(command: command)
            }
            .startWith(initialState)
            .map {
                $0.sections
            }
            .share(replay: 1)
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
        self.navigationItem.rightBarButtonItem = addButton
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
