//
//  HpsIngenicoTerminalResponse.m
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoTerminalResponse.h"

@implementation HpsIngenicoTerminalResponse

-(id)initWithBuffer:(NSData *)data{
    self = [super initWithBuffer:data parseFormat:HPS_INGENICO_PARSE_FORMAT_TRANSACTION];

    self.authorizationCode = self.repData.authorizationCode;
    self.cashBackAmount = self.repData.cashBackAmount;
    self.tipAmount = self.repData.tipAmount;
    self.finalTransactionAmount = self.repData.finalTransactionAmount;
    self.balanceAmount = self.repData.balanceAmount;
    self.paymentMethod = self.repData.paymentMethod;
    self.transactionSubType = self.repData.transactionSubType;
    self.splitSaleAmount = self.repData.splitSaleAmount;
    self.dccStatus = self.repData.dccStatus;
    self.dccAmount = self.repData.dccAmount;
    self.dccCurrency = self.repData.dccCurrency;
    
    return self;
}

-(NSString*)toString{
    return self.deviceResponseMessage;
}



@end
 
