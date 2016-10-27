// Inspired by https://gist.github.com/mikeMTOL/79fe0bb97d08bc9a5d0bf7fa1458f6fe

import UIKit

class UIPaddedLabel: UILabel {
    var contentInset:UIEdgeInsets = UIEdgeInsetsZero {
        didSet {
            setNeedsDisplay()
        }
    }

    convenience init(insets: UIEdgeInsets = UIEdgeInsetsZero, text: String? = nil) {
        self.init(frame:CGRectZero)
        contentInset = insets
        self.text = text
    }

    override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()
        return CGSize(width: size.width + contentInset.left + contentInset.right, height: size.height + contentInset.top + contentInset.bottom)
    }

    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, contentInset))
    }
}