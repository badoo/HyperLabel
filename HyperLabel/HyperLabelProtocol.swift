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

public protocol HyperLabelProtocol: AnyObject {
    var extendsLinkTouchArea: Bool { get set }
    var additionalLinkAttributes: [NSAttributedString.Key: Any] { get set }
    func addLink(withRange range: NSRange,
                 accessibilityIdentifier: String?,
                 handler: @escaping () -> Void)
}

extension HyperLabelProtocol {
    public func addLink(withRange range: NSRange, handler: @escaping () -> Void) {
        self.addLink(withRange: range, accessibilityIdentifier: nil, handler: handler)
    }
}

private var presenterAssociatedKey = 0

extension HyperLabelProtocol where Self: HLHyperLabel {

    private typealias Presenter = HyperLabelPresenter<Self>

    private var presenter: Presenter? {
        get { return objc_getAssociatedObject(self, &presenterAssociatedKey) as? Presenter }
        set { objc_setAssociatedObject(self, &presenterAssociatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    public var extendsLinkTouchArea: Bool {
        get {
            guard let presenter = self.presenter else {
                assertionFailure("Call `initializeHyperLabel` before accessing extendsLinkTouchArea")
                return false
            }
            return presenter.extendsLinkTouchArea
        }
        set {
            guard let presenter = self.presenter else {
                assertionFailure("Call `initializeHyperLabel` before setting extendsLinkTouchArea")
                return
            }
            presenter.extendsLinkTouchArea = newValue
        }
    }

    public var additionalLinkAttributes: [NSAttributedString.Key: Any] {
        get {
            guard let presenter = self.presenter else {
                assertionFailure("Call `initializeHyperLabel` before accessing additionalLinkAttributes")
                return [:]
            }
            return presenter.additionalLinkAttributes
        }
        set {
            guard let presenter = self.presenter else {
                assertionFailure("Call `initializeHyperLabel` before setting additionalLinkAttributes")
                return
            }
            presenter.additionalLinkAttributes = newValue
        }
    }

    public func addLink(withRange range: NSRange,
                        accessibilityIdentifier: String?,
                        handler: @escaping () -> Void) {
        guard let presenter = self.presenter else {
            assertionFailure("Call `initializeHyperLabel` before calling addLink")
            return
        }
        presenter.addLink(addLinkWithRange: range,
                          accessibilityIdentifier: accessibilityIdentifier,
                          withHandler: handler)
    }

    public func initializeHyperLabel() {
        guard self.presenter == nil else {
            assertionFailure("You should call `initializeHyperLabel` only once")
            return
        }
        self.setupForHyperLabel()
        let presenter = Presenter()
        presenter.textView = self
        let gestureRecognizer = UITapGestureRecognizer(target: presenter,
                                                       action: #selector(Presenter.handleTapGesture))
        self.addGestureRecognizer(gestureRecognizer)
        self.presenter = presenter
    }
}

private extension HLHyperLabel {
    func setupForHyperLabel() {
        self.isAccessibilityElement = false
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = false
    }
}
