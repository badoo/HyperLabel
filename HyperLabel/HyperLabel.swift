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
            self.gestureHandler.removeAllLinks()
        }
    }

    public override var attributedText: NSAttributedString? {
        didSet {
            self.gestureHandler.removeAllLinks()
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
        self.gestureHandler.addLink(addLinkWithRange: range,
                                    accessibilityIdentifier: accessibilityIdentifier,
                                    withHandler: handler)
        super.attributedText = self.attributedText.map {
            self.textStyler.applyLinkAttributes(for: $0, at: range)
        }
    }

    // UIAccessibilityContainer

    public override var accessibilityElements: [Any]? {
        get { return self.gestureHandler.accessibilityElements }
        set { fatalError("Setting accessibility elements is forbidden") }
    }
}

extension HyperLabel: TextContainerData {
    public var size: CGSize {
        return self.bounds.size
    }
}
