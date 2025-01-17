//
//  ALApplozicSettings.m
//  Applozic
//
//  Created by devashish on 20/11/2015.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALApplozicSettings.h"
#import "ALUserDefaultsHandler.h"
#import "ALConstant.h"

@interface ALApplozicSettings ()

@end

@implementation ALApplozicSettings

+(void)setFontFace:(NSString *)fontFace
{
    [[NSUserDefaults standardUserDefaults] setValue:fontFace forKey:FONT_FACE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getFontFace
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:FONT_FACE];
}

+(void)setTitleForConversationScreen:(NSString *)titleText
{
    [[NSUserDefaults standardUserDefaults] setValue:titleText forKey:CONVERSATION_TITLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getTitleForConversationScreen
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:CONVERSATION_TITLE];
}

+(void)setUserProfileHidden: (BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:USER_PROFILE_PROPERTY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isUserProfileHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:USER_PROFILE_PROPERTY];
}

+(void)setColorForSendMessages:(UIColor *)sendMsgColor
{
    NSData *sendColorData = [NSKeyedArchiver archivedDataWithRootObject:sendMsgColor];
    [[NSUserDefaults standardUserDefaults] setObject:sendColorData forKey:SEND_MSG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setColorForReceiveMessages:(UIColor *)receiveMsgColor
{
    NSData *receiveColorData = [NSKeyedArchiver archivedDataWithRootObject:receiveMsgColor];
    [[NSUserDefaults standardUserDefaults] setObject:receiveColorData forKey:RECEIVE_MSG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getSendMsgColor
{
    NSData *sendColorData = [[NSUserDefaults standardUserDefaults] objectForKey:SEND_MSG_COLOUR];
    UIColor *sendColor = [NSKeyedUnarchiver unarchiveObjectWithData:sendColorData];
    if(sendColor)
    {
        return sendColor;
    }
    return [UIColor whiteColor];
}

+(UIColor *)getReceiveMsgColor
{
    NSData *receiveColorData = [[NSUserDefaults standardUserDefaults] objectForKey:RECEIVE_MSG_COLOUR];
    UIColor *receiveColor = [NSKeyedUnarchiver unarchiveObjectWithData:receiveColorData];
    if(receiveColor)
    {
        return receiveColor;
    }
    return [UIColor whiteColor];
}

+(void)setColorForNavigation:(UIColor *)barColor
{
    NSData *barColorData = [NSKeyedArchiver archivedDataWithRootObject:barColor];
    [[NSUserDefaults standardUserDefaults] setObject:barColorData forKey:NAVIGATION_BAR_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(UIColor *)getColorForNavigation
{
    NSData *barColorData = [[NSUserDefaults standardUserDefaults] objectForKey:NAVIGATION_BAR_COLOUR];
    UIColor *barColor = [NSKeyedUnarchiver unarchiveObjectWithData:barColorData];
    return barColor;
}

+(void)setColorForNavigationItem:(UIColor *)barItemColor
{
    NSData *barItemColorData = [NSKeyedArchiver archivedDataWithRootObject:barItemColor];
    [[NSUserDefaults standardUserDefaults] setObject:barItemColorData forKey:NAVIGATION_BAR_ITEM_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(UIColor *)getColorForNavigationItem
{
    NSData *barItemColourData = [[NSUserDefaults standardUserDefaults] objectForKey:NAVIGATION_BAR_ITEM_COLOUR];
    UIColor *barItemColour = [NSKeyedUnarchiver unarchiveObjectWithData:barItemColourData];
    return barItemColour;
}

+(void)hideRefreshButton:(BOOL)state
{
    [[NSUserDefaults standardUserDefaults] setBool:state forKey:REFRESH_BUTTON_VISIBILITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isRefreshButtonHidden
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:REFRESH_BUTTON_VISIBILITY];
}

+(void)setTitleForBackButtonMsgVC:(NSString *)backButtonTitle
{
    [[NSUserDefaults standardUserDefaults] setValue:backButtonTitle forKey:BACK_BUTTON_TITLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getTitleForBackButtonMsgVC
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:BACK_BUTTON_TITLE];
}

+(void)setTitleForBackButtonChatVC:(NSString *)backButtonTitle
{
    [[NSUserDefaults standardUserDefaults] setValue:backButtonTitle forKey:BACK_BUTTON_TITLE_CHATVC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getTitleForBackButtonChatVC
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:BACK_BUTTON_TITLE_CHATVC];
}

+(void)setNotificationTitle:(NSString *)notificationTitle
{
    [[NSUserDefaults standardUserDefaults] setValue:notificationTitle forKey:NOTIFICATION_TITLE];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getNotificationTitle{
    return [[NSUserDefaults standardUserDefaults] valueForKey:NOTIFICATION_TITLE];
}

+(void)setMaxImageSizeForUploadInMB:(NSInteger)maxFileSize{
    [[NSUserDefaults standardUserDefaults] setInteger:maxFileSize forKey:IMAGE_UPLOAD_MAX_SIZE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)getMaxImageSizeForUploadInMB{
    return [[NSUserDefaults standardUserDefaults] integerForKey:IMAGE_UPLOAD_MAX_SIZE];
    
}

+(void) setMaxCompressionFactor:(double)maxCompressionRatio{
    [[NSUserDefaults standardUserDefaults] setDouble:maxCompressionRatio  forKey:IMAGE_COMPRESSION_FACTOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(double) getMaxCompressionFactor{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:IMAGE_COMPRESSION_FACTOR];
    
}

+(void)setGroupOption:(BOOL)option{
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:GROUP_ENABLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getGroupOption{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GROUP_ENABLE];
}

+(void)setMultipleAttachmentMaxLimit:(NSInteger)limit
{
    [[NSUserDefaults standardUserDefaults] setInteger:limit forKey:MAX_SEND_ATTACHMENT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)getMultipleAttachmentMaxLimit
{
    NSInteger maxLimit = [[NSUserDefaults standardUserDefaults] integerForKey:MAX_SEND_ATTACHMENT];
    return maxLimit ? maxLimit : 5;
}

+(void)setFilterContactsStatus:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:FILTER_CONTACT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getFilterContactsStatus
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:FILTER_CONTACT];
}

+(void)setStartTime:(NSNumber *)startTime
{
    startTime = @([startTime doubleValue] + 1);
    [[NSUserDefaults standardUserDefaults] setDouble:[startTime doubleValue] forKey:FILTER_CONTACT_START_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSNumber *)getStartTime
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:FILTER_CONTACT_START_TIME];
}

+(void)setChatWallpaperImageName:(NSString*)imageName{
    [[NSUserDefaults standardUserDefaults] setValue:imageName forKey:WALLPAPER_IMAGE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getChatWallpaperImageName{
    return [[NSUserDefaults standardUserDefaults] valueForKey:WALLPAPER_IMAGE];
}

+(void)setCustomMessageBackgroundColor:(UIColor *)color{
    
    NSData * recievedCustomBackgroundColorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setValue:recievedCustomBackgroundColorData
                                             forKey:CUSTOM_MSG_BACKGROUND_COLOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getCustomMessageBackgroundColor
{
    NSData *customMessageBackGroundColorData = [[NSUserDefaults standardUserDefaults]
                                                objectForKey:CUSTOM_MSG_BACKGROUND_COLOR];
    UIColor *customMessageBackGroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:customMessageBackGroundColorData];
    return customMessageBackGroundColor;
}

+(void)setGroupExitOption:(BOOL)option{
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:GROUP_EXIT_BUTTON];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getGroupExitOption{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GROUP_EXIT_BUTTON];
}

+(void)setGroupMemberAddOption:(BOOL)option{
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:GROUP_MEMBER_ADD_OPTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getGroupMemberAddOption{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GROUP_MEMBER_ADD_OPTION];
}

+(void)setGroupMemberRemoveOption:(BOOL)option{
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:GROUP_MEMBER_REMOVE_OPTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getGroupMemberRemoveOption{
    return [[NSUserDefaults standardUserDefaults] boolForKey:GROUP_MEMBER_REMOVE_OPTION];
}

+(void)setOnlineContactLimit:(NSInteger)limit
{
    [[NSUserDefaults standardUserDefaults] setInteger:limit forKey:ONLINE_CONTACT_LIMIT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSInteger)getOnlineContactLimit
{
    NSInteger maxLimit = [[NSUserDefaults standardUserDefaults] integerForKey:ONLINE_CONTACT_LIMIT];
    return maxLimit ? maxLimit : 0;
}

+(void)setContextualChat:(BOOL)option
{
    [[NSUserDefaults standardUserDefaults] setBool:option forKey:CONTEXTUAL_CHAT_OPTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getContextualChatOption
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:CONTEXTUAL_CHAT_OPTION];
}

+(NSString *)getCustomClassName
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:THIRD_PARTY_VC_NAME];
}

+(void)setCustomClassName:(NSString *)className
{
    [[NSUserDefaults standardUserDefaults] setValue:className forKey:THIRD_PARTY_VC_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)setCallOption:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:USER_CALL_OPTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getCallOption
{
     return [[NSUserDefaults standardUserDefaults] boolForKey:USER_CALL_OPTION];
}

/*
NOTIFICATION_ENABLE_SOUND = 0,
NOTIFICATION_DISABLE_SOUND = 1,
NOTIFICATION_DISABLE = 2
*/
+(void)enableNotificationSound
{
    [ALUserDefaultsHandler setNotificationMode:NOTIFICATION_ENABLE_SOUND];
}

+(void)disableNotificationSound
{
    [ALUserDefaultsHandler setNotificationMode:NOTIFICATION_DISABLE_SOUND];
}

+(void)enableNotification
{
    [ALUserDefaultsHandler setNotificationMode:NOTIFICATION_ENABLE];
}

+(void)disableNotification
{
    [ALUserDefaultsHandler setNotificationMode:NOTIFICATION_DISABLE];
}

+(void)setColorForSendButton:(UIColor *)color
{
    NSData * colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:SEND_BUTTON_BG_COLOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getColorForSendButton
{
    NSData * colorData = [[NSUserDefaults standardUserDefaults] objectForKey:SEND_BUTTON_BG_COLOR];
    UIColor * color = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    return color;
}

+(void)setColorForTypeMsgBackground:(UIColor *)viewColor
{
    NSData * viewColorData = [NSKeyedArchiver archivedDataWithRootObject:viewColor];
    [[NSUserDefaults standardUserDefaults] setObject:viewColorData forKey:TYPE_MSG_BG_COLOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getColorForTypeMsgBackground
{
    NSData * viewColorData = [[NSUserDefaults standardUserDefaults] objectForKey:TYPE_MSG_BG_COLOR];
    UIColor * viewColor = [NSKeyedUnarchiver unarchiveObjectWithData:viewColorData];
    return viewColor ? viewColor : [UIColor lightGrayColor];
}

+(void)setBGColorForTypingLabel:(UIColor *)bgColor
{
    NSData * bgColorData = [NSKeyedArchiver archivedDataWithRootObject:bgColor];
    [[NSUserDefaults standardUserDefaults] setObject:bgColorData forKey:TYPING_LABEL_BG_COLOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getBGColorForTypingLabel
{
    NSData * bgColorData = [[NSUserDefaults standardUserDefaults] objectForKey:TYPING_LABEL_BG_COLOR];
    UIColor * bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:bgColorData];
    return bgColor ? bgColor : [UIColor colorWithRed:242/255.0 green:242/255.0  blue:242/255.0 alpha:1];
}

+(void)setTextColorForTypingLabel:(UIColor *)txtColor
{
    NSData * txtColorData = [NSKeyedArchiver archivedDataWithRootObject:txtColor];
    [[NSUserDefaults standardUserDefaults] setObject:txtColorData forKey:TYPING_LABEL_TEXT_COLOR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getTextColorForTypingLabel
{
    NSData * txtColorData = [[NSUserDefaults standardUserDefaults] objectForKey:TYPING_LABEL_TEXT_COLOR];
    UIColor * txtColor = [NSKeyedUnarchiver unarchiveObjectWithData:txtColorData];
    return txtColor ? txtColor : [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:0.5];
}

+(void)setEmptyConversationText:(NSString *)text
{
    [[NSUserDefaults standardUserDefaults] setValue:text forKey:EMPTY_CONVERSATION_TEXT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getEmptyConversationText
{
    NSString * text = [[NSUserDefaults standardUserDefaults] valueForKey:EMPTY_CONVERSATION_TEXT];
    return text ? text : @"You have no conversations yet";
}

+(void)setVisibilityNoConversationLabelChatVC:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:NO_CONVERSATION_FLAG_CHAT_VC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getVisibilityNoConversationLabelChatVC
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:NO_CONVERSATION_FLAG_CHAT_VC];
}

+(void)setVisibilityForOnlineIndicator:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:ONLINE_INDICATOR_VISIBILITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getVisibilityForOnlineIndicator
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:ONLINE_INDICATOR_VISIBILITY];
}

+(void)setVisibilityForNoMoreConversationMsgVC:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:NO_MORE_CONVERSATION_VISIBILITY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getVisibilityForNoMoreConversationMsgVC
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:NO_MORE_CONVERSATION_VISIBILITY];
}

+(void)setCustomNavRightButtonMsgVC:(BOOL)flag
{
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:CUSTOM_NAV_RIGHT_BUTTON_MSGVC];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getCustomNavRightButtonMsgVC
{
   return [[NSUserDefaults standardUserDefaults] boolForKey:CUSTOM_NAV_RIGHT_BUTTON_MSGVC];
}

+(void)setColorForToastBackground:(UIColor *)toastBGColor
{
    NSData * toastBGData = [NSKeyedArchiver archivedDataWithRootObject:toastBGColor];
    [[NSUserDefaults standardUserDefaults] setObject:toastBGData forKey:TOAST_BG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getColorForToastBackground
{
    NSData * toastBGData = [[NSUserDefaults standardUserDefaults] objectForKey:TOAST_BG_COLOUR];
    UIColor * toastBGColor = [NSKeyedUnarchiver unarchiveObjectWithData:toastBGData];
    return toastBGColor ? toastBGColor : [UIColor grayColor];
}

+(void)setColorForToastText:(UIColor *)toastTextColor
{
    NSData * toastTextData = [NSKeyedArchiver archivedDataWithRootObject:toastTextColor];
    [[NSUserDefaults standardUserDefaults] setObject:toastTextData forKey:TOAST_TEXT_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getColorForToastText
{
    NSData * toastTextData = [[NSUserDefaults standardUserDefaults] objectForKey:TOAST_TEXT_COLOUR];
    UIColor * toastTextColor = [NSKeyedUnarchiver unarchiveObjectWithData:toastTextData];
    return toastTextColor ? toastTextColor : [UIColor blackColor];
}

+(void)setSendMsgTextColor:(UIColor *)sendMsgColor
{
    NSData *sendColorData = [NSKeyedArchiver archivedDataWithRootObject:sendMsgColor];
    [[NSUserDefaults standardUserDefaults] setObject:sendColorData forKey:SEND_MSG_TEXT_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getSendMsgTextColor
{
    NSData *sendColorData = [[NSUserDefaults standardUserDefaults] objectForKey:SEND_MSG_TEXT_COLOUR];
    UIColor *sendColor = [NSKeyedUnarchiver unarchiveObjectWithData:sendColorData];
    return sendColor ? sendColor : [UIColor whiteColor];
}

+(void)setReceiveMsgTextColor:(UIColor *)receiveMsgColor
{
    NSData *receiveColorData = [NSKeyedArchiver archivedDataWithRootObject:receiveMsgColor];
    [[NSUserDefaults standardUserDefaults] setObject:receiveColorData forKey:RECEIVE_MSG_TEXT_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getReceiveMsgTextColor
{
    NSData *receiveColorData = [[NSUserDefaults standardUserDefaults] objectForKey:RECEIVE_MSG_TEXT_COLOUR];
    UIColor *receiveColor = [NSKeyedUnarchiver unarchiveObjectWithData:receiveColorData];
    return receiveColor ? receiveColor : [UIColor grayColor];
}

+(void)setMsgTextViewBGColor:(UIColor *)color
{
    NSData * colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:MSG_TEXT_BG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getMsgTextViewBGColor
{
    NSData * colorData = [[NSUserDefaults standardUserDefaults] objectForKey:MSG_TEXT_BG_COLOUR];
    UIColor * bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    return bgColor ? bgColor : [UIColor whiteColor];
}

+(void)setPlaceHolderColor:(UIColor *)color
{
    NSData * colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:PLACE_HOLDER_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getPlaceHolderColor
{
    NSData * colorData = [[NSUserDefaults standardUserDefaults] objectForKey:PLACE_HOLDER_COLOUR];
    UIColor * bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    return bgColor ? bgColor : [UIColor grayColor];
}

+(void)setUnreadCountLabelBGColor:(UIColor *)color
{
    NSData * colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:UNREAD_COUNT_LABEL_BG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getUnreadCountLabelBGColor
{
    NSData * colorData = [[NSUserDefaults standardUserDefaults] objectForKey:UNREAD_COUNT_LABEL_BG_COLOUR];
    UIColor * bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    return bgColor ? bgColor : [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1];
}

+(void)setStatusBarBGColor:(UIColor *)color
{
    NSData * colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:STATUS_BAR_BG_COLOUR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIColor *)getStatusBarBGColor
{
    NSData * colorData = [[NSUserDefaults standardUserDefaults] objectForKey:STATUS_BAR_BG_COLOUR];
    UIColor * bgColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    return bgColor ? bgColor : [self getColorForNavigation];
}

+(void)setStatusBarStyle:(UIStatusBarStyle)style
{
    [[NSUserDefaults standardUserDefaults] setInteger:style forKey:STATUS_BAR_STYLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(UIStatusBarStyle)getStatusBarStyle
{
    UIStatusBarStyle style = [[NSUserDefaults standardUserDefaults] integerForKey:STATUS_BAR_STYLE];
    return style ? style : UIStatusBarStyleDefault;
}

+(void)setMaxTextViewLines:(int)numberOfLines
{
    [[NSUserDefaults standardUserDefaults] setInteger:numberOfLines forKey:MAX_TEXT_VIEW_LINES];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(int)getMaxTextViewLines
{
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:MAX_TEXT_VIEW_LINES]?[[NSUserDefaults standardUserDefaults] integerForKey:MAX_TEXT_VIEW_LINES]:4;
}


@end
