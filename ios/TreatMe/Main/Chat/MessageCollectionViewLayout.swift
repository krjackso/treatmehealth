//
//  MessageCollectionViewLayout.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/4/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit

protocol MessageCollectionViewDelegateLayout: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
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

    var contentSize: CGSize = CGSize.zero
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
        self.scrollDirection = .vertical
    }

    override var collectionViewContentSize : CGSize {
        return self.contentSize
    }

    override func prepare() {
        guard let collectionView = self.collectionView, let delegate = self.layoutDelegate else {
            return
        }

        attrCache.removeAll()

        let width = collectionView.bounds.width

        let height: CGFloat = (0..<collectionView.numberOfItems(inSection: 0)).reduce(rowPadding) { (sofar, index) -> CGFloat in

            let indexPath = IndexPath(item: index, section: 0)
            let cellHeight = delegate.collectionView(collectionView, heightForRowAtIndexPath: indexPath)

            let cellAttrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            cellAttrs.frame = CGRect(x: 0, y: sofar, width: width, height: cellHeight)
            cellAttrs.transform = collectionView.transform
            attrCache.append(cellAttrs)

            return sofar + cellHeight + rowPadding
        }

        self.contentSize = CGSize(width: width, height: height)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrCache.filter({ $0.frame.intersects(rect) })
    }

}
