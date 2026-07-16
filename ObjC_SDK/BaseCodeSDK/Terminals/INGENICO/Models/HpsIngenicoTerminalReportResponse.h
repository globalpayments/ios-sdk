//
//  HpsIngenicoTerminalReportResponse.h
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsTerminalUtilities.h"
#import "HpsIngenicoEnums.h"
#import "HpsTypeLengthValue.h"
#import "HpsDeviceProtocols.h"
#import "HpsIngenicoTerminalResponse.h"


NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoTerminalReportResponse : HpsIngenicoTerminalResponse 

-(id)initWithBuffer:(NSData *)data;
-(NSString*)toString;

@end


NS_ASSUME_NONNULL_END
