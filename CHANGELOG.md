# Changelog

## Latest - v2.0.7 (04/09/2024)

#### Enhancements

- GP-API: Add APM AliPay

## v2.0.6 (04/04/2024)

#### Enhancements

- GP-API: Fix ApplePay Request

## v2.0.5 (03/19/2024)

#### Enhancements

- GP-API: Add File Processing

## v2.0.4 (03/05/2024)

#### Enhancements

- GP-API: Exemption Fields
- GP-API: Add 3DS properties

## v2.0.3 (02/27/2024)

#### Enhancements

- GP-API: Add transfers, split and reverse endpoints
- GP-API: Add Funds endpoint

## v2.0.2 (02/14/2024)

#### Enhancements

- GP-API: Code cleanup

## v2.0.1 (01/30/2024)

#### Enhancements

- GP-API: Add Account Endpoints

## v2.0.0 (01/23/2024)

#### Enhancements

- GP-API: Redesign Demo App and fixed minor issues

## v1.2.21 (09/13/2023)

#### Enhancements

- GP-API: Add request logger sensitive data masked

## v1.2.21 (09/07/2023)

#### Enhancements

- GP-API: Add recurring payments feature
- [DemoApp]: Recurring payments with Hosted Fields library and 3DS flow

## v1.2.20 (08/20/2023)

#### Enhancements

- GP-API: Add OpenBanking feature

## v1.2.19 (07/31/2023)

#### Enhancements

- GP-API: Add BNPL feature

## v1.2.18 (05/24/2023)

#### Enhancements

- GP-API: Add Payer Details on Transaction response

## v1.2.17 (05/18/2023)

#### Enhancements

- GP-API: Add APM Paypal feature

## v1.2.16 (05/01/2023)

#### Enhancements

- GP-API: Add PayLink feature

## v1.2.15 (04/03/2023)

#### Enhancements

- GP-API: Add account id into requests

## v1.2.14 (03/28/2023)

#### Enhancements

- GP-API: Add Brand reference in recurring transaction
- GP-API: Add XGP validation function
- GP-API: Add phone country code function into utils class

## v1.2.13 (03/22/2023)

#### Enhancements

- GP-API: Add Merchant Onboarding

## v1.2.12 (02/27/2023)

#### Enhancements

- GP-API: Add ACH feature

## v1.2.11 (02/01/2023)

#### Enhancements

- GP-API: Add new feature Decoupled Auth on SDK and 3ds demo app project

## v1.2.10 (01/17/2023)

#### Enhancements

- GP-API: Add new feature Currency Conversion DCC
- GP-API: Add 3DS demo app using netcetera library

## v1.2.9 (12/07/2022)

#### Enhancements

- GP-API: Add new feature Adjust, TransactionType::EDIT
- GP-API: Add Stored Payment Methods Search Request
- GP-API: Add get Dispute Document

## v1.2.8 (11/06/2022)

#### Enhancements

- GP-API: Add partner functionality

## v1.2.7 (11/01/2022)

#### Enhancements

- GP-API: Add incremental auth feature

## v1.2.6 (10/22/2022)

- GP-API: Add mapping for card issuer result codes
- GP-API: Add GP-API Dynamic Descriptor
- GP-API: Add Fraud Management flow
- GP-API: Add mapping on missing fields in 3DS flow

## v1.2.5 (07/17/2022)

#### Enhancements

- GP-API: Add update payment token

## v1.2.4 (05/23/2022)

#### Enhancements

- GP-API: Add fingerprint mode
- GP-API: Add functionality for Digital Wallet

## v1.2.3 (04/17/2022)

#### Enhancements

- GP-API: Add Payment Link Id in the request for authorize
- GP-API: Update "entry_mode" functionality and add manual entry methods: MOTO, PHONE, MAIL
- CardUtils MC regex updated
- GP-API: Prepare "IN_APP" entry_mode when creating a transaction with digital wallets

## v1.2.2 (04/11/2021)

#### Enhancements

- Add SDK and library versions on headers

## v1.2.1

#### Enhancements

- Add spinner for country list inside configuration screen
- Add AVS missing mapping to response
- Add deposit date filter on settlement disputes report - GP-API
- Remove "funding" and "cvv_indicator" from Create Stored Payment Method
- add DepositDate, DepositReference on the SettledDisputes report
- Add "Netherlands Antilles" to our mapping for country codes

---

## v1.2.0

#### Enhancements:

- Add GP API actions report
- Add GP API stored payment methods report
- Add GP API transaction reauthorization
- Remove "/detokenize" endpoint from GP-API
- Add 3DSecure implementaiton example in Sample App
- Update GP-API version to 2021-03-22

---
