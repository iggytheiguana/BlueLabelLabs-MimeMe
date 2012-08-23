//
//  Mime_meScrapbookMenuViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/18/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meScrapbookMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime_meGuessMenuViewController.h"
#import "Mime_meSettingsViewController.h"
#import "Mime_meAppDelegate.h"
#import "Attributes.h"
#import "Macros.h"
#import "Mime.h"
#import "MimeType.h"
#import "MimeAnswer.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "DateTimeHelper.h"
#import "UIImage+UIImageCategory.h"
#import "Mime_meViewMimeViewController.h"
#import "Mime_meScrapbookFullTableViewController.h"
#import "Favorite.h"
#import "MimeAnswerState.h"
#import "Feed.h"
#import "FeedTypes.h"


#define kMIMEFRC @"mimefrc"

#define kMIMEID @"mimeid"
#define kMIMEANSWERID @"mimeanswerid"
#define kFAVORITEID @"favoriteid"

#define kMAXROWS 3

@interface Mime_meScrapbookMenuViewController ()

@end

@implementation Mime_meScrapbookMenuViewController
@synthesize frc_sentMimes           = __frc_sentMimes;
@synthesize frc_favoriteMimes       = __frc_favoriteMimes;
@synthesize frc_guessedMimeAnswers  = __frc_guessedMimeAnswers;

@synthesize sentMimesCloudEnumerator            = m_sentMimesCloudEnumerator;
@synthesize favoriteMimesCloudEnumerator        = m_favoriteMimesCloudEnumerator;
@synthesize guessedMimeAnswersCloudEnumerator   = m_guessedMimeAnswersCloudEnumerator;

@synthesize nv_navigationHeader     = m_nv_navigationHeader;
@synthesize tbl_scrapbook           = m_tbl_scrapbook;
@synthesize tc_sentHeader           = m_tc_sentHeader;
@synthesize tc_favoritesHeader      = m_tc_favoritesHeader;
@synthesize tc_guessedHeader        = m_tc_guessedHeader;
@synthesize gad_bannerView      = m_gad_bannerView;


