//
//  ALMQTTConversationService.h
//  Applozic
//
//  Created by Applozic Inc on 11/27/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTSession.h"
#import "ALMessage.h"
#import "ALUserDetail.h"
#import "ALSyncCallService.h"

@protocol ALMQTTConversationDelegate <NSObject>

-(void) syncCall:(ALMessage *) alMessage andMessageList:(NSMutableArray *)messageArray;
-(void) delivered:(NSString *) messageKey contactId:(NSString *)contactId withStatus:(int)status;
-(void) updateStatusForContact:(NSString *)contactId  withStatus:(int)status;
-(void) updateTypingStatus: (NSString *) applicationKey userId: (NSString *) userId status: (BOOL) status;
-(void) updateLastSeenAtStatus: (ALUserDetail *) alUserDetail;
-(void) mqttConnectionClosed;

@optional

-(void) reloadDataForUserBlockNotification:(NSString *)userId andBlockFlag:(BOOL)flag;

@end

@interface ALMQTTConversationService : NSObject <MQTTSessionDelegate>

+(ALMQTTConversationService *)sharedInstance;

@property(nonatomic, strong) ALSyncCallService *alSyncCallService;

-(void) subscribeToConversation;

-(void) unsubscribeToConversation;

-(void) unsubscribeToConversation: (NSString *)userKey;

-(void) sendTypingStatus:(NSString *) applicationKey userID:(NSString *) userId typing: (BOOL) typing;

@property(nonatomic, strong) id<ALMQTTConversationDelegate>mqttConversationDelegate;

@end
