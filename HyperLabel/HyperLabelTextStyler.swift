//
// The MIT License (MIT)
//
// Copyright (c) 2015-present Badoo Trading Limited.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public protocol AttributedTextContainer: class {
    var attributedText: NSAttributedString? { get }
    func updateAttributedText(_ text: NSAttributedString)
}

public final class HyperLabelTextStyler {
    public weak var container: AttributedTextContainer?
    public var linkAttributes: [NSAttributedString.Key: Any] = [:]

    public func applyLinkAttributes(atRange range: Range<String.Index>) {
        guard !self.linkAttributes.isEmpty,
            let container = self.container,
            let attributedString = container.attributedText else { return }

        let mutable = attributedString.mutableCopy() as! NSMutableAttributedString
        let text = mutable.string
        let range = NSRange(range, in: text)
        mutable.addAttributes(self.linkAttributes, range: range)
        container.updateAttributedText(mutable.copy() as! NSAttributedString)
    }
}
