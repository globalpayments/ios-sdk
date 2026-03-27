//
//  HpsTypeLengthValue.m
//  ObjC_SDK
//
//  Created by ADL on 8/31/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsTypeLengthValue.h"

@implementation HpsTypeLengthValue {
    NSString *dataString;
    NSArray *dataArray;
    ParseFormat parseFormat;
}

-(id)initWithBuffer:(NSData *)data parseFormat:(ParseFormat)format{
    self = [super init];

    dataString = [[NSString alloc]initWithString:[HpsTerminalUtilities stringFromData:data]];
    dataArray = [HpsTerminalUtilities stringToArray:dataString];
    parseFormat = format;
    
    NSLog(@"DATASTRING LENGTH:%d", [dataString length]);
    
    return self;
}

-(id)getValue:(int)type returnType:(Class)returnType{
    
    NSString *marker = [NSString stringWithFormat:@"%c", type];
    
    int markerIndex = [dataArray indexOfObject:marker];

    if (markerIndex != -1 && markerIndex <= dataString.length){

        NSString *lengthString = [dataString substringWithRange: NSMakeRange(markerIndex + 1, 2)];

        //convert length string to integer save in result variable
        unsigned result = 0;
        NSScanner *scanner = [NSScanner scannerWithString:lengthString];

        [scanner setScanLocation:0];
        
        if ((parseFormat == HPS_INGENICO_PARSE_FORMAT_PAT && type == HPS_INGENICO_PAT_PRIV_CODE_TABLE_ID) || (parseFormat == HPS_INGENICO_PARSE_FORMAT_STATE && (type == HPS_INGENICO_STATUS_RESPONSE_CODE_APP_VERSION || type == HPS_INGENICO_STATUS_RESPONSE_CODE_STATUS ))){
            [scanner scanInt:&result];
        } else {
            [scanner scanHexInt:&result];
        }

        int length = result;
        
        NSLog(@"MARKER: %@ LENGTH:%d", marker, length);
        

        //set markerIndex 3 places to the right in order to read its data
        markerIndex = markerIndex + 3;
        NSString *valueString = [dataString substringWithRange: NSMakeRange(markerIndex, length)];
        
        NSLog(@"VALUE STRING:%@", valueString);
        
        int endIndex = markerIndex + length;
        
        //dataString = [dataString substringWithRange: NSMakeRange(endIndex, ([dataString length] - (length + 3)))];
        dataString = [HpsTerminalUtilities getSubString:dataString range:NSMakeRange(endIndex, ([dataString length] - (length + 3)))];
        
        if ([dataString length] > 0){
            dataArray = [HpsTerminalUtilities stringToArray:dataString];
        }
        
        
        if (returnType == [NSString class]){
            return valueString;
        } else if (returnType == [NSNumber class]){
            float value = [valueString doubleValue] / 100.00f;
            return [NSNumber numberWithDouble:value];
        } else {
            return nil;
        }
        
    } else {
        return nil;
    }
    
}

@end
