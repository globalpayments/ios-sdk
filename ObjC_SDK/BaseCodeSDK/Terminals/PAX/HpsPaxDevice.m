#import "HpsPaxDevice.h"
#import "HpsPaxMessageIDs.h"
#import "HpsTerminalUtilities.h"
#import "HpsTerminalEnums.h"
#import "HpsPaxTcpInterface.h"

@implementation HpsPaxDevice

- (instancetype) initWithConfig:(HpsConnectionConfig*)config
{
	if((self = [super init]))
		{
		self.config = config;
		errorDomain = [HpsCommon sharedInstance].hpsErrorDomain;
		switch ((int)self.config.connectionMode) {

			case HpsConnectionModes_TCP_IP:
			{
			self.interface = [[HpsPaxTcpInterface alloc] initWithConfig:config];
			break;
			}
			case HpsConnectionModes_HTTP:
			{
			self.interface = [[HpsPaxHttpInterface alloc] initWithConfig:config];
			break;
			}
			default:
			{

			}
		}

		}
	return self;
}

#pragma mark -
#pragma Admin functions
- (void) initialize:(void(^)(HpsPaxInitializeResponse*, NSError*))responseBlock{

	id<IHPSDeviceMessage> request = [HpsTerminalUtilities buildRequest:A00_INITIALIZE];

	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"data returned: %@", dataview);
			HpsPaxInitializeResponse *response;
			@try {
					//parse data
				response = [[HpsPaxInitializeResponse alloc] initWithBuffer:data];
				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];
}

	//void results or error
- (void) cancel:(void(^)(NSError*))responseBlock{

	if ((int)self.config.connectionMode == HpsConnectionModes_HTTP) {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"HTTP mode not supported"};
		NSError *error = [NSError errorWithDomain:errorDomain
											 code:CocoaError
										 userInfo:userInfo];

		dispatch_async(dispatch_get_main_queue(), ^{
			responseBlock(error);
		});

	}else{
		id<IHPSDeviceMessage> request = [HpsTerminalUtilities buildRequest:A14_CANCEL];

		[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
			if (error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(error);
				});
			}else{
					//done
				NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
				NSLog(@"data returned: %@", dataview);
				HpsPaxInitializeResponse *response;
				@try {
						//parse data
					response = [[HpsPaxInitializeResponse alloc] initWithBuffer:data];
					dispatch_async(dispatch_get_main_queue(), ^{
						responseBlock(nil);
					});
				} @catch (NSException *exception) {
					NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
					NSError *error = [NSError errorWithDomain:self->errorDomain
														 code:CocoaError
													 userInfo:userInfo];

					dispatch_async(dispatch_get_main_queue(), ^{
						responseBlock(error);
					});
				}
			}
		}];
	}
}

- (void) reset:(void(^)(HpsPaxDeviceResponse*, NSError*))responseBlock{

	id<IHPSDeviceMessage> request = [HpsTerminalUtilities buildRequest:A16_RESET];

	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"data returned: %@", dataview);
			HpsPaxDeviceResponse *response;
			@try {
					//parse data
				response = [[HpsPaxDeviceResponse alloc] initWithMessageID:A17_RSP_RESET andBuffer:data];
				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];
}

- (void) batchClose:(void(^)(HpsPaxBatchCloseResponse*, NSError*))responseBlock
{
	id<IHPSDeviceMessage> request = [HpsTerminalUtilities buildRequest:B00_BATCH_CLOSE];

	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"data returned: %@", dataview);
			HpsPaxBatchCloseResponse *response;
			@try {
					//parse data
				response = [[HpsPaxBatchCloseResponse alloc] initWithBuffer:data];
				dispatch_async(dispatch_get_main_queue(), ^{
					[self printRecipt:response];
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];

}

- (void) reboot:(void(^)(HpsPaxDeviceResponse*, NSError*))responseBlock{

	id<IHPSDeviceMessage> request = [HpsTerminalUtilities buildRequest:A26_REBOOT];

	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			NSLog(@"data returned: %@", dataview);
			HpsPaxDeviceResponse *response;
			@try {
					//parse data
				response = [[HpsPaxDeviceResponse alloc] initWithMessageID:A27_RSP_REBOOT andBuffer:data];
				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(response, nil);
				});
			} @catch (NSException *exception) {
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [exception description]};
				NSError *error = [NSError errorWithDomain:self->errorDomain
													 code:CocoaError
												 userInfo:userInfo];

				dispatch_async(dispatch_get_main_queue(), ^{
					responseBlock(nil, error);
				});
			}
		}
	}];
}

#pragma mark -
#pragma mark Transactions

- (void) doCredit:(NSString*)txnType
	 andSubGroups:(NSArray*)subGroups
withResponseBlock:(void(^)(HpsPaxCreditResponse*, NSError*))responseBlock{

		//Blocks call chain
	[self doTransaction:T00_DO_CREDIT andTxnType:txnType andSubGroups:subGroups withResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			dispatch_async(dispatch_get_main_queue(), ^{
				NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
				NSLog(@"data returned: %@", dataview);

				HpsPaxCreditResponse *response = [[HpsPaxCreditResponse alloc] initWithBuffer:data];

				[self printRecipt:response];
				responseBlock(response, error);
			});
		}


	}];
}

