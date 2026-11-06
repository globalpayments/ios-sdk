//
//  HpsIngenicoPOSIdentifierResponse.m
//  ObjC_SDK
//
//  Created by ADL on 10/23/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoPOSIdentifierResponse.h"

@implementation HpsIngenicoPOSIdentifierResponse

-(id)initWithBuffer:(NSData *)data{
    self = [super initWithBuffer:data parseFormat:HPS_INGENICO_PARSE_FORMAT_PID];
    return self;
}

-(void)parseResponse:(NSData*)data{
    
    [super parseResponse:data];
    
    NSString *dataString = [[NSString alloc]initWithString:[HpsTerminalUtilities stringFromData:data]];
    self.serialNumber = [HpsTerminalUtilities getSubString:dataString range:NSMakeRange(12, 55)];
    
}


@end
