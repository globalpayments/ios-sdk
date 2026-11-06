//
//  HpsIngenicoDeviceResponse.h
//  IOS_SDK_APP
//
//  Created by Macbook Air on 3/24/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsTerminalUtilities.h"
#import "HpsIngenicoEnums.h"
#import "HpsTypeLengthValue.h"
#import "HpsIngenicoTerminalRepData.h"
#import "HpsIngenicoBaseResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoTerminalResponse : HpsIngenicoBaseResponse <IHPSDeviceResponse>

//REP Fields
@property(strong,nonatomic) NSString* authorizationCode;
@property(strong,nonatomic) NSNumber* finalTransactionAmount;
@property(strong,nonatomic) NSString* paymentMethod;
@property(strong,nonatomic) NSString* transactionSubType;
@property(strong,nonatomic) NSNumber* splitSaleAmount;
@property(strong,nonatomic) NSString* dccStatus;
@property(strong,nonatomic) NSNumber* dccAmount;
@property(strong,nonatomic) NSString* dccCurrency;

-(id)initWithBuffer:(NSData *)data;
-(NSString*)toString;

@end


NS_ASSUME_NONNULL_END


