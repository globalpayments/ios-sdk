//
//  HpsIngenicoPOSIdentifierResponse.h
//  ObjC_SDK
//
//  Created by ADL on 10/23/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsIngenicoTerminalResponse.h"
#import "HpsTerminalUtilities.h"
#import "HpsIngenicoEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoPOSIdentifierResponse : HpsIngenicoTerminalResponse

@property (nonatomic,strong) NSString* serialNumber;

-(id)initWithBuffer:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
