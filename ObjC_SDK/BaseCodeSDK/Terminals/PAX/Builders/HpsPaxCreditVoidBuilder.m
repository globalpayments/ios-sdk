#import "HpsPaxCreditVoidBuilder.h"

@implementation HpsPaxCreditVoidBuilder
- (id)initWithDevice: (HpsPaxDevice*)paxDevice{
    self = [super init];
    if (self != nil)
    {
        device = paxDevice;
    }
    return self;
}

- (void) execute:(void(^)(HpsPaxCreditResponse*, NSError*))responseBlock{
    
    [self validate];
    
    NSMutableArray *subgroups = [[NSMutableArray alloc] init];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"0.##"];
    
    HpsPaxAmountRequest *amounts = [[HpsPaxAmountRequest alloc] init];
    [subgroups addObject:amounts];
    
    HpsPaxAccountRequest *account = [[HpsPaxAccountRequest alloc] init];
    [subgroups addObject:account];
    
    HpsPaxTraceRequest *traceRequest = [[HpsPaxTraceRequest alloc] init];
    traceRequest.referenceNumber = [NSString stringWithFormat:@"%d", self.referenceNumber];
    [subgroups addObject:traceRequest];
    
    HpsPaxAvsRequest *avsRequest = [[HpsPaxAvsRequest alloc] init];
    [subgroups addObject:avsRequest];
    
    [subgroups addObject:[[HpsPaxCashierSubGroup alloc] init]];
    [subgroups addObject:[[HpsPaxCommercialRequest alloc] init]];
    [subgroups addObject:[[HpsPaxEcomSubGroup alloc] init]];
    
    HpsPaxExtDataSubGroup *extData = [[HpsPaxExtDataSubGroup alloc] init];
    
    if (self.transactionId != 0) {
        [extData.collection setObject:[NSString stringWithFormat:@"%d", self.transactionId] forKey:PAX_EXT_DATA_HOST_REFERENCE_NUMBER.uppercaseString];
    }
    [subgroups addObject:extData];
    
    [device doCredit:PAX_TXN_TYPE_VOID andSubGroups:subgroups withResponseBlock:^(HpsPaxCreditResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            responseBlock(response, error);
        });
    }];
}

- (void) validate
{
    if (self.transactionId == 0) {
        @throw [NSException exceptionWithName:@"HpsPaxException" reason:@"transactionId is required." userInfo:nil];
    }
    
}

@end
