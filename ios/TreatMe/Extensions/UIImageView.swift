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

    func setImageWithUrlString(urlString: String) -> Promise<Void> {
        guard let url = NSURL(string: urlString) else {
            return Promise(error: NSURLError.BadURL)
        }

        let (promise, resolve, reject) = Promise<Void>.pendingPromise()
        self.kf_setImageWithURL(url, placeholderImage: self.image, optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in

            if let error = error {
                return reject(error)
            } else {
                return resolve()
            }
        }
        return promise
    }

    private func getAndSetUserImage(user: User) -> Promise<Void> {
        return TreatMe.client.getUserImage(user).then { imageSource -> Void in
            return self.setImageWithUrlString(imageSource)
        }.asVoid()
    }

    func setImageForUser(user: User) -> Promise<Void> {
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
            return Promise(error: TreatMeError.InvalidImage)
        }
    }
}
