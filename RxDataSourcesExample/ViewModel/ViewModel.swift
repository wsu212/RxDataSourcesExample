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
            configureCell: { _, table, idxPath, item in
                let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: idxPath)
                cell.textLabel?.text = "\(item)"
                return cell
            },
            titleForHeaderInSection: { ds, section -> String? in return ds[section].header },
            canEditRowAtIndexPath: { _, _ in return true },
            canMoveRowAtIndexPath: { _, _ in return true }
        )
    }
}
