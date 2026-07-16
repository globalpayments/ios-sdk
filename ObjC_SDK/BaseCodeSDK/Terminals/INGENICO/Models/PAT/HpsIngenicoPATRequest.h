//
//  HpsIngenicoPATRequest.h
//  ObjC_SDK
//
//  Created by ADL on 8/30/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsIngenicoEnums.h"
#import "HpsTerminalUtilities.h"
#import "HpsTypeLengthValue.h"
#import "HpsIngenicoPATTransactionOutcome.h"
#import "XMLDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoPATRequest : NSObject

-(id)initWithBuffer:(NSData *)data;

-(PATRequestType)getRequestType;
-(HpsIngenicoPATTransactionOutcome*)getTransactionOutcome;
-(NSString*)getWaiterId;
-(NSString*)getTableNumber;
-(NSString*)getTerminalId;
-(NSString*)getTerminalCurrency;
-(NSString*)getRawRequest;

@end

NS_ASSUME_NONNULL_END
