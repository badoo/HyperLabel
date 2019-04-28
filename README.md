HyperLabel
==========

HyperLabel is a UILabel replacement which suports adding links for arbitraray part of the text

Features
--------

### UI Automation support

HyperLabel supports setting custom `accessibilityIdentifier` for added links

### VoiceOver

All added links will have proper description and will be accessible with VoiceOver
  
### No subclassing needed

If you already have a subclass of UILabel, you can add HyperLabel functionallity to it. Just by conform it to `HyperLabelProtocol` and call `initializeHyperLabel`

Usage
-----

```swift
let label = HyperLabel()

// Set additional attributes which will be applied for added links
label.additionalLinkAttributes = [
    NSAttributedString.Key.foregroundColor: UIColor.red,
    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
]

// Set text
label.text = "Hello world!"

// Get range of the link
let linkRange = text.range(of: "world")!

// Add handler for range
label.addLink(withRange: linkRange) {
    // On link press
}
```

Installation
------------

### Carthage

Add HyperLabel to your Cartfile:
```
github "badoo/HyperLabel"
```

### Manual

1. Add as a submodule or [download](https://github.com/badoo/HyperLabel/archive/master.zip)
2. Drag `HyperLabel.xcodeproj` inside of your project
3. Add `HyperLabel.framework` to Target Dependencies
4. Add `HyperLabel.framework` to Embedded Binaries

License
-------

Source code is distributed under MIT license
