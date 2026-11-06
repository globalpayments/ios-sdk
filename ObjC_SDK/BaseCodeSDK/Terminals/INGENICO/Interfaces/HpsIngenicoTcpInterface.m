//
//  HpsIngenicoTcpInterface.m
//  IOS_SDK_APP
//
//  Created by Macbook Air on 3/20/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import "HpsIngenicoTcpInterface.h"
#include <unistd.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@interface HpsIngenicoTcpInterface () {
    NSString *errorDomain;

}

@end

@implementation HpsIngenicoTcpInterface

ConnectionStatusBlock connectionStatusBlock;
BOOL isConnected;

- (instancetype) initWithConfig:(HpsConnectionConfig*)config{
    if((self = [super init])){
        _config = config;
        errorDomain = [HpsCommon sharedInstance].hpsErrorDomain;
        server = NULL;

    }
    return self;
}

- (void)connect {
    
    if (server != NULL){
        [self disconnect];
        server = NULL;
    }
    
    server = ServerThread.new;
    [server initWithConfig:_config];

    [server start];
    
    isConnected = NO;
    
    [server connectionStatusBlock:^(BOOL connected) {
        if (connected){
            isConnected = YES;
        }
    }];
    
    while(!isConnected){ [NSThread sleepForTimeInterval:.001]; }
    
}

- (void)disconnect {
    [server disconnect];
}

-(void) send:(id<IHPSDeviceMessage>)message andResponseBlock:(ResponseBlock)responseBlock; {
    [server send:message andResponseBlock:responseBlock];
}

-(void) broadcastMessageBlock:(BroadcastMessageBlock)broadcastMessageBlock{
    [server broadcastMessageBlock:broadcastMessageBlock];
}

-(void) onMessageSentBlock:(MessageBlock)messageBlock{
    [server onMessageSentBlock:messageBlock];
}

-(void) onPayAtTableRequestBlock:(PayAtTableRequestBlock)payAtTableRequestBlock{
    [server onPayAtTableRequestBlock:payAtTableRequestBlock];
}

@end


@implementation ServerThread

HpsConnectionConfig* configuration;
ClientHandler *obj_client;
MessageBlock messageSentBlock;


-(void)initWithConfig:(HpsConnectionConfig*)config{
    
    configuration = config;

    CFSocketContext ctx = {0,(__bridge void *)(self),NULL,NULL,NULL};
    obj_server = CFSocketCreate(kCFAllocatorDefault, AF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, TCPServerCallBackHandler, &ctx);
    
    int so_reuse_flag = 1;
    setsockopt(CFSocketGetNative(obj_server), SOL_SOCKET, SO_REUSEADDR, &so_reuse_flag, sizeof(so_reuse_flag));
    setsockopt(CFSocketGetNative(obj_server), SOL_SOCKET, SO_REUSEPORT, &so_reuse_flag, sizeof(so_reuse_flag));

    struct sockaddr_in sock_addr;
    memset(&sock_addr,0,sizeof(sock_addr));
    sock_addr.sin_len = sizeof(sock_addr);
    sock_addr.sin_family = AF_INET; /* Address family */
    sock_addr.sin_port = htons([config.port intValue]); /* Or a specific port */
    sock_addr.sin_addr.s_addr= INADDR_ANY;

    CFDataRef dref = CFDataCreate(
        kCFAllocatorDefault,
        (UInt8 *)&sock_addr,
        sizeof(sock_addr));

    CFSocketError socketErr = CFSocketSetAddress(obj_server, dref);
    switch (socketErr) {
        case kCFSocketSuccess:
            NSLog(@"Success.");
            break;
        case kCFSocketError:
            NSLog(@"Error.");
            break;
        case kCFSocketTimeout:
            NSLog(@"Timeout.");
            break;
    }

    CFRelease(dref);

}

-(void)main{

    CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(
        kCFAllocatorDefault,
        obj_server,
        0);
    CFRunLoopAddSource(
        CFRunLoopGetCurrent(),
        socketsource,
        kCFRunLoopDefaultMode);
    CFRelease(socketsource);
    NSLog(@"Server listening");

    CFRunLoopRun();

}

