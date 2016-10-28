//
//  UIImage.swift
//  TreatMe
//
//  Created by Keilan Jackson on 4/3/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeToWidth(_ width: CGFloat, toHeight height: CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: height)))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
