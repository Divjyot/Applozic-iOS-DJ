//
//  ALNewContactsViewController.m
//  ChatApp
//
//  Created by Gaurav Nigam on 16/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALNewContactsViewController.h"
#import "ALNewContactCell.h"
#import "ALDBHandler.h"
#import "DB_CONTACT.h"
#import "ALContact.h"
#import "ALChatViewController.h"
#import "ALUtilityClass.h"
#import "ALConstant.h"
#import "ALUserDefaultsHandler.h"
#import "ALMessagesViewController.h"
#import "ALColorUtility.h"
#import "UIImageView+WebCache.h"
#import "ALGroupCreationViewController.h"
#import "ALGroupDetailViewController.h"
#import "ALContactDBService.h"
#import "TSMessage.h"
#import "ALDataNetworkConnection.h"
#import "ALNotificationView.h"
#import "ALUserService.h"


#define DEFAULT_TOP_LANDSCAPE_CONSTANT -34
#define DEFAULT_TOP_PORTRAIT_CONSTANT -64

#define SHOW_CONTACTS 101
#define SHOW_GROUP 102

@interface ALNewContactsViewController ()

@property (strong, nonatomic) NSMutableArray *contactList;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *filteredContactList;

@property (strong, nonatomic) NSString *stopSearchText;

@property  NSUInteger lastSearchLength;

@property (strong,nonatomic)NSMutableArray* groupMembers;
@property (strong,nonatomic)ALChannelService * creatingChannel;

@property (strong,nonatomic) NSNumber* groupOrContacts;
@property (strong, nonatomic) NSMutableArray *alChannelsList;
@property (nonatomic)NSInteger selectedSegment;
@property (strong, nonatomic) UILabel *emptyConversationText;
@end

@implementation ALNewContactsViewController
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self activityIndicator] startAnimating];
    self.selectedSegment = 0;
    UIColor *color = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
    
    if (!color) {
        color = [UIColor blackColor];
    }
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.navigationItem.title = @"Contacts";
    self.contactList = [NSMutableArray new];
    [self handleFrameForOrientation];
    
    //    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    //    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    //    if(![ALUserDefaultsHandler getContactViewLoaded] && [ALApplozicSettings getFilterContactsStatus]) // COMMENTED for INTERNAL PURPOSE
    //    {
    if([ALApplozicSettings getFilterContactsStatus])
    {
        ALUserService * userService = [ALUserService new];
        [userService getListOfRegisteredUsersWithCompletion:^(NSError *error) {
            
            if(error)
            {
                [self.activityIndicator stopAnimating];
                [self.emptyConversationText setHidden:NO];
                [self.emptyConversationText setText:@"Unable to fetch contacts"];
                [self onlyGroupFetch];
                return;
            }
            [self subProcessContactFetch];
        }];
    }
    else if([ALApplozicSettings getOnlineContactLimit])
    {
        [self processFilterListWithLastSeen];
        [self onlyGroupFetch];
    }
    else
    {
        [self subProcessContactFetch];
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setCustomBackButton:@"Back"]];
    [self.navigationItem setLeftBarButtonItem: barButtonItem];
    
    float y = self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,y, self.view.frame.size.width, 40)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Email, userid, number";
    [self.view addSubview:self.searchBar];
    self.colors = [[NSArray alloc] initWithObjects:@"#617D8A",@"#628B70",@"#8C8863",@"8B627D",@"8B6F62", nil];
    
    self.groupMembers=[[NSMutableArray alloc] init];
    
    [self emptyConversationAlertLabel];
}

-(void)subProcessContactFetch
{
    ALChannelDBService * alChannelDBService = [[ALChannelDBService alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchConversationsGroupByContactId];
        self.alChannelsList = [NSMutableArray arrayWithArray:[alChannelDBService getAllChannelKeyAndName]];
    });
}

-(void)onlyGroupFetch
{
    ALChannelDBService * alChannelDBService = [[ALChannelDBService alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alChannelsList = [NSMutableArray arrayWithArray:[alChannelDBService getAllChannelKeyAndName]];
    });
}

