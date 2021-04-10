//
//  SectionOfCustomData.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/9/21.
//

import Foundation
import RxDataSources

struct SectionOfCustomData {
    typealias Item = CustomData
    var items: [Item]
}

extension SectionOfCustomData: SectionModelType {
    init(
        original: SectionOfCustomData,
        items: [CustomData]
    ) {
        self = original
        self.items = items
    }
}
