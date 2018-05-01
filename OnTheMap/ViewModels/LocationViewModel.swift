//
//  LocationViewModel.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 01.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation
import ReactiveSwift

class LocationViewModel {

    // MARK: - LocationViewModels

    private let _studentViewModels = MutableProperty<[StudentViewModel]>([])
    lazy var studentViewModels: Property<[StudentViewModel]> = {
        return Property(self._studentViewModels)
    }()

    // MARK: - Network Actions

    lazy var refreshStudentLocations: Action<Void, [StudentInformation], APIError> = {
        return Action { _ in

            APIClient
                .request(.getStudentLocations(limit: 100, skip: nil, order: nil), type: StudentInformations.self)
                .map { $0.results }
                .on(value: { [weak self] (studentInformations) in
                    self?._studentViewModels.value = studentInformations.map { StudentViewModel(model: $0)}
                })
        }
    }()
}
