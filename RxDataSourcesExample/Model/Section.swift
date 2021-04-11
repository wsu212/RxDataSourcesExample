//
//  SectionOfCustomData.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/9/21.
//

import Foundation
import RxDataSources

struct Section {
    var header: String
    var numbers: [IntItem]
    var updated: Date

    init(header: String, numbers: [Item], updated: Date) {
        self.header = header
        self.numbers = numbers
        self.updated = updated
    }
}

struct IntItem {
    let number: Int
    let date: Date
}

// MARK: Just extensions to say how to determine identity and how to determine is entity updated

extension Section: AnimatableSectionModelType {
    typealias Item = IntItem
    typealias Identity = String

    var identity: String {
        return header
    }

    var items: [IntItem] {
        return numbers
    }

    init(original: Section, items: [Item]) {
        self = original
        self.numbers = items
    }
}

extension IntItem: IdentifiableType , Equatable {
    typealias Identity = Int

    var identity: Int {
        return number
    }
}
