//
//  TableViewEditingCommand.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/10/21.
//

import Foundation

enum TableViewEditingCommand {
    case append(item: IntItem, section: Int)
    case move(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case delete(IndexPath)
}

extension TableViewEditingCommand {
    static var nextNumber = 0
    static func addRandomItem() -> TableViewEditingCommand {
        let randSection = Int.random(in: 0...2)
        let number = nextNumber
        defer { nextNumber = nextNumber + 1 }
        let item = IntItem(number: number, date: Date())
        return .append(item: item, section: randSection)
    }
}
