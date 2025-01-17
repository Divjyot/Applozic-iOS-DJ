//
//  ALRegistrationResponse.h
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALJson.h"

@interface ALRegistrationResponse : ALJson

@property NSString *message;
@property NSString *deviceKey;
@property NSString *userKey;
@property NSString *contactNumber;
@property NSString *lastSyncTime;
@property NSString *currentTimeStamp;
@property NSString *brokerURL;
@end