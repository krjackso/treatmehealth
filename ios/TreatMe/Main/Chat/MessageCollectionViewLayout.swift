//
//  MessageCollectionViewLayout.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/4/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit

protocol MessageCollectionViewDelegateLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
}

class MessageCollectionViewLayout: UICollectionViewFlowLayout {

    var layoutDelegate: MessageCollectionViewDelegateLayout? {
        get {
            if let collectionView = self.collectionView {
                return collectionView.delegate as? MessageCollectionViewDelegateLayout
            }
            return nil
        }
    }

    var contentSize: CGSize = CGSizeZero
    var attrCache: [UICollectionViewLayoutAttributes] = []

    let rowPadding: CGFloat = 0.0

    override init() {
        super.init()
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        self.scrollDirection = .Vertical
    }

    override func collectionViewContentSize() -> CGSize {
        return self.contentSize
    }

    override func prepareLayout() {
        guard let collectionView = self.collectionView, delegate = self.layoutDelegate else {
            return
        }

        attrCache.removeAll()

        let width = collectionView.bounds.width

        let height: CGFloat = (0..<collectionView.numberOfItemsInSection(0)).reduce(rowPadding) { (sofar, index) -> CGFloat in

            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            let cellHeight = delegate.collectionView(collectionView, heightForRowAtIndexPath: indexPath)

            let cellAttrs = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            cellAttrs.frame = CGRect(x: 0, y: sofar, width: width, height: cellHeight)
            cellAttrs.transform = collectionView.transform
            attrCache.append(cellAttrs)

            return sofar + cellHeight + rowPadding
        }

        self.contentSize = CGSize(width: width, height: height)
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrCache.filter({ $0.frame.intersects(rect) })
    }

}
