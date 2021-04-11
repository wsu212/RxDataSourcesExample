//
//  AnimatedDataSource.swift
//  RxDataSourcesExample
//
//  Created by Wei-Lun Su on 4/10/21.
//

import Foundation
import RxDataSources

final class AnimatedDataSource: RxTableViewSectionedAnimatedDataSource<Section> {
    override init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideViewTransition: @escaping RxTableViewSectionedAnimatedDataSource<Section>.DecideViewTransition = { _, _, _ in .animated },
        configureCell: @escaping RxTableViewSectionedAnimatedDataSource<Section>.ConfigureCell,
        titleForHeaderInSection: @escaping RxTableViewSectionedAnimatedDataSource<Section>.TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping RxTableViewSectionedAnimatedDataSource<Section>.TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping RxTableViewSectionedAnimatedDataSource<Section>.CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping RxTableViewSectionedAnimatedDataSource<Section>.CanMoveRowAtIndexPath = { _, _ in false },
        sectionIndexTitles: @escaping RxTableViewSectionedAnimatedDataSource<Section>.SectionIndexTitles = { _ in nil },
        sectionForSectionIndexTitle: @escaping RxTableViewSectionedAnimatedDataSource<Section>.SectionForSectionIndexTitle = { _, _, index in index }
    ) {
        super.init(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: configureCell,
            titleForHeaderInSection: titleForHeaderInSection,
            canEditRowAtIndexPath: canEditRowAtIndexPath,
            canMoveRowAtIndexPath: canMoveRowAtIndexPath
        )
    }
}