- (void) dismissKeyboard
{
    // add self
    [self.searchBar resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    self.groupOrContacts = [NSNumber numberWithInt:SHOW_CONTACTS]; //default
    self.navigationItem.leftBarButtonItem = nil;
    
    [self.tabBarController.tabBar setHidden: [ALUserDefaultsHandler isBottomTabBarHidden]];
    
    if([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem])
    {
        //        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [ALApplozicSettings getColorForNavigationItem], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:18]}];
        [self.navigationController.navigationBar addSubview:[ALUtilityClass setStatusBarStyle]];
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColorForNavigationItem]];
        
    }
    
    BOOL groupRegular = [self.forGroup isEqualToNumber:[NSNumber numberWithInt:REGULAR_CONTACTS]];
    if((!groupRegular && self.forGroup != NULL)){
        [self updateView];
    }
    
    if(![ALApplozicSettings getGroupOption]){
        [self.navigationItem setTitle:@"Contacts"];
        [self.segmentControl setSelectedSegmentIndex:0];
        [self.segmentControl setHidden:YES];
    }
    
}

- (void)updateView
{
    [self.tabBarController.tabBar setHidden:YES];
    [self.segmentControl setSelectedSegmentIndex:0];
    [self.segmentControl setHidden:YES];
    
    BOOL groupCreation = [self.forGroup isEqualToNumber:[NSNumber numberWithInt:GROUP_CREATION]];
    if (groupCreation)
    {
        self.contactsTableView.editing=YES;
        self.contactsTableView.allowsMultipleSelectionDuringEditing = YES;
        self.done = [[UIBarButtonItem alloc]
                     initWithTitle:@"Done"
                     style:UIBarButtonItemStylePlain
                     target:self
                     action:@selector(createNewGroup:)];
        
        self.navigationItem.rightBarButtonItem = self.done;
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden: NO];
    self.forGroup = [NSNumber numberWithInt:0];
}

