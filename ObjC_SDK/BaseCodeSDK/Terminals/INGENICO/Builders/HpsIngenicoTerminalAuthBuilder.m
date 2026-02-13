//
//  HpsIngenicoTerminalAuthBuilder.m
//  IOS_SDK_APP
//
//  Created by Macbook Air on 3/19/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import "HpsIngenicoTerminalAuthBuilder.h"
#import "HpsIngenicoDevice.h"
#import "HpsIngenicoRequestBuilder.h"

@implementation HpsIngenicoTerminalAuthBuilder{
    NSNumber *referenceNumber;
    NSNumber *amount;
    NSString *authCode;
    NSNumber *cashBackAmount;
    NSNumber *gratuity;
    NSString *currencyCode;
    NSString *tableNumber;
    PaymentMode paymentMode;
    PaymentType paymentType;
    TransactionType transactionType;
    TransactionStatus transactionStatus;
    TaxFreeType taxFreeType;
    ExtendedDataTags extendedDataTags;
    PATResponseType patResponseType;
    PATPaymentMode patPaymentMode;
    NSString *xmlPath;
    
}


-(NSNumber*)getReferenceNumber{ return referenceNumber; }
-(NSNumber*)getAmount{ return amount; }
-(NSString*)getAuthCode{ return authCode; }
-(NSNumber*)getCashBackAmount{ return cashBackAmount; }
-(NSNumber*)getGratuity{ return gratuity; }
-(NSString*)getCurrencyCode{ return currencyCode; }
-(NSString*)getTableNumber{ return tableNumber; }
-(PaymentMode)getPaymentMode{ return paymentMode; }
-(PaymentType)getPaymentType{ return paymentType; }
-(TransactionType)getTransactionType { return transactionType; }
-(TransactionStatus)getTransactionStatus { return transactionStatus; }
-(TaxFreeType)getTaxFreeType { return taxFreeType; }
-(ExtendedDataTags)getExtendedDataTags{ return extendedDataTags; }
-(PATResponseType)getPATResponseType{ return patResponseType; }
-(PATPaymentMode)getPATPaymentMode{ return patPaymentMode; }
-(NSString*)getXmlPath{ return xmlPath; }


-(HpsIngenicoTerminalAuthBuilder*(^)(NSNumber*))withReferenceNumber{
    return ^HpsIngenicoTerminalAuthBuilder *(NSNumber* value){
        self->referenceNumber = value;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(NSNumber*))withAmount{
    return ^HpsIngenicoTerminalAuthBuilder *(NSNumber* value){
        self->amount = value;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(NSString*))withAuthCode{
    return ^HpsIngenicoTerminalAuthBuilder *(NSString* value){
        self->authCode = value;
        self->extendedDataTags = HPS_INGENICO_AUTHCODE;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(NSNumber*))withCashback{
    return ^HpsIngenicoTerminalAuthBuilder *(NSNumber* value){
        self->cashBackAmount = value;
        self->extendedDataTags = HPS_INGENICO_CASHB;
        return self;
    };
}


-(HpsIngenicoTerminalAuthBuilder*(^)(NSNumber*))withGratuity{
    return ^HpsIngenicoTerminalAuthBuilder *(NSNumber* value){
        self->gratuity = value;
        return self;
    };
}


-(HpsIngenicoTerminalAuthBuilder*(^)(NSString*))withCurrencyCode{
    return ^HpsIngenicoTerminalAuthBuilder *(NSString* value){
        self->currencyCode = value;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(NSString*))withTableNumber{
    return ^HpsIngenicoTerminalAuthBuilder *(NSString* value){
        self->tableNumber = value;
        self->extendedDataTags = HPS_INGENICO_TABLE_NUMBER;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(PaymentMode))withPaymentMode{
    return ^HpsIngenicoTerminalAuthBuilder *(PaymentMode value){
        self->paymentMode = value;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(PaymentType))withPaymentType{
    return ^HpsIngenicoTerminalAuthBuilder *(PaymentType value){
        self->paymentType = value;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(TransactionType))withTransactionType{
    return ^HpsIngenicoTerminalAuthBuilder *(TransactionType value){
        self->transactionType = value;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(TransactionStatus))withTransactionStatus{
    return ^HpsIngenicoTerminalAuthBuilder *(TransactionStatus value){
        self->transactionStatus = value;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(TaxFreeType))withTaxFreeType{
    return ^HpsIngenicoTerminalAuthBuilder *(TaxFreeType value){
        self->taxFreeType = value;
        return self;
    };
}


-(HpsIngenicoTerminalAuthBuilder*(^)(PATResponseType))withPATResponseType{
    return ^HpsIngenicoTerminalAuthBuilder *(PATResponseType value){
        self->patResponseType = value;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(PATPaymentMode))withPATPaymentMode{
    return ^HpsIngenicoTerminalAuthBuilder *(PATPaymentMode value){
        self->patPaymentMode = value;
        return self;
    };
}

-(HpsIngenicoTerminalAuthBuilder*(^)(NSString*))withXmlPath{
    return ^HpsIngenicoTerminalAuthBuilder *(NSString* value){
        self->xmlPath = value;
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
        
        if(device.config.connectionMode == HpsConnectionModes_PAY_AT_TABLE){
            requestData = [HpsIngenicoRequestBuilder buildPATTResponseMessage:self];
        } else {
            requestData = [HpsIngenicoRequestBuilder buildPaymentTransactionRequest:self];
        }
        
        [device send:requestData andResponseBlock:^(NSData * _Nullable data, NSError * _Nonnull error) {
            @try {
                if(self->device.config.connectionMode != HpsConnectionModes_PAY_AT_TABLE){
                    HpsIngenicoTerminalResponse *response = [[HpsIngenicoTerminalResponse alloc] initWithBuffer:data];
                    responseBlock(response,error);
                }
            } @catch (NSException *exception) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
                NSError *error = [NSError errorWithDomain:[self->device getErrorDomain]
                                                     code:CocoaError
                                                 userInfo:userInfo];
                responseBlock(nil,error);
            }
        }];
        
    } @catch (NSException *exception) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
        NSError *error = [NSError errorWithDomain:[device getErrorDomain]
                                             code:CocoaError
                                         userInfo:userInfo];
        responseBlock(nil,error);
    }
    
}



@end
