//
//  HpsIngenicoTerminalReceiptResponse.h
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsDeviceProtocols.h"
#import "HpsIngenicoEnums.h"
#import "HpsIngenicoBaseResponse.h"


NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoTerminalReceiptResponse : HpsIngenicoBaseResponse <IHPSDeviceResponse>

-(id)initWithBuffer:(NSData *)data;
-(NSString*)toString;

@end

NS_ASSUME_NONNULL_END
