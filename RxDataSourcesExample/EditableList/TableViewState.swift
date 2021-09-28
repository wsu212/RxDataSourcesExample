//
//  TableViewState.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/10/21.
//

import Foundation

struct TableViewState {
    var sections: [Section]
    
    init(sections: [Section]) {
        self.sections = sections
    }
    
    /// Generate TableViewState based on given TableViewEditingCommand
    func execute(command: TableViewEditingCommand) -> TableViewState {
        switch command {
        case let .append(item):
            let section = 0
            var sections = self.sections
            let items = sections[section].items + item
            
            sections[section] = Section(
                original: sections[section],
                items: items
            )
            return TableViewState(sections: sections)
            
        case let .delete(indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            
            sections[indexPath.section] = Section(
                original: sections[indexPath.section],
                items: items
            )
            return TableViewState(sections: sections)
            
        case let .move(sourceIndex, destinationIndex):
            var sections = self.sections
            var sourceItems = sections[sourceIndex.section].items
            var destinationItems = sections[destinationIndex.section].items
            
            if sourceIndex.section == destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: sourceIndex.row),
                                        at: destinationIndex.row)
                let destinationSection = Section(
                    original: sections[destinationIndex.section],
                    items: destinationItems
                )
                sections[sourceIndex.section] = destinationSection
                
                return TableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: sourceIndex.row)
                destinationItems.insert(item, at: destinationIndex.row)
                let sourceSection = Section(
                    original: sections[sourceIndex.section],
                    items: sourceItems
                )
                let destinationSection = Section(
                    original: sections[destinationIndex.section],
                    items: destinationItems
                )
                sections[sourceIndex.section] = sourceSection
                sections[destinationIndex.section] = destinationSection
                
                return TableViewState(sections: sections)
            }
        }
    }
}

func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}
