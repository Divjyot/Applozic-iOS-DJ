//
//  ALChatLauncher.m
//  Applozic
//
//  Created by devashish on 21/12/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//


#import "ALChatLauncher.h"
#import "ALUserDefaultsHandler.h"
#import "ALApplozicSettings.h"
#import "ALChatViewController.h"
#import "ALUser.h"
#import "ALRegisterUserClientService.h"
#import "ALMessageClientService.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessagesViewController.h"
#import "ALUserService.h"

@interface ALChatLauncher ()<ALChatViewControllerDelegate, ALMessagesViewDelegate>

@end

@implementation ALChatLauncher


- (instancetype)initWithApplicationId:(NSString *) applicationId;
{
    self = [super init];
    if (self)
    {
        self.applicationId = applicationId;
    }
    return self;
}

-(void)launchIndividualChat:(NSString *)userId withGroupId:(NSNumber*)groupID
    andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text
{
    self.chatLauncherFLAG = [NSNumber numberWithInt:1];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    
    ALChatViewController * chatView = (ALChatViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    
    chatView.channelKey = groupID;
    chatView.contactIds = userId;
    chatView.text = text;
    chatView.individualLaunch = YES;
    chatView.chatViewDelegate = self;
    
    
    
    NSLog(@"CALLED_VIA_NOTIFICATION");
    
    UINavigationController * conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:chatView];
    conversationViewNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
}


-(void)launchIndividualChat:(NSString *)userId withGroupId:(NSNumber*)groupID
            withDisplayName:(NSString*)displayName andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text
{

    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                
                                                         bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    
    ALChatViewController *chatView = (ALChatViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    
    chatView.channelKey = groupID;
    chatView.contactIds = userId;
    chatView.text = text;
    chatView.individualLaunch = YES;
    chatView.displayName = displayName;
    chatView.chatViewDelegate = self;
    
    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:chatView];
    conversationViewNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve ;
    [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
    
}

-(void)launchChatList:(NSString *)title andViewControllerObject:(UIViewController *)viewController
{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    UIViewController *theTabBar = [storyboard instantiateViewControllerWithIdentifier:@"messageTabBar"];
    
    //              To Lunch with different Animation...
    //theTabBar.modalTransitionStyle=UIModalTransitionStyleCrossDissolve ;
    
    UITabBarController * tabBAR = ((UITabBarController *)theTabBar);
    UINavigationController * navBAR = (UINavigationController *)[[tabBAR viewControllers] objectAtIndex:0];
    ALMessagesViewController * msgVC = (ALMessagesViewController *)[[navBAR viewControllers] objectAtIndex:0];
    msgVC.messagesViewDelegate = self;
    
    [viewController presentViewController:theTabBar animated:YES completion:nil];
    
}

-(void)registerForNotification
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:
                                                                             (UIUserNotificationTypeSound | UIUserNotificationTypeAlert
                                                                              | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

-(void)launchContactList:(UIViewController *)uiViewController
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    
    UIViewController *contcatListView = [storyboard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    
    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:contcatListView];
    [uiViewController presentViewController:conversationViewNavController animated:YES completion:nil];

}

-(void)launchIndividualContextChat:(ALConversationProxy *)alConversationProxy andViewControllerObject:(UIViewController *)viewController andWithText:(NSString *)text
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Applozic"
                                                         bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    
    ALChatViewController * contextChatView = (ALChatViewController*) [storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    
    contextChatView.displayName      = @"Adarsh";
    contextChatView.conversationId   = alConversationProxy.Id;
    contextChatView.channelKey       = alConversationProxy.groupId;
    contextChatView.contactIds       = alConversationProxy.userId;
    contextChatView.text             = text;
    contextChatView.individualLaunch = YES;
    
    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:contextChatView];
    conversationViewNavController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve ;
    [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
    
}

-(void)launchChatListWithUserOrGroup:(NSString *)userId withChannel:(NSNumber*)channelKey andViewControllerObject:(UIViewController *)viewController
{
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessagesViewController *chatListView = (ALMessagesViewController*)[storyboard instantiateViewControllerWithIdentifier:@"ALViewController"];
    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:chatListView];

    chatListView.userIdToLaunch = userId;
    chatListView.channelKey = channelKey;
    chatListView.messagesViewDelegate = self;
    
    [viewController presentViewController:conversationViewNavController animated:YES completion:nil];
    
}

//  WHEN FLOW IS FROM MESSAGEVIEW TO CHATVIEW
-(void)handleCustomActionFromMsgVC:(UIViewController *)chatView andWithMessage:(ALMessage *)alMessage
{
    id launcherDelegate = NSClassFromString([ALApplozicSettings getCustomClassName]);
    [launcherDelegate handleCustomAction:chatView andWithMessage:alMessage];
}

//  WHEN FLOW IS FROM DIRECT CHATVIEW
-(void)handleCustomActionFromChatVC:(UIViewController *)chatViewController andWithMessage:(ALMessage *)alMessage
{
    id launcherDelegate = NSClassFromString([ALApplozicSettings getCustomClassName]);
    [launcherDelegate handleCustomAction:chatViewController andWithMessage:alMessage];
}

@end

