//
//  HpsIngenicoPATRequest.m
//  ObjC_SDK
//
//  Created by ADL on 8/30/20.
//  Copyright © 2020 iGen Payment Systems. All rights reserved.
//

#import "HpsIngenicoPATRequest.h"

@implementation HpsIngenicoPATRequest {
    PATRequestType requestType;
    HpsIngenicoPATTransactionOutcome *transactionOutcome;
    
    NSString *waiterId;
    NSString *tableNumber;
    NSString *terminalId;
    NSString *terminalCurrency;
    NSString *rawData;
}

-(PATRequestType)getRequestType{
    return requestType;
}

-(HpsIngenicoPATTransactionOutcome*)getTransactionOutcome{
    return transactionOutcome;
}

-(NSString*)getWaiterId{
    return waiterId;
}

-(NSString*)getTableNumber{
    return tableNumber;
}

-(NSString*)getTerminalId{
    return terminalId;
}

-(NSString*)getTerminalCurrency{
    return terminalCurrency;
}

-(NSString*)getRawRequest{
    return rawData;
}

-(id)initWithBuffer:(NSData *)data{
    
    self = [super init];
    
    if(!data) return nil;
    
    rawData = [[NSString alloc] initWithString:[HpsTerminalUtilities getString:data]];
    
    //if ([rawData rangeOfString:HPS_INGENICO_XML_TAG].location != NSNotFound){
    
    NSDictionary *xmlDoc = [[NSDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithXMLString:rawData]];
    NSString *rootNode = [xmlDoc valueForKey:[[xmlDoc allKeys] firstObject]];
    
    if (rootNode){
        
        if([rootNode isEqualToString:HPS_INGENICO_PAT_XML_TYPE_ADDITIONAL_MSG]){
            
            requestType = HPS_INGENICO_PAT_REQUEST_ADDITIONAL_MESSAGE;
            
        } else if ([rootNode isEqualToString:HPS_INGENICO_PAT_XML_TYPE_TRANSFER_DATA_REQUEST]) {
            
            requestType = HPS_INGENICO_PAT_REQUEST_TRANSFER_DATA;
            
        } else if ([rootNode isEqualToString:HPS_INGENICO_PAT_STYPE_SPLIT_SALE_ROOT]) {
            
            requestType = HPS_INGENICO_PAT_REQUEST_SPLITSALE_REPORT;
            
        } else {
            
            NSDictionary *nodeList = xmlDoc[@"RECEIPT"];
            
            [nodeList enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if([key containsString:@"STYPE"]){
                    
                    NSString *sType = [nodeList valueForKey:[[nodeList allKeys] firstObject]];
                    
                    if ([sType isEqualToString:HPS_INGENICO_PAT_STYPE_SPLIT_SALE]) {
                        
                        requestType = HPS_INGENICO_PAT_REQUEST_SPLITSALE_REPORT;
                        
                    } else if ([sType isEqualToString:HPS_INGENICO_PAT_STYPE_TICKET_MERCHANT] || [sType isEqualToString:HPS_INGENICO_PAT_STYPE_TICKET_CUSTOMER]) {
                        
                        requestType = HPS_INGENICO_PAT_REQUEST_TICKET;
                        
                    } else if ([sType isEqualToString:HPS_INGENICO_PAT_STYPE_EOD]){
                        
                        requestType = HPS_INGENICO_PAT_REQUEST_EOD_REPORT;
                        
                    }
                }
            }];
        
        }

        
    } else {
        
        if([rawData length] >= 80){
            requestType = HPS_INGENICO_PAT_REQUEST_TRANSACTION_OUTCOME;
            transactionOutcome = [[HpsIngenicoPATTransactionOutcome alloc] initWithBuffer:data];
        }
        
        else {
            NSString *type = [HpsTerminalUtilities getSubString:rawData range:NSMakeRange(11, 1)];
            requestType = [type intValue];

            NSString *privData = [HpsTerminalUtilities getSubString:rawData range:NSMakeRange(16, rawData.length - 16)];
            
            if([rawData length] < 55){
                tableNumber = privData;
            } else {
                HpsTypeLengthValue *tlv = [[HpsTypeLengthValue alloc] initWithBuffer:[privData dataUsingEncoding:NSUTF8StringEncoding] parseFormat:HPS_INGENICO_PARSE_FORMAT_PAT];
                
                waiterId = [tlv getValue:HPS_INGENICO_PAT_PRIV_CODE_WAITER_ID returnType:[NSString class]];
                tableNumber = [tlv getValue:HPS_INGENICO_PAT_PRIV_CODE_TABLE_ID returnType:[NSString class]];
                terminalId = [tlv getValue:HPS_INGENICO_PAT_PRIV_CODE_TID returnType:[NSString class]];
                terminalCurrency = [tlv getValue:HPS_INGENICO_PAT_PRIV_CODE_TERMINAL_CURRENCY returnType:[NSString class]];
            }
        }
        
    }
    
    return self;
}

@end
