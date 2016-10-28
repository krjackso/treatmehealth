// Inspired by https://gist.github.com/mikeMTOL/79fe0bb97d08bc9a5d0bf7fa1458f6fe

import UIKit

class UIPaddedLabel: UILabel {
    var contentInset:UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsDisplay()
        }
    }

    convenience init(insets: UIEdgeInsets = UIEdgeInsets.zero, text: String? = nil) {
        self.init(frame:CGRect.zero)
        contentInset = insets
        self.text = text
    }

    override var intrinsicContentSize : CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + contentInset.left + contentInset.right, height: size.height + contentInset.top + contentInset.bottom)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, contentInset))
    }
}
