//
//  UIImageView.swift
//  TreatMe
//
//  Created by Keilan Jackson on 4/19/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import PromiseKit
import Kingfisher

extension UIImageView {

    func setImageWithUrlString(_ urlString: String) -> Promise<Void> {
        let url = URL(string: urlString)

        let (promise, resolve, reject) = Promise<Void>.pending()
        self.kf.setImage(with: url, placeholder: self.image, options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in

            if let error = error {
                return reject(error)
            } else {
                return resolve()
            }
        }
        return promise
    }

    fileprivate func getAndSetUserImage(_ user: User) -> Promise<Void> {
        return TreatMe.client.getUserImage(user).then { imageSource -> Void in
            return self.setImageWithUrlString(imageSource)
        }.asVoid()
    }

    func setImageForUser(_ user: User) -> Promise<Void> {
        if let _ = user.imageHref {
            if let imageSource = TreatMe.data.userImages[user] {
                return imageSource.then { imageSource -> Void in
                    return self.setImageWithUrlString(imageSource).onError { _ in
                        return self.getAndSetUserImage(user)
                    }
                }
            } else {
                return self.getAndSetUserImage(user)
            }
        } else {
            return Promise(error: TreatMeError.invalidImage)
        }
    }
}
