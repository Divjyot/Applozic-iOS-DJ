//
//  ALRegistrationResponse.m
//  ChatApp
//
//  Created by devashish on 18/09/2015.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALRegistrationResponse.h"

@implementation ALRegistrationResponse


- (id)initWithJSONString:(NSString *)registrationResponse {

    //TODO: Right now error is coming super initWithJSONString, so overriding it...once fixed remove this
    self.message = [registrationResponse valueForKey:@"message"];
    self.deviceKey = [registrationResponse valueForKey:@"deviceKey"];
    self.userKey = [registrationResponse valueForKey:@"userKey"];
    self.contactNumber = [registrationResponse valueForKey:@"contactNumber"];
    self.lastSyncTime = [registrationResponse valueForKey:@"lastSyncTime"];
    self.currentTimeStamp = [registrationResponse valueForKey:@"currentTimeStamp"];
    self.brokerURL = [registrationResponse valueForKey:@"brokerUrl"];
    return self;
}
@end
