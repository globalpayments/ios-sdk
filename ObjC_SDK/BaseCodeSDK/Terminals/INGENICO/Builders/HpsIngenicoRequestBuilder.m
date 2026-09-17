//
//  HpsIngenicoRequestBuilder.m
//  IOS_SDK_APP
//
//  Created by Macbook Air on 5/18/20.
//  Copyright © 2020 igen. All rights reserved.
//

#import "HpsIngenicoRequestBuilder.h"

@implementation HpsIngenicoRequestBuilder

+(HpsDeviceMessage*)buildReceiptRequest:(HpsIngenicoTerminalReportBuilder*)builder{
    
    NSString *requestString = @"";
    
    requestString = [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_RECEIPT, ReceiptType_toString[builder.getReceiptType]];
    
    return [HpsTerminalUtilities BuildIngenicoRequest:requestString];
    
}

+(HpsDeviceMessage*)buildReportRequest:(HpsIngenicoTerminalReportBuilder*)builder{
    
    NSString *requestString = @"";
    
    requestString = [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_REPORT, ReportType_toString[builder.getReportType]];
    
    return [HpsTerminalUtilities BuildIngenicoRequest:requestString];
    
}

+(HpsDeviceMessage*)buildTransactionManagementRequest:(HpsIngenicoTerminalManageBuilder*)builder{
    
    NSString *requestString = @"";
    
    int referenceNumber = [[builder getReferenceNumber] intValue];
    NSNumber *amount = [builder getAmount];
    int returnRep = 1;
    int paymentMode = [builder getPaymentMode];
    int paymentType = [builder getPaymentType];
    NSString *currencyCode = [builder getCurrencyCode];
    NSString *privateData = @"EXT0100000";
    int immediateAnswer = 0;
    int forceOnline = 0;
    NSString *extendedData = @"0000000000";
    
    //Validations
    @try {
        amount = [self validateAmount:amount];
        paymentMode = [self validatePaymentMode:paymentMode];
        currencyCode = [self validateCurrencyCode:currencyCode];
        
        
        if ([builder getAuthCode] != nil && [[builder getAuthCode] length] > 0) {
            extendedData = [self validateExtendedData:[builder getAuthCode] tag:[builder getExtendedDataTags]];
        } else if (([builder getTransactionId] != nil && [[builder getTransactionId] length] > 0) && [builder getTransactionType] == Reversal){
            extendedData = [self validateExtendedData:[builder getTransactionId] tag:HPS_INGENICO_TXN_COMMANDS_PARAMS];
        } else {
            extendedData = [self validateExtendedData:[NSString stringWithFormat:@"%ld",(long)[builder getTransactionType]] tag:HPS_INGENICO_TXN_COMMANDS];
        }
    
    } @catch (NSException *exception) {
        @throw exception;
    }
    
    requestString = [NSString stringWithFormat:@"%@%@%d%d%d%@%@A01%dB01%d%@", [NSString stringWithFormat:@"%02d", referenceNumber],[NSString stringWithFormat:@"%08d", [amount intValue]], returnRep, paymentMode, paymentType, currencyCode, privateData, immediateAnswer, forceOnline, extendedData];

    return [HpsTerminalUtilities BuildIngenicoRequest:requestString];
    
}

+(HpsDeviceMessage*)buildPATTResponseMessage:(HpsIngenicoTerminalAuthBuilder*)builder{
    
    NSString *responseString = @"";
    
    if(![builder getXmlPath]){
        int referenceNumber = [[builder getReferenceNumber] intValue];
        int transactionStatus = [builder getTransactionStatus];
        NSNumber *amount = [builder getAmount];
        
        @try {
            amount = [self validateAmount:amount];
        } @catch (NSException *exception) {
            @throw exception;
        }
        
        int paymentMode = [builder getPATPaymentMode];
        NSString *currencyCode = [self validateCurrencyCode:[builder getCurrencyCode]];
        NSString *privateData = [[NSString alloc] initWithFormat:@"%@", PATResponseType_toString[[builder getPATResponseType]]];
        privateData = [privateData stringByPaddingToLength:10 withString:@" " startingAtIndex:0];
        
        responseString = [NSString stringWithFormat:@"%@%d%@%d%@%@", [NSString stringWithFormat:@"%02d", referenceNumber], transactionStatus, [NSString stringWithFormat:@"%08d", [amount intValue]], paymentMode, currencyCode, privateData];

        return [HpsTerminalUtilities buildPATMessage:responseString];
    
    } else {
        
        NSArray *xmlPathArray = [[builder getXmlPath] componentsSeparatedByString:@"."];
        NSString *fileExtension = [xmlPathArray lastObject];
        
        if ([fileExtension isEqualToString:@"xml"] || [fileExtension isEqualToString:@"txt"]){
            responseString = [self getXmlContent:[builder getXmlPath]];
            return [HpsTerminalUtilities buildPATMessage:responseString];
        } else {
            @throw [NSException exceptionWithName:@"HpsIngenicoException" reason:@"Invalid XML Path" userInfo:nil];
        }
    
    }
    
    
    
}

+(NSString*)getXmlContent:(NSString*)xmlPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:xmlPath];
    
    NSString* content = [NSString stringWithContentsOfFile:documentPath encoding:NSISOLatin1StringEncoding error:NULL];
    
    return content;
}

