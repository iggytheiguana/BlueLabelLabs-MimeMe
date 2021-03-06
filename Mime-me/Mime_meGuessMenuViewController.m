//
//  Mime_meGuessMenuViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/5/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meGuessMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime_meCreateMimeViewController.h"
#import "Mime_meGuessFullTableViewController.h"
#import "Mime_meSettingsViewController.h"
#import "Mime_meAppDelegate.h"
#import "Attributes.h"
#import "Macros.h"
#import "Mime.h"
#import "MimeAnswer.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "DateTimeHelper.h"
#import "UIImage+UIImageCategory.h"
#import "Mime_meViewMimeViewController.h"
#import "MimeAnswerState.h"
#import "MimeType.h"

#define kMIMEFRC @"mimefrc"

#define kMIMEANSWERID @"mimeanswerid"
#define kMIMEID @"mimeid"

#define kMAXROWS 3
//#define kMAXROWSFRIENDS 5

@interface Mime_meGuessMenuViewController ()

@end

@implementation Mime_meGuessMenuViewController
@synthesize frc_mimeAnswersFromFriends  = __frc_mimeAnswersFromFriends;
@synthesize frc_recentMimes             = __frc_recentMimes;
@synthesize frc_staffPickedMimes        = __frc_staffPickedMimes;
@synthesize frc_topFavoriteMimes        = __frc_topFavoriteMimes;

@synthesize mimeAnswersCloudEnumerator  = m_mimeAnswersCloudEnumerator;
@synthesize recentMimesCloudEnumerator  = m_recentMimesCloudEnumerator;
@synthesize staffPickedMimesCloudEnumerator = m_staffPickedMimesCloudEnumerator;
@synthesize topFavoriteMimesCloudEnumerator = m_topFavoriteMimesCloudEnumerator;

@synthesize nv_navigationHeader = m_nv_navigationHeader;

@synthesize tbl_mimes           = m_tbl_mimes;
@synthesize tc_friendsHeader    = m_tc_friendsHeader;
@synthesize tc_recentHeader     = m_tc_recentHeader;
@synthesize tc_staffPicksHeader = m_tc_staffPicksHeader;
@synthesize tc_topFavoritesHeader = m_tc_topFavoritesHeader;
@synthesize gad_bannerView      = m_gad_bannerView;