- (void) doDebit:(NSString*)txnType
	andSubGroups:(NSArray*)subGroups
withResponseBlock:(void(^)(HpsPaxDebitResponse*, NSError*))responseBlock{

		//Blocks call chain
	[self doTransaction:T02_DO_DEBIT andTxnType:txnType andSubGroups:subGroups withResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			dispatch_async(dispatch_get_main_queue(), ^{
				HpsPaxDebitResponse *response = [[HpsPaxDebitResponse alloc] initWithBuffer:data];
				[self printRecipt:response];
				responseBlock(response, error);
			});
		}


	}];
}

- (void) doGift:(NSString*)messageId
	withTxnType:(NSString*)txnType
   andSubGroups:(NSArray*)subGroups
withResponseBlock:(void(^)(HpsPaxGiftResponse*, NSError*))responseBlock{

		//Blocks call chain
	[self doTransaction:messageId andTxnType:txnType andSubGroups:subGroups withResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
			dispatch_async(dispatch_get_main_queue(), ^{
				HpsPaxGiftResponse *response = [[HpsPaxGiftResponse alloc] initWithBuffer:data];
				[self printRecipt:response];
				responseBlock(response, error);
			});
		}

	}];
}

#pragma mark -
#pragma mark Private Methods

- (void) doTransaction:(NSString*)messageId
			andTxnType:(NSString*)txnType
		  andSubGroups:(NSArray*)subGroups
	 withResponseBlock:(void(^)(NSData*, NSError*))responseBlock{

		//load commands
	NSMutableArray *commands = [[NSMutableArray alloc] init];
	[commands addObject:txnType];

	NSString* fs_code = [HpsTerminalEnums controlCodeString:HpsControlCodes_FS];
	[commands addObject:fs_code];
	if (subGroups.count > 0) {
		[commands addObject:[subGroups objectAtIndex:0]];
		for (int i = 1; i < subGroups.count ; i++) {

			[commands addObject:fs_code];
			[commands addObject:[subGroups objectAtIndex:i]];
		}
	}else{
		[commands addObject:fs_code];
	}

		//Run on device
	id<IHPSDeviceMessage> request = [HpsTerminalUtilities buildRequest:messageId withElements:commands];
	[self.interface send:request andResponseBlock:^(NSData *data, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(nil, error);
			});
		}else{
				//done
				//NSString *dataview = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
				// NSLog(@"data returned device: %@", dataview);
			dispatch_async(dispatch_get_main_queue(), ^{
				responseBlock(data, nil);
			});
		}
	}];
}

-(id)getValueOfObject:(id)value{

	return value == NULL?(id)@"":value;
}

-(void)printRecipt:(HpsTerminalResponse*)response
{
	NSMutableString *recipt = [[NSMutableString alloc]init];

	[recipt appendString:[NSString stringWithFormat:@"x_trans_type=%@",[self getValueOfObject:response.transactionType]]] ;
	[recipt appendString:[NSString stringWithFormat:@"&x_application_label=%@",[self getValueOfObject:response.applicationName]]];
	if (response.maskedCardNumber)[recipt appendString:[NSString stringWithFormat: @"&x_masked_card=************%@",response.maskedCardNumber]];
	else [recipt appendString:[NSString stringWithFormat: @"&x_masked_card="]];
	[recipt appendString:[NSString stringWithFormat:@"&x_application_id=%@",[self getValueOfObject:response.applicationId]]];

	switch (response.applicationCryptogramType)
	{
		case TC:
		[recipt appendString:[NSString stringWithFormat:@"&x_cryptogram_type=TC"]];
		break;
		case ARQC:
		[recipt appendString:[NSString stringWithFormat:@"&x_cryptogram_type=ARQC"]];
		break;
		default:
		[recipt appendString:[NSString stringWithFormat:@"&x_cryptogram_type="]];
		break;
	}

	[recipt appendString:[NSString stringWithFormat:@"&x_application_cryptogram=%@",[self getValueOfObject:response.applicationCrytptogram]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_expiration_date=%@",[self getValueOfObject:response.expirationDate]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_entry_method=%@",[HpsTerminalEnums entryModeToString:response.entryMode]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_approval=%@",[self getValueOfObject:response.approvalCode]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_transaction_amount=%@",response.transactionAmount]];
	[recipt appendString:[NSString stringWithFormat:@"&x_amount_due=%@",[self getValueOfObject:response.amountDue]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_customer_verification_method=%@",[self getValueOfObject:response.cardHolderVerificationMethod]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_signature_status=%@",[self getValueOfObject:response.signatureStatus]]];
	[recipt appendString:[NSString stringWithFormat:@"&x_response_text=%@",[self getValueOfObject:response.responseText]]];
	
	NSLog(@"Recipt = %@", recipt);
}

@end
