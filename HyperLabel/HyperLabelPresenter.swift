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

final class HyperLabelPresenter<TextView: UIView> where TextView: TextContainerData {

    // MARK: - Type declarations

    private final class LinkItem {
        let handler: Handler
        let accessibilityElement: LinkAccessibilityElement?

        init(handler: @escaping Handler,
             accessibilityElement: LinkAccessibilityElement?) {
            self.handler = handler
            self.accessibilityElement = accessibilityElement
        }
    }

    typealias Handler = () -> Void

    // MARK: - Private properties

    private var linkRegistry = RangeMap<LinkItem>()
    private let layoutInfoProvider = TextLayoutInfoProvider()
    private var textStyler = HyperLabelTextStyler()

    private var shouldReactToTextChange = true

    // MARK: - Instantiation

    init() {}

    // MARK: - API

    var extendsLinkTouchArea: Bool = true

    weak var textView: TextView? {
        didSet {
            self.observerTextViewChanges()
        }
    }

    var additionalLinkAttributes: [NSAttributedString.Key: Any] {
        get { return self.textStyler.linkAttributes }
        set { self.textStyler.linkAttributes = newValue }
    }

    func addLink(addLinkWithRange range: NSRange,
                 accessibilityIdentifier: String?,
                 withHandler handler: @escaping Handler) {
        guard let textView = self.textView else {
            assertionFailure("textView is nil")
            return
        }
        guard let attributedText = textView.attributedText else { return }
        let accessibilityElement = accessibilityIdentifier.flatMap {
            self.makeAccessibilityElement(range: range, accessibilityIdentifier: $0)
        }
        let item = LinkItem(handler: handler, accessibilityElement: accessibilityElement)
        self.linkRegistry.setValue(value: item, forRange: range)
        let updatedAttributedText = self.textStyler.applyLinkAttributes(for: attributedText,
                                                                        at: range)
        self.updateTextWithoutObserving(attributedText: updatedAttributedText)
        self.reloadAccessibilityElements()
    }

    @objc
    func handleTapGesture(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        guard let view = self.textView else {
            assertionFailure("textView is nil")
            return
        }
        let point = sender.location(in: view)
        self.layoutInfoProvider.update(textContainerData: view)
        let handlerProvider = self.extendsLinkTouchArea ? self.handler(nearPoint:) : self.handler(atPoint:)
        guard let handler = handlerProvider(point) else { return }
        handler()
    }

    // MARK: - Private methods

    private func updateTextWithoutObserving(attributedText: NSAttributedString) {
        self.shouldReactToTextChange = false
        defer { self.shouldReactToTextChange = true }
        self.textView?.attributedText = attributedText
    }

    private func didChangeText() {
        guard self.shouldReactToTextChange else { return }
        self.linkRegistry.clear()
        self.reloadAccessibilityElements()
    }

    private var textViewObservers: [NSKeyValueObservation] = []
    private func observerTextViewChanges() {
        guard var textView = self.textView else {
            self.textViewObservers.removeAll()
            return
        }
        textView.onTextDidChange = { [weak self] change in
            guard let self = self, change.oldValue != change.newValue else { return }
            self.didChangeText()
        }
        textView.onAttributedTextChange = { [weak self] change in
            guard let self = self, change.oldValue != change.newValue else { return }
            self.didChangeText()
        }
        self.textViewObservers = [
            textView.observe(\.bounds, options: [.new, .old, .initial]) { [weak self] _, change in
                guard let self = self, change.oldValue != change.newValue else { return }
                self.reloadAccessibilityElements()
            },
            textView.observe(\.frame, options: [.new, .old]) { [weak self] _, change in
                guard let self = self, change.oldValue != change.newValue else { return }
                self.reloadAccessibilityElements()
            },
        ]
    }

    private func makeAccessibilityElements() -> [UIAccessibilityElement] {
        var result: [UIAccessibilityElement] = []
        if let textView = self.textView, let container = self.containerAccessibilityElement {
            container.accessibilityFrameInContainerSpace = textView.bounds
            container.accessibilityValue = textView.attributedText?.string
            container.accessibilityIdentifier = textView.accessibilityIdentifier
            result.append(container)
        }
        for item in self.linkRegistry.values {
            guard let element = item.accessibilityElement else { continue }
            element.accessibilityFrameInContainerSpace = self.rect(forRange: element.range)
            result.append(element)
        }
        return result
    }

    private func rect(forRange range: NSRange) -> CGRect {
        guard let view = self.textView else {
            assertionFailure("textView is nil")
            return .zero
        }
        self.layoutInfoProvider.update(textContainerData: view)
        return self.layoutInfoProvider.rect(forRange: range)
    }

    private lazy var containerAccessibilityElement: UIAccessibilityElement? = self.makeContainerAccessibilityElement()

    private func handler(nearPoint point: CGPoint) -> Handler? {
        if let handler = self.handler(atPoint: point) {
            return handler
        }
        return stride(from: 2.5, to: 15, by: 2.5)
            .lazy
            .flatMap(CGPoint.deltas)
            .compactMap { self.handler(atPoint: point + $0) }
            .first
    }

    private func handler(atPoint point: CGPoint) -> Handler? {
        guard let index = self.layoutInfoProvider.indexOfCharacter(atPoint: point) else { return nil }
        return self.linkRegistry.value(at: index)?.handler
    }

    private func makeAccessibilityElement(range: NSRange,
                                          accessibilityIdentifier: String) -> LinkAccessibilityElement? {
        guard let container = self.textView else {
            assertionFailure("textView is nil")
            return nil
        }
        guard let string = container.attributedText?.string as NSString? else { return nil }
        let value = string.substring(with: range)
        return LinkAccessibilityElement(
            accessibilityContainer: container,
            range: range,
            value: value,
            identfier: accessibilityIdentifier
        )
    }

    private func makeContainerAccessibilityElement() -> UIAccessibilityElement? {
        guard let container = self.textView else {
            assertionFailure("textView is nil")
            return nil
        }
        let element = UIAccessibilityElement(accessibilityContainer: container)
        element.accessibilityTraits = .staticText
        return element
    }

    private func reloadAccessibilityElements() {
        guard let textView = self.textView else {
            assertionFailure("textView is nil")
            return
        }
        textView.accessibilityElements = self.makeAccessibilityElements()
    }
}

// MARK: - Extensions

// ¯\_(ツ)_/¯
#if !swift(>=5)
private extension LazySequenceProtocol {
    var first: Element? {
        for element in self {
            return element
        }
        return nil
    }
}
#endif

private extension CGPoint {
    static func deltas(forRadius radius: CGFloat) -> [CGPoint] {
        let diagonal = radius / sqrt(2)
        return [
            CGPoint(x: -radius, y: 0),
            CGPoint(x: radius, y: 0),
            CGPoint(x: 0, y: -radius),
            CGPoint(x: 0, y: radius),
            CGPoint(x: -diagonal, y: -diagonal),
            CGPoint(x: diagonal, y: diagonal),
            CGPoint(x: diagonal, y: -diagonal),
            CGPoint(x: -diagonal, y: diagonal)
        ]
    }
}

private extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        var copy = lhs
        copy.x += rhs.x
        copy.y += rhs.y
        return copy
    }
}
