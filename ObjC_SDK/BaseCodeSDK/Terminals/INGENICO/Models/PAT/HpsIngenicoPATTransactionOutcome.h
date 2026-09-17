//
//  HpsIngenicoPATTransactionOutcome.h
//  ObjC_SDK
//
//  Created by ADL on 8/30/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsIngenicoDeviceResponse.h"
#import "HpsIngenicoEnums.h"
#import "HpsIngenicoTerminalResponse.h"
#import "HpsTerminalUtilities.h"
#import "HpsTypeLengthValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoPATTransactionOutcome : HpsIngenicoTerminalResponse

-(id)initWithBuffer:(NSData *)data;

-(HpsIngenicoTerminalRepData*)getRepFields;
-(NSString*)getTransactionStatus;
-(NSNumber*)getTransactionAmount;
-(NSString*)getCurrency;
-(NSString*)getPrivateData;

@end

NS_ASSUME_NONNULL_END
