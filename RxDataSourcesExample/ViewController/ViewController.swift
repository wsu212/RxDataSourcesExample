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

// redux like editing example
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

        let initialState = SectionedTableViewState(sections: sections)
        let add3ItemsAddStart = Observable.of((), (), ())
        let addCommand = Observable.of(addButton.rx.tap.asObservable(), add3ItemsAddStart)
            .merge()
            .map(TableViewEditingCommand.addRandomItem)

        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .map(TableViewEditingCommand.DeleteItem)

        let movedCommand = tableView.rx.itemMoved
            .map(TableViewEditingCommand.MoveItem)

        Observable.of(addCommand, deleteCommand, movedCommand)
            .merge()
            .scan(initialState) { (state: SectionedTableViewState, command: TableViewEditingCommand) -> SectionedTableViewState in
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

enum TableViewEditingCommand {
    case AppendItem(item: IntItem, section: Int)
    case MoveItem(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case DeleteItem(IndexPath)
}

// This is the part

struct SectionedTableViewState {
    fileprivate var sections: [Section]
    
    init(sections: [Section]) {
        self.sections = sections
    }
    
    func execute(command: TableViewEditingCommand) -> SectionedTableViewState {
        switch command {
        case .AppendItem(let appendEvent):
            var sections = self.sections
            let items = sections[appendEvent.section].items + appendEvent.item
            sections[appendEvent.section] = Section(original: sections[appendEvent.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = Section(original: sections[indexPath.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .MoveItem(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destinationItems = sections[moveEvent.destinationIndex.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: moveEvent.sourceIndex.row),
                                        at: moveEvent.destinationIndex.row)
                let destinationSection = Section(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: moveEvent.sourceIndex.row)
                destinationItems.insert(item, at: moveEvent.destinationIndex.row)
                let sourceSection = Section(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destinationSection = Section(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = sourceSection
                sections[moveEvent.destinationIndex.section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            }
        }
    }
}

extension TableViewEditingCommand {
    static var nextNumber = 0
    static func addRandomItem() -> TableViewEditingCommand {
        let randSection = Int.random(in: 0...2)
        let number = nextNumber
        defer { nextNumber = nextNumber + 1 }
        let item = IntItem(number: number, date: Date())
        return TableViewEditingCommand.AppendItem(item: item, section: randSection)
    }
}

func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}
