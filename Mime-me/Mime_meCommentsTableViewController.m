//
//  Mime_meCommentsTableViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 8/22/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meCommentsTableViewController.h"
#import "Mime_meSettingsViewController.h"
#import "Mime_meAppDelegate.h"
#import "Attributes.h"
#import "Macros.h"
#import "Mime.h"
#import "Comment.h"
#import "ImageManager.h"
#import "ImageDownloadResponse.h"
#import "DateTimeHelper.h"
#import "UIImage+UIImageCategory.h"

#define kCOMMENTID @"commentid"
#define kMIMEID @"mimeid"

#define kMAXROWS 200

@interface Mime_meCommentsTableViewController ()

@end

@implementation Mime_meCommentsTableViewController
@synthesize mimeID                      = m_mimeID;
@synthesize frc_comments                = __frc_comments;
@synthesize commentsCloudEnumerator     = m_commentsCloudEnumerator;
@synthesize tbl_comments                 = m_tbl_comments;
@synthesize btn_back                    = m_btn_back;
@synthesize v_headerContainer           = m_v_headerContainer;

#pragma mark - FRCs
- (NSFetchedResultsController*)frc_comments {
    NSString* activityName = @"Mime_meAnswersTableViewController.frc_comments";
    if (__frc_comments != nil) {
        return __frc_comments;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:COMMENT inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATEMODIFIED ascending:NO];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", MIMEID, self.mimeID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:kMAXROWS];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_comments = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
    
  	if (error != nil)
    {
        LOG_MIME_MECOMMENTSTABLEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    else {
        LOG_MIME_MECOMMENTSTABLEVIEWCONTROLLER(0, @"%@ Successfully created NSFetchedResultsController with %d items found",activityName,[[controller fetchedObjects]count]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    [predicate release];
    return __frc_comments;
    
}

#pragma mark - Enumerators
- (void)showHUDForMimeEnumerators {
    Mime_meAppDelegate* appDelegate = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    NSString* message = @"Updating...";
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    
}

- (void) enumerateMimeAnswers {    
    if (self.commentsCloudEnumerator != nil && [self.commentsCloudEnumerator canEnumerate]) {
        [self.commentsCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.commentsCloudEnumerator = nil;
        self.commentsCloudEnumerator = [CloudEnumerator enumeratorForMimeAnswersForMime:self.mimeID];
        self.commentsCloudEnumerator.delegate = self;
        self.commentsCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:kMAXROWS];
        [self.commentsCloudEnumerator enumerateUntilEnd:nil];
    }
}

#pragma mark - Helper Methods
- (void)markCommentsSeen {
    BOOL shouldSave = NO;
    
    for (Comment *comment in [self.frc_comments fetchedObjects]) {
        if ([comment.hasseen boolValue] == NO)
        {
            comment.hasseen = [NSNumber numberWithBool:YES];
            shouldSave = YES;
        }
    }
    
    if (shouldSave == YES) {
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
    }
}

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
    
    // Add rounded corners to top part of header view
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.v_headerContainer.bounds 
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(8.0, 8.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.v_headerContainer.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.v_headerContainer.layer.mask = maskLayer;
    [self.v_headerContainer.layer setOpaque:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.tbl_comments = nil;
    self.btn_back = nil;
    self.v_headerContainer = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self markCommentsSeen];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [[self.frc_comments fetchedObjects]count];
    
    return rows;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    Comment *comment = [[self.frc_comments fetchedObjects] objectAtIndex:indexPath.row];
    User *user = (User*)[resourceContext resourceWithType:USER withID:comment.creatorid];
    
    NSString *creatorName = user.username;
    cell.textLabel.text = creatorName;
    
    NSDate* dateSent = [DateTimeHelper parseWebServiceDateDouble:comment.datecreated];
    cell.detailTextLabel.text = [self getDateStringForMimeDate:dateSent];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:comment.objectid, kCOMMENTID, nil];
    
    ImageManager* imageManager = [ImageManager instance];
    
    // Set the user profile image
    if (user.thumbnailurl != nil && ![user.thumbnailurl isEqualToString:@""]) {
        Callback* callback = [[Callback alloc]initWithTarget:self withSelector:@selector(onImageDownloadComplete:) withContext:userInfo];
        callback.fireOnMainThread = YES;
        UIImage* image = [imageManager downloadImage:user.thumbnailurl withUserInfo:nil atCallback:callback];
        [callback release];
        if (image != nil) {
            
            cell.imageView.image = [image imageScaledToSize:CGSizeMake(40, 40)];
        }
        else {
            cell.imageView.backgroundColor = [UIColor lightGrayColor];
            cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(40, 40)];
        }
        
        [self.view setNeedsDisplay];
    }
    
    // Mark comment as "new" if user has not previously seen it
    if ([comment.hasseen boolValue] == NO) {
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
    
    NSInteger count = [[self.frc_comments fetchedObjects]count];
    
    if (indexPath.row < count) {
        // Set comment
        CellIdentifier = @"Comment";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.layer.masksToBounds = YES;
            cell.imageView.layer.cornerRadius = 8.0;
            cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            cell.imageView.layer.borderWidth = 1.0;
            
            cell.imageView.backgroundColor = [UIColor lightGrayColor];
            cell.imageView.image = [[UIImage imageNamed:@"logo-MimeMe.png"] imageScaledToSize:CGSizeMake(40, 40)];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    else {
        // Set None row
        CellIdentifier = @"NoComment";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.shadowColor = [UIColor whiteColor];
            cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            cell.textLabel.textColor = [UIColor lightGrayColor];
            
            cell.textLabel.text = @"No comments!";
            
            cell.userInteractionEnabled = NO;
        }
        
        return cell;
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
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UIButton Handlers
- (IBAction) onBackButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"Mime_meAnswersTableViewController.controller.didChangeObject:";
    
    if (type == NSFetchedResultsChangeDelete)
    {
        LOG_MIME_MECOMMENTSTABLEVIEWCONTROLLER(0,@"%@ Received NSFetechedResultsChangeDelete notification",activityName);
    }
    
    if (controller == self.frc_comments) {
        LOG_MIME_MECOMMENTSTABLEVIEWCONTROLLER(0, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
        
        if (indexPath.row < kMAXROWS) {
            [self.tbl_comments reloadData];
        }
    }
    else {
        LOG_MIME_MECOMMENTSTABLEVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    
    [self hideProgressBar];
    
}

#pragma mark - MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meGuessFullTableViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed) {
        //enumeration was sucessful
        LOG_REQUEST(0, @"%@ Comments enumeration was successful", activityName);
        
    }
    else {
        //enumeration failed
        LOG_REQUEST(1, @"%@ Comments enumeration failure", activityName);
        
    }
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meGuessFullTableViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        
        UITableViewCell *cell = nil;
        
        NSNumber* commentID = [userInfo valueForKey:kCOMMENTID];
        
        NSInteger count = [[self.frc_comments fetchedObjects] count];
        for (int i = 0; i < count; i++) {
            Comment *comment = [[self.frc_comments fetchedObjects] objectAtIndex:i];
            if ([comment.objectid isEqualToNumber:commentID]) {
                cell = [self.tbl_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                
                break;
            }
        }
        
        if (cell != nil) {
            //we only draw the image if this view hasnt been repurposed for another photo
            LOG_IMAGE(0,@"%@settings UIImage object equal to downloaded response",activityName);
            
            UIImage *image = [response.image imageScaledToSize:CGSizeMake(40, 40)];
            
            [cell.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
            
            [self.view setNeedsDisplay];
        }
    }    
}


#pragma mark - Static Initializers
+ (Mime_meCommentsTableViewController*)createInstanceForMimeWithID:(NSNumber *)mimeID {
    Mime_meCommentsTableViewController* instance = [[Mime_meCommentsTableViewController alloc]initWithNibName:@"Mime_meCommentsTableViewController" bundle:nil];
    [instance autorelease];
    instance.mimeID = mimeID;
    return instance;
}

@end
