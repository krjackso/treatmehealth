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

    func mapError(body: (ErrorType -> ErrorType)) -> Promise {
        if self.rejected, let error = self.error {
            return Promise(error: body(error))
        } else {
            return self
        }
    }

    func onError(body: (ErrorType -> Void)) -> Promise {
        self.error(body)
        return self
    }

}
