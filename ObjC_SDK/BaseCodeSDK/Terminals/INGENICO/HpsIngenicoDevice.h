//
//  HpsIngenicoDevice.h
//  IOS_SDK_APP
//
//  Created by Macbook Air on 3/19/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsDeviceProtocols.h"
#import "HpsConnectionConfig.h"
#import "HpsIngenicoTcpInterface.h"
#import "HpsTerminalEnums.h"
#import "HpsCommon.h"
#import "HpsIngenicoTerminalAuthBuilder.h"
#import "HpsIngenicoTerminalManageBuilder.h"
#import "HpsIngenicoTerminalReportBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoDevice : NSObject{
    NSString *errorDomain;
}

@property (nonatomic, strong) HpsConnectionConfig *config;
@property (nonatomic, strong) HpsIngenicoTcpInterface *interface;

+(id)sharedInstance;
-(id)initWithConfig:(HpsConnectionConfig*)config;
-(void)disconnect;
-(NSString *)getErrorDomain;

-(void)send:(id<IHPSDeviceMessage>)data andResponseBlock:(void (^)(NSData *, NSError *))responseBlock;
-(void)onBroadcastMessageBlock:(void (^)(HpsIngenicoBroadcastMessage *, NSError *))broadcastMessageBlock;
-(void)onMessageSentBlock:(MessageBlock)messageBlock;
-(void)onPayAtTableRequestBlock:(PayAtTableRequestBlock)payAtTableRequestBlock;

//PaymentTransactions
-(HpsIngenicoTerminalAuthBuilder*)sale:(NSNumber*)amount;
-(HpsIngenicoTerminalAuthBuilder*)refund:(NSNumber*)amount;
-(HpsIngenicoTerminalAuthBuilder*)authorize:(NSNumber*)amount;
-(HpsIngenicoTerminalManageBuilder*)capture:(NSNumber*)amount;
-(HpsIngenicoTerminalAuthBuilder*)verify;
-(HpsIngenicoTerminalManageBuilder*)referralConfirmation;

//TransactionManagement
-(void)duplicate:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;
-(void)cancel:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;
-(HpsIngenicoTerminalManageBuilder*)reverse:(NSNumber*)Amount;


//Report Management
-(HpsIngenicoTerminalReportBuilder*)getReport:(ReportType)type;

//XML Management
-(HpsIngenicoTerminalReportBuilder*)getLastReceipt:(ReceiptType)type;

//Pay@Table
-(HpsIngenicoTerminalAuthBuilder*)payAtTableResponse;

//Terminal Management
- (void)getTerminalConfiguration:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;
- (void)testConnection:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;
- (void)getTerminalStatus:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;
- (void)reboot:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;
- (void)initialize:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;
@end

NS_ASSUME_NONNULL_END
