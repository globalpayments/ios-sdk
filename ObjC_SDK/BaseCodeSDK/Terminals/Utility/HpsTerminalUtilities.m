#import "HpsTerminalUtilities.h"
#import "HpsTerminalEnums.h"

@implementation HpsTerminalUtilities

+ (HpsDeviceMessage*) buildRequest: (NSString*) messageId{
    return [self buildMessage:messageId withMessage:@""];
    
}

+ (HpsDeviceMessage*) buildRequest: (NSString*) messageId withElements:(NSArray*)elements{
    NSString *message = [self getElementString:elements];
    return [self buildMessage:messageId withMessage:message];
}

+ (NSString*) getElementString:(NSArray*)elements{
	NSMutableString *sb = [[NSMutableString alloc] init];
	for (int i = 0; i < elements.count; i++) {

		id thing = elements[i];

		if ([thing isKindOfClass:[NSArray class]]) {
			for (NSString *thisString in thing) {
				[sb appendString:[HpsTerminalEnums controlCodeString:HpsControlCodes_FS]];
				[sb appendString:thisString];
			}
		}else if ([HpsTerminalEnums isControlCode:(Byte)thing]){
			NSString *codestring = [HpsTerminalEnums controlCodeString:(Byte)thing];
			[sb appendString:codestring];
		}else if ([thing respondsToSelector:@selector(getElementString)]) {
			NSString *valueRecived = [thing performSelector:@selector(getElementString)];
			NSString *modifiedString = [self trimHpsRequestString:valueRecived];
			[sb appendString:modifiedString];
		}else if ([thing isKindOfClass:[NSString class]]) {
			[sb appendString:thing];
		}

	}
	return [sb copy];
}