-(void)disconnect{

    [obj_client disconnect];
    
    if (obj_server != nil){
        if(CFSocketIsValid(obj_server)){
            CFSocketInvalidate(obj_server);
            CFRelease(obj_server);
        }
    }
    
    obj_server = nil;

    CFRunLoopStop(CFRunLoopGetCurrent());

    [self cancel];
}

-(void)send:(id<IHPSDeviceMessage>)data andResponseBlock:(ResponseBlock)responseBlock{
    [obj_client send:data andResponseBlock:responseBlock];
}

-(void)connectionStatusBlock:(void (^)(BOOL))isConnected{
    connectionStatusBlock = isConnected;
}

-(void)broadcastMessageBlock:(BroadcastMessageBlock)broadcastMessageBlock{
    [obj_client broadcastMessageBlock:broadcastMessageBlock];
}

-(void) onMessageSentBlock:(MessageBlock)messageBlock{
    [obj_client onMessageSentBlock:messageBlock];
    messageSentBlock = messageBlock;
}

-(void) onPayAtTableRequestBlock:(PayAtTableRequestBlock)responseBlock{
    [obj_client onPayAtTableRequestBlock:responseBlock];
}


void TCPServerCallBackHandler(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info){

    switch (type) {
        case kCFSocketAcceptCallBack:
        {

            connectionStatusBlock(YES);
            
            NSError *error;
            error = nil;

            obj_client = [[ClientHandler alloc] init];
            [obj_client initWithConfig:configuration];
            CFStreamCreatePairWithSocket(kCFAllocatorDefault, *(CFSocketNativeHandle* )data, &obj_client->rd_stream, &obj_client->wt_stream);
            CFReadStreamSetProperty(obj_client->rd_stream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
            CFWriteStreamSetProperty(obj_client->wt_stream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
     
            [obj_client start];
            break;
        }
        
        default:
            break;
    }

}

@end



@implementation ClientHandler

ResponseBlock responseDataBlock;
BroadcastMessageBlock onBroadcastMessageBlock;
PayAtTableRequestBlock onPayAtTableRequestBlock;
MessageBlock messageSentBlock;

//Variables for timeout
BOOL terminalResponded = false;
BOOL isTransactionOngoing = false;
NSTimer *timeoutTimer = nil;

-(void)initWithConfig:(HpsConnectionConfig*)config{
    self->config = config;
}

-(void)main {

    terminalResponded = false;
    isTransactionOngoing = false;
    
    cur_offset = 0;
    m_write_arr = [[NSMutableArray alloc]init];
    inputBuffer = [[NSMutableData alloc] init];
    outputBuffer = [[NSMutableData alloc] init];
    input = (__bridge NSInputStream *)(rd_stream);
    output = (__bridge NSOutputStream *)(wt_stream);

    [input setDelegate:self];
    [output setDelegate:self];

    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [input open];
    [output open];

    @try {
       CFRunLoopRun();
    }
    @catch (NSException *exception) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
        NSError *error = [NSError errorWithDomain:[HpsCommon sharedInstance].hpsErrorDomain
                                             code:CocoaError
                                         userInfo:userInfo];
        
        messageSentBlock([exception description],error);
    }
    
}

-(void)disconnect{

    input.delegate = nil;
    [input removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [input close];
    
    input = nil;

    output.delegate = nil;
    [output removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [output close];
    output = nil;

    inputBuffer = nil;
    outputBuffer = nil;

    CFReadStreamClose(rd_stream);
    CFWriteStreamClose(wt_stream);
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(returnTimeoutMessage) object: self];
    [self cancel];
    
    [self invalidateTimer];

}

-(void)send:(id<IHPSDeviceMessage>)data andResponseBlock:(ResponseBlock)responseBlock{

    responseDataBlock = responseBlock;

    NSError *error;
    error = nil;
    
    NSString *message = [HpsTerminalUtilities stringFromData:[data getSendBuffer]];
    NSString *rawRequest =  [NSString stringWithFormat: @"%@", [message substringWithRange:NSMakeRange(1, [message length]-1)]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (messageSentBlock){
            messageSentBlock([NSString stringWithFormat:@"Raw Request:%@", rawRequest],error);
        }
    });
    
    isTransactionOngoing = true;
    terminalResponded = false;

    [outputBuffer appendBytes:[data getSendBuffer].bytes length:[data getSendBuffer].length];
    [self writeOutputBufferToStream];

}

- (void)writeOutputBufferToStream {
    
    if ([outputBuffer length] == 0){
        return;
    }

    if (![output hasSpaceAvailable]){
        return;
    }

    NSInteger bytesWritten = [output write:[outputBuffer bytes]
                                       maxLength:[outputBuffer length]];
    
    if (bytesWritten == -1)  {
        return;
    }
    
    if (isTransactionOngoing && config.timeout > 0){
        
        NSInteger timeout = config.timeout;
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(returnTimeoutMessage) userInfo:nil repeats:NO];
    }

    [outputBuffer replaceBytesInRange:NSMakeRange(0, bytesWritten)
                            withBytes:NULL
                               length:0];
}

