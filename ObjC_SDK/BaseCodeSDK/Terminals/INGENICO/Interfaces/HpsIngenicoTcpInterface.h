//
//  HpsIngenicoTcpInterface.h
//  IOS_SDK_APP
//
//  Created by Macbook Air on 3/20/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsDeviceProtocols.h"
#import "HpsConnectionConfig.h"
#import "HpsCommon.h"
#import "HpsIngenicoEnums.h"
#import "HpsTerminalUtilities.h"
#import "HpsTerminalEnums.h"
#import "HpsIngenicoPATRequest.h"
#import "HpsIngenicoPATTransactionOutcome.h"
#include <sys/socket.h>
#include <netinet/in.h>

NS_ASSUME_NONNULL_BEGIN


@class ServerThread;

typedef void (^ResponseBlock)(NSData* _Nullable, NSError* _Nullable);
typedef void (^BroadcastMessageBlock)(NSData* _Nullable, NSError* _Nullable);
typedef void (^MessageBlock)(NSString* _Nullable, NSError* _Nullable);
typedef void (^PayAtTableRequestBlock)(HpsIngenicoPATRequest* _Nullable, NSError* _Nullable);
typedef void (^ConnectionStatusBlock)(BOOL);

@interface HpsIngenicoTcpInterface : NSObject<IHPSDeviceCommInterface>{
    ServerThread *server;
}

@property (nonatomic, strong) HpsConnectionConfig *config;

- (instancetype) initWithConfig:(HpsConnectionConfig*)config;
-(void)connect;
-(void)disconnect;
-(void)send:(id<IHPSDeviceMessage>)message andResponseBlock:(ResponseBlock)responseBlock;
-(void)broadcastMessageBlock:(BroadcastMessageBlock)broadcastMessageBlock;
-(void)onMessageSentBlock:(MessageBlock)messageBlock;
-(void)onPayAtTableRequestBlock:(PayAtTableRequestBlock)payAtTableRequestBlock;

@end


@interface ServerThread : NSThread {
    CFSocketRef obj_server;
}


-(void)initWithConfig:(HpsConnectionConfig*)config;
-(void)disconnect;
-(void)send:(id<IHPSDeviceMessage>)data andResponseBlock:(ResponseBlock)responseBlock;
-(void)broadcastMessageBlock:(BroadcastMessageBlock)broadcastMessageBlock;
-(void)onMessageSentBlock:(MessageBlock)messageBlock;
-(void)onPayAtTableRequestBlock:(PayAtTableRequestBlock)payAtTableRequestBlock;
-(void)connectionStatusBlock:(ConnectionStatusBlock)isConnected;

@end


@interface ClientHandler : NSThread<NSStreamDelegate> {
    @public
    CFReadStreamRef rd_stream;
    CFWriteStreamRef wt_stream;
    NSMutableData* outputBuffer;
    NSMutableData* inputBuffer;
    
    @private
    __strong NSInputStream *input;
    __strong NSOutputStream *output;
    NSUInteger cur_offset;
    NSMutableArray *m_write_arr;
    HpsConnectionConfig* config;
}

-(void)disconnect;
-(void)initWithConfig:(HpsConnectionConfig*)config;
-(void)send:(id<IHPSDeviceMessage>)data andResponseBlock:(ResponseBlock)responseBlock;
-(void)broadcastMessageBlock:(BroadcastMessageBlock)broadcastMessageBlock;
-(void)onMessageSentBlock:(MessageBlock)messageBlock;
-(void)onPayAtTableRequestBlock:(PayAtTableRequestBlock)payAtTableRequestBlock;

@end


NS_ASSUME_NONNULL_END


