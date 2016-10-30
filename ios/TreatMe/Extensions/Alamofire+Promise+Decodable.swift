//
//  Alamofire+Promise.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/29/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Decodable

enum ResponseError: Error {
    // Status code errors
    case badRequest
    case authenticationError
    case authorizationError
    case notFound
    case conflict
    case unknownError(Int)

    // Errors reading response
    case invalidResponse
    case malformedJson
}

struct Response {
    let httpResponse: HTTPURLResponse
    let data: Data?
}

struct ErrorResponse: Error {
    let error: ResponseError
    let text: String?
}

extension DefaultDataResponse {
    func checkStatus() -> ResponseError? {
        if let status = self.response?.statusCode {
            guard (200..<400).contains(status) else {
                switch status {
                case 400: return .badRequest
                case 401: return .authenticationError
                case 403: return .authorizationError
                case 404: return .notFound
                case 409: return .conflict
                default: return .unknownError(status)
                }
            }
        }
        return nil
    }
}

extension DataRequest {
    func response() -> Promise<Response> {
        return Promise { resolve, reject in
            self.response { res in
                guard res.error == nil else {
                    reject(res.error!)
                    return
                }

                guard let response = res.response, let data = res.data else {
                    reject(ResponseError.invalidResponse)
                    return
                }

                if let error = res.checkStatus() {
                    let text = String(data: data, encoding: String.Encoding.utf8)
                    reject(ErrorResponse(error: error, text: text))
                } else {
                    resolve(Response(httpResponse: response, data: data))
                }
            }
        }
    }

    func responseObject<T: Decodable>() -> Promise<(T, Response)> {
        return self.response().then { res -> (T, Response) in
            if let json = DataRequest.jsonResponseSerializer().serializeResponse(self.request, res.httpResponse, res.data, nil).value {

                let t = try T.decode(json)
                return (t, res)
            } else {
                throw ResponseError.malformedJson
            }
        }.onError { error in
            debugPrint("Error getting response: \(error)")
        }
    }

    func responseArray<T: Decodable>() -> Promise<([T], Response)> {
        return self.response().then { res -> ([T], Response) in
            if let json = DataRequest.jsonResponseSerializer().serializeResponse(self.request, res.httpResponse, res.data, nil).value {

                let t: [T] = try [T].decode(json)
                return (t, res)
            } else {
                throw ResponseError.malformedJson
            }

        }.onError { error in
            debugPrint("Error getting response: \(error)")
        }
    }

}