-(void)readFromInputBuffer{
    
    @try {
        if ([input hasBytesAvailable]){
            
            if (config.connectionMode == HpsConnectionModes_PAY_AT_TABLE) {
                
                //int headerLength = [HpsTerminalUtilities HeaderLength:inputBuffer];
                
                uint8_t buffer[1];
                NSMutableData* dataBuffer = [[NSMutableData alloc] init];
                
                while ([input hasBytesAvailable]) {
                    NSInteger bytesRead = [input read:buffer maxLength:sizeof(buffer)];
                    
                    if (*buffer == HpsControlCodes_ETX){
                        break;
                    }
                    
                    if (*buffer != HpsControlCodes_STX){
                        [dataBuffer appendBytes:buffer length:bytesRead];
                    } 
                    
                }
                
                NSString *bufferString = [[NSString alloc] initWithData:dataBuffer encoding:NSISOLatin1StringEncoding];
                
                NSError *error;
                error = nil;
                
                HpsIngenicoPATRequest *request = [[HpsIngenicoPATRequest alloc] initWithBuffer:dataBuffer];
                
                if (onPayAtTableRequestBlock){
                    onPayAtTableRequestBlock(request, error);
                }
                
            } else {
                
                if (isTransactionOngoing && config.timeout > 0){
                    
                    [self invalidateTimer];
                    
                    NSInteger timeout = config.timeout;
                    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(returnTimeoutMessage) userInfo:nil repeats:NO];
                }
                
                uint8_t headerBuffer[2];
                NSInteger bytesRead = [input read:headerBuffer maxLength:sizeof(headerBuffer)];
                [inputBuffer appendBytes:headerBuffer length:bytesRead];
                
                //int headerLength = [HpsTerminalUtilities HeaderLength:inputBuffer];
                
                uint8_t buffer[10];
                NSMutableData* dataBuffer = [[NSMutableData alloc] init];
                
                while ([input hasBytesAvailable]) {
                    NSInteger bytesRead = [input read:buffer maxLength:sizeof(buffer)];
                    [dataBuffer appendBytes:buffer length:bytesRead];
                }
                
                if ([self isBroadcast:dataBuffer]){
                    NSError *error;
                    error = nil;
                    
                    if(onBroadcastMessageBlock){
                        onBroadcastMessageBlock(dataBuffer,error);
                    }
                    
                } else if ([self isKeepAlive:dataBuffer]){
                    NSError *error;
                    error = nil;
                    
                    [self send:[HpsTerminalUtilities GenerateKeepAliveResponse:dataBuffer] andResponseBlock:^(NSData * _Nullable response, NSError * _Nullable error) {
                        
                    }];
                } else {
                    NSError *error;
                    error = nil;
                    
                    if ([dataBuffer length] > 0 && !terminalResponded){
                        
                        terminalResponded = true;
                        isTransactionOngoing = false;
                        
                        [self invalidateTimer];
                        
                        if (responseDataBlock){
                            responseDataBlock(dataBuffer,error);
                        }
                        
                    } else {
                        
                        if (messageSentBlock && !terminalResponded){
                            terminalResponded = true;
                            isTransactionOngoing = false;
                            
                            [self invalidateTimer];
                            
                            messageSentBlock(@"Server Error", error);
                        }
                        
                    }
                    
                }
                
            }
            
            [inputBuffer replaceBytesInRange:NSMakeRange(0,inputBuffer.length)
                         withBytes:NULL
                         length:0];

            
        }
    }
    @catch (NSException *exception) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
        NSError *error = [NSError errorWithDomain:[HpsCommon sharedInstance].hpsErrorDomain
                                             code:CocoaError
                                         userInfo:userInfo];
        
        messageSentBlock([exception description],error);
    }
    
}


