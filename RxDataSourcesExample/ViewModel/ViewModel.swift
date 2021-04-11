//
//  ViewModel.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/10/21.
//

import Foundation
import RxSwift
import RxDataSources

struct ViewModel {
    let dataSource: AnimatedDataSource
    
    // MARK: - Outputs
    let sections: Observable<[Section]>
    
    init(
        initialState: TableViewState,
        addCommand: Observable<TableViewEditingCommand>,
        deleteCommand: Observable<TableViewEditingCommand>,
        movedCommand: Observable<TableViewEditingCommand>
        )
    {
        dataSource = AnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { _, table, indexPath, item in
                let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = item.title
                return cell
            },
            canEditRowAtIndexPath: { _, _ in return true },
            canMoveRowAtIndexPath: { _, _ in return true }
        )
        
        let commands = Observable.of(
            addCommand,
            deleteCommand,
            movedCommand
        )
        .merge()
        
        let tableViewState = commands
            .scan(initialState) { state, command in state.execute(command: command) }
            .startWith(initialState)
        
        sections = tableViewState
            .map(\.sections)
            .share(replay: 1)
    }
}