-(void)emptyConversationAlertLabel
{
    if(self.filteredContactList.count)
    {
        return;
    }
    self.emptyConversationText = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                           self.view.frame.origin.y + self.view.frame.size.height/2,
                                                                           self.view.frame.size.width, 30)];
    
    [self.emptyConversationText setText:@"No contact found"];
    [self.emptyConversationText setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.emptyConversationText];
    [self.emptyConversationText setHidden:YES];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contactsTableView?1:0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = self.filteredContactList.count;
    if(self.selectedSegment == 1)
    {
        count = self.filteredContactList.count;
    }
    if(count == 0)
    {
        if(![self.activityIndicator isAnimating]){
            [self.emptyConversationText setHidden:NO];
        }
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *individualCellIdentifier = @"NewContactCell";
    ALNewContactCell *newContactCell = (ALNewContactCell *)[tableView dequeueReusableCellWithIdentifier:individualCellIdentifier];
    NSUInteger randomIndex = random()% [self.colors count];
    UILabel* nameIcon = (UILabel*)[newContactCell viewWithTag:101];
    [nameIcon setTextColor:[UIColor whiteColor]];
    [nameIcon setHidden:YES];
    [newContactCell.contactPersonImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
    
    [newContactCell.contactPersonImageView setHidden:NO];
    newContactCell.contactPersonImageView.layer.cornerRadius = newContactCell.contactPersonImageView.frame.size.width/2;
    newContactCell.contactPersonImageView.layer.masksToBounds = YES;
    
    [self.emptyConversationText setHidden:YES];
    [self.contactsTableView setHidden:NO];
    switch (self.groupOrContacts.intValue)
    {
        case SHOW_CONTACTS:
        {
            ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
            newContactCell.contactPersonName.text = [contact getDisplayName];
            
            
            if (contact)
            {
                if (contact.contactImageUrl)
                {
                    [newContactCell.contactPersonImageView sd_setImageWithURL:[NSURL URLWithString:contact.contactImageUrl]];
                }
                else
                {
                    [nameIcon setHidden:NO];
                    [newContactCell.contactPersonImageView setImage:[ALColorUtility imageWithSize:CGRectMake(0, 0, 55, 55) WithHexString:self.colors[randomIndex]]];
                    [newContactCell.contactPersonImageView addSubview:nameIcon];
                    [nameIcon  setText:[ALColorUtility getAlphabetForProfileImage:[contact getDisplayName]]];
                }
                
                if(self.forGroup.intValue == GROUP_ADDITION && [self.contactsInGroup containsObject:contact.userId])
                {
                    newContactCell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
                    newContactCell.selectionStyle = UITableViewCellSelectionStyleNone ;
                }
                else if(self.forGroup.intValue == GROUP_CREATION && [contact.userId isEqualToString:[ALUserDefaultsHandler getUserId]]){
                    [self disableOrRemoveCell:newContactCell];
                }
                else
                {
                    newContactCell.backgroundColor = [UIColor whiteColor];
                    newContactCell.selectionStyle = UITableViewCellSelectionStyleGray ;
                }
                
            }
        }break;
        case SHOW_GROUP:
        {
            if(self.filteredContactList.count)
            {
                ALChannel * channel = [self.filteredContactList objectAtIndex:indexPath.row];
                newContactCell.contactPersonName.text = [channel name];
                [newContactCell.contactPersonImageView setImage:[UIImage imageNamed:@"applozic_group_icon.png"]];
                [nameIcon setHidden:YES];
            }
            else
            {
                [self.contactsTableView setHidden:YES];
                [self.emptyConversationText setHidden:NO];
            }
        }break;
        default:
            break;
    }
    
    return newContactCell;
}
-(void)disableOrRemoveCell:(ALNewContactCell*)contactCell{
    contactCell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    [contactCell setUserInteractionEnabled:NO];
    
}

-(void)maskOutCell:(ALNewContactCell*)contactCell{
    contactCell.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    contactCell.selectionStyle = UITableViewCellSelectionStyleNone ;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (self.forGroup.intValue){
            
        case GROUP_CREATION:{
            ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
            [self.groupMembers addObject:contact.userId];
        }break;
        case GROUP_ADDITION:
        {
            if(![self checkInternetConnectivity:tableView andIndexPath:indexPath]){
                return;
            }
            
            ALContact * contact = self.filteredContactList[indexPath.row];
            
            if([self.contactsInGroup containsObject:contact.userId]){
                return;
            }
            
            [self turnUserInteractivityForNavigationAndTableView:NO];
            [delegate addNewMembertoGroup:contact withComletion:^(NSError *error, ALAPIResponse *response) {
                
                if(error)
                {
                    [TSMessage showNotificationWithTitle:@"Unable to add new member" type:TSMessageNotificationTypeError];
                    [self setUserInteraction:YES];
                }
                else
                {
                    
                    [self backToDetailView];
                    [self turnUserInteractivityForNavigationAndTableView:YES];
                    [self setUserInteraction:YES];
                }
                
            }];
        }
            break;
        default:
        { //DEFAULT : Launch contact!
            NSNumber * key = nil;
            NSString * userId = @"";
            if(self.selectedSegment == 0)
            {
                ALContact * selectedContact = self.filteredContactList[indexPath.row];
                userId = selectedContact.userId;
            }
            else
            {
                ALChannel * selectedChannel = self.filteredContactList[indexPath.row];
                key = selectedChannel.key;
                userId = nil;
            }
            [self launchChatForContact:userId withChannelKey:key];
        }
            
    }
}

-(void)setUserInteraction:(BOOL)flag
{
    [self.contactsTableView setUserInteractionEnabled:flag];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.forGroup isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        ALContact * contact = [self.filteredContactList objectAtIndex:indexPath.row];
        [self.groupMembers removeObject:contact.userId];
    }
}

