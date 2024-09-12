#import "HpsPaxGiftActivateBuilder.h"

@implementation HpsPaxGiftActivateBuilder

- (id)initWithDevice: (HpsPaxDevice*)paxDevice{
    self = [super init];
    if (self != nil)
    {
        device = paxDevice;
        self.currencyType = HpsCurrencyCodes_USD;
    }
    return self;
}

- (void) execute:(void(^)(HpsPaxGiftResponse*, NSError*))responseBlock{

    [self validate];

    NSMutableArray *subgroups = [[NSMutableArray alloc] init];

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"0.##"];

    HpsPaxAmountRequest *amounts = [[HpsPaxAmountRequest alloc] init];
    amounts.transactionAmount = self.amount != nil ? [formatter stringFromNumber:[NSNumber numberWithDouble:[self.amount doubleValue] * 100]] : nil;
    [subgroups addObject:amounts];

    HpsPaxAccountRequest *account = [[HpsPaxAccountRequest alloc] init];
    if (self.giftCard != nil) {
        account.accountNumber = self.giftCard.value;
    }
    [subgroups addObject:account];

    HpsPaxTraceRequest *traceRequest = [[HpsPaxTraceRequest alloc] init];
    traceRequest.referenceNumber = [NSString stringWithFormat:@"%d", self.referenceNumber];
    [subgroups addObject:traceRequest];

    [subgroups addObject:[[HpsPaxCashierSubGroup alloc] init]];

    HpsPaxExtDataSubGroup *extData = [[HpsPaxExtDataSubGroup alloc] init];
    [subgroups addObject:extData];

    NSString *messageId = self.currencyType == HpsCurrencyCodes_USD ? T06_DO_GIFT : T08_DO_LOYALTY;

    [device doGift:messageId withTxnType:PAX_TXN_TYPE_ACTIVATE andSubGroups:subgroups withResponseBlock:^(HpsPaxGiftResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            responseBlock(response, error);
        });
    }];
}

- (void) validate
{
    if (self.amount == nil || self.amount <= 0) {
        @throw [NSException exceptionWithName:@"HpsPaxException" reason:@"Amount is required." userInfo:nil];
    }
    if (self.currencyType < 0) {
        @throw [NSException exceptionWithName:@"HpsPaxException" reason:@"currencyType is required." userInfo:nil];
    }

}

@end