-(void)broadcastMessageBlock:(BroadcastMessageBlock)broadcastMessageBlock{
    onBroadcastMessageBlock = broadcastMessageBlock;
}

-(void)onMessageSentBlock:(MessageBlock)messageBlock{
    messageSentBlock = messageBlock;
}

-(void) onPayAtTableRequestBlock:(PayAtTableRequestBlock)payAtTableRequestBlock{
    onPayAtTableRequestBlock = payAtTableRequestBlock;
}

-(BOOL)isBroadcast:(NSData*)dataBuffer{
    NSString *response = [[NSString alloc] initWithString:[HpsTerminalUtilities stringFromData:dataBuffer]];
    return ([response rangeOfString:HpsIngenico_BROADCAST].location != NSNotFound);
}

-(BOOL)isKeepAlive:(NSData*)dataBuffer{
    NSString *response = [[NSString alloc] initWithString:[HpsTerminalUtilities stringFromData:dataBuffer]];
    return ([response rangeOfString:HPS_INGENICO_TID_CODE].location != NSNotFound);
}


-(void)returnTimeoutMessage{
    if (!terminalResponded){
        
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Server Timeout"};
        NSError *error = [NSError errorWithDomain:[HpsCommon sharedInstance].hpsErrorDomain
                                             code:CocoaError
                                         userInfo:userInfo];
        
        terminalResponded = true;
        isTransactionOngoing = false;
        
        if (responseDataBlock){
            responseDataBlock(nil,error);
        }
        
        [self invalidateTimer];
            
        //messageSentBlock(@"Server Timeout",nil);
    }
}

-(void)invalidateTimer{
    [timeoutTimer invalidate];
    timeoutTimer = nil;
}




-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {

    switch (eventCode) {

        case NSStreamEventOpenCompleted:
        {

        }
            break;

        case NSStreamEventHasBytesAvailable:
        {
            @try {
                [self readFromInputBuffer];
            }
            @catch (NSException *exception) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
                NSError *error = [NSError errorWithDomain:[HpsCommon sharedInstance].hpsErrorDomain
                                                     code:CocoaError
                                                 userInfo:userInfo];

                messageSentBlock([exception description],error);
            }
        }
            break;

        case NSStreamEventHasSpaceAvailable:
        {
            [self writeOutputBufferToStream];
        }
            break;

        case NSStreamEventErrorOccurred:
        {
            NSError *err = [aStream streamError];
            NSLog(@"%li : %@", (long)[err code], [err localizedDescription]);
        }
            break;
        case NSStreamEventEndEncountered:
        {
            NSLog(@"Stream end");
            [self invalidateTimer];
            NSError *error;
            error = nil;
            
            if (messageSentBlock){
                messageSentBlock(@"Server Error: Terminal Disconnected", error);
            }
        }
            break;
        default:
            NSLog(@"Unprocessed Event %lu", (unsigned long) eventCode);
            break;
    }


}


@end