#pragma mark - FRCs
- (NSFetchedResultsController*)frc_mimeAnswersFromFriends {
    NSString* activityName = @"Mime_meGuessMenuViewController.frc_mimeAnswersFromFriends:";
    if (__frc_mimeAnswersFromFriends != nil) {
        return __frc_mimeAnswersFromFriends;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MIMEANSWER inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    NSNumber* unansweredStateObj = [NSNumber numberWithInt:kUNANSWERED];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@", TARGETUSERID, self.loggedInUser.objectid, STATE, unansweredStateObj];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:(kMAXROWS + 1)];    // We add 1 to find out if the "more" button should be shown
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_mimeAnswersFromFriends = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
    
  	if (error != nil)
    {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    else {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(0,@"%@ Successfully created NSFetchedResultsController with %d items found",activityName,[[controller fetchedObjects]count]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    [predicate release];
    return __frc_mimeAnswersFromFriends;
    
}

- (NSFetchedResultsController*)frc_recentMimes {
    NSString* activityName = @"Mime_meGuessMenuViewController.frc_recentMimes:";
    if (__frc_recentMimes != nil) {
        return __frc_recentMimes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MIME inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    NSNumber* hasAnsweredObj = [NSNumber numberWithBool:NO];
    NSNumber* isPublicObj = [NSNumber numberWithBool:YES];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K!=%@ AND %K=%@ AND %K=%@", CREATORID, self.loggedInUser.objectid, HASANSWERED, hasAnsweredObj, ISPUBLIC, isPublicObj];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:(kMAXROWS + 1)];    // We add 1 to find out if the "more" button should be shown
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_recentMimes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    [predicate release];
    return __frc_recentMimes;
    
}

- (NSFetchedResultsController*)frc_staffPickedMimes {
    NSString* activityName = @"Mime_meGuessMenuViewController.frc_staffPickedMimes:";
    if (__frc_staffPickedMimes != nil) {
        return __frc_staffPickedMimes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MIME inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    NSNumber* hasAnsweredObj = [NSNumber numberWithBool:NO];
    NSNumber* isStaffPickObj = [NSNumber numberWithBool:YES];
    NSNumber* isPublicObj = [NSNumber numberWithBool:YES];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K!=%@ AND %K=%@ AND %K=%@ AND %K=%@", CREATORID, self.loggedInUser.objectid, ISSTAFFPICK, isStaffPickObj, HASANSWERED, hasAnsweredObj, ISPUBLIC, isPublicObj];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:(kMAXROWS + 1)];    // We add 1 to find out if the "more" button should be shown
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_staffPickedMimes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    [predicate release];
    return __frc_staffPickedMimes;
    
}

- (NSFetchedResultsController*)frc_topFavoriteMimes {
    NSString* activityName = @"Mime_meGuessMenuViewController.frc_topFavoriteMimes:";
    if (__frc_topFavoriteMimes != nil) {
        return __frc_topFavoriteMimes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MIME inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NUMBEROFTIMESFAVORITED ascending:NO];
    
    NSNumber* hasAnsweredObj = [NSNumber numberWithBool:NO];
    NSNumber* minFavorited = [NSNumber numberWithInt:0];
    NSNumber* isPublicObj = [NSNumber numberWithBool:YES];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K!=%@ AND %K=%@ AND %K>%@ AND %K=%@", CREATORID, self.loggedInUser.objectid, HASANSWERED, hasAnsweredObj, NUMBEROFTIMESFAVORITED, minFavorited, ISPUBLIC, isPublicObj];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:(kMAXROWS + 1)];    // We add 1 to find out if the "more" button should be shown
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_topFavoriteMimes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    [predicate release];
    return __frc_topFavoriteMimes;
    
}

#pragma mark - Enumerators
- (void)showHUDForMimeEnumerators {
    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    NSString* message = @"Updating...";
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    
}

- (void) enumerateMimeAnswersFromFriends {    
    if (self.mimeAnswersCloudEnumerator != nil && [self.mimeAnswersCloudEnumerator canEnumerate]) {
        [self.mimeAnswersCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.mimeAnswersCloudEnumerator = nil;
        NSNumber* unansweredStateObj = [NSNumber numberWithInt:kUNANSWERED];
        self.mimeAnswersCloudEnumerator = [CloudEnumerator enumeratorForMimeAnswersWithTarget:self.loggedInUser.objectid withState:unansweredStateObj];
        self.mimeAnswersCloudEnumerator.delegate = self;
        self.mimeAnswersCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:(kMAXROWS + 1)]; // We add 1 to find out if the "more" button should be shown
        [self.mimeAnswersCloudEnumerator enumerateUntilEnd:nil];
    }
}

- (void) enumerateRecentMimes {    
    if (self.recentMimesCloudEnumerator != nil && [self.recentMimesCloudEnumerator canEnumerate]) {
        [self.recentMimesCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.recentMimesCloudEnumerator = nil;
        self.recentMimesCloudEnumerator = [CloudEnumerator enumeratorForMostRecentMimes];
        self.recentMimesCloudEnumerator.delegate = self;
        self.recentMimesCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:(kMAXROWS + 1)];    // We add 1 to find out if the "more" button should be shown
        [self.recentMimesCloudEnumerator enumerateUntilEnd:nil];
    }
}

- (void) enumerateStaffPickedMimes { 
    if (self.staffPickedMimesCloudEnumerator != nil && [self.staffPickedMimesCloudEnumerator canEnumerate]) {
        [self.staffPickedMimesCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.staffPickedMimesCloudEnumerator = nil;
        self.staffPickedMimesCloudEnumerator = [CloudEnumerator enumeratorForStaffPickedMimes];
        self.staffPickedMimesCloudEnumerator.delegate = self;
        self.staffPickedMimesCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:(kMAXROWS + 1)];   // We add 1 to find out if the "more" button should be shown
        [self.staffPickedMimesCloudEnumerator enumerateUntilEnd:nil];
    }
}

- (void) enumerateTopFavoriteMimes { 
    if (self.topFavoriteMimesCloudEnumerator != nil && [self.topFavoriteMimesCloudEnumerator canEnumerate]) {
        [self.topFavoriteMimesCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.topFavoriteMimesCloudEnumerator = nil;
        self.topFavoriteMimesCloudEnumerator = [CloudEnumerator enumeratorForTopFavoritedMimes];
        self.topFavoriteMimesCloudEnumerator.delegate = self;
        self.topFavoriteMimesCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:(kMAXROWS + 1)];   // We add 1 to find out if the "more" button should be shown
        [self.topFavoriteMimesCloudEnumerator enumerateUntilEnd:nil];
    }
}

#pragma mark - Helper Methods
- (NSString*) getDateStringForMimeDate:(NSDate*)date {
    NSDate* now = [NSDate date];
    NSTimeInterval intervalSinceCreated = [now timeIntervalSinceDate:date];
    NSString* timeSinceCreated = nil;
    if (intervalSinceCreated < 1 ) {
        timeSinceCreated = @"a moment";
    }
    else {
        timeSinceCreated = [DateTimeHelper formatTimeInterval:intervalSinceCreated];
    }
    
    return [NSString stringWithFormat:@"%@ ago",timeSinceCreated];
}

- (void)initializeGADBannerView {
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    self.gad_bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Move the view into position at the bottom of the screen
    self.gad_bannerView.frame = CGRectMake(0.0, 430.0, 320.0, 50.0);
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    self.gad_bannerView.adUnitID = kGADPublisherID;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    self.gad_bannerView.rootViewController = self;
    
    // Add drop shadow to Ad view
    [self.gad_bannerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.gad_bannerView.layer setShadowOpacity:0.7f];
    [self.gad_bannerView.layer setShadowRadius:2.0f];
    [self.gad_bannerView.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [self.gad_bannerView.layer setMasksToBounds:NO];
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
    [self.gad_bannerView.layer setShadowPath:shadowPath];
    
    [self.view addSubview:self.gad_bannerView];
    
    // Initiate a generic request to load it with an ad.
    [self.gad_bannerView loadRequest:[GADRequest request]];
}

#pragma mark - View Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Set background pattern
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
    
    // Add rounded corners to view
    [self.view.layer setCornerRadius:8.0f];
    
    // Add the navigation header
    Mime_meUINavigationHeaderView *navigationHeader = [[Mime_meUINavigationHeaderView alloc]initWithFrame:[Mime_meUINavigationHeaderView frameForNavigationHeader]];
    navigationHeader.delegate = self;
    navigationHeader.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    navigationHeader.btn_back.hidden = YES;
    navigationHeader.btn_gemCount.hidden = NO;
    [navigationHeader.btn_gemCount setTitle:[self.loggedInUser.numberofpoints stringValue] forState:UIControlStateNormal];
    if ([self.loggedInUser.numberofpoints stringValue].length > 3) {
        navigationHeader.btn_gemCount.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    }
    self.nv_navigationHeader = navigationHeader;
    [self.view addSubview:self.nv_navigationHeader];
    [navigationHeader release];
    
    // Initialize Google AdMob Banner view
    [self initializeGADBannerView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.nv_navigationHeader = nil;
    
    self.tbl_mimes = nil;
    self.tc_friendsHeader = nil;
    self.tc_recentHeader = nil;
    self.tc_staffPicksHeader = nil;
    self.tc_topFavoritesHeader = nil;
    self.gad_bannerView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nv_navigationHeader.btn_guess setHighlighted:YES];
    [self.nv_navigationHeader.btn_guess setUserInteractionEnabled:NO];
    
    // Enumerate for Mimes from friends, recent and staff pick Mimes
    [self enumerateMimeAnswersFromFriends];
    [self enumerateRecentMimes];
    [self enumerateStaffPickedMimes];
    [self enumerateTopFavoriteMimes];
    
    [self showHUDForMimeEnumerators];
    
    // Update notifications and Gem count
    [self updateNotificationsAndGemCount];
    
    // Reload the tableview to update "new" badges
    [self.tbl_mimes reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    NSInteger rows;
    
    if (section == 0) {
        // From Friends section
        count = [[self.frc_mimeAnswersFromFriends fetchedObjects] count];
    }
    else if (section == 1) {
        // Recent section
        count = [[self.frc_recentMimes fetchedObjects] count];
    }
    else if (section == 2) {
        // Top Favorites section
        count = [[self.frc_topFavoriteMimes fetchedObjects] count];
    }
    else {
        // Staff Picks section
        count = [[self.frc_staffPickedMimes fetchedObjects] count];
    }
    
    if (count == 0) {
        rows = 2;   // 1. Header, and 2. None rows
    }
    else if (count <= kMAXROWS) {
        rows = count + 1;   // Add 1 for the header
    }
    else {
        rows = kMAXROWS + 2;    // Add 2 to the count to include 1. Header, and 2. More
    }
    
    return rows;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime *mime;
    
    ImageManager* imageManager = [ImageManager instance];
    NSDictionary* userInfo;
    
    BOOL hasSeen = NO;
    
    if (indexPath.section == 0) {
        // From Friends section
        MimeAnswer *mimeAnswer = [[self.frc_mimeAnswersFromFriends fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        // Get the Mime object associated with this MimeAnswer
        mime = (Mime*)[resourceContext resourceWithType:MIME withID:mimeAnswer.mimeid]; 
        
        NSString *creatorName = mimeAnswer.creatorname;
        cell.textLabel.text = creatorName;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mimeAnswer.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_mimeAnswersFromFriends, kMIMEFRC, mimeAnswer.objectid, kMIMEANSWERID, nil];
        
        hasSeen = [mimeAnswer.hasseen boolValue];
    }
    else if (indexPath.section == 1) {
        // Recent Mimes section
        mime = [[self.frc_recentMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        cell.textLabel.text = mime.creatorname;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_recentMimes, kMIMEFRC, mime.objectid, kMIMEID, nil];
        
        hasSeen = [mime.hasseen boolValue];
    }
    else if (indexPath.section == 2) {
        // Top Favorite Mimes section
        mime = [[self.frc_topFavoriteMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        cell.textLabel.text = mime.creatorname;
        
//        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
//        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        int numTimesFavorited = [mime.numberoftimesfavorited intValue];
        if (numTimesFavorited == 1) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Favorited %d time!", numTimesFavorited];
        }
        else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Favorited %d times!", numTimesFavorited];
        }
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_topFavoriteMimes, kMIMEFRC, mime.objectid, kMIMEID, nil];
        
        hasSeen = [mime.hasseen boolValue];
    }
    else if (indexPath.section == 3) {
        // Staff Picked Mimes section
        mime = [[self.frc_staffPickedMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        cell.textLabel.text = mime.creatorname;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_staffPickedMimes, kMIMEFRC, mime.objectid, kMIMEID, nil];
        
        hasSeen = [mime.hasseen boolValue];
    }
    
    // Set the mime image
    if (mime.thumbnailurl != nil && ![mime.thumbnailurl isEqualToString:@""]) {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
        callback.fireOnMainThread = YES;
        UIImage* image = [imageManager downloadImage:mime.thumbnailurl withUserInfo:nil atCallback:callback];
        [callback release];
        if (image != nil) {
            
            cell.imageView.image = [image imageScaledToSize:CGSizeMake(50, 50)];
        }
        else {
            cell.imageView.backgroundColor = [UIColor lightGrayColor];
            cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(50, 50)];
        }
        
        [self.view setNeedsDisplay];
    }
    
//    // Mark mime as "new" if user has not previously seen it
//    UILabel *lbl_new = (UILabel *)[cell.contentView viewWithTag:101];
//    if (hasSeen == NO) {
//        [lbl_new setHidden:NO];
//    }
//    else {
//        [lbl_new setHidden:YES];
//    }
    
    
    // Mark mime as "new" if user has not previously seen it
    if (hasSeen == NO) {
        UILabel *lbl_new = [[UILabel alloc] initWithFrame:CGRectMake(270.0f, 0.0f, 40.0f, 21.0f)];
        lbl_new.text = @"New!";
        lbl_new.backgroundColor = [UIColor clearColor];
        lbl_new.font =[UIFont systemFontOfSize:14.0f];
        lbl_new.adjustsFontSizeToFitWidth = YES;
        lbl_new.textColor = [UIColor blueColor];
        lbl_new.textAlignment = UITextAlignmentRight;
        
        cell.accessoryView = lbl_new;
        [lbl_new release];
    }
    else {
        cell.accessoryView = nil;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    
//    UILabel *lbl_new = [[UILabel alloc] initWithFrame:CGRectMake(235.0f, 0.0f, 40.0f, 21.0f)];
//    [lbl_new setTag:101];
//    lbl_new.text = @"New!";
//    lbl_new.backgroundColor = [UIColor clearColor];
//    lbl_new.font =[UIFont systemFontOfSize:14.0f];
//    lbl_new.textColor = [UIColor redColor];
//    lbl_new.textAlignment = UITextAlignmentRight;
    
    if (indexPath.section == 0) {
        // From Friends section
        
        NSInteger count = MIN([[self.frc_mimeAnswersFromFriends fetchedObjects]count], kMAXROWS);    // Maximize the number of friends to show
        
        if (indexPath.row == 0) {
            // Set the header
            CellIdentifier = @"FromFriendsHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_friendsHeader;
                
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Friend's mime
                    CellIdentifier = @"FriendsMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imageView.layer.masksToBounds = YES;
                        cell.imageView.layer.cornerRadius = 8.0;
                        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        cell.imageView.layer.borderWidth = 1.0;
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
//                        [cell.contentView addSubview:lbl_new];
                        
                    }
                    
                    [self configureCell:cell atIndexPath:indexPath];
                    
                    return cell;
                }
                else {
                    // Set More row
                    CellIdentifier = @"MoreFromFriends";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More from friends";
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.shadowColor = [UIColor whiteColor];
                        cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                        cell.textLabel.textColor = [UIColor lightGrayColor];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
            }
            else {
                // Set None row
                CellIdentifier = @"NoneFromFirends";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"Create a new mime!";
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    
                    cell.userInteractionEnabled = YES;
                }
                
                return cell;
            }
        }
    }
    if (indexPath.section == 1) {
        // Recent Mimes section
        
        NSInteger count = MIN([[self.frc_recentMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of recent mimes to show to 3
        
        if (indexPath.row == 0) {
            // Set the header
            CellIdentifier = @"MostRecentHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_recentHeader;
                
                // Cell properties
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Recent mime
                    CellIdentifier = @"RecentMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imageView.layer.masksToBounds = YES;
                        cell.imageView.layer.cornerRadius = 8.0;
                        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        cell.imageView.layer.borderWidth = 1.0;
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
//                        [cell.contentView addSubview:lbl_new];
                        
                    }
                    
                    [self configureCell:cell atIndexPath:indexPath];
                    
                    return cell;
                }
                else {
                    // Set More row
                    CellIdentifier = @"MoreFromRecent";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More recent mimes";
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.shadowColor = [UIColor whiteColor];
                        cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                        cell.textLabel.textColor = [UIColor lightGrayColor];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
            }
            else {
                // Set None row
                CellIdentifier = @"NoneRecent";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No recent mimes!";
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    
                    cell.userInteractionEnabled = NO;
                }
                
                return cell;
            }
        }
    }
    if (indexPath.section == 2) {
        // Top Favorite Mimes section
        
        NSInteger count = MIN([[self.frc_topFavoriteMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of recent mimes to show to 3
        
        if (indexPath.row == 0) {
            // Set the header
            CellIdentifier = @"TopFavoritesHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_topFavoritesHeader;
                
                // Cell properties
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Top Favorite mime
                    CellIdentifier = @"TopFavoriteMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imageView.layer.masksToBounds = YES;
                        cell.imageView.layer.cornerRadius = 8.0;
                        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        cell.imageView.layer.borderWidth = 1.0;
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                        //                        [cell.contentView addSubview:lbl_new];
                        
                    }
                    
                    [self configureCell:cell atIndexPath:indexPath];
                    
                    return cell;
                }
                else {
                    // Set More row
                    CellIdentifier = @"MoreTopFavorites";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More top favorited mimes";
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.shadowColor = [UIColor whiteColor];
                        cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                        cell.textLabel.textColor = [UIColor lightGrayColor];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
            }
            else {
                // Set None row
                CellIdentifier = @"NoneTopFavorited";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No top favorited mimes!";
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    
                    cell.userInteractionEnabled = NO;
                }
                
                return cell;
            }
        }
    }
    else {
        // Staff Picked Mimes section
        
        NSInteger count = MIN([[self.frc_staffPickedMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of staff pick mimes to show to 3
        
        if (indexPath.row == 0) {
            // Set the header
            CellIdentifier = @"StaffPicksHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_staffPicksHeader;
                
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Staff Picked mime
                    CellIdentifier = @"StaffPickMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imageView.layer.masksToBounds = YES;
                        cell.imageView.layer.cornerRadius = 8.0;
                        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        cell.imageView.layer.borderWidth = 1.0;
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
//                        [cell.contentView addSubview:lbl_new];
                        
                    }
                    
                    [self configureCell:cell atIndexPath:indexPath];
                    
                    return cell;
                }
                else {
                    // Set More row
                    CellIdentifier = @"MoreFromStaffPicks";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More staff picks";
                        cell.textLabel.textAlignment = UITextAlignmentCenter;
                        cell.textLabel.shadowColor = [UIColor whiteColor];
                        cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                        cell.textLabel.textColor = [UIColor lightGrayColor];
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
                    }
                    
                    return cell;
                }
            }
            else {
                // Set None row
                CellIdentifier = @"NoneStaffPicks";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No staff picks!";
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    
                    cell.userInteractionEnabled = NO;
                }
                
                return cell;
            }
        }
    }
    
//    [lbl_new release];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger count;
    NSUInteger rows;
    
    if (indexPath.section == 0) {
        count = [[self.frc_mimeAnswersFromFriends fetchedObjects]count];
    }
    else if (indexPath.section == 1) {
        // Recent section
        count = [[self.frc_recentMimes fetchedObjects]count];
    }
    else if (indexPath.section == 2) {
        // Top Favorites section
        count = [[self.frc_topFavoriteMimes fetchedObjects]count];
    }
    else {
        // Staff Picked section
        count = [[self.frc_staffPickedMimes fetchedObjects]count];
    }
    
    rows = MIN(count, kMAXROWS);
    
    if (indexPath.row == 0) {
        // Header
        return 50;
    }
    else if (indexPath.row > rows) {
        // Last row
        return 50;
    }
    else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
                
        // Friends mime selected
        NSInteger count = MIN([[self.frc_mimeAnswersFromFriends fetchedObjects]count], kMAXROWS);
        
        if (count == 0) {
            // No mimes from friends, user selected to create new mime
            Mime_meCreateMimeViewController *mimeViewController = [Mime_meCreateMimeViewController createInstance];
            
            [self.navigationController setViewControllers:[NSArray arrayWithObject:mimeViewController] animated:NO];
        }
        else {
            if (indexPath.row > 0 && indexPath.row <= count) {
                
                MimeAnswer *mimeAnswer = [[self.frc_mimeAnswersFromFriends fetchedObjects] objectAtIndex:(indexPath.row - 1)];
                
                // Show the Mime
                Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWANSWERMIME withMimeID:mimeAnswer.mimeid withMimeAnswerIDorNil:mimeAnswer.objectid];
                [self.navigationController pushViewController:viewMimeViewController animated:YES];
            }
            else {
                Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstanceForMimeType:kFROMFRIENDMIME];
                
                [self.navigationController pushViewController:fullTableViewController animated:YES];
            }
        }
    }
    else if (indexPath.section == 1) {
        // Recent mime selected
        NSInteger count = MIN([[self.frc_recentMimes fetchedObjects]count], kMAXROWS);
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Mime *mime = [[self.frc_recentMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWANSWERMIME withMimeID:mime.objectid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
        else {
            Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstanceForMimeType:kRECENTMIME];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
    else if (indexPath.section == 2) {
        // Top Favorited mime selected
        NSInteger count = MIN([[self.frc_topFavoriteMimes fetchedObjects]count], kMAXROWS);
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Mime *mime = [[self.frc_topFavoriteMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWANSWERMIME withMimeID:mime.objectid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
        else {
            Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstanceForMimeType:kTOPFAVORITEDMIME];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
    else {
        // Staff Pick mime selected
        NSInteger count = MIN([[self.frc_staffPickedMimes fetchedObjects]count], kMAXROWS);
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Mime *mime = [[self.frc_staffPickedMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWANSWERMIME withMimeID:mime.objectid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
        else {
            Mime_meGuessFullTableViewController *fullTableViewController = [Mime_meGuessFullTableViewController createInstanceForMimeType:kSTAFFPICKEDMIME];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
    
}

#pragma mark - NSFetchedResultsControllerDelegate methods
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tbl_mimes beginUpdates];
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tbl_mimes endUpdates];
//}

- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"Mime_meGuessMenuViewController.controller.didChangeObject:";
    
//    UITableView *tableView = self.tbl_mimes;
    
    if (type == NSFetchedResultsChangeDelete)
    {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(0,@"%@ Received NSFetechedResultsChangeDelete notification",activityName);
    }
    
////    NSInteger section;
//    NSInteger maxNumRows;
//    if (controller == self.frc_mimeAnswersFromFriends) {
////        section = 0;
//        maxNumRows = kMAXROWS;
//    }
//    else if (controller == self.frc_recentMimes) {
////        section = 1;
//        maxNumRows = kMAXROWS;
//    }
//    else if (controller == self.frc_staffPickedMimes) {
////        section = 2;
//        maxNumRows = kMAXROWS;
//    }
    
    if (controller == self.frc_mimeAnswersFromFriends || controller == self.frc_recentMimes || controller == self.frc_staffPickedMimes) {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(0, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
        
        if (indexPath.row < kMAXROWS) {
//            switch(type) {
//                    
//                case NSFetchedResultsChangeInsert:
//                    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(newIndexPath.row + 1) inSection:section]]
//                                     withRowAnimation:UITableViewRowAnimationFade];
//                    break;
//                    
//                case NSFetchedResultsChangeDelete:
//                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:section]]
//                                     withRowAnimation:UITableViewRowAnimationFade];
//                    break;
//                    
//                case NSFetchedResultsChangeUpdate:
//                    [self configureCell:[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:section]]
//                            atIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:section]];
//                    break;
//                    
//                case NSFetchedResultsChangeMove:
//                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:section]]
//                                     withRowAnimation:UITableViewRowAnimationFade];
//                    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(newIndexPath.row + 1) inSection:section]]
//                                     withRowAnimation:UITableViewRowAnimationFade];
//                    break;
//            }
            
            [self.tbl_mimes reloadData];
        }
    }
    else {
        LOG_MIME_MEGUESSMENUVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    
    [self hideProgressBar];
    
//    if (enumerator == self.mimeAnswersCloudEnumerator) {
//        
//    }
//    else if (enumerator == self.recentMimesCloudEnumerator) {
//        
//    }
//    else if (enumerator == self.staffPickedMimesCloudEnumerator) {
//        
//    }

}

#pragma mark - Feed Event Handlers
- (void)updateNotificationsAndGemCount {
    if ([self.authenticationManager isUserAuthenticated]) {
        // update notification bubbles in navigation header
        [self.nv_navigationHeader updateNotificationsAndGemCount];
    }
}

- (void) onFeedRefreshComplete:(CallbackResult*)result
{
    [super onFeedRefreshComplete:result];
    
    // Update notifications and Gem count
    [self updateNotificationsAndGemCount];
}

#pragma mark - MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meGuessMenuViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    //    Request* request = [progressView.requests objectAtIndex:0];
    //    //now we have the request
    //    NSArray* changedAttributes = request.changedAttributesList;
    //    //list of all changed attributes
    //    //we take the first one and base our messaging off that
    //    NSString* attributeName = [changedAttributes objectAtIndex:0];
    
    if (progressView.didSucceed) {
        //enumeration was sucessful
        LOG_REQUEST(0, @"%@ Mime and MimeAnswer enumeration was successful", activityName);
        
    }
    else {
        //enumeration failed
        LOG_REQUEST(1, @"%@ Mime and MimeAnswer enumeration failure", activityName);
        
    }
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meGuessMenuViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    
    NSFetchedResultsController *frc = (NSFetchedResultsController *)[userInfo valueForKey:kMIMEFRC];

    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        
        UITableViewCell *cell = nil;
        
        if (frc == self.frc_mimeAnswersFromFriends) {
            
            NSNumber* mimeAnswerID = [userInfo valueForKey:kMIMEANSWERID];
            
            NSInteger count = MIN([[self.frc_mimeAnswersFromFriends fetchedObjects]count], kMAXROWS);    // Maximize the number of friends mimes to show
            for (int i = 0; i < count; i++) {
                MimeAnswer *mimeAnswer = [[self.frc_mimeAnswersFromFriends fetchedObjects] objectAtIndex:i];
                if ([mimeAnswer.objectid isEqualToNumber:mimeAnswerID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:0]];
                    
                    break;
                }
            }
        }
        else if (frc == self.frc_recentMimes) {
            
            NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
            
            NSInteger count = MIN([[self.frc_recentMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of recent mimes to show
            for (int i = 0; i < count; i++) {
                Mime *mime = [[self.frc_recentMimes fetchedObjects] objectAtIndex:i];
                if ([mime.objectid isEqualToNumber:mimeID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:1]];
                    
                    break;
                }
            }
        }
        else if (frc == self.frc_topFavoriteMimes) {
            
            NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
            
            NSInteger count = MIN([[self.frc_topFavoriteMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of recent mimes to show
            for (int i = 0; i < count; i++) {
                Mime *mime = [[self.frc_topFavoriteMimes fetchedObjects] objectAtIndex:i];
                if ([mime.objectid isEqualToNumber:mimeID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:2]];
                    
                    break;
                }
            }
        }
        else if (frc == self.frc_staffPickedMimes) {
            
            NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
            
            NSInteger count = MIN([[self.frc_staffPickedMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of recent mimes to show
            for (int i = 0; i < count; i++) {
                Mime *mime = [[self.frc_staffPickedMimes fetchedObjects] objectAtIndex:i];
                if ([mime.objectid isEqualToNumber:mimeID]) {
                    cell = [self.tbl_mimes cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:3]];
                    
                    break;
                }
            }
        }
        
        if (cell != nil) {
            //we only draw the image if this view hasnt been repurposed for another photo
            LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
            
            UIImage *image = [response.image imageScaledToSize:CGSizeMake(50, 50)];
            
            [cell.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
            
            [self.view setNeedsDisplay];
        }
    }    
}

#pragma mark - Static Initializers
+ (Mime_meGuessMenuViewController*)createInstance {
    Mime_meGuessMenuViewController* instance = [[Mime_meGuessMenuViewController alloc]initWithNibName:@"Mime_meGuessMenuViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
