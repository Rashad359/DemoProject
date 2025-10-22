//
//  DetailsBuilder.swift
//  DemoProject
//
//  Created by Rəşad Əliyev on 10/21/25.
//

import UIKit

final class DetailsBuilder {
    
    let detailsData: DetailsData
    
    init(detailsData: DetailsData) {
        self.detailsData = detailsData
    }
    
    func build(completion: (() -> ())?) -> UIViewController {
        let viewModel = DetailsViewModel()
        let detailsVC = DetailsViewController(viewModel: viewModel, detailsData: detailsData)
        detailsVC.didBookmark = completion
        return detailsVC
    }
}
