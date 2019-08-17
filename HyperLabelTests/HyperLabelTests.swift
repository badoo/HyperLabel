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

import XCTest
@testable import HyperLabel

class HyperLabelTests: XCTestCase {

    override func setUp() { }

    override func tearDown() { }

    func test_GivenTextWithSpecialCharacter_WhenAddLink_ThenRangesAreCorrect() {
        // Given
        // '’' is UTF16?
        let exampleText = "You’ll be happy one day."
        let sut: HyperLabel = {
            let hyperLabel = HyperLabel()
            hyperLabel.numberOfLines = 0
            hyperLabel.text = exampleText
            hyperLabel.additionalLinkAttributes = [.underlineStyle: NSUnderlineStyle.single.rawValue]
            return hyperLabel
        }()

        // When
        let range = exampleText.range(of: "day")!

        // Then
        sut.addLink(withRange: range) {}
    }

    func test_GivenSimpleText_WhenAddLink_ThenRangesAreCorrect() {
        // Given
        let exampleText = "Look's good with no special characters."
        let sut: HyperLabel = {
            let hyperLabel = HyperLabel()
            hyperLabel.numberOfLines = 0
            hyperLabel.text = exampleText
            hyperLabel.additionalLinkAttributes = [.underlineStyle: NSUnderlineStyle.single.rawValue]
            return hyperLabel
        }()

        // When
        let range = exampleText.range(of: "characters")!

        // Then
        sut.addLink(withRange: range) {}
    }

}
