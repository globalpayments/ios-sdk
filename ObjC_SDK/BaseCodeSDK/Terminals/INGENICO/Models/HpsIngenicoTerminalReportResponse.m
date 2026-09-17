//
//  HpsIngenicoTerminalReportResponse.m
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoTerminalReportResponse.h"

@implementation HpsIngenicoTerminalReportResponse

-(id)initWithBuffer:(NSData *)data{
    self = [super initWithBuffer:data parseFormat:HPS_INGENICO_PARSE_FORMAT_TRANSACTION];
    return self;
}

-(NSString*)toString{
    return self.deviceResponseMessage;
}


@end
