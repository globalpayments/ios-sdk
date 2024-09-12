#import <Foundation/Foundation.h>
#import "HpsIngenicoEnums.h"

@interface HpsConnectionConfig : NSObject

@property (nonatomic) NSInteger connectionMode;
@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic, strong) NSString *port;
@property (nonatomic) NSInteger baudeRate;
@property (nonatomic) NSInteger parity;
@property (nonatomic) NSInteger stopBits;
@property (nonatomic) NSInteger dataBits;
@property (nonatomic) NSInteger timeout;

@end
