//
//  LocationViewModel.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 01.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation
import ReactiveSwift
import CoreLocation

class LocationViewModel {

    // MARK: - Properties

    lazy var geocoder = CLGeocoder()

    private var ownStudentInformation: StudentInformation?

    var ownStudentViewModel: StudentViewModel? {
        if let ownStudentInformation = ownStudentInformation {
            return StudentViewModel(model: ownStudentInformation)
        }
        return nil
    }

    // MARK: - LocationViewModels

    private let _studentViewModels = MutableProperty<[StudentViewModel]>([])
    lazy var studentViewModels: Property<[StudentViewModel]> = {
        return Property(self._studentViewModels)
    }()

    // MARK: - Location Actions

    typealias ShouldStartNew = Bool
    lazy var refreshStudentLocations: Action<ShouldStartNew, [StudentInformation], APIError> = {

        return Action { shouldStartNew in

            let skip: Int? = shouldStartNew ? nil : self._studentViewModels.value.count

            return APIClient
                .request(.getStudentLocations(limit: 100, skip: skip, order: nil), type: StudentInformations.self)
                .map { $0.results }
                .on(value: { [weak self] (studentInformations) in
                    guard let `self` = self else { return }

                    let newStudentInformations = studentInformations
                        .map { StudentViewModel(model: $0)}

                    self._studentViewModels.value = shouldStartNew
                                                  ? newStudentInformations
                                                  : self._studentViewModels.value + newStudentInformations
                })
        }
    }()

    lazy var getOwnStudentLocation: Action<UniqueKey, StudentInformation?, APIError> = {

        return Action { uniqueKey in
            APIClient
                .request(.getStudentLocation(uniqueKey: uniqueKey), type: StudentInformations.self)
                .map { $0.results.last }
        }
    }()

    lazy var uploadNewStudentLocation: Action<Void, Void, APIError> = {

        return Action { [weak self] studentInformation in

            guard let ownStudentInformation = self?.ownStudentInformation else {
                return SignalProducer(error: APIError.noStudentInformation)
            }

            let apiTarget: API = ownStudentInformation.objectId != nil
                         ? .putStudentLocation(location: ownStudentInformation,
                                               objectID: ownStudentInformation.objectId!)
                         : .postStudentLocation(location: ownStudentInformation)

            return APIClient
                .request(apiTarget, type: StudentInformation.self)
                .map { _ in return () }
        }
    }()

    // MARK: - Geocode Action

    typealias Address = String
    typealias UserURL = String?
    lazy var geocodeAddress: Action<(Address, UserURL), StudentInformation, GeoCodeError> = {

        return Action { (address, userURL) in

            return SignalProducer<(GeoCodeResult, User), GeoCodeError> { [weak self] (sink, _) in

                self?.geocoder.geocodeAddressString(address) { (placeMarks, error) in

                    if let error = error {
                        let geoCodeError = GeoCodeError.underlying(error)
                        sink.send(error: geoCodeError)

                    } else if let placeMarks = placeMarks, placeMarks.count > 0 {

                        /// Get First PlaceMark with a coordinate
                        let firstPlaceMarkWithCoordinate = placeMarks
                            .filter { $0.location?.coordinate != nil }
                            .first

                        if let firstPlaceMarkWithCoordinate = firstPlaceMarkWithCoordinate {

                            /// Create MapString
                            var mapString = firstPlaceMarkWithCoordinate.locality ?? ""

                            mapString += firstPlaceMarkWithCoordinate.country != nil
                                      ? ", \(firstPlaceMarkWithCoordinate.country!)"
                                      : ""

                            /// Create GeoCodeResult
                            let geoCodeResult = GeoCodeResult(coordinate: firstPlaceMarkWithCoordinate.location!.coordinate, mapString: mapString)

                            /// Get Current User for Network Request
                            guard let user = UserController.currentUser,
                                let publicData = user.publicData else {

                                let geoCodeError = GeoCodeError.missingUserData
                                sink.send(error: geoCodeError)
                                return
                            }

                            /// Send result and completed
                            sink.send(value: (geoCodeResult, user))
                            sink.sendCompleted()

                        } else {
                            let geoCodeError = GeoCodeError.noValuesIncluded
                            sink.send(error: geoCodeError)
                        }
                    } else {
                        let geoCodeError = GeoCodeError.noValuesIncluded
                        sink.send(error: geoCodeError)
                    }
                }
            }
            .flatMap(.latest) { (geoCodeResult, user) -> SignalProducer<StudentInformation, GeoCodeError> in

                return APIClient
                    .request(.getStudentLocation(uniqueKey: user.account.key), type: StudentInformations.self)
                    .map { [weak self] value in

                        if var studentInformation = value.results.last {
                            studentInformation.latitude = geoCodeResult.coordinate.latitude
                            studentInformation.longitude = geoCodeResult.coordinate.longitude
                            studentInformation.mapString = geoCodeResult.mapString
                            studentInformation.mediaURL = userURL

                            self?.ownStudentInformation = studentInformation
                            return studentInformation
                        } else {
                            let newStudentInformation = StudentInformation(objectId: nil,
                                               uniqueKey: user.account.key,
                                               firstName: user.publicData?.first_name ?? "",
                                               lastName: user.publicData?.last_name ?? "",
                                               mapString: geoCodeResult.mapString,
                                               mediaURL: userURL,
                                               latitude: geoCodeResult.coordinate.latitude,
                                               longitude: geoCodeResult.coordinate.longitude,
                                               createdAt: nil,
                                               updatedAt: nil)

                            self?.ownStudentInformation = newStudentInformation
                            return newStudentInformation
                        }

                    }
                    .mapError { GeoCodeError.underlying($0) }
            }
        }
    }()
}
