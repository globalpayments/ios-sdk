//
//  HpsIngenicoRequestBuilder.h
//  IOS_SDK_APP
//
//  Created by Macbook Air on 5/18/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsIngenicoTerminalAuthBuilder.h"
#import "HpsIngenicoTerminalManageBuilder.h"
#import "HpsIngenicoTerminalReportBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface HpsIngenicoRequestBuilder : NSObject


+(HpsDeviceMessage*)buildPaymentTransactionRequest:(HpsIngenicoTerminalAuthBuilder*)builder;
+(HpsDeviceMessage*)buildTransactionManagementRequest:(HpsIngenicoTerminalManageBuilder*)builder;
+(HpsDeviceMessage*)buildReportRequest:(HpsIngenicoTerminalReportBuilder*)builder;
+(HpsDeviceMessage*)buildReceiptRequest:(HpsIngenicoTerminalReportBuilder*)builder;
+(HpsDeviceMessage*)buildPATTResponseMessage:(HpsIngenicoTerminalAuthBuilder*)builder;

@end

NS_ASSUME_NONNULL_END
