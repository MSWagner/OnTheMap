//
//  APIClient.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 13.12.17.
//  Copyright © 2017 Michael Wagner. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result
import Reachability

class APIClient {

    static let shared: APIClient = APIClient()

    static let reachability: Reachability? = Reachability()

    static var session = URLSession.shared
    var accountKey: String?

    // MARK: - Request

    static func request<T: Decodable>(_ target: API, type: T.Type) -> SignalProducer<T, APIError> {
        return session.reactive
            .data(with: target.request)
            .retry(upTo: 2)
            .observe(on: QueueScheduler())
            .attemptMap { (data, response) -> T in

                do {
                    guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                        throw APIError.invalidURLResponse
                    }

                    // Security reasons from udacity
                    let range = Range(5..<data.count)
                    let newData = data.subdata(in: range)

                    let json = try JSONSerialization.jsonObject(with: newData) as? [String: Any]
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(Formatters.isoDateFormatter)

                    print(String(data: newData, encoding: .utf8)!)
                    print("JSON: \(json.debugDescription)")

                    if statusCode < 200 || statusCode >= 300 {
                        let decodedError = try decoder.decode(UdacityError.self, from: newData as Data)

                        throw APIError.udacityError(decodedError)
                    }

                    let decodedData = try decoder.decode(T.self, from: newData as Data)
                    return decodedData
                }
            }
            .mapError {
                if let apiError = $0.error as? APIError {
                    return apiError
                }

                return APIError.underlying($0)
            }
            .observe(on: UIScheduler())
    }
}

extension SignalProducerProtocol {
    func filterReachability(_ reachability: Reachability) throws -> SignalProducer<Self.Value, Self.Error> {
        if reachability.connection == .none {
            throw APIError.noConnection
        }
        return self.producer
    }
}
