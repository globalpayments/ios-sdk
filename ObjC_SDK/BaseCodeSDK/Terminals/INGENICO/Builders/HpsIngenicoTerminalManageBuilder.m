//
//  HpsIngenicoTerminalManageBuilder.m
//  IOS_SDK_APP
//
//  Created by Macbook Air on 5/18/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import "HpsIngenicoTerminalManageBuilder.h"
#import "HpsIngenicoDevice.h"
#import "HpsIngenicoRequestBuilder.h"

@implementation HpsIngenicoTerminalManageBuilder{
    NSNumber *referenceNumber;
    NSNumber *amount;
    NSString *authCode;
    NSNumber *gratuity;
    NSString *transactionId;
    NSString *currencyCode;
    PaymentMode paymentMode;
    PaymentType paymentType;
    TransactionType transactionType;
    TerminalCommandType terminalCommandType;
    ExtendedDataTags extendedDataTags;
}


-(NSNumber*)getReferenceNumber{ return referenceNumber; }
-(NSNumber*)getAmount{ return amount; }
-(NSString*)getAuthCode{ return authCode; }
-(NSNumber*)getGratuity{ return gratuity; }
-(NSString*)getTransactionId{ return transactionId; }
-(NSString*)getCurrencyCode{ return currencyCode; }
-(PaymentMode)getPaymentMode{ return paymentMode; }
-(PaymentType)getPaymentType{ return paymentType; }
-(TransactionType)getTransactionType{ return transactionType; }
-(TerminalCommandType)getTerminalCommandType{ return terminalCommandType; }
-(ExtendedDataTags)getExtendedDataTags{ return extendedDataTags; }



-(HpsIngenicoTerminalManageBuilder*(^)(NSNumber*))withReferenceNumber{
    return ^HpsIngenicoTerminalManageBuilder *(NSNumber* value){
        self->referenceNumber = value;
        return self;
    };
}

-(HpsIngenicoTerminalManageBuilder*(^)(NSNumber*))withAmount{
    return ^HpsIngenicoTerminalManageBuilder *(NSNumber* value){
        self->amount = value;
        return self;
    };
}

-(HpsIngenicoTerminalManageBuilder*(^)(NSString*))withAuthCode{
    return ^HpsIngenicoTerminalManageBuilder *(NSString* value){
        self->authCode = value;
        self->extendedDataTags = HPS_INGENICO_AUTHCODE;
        return self;
    };
}

-(HpsIngenicoTerminalManageBuilder*(^)(NSNumber*))withGratuity{
    return ^HpsIngenicoTerminalManageBuilder *(NSNumber* value){
        self->gratuity = value;
        return self;
    };
}

-(HpsIngenicoTerminalManageBuilder*(^)(NSString*))withTransactionId{
    return ^HpsIngenicoTerminalManageBuilder *(NSString* value){
        self->transactionId = value;
        return self;
    };
}

-(HpsIngenicoTerminalManageBuilder*(^)(NSString*))withCurrencyCode{
    return ^HpsIngenicoTerminalManageBuilder *(NSString* value){
        self->currencyCode = value;
        return self;
    };
}

-(HpsIngenicoTerminalManageBuilder*(^)(PaymentMode))withPaymentMode{
    return ^HpsIngenicoTerminalManageBuilder *(PaymentMode value){
        self->paymentMode = value;
        return self;
    };
}

-(HpsIngenicoTerminalManageBuilder*(^)(PaymentType))withPaymentType{
    return ^HpsIngenicoTerminalManageBuilder *(PaymentType value){
        self->paymentType = value;
        return self;
    };
}

-(HpsIngenicoTerminalManageBuilder*(^)(TransactionType))withTransactionType{
    return ^HpsIngenicoTerminalManageBuilder *(TransactionType value){
        self->transactionType = value;
        return self;
    };
}

-(HpsIngenicoTerminalManageBuilder*(^)(TerminalCommandType))withTerminalCommandType{
    return ^HpsIngenicoTerminalManageBuilder *(TerminalCommandType value){
        self->terminalCommandType = value;
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
        requestData = [HpsIngenicoRequestBuilder buildTransactionManagementRequest:self];
        
        [device send:requestData andResponseBlock:^(NSData * _Nonnull data, NSError * _Nonnull error) {
            
            HpsIngenicoTerminalResponse *response = [[HpsIngenicoTerminalResponse alloc] initWithBuffer:data];
            responseBlock(response,error);
            
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
