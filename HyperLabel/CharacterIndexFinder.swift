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

public final class CharacterIndexFinder {

    private let layoutManager: NSLayoutManager
    private let textContainer: NSTextContainer
    private let textStorage: NSTextStorage

    public init() {
        self.layoutManager = NSLayoutManager()
        self.textContainer = NSTextContainer()
        self.textStorage = NSTextStorage()

        self.layoutManager.addTextContainer(self.textContainer)
        self.textStorage.addLayoutManager(self.layoutManager)
    }

    public func update(textContainerData data: TextContainerData) {
        var attributedText = NSAttributedString()
        if let text = data.attributedText {
            attributedText = data.font.map(text.applying(defaultFont:)) ?? text
        }
        if data.numberOfLines != 1 && !data.lineBreakMode.isWrapping {
            attributedText = attributedText.resetLineBreakMode(.byWordWrapping)
        }
        self.textStorage.setAttributedString(attributedText)
        self.textContainer.lineFragmentPadding = 0
        self.textContainer.lineBreakMode = data.lineBreakMode
        self.textContainer.maximumNumberOfLines = data.numberOfLines
        self.textContainer.size = data.size
    }

    public func indexOfCharacter(atPoint point: CGPoint) -> String.Index? {
        guard self.textStorage.length > 0 else { return nil }
        let usedRect = self.layoutManager.usedRect(for: self.textContainer)
        guard usedRect.contains(point) else { return nil }
        let index = self.layoutManager.glyphIndex(for: point, in: self.textContainer)
        return String.Index(encodedOffset: index)
    }

    public func rect(forRange range: Range<String.Index>) -> CGRect {
        return self.layoutManager.boundingRect(forGlyphRange: NSRange(range, in: self.textStorage.string),
                                               in: self.textContainer)
    }
}

private extension NSLineBreakMode {
    var isWrapping: Bool {
        switch self {
        case .byCharWrapping, .byWordWrapping:
            return true
        default:
            return false
        }
    }
}

private extension NSAttributedString {

    func applying(defaultFont: UIFont) -> NSAttributedString {
        let copy = self.mutableCopy() as! NSMutableAttributedString
        let allStringRange = NSRange(location: 0, length: copy.length)

        var defaultFontAttributeRanges: [NSRange] = []
        copy.enumerateAttributes(in: allStringRange, options: []) { attrs, range, _ in
            if attrs[.font] == nil {
                defaultFontAttributeRanges.append(range)
            }
        }

        defaultFontAttributeRanges.forEach { range in
            copy.addAttribute(.font, value: defaultFont, range: range)
        }
        return copy.copy() as! NSAttributedString
    }

    func resetLineBreakMode(_ lineBreakMode: NSLineBreakMode) -> NSAttributedString {
        let mutable = self.mutableCopy() as! NSMutableAttributedString
        self.enumerateAttributes(in: NSRange(location: 0, length: self.length), options: []) { (attributes, range, _) in
            guard let paragraph = attributes[.paragraphStyle] as? NSParagraphStyle else { return }
            var mutableAttributes = attributes
            let mutableParagraph = paragraph.mutableCopy() as! NSMutableParagraphStyle
            mutableParagraph.lineBreakMode = lineBreakMode
            mutableAttributes[.paragraphStyle] = mutableParagraph.copy()
            mutable.setAttributes(mutableAttributes, range: range)
        }
        return mutable.copy() as! NSAttributedString
    }
}
