//
//  Promise.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/4/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation
import PromiseKit

extension Promise {

    func mapError(_ body: ((Error) -> Error)) -> Promise {
        if self.isRejected, let error = self.error {
            return Promise(error: body(error))
        } else {
            return self
        }
    }

    func onError(_ body: @escaping ((Error) -> Void)) -> Promise {
        self.catch(execute: body)
        return self
    }

}
