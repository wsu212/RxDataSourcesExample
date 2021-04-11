//
//  SectionOfCustomData.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/9/21.
//

import Foundation
import RxDataSources

struct Section {
    var id: String
    var items: [Model]

    init(id: String, items: [Model]) {
        self.id = id
        self.items = items
    }
}

extension Section: AnimatableSectionModelType {
    var identity: String { return id }

    init(original: Section, items: [Model]) {
        self = original
        self.items = items
    }
}
