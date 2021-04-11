//
//  Model.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/9/21.
//

import Foundation
import RxDataSources

struct Model {
    let id: Int
    let title: String
}

extension Model: IdentifiableType, Equatable {
    var identity: Int { return id }
}
