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

import UIKit

public final class HyperLabel: UILabel {

    // MARK: - Private properties

    private let gestureHandler = HyperLabelGestureHandler()
    private var textStyler = HyperLabelTextStyler()

    // MARK: - Instantiation

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.isAccessibilityElement = false
        self.gestureHandler.textView = self
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = false
        let gestureRecognizer = UITapGestureRecognizer(target: self.gestureHandler,
                                                       action: #selector(HyperLabelGestureHandler.handleTapGesture))
        self.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: - UILabel

    public override var text: String? {
        didSet {
            self.removeLinks()
        }
    }

    public override var attributedText: NSAttributedString? {
        didSet {
            self.removeLinks()
        }
    }

    // MARK: - Public API

    public var extendsLinkTouchArea: Bool {
        get { return self.gestureHandler.extendsLinkTouchArea }
        set { self.gestureHandler.extendsLinkTouchArea = newValue }
    }

    public var additionalLinkAttributes: [NSAttributedString.Key: Any] {
        get { return self.textStyler.linkAttributes }
        set { self.textStyler.linkAttributes = newValue }
    }

    public func addLink(withRange range: Range<String.Index>, handler: @escaping () -> Void) {
        self.addLink(withRange: range, accessibilityIdentifier: nil, handler: handler)
    }

    public func addLink(withRange range: Range<String.Index>,
                        accessibilityIdentifier: String?,
                        handler: @escaping () -> Void) {
        self.gestureHandler.addLink(addLinkWithRange: range, withHandler: handler)
        super.attributedText = self.attributedText.map {
            self.textStyler.applyLinkAttributes(for: $0, at: range)
        }
        if let accessibilityIdentifier = accessibilityIdentifier {
            let element = LinkAccessibilityElement(accessibilityContainer: self,
                                                   range: range,
                                                   identfier: accessibilityIdentifier)
            self.linkAccessibilityElements.append(element)
        }
    }

    // MARK: - Private methods

    private func removeLinks() {
        self.gestureHandler.removeAllLinks()
        self.linkAccessibilityElements.removeAll()
    }

    // MARK: - UIAccessibilityContainer

    private lazy var accessibilityElement: UIAccessibilityElement = {
        let element = UIAccessibilityElement(accessibilityContainer: self)
        element.accessibilityTraits = UIAccessibilityTraits.staticText
        return element
    }()

    private var linkAccessibilityElements: [LinkAccessibilityElement] = []

    public override func accessibilityElementCount() -> Int {
        return self.linkAccessibilityElements.count + 1
    }

    public override func accessibilityElement(at index: Int) -> Any? {
        if index < self.linkAccessibilityElements.count && index >= 0 {
            let element = self.linkAccessibilityElements[index]
            let frame = self.gestureHandler.rect(forRange: element.range)
            element.accessibilityFrameInContainerSpace = frame
            return element
        }

        let element = self.accessibilityElement
        element.accessibilityFrameInContainerSpace = self.bounds
        element.accessibilityIdentifier = self.accessibilityIdentifier
        element.accessibilityValue = self.text

        return element
    }

    public override func index(ofAccessibilityElement element: Any) -> Int {
        guard let accessibilityElement = element as? UIAccessibilityElement else { return NSNotFound }
        guard let index = self.linkAccessibilityElements.index(where: { accessibilityElement.accessibilityIdentifier == $0.accessibilityIdentifier }) else {
            return self.linkAccessibilityElements.count + 1
        }
        return index
    }
}

extension HyperLabel: TextContainerData {
    public var size: CGSize {
        return self.bounds.size
    }
}