+ (HpsDeviceMessage*) buildMessage: (NSString*) messageId withMessage:(NSString*)message{

    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    //Begin Message    
    [buffer appendBytes:(char []){ HpsControlCodes_STX } length:1];
    
    //Add MessageID
    [buffer appendData:[messageId dataUsingEncoding:NSASCIIStringEncoding]];
    [buffer appendBytes:(char []){ HpsControlCodes_FS } length:1];
    
    //Add Version
    [buffer appendData:[PAX_DEVICE_VERSION dataUsingEncoding:NSASCIIStringEncoding]];
    [buffer appendBytes:(char []){ HpsControlCodes_FS }  length:1];
    
    // Add the Message
    [buffer appendData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    
    //End Message
    [buffer appendBytes:(char []){ HpsControlCodes_ETX }  length:1];    
        
    //Calc LRC
    Byte lrc = [self calcLRC:buffer];
    [buffer appendBytes:(char []){ lrc } length:sizeof(lrc)];
    
    //Return
    return [[HpsDeviceMessage alloc] initWithBuffer:buffer];
    
}

+ (Byte) calcLRC:(NSMutableData*) data{
    Byte LRC = 0;
    
    const unsigned char *bytes = [data bytes];
    for(int j=1; j < [data length]; j++){
       LRC ^= bytes[j];
    }    
    return LRC;
}

+ (NSString *)trimHpsRequestString:(NSString *)message{
	NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData *mutable_data = [[NSMutableData alloc]initWithData:data];;

	unsigned char *bytes = (unsigned char *)[mutable_data bytes];
	int length = [NSNumber numberWithInteger:[mutable_data length]].intValue;
	BOOL isTrimmed = NO;

	for(int j=length-1; j >= 0 && !isTrimmed; j--){
		Byte currentByte = (Byte)bytes[j];

		switch (currentByte) {
			case HpsControlCodes_US:
				[mutable_data setLength:mutable_data.length - sizeof(Byte)];
				break;
			case HpsControlCodes_FS:
				break;
			default:
				isTrimmed = YES;
				break;
		}
	}

 NSString *trimmed_US_CodeAtEnd	=  [[NSString alloc]initWithData:mutable_data encoding:NSUTF8StringEncoding];
	return trimmed_US_CodeAtEnd;
}

+ (NSData *)trimHpsResponseData:(NSData *)data{
	NSString *responseString = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
	NSArray *array	= [responseString componentsSeparatedByString:[HpsTerminalEnums controlCodeString:HpsControlCodes_FS]];
	NSMutableString *trimmedString = [[NSMutableString alloc] init];
	for (int i = 0 ; i < [array count];i++){
		[trimmedString appendString:[self trimHpsRequestString:[array objectAtIndex:i]]];
		if (!(i == [array count] -1))
			[trimmedString appendString:[HpsTerminalEnums controlCodeString:HpsControlCodes_FS]];
	}

return [trimmedString dataUsingEncoding:NSUTF8StringEncoding];
}


	//HPA
+ (id <IHPSDeviceMessage>) BuildRequest:(NSString *) message withFormat:(MessageFormat)format {
	NSMutableData *buffer = [[NSMutableData alloc] init];

	switch(format)
	{
		case Visa2nd:
		{
			[buffer appendBytes:(char []){ HpsControlCodes_STX } length:1];
			[buffer appendData:[message dataUsingEncoding:NSASCIIStringEncoding]];
			[buffer appendBytes:(char []){ HpsControlCodes_ETX }  length:1];
			Byte lrc = [HpsTerminalUtilities calcLRC:buffer];
			[buffer appendBytes:(char []){ lrc } length:sizeof(lrc)];
		}
		break;

		case HPA:
		{
			//add length
		uint16_t swapped = NSSwapHostShortToBig(message.length);
		[buffer appendBytes:&swapped length:sizeof(swapped)];
		//Add Message
		[buffer appendData:[message dataUsingEncoding:NSASCIIStringEncoding]];
}
		break;
		default:

		break;
			
	}
		//Return
	
	return [[HpsDeviceMessage alloc] initWithBuffer:buffer];
}


//INGENICO

+ (NSString *)getSubString:(NSString *)dataString range:(NSRange)range{
    
    NSString *str = @"";

    if ((range.location <= ([dataString length]-1)) && (range.location + range.length) <= [dataString length]){
        str = [dataString substringWithRange: range];
    } else if ((range.location <= ([dataString length]-1)) && (range.location + range.length) > [dataString length]){
        str = [dataString substringWithRange: NSMakeRange(range.location, [dataString length] - range.location)];
    }
    
    return str;
}

+ (HpsDeviceMessage *)BuildIngenicoRequest:(NSString *)message{
    
    NSMutableData *request = [[NSMutableData alloc] init];
    NSData *messageData = [[NSData alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request appendData:[self CalculateHeader:messageData]];
    [request appendData:messageData];
    
    NSString *requestString = [[NSString alloc] initWithData:request encoding:NSUTF8StringEncoding];
    
    NSLog(@"REQUEST DATA: %@\n", request);
    NSLog(@"REQUEST STRING: %@", requestString);
    
    return [[HpsDeviceMessage alloc] initWithBuffer:request];
    
}

+ (NSData *)CalculateHeader:(NSData *)data{
    
    unsigned long dataLength = [data length];
    
    NSMutableString * str = [[NSMutableString alloc] init];
    [str appendString:@"00"];
    
    if (dataLength < 10){
        [str appendFormat:@"0%lu",dataLength];
    } else {
        [str appendFormat:@"%lu",dataLength];
    }
    
    return [self dataFromHexString:str];
    
}

+ (int)HeaderLength:(NSData *)data{
    
    NSMutableString *result = [NSMutableString string];
    const char *bytes = [data bytes];

    for (int i = 0; i < [data length]; i++) {
        [result appendFormat:@"%02hhx", (unsigned char)bytes[i]];
    }
    
    NSLog(@"HEADER STRING:%@", result);
    
    unsigned resultIntValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:result];

    [scanner setScanLocation:0]; // bypass '#' character
    [scanner scanHexInt:&resultIntValue];
    
    NSLog(@"HEADER VAL:%d", resultIntValue);
    
    return resultIntValue;
    
}

+(HpsDeviceMessage*)buildPATMessage:(NSString*)message{
    
    NSLog(@"PAT MESSAGE: %@", message);

    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    //Begin Message
    [buffer appendBytes:(char []){ HpsControlCodes_STX } length:1];
    
    // Add the Message
    [buffer appendData:[message dataUsingEncoding:NSISOLatin1StringEncoding]];
    
    //End Message
    [buffer appendBytes:(char []){ HpsControlCodes_ETX }  length:1];
        
    //Calc LRC
    Byte lrc = [self calcLRC:buffer];
    [buffer appendBytes:(char []){ lrc } length:sizeof(lrc)];
    
    NSString *bufferString = [[NSString alloc] initWithData:buffer encoding:NSISOLatin1StringEncoding];
    
    NSLog(@"PAT DATA: %@\n", [[buffer debugDescription] debugDescription]);
    NSLog(@"PAT STRING: %@", bufferString);
    
    //Return
    return [[HpsDeviceMessage alloc] initWithBuffer:buffer];
    
}


+ (HpsDeviceMessage *)GenerateKeepAliveResponse:(NSData *)keepAliveData{
    
    NSString *keepAliveString = [self stringFromData:keepAliveData];
    
    unsigned long tidCodeIndex = [keepAliveString rangeOfString:HPS_INGENICO_TID_CODE].location;
    NSString *tidCode = [keepAliveString substringWithRange:NSMakeRange(tidCodeIndex + 10, 8)];
    
    NSString *keepAliveResponse = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> <TID CODE=\"%@\">OK</TID>", tidCode];

    return [self BuildIngenicoRequest:keepAliveResponse];
    
}

+ (NSData*)dataFromHexString:(NSString*)hexString{
    
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};

    for (int i=0; i < [hexString length]/2; i++) {
        byte_chars[0] = [hexString characterAtIndex:i*2];
        byte_chars[1] = [hexString characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    
    return data;
}

+ (NSString *)stringFromData:(NSData *)data {
    
    NSMutableString *result = [NSMutableString string];
    const char *bytes = [data bytes];

    for (int i = 0; i < [data length]; i++) {
        [result appendFormat:@"%02hhx", (unsigned char)bytes[i]];
    }

    NSMutableString * str = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [result length])
    {
        NSString * hexChar = [result substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [str appendFormat:@"%c", (char)value];
        i+=2;
    }

    return str;
}

+ (NSString *)getString:(NSData *)data{
    return [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
}

+ (NSArray *)stringToArray:(NSString *)string{
    NSMutableArray *array = NSMutableArray.new;
    
    const char *charArray = [string UTF8String];
    int i = 0; int len = string.length;
    
    while (i < len){
        [array addObject:[NSString stringWithFormat:@"%c", charArray[i++]]];
    }
    
    return array;
}



@end
