# Spinner

[![CI Status](http://img.shields.io/travis/Igor Nikitin/Spinner.svg?style=flat)](https://travis-ci.org/Igor Nikitin/Spinner)
[![Version](https://img.shields.io/cocoapods/v/Spinner.svg?style=flat)](http://cocoapods.org/pods/Spinner)
[![License](https://img.shields.io/cocoapods/l/Spinner.svg?style=flat)](http://cocoapods.org/pods/Spinner)
[![Platform](https://img.shields.io/cocoapods/p/Spinner.svg?style=flat)](http://cocoapods.org/pods/Spinner)

<img src="Screenshots/screenshot.png" width="300"/>

## Usage

1. Create instance of `Spinner`:

  `private let spinner = Spinner()`
  
2. Show `spinner`:

  `spinner.showInView(view, withTitle: text)`
  
3. Hide `spinner` when needed:

  ```swift
  spinner.hide()
  
  // or
  
  spinner.hide {
      // completion
  }
  ```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Xcode 7.3
- iOS 9

## Installation

Spinner is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Spinner"
```

## Author

Igor Nikitin, devnickr@icloud.com

## License

Spinner is available under the MIT license. See the LICENSE file for more info.
