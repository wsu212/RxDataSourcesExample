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
    
    func execute(command: TableViewEditingCommand) -> TableViewState {
        switch command {
        case .append(let appendEvent):
            var sections = self.sections
            let items = sections[appendEvent.section].items + appendEvent.item
            sections[appendEvent.section] = Section(original: sections[appendEvent.section], items: items)
            return TableViewState(sections: sections)
        case .delete(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = Section(original: sections[indexPath.section], items: items)
            return TableViewState(sections: sections)
        case .move(let moveEvent):
            var sections = self.sections
            var sourceItems = sections[moveEvent.sourceIndex.section].items
            var destinationItems = sections[moveEvent.destinationIndex.section].items
            
            if moveEvent.sourceIndex.section == moveEvent.destinationIndex.section {
                destinationItems.insert(destinationItems.remove(at: moveEvent.sourceIndex.row),
                                        at: moveEvent.destinationIndex.row)
                let destinationSection = Section(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = destinationSection
                
                return TableViewState(sections: sections)
            } else {
                let item = sourceItems.remove(at: moveEvent.sourceIndex.row)
                destinationItems.insert(item, at: moveEvent.destinationIndex.row)
                let sourceSection = Section(original: sections[moveEvent.sourceIndex.section], items: sourceItems)
                let destinationSection = Section(original: sections[moveEvent.destinationIndex.section], items: destinationItems)
                sections[moveEvent.sourceIndex.section] = sourceSection
                sections[moveEvent.destinationIndex.section] = destinationSection
                
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
