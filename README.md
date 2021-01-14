<a href="https://github.com/globalpayments" target="_blank">
    <img src="https://developer.globalpay.com/static/media/logo.dab7811d.svg" alt="Global Payments logo" title="Global Payments" align="right" width="225" />
</a>

# GlobalPayments iOS Library
You can find more information on how to use this library and sign up for a free Global Payments sandbox account at https://developer.globalpay.com

## Requirements

- iOS 9.0+
- Xcode 11+
- Swift 5.0+

## Installation

### Cocoapods

1. To integrate the Global Payments iOS Library into your Xcode project using CocoaPods, specify it in your podfile:

```
pod 'GlobalPayments-iOS-SDK', '~> 1.0'
```

2. Then, run the following command:

```
$ pod install
```
### Manual

If you prefer not to use a dependency manager, you can integrate the Global Payments iOS Library into your project manually.

* Download the the latest release from GitHub:

	https://github.com/globalpayments/ios-sdk/releases

* Drag and drop the folder 'GlobalPayments-iOS-SDK' into Xcode.

## Documentation and Examples

You can find the latest SDK documentation along with code examples and test cards on the [Global Payments](https://developer.globalpay.com) Developer Hub.

In addition you can find working examples in the our example code repository.

*Quick Tip*: The included [test suite](https://github.com/globalpayments/ios-sdk/tree/master/Example/Tests/GpApi) can be a great source of code samples for using the SDK!

#### Process a Payment Example

```Swift
/// Prepare required configuration
let config = GpApiConfig (
    appId: "Your application ID",
    appKey: "Your application key"
)

/// Add config to container
try ServicesContainer.configureService(config: config)

/// Prepare card
let card = CreditCardData()
card.number = "4111111111111111"
card.expMonth = 12
card.expYear = 2025
card.cvn = "123"
card.cardHolderName = "Joe Smith"

// Execute operation
card.charge(amount: 19.99)
    .withCurrency("USD")
    .execute { transaction, error in
        // Handle transaction response or error
}
```

#### Test Card Data

Name        | Number           | Exp Month | Exp Year | CVN
----------- | ---------------- | --------- | -------- | ----
Visa        | 4263970000005262 | 12        | 2025     | 123
MasterCard  | 2223000010005780 | 12        | 2019     | 900
MasterCard  | 5425230000004415 | 12        | 2025     | 123
Discover    | 6011000000000087 | 12        | 2025     | 123
Amex        | 374101000000608  | 12        | 2025     | 1234
JCB         | 3566000000000000 | 12        | 2025     | 123
Diners Club | 36256000000725   | 12        | 2025     | 123

#### Testing Exceptions

During your integration you will want to test for specific issuer responses such as 'Card Declined'. Because our sandbox environments do not actually reach out to issuing banks for authorizations, there are specific transaction amounts and/or card numbers that will trigger gateway and issuing bank responses. Please contact your support representative for a complete listing of values used to simulate transaction AVS/CVV results, declines, errors, and other responses that can be caught in your code. Example error handling code:

```Swift
card.charge(amount: 19.99)
    .withCurrency("USD")
    .withAddress(address)
    .execute { transaction, error in
        if let error = error as? BuilderException {
            // handle builder errors
        } else if let error = error as? ConfigurationException {
            // handle errors related to your services configuration
        } else if let error = error as? GatewayException {
            // handle gateway errors/exceptions
        } else if let error = error as? UnsupportedTransactionException {
            // handle errors when the configured gateway doesn't support desired transaction
        } else if let error = error as? ApiException {
            // handle all other errors
        }
    }
```

## Contributing

All our code is open sourced and we encourage fellow developers to contribute and help improve it!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Ensure SDK tests are passing
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## License

This project is licensed under the GNU General Public License v2.0. Please see [LICENSE.md](LICENSE.md) located at the project's root for more details.
