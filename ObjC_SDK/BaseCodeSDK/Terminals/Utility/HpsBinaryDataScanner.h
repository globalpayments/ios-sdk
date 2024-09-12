#import <Foundation/Foundation.h>

@interface HpsBinaryDataScanner : NSObject{
    BOOL littleEndian;
    NSStringEncoding encoding;
    NSData *data;
    const uint8_t *current;
    NSUInteger scanRemain;
}

+(id)binaryDataScannerWithData:(NSData*)data littleEndian:(BOOL)littleEndian defaultEncoding:(NSStringEncoding)defaultEncoding;

-(NSUInteger) remainingBytes;
-(const uint8_t *) currentPointer;

-(void) skipBytes:(NSUInteger)count;
-(uint8_t) readByte;
-(uint16_t) readWord;
-(uint32_t) readDoubleWord;
-(NSString*) readNullTerminatedString;
-(NSString*) readNullTerminatedStringWithEncoding:(NSStringEncoding)overrideEncoding;
-(NSString*) readStringUntilDelimiter:(uint8_t)delim;
-(NSString*) readStringUntilDelimiter:(uint8_t)delim encoding:(NSStringEncoding)overrideEncoding;
-(NSString*) readStringOfLength:(NSUInteger)count handleNullTerminatorAfter:(BOOL)handleNull;
-(NSString*) readStringOfLength:(NSUInteger)count handleNullTerminatorAfter:(BOOL)handleNull encoding:(NSStringEncoding)overrideEncoding;
-(NSArray*) readArrayOfNullTerminatedStrings:(NSUInteger)count;
-(NSArray*) readArrayOfNullTerminatedStrings:(NSUInteger)count encoding:(NSStringEncoding)overrideEncoding;

@end
