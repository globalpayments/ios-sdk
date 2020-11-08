//
//  HpsIngenicoTerminalStateResponse.m
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoTerminalStateResponse.h"

@implementation HpsIngenicoTerminalStateResponse

-(id)initWithBuffer:(NSData *)data{
    self = [super initWithBuffer:data parseFormat:HPS_INGENICO_PARSE_FORMAT_STATE];
    return self;
}

-(void)parseResponse:(NSData*)data{
    
    [super parseResponse:data];
    
    NSString *dataString = [[NSString alloc]initWithString:[HpsTerminalUtilities stringFromData:data]];
    NSString *stateData = [HpsTerminalUtilities getSubString:dataString range:NSMakeRange(12, 55)];
    
    HpsTypeLengthValue *tlv = [[HpsTypeLengthValue alloc] initWithBuffer:[stateData dataUsingEncoding:NSUTF8StringEncoding] parseFormat:HPS_INGENICO_PARSE_FORMAT_STATE];
    
    NSString *status = [tlv getValue:HPS_INGENICO_STATUS_RESPONSE_CODE_STATUS returnType:[NSString class]];
    
    self.terminalStatus = TerminalStatus_toString[[[status substringWithRange: NSMakeRange(0, 1)] intValue]];
    self.salesMode = SalesMode_toString[[[status substringWithRange: NSMakeRange(1, 1)] intValue]];
    self.terminalCapabilities = [status substringWithRange: NSMakeRange(2, 6)];
    self.additionalTerminalCap = [status substringWithRange: NSMakeRange(8, 10)];
    
    self.appVersion = [tlv getValue:HPS_INGENICO_STATUS_RESPONSE_CODE_APP_VERSION returnType:[NSString class]];
    self.handsetNumber = [tlv getValue:HPS_INGENICO_STATUS_RESPONSE_CODE_HANDSET_NUMBER returnType:[NSString class]];
    self.terminalId = [tlv getValue:HPS_INGENICO_STATUS_RESPONSE_CODE_TERMINAL_ID returnType:[NSString class]];
    
}

@end
