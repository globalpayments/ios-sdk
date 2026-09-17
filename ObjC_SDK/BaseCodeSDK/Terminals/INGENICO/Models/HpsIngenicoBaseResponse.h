//
//  HpsIngenicoBaseResponse.h
//  ObjC_SDK
//
//  Created by ADL on 10/23/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsTerminalResponse.h"
#import "HpsIngenicoTerminalRepData.h"
#import "HpsIngenicoEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoBaseResponse : HpsTerminalResponse

@property(strong,nonatomic) NSString* referenceNumber;
@property(strong,nonatomic) NSNumber* amount;
@property(strong,nonatomic) NSString* paymentMode;
@property(strong,nonatomic) NSString* currencyCode;
@property(strong,nonatomic) NSString* privateData;

@property(strong,nonatomic) HpsIngenicoTerminalRepData* repData;

-(id)initWithBuffer:(NSData *)data parseFormat:(ParseFormat)pFormat;
-(void)parseResponse:(NSData*)data;

@end

NS_ASSUME_NONNULL_END
