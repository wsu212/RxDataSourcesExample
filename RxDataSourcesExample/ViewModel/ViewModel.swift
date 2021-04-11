//
//  ViewModel.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/10/21.
//

import Foundation
import RxDataSources

struct ViewModel {
    let dataSource: AnimatedDataSource
    
    init() {
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
    }
}