-(BOOL)checkInternetConnectivity:(UITableView*)tableView andIndexPath:(NSIndexPath *)indexPath{
    
    if(![ALDataNetworkConnection checkDataNetworkAvailable]){
        [[self activityIndicator] stopAnimating];
        ALNotificationView * notification = [ALNotificationView new];
        [notification noDataConnectionNotificationView];
        if(tableView){
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        return NO;
    }
    return YES;
}

-(void) fetchConversationsGroupByContactId
{
    
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    
    // get all unique contacts
    
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CONTACT"];
    
    [theRequest setReturnsDistinctResults:YES];
    
    if(![ALUserDefaultsHandler getLoginUserConatactVisibility])
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId!=%@",[ALUserDefaultsHandler getUserId]];
        [theRequest setPredicate:predicate];
    }
    
    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    
    for (DB_CONTACT *dbContact in theArray)
    {

        ALContact *contact = [[ALContact alloc] init];
        
        contact.userId = dbContact.userId;
        contact.fullName = dbContact.fullName;
        contact.contactNumber = dbContact.contactNumber;
        contact.displayName = dbContact.displayName;
        contact.contactImageUrl = dbContact.contactImageUrl;
        contact.email = dbContact.email;
        contact.localImageResourceName = dbContact.localImageResourceName;

        [self.contactList addObject:contact];
    }
    
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    self.filteredContactList = [NSMutableArray arrayWithArray:[self.contactList sortedArrayUsingDescriptors:descriptors]];
    [self.contactList removeAllObjects];
    self.contactList = [NSMutableArray arrayWithArray:self.filteredContactList];
    
    [[self activityIndicator] stopAnimating];
    [self.contactsTableView reloadData];
    
}

#pragma mark orientation method
//=============================
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self handleFrameForOrientation];
    
}

-(void)handleFrameForOrientation {
    
    UIInterfaceOrientation toOrientation   = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone && (toOrientation == UIInterfaceOrientationLandscapeLeft || toOrientation == UIInterfaceOrientationLandscapeRight)) {
        self.mTableViewTopConstraint.constant = DEFAULT_TOP_LANDSCAPE_CONSTANT;
    }else{
        self.mTableViewTopConstraint.constant = DEFAULT_TOP_PORTRAIT_CONSTANT;
    }
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
    ALChatViewController * theVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    theVC.contactIds = searchBar.text;
    
}

#pragma mark - Search Bar Delegate Methods -
//========================================
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.stopSearchText = searchText;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getSerachResult:searchText];
    });
    
}

-(void)getSerachResult:(NSString*)searchText
{
    
    if (searchText.length != 0)
    {
        NSPredicate * searchPredicate;
        
        if(self.selectedSegment == 0)
        {
            searchPredicate = [NSPredicate predicateWithFormat:@"email CONTAINS[cd] %@ OR userId CONTAINS[cd] %@ OR contactNumber CONTAINS[cd] %@ OR fullName CONTAINS[cd] %@", searchText, searchText, searchText,searchText];
        }
        else
        {
            searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
        }
        
        if(self.lastSearchLength > searchText.length)
        {
            NSArray * searchResults;
            if(self.selectedSegment == 0)
            {
                searchResults = [self.contactList filteredArrayUsingPredicate:searchPredicate];
            }
            else
            {
                searchResults = [self.alChannelsList filteredArrayUsingPredicate:searchPredicate];
            }
            [self.filteredContactList removeAllObjects];
            [self.filteredContactList addObjectsFromArray:searchResults];
        }
        else
        {
            NSArray *searchResults;
            if(self.selectedSegment == 0)
            {
                searchResults = [self.contactList filteredArrayUsingPredicate:searchPredicate];
            }
            else
            {
                searchResults = [self.alChannelsList filteredArrayUsingPredicate:searchPredicate];
            }
            [self.filteredContactList removeAllObjects];
            [self.filteredContactList addObjectsFromArray:searchResults];
        }
    }
    else
    {
        [self.filteredContactList removeAllObjects];
        if(self.selectedSegment == 0)
        {
            [self.filteredContactList addObjectsFromArray:self.contactList];
        }
        else
        {
            [self.filteredContactList addObjectsFromArray:self.alChannelsList];
        }
        
    }
    
    self.lastSearchLength = searchText.length;
    [self.contactsTableView reloadData];
}


