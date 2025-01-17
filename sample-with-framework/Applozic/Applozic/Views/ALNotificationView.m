//
//  ALNotificationView.m
//  ChatApp
//
//  Created by Devashish on 06/10/15.
//  Copyright © 2015 AppLogic. All rights reserved.
//

#import "ALNotificationView.h"
#import "TSMessage.h"
#import "ALPushAssist.h"
#import "ALUtilityClass.h"
#import "ALChatViewController.h"
#import "TSMessageView.h"
#import "ALMessagesViewController.h"
#import "ALUserDefaultsHandler.h"
#import "ALContact.h"
#import "ALContactDBService.h"
#import "ALApplozicSettings.h"
#import "ALChannelDBService.h"
#import "ALApplozicSettings.h"
#import "ALConstant.h"
@implementation ALNotificationView
    

/*********************
 GROUP_NAME
 CONTACT_NAME: MESSAGE
*********************
 
*********************
 CONTACT_NAME
 MESSAGE
*********************/


-(instancetype)initWithAlMessage:(ALMessage*)alMessage  withAlertMessage: (NSString *) alertMessage{
    self = [super init];
    self.text =[self getNotificationText:alMessage];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.layer.cornerRadius = 0;
    self.userInteractionEnabled = YES;
    self.contactId = alMessage.contactIds;
    self.groupId = alMessage.groupId;
    self.conversationId = alMessage.conversationId;
    self.alMessageObject = alMessage;
    return self;
}

-(NSString*)getNotificationText:(ALMessage *)alMessage
{
    if(alMessage.contentType == ALMESSAGE_CONTENT_LOCATION)
    {
        return @"Shared a Location";
    }
    else if(alMessage.contentType == ALMESSAGE_CONTENT_VCARD)
    {
        return @"Shared a Contact";
    }
    else if (alMessage.contentType == ALMESSAGE_CONTENT_CAMERA_RECORDING)
    {
        return @"Shared a Video";
    }
    else if (alMessage.contentType == ALMESSAGE_CONTENT_AUDIO)
    {
        return @"Shared an Audio";
    }
    else if (alMessage.contentType == ALMESSAGE_CONTENT_ATTACHMENT ||
             [alMessage.message isEqualToString:@""] || alMessage.fileMeta != NULL)
    {
        return @"Shared an Attachment";
    }

    else{
        return alMessage.message;
    }
}

- (void)customizeMessageView:(TSMessageView *)messageView
{
    messageView.alpha = 0.4;
    messageView.backgroundColor=[UIColor blackColor];
}


#pragma mark- Our SDK views notification
//=======================================
-(void)nativeNotification:(id)delegate{
   
    if([ALUserDefaultsHandler getNotificationMode] == NOTIFICATION_DISABLE){
        return;
    }
    NSString * title; // Title of Notification Banner (Display Name or Group Name)
    NSString * subtitle = self.text; //Message to be shown
    
    ALPushAssist * top=[[ALPushAssist alloc] init];
    
    ALContactDBService * contactDbService = [[ALContactDBService alloc] init];
    ALContact * alcontact = [contactDbService loadContactByKey:@"userId" value:self.contactId];
   
    ALChannel * alchannel=[[ALChannel alloc] init];
    ALChannelDBService * channelDbService= [[ALChannelDBService alloc] init];
    

    if(self.groupId && self.groupId.intValue != 0){
    

        NSString * contactName;
        NSString * groupName;
        
        alchannel = [channelDbService loadChannelByKey:self.groupId];
        alcontact.userId = (alcontact.userId != nil ? alcontact.userId:@"");
        
        groupName = [NSString stringWithFormat:@"%@",(alchannel.name != nil ? alchannel.name : self.groupId)];
        
        NSArray *notificationComponents = [alcontact.getDisplayName componentsSeparatedByString:@":"];
        if(notificationComponents.count>1){
            contactName =[[contactDbService loadContactByKey:@"userId" value:[notificationComponents lastObject]] getDisplayName];
            
        }
        else{
            contactName = alcontact.getDisplayName;
        }
        
        if(_alMessageObject.contentType == 10){
            title = self.text;
            subtitle = @"";
        }
        else{
            title    = groupName;
            subtitle = [NSString stringWithFormat:@"%@:%@",contactName,subtitle];
        }


    }
    else{
        
        title    = alcontact.getDisplayName;
        subtitle = self.text;

    }
    
    // ** Attachment ** //
    if(self.alMessageObject.contentType == ALMESSAGE_CONTENT_LOCATION){
        subtitle = [NSString stringWithFormat:@"Shared location"];
    }
    
    subtitle = (subtitle.length > 20) ? [NSString stringWithFormat:@"%@...",[subtitle substringToIndex:17]] : subtitle;
    
    UIImage *appIcon = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] objectAtIndex:0]];
   
    [[TSMessageView appearance] setTitleFont:[UIFont boldSystemFontOfSize:17]];
    [[TSMessageView appearance] setContentFont:[UIFont systemFontOfSize:13]];
    [[TSMessageView appearance] setTitleFont:[UIFont fontWithName:@"Helvetica Neue" size:18.0]];
    [[TSMessageView appearance] setContentFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[TSMessageView appearance] setContentTextColor:[UIColor whiteColor]];
    
    
    [TSMessage showNotificationInViewController:top.topViewController
                                          title:title
                                       subtitle:subtitle
                                          image:appIcon
                                           type:TSMessageNotificationTypeMessage
                                       duration:1.75
                                       callback:
     ^(void){
         
         if([delegate isKindOfClass:[ALMessagesViewController class]] && top.isMessageViewOnTop){
             // Conversation View is Opened.....
             ALMessagesViewController* class2=(ALMessagesViewController*)delegate;
             if(self.groupId){
                 class2.channelKey=self.groupId; NSLog(@"CLASS %@",class2.channelKey);
                 //_contactId=self.groupId; CRASH: if you send contactId as NSNumber.
             }
             else{
                 class2.channelKey=nil;
                 self.groupId=nil;
             }
             NSLog(@"onTopMessageVC: ContactID %@ and ChannelID %@",self.contactId, self.groupId);
             [class2 createDetailChatViewController:_contactId];
             self.checkContactId=[NSString stringWithFormat:@"%@",self.contactId];
             
         }
         else if([delegate isKindOfClass:[ALChatViewController class]] && top.isChatViewOnTop){
             // Chat View is Opened....
             ALChatViewController * class1= (ALChatViewController*)delegate;
             NSLog(@"onTopChatVC: ContactID %@ and ChannelID %@",self.contactId, self.groupId);
             if(self.groupId){
                 class1.channelKey=self.groupId;
             }
             else {
                 class1.channelKey=nil;
                 self.groupId=nil;
             }
             
             if (self.conversationId) {
                 class1.conversationId = self.conversationId;
                 [[class1.alMessageWrapper messageArray] removeAllObjects];
                 [class1 processLoadEarlierMessages:YES];
             }
             else{
                 class1.conversationId = nil;
                 class1.contactIds=self.contactId;
                 [class1 reloadView];
                 [class1 markConversationRead];
                 [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
             }
         }
         else{
             NSLog(@"View Already Opened and Notification coming already");
         }
}
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
}

-(void)showGroupLeftMessage
{
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [TSMessage showNotificationWithTitle:@"You have left this group" type:TSMessageNotificationTypeWarning];
}

-(void)noDataConnectionNotificationView
{
    [[TSMessageView appearance] setTitleTextColor:[UIColor whiteColor]];
    [TSMessage showNotificationWithTitle:@"No Internet Connectivity" type:TSMessageNotificationTypeWarning];
    
}

@end
