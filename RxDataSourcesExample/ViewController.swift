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
class EditingExampleViewController: UIViewController {
    
    private let addButton = UIBarButtonItem()
    private let tableView = UITableView()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        let dataSource = EditingExampleViewController.dataSource()

        let sections: [SectionOfCustomData] = [SectionOfCustomData(header: "Section 1", numbers: [], updated: Date()),
                                               SectionOfCustomData(header: "Section 2", numbers: [], updated: Date()),
                                               SectionOfCustomData(header: "Section 3", numbers: [], updated: Date())]

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
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setEditing(true, animated: true)
    }
}

extension EditingExampleViewController {
    static func dataSource() -> RxTableViewSectionedAnimatedDataSource<SectionOfCustomData> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { _, table, idxPath, item in
                let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: idxPath)
                cell.textLabel?.text = "\(item)"
                return cell
            },
            titleForHeaderInSection: { ds, section -> String? in
                return ds[section].header
            },
            canEditRowAtIndexPath: { _, _ in
                return true
            },
            canMoveRowAtIndexPath: { _, _ in
                return true
            }
        )
    }
}

enum TableViewEditingCommand {
    case AppendItem(item: IntItem, section: Int)
    case MoveItem(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case DeleteItem(IndexPath)
}

// This is the part

struct SectionedTableViewState {
    fileprivate var sections: [SectionOfCustomData]
    
    init(sections: [SectionOfCustomData]) {
        self.sections = sections
    }
    
    func execute(command: TableViewEditingCommand) -> SectionedTableViewState {
        switch command {
        case .AppendItem(let appendEvent):
            var sections = self.sections
            let items = sections[appendEvent.section].items + appendEvent.item
            sections[appendEvent.section] = SectionOfCustomData(original: sections[appendEvent.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = SectionOfCustomData(original: sections[indexPath.section], items: items)
            return SectionedTableViewState(sections: sections)
        case .MoveItem(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destinationItems = sections[moveEvent.destinationIndex.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: moveEvent.sourceIndex.row),
                                        at: moveEvent.destinationIndex.row)
                let destinationSection = SectionOfCustomData(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = destinationSection
                
                return SectionedTableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: moveEvent.sourceIndex.row)
                destinationItems.insert(item, at: moveEvent.destinationIndex.row)
                let sourceSection = SectionOfCustomData(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destinationSection = SectionOfCustomData(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
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
