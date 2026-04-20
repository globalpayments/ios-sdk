//
//  HpsIngenicoTerminalReportBuilder.h
//  IOS_SDK
//
//  Created by Macbook Air on 5/25/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsDeviceProtocols.h"
#import "HpsTerminalUtilities.h"
#import "HpsIngenicoDeviceResponse.h"
#import "HpsDeviceProtocols.h"
#import "HpsIngenicoEnums.h"

NS_ASSUME_NONNULL_BEGIN

@class HpsIngenicoDevice;
@interface HpsIngenicoTerminalReportBuilder : NSObject{
    HpsIngenicoDevice *device;
}

@property (readonly, nonatomic, copy) HpsIngenicoTerminalReportBuilder* (^withTransactionType)(TransactionType transactionType);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalReportBuilder* (^withReportType)(ReportType reportType);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalReportBuilder* (^withReceiptType)(ReceiptType receiptType);

-(TransactionType)getTransactionType;
-(ReceiptType)getReceiptType;
-(ReportType)getReportType;

- (id)initWithDevice: (HpsIngenicoDevice*)HpsIngenicoDevice;
- (void)execute:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;



@end

NS_ASSUME_NONNULL_END
