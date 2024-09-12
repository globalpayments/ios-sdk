//
//  HpsIngenicoTerminalReportBuilder.m
//  IOS_SDK
//
//  Created by Macbook Air on 5/25/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoTerminalReportBuilder.h"
#import "HpsIngenicoDevice.h"
#import "HpsIngenicoRequestBuilder.h"

@implementation HpsIngenicoTerminalReportBuilder{
    ReportType reportType;
    ReceiptType receiptType;
    TransactionType transactionType;
}


-(ReceiptType)getReceiptType{ return receiptType; }
-(ReportType)getReportType{ return reportType; }
-(TransactionType)getTransactionType { return transactionType; }


-(HpsIngenicoTerminalReportBuilder*(^)(ReceiptType))withReceiptType{
    return ^HpsIngenicoTerminalReportBuilder *(ReceiptType value){
        self->receiptType = value;
        return self;
    };
}

-(HpsIngenicoTerminalReportBuilder*(^)(ReportType))withReportType{
    return ^HpsIngenicoTerminalReportBuilder *(ReportType value){
        self->reportType = value;
        return self;
    };
}

-(HpsIngenicoTerminalReportBuilder*(^)(TransactionType))withTransactionType{
    return ^HpsIngenicoTerminalReportBuilder *(TransactionType value){
        self->transactionType = value;
        return self;
    };
}


- (id)initWithDevice: (HpsIngenicoDevice*)HpsIngenicoDevice{
    self = [super init];
    if (self != nil){
        device = HpsIngenicoDevice;
    }
    return self;
}

- (void)execute:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock{
    
    @try {
        
        HpsDeviceMessage* requestData = [[HpsDeviceMessage alloc] init];
        
        if (transactionType == Create){
            requestData = [HpsIngenicoRequestBuilder buildReportRequest:self];
            
            [device send:requestData andResponseBlock:^(NSData * _Nonnull data, NSError * _Nonnull error) {
                
                HpsIngenicoTerminalReportResponse *response = [[HpsIngenicoTerminalReportResponse alloc] initWithBuffer:data];
                responseBlock(response,error);
                
            }];
            
        } else {
            requestData = [HpsIngenicoRequestBuilder buildReceiptRequest:self];
            
            [device send:requestData andResponseBlock:^(NSData * _Nonnull data, NSError * _Nonnull error) {
                
                HpsIngenicoTerminalReceiptResponse *response = [[HpsIngenicoTerminalReceiptResponse alloc] initWithBuffer:data];
                responseBlock(response,error);
                
            }];
        }
        
    } @catch (NSException *exception) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
        NSError *error = [NSError errorWithDomain:[device getErrorDomain]
                                             code:CocoaError
                                         userInfo:userInfo];
        responseBlock(nil,error);
    }
    
}


@end
