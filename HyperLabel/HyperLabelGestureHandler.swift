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

public final class HyperLabelGestureHandler {

    // MARK: - Type declarations

    public typealias Handler = () -> Void
    public typealias TextView = UIView & TextContainerData

    // MARK: - Private properties

    private var linkRegistry = RangeMap<String.Index, Handler>()
    private let indexFinder = CharacterIndexFinder()

    // MARK: - Public API

    public var extendsLinkTouchArea: Bool = true

    public weak var textView: TextView?

    public func addLink(addLinkWithRange range: Range<String.Index>, withHandler handler: @escaping Handler) {
        self.linkRegistry.setValue(value: handler, forRange: range)
    }

    public func removeAllLinks() {
        self.linkRegistry.clear()
    }

    @objc
    public func handleTapGesture(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        guard let view = self.textView else { return }
        let point = sender.location(in: view)
        self.indexFinder.update(textContainerData: view)
        let handlerProvider = self.extendsLinkTouchArea ? self.handler(nearPoint:) : self.handler(atPoint:)
        guard let handler = handlerProvider(point) else { return }
        handler()
    }

    public func rect(forRange range: Range<String.Index>) -> CGRect {
        guard let view = self.textView else { return .zero }
        self.indexFinder.update(textContainerData: view)
        return self.indexFinder.rect(forRange: range)
    }

    // MARK: - Private methods

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
        guard let index = self.indexFinder.indexOfCharacter(atPoint: point) else { return nil }
        return self.linkRegistry.value(at: index)
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
