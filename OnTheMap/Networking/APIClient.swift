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

typealias RequestResponse = (Data, URLResponse)
class APIClient {

    static let shared: APIClient = APIClient()

    static let reachability: Reachability? = Reachability()

    static var session = URLSession.shared
    var accountKey: String?

    // MARK: - Request

    static func request(_ target: API) -> SignalProducer<RequestResponse, APIError> {

        return proveReachability(reachability: reachability)
            .flatMap(.latest) { _ -> SignalProducer<RequestResponse, APIError> in

                return session.reactive
                    .data(with: target.request)
                    .retry(upTo: 2)
//                    .observe(on: QueueScheduler())
//                    .map { _ in () }
                    .mapError { $0.toAPIError() }
                    .observe(on: UIScheduler())
        }
    }

    static func request<T: Decodable>(_ target: API, type: T.Type) -> SignalProducer<T, APIError> {

        return proveReachability(reachability: reachability)
            .flatMap(.latest) { _ -> SignalProducer<T, APIError> in

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
                            var tempData = data
                            if target.shouldSkipFirst5Chars {
                                let range = Range(5..<data.count)
                                tempData = data.subdata(in: range)
                            }

                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .formatted(Formatters.isoDateFormatter)

                            if statusCode < 200 || statusCode >= 300 {
                                let decodedError = try decoder.decode(UdacityError.self, from: tempData as Data)

                                throw APIError.udacityError(decodedError)
                            }

                            let decodedData = try decoder.decode(T.self, from: tempData as Data)
                            return decodedData
                        }
                    }
                    .mapError { $0.toAPIError() }
                    .observe(on: UIScheduler())
            }
    }

    static func proveReachability(reachability: Reachability?) -> SignalProducer<Void, APIError> {
        return SignalProducer<Void, APIError> { (sink, _) in
            if let reachability = reachability,
                reachability.connection == .cellular || reachability.connection == .wifi {
                sink.send(value: ())
                sink.sendCompleted()
            } else {
                sink.send(error: APIError.noConnection)
            }
        }
    }
}
