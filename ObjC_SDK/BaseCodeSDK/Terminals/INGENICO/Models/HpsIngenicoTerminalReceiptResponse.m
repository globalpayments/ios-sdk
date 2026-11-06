//
//  HpsIngenicoTerminalReceiptResponse.m
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoTerminalReceiptResponse.h"

@implementation HpsIngenicoTerminalReceiptResponse{
    NSData *buffer;
}

-(id)initWithBuffer:(NSData *)data{
    self = [super initWithBuffer:data parseFormat:HPS_INGENICO_PARSE_FORMAT_XML];
    
    buffer = [[NSData alloc]initWithData:data];
    self.status = [buffer length] > 0 ? @"SUCCESS" : @"FAILED";
    
    return self;
}

-(NSString*)toString{
    return [[NSString alloc] initWithString: [HpsTerminalUtilities getString:buffer]];
}

@end
