//
//  HpsIngenicoDevice.m
//  IOS_SDK_APP
//
//  Created by Macbook Air on 3/19/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import "HpsIngenicoDevice.h"

@implementation HpsIngenicoDevice

static id sharedInstance = nil;

+(id)sharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[HpsIngenicoDevice alloc] init];
    }
    return sharedInstance;
}

-(id)initWithConfig:(HpsConnectionConfig*)config {
    self.config = config;
    errorDomain = [HpsCommon sharedInstance].hpsErrorDomain;
        
    switch ((int)self.config.connectionMode) {

        case HpsConnectionModes_TCP_IP:
        {
            self.interface = [[HpsIngenicoTcpInterface alloc] initWithConfig:config];
            [self.interface connect];
        }
            break;
        case HpsConnectionModes_PAY_AT_TABLE:
        {
            self.interface = [[HpsIngenicoTcpInterface alloc] initWithConfig:config];
            [self.interface connect];
        }
            break;
        default:
            break;
    }
    return sharedInstance;
}

-(void)disconnect{
    [self.interface disconnect];
}

-(NSString *)getErrorDomain{
    return errorDomain;
}

-(void)send:(id<IHPSDeviceMessage>)data andResponseBlock:(void (^)(NSData *, NSError *))responseBlock{
    [self.interface send:data andResponseBlock:responseBlock];
}

//-(void) connectionStatusBlock:(void (^)(BOOL))isConnected{
//    [self.interface connectionStatusBlock:isConnected];
//}

-(void) onBroadcastMessageBlock:(void (^)(HpsIngenicoBroadcastMessage *, NSError *))broadcastMessageBlock{
    [self.interface broadcastMessageBlock:^(NSData * _Nonnull data, NSError * _Nonnull error) {
        broadcastMessageBlock([[HpsIngenicoBroadcastMessage alloc] initWithBuffer:data],error);
    }];
}

-(void) onMessageSentBlock:(void (^)(NSString *, NSError *))messageBlock{
    [self.interface onMessageSentBlock:^(NSString * _Nonnull message, NSError * _Nonnull error) {
        messageBlock(message,error);
    }];
}

-(void)onPayAtTableRequestBlock:(PayAtTableRequestBlock)payAtTableRequestBlock{
    [self.interface onPayAtTableRequestBlock:^(HpsIngenicoPATRequest * _Nonnull request, NSError * _Nonnull error) {
        payAtTableRequestBlock(request,error);
    }];
    
}

//Payment Transactions

-(HpsIngenicoTerminalAuthBuilder*)sale:(NSNumber*)amount{
    HpsIngenicoTerminalAuthBuilder *builder = [[HpsIngenicoTerminalAuthBuilder alloc] initWithDevice:self];
    builder.withAmount(amount).withTransactionType(Sale).withPaymentType(HpsIngenicoPaymentType_SALE);
    
    return builder;
}

-(HpsIngenicoTerminalAuthBuilder*)refund:(NSNumber*)amount{
    HpsIngenicoTerminalAuthBuilder *builder = [[HpsIngenicoTerminalAuthBuilder alloc] initWithDevice:self];
    builder.withAmount(amount).withTransactionType(Refund).withPaymentType(HpsIngenicoPaymentType_REFUND);
    
    return builder;
}

-(HpsIngenicoTerminalAuthBuilder*)authorize:(NSNumber*)amount{
    HpsIngenicoTerminalAuthBuilder *builder = [[HpsIngenicoTerminalAuthBuilder alloc] initWithDevice:self];
    builder.withAmount(amount).withTransactionType(Auth).withPaymentType(HpsIngenicoPaymentType_PREAUTH);
    
    return builder;
}

-(HpsIngenicoTerminalManageBuilder*)capture:(NSNumber*)amount{
    HpsIngenicoTerminalManageBuilder *builder = [[HpsIngenicoTerminalManageBuilder alloc] initWithDevice:self];
    builder.withAmount(amount).withTransactionType(Capture).withPaymentType(HpsIngenicoPaymentType_COMPLETION);
    
    return builder;
}

-(HpsIngenicoTerminalAuthBuilder*)verify{
    HpsIngenicoTerminalAuthBuilder *builder = [[HpsIngenicoTerminalAuthBuilder alloc] initWithDevice:self];
    builder.withAmount([NSNumber numberWithDouble:0.01]).withTransactionType(Verify).withPaymentType(HpsIngenicoPaymentType_ACCOUNT_VERIFICATION);
    
    return builder;
}


//Transaction Management

-(void)duplicate:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock{
    
    NSString *requestString = [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_REQUEST_MESSAGE, HPS_INGENICO_REQ_CMD_DUPLICATE];

    [self send:[HpsTerminalUtilities BuildIngenicoRequest:requestString] andResponseBlock:^(NSData * _Nullable data, NSError * _Nullable error) {

        @try {

            HpsIngenicoTerminalResponse *response = [[HpsIngenicoTerminalResponse alloc] initWithBuffer:data];
            responseBlock(response,error);

        } @catch (NSException *exception) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
            NSError *error = [NSError errorWithDomain:[self getErrorDomain]
                                                 code:CocoaError
                                             userInfo:userInfo];
            responseBlock(nil,error);
        }

    }];
}



-(void)cancel:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock{
    
    NSString *requestString = [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_REQUEST_MESSAGE, HPS_INGENICO_REQ_CMD_CANCEL];

    [self send:[HpsTerminalUtilities BuildIngenicoRequest:requestString] andResponseBlock:^(NSData * _Nullable data, NSError * _Nullable error) {

        @try {

            HpsIngenicoTerminalResponse *response = [[HpsIngenicoTerminalResponse alloc] initWithBuffer:data];
            responseBlock(response,error);

        } @catch (NSException *exception) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
            NSError *error = [NSError errorWithDomain:[self getErrorDomain]
                                                 code:CocoaError
                                             userInfo:userInfo];
            responseBlock(nil,error);
        }

    }];
}

