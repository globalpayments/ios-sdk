//
//  HpsIngenicoBroadcastMessage.h
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsTerminalUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoBroadcastMessage : NSObject

@property (nonatomic,strong) NSData *buffer;
@property (nonatomic,strong) NSString *code;
@property (nonatomic,strong) NSString *message;


-(id)initWithBuffer:(NSData *)data;

@end


NS_ASSUME_NONNULL_END
