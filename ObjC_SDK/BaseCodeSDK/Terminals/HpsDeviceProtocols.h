#import <Foundation/Foundation.h>

@protocol IHPSDeviceMessage
@required
-(NSData*) getSendBuffer;

- (id) initWithBuffer:(NSData*)buffer;
- (NSString*) toString;

@end

@protocol IHPSDeviceResponse

@required
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *command;
@property (nonatomic,strong) NSString *version;
@property (nonatomic,strong) NSString *deviceResponseCode;
@property (nonatomic,strong) NSString *deviceResponseMessage;
@optional
-(NSString*)toString;

@end

@protocol IHPSDeviceCommInterface
@required

-(void) connect;
-(void) disconnect;
-(void) send:(id<IHPSDeviceMessage>)message andResponseBlock:(void(^)(NSData*, NSError*))responseBlock;

//@optional
@end


@protocol IHPSRequestSubGroup
@required

-(NSString*) getElementString;

//@optional
@end
#pragma mark - HpaInterfaces

@protocol IBatchCloseResponse <IHPSDeviceResponse>

@property(nonatomic,strong) NSString *sequenceNumber;
@property(nonatomic,strong) NSString *totalCount;
@property(nonatomic,strong) NSString *totalAmount;

@end

@protocol IInitializeResponse
@required
@property (nonatomic,strong) NSString *serialNumber;
@end

@protocol IDeviceInterface

- (void) cancel:(void(^)(NSError*))responseBlock;
- (void) closeLane:(void(^)(id <IInitializeResponse>, NSError*))responseBlock;
- (void) disableHostResponseBeep:(void(^)(id <IInitializeResponse>, NSError*))responseBlock;
- (void) initialize:(void(^)(id <IInitializeResponse>, NSError*))responseBlock;
- (void) openLane:(void(^)(id <IHPSDeviceResponse>, NSError*))responseBlock;
- (void) reboot:(void(^)(id <IHPSDeviceResponse>, NSError*))responseBlock;
- (void) reset:(void(^)(id <IHPSDeviceResponse>, NSError*))responseBlock;
- (void) batchClose:(void(^)(id <IBatchCloseResponse> , NSError*))responseBlock;

@end

@interface HpsDeviceProtocols : NSObject

@end
