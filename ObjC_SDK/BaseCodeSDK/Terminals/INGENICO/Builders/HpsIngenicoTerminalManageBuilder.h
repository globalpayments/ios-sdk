//
//  HpsIngenicoTerminalManageBuilder.h
//  IOS_SDK_APP
//
//  Created by Macbook Air on 5/18/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsDeviceProtocols.h"
#import "HpsTerminalUtilities.h"
#import "HpsIngenicoDeviceResponse.h"
#import "HpsIngenicoEnums.h"

NS_ASSUME_NONNULL_BEGIN


@class HpsIngenicoDevice;
@interface HpsIngenicoTerminalManageBuilder : NSObject{
    HpsIngenicoDevice *device;
}

@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withReferenceNumber)(NSNumber *referenceNumber);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withAmount)(NSNumber *amount);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withAuthCode)(NSString *authCode);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withCurrencyCode)(NSString *currencyCode);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withGratuity)(NSNumber *gratuity);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withTransactionId)(NSString *transactionId);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withPaymentMode)(PaymentMode paymentMode);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withPaymentType)(PaymentType paymentType);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withTransactionType)(TransactionType transactionType);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalManageBuilder* (^withTerminalCommandType)(TerminalCommandType terminalCommandType);


-(NSNumber*)getReferenceNumber;
-(NSNumber*)getAmount;
-(NSString*)getAuthCode;
-(NSNumber*)getGratuity;
-(NSString*)getTransactionId;
-(NSString*)getCurrencyCode;
-(PaymentMode)getPaymentMode;
-(PaymentType)getPaymentType;
-(PaymentMethodType)getPaymentMethod;
-(TransactionType)getTransactionType;
-(TerminalCommandType)getTerminalCommandType;
-(ExtendedDataTags)getExtendedDataTags;


- (id)initWithDevice: (HpsIngenicoDevice*)HpsIngenicoDevice;
- (void)execute:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;


@end

NS_ASSUME_NONNULL_END