#pragma mark - Properties
- (NSFetchedResultsController*)frc_sentMimes {
    NSString* activityName = @"Mime_meScrapbookMenuViewController.frc_sentMimes:";
    if (__frc_sentMimes != nil) {
        return __frc_sentMimes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MIME inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", CREATORID, self.loggedInUser.objectid];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:(kMAXROWS + 1)];    // We add 1 to find out if the "more" button should be shown
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_sentMimes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MESCRAPBOOKMENUVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_sentMimes;
    
}

- (NSFetchedResultsController*)frc_favoriteMimes {
    NSString* activityName = @"Mime_meScrapbookMenuViewController.frc_favoriteMimes:";
    if (__frc_favoriteMimes != nil) {
        return __frc_favoriteMimes;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:FAVORITE inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", USERID, self.loggedInUser.objectid];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:(kMAXROWS + 1)];    // We add 1 to find out if the "more" button should be shown
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_favoriteMimes = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MESCRAPBOOKMENUVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_favoriteMimes;
    
}

- (NSFetchedResultsController*)frc_guessedMimeAnswers {
    NSString* activityName = @"Mime_meScrapbookMenuViewController.frc_guessedMimes:";
    if (__frc_guessedMimeAnswers != nil) {
        return __frc_guessedMimeAnswers;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MIMEANSWER inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATECREATED ascending:NO];
    
    NSNumber* answeredStateObj = [NSNumber numberWithInt:kANSWERED];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@ AND %K=%@", TARGETUSERID, self.loggedInUser.objectid, STATE, answeredStateObj];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:(kMAXROWS + 1)];    // We add 1 to find out if the "more" button should be shown
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_guessedMimeAnswers = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MESCRAPBOOKMENUVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_guessedMimeAnswers;
    
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

- (void) enumerateSentMimes {    
    if (self.sentMimesCloudEnumerator != nil && [self.sentMimesCloudEnumerator canEnumerate]) {
        [self.sentMimesCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.sentMimesCloudEnumerator = nil;
        self.sentMimesCloudEnumerator = [CloudEnumerator enumeratorForSentMimes:self.loggedInUser.objectid];
        self.sentMimesCloudEnumerator.delegate = self;
        self.sentMimesCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:(kMAXROWS + 1)];  // We add 1 to find out if the "more" button should be shown
        [self.sentMimesCloudEnumerator enumerateUntilEnd:nil];
    }
}

- (void) enumerateFavoriteMimes {    
    if (self.favoriteMimesCloudEnumerator != nil && [self.favoriteMimesCloudEnumerator canEnumerate]) {
        [self.favoriteMimesCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.favoriteMimesCloudEnumerator = nil;
        self.favoriteMimesCloudEnumerator = [CloudEnumerator enumeratorForFavoriteMimes:self.loggedInUser.objectid];
        self.favoriteMimesCloudEnumerator.delegate = self;
        self.sentMimesCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:(kMAXROWS + 1)];  // We add 1 to find out if the "more" button should be shown
        [self.favoriteMimesCloudEnumerator enumerateUntilEnd:nil];
    }
}

- (void) enumerateGuessedMimes {    
    if (self.guessedMimeAnswersCloudEnumerator != nil && [self.guessedMimeAnswersCloudEnumerator canEnumerate]) {
        [self.guessedMimeAnswersCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.guessedMimeAnswersCloudEnumerator = nil;
        NSNumber* answeredStateObj = [NSNumber numberWithInt:kANSWERED];
        self.guessedMimeAnswersCloudEnumerator = [CloudEnumerator enumeratorForMimeAnswersWithTarget:self.loggedInUser.objectid withState:answeredStateObj];
        self.guessedMimeAnswersCloudEnumerator.delegate = self;
        self.sentMimesCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:(kMAXROWS + 1)];  // We add 1 to find out if the "more" button should be shown
        [self.guessedMimeAnswersCloudEnumerator enumerateUntilEnd:nil];
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
    
    // Add rounded corners to view
    [self.view.layer setCornerRadius:8.0f];
    
    // Add the navigation header
    Mime_meUINavigationHeaderView *navigationHeader = [[Mime_meUINavigationHeaderView alloc]initWithFrame:[Mime_meUINavigationHeaderView frameForNavigationHeader]];
    navigationHeader.delegate = self;
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
    self.tbl_scrapbook = nil;
    self.tc_sentHeader = nil;
    self.tc_favoritesHeader = nil;
    self.tc_guessedHeader = nil;
    self.gad_bannerView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    NSString* activityName = @"Mime_meScrapbookMenuViewController.viewWillAppear:";
    
    [self.nv_navigationHeader.btn_scrapbook setHighlighted:YES];
    [self.nv_navigationHeader.btn_scrapbook setUserInteractionEnabled:NO];
    
    // Enumerate for Mimes from friends, recent and staff pick Mimes
    [self enumerateSentMimes];
    [self enumerateFavoriteMimes];
    [self enumerateGuessedMimes];
    
    [self showHUDForMimeEnumerators];
    
//    // Refresh the notification feed
//    Callback* callback = [Callback callbackForTarget:self selector:@selector(onFeedRefreshComplete:) fireOnMainThread:YES];
//    BOOL isEnumeratingFeed = [[FeedManager instance] tryRefreshFeedOnFinish:callback];
//    if (isEnumeratingFeed) 
//    {
//        LOG_MIME_MESCRAPBOOKMENUVIEWCONTROLLER(0, @"%@Refreshing user's notification feed", activityName);
//    }
    
    // Update notifications
    [self updateNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    NSInteger rows;
    
    if (section == 0) {
        // Sent section
        count = [[self.frc_sentMimes fetchedObjects] count];
    }
    else if (section == 1) {
        // Favorites section
        count = [[self.frc_favoriteMimes fetchedObjects] count];
    }
    else {
        // Guessed section
        count = [[self.frc_guessedMimeAnswers fetchedObjects] count];
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
    
    if (indexPath.section == 0) {
        // Sent Mimes section
        mime = [[self.frc_sentMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        NSString *wordStr = mime.word;
        cell.textLabel.text = wordStr;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_sentMimes, kMIMEFRC, mime.objectid, kMIMEID, nil];
    }
    else if (indexPath.section == 1) {
        // Favorite Mimes section
        Favorite *favorite = [[self.frc_favoriteMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        // Get the Mime object associated with this Favorite
        mime = (Mime*)[resourceContext resourceWithType:MIME withID:favorite.mimeid];
        
        cell.textLabel.text = mime.word;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_favoriteMimes, kMIMEFRC, mime.objectid, kFAVORITEID, nil];
    }
    else if (indexPath.section == 2) {
        // Guessed Mimes section
        MimeAnswer *mimeAnswer = [[self.frc_guessedMimeAnswers fetchedObjects] objectAtIndex:(indexPath.row - 1)];
        
        // Get the Mime object associated with this MimeAnswer
        mime = (Mime*)[resourceContext resourceWithType:MIME withID:mimeAnswer.mimeid];
        
        cell.textLabel.text = mime.word;
        
        NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:mime.datecreated];
        cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.frc_guessedMimeAnswers, kMIMEFRC, mimeAnswer.objectid, kMIMEANSWERID, nil];
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
    
    
//    // Display label for new answers if there are unseen answers
//    int numNewAnswers = [mime numUnopenedMimeAnswers];
//    UILabel *lbl_newAnswer = (UILabel *)[cell.contentView viewWithTag:101];
//    if (numNewAnswers > 1) {
//        [lbl_newAnswer setHidden:NO];
//        [lbl_newAnswer setText:@"New answers!"];
//    }
//    else if (numNewAnswers == 1) {
//        [lbl_newAnswer setHidden:NO];
//        [lbl_newAnswer setText:@"New answer!"];
//    }
//    else {
//        [lbl_newAnswer setHidden:YES];
//    }
//    
//    // Display label for new comments if there are unseen comments
//    int numNewComments = 0;
//    UILabel *lbl_newComment = (UILabel *)[cell.contentView viewWithTag:102];
//    if (numNewComments > 1) {
//        [lbl_newComment setHidden:NO];
//        [lbl_newComment setText:@"New comments!"];
//    }
//    else if (numNewComments == 1) {
//        [lbl_newComment setHidden:NO];
//        [lbl_newComment setText:@"New comment!"];
//    }
//    else {
//        [lbl_newComment setHidden:YES];
//    }
    
    
    // Display label for new answers if there are unseen answers
    int numNewAnswers = [mime numUnopenedMimeAnswers];
    int numNewComments = [mime numUnopenedComments];
    
    UILabel *lbl_newNotification = [[UILabel alloc] initWithFrame:CGRectMake(175.0f, 0.0f, 90.0f, 36.0f)];
    lbl_newNotification.backgroundColor = [UIColor clearColor];
    lbl_newNotification.font =[UIFont systemFontOfSize:12.0f];
    lbl_newNotification.adjustsFontSizeToFitWidth = YES;
    lbl_newNotification.textColor = [UIColor blueColor];
    lbl_newNotification.textAlignment = UITextAlignmentRight;
    
    if (numNewAnswers > 0 && numNewComments > 0) {
        lbl_newNotification.numberOfLines = 2;
        [lbl_newNotification setText:@"New answer!\nNew comment!"];
        
        cell.accessoryView = lbl_newNotification;
    }
    else if (numNewAnswers > 0 && numNewComments == 0) {
        lbl_newNotification.numberOfLines = 1;
        [lbl_newNotification setText:@"New answer!"];
        
        cell.accessoryView = lbl_newNotification;
    }
    else if (numNewAnswers == 0 && numNewComments > 0) {
        lbl_newNotification.numberOfLines = 1;
        [lbl_newNotification setText:@"New comment!"];
        
        cell.accessoryView = lbl_newNotification;
    }
    else {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [lbl_newNotification release];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    
//    UILabel *lbl_newAnswer = [[UILabel alloc] initWithFrame:CGRectMake(175.0f, 0.0f, 100.0f, 21.0f)];
//    [lbl_newAnswer setTag:101];
//    lbl_newAnswer.text = @"New answers!";
//    lbl_newAnswer.backgroundColor = [UIColor clearColor];
//    lbl_newAnswer.font =[UIFont systemFontOfSize:14.0f];
//    lbl_newAnswer.textColor = [UIColor redColor];
//    lbl_newAnswer.textAlignment = UITextAlignmentRight;
//    [lbl_newAnswer setHidden:YES];
//    
//    UILabel *lbl_newComment = [[UILabel alloc] initWithFrame:CGRectMake(175.0f, 29.0f, 100.0f, 21.0f)];
//    [lbl_newComment setTag:102];
//    lbl_newComment.text = @"New comments!";
//    lbl_newComment.backgroundColor = [UIColor clearColor];
//    lbl_newComment.font =[UIFont systemFontOfSize:14.0f];
//    lbl_newComment.textColor = [UIColor blueColor];
//    lbl_newComment.textAlignment = UITextAlignmentRight;
//    [lbl_newComment setHidden:YES];
    
    if (indexPath.section == 0) {
        // From Friends section
        
        NSInteger count = MIN([[self.frc_sentMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of mimes to show
        
        if (indexPath.row == 0) {
            // Set the header
            CellIdentifier = @"SentHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_sentHeader;
                
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set sent mime
                    CellIdentifier = @"SentMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imageView.layer.masksToBounds = YES;
                        cell.imageView.layer.cornerRadius = 8.0;
                        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        cell.imageView.layer.borderWidth = 1.0;
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
//                        [cell.contentView addSubview:lbl_newAnswer];
//                        [cell.contentView addSubview:lbl_newComment];
                        
                    }
                    
                    [self configureCell:cell atIndexPath:indexPath];
                    
                    return cell;
                }
                else {
                    // Set More row
                    CellIdentifier = @"MoreSentMimes";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More sent mimes";
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
                // Set no sent mimes row
                CellIdentifier = @"NoSentMimes";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No sent mimes!";
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
    if (indexPath.section == 1) {
        // Favorite Mimes section
        
        NSInteger count = MIN([[self.frc_favoriteMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of mimes to show
        
        if (indexPath.row == 0) {
            // Set the header
            CellIdentifier = @"FavoritesHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_favoritesHeader;
                
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Favorite mime
                    CellIdentifier = @"FavoriteMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imageView.layer.masksToBounds = YES;
                        cell.imageView.layer.cornerRadius = 8.0;
                        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        cell.imageView.layer.borderWidth = 1.0;
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
//                        [cell.contentView addSubview:lbl_newAnswer];
//                        [cell.contentView addSubview:lbl_newComment];
                        
                    }
                    
                    [self configureCell:cell atIndexPath:indexPath];
                    
                    return cell;
                }
                else {
                    // Set More row
                    CellIdentifier = @"MoreFavorites";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More favorite mimes";
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
                // Set no favorite mimes row
                CellIdentifier = @"NoFavoriteMimes";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No favorite mimes!";
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
        // Guessed Mimes section
        
        NSInteger count = MIN([[self.frc_guessedMimeAnswers fetchedObjects]count], kMAXROWS);    // Maximize the number of mimes to show
        
        if (indexPath.row == 0) {
            // Set the header
            CellIdentifier = @"GuessedHeader";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = self.tc_guessedHeader;
                
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        }
        else {
            if (count > 0) {
                if (indexPath.row > 0 && indexPath.row <= count) {
                    // Set Guessed mime
                    CellIdentifier = @"GuessedMime";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                        cell.imageView.layer.masksToBounds = YES;
                        cell.imageView.layer.cornerRadius = 8.0;
                        cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        cell.imageView.layer.borderWidth = 1.0;
                        
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        
//                        [cell.contentView addSubview:lbl_newAnswer];
//                        [cell.contentView addSubview:lbl_newComment];
                        
                    }
                    
                    [self configureCell:cell atIndexPath:indexPath];
                    
                    return cell;
                }
                else {
                    // Set More row
                    CellIdentifier = @"MoreGuessedMimes";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                        
                        cell.textLabel.text = @"More guessed mimes";
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
                // Set no guessed mimes row
                CellIdentifier = @"NoGuessedMimes";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    
                    cell.textLabel.text = @"No guessed mimes!";
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    cell.textLabel.shadowColor = [UIColor whiteColor];
                    cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    
                    // Cell properties
                    cell.userInteractionEnabled = NO;
                }
                
                return cell;
            }
        }
    }
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
        // Sent section
        count = [[self.frc_sentMimes fetchedObjects]count];
        rows = MIN(count, kMAXROWS);
    }
    else if (indexPath.section == 1) {
        // Favorites section
        count = [[self.frc_favoriteMimes fetchedObjects]count];
        rows = MIN(count, kMAXROWS);
    }
    else {
        // Guessed section
        count = [[self.frc_guessedMimeAnswers fetchedObjects]count];
        rows = MIN(count, kMAXROWS);
    }
    
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
        // Sent mime selected
        NSInteger count = MIN([[self.frc_sentMimes fetchedObjects]count], kMAXROWS);
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Mime *mime = [[self.frc_sentMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWSCRAPBOOKMIME withMimeID:mime.objectid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
        else {
            Mime_meScrapbookFullTableViewController *fullTableViewController = [Mime_meScrapbookFullTableViewController createInstanceForMimeType:kSENTMIME];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
    else if (indexPath.section == 1) {
        // Favorite mimes selected
        NSInteger count = MIN([[self.frc_favoriteMimes fetchedObjects]count], kMAXROWS);
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            Favorite *favorite = [[self.frc_favoriteMimes fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWSCRAPBOOKMIME withMimeID:favorite.mimeid withMimeAnswerIDorNil:nil];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
        else {
            Mime_meScrapbookFullTableViewController *fullTableViewController = [Mime_meScrapbookFullTableViewController createInstanceForMimeType:kFAVORITEMIME];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }
    else if (indexPath.section == 2) {
        // Guessed mines selected
        NSInteger count = MIN([[self.frc_guessedMimeAnswers fetchedObjects]count], kMAXROWS);
        
        if (indexPath.row > 0 && indexPath.row <= count) {
            
            MimeAnswer *mimeAnswer = [[self.frc_guessedMimeAnswers fetchedObjects] objectAtIndex:(indexPath.row - 1)];
            
            // Show the Mime
            Mime_meViewMimeViewController *viewMimeViewController = [Mime_meViewMimeViewController createInstanceForCase:kVIEWSCRAPBOOKMIME withMimeID:mimeAnswer.mimeid withMimeAnswerIDorNil:mimeAnswer.objectid];
            [self.navigationController pushViewController:viewMimeViewController animated:YES];
        }
        else {
            Mime_meScrapbookFullTableViewController *fullTableViewController = [Mime_meScrapbookFullTableViewController createInstanceForMimeType:kGUESSEDMIME];
            
            [self.navigationController pushViewController:fullTableViewController animated:YES];
        }
    }

    
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"Mime_meScrapbookMenuViewController.controller.didChangeObject:";
    if (controller == self.frc_sentMimes) {
        LOG_MIME_MESCRAPBOOKMENUVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
        
        if (indexPath.row < kMAXROWS) {
            
            [self.tbl_scrapbook reloadData];
        }
    }
    else {
        LOG_MIME_MESCRAPBOOKMENUVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    
    [self hideProgressBar];
    
//    if (enumerator == self.sentMimesCloudEnumerator) {
//        
//    }
//    else if (enumerator == self.favoriteMimesCloudEnumerator) {
//        
//    }
//    else if (enumerator == self.guessedMimesCloudEnumerator) {
//        
//    }
    
}

#pragma mark - Feed Event Handlers
- (void)updateNotifications {
    if ([self.authenticationManager isUserAuthenticated]) {
        // update notification bubbles in navigation header
        [self.nv_navigationHeader updateNotifications];
    }
}

- (void) onFeedRefreshComplete:(CallbackResult*)result
{
    [super onFeedRefreshComplete:result];
    
    // Update notifications
    [self updateNotifications];
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meScrapbookMenuViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    
    NSFetchedResultsController *frc = (NSFetchedResultsController *)[userInfo valueForKey:kMIMEFRC];
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        
        UITableViewCell *cell = nil;
        
        if (frc == self.frc_sentMimes) {
            
            NSNumber* mimeID = [userInfo valueForKey:kMIMEID];
            
            NSInteger count = MIN([[self.frc_sentMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of friends mimes to show
            for (int i = 0; i < count; i++) {
                MimeAnswer *mimeAnswer = [[self.frc_sentMimes fetchedObjects] objectAtIndex:i];
                if ([mimeAnswer.objectid isEqualToNumber:mimeID]) {
                    cell = [self.tbl_scrapbook cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:0]];
                    
                    break;
                }
            }
        }
        else if (frc == self.frc_favoriteMimes) {
            
            NSNumber* favoriteID = [userInfo valueForKey:kFAVORITEID];
            
            NSInteger count = MIN([[self.frc_favoriteMimes fetchedObjects]count], kMAXROWS);    // Maximize the number of recent mimes to show
            for (int i = 0; i < count; i++) {
                Favorite *favorite = [[self.frc_favoriteMimes fetchedObjects] objectAtIndex:i];
                if ([favorite.objectid isEqualToNumber:favoriteID]) {
                    cell = [self.tbl_scrapbook cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:1]];
                    
                    break;
                }
            }
        }
        else if (frc == self.frc_guessedMimeAnswers) {
            
            NSNumber* mimeAnswerID = [userInfo valueForKey:kMIMEANSWERID];
            
            NSInteger count = MIN([[self.frc_guessedMimeAnswers fetchedObjects]count], kMAXROWS);    // Maximize the number of recent mimes to show
            for (int i = 0; i < count; i++) {
                MimeAnswer *mimeAnswer = [[self.frc_guessedMimeAnswers fetchedObjects] objectAtIndex:i];
                if ([mimeAnswer.objectid isEqualToNumber:mimeAnswerID]) {
                    cell = [self.tbl_scrapbook cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(i+1) inSection:2]];
                    
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
+ (Mime_meScrapbookMenuViewController*)createInstance {
    Mime_meScrapbookMenuViewController* instance = [[Mime_meScrapbookMenuViewController alloc]initWithNibName:@"Mime_meScrapbookMenuViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
