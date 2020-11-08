//
//  HpsIngenicoBaseResponse.m
//  ObjC_SDK
//
//  Created by ADL on 10/23/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoBaseResponse.h"

@implementation HpsIngenicoBaseResponse {
    ParseFormat parseFormat;
}

-(id)initWithBuffer:(NSData *)data parseFormat:(ParseFormat)pFormat{
    self = [super init];
    
    parseFormat = pFormat;
    
    if(parseFormat != HPS_INGENICO_PARSE_FORMAT_XML){
        [self parseResponse:data];
    }
    
    return self;
}


-(void)parseResponse:(NSData*)data{
    
    NSString *dataString = [[NSString alloc]initWithString:[HpsTerminalUtilities stringFromData:data]];

    NSString *eposNum = [HpsTerminalUtilities getSubString:dataString range:NSMakeRange(0, 2)];
    self.referenceNumber = eposNum;
    
    NSString *status = [HpsTerminalUtilities getSubString:dataString range:NSMakeRange(2, 1)];
    self.status = TransactionStatus_toString[[status intValue]];
    
    NSString *amount = [HpsTerminalUtilities getSubString:dataString range:NSMakeRange(3, 8)];
    self.amount = [NSNumber numberWithDouble:([amount doubleValue] / 100.00f)];
    
    NSString *paymentMode = [HpsTerminalUtilities getSubString:dataString range:NSMakeRange(11, 1)];
    self.paymentMode = PaymentMode_toString[[paymentMode intValue]];
    
    NSString *currency = [HpsTerminalUtilities getSubString:dataString range:NSMakeRange(67, 3)];
    self.currencyCode = currency;
    
    NSString *privateData = [HpsTerminalUtilities getSubString:dataString range:NSMakeRange(70, 10)];
    self.privateData = privateData;
    
    if (parseFormat == HPS_INGENICO_PARSE_FORMAT_TRANSACTION){
        self.repData = [[HpsIngenicoTerminalRepData alloc] initWithString:[HpsTerminalUtilities getSubString:dataString range:NSMakeRange(12, 55)]];
    }
    
    self.deviceResponseMessage = dataString;
}

@end