-(HpsIngenicoTerminalManageBuilder*)reverse:(NSNumber*)Amount{
    HpsIngenicoTerminalManageBuilder *builder = [[HpsIngenicoTerminalManageBuilder alloc] initWithDevice:self];
    builder.withAmount(Amount).withTransactionType(Reversal);
    
    return builder;
}


//Report Management
-(HpsIngenicoTerminalReportBuilder*)getReport:(ReportType)type{
    HpsIngenicoTerminalReportBuilder *builder = [[HpsIngenicoTerminalReportBuilder alloc] initWithDevice:self];
    builder.withTransactionType(Create).withReportType(type);
    
    return builder;
}


//XML Management

-(HpsIngenicoTerminalReportBuilder*)getLastReceipt:(ReceiptType)type{
    HpsIngenicoTerminalReportBuilder *builder = [[HpsIngenicoTerminalReportBuilder alloc] initWithDevice:self];
    builder.withTransactionType(Fetch).withReceiptType(type);
    
    return builder;
}

//Pay@Table
-(HpsIngenicoTerminalAuthBuilder*)payAtTableResponse{
    HpsIngenicoTerminalAuthBuilder *builder = [[HpsIngenicoTerminalAuthBuilder alloc] initWithDevice:self];
    builder.withReferenceNumber([NSNumber numberWithInt:00]).withTransactionStatus(HPS_INGENICO_TRANSACTION_STATUS_SUCCESS).withCurrencyCode(@"826");
    
    return builder;
}


//TerminalManagement

- (void)getTerminalConfiguration:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock{

    NSString *requestString = [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_TERMINAL, TerminalCommandType_toString[HPS_INGENICO_CALL_TMS]];

    [self send:[HpsTerminalUtilities BuildIngenicoRequest:requestString] andResponseBlock:^(NSData * _Nullable data, NSError * _Nullable error) {

        @try {

            HpsIngenicoTerminalResponse *response = [[HpsIngenicoTerminalResponse alloc] initWithBuffer:data parseFormat:HPS_INGENICO_PARSE_FORMAT_TRANSACTION];
            responseBlock(response,error);

        } @catch (NSException *exception) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
            NSError *error = [NSError errorWithDomain:[self getErrorDomain]
                                                 code:CocoaError
                                             userInfo:userInfo];
            responseBlock(nil,error);
        }

    }];


}

- (void)testConnection:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock{
    
    NSString *requestString = [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_TERMINAL, TerminalCommandType_toString[HPS_INGENICO_LOGON]];

    [self send:[HpsTerminalUtilities BuildIngenicoRequest:requestString] andResponseBlock:^(NSData * _Nullable data, NSError * _Nullable error) {

        @try {

            HpsIngenicoTerminalResponse *response = [[HpsIngenicoTerminalResponse alloc] initWithBuffer:data];
            responseBlock(response,error);

        } @catch (NSException *exception) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
            NSError *error = [NSError errorWithDomain:[self getErrorDomain]
                                                 code:CocoaError
                                             userInfo:userInfo];
            responseBlock(nil,error);
        }

    }];
}

- (void)getTerminalStatus:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock{
    
    NSString *requestString = [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_TERMINAL, TerminalCommandType_toString[HPS_INGENICO_STATE]];

    [self send:[HpsTerminalUtilities BuildIngenicoRequest:requestString] andResponseBlock:^(NSData * _Nullable data, NSError * _Nullable error) {

        @try {

            HpsIngenicoTerminalStateResponse *response = [[HpsIngenicoTerminalStateResponse alloc] initWithBuffer:data];
            responseBlock(response,error);

        } @catch (NSException *exception) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
            NSError *error = [NSError errorWithDomain:[self getErrorDomain]
                                                 code:CocoaError
                                             userInfo:userInfo];
            responseBlock(nil,error);
        }

    }];
}

- (void)reboot:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock{
    NSString *requestString = [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_TERMINAL, TerminalCommandType_toString[HPS_INGENICO_RESET]];

    [self send:[HpsTerminalUtilities BuildIngenicoRequest:requestString] andResponseBlock:^(NSData * _Nullable data, NSError * _Nullable error) {

        @try {

            HpsIngenicoTerminalResponse *response = [[HpsIngenicoTerminalResponse alloc] initWithBuffer:data];
            responseBlock(response,error);

        } @catch (NSException *exception) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
            NSError *error = [NSError errorWithDomain:[self getErrorDomain]
                                                 code:CocoaError
                                             userInfo:userInfo];
            responseBlock(nil,error);
        }

    }];
}

- (void)initialize:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock{
    
    NSString *requestString = [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_TERMINAL, TerminalCommandType_toString[HPS_INGENICO_PID]];

    [self send:[HpsTerminalUtilities BuildIngenicoRequest:requestString] andResponseBlock:^(NSData * _Nullable data, NSError * _Nullable error) {

        @try {

            HpsIngenicoPOSIdentifierResponse *response = [[HpsIngenicoPOSIdentifierResponse alloc] initWithBuffer:data];
            responseBlock(response,error);

        } @catch (NSException *exception) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
            NSError *error = [NSError errorWithDomain:[self getErrorDomain]
                                                 code:CocoaError
                                             userInfo:userInfo];
            responseBlock(nil,error);
        }

    }];

}





@end
