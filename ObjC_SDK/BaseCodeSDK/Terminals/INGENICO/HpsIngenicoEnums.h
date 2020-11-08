//
//  HpsIngenicoEnums.h
//  IOS_SDK_APP
//
//  Created by Macbook Air on 3/24/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsEnum.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, PaymentType) {
    HpsIngenicoPaymentType_SALE = 0,
    HpsIngenicoPaymentType_REFUND = 1,
    HpsIngenicoPaymentType_COMPLETION = 2,
    HpsIngenicoPaymentType_PREAUTH = 3,
    HpsIngenicoPaymentType_ACCOUNT_VERIFICATION = 6,
};

typedef NS_ENUM(int, TaxFreeType) {
    HpsIngenicoTaxFreeType_CREDIT = 4,
    HpsIngenicoTaxFreeType_CASH = 5,
};

typedef NS_ENUM(int, PaymentMode) {
    HpsIngenicoPaymentMode_APPLICATION = 0,
    HpsIngenicoPaymentMode_MAILORDER = 1
};

typedef NS_ENUM(int, PaymentMethod) {
    HPS_INGENICO_KEYED = 1,
    HPS_INGENICO_SWIPED = 2,
    HPS_INGENICO_CHIP = 3,
    HPS_INGENICO_CONTACTLESS = 4
};

typedef NS_ENUM(int, TransactionStatus) {
    HPS_INGENICO_TRANSACTION_STATUS_SUCCESS = 0,
    HPS_INGENICO_TRANSACTION_STATUS_REFERRAL = 2,
    HPS_INGENICO_TRANSACTION_STATUS_CANCELLED_BY_USER = 6,
    HPS_INGENICO_TRANSACTION_STATUS_FAILED = 7,
    HPS_INGENICO_TRANSACTION_STATUS_RECEIVED = 9
};

typedef NS_ENUM(int, ExtendedDataTags) {
    HPS_INGENICO_CASHB,
    HPS_INGENICO_AUTHCODE,
    HPS_INGENICO_TABLE_NUMBER,
    HPS_INGENICO_TXN_COMMANDS,
    HPS_INGENICO_TXN_COMMANDS_PARAMS
};

typedef NS_ENUM(int, ReportType) {
    HPS_INGENICO_EOD,
    HPS_INGENICO_BANKING,
    HPS_INGENICO_XBAL,
    HPS_INGENICO_ZBAL
};

typedef NS_ENUM(int, ReceiptType) {
    HPS_INGENICO_TICKET,
    HPS_INGENICO_SPLITR,
    HPS_INGENICO_TAXFREE,
    HPS_INGENICO_REPORT
};

typedef NS_ENUM(int, TerminalCommandType) {
    HPS_INGENICO_CALL_TMS,
    HPS_INGENICO_LOGON,
    HPS_INGENICO_RESET,
    HPS_INGENICO_STATE,
    HPS_INGENICO_PID
};

typedef NS_ENUM(int, TerminalStatus) {
    HPS_INGENICO_NOT_READY = 0,
    HPS_INGENICO_READY = 1
};

typedef NS_ENUM(int, SalesMode) {
    HPS_INGENICO_STANDARD_SALE_MODE = 0,
    HPS_INGENICO_VENDING_MODE = 1
};

typedef NS_ENUM(int, ParseFormat) {
    HPS_INGENICO_PARSE_FORMAT_TRANSACTION = 0,
    HPS_INGENICO_PARSE_FORMAT_STATE = 1,
    HPS_INGENICO_PARSE_FORMAT_PID = 2,
    HPS_INGENICO_PARSE_FORMAT_PAT = 3,
    HPS_INGENICO_PARSE_FORMAT_XML = 4
};

typedef NS_ENUM(int, RepFieldCode) {
    HPS_INGENICO_REP_CODE_AUTHCODE = 67,
    HPS_INGENICO_REP_CODE_CASHBACK = 90,
    HPS_INGENICO_REP_CODE_GRATUITY = 89,
    HPS_INGENICO_REP_CODE_FINAL_TRANSACTION = 77,
    HPS_INGENICO_REP_CODE_AVAILABLE_AMOUNT = 65,
    HPS_INGENICO_REP_CODE_DCC_CURRENCY = 85,
    HPS_INGENICO_REP_CODE_DCC_AMOUNT = 79,
    HPS_INGENICO_REP_CODE_PAYMENT_METHOD = 80,
    HPS_INGENICO_REP_CODE_TRANSACTION_SUB_TYPE = 84,
    HPS_INGENICO_REP_CODE_SPLIT_SALE_AMOUNT = 83,
    HPS_INGENICO_REP_CODE_DCC_STATUS = 68,
};

typedef NS_ENUM(int, StatusResponseCode) {
    HPS_INGENICO_STATUS_RESPONSE_CODE_STATUS = 83,
    HPS_INGENICO_STATUS_RESPONSE_CODE_APP_VERSION = 86,
    HPS_INGENICO_STATUS_RESPONSE_CODE_HANDSET_NUMBER = 72,
    HPS_INGENICO_STATUS_RESPONSE_CODE_TERMINAL_ID = 84
};


