//
//  HpsIngenicoTerminalAuthBuilder.h
//  IOS_SDK_APP
//
//  Created by Macbook Air on 3/19/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HpsDeviceProtocols.h"
#import "HpsTerminalUtilities.h"
#import "HpsIngenicoDeviceResponse.h"
#import "HpsIngenicoEnums.h"
#import "HpsDeviceProtocols.h"


NS_ASSUME_NONNULL_BEGIN

@class HpsIngenicoDevice;
@interface HpsIngenicoTerminalAuthBuilder : NSObject {
    HpsIngenicoDevice *device;
}

@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withReferenceNumber)(NSNumber *referenceNumber);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withCashback)(NSNumber *amount);

@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withGratuity)(NSNumber *gratuity);

@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withCurrencyCode)(NSString *currencyCode);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withTableNumber)(NSString *tableNumber);

@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withPaymentMode)(PaymentMode paymentMode);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withPaymentType)(PaymentType paymentType);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withTransactionType)(TransactionType transactionType);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withTransactionStatus)(TransactionStatus transactionStatus);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withTaxFreeType)(TaxFreeType taxFreeType);

//Pay@Table
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withAmount)(NSNumber *amount);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withPATResponseType)(PATResponseType patResponseType);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withPATPaymentMode)(PATPaymentMode patPaymentMode);
@property (readonly, nonatomic, copy) HpsIngenicoTerminalAuthBuilder* (^withXmlPath)(NSString *xmlPath);

-(NSNumber*)getReferenceNumber;
-(NSNumber*)getAmount;
-(NSNumber*)getCashBackAmount;
-(NSNumber*)getGratuity;
-(NSString*)getCurrencyCode;
-(NSString*)getTableNumber;
-(PaymentMode)getPaymentMode;
-(PaymentType)getPaymentType;
-(TransactionType)getTransactionType;
-(TransactionStatus)getTransactionStatus;
-(TaxFreeType)getTaxFreeType;
-(ExtendedDataTags)getExtendedDataTags;
-(PATResponseType)getPATResponseType;
-(PATPaymentMode)getPATPaymentMode;
-(NSString*)getXmlPath;


- (id)initWithDevice: (HpsIngenicoDevice*)HpsIngenicoDevice;
- (void)execute:(void (^)(id<IHPSDeviceResponse>, NSError *))responseBlock;



@end

NS_ASSUME_NONNULL_END
