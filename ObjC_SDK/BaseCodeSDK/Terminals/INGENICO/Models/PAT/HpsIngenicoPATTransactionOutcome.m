//
//  HpsIngenicoPATTransactionOutcome.m
//  ObjC_SDK
//
//  Created by ADL on 8/30/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoPATTransactionOutcome.h"

@implementation HpsIngenicoPATTransactionOutcome {
    NSString* transactionStatus;
    NSNumber* transactionAmount;
    NSString* currencyCode;
}

-(HpsIngenicoTerminalRepData*)getRepFields {
    return self.repData;
}

-(NSString*)getTransactionStatus {
    return self.status;
}
-(NSNumber*)getTransactionAmount{
    return self.amount;
}

-(NSString*)getCurrency{
    return self.currencyCode;
}

-(NSString*)getPrivateData{
    return self.privateData;
}

-(id)initWithBuffer:(NSData *)data{
    self = [super initWithBuffer:data];
    return self;
}

@end
