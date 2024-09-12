#import <Foundation/Foundation.h>
#import "HpsPaxMessageIDs.h"
#import "HpsCreditCard.h"
#import "HpsAddress.h"
#import "HpsTransactionDetails.h"
#import "HpsPaxCreditResponse.h"
#import "HpsPaxAvsRequest.h"
#import "HpsPaxAccountRequest.h"
#import "HpsPaxCashierSubGroup.h"
#import "HpsPaxCommercialRequest.h"
#import "HpsPaxAmountRequest.h"
#import "HpsPaxTraceRequest.h"
#import "HpsPaxEcomSubGroup.h"
#import "HpsPaxExtDataSubGroup.h"
#import "HpsPaxDevice.h"

@interface HpsPaxCreditReturnBuilder : NSObject
{
    HpsPaxDevice *device;
}

@property (nonatomic, readwrite) int referenceNumber;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) HpsCreditCard *creditCard;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, readwrite) int transactionId;
@property (nonatomic, strong) HpsAddress *address;
@property (nonatomic, strong) HpsTransactionDetails *details;
@property (nonatomic, readwrite) BOOL allowDuplicates;
@property (nonatomic, strong) NSString *authCode;

- (void) execute:(void(^)(HpsPaxCreditResponse*, NSError*))responseBlock;
- (id)initWithDevice: (HpsPaxDevice*)paxDevice;

@end
