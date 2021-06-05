//
//  HpsIngenicoBroadcastMessage.m
//  ObjC_SDK
//
//  Created by ADL on 10/22/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoBroadcastMessage.h"

@implementation HpsIngenicoBroadcastMessage

-(id)initWithBuffer:(NSData *)data{
    
    
    HpsIngenicoBroadcastMessage *broadcastMessage = HpsIngenicoBroadcastMessage.new;

    broadcastMessage.buffer = data;
    
    NSMutableDictionary *broadcastCodes = NSMutableDictionary.new;
    [broadcastCodes setValue:@"CONNECTING" forKey:@"A0"];
    [broadcastCodes setValue:@"CONNECTION MADE" forKey:@"A1"];
    [broadcastCodes setValue:@"APPROVED" forKey:@"A2"];
    [broadcastCodes setValue:@"DECLINED" forKey:@"A3"];
    [broadcastCodes setValue:@"INSERT CARD" forKey:@"A4"];

    [broadcastCodes setValue:@"CARD ERROR" forKey:@"A5"];
    [broadcastCodes setValue:@"PROCESSING ERROR" forKey:@"A6"];
    [broadcastCodes setValue:@"REMOVE CARD" forKey:@"A7"];
    [broadcastCodes setValue:@"TRY AGAIN" forKey:@"A8"];
    [broadcastCodes setValue:@"PRESENT CARD" forKey:@"A9"];

    [broadcastCodes setValue:@"RE-PRESENT CARD" forKey:@"AA"];
    [broadcastCodes setValue:@"CARD NOT SUPPORTED" forKey:@"AB"];
    [broadcastCodes setValue:@"PRESENT ONLY ONE CARD" forKey:@"AC"];
    [broadcastCodes setValue:@"PLEASE WAIT" forKey:@"AD"];
    [broadcastCodes setValue:@"BAD SWIPE" forKey:@"AE"];

    [broadcastCodes setValue:@"CARD EXPIRED" forKey:@"AF"];
    [broadcastCodes setValue:@"DECLINED BY CARD" forKey:@"B0"];
    [broadcastCodes setValue:@"PIN ENTRY" forKey:@"B1"];
    [broadcastCodes setValue:@"CASHBACK AMOUNT ENTRY" forKey:@"B2"];
    [broadcastCodes setValue:@"PAPER OUT" forKey:@"B3"];

    [broadcastCodes enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        NSString *broadcastKey = key;
        NSString *broadcastValue = object;

        if ([[HpsTerminalUtilities stringFromData:data] rangeOfString:broadcastKey].location != NSNotFound){
            broadcastMessage.code = broadcastKey;
            broadcastMessage.message = broadcastValue;
        }
    }];
    
    return broadcastMessage;
    
}

@end
