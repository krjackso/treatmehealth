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

enum ResponseError: ErrorType {
    // Status code errors
    case BadRequest
    case AuthenticationError
    case AuthorizationError
    case NotFound
    case Conflict
    case UnknownError(Int)

    // Errors reading response
    case InvalidResponse
    case MalformedJson
}

struct Response {
    let httpResponse: NSHTTPURLResponse
    let data: NSData?
}

extension NSHTTPURLResponse {
    func checkStatus() -> ResponseError? {
        guard (200..<400).contains(self.statusCode) else {
            switch self.statusCode {
            case 400: return .BadRequest
            case 401: return .AuthenticationError
            case 403: return .AuthorizationError
            case 404: return .NotFound
            case 409: return .Conflict
            default: return .UnknownError(self.statusCode)
            }
        }
        return nil
    }
}

extension Request {

    func response() -> Promise<Response> {
        return Promise { resolve, reject in
            self.response { req, res, data, err in
                guard err == nil else {
                    reject(err!)
                    return
                }

                guard let res = res, let data = data else {
                    reject(ResponseError.InvalidResponse)
                    return
                }

                if let error = res.checkStatus() {
                    debugPrint("Status check failed: \(error)")
                    reject(error)
                } else {
                    resolve(Response(httpResponse: res, data: data))
                }
            }
        }
    }

    func responseObject<T: Decodable>() -> Promise<(T, Response)> {
        return self.response().then { res -> (T, Response) in
            if let json = Request.JSONResponseSerializer().serializeResponse(self.request, res.httpResponse, res.data, nil).value {

                let t = try T.decode(json)
                return (t, res)
            } else {
                throw ResponseError.MalformedJson
            }
        }.onError { error in
            debugPrint("Error getting response: \(error)")
        }
    }

    func responseArray<T: Decodable>() -> Promise<([T], Response)> {
        return self.response().then { res -> ([T], Response) in
            if let json = Request.JSONResponseSerializer().serializeResponse(self.request, res.httpResponse, res.data, nil).value {

                let t: [T] = try [T].decode(json)
                return (t, res)
            } else {
                throw ResponseError.MalformedJson
            }

        }.onError { error in
            debugPrint("Error getting response: \(error)")
        }
    }

}