#pragma mark -  Pay@Table

typedef NS_ENUM(int, PATRequestType) {
    HPS_INGENICO_PAT_REQUEST_TABLE_LOCK = 1,
    HPS_INGENICO_PAT_REQUEST_TABLE_UNLOCK = 2,
    HPS_INGENICO_PAT_REQUEST_RECEIPT_MESSAGE = 3,
    HPS_INGENICO_PAT_REQUEST_TABLE_LIST = 4,
    HPS_INGENICO_PAT_REQUEST_TRANSACTION_OUTCOME = 5,
    HPS_INGENICO_PAT_REQUEST_ADDITIONAL_MESSAGE = 6,
    HPS_INGENICO_PAT_REQUEST_TRANSFER_DATA = 7,
    HPS_INGENICO_PAT_REQUEST_SPLITSALE_REPORT = 8,
    HPS_INGENICO_PAT_REQUEST_FINAL_REPORT = 9,
    HPS_INGENICO_PAT_REQUEST_TICKET = 10,
    HPS_INGENICO_PAT_REQUEST_EOD_REPORT = 11,
    HPS_INGENICO_PAT_REQUEST_STATE = 12
};

typedef NS_ENUM(int, PATPrivateDataCode) {
    HPS_INGENICO_PAT_PRIV_CODE_WAITER_ID = 79,
    HPS_INGENICO_PAT_PRIV_CODE_TABLE_ID = 76,
    HPS_INGENICO_PAT_PRIV_CODE_TID = 84,
    HPS_INGENICO_PAT_PRIV_CODE_TERMINAL_CURRENCY = 67
};

typedef NS_ENUM(int, PATResponseType) {
    HPS_INGENICO_PAT_RESPONSE_TYPE_CONF_NOK = 0,
    HPS_INGENICO_PAT_RESPONSE_TYPE_CONF_OK = 1
};

typedef NS_ENUM(int, PATPaymentMode) {
    HPS_INGENICO_PAT_PAYMENT_MODE_NO_ADDITIONAL_MSG = 0,
    HPS_INGENICO_PAT_PAYMENT_MODE_USE_ADDITIONAL_MSG = 1
};



@interface HpsIngenicoEnums : NSObject

//String literals
extern  NSString * const HpsIngenico_BROADCAST;
extern  NSString * const HPS_INGENICO_TID_CODE;
extern  NSString * const HPS_INGENICO_XML_TAG;

extern  NSString * const HPS_INGENICO_PAT_XML_TYPE_ADDITIONAL_MSG;
extern  NSString * const HPS_INGENICO_PAT_XML_TYPE_TRANSFER_DATA_REQUEST;
extern  NSString * const HPS_INGENICO_PAT_XML_TYPE_TRANSACTION_XML;

extern  NSString * const HPS_INGENICO_PAT_STYPE_SPLIT_SALE;
extern  NSString * const HPS_INGENICO_PAT_STYPE_SPLIT_SALE_ROOT;
extern  NSString * const HPS_INGENICO_PAT_STYPE_TICKET_MERCHANT;
extern  NSString * const HPS_INGENICO_PAT_STYPE_TICKET_CUSTOMER;
extern  NSString * const HPS_INGENICO_PAT_STYPE_EOD;
extern  NSString * const HPS_INGENICO_PAT_STYPE_STATE;

extern  NSString * const HPS_INGENICO_REQ_CMD_CANCEL;
extern  NSString * const HPS_INGENICO_REQ_CMD_DUPLICATE;
extern  NSString * const HPS_INGENICO_REQ_CMD_REVERSE;
extern  NSString * const HPS_INGENICO_REQ_CMD_REVERSE_WITH_ID;
extern  NSString * const HPS_INGENICO_REQ_CMD_REPORT;
extern  NSString * const HPS_INGENICO_REQ_CMD_RECEIPT;
extern  NSString * const HPS_INGENICO_REQ_CMD_TERMINAL;
extern  NSString * const HPS_INGENICO_REQ_CMD_REQUEST_MESSAGE;

extern  NSString * const HPS_INGENICO_REQ_CMD_CALL_TMS;
extern  NSString * const HPS_INGENICO_REQ_CMD_LOGON;
extern  NSString * const HPS_INGENICO_REQ_CMD_RESET;
extern  NSString * const HPS_INGENICO_REQ_CMD_STATE;
extern  NSString * const HPS_INGENICO_REQ_CMD_PID;

extern  NSString * _Nonnull const PaymentMode_toString[];
extern  NSString * _Nonnull const PaymentMethod_toString[];

extern  NSString * _Nonnull const TransactionStatus_toString[];
extern  NSString * _Nonnull const ReportType_toString[];
extern  NSString * _Nonnull const ReceiptType_toString[];
extern  NSString * _Nonnull const TerminalCommandType_toString[];

extern  NSString * _Nonnull const TerminalStatus_toString[];
extern  NSString * _Nonnull const SalesMode_toString[];

#pragma mark -  Pay@Table
extern  NSString * _Nonnull const PATResponseType_toString[];

@end

NS_ASSUME_NONNULL_END