+(HpsDeviceMessage*)buildPaymentTransactionRequest:(HpsIngenicoTerminalAuthBuilder*)builder{
    
    NSString *requestString = @"";
    
    int referenceNumber = [[builder getReferenceNumber] intValue];
    NSNumber *amount = [builder getAmount];
    int returnRep = 1;
    int paymentMode = [builder getPaymentMode];
    int paymentType = [builder getPaymentType];
    
    if (paymentType == HpsIngenicoPaymentType_REFUND && [builder getTaxFreeType] != 0){
        paymentType = [builder getTaxFreeType];
    }
    
    NSString *currencyCode = [builder getCurrencyCode];
    NSString *privateData = @"EXT0100000";
    int immediateAnswer = 0;
    int forceOnline = 0;
    NSString *extendedData = @"0000000000";
    
    //Validations
    @try {
        amount = [self validateAmount:amount];
        paymentMode = [self validatePaymentMode:paymentMode];
        currencyCode = [self validateCurrencyCode:currencyCode];
        
        if ([builder getTableNumber] != nil && [[builder getTableNumber] length] > 0 ) {
            if ( [[builder getTableNumber] length] <= 8){
                extendedData = [self validateExtendedData:[builder getTableNumber] tag:[builder getExtendedDataTags]];
            } else {
                @throw [NSException exceptionWithName:@"HpsIngenicoException" reason:@"Table number must not exceed 8 numeric characters." userInfo:nil];
            }
        }
        
        if ([[builder getCashBackAmount] doubleValue] != 0){
            extendedData = [self validateExtendedData:[[builder getCashBackAmount] stringValue] tag:[builder getExtendedDataTags]];
        }
    
    } @catch (NSException *exception) {
        @throw exception;
    }
    
    requestString = [NSString stringWithFormat:@"%@%@%d%d%d%@%@A01%dB01%d%@", [NSString stringWithFormat:@"%02d", referenceNumber],[NSString stringWithFormat:@"%08d", [amount intValue]], returnRep, paymentMode, paymentType, currencyCode, privateData, immediateAnswer, forceOnline, extendedData];
    
    return [HpsTerminalUtilities BuildIngenicoRequest:requestString];
    
}

+(NSNumber *)validateAmount:(NSNumber *)amount{
    
    if (amount==nil){
        @throw [NSException exceptionWithName:@"HpsIngenicoException" reason:@"Amount can not be null." userInfo:nil];
    } else if ([amount doubleValue] > 0 && [amount doubleValue] < 1000000){
        amount = [NSNumber numberWithDouble:round([amount doubleValue] * 100)];
    } else if ([amount doubleValue] > 1000000){
        @throw [NSException exceptionWithName:@"HpsIngenicoException" reason:@"Amount exceeded." userInfo:nil];
    } else {
        @throw [NSException exceptionWithName:@"HpsIngenicoException" reason:@"Invalid input amount." userInfo:nil];
    }
    
    return amount;
}

+(int)validatePaymentMode:(int)paymentMode{

    if (paymentMode != HpsIngenicoPaymentMode_APPLICATION && paymentMode != HpsIngenicoPaymentMode_MAILORDER){
        paymentMode = HpsIngenicoPaymentMode_APPLICATION;
    }

    return paymentMode;

}

+(NSString *)validateCurrencyCode:(NSString *)currencyCode{

    return currencyCode = [NSString stringWithString:([[currencyCode stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] length] > 0) ? currencyCode : @"826"];

}


+(NSString *)validateExtendedData:(NSString*)value tag:(ExtendedDataTags)tag{
    
    NSString *extDataString = @"0000000000";
    
    switch (tag) {
        case HPS_INGENICO_CASHB:
        {
            NSNumber *amount = [NSNumber numberWithDouble:[value doubleValue]];
            NSString *cashbackFormat = @"%04d";
            
            if (amount==nil){
                @throw [NSException exceptionWithName:@"HpsIngenicoException" reason:@"Cashback Amount can not be null." userInfo:nil];
            } else if ([amount doubleValue] > 0 && [amount doubleValue] <= 100){
                
                if ([amount doubleValue] == 100){
                    cashbackFormat = @"%05d";
                }
                
                amount = [NSNumber numberWithDouble:round([amount doubleValue] * 100)];
                
            } else if ([amount doubleValue] > 100){
                @throw [NSException exceptionWithName:@"HpsIngenicoException" reason:@"Cashback Amount exceeded." userInfo:nil];
            } else {
                @throw [NSException exceptionWithName:@"HpsIngenicoException" reason:@"Invalid input amount." userInfo:nil];
            }
            
            
            return [NSString stringWithFormat:@"CASHB=%@;", [NSString stringWithFormat:cashbackFormat, [amount intValue]]];
            
        }
        break;
            
        case HPS_INGENICO_AUTHCODE:
        {
            return [NSString stringWithFormat:@"AUTHCODE=%@;", value];
        }
        break;
            
        case HPS_INGENICO_TABLE_NUMBER:
        {
            return [NSString stringWithFormat:@"CMD=ID%@;", value];
        }
        break;
            
        case HPS_INGENICO_TXN_COMMANDS:
        {
            TransactionType transType = [value intValue];
            switch (transType) {
                
                case Cancel:
                {
                    return HPS_INGENICO_REQ_CMD_CANCEL;
                }
                break;
                    
                case Duplicate:
                {
                    return HPS_INGENICO_REQ_CMD_DUPLICATE;
                }
                break;
                    
                case Reversal:
                {
                    return HPS_INGENICO_REQ_CMD_REVERSE;
                }
                break;
                    
                default:
                    break;
            }
        }
        break;
            
        case HPS_INGENICO_TXN_COMMANDS_PARAMS:
        {
            return [NSString stringWithFormat:HPS_INGENICO_REQ_CMD_REVERSE_WITH_ID, value];
        }
        break;
            
        default:
            break;
    }
    
    
    return extDataString;
    
}


@end
