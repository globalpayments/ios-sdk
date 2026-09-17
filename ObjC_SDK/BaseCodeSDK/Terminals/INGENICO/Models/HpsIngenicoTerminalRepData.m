//
//  HpsIngenicoTerminalRepData.m
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoTerminalRepData.h"

@implementation HpsIngenicoTerminalRepData

-(id)initWithString:(NSString *)repData{
    self = [super init];
    
    HpsTypeLengthValue *tlv = [[HpsTypeLengthValue alloc] initWithBuffer:[repData dataUsingEncoding:NSUTF8StringEncoding] parseFormat:HPS_INGENICO_PARSE_FORMAT_TRANSACTION];
    
    self.authorizationCode = [tlv getValue:HPS_INGENICO_REP_CODE_AUTHCODE returnType:[NSString class]];
    self.cashBackAmount = [tlv getValue:HPS_INGENICO_REP_CODE_CASHBACK returnType:[NSNumber class]];
    self.tipAmount = [tlv getValue:HPS_INGENICO_REP_CODE_GRATUITY returnType:[NSNumber class]];
    self.finalTransactionAmount = [tlv getValue:HPS_INGENICO_REP_CODE_FINAL_TRANSACTION returnType:[NSNumber class]];
    self.balanceAmount = [tlv getValue:HPS_INGENICO_REP_CODE_AVAILABLE_AMOUNT returnType:[NSNumber class]];
    
    int paymentMethodValue = [[tlv getValue:HPS_INGENICO_REP_CODE_PAYMENT_METHOD returnType:[NSString class]] intValue];
    self.paymentMethod = PaymentMethod_toString[paymentMethodValue];
    
    self.transactionSubType = [tlv getValue:HPS_INGENICO_REP_CODE_TRANSACTION_SUB_TYPE returnType:[NSString class]];
    self.splitSaleAmount = [tlv getValue:HPS_INGENICO_REP_CODE_SPLIT_SALE_AMOUNT returnType:[NSNumber class]];
    self.dccAmount = [tlv getValue:HPS_INGENICO_REP_CODE_DCC_AMOUNT returnType:[NSNumber class]];
    self.dccCurrency = [tlv getValue:HPS_INGENICO_REP_CODE_DCC_CURRENCY returnType:[NSString class]];
    self.dccStatus = [tlv getValue:HPS_INGENICO_REP_CODE_DCC_STATUS returnType:[NSString class]];
    
    return self;
}

@end
