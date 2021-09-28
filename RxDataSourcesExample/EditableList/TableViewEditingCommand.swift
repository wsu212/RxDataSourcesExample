//
//  TableViewEditingCommand.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/10/21.
//

import Foundation

enum TableViewEditingCommand {
    case append(item: Model)
    case move(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case delete(indexPath: IndexPath)
}

extension TableViewEditingCommand {
    static var nextNumber = 0
    static func addRandomItem() -> TableViewEditingCommand {
        let number = nextNumber
        defer { nextNumber = nextNumber + 1 }
        let item = Model(id: number, title: "Model \(number)")
        return .append(item: item)
    }
}
