//
//  HpsIngenicoTerminalRepData.h
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsTerminalUtilities.h"
#import "HpsIngenicoEnums.h"
#import "HpsTypeLengthValue.h"


NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoTerminalRepData : NSObject

@property(strong,nonatomic) NSString* authorizationCode;
@property(strong,nonatomic) NSNumber* cashBackAmount;
@property(strong,nonatomic) NSNumber* tipAmount;
@property(strong,nonatomic) NSNumber* finalTransactionAmount;
@property(strong,nonatomic) NSNumber* balanceAmount;
@property(strong,nonatomic) NSString* paymentMethod;
@property(strong,nonatomic) NSString* transactionSubType;
@property(strong,nonatomic) NSNumber* splitSaleAmount;
@property(strong,nonatomic) NSString* dccStatus;
@property(strong,nonatomic) NSNumber* dccAmount;
@property(strong,nonatomic) NSString* dccCurrency;

-(id)initWithString:(NSString *)repData;

@end
NS_ASSUME_NONNULL_END