-(void)back:(id)sender {
    
    UIViewController * viewControllersFromStack = [self.navigationController popViewControllerAnimated:YES];
    if(!viewControllersFromStack){
        self.tabBarController.selectedIndex = 0;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

-(void)launchChatForContact:( NSString *)contactId  withChannelKey:(NSNumber*)channelKey {
    
    BOOL isFoundInBackStack =false;
    NSMutableArray *viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
    for (UIViewController *currentVC in viewControllersFromStack){
        if ([currentVC isKindOfClass:[ALMessagesViewController class]]){
            [(ALMessagesViewController*)currentVC setChannelKey:channelKey];
            NSLog(@"found in backStack .....launching from current vc");
            [(ALMessagesViewController*) currentVC createDetailChatViewController:contactId];
            isFoundInBackStack = true;
        }
    }
    if(!isFoundInBackStack){
        NSLog(@"Not found in backStack .....");
        self.tabBarController.selectedIndex=0;
        UINavigationController * uicontroller =  self.tabBarController.selectedViewController;
        NSMutableArray *viewControllersFromStack = [uicontroller.childViewControllers mutableCopy];
        
        for (UIViewController *currentVC in viewControllersFromStack){
            if ([currentVC isKindOfClass:[ALMessagesViewController class]]){
                [(ALMessagesViewController*)currentVC setChannelKey:channelKey];
                NSLog(@"f####ound in backStack .....launching from current vc");
                [(ALMessagesViewController*) currentVC createDetailChatViewController:contactId];
                isFoundInBackStack = true;
            }
        }
    }else{
        //remove ALNewContactsViewController from back stack...
        
        viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
        if(viewControllersFromStack.count >=2 && [ [viewControllersFromStack objectAtIndex:viewControllersFromStack.count -2] isKindOfClass:[ALNewContactsViewController class]]){
            [ viewControllersFromStack removeObjectAtIndex:viewControllersFromStack.count -2];
            self.navigationController.viewControllers = viewControllersFromStack;
            
        }
    }
}

-(UIView *)setCustomBackButton:(NSString *)text
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [ALUtilityClass getImageFromFramworkBundle:@"bbb.png"]];
    [imageView setFrame:CGRectMake(-10, 0, 30, 30)];
    [imageView setTintColor:[UIColor whiteColor]];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - 5, imageView.frame.origin.y + 5 , @"back".length, 15)];
    [label setTextColor: [ALApplozicSettings getColorForNavigationItem]];
    [label setText:text];
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width + label.frame.size.width, imageView.frame.size.height)];
    view.bounds=CGRectMake(view.bounds.origin.x+8, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    [view addSubview:label];
    
    UIButton *button=[[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
    
}

#pragma mark- Segment Control
//===========================
- (IBAction)segmentControlAction:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    self.selectedSegment = segmentedControl.selectedSegmentIndex;
    [self.filteredContactList removeAllObjects];
    if (self.selectedSegment == 0) {
        //toggle the Contacts view to be visible
        self.groupOrContacts = [NSNumber numberWithInt:SHOW_CONTACTS];
        self.filteredContactList = [NSMutableArray arrayWithArray: self.contactList];
    }
    else{
        //toggle the Group view to be visible
        self.groupOrContacts = [NSNumber numberWithInt:SHOW_GROUP];
        self.filteredContactList = [NSMutableArray arrayWithArray: self.alChannelsList];
    }
    [self.contactsTableView reloadData];
}

#pragma mark - Create group method
//================================
-(void)createNewGroup:(id)sender{
    
    if(![self checkInternetConnectivity:nil andIndexPath:nil]){
        return;
    }
    
    [self turnUserInteractivityForNavigationAndTableView:NO];
    //check whether at least two memebers selected
    if(self.groupMembers.count < 2)
    {
        [self turnUserInteractivityForNavigationAndTableView:YES];
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Group Members"
                                              message:@"Please select minimum two members"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
        
    }
    
    //Server Call
    self.creatingChannel = [[ALChannelService alloc] init];
    [self.creatingChannel createChannel:self.groupName orClientChannelKey:nil andMembersList:self.groupMembers withCompletion:^(ALChannel *alChannel) {
        
        if(alChannel)
        {
            //Updating view, popping to MessageList View
            NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            
            for (UIViewController *aViewController in allViewControllers)
            {
                if ([aViewController isKindOfClass:[ALMessagesViewController class]])
                {
                    ALMessagesViewController * messageVC = (ALMessagesViewController *)aViewController;
                    [messageVC insertChannelMessage:alChannel.key];
                    [self.navigationController popToViewController:aViewController animated:YES];
                }
            }
        }
        else
        {
            [TSMessage showNotificationWithTitle:@"Unable to create group. Please try again" type:TSMessageNotificationTypeError];
            [self turnUserInteractivityForNavigationAndTableView:YES];
        }
        
        [[self activityIndicator] stopAnimating];
        
    }];
    
    
    
    if(![ALDataNetworkConnection checkDataNetworkAvailable])
    {
        [self turnUserInteractivityForNavigationAndTableView:YES];
    }
    
    
}

-(void)turnUserInteractivityForNavigationAndTableView:(BOOL)option{
    
    [self.contactsTableView setUserInteractionEnabled:option];
    [[[self navigationController] navigationBar] setUserInteractionEnabled:option];
    [[self searchBar] setUserInteractionEnabled:option];
    [[self searchBar] resignFirstResponder];
    if(option == YES){
        [[self activityIndicator] stopAnimating];
    }
    else{
        [[self activityIndicator] startAnimating];
    }
    
}


# pragma mark - Dummy group message method
//========================================
-(void) addDummyMessage:(NSNumber *)channelKey
{
    ALDBHandler * theDBHandler = [ALDBHandler sharedInstance];
    ALMessageDBService* messageDBService = [[ALMessageDBService alloc]init];
    
    ALMessage * theMessage = [ALMessage new];
    theMessage.createdAtTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
    theMessage.deviceKey = [ALUserDefaultsHandler getDeviceKeyString];
    theMessage.sendToDevice = NO;
    theMessage.shared = NO;
    theMessage.fileMeta = nil;
    theMessage.key = @"welcome-message-temp-key-string";
    theMessage.fileMetaKey = @"";//4
    theMessage.contentType = 0;
    theMessage.type = @"101";
    theMessage.message = @"You have created a new group, Say Hi to members :)";
    theMessage.groupId = channelKey;
    theMessage.status = [NSNumber numberWithInt:DELIVERED_AND_READ];
    theMessage.sentToServer = TRUE;
    
    //UI update...
    NSMutableArray* updateArr=[[NSMutableArray alloc] initWithObjects:theMessage, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:updateArr];
    
    //db insertion..
    [messageDBService createMessageEntityForDBInsertionWithMessage:theMessage];
    [theDBHandler.managedObjectContext save:nil];
    
}

#pragma mar - Member Addition to group
//====================================
-(void)backToDetailView{
    
    self.forGroup = [NSNumber numberWithInt:0];
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[ALGroupDetailViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:YES];
        }
    }
}

-(void)processFilterListWithLastSeen
{
    ALUserService * userService = [ALUserService new];
    [userService fetchOnlineContactFromServer:^(NSMutableArray * array, NSError * error) {
        
        if(error)
        {
            [self.activityIndicator stopAnimating];
            [self.emptyConversationText setHidden:NO];
            [self.emptyConversationText setText:@"Unable to fetch contacts"];
            return;
        }
        
        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastSeenAt" ascending:NO];
        NSArray * descriptors = [NSArray arrayWithObject:sortDescriptor];
        self.filteredContactList = [NSMutableArray arrayWithArray:[array sortedArrayUsingDescriptors:descriptors]];
        NSLog(@"ARRAY_COUNT : %lu",(unsigned long)self.filteredContactList.count);
        [[self activityIndicator] stopAnimating];
        [self.contactsTableView reloadData];
        [self emptyConversationAlertLabel];
        
    }];
}

@end
