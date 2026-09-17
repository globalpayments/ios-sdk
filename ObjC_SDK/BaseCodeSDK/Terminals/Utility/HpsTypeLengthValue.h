//
//  HpsTypeLengthValue.h
//  ObjC_SDK
//
//  Created by ADL on 8/31/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsTerminalUtilities.h"
#import "HpsIngenicoEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpsTypeLengthValue : NSObject

-(id)initWithBuffer:(NSData *)data parseFormat:(ParseFormat)format;
-(id)getValue:(int)type returnType:(Class)returnType;

@end

NS_ASSUME_NONNULL_END
