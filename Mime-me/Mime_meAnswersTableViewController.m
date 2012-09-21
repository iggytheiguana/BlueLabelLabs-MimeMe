//
//  Mime_meAnswersTableViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 8/20/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meAnswersTableViewController.h"
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
#import "MimeAnswerState.h"
#import <QuartzCore/QuartzCore.h>

#define kMIMEANSWERID @"mimeanswerid"
#define kMIMEID @"mimeid"

#define kMAXROWS 200

@interface Mime_meAnswersTableViewController ()

@end

@implementation Mime_meAnswersTableViewController
@synthesize mimeID                      = m_mimeID;
@synthesize frc_mimeAnswers             = __frc_mimeAnswers;
@synthesize mimeAnswerCloudEnumerator   = m_mimeAnswerCloudEnumerator;
@synthesize tbl_answers                 = m_tbl_answers;
@synthesize btn_back                    = m_btn_back;
@synthesize v_headerContainer           = m_v_headerContainer;
//@synthesize userCloudEnumerator         = m_userCloudEnumerator;


#pragma mark - FRCs
- (NSFetchedResultsController*)frc_mimeAnswers {
    NSString* activityName = @"Mime_meAnswersTableViewController.frc_mimeAnswers";
    if (__frc_mimeAnswers != nil) {
        return __frc_mimeAnswers;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MIMEANSWER inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATEMODIFIED ascending:NO];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K=%@", MIMEID, self.mimeID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    [fetchRequest setFetchBatchSize:kMAXROWS];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_mimeAnswers = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
    
  	if (error != nil)
    {
        LOG_MIME_MEANSWERSTABLEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    else {
        LOG_MIME_MEANSWERSTABLEVIEWCONTROLLER(0,@"%@ Successfully created NSFetchedResultsController with %d items found",activityName,[[controller fetchedObjects]count]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    [predicate release];
    return __frc_mimeAnswers;
    
}

#pragma mark - Enumerators
- (void)showHUDForMimeAnswersEnumerator {
    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    NSString* message = @"Updating...";
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    
}

- (void) enumerateMimeAnswers {    
    if (self.mimeAnswerCloudEnumerator != nil && [self.mimeAnswerCloudEnumerator canEnumerate]) {
        [self.mimeAnswerCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.mimeAnswerCloudEnumerator = nil;
        self.mimeAnswerCloudEnumerator = [CloudEnumerator enumeratorForMimeAnswersForMime:self.mimeID];
        self.mimeAnswerCloudEnumerator.delegate = self;
        self.mimeAnswerCloudEnumerator.enumerationContext.maximumNumberOfResults = [NSNumber numberWithInt:kMAXROWS];
        [self.mimeAnswerCloudEnumerator enumerateUntilEnd:nil];
    }
    
    [self showHUDForMimeAnswersEnumerator];
}

#pragma mark - Helper Methods
- (void)markMimeAnswersSeen {
    BOOL shouldSave = NO;
    
    for (MimeAnswer *mimeAnswer in [self.frc_mimeAnswers fetchedObjects]) {
        if ([mimeAnswer.state isEqualToNumber:[NSNumber numberWithInt:kANSWERED]] &&
            [mimeAnswer.hasseen boolValue] == NO)
        {
            mimeAnswer.hasseen = [NSNumber numberWithBool:YES];
            shouldSave = YES;
        }
    }
    
    if (shouldSave == YES) {
        ResourceContext* resourceContext = [ResourceContext instance];
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
    }
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
    
    self.tbl_answers = nil;
    self.btn_back = nil;
    self.v_headerContainer = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Enumerate for Mimes Answers
    [self enumerateMimeAnswers];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self markMimeAnswersSeen];
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
    NSInteger rows = [[self.frc_mimeAnswers fetchedObjects]count];
    
    return rows;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    ResourceContext* resourceContext = [ResourceContext instance];
    MimeAnswer *mimeAnswer = [[self.frc_mimeAnswers fetchedObjects] objectAtIndex:indexPath.row];
    User *user = (User*)[resourceContext resourceWithType:USER withID:mimeAnswer.targetuserid];
    
//    NSString *targetName = user.username;
    NSString *targetName = mimeAnswer.targetname;
    cell.textLabel.text = targetName;
    
    if ([mimeAnswer.state intValue] == kANSWERED) {
        if ([mimeAnswer.didusehint boolValue] == YES) {
            cell.detailTextLabel.text = @"Answered, but used a hint.";
        }
        else {
            cell.detailTextLabel.text = @"Answered without hints!";
        }
    }
    else {
        cell.detailTextLabel.text = @"Has not answered yet.";
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:mimeAnswer.objectid, kMIMEANSWERID, nil];
    
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
    
//    // Mark mime as "new" if user has not previously seen it
//    UILabel *lbl_new = (UILabel *)[cell.contentView viewWithTag:101];
//    if ([mimeAnswer.state isEqualToNumber:[NSNumber numberWithInt:kANSWERED]])
//    {
//        cell.detailTextLabel.textColor = [UIColor blueColor];
//        
//        if ([mimeAnswer.hasseen boolValue] == NO) {
//            [lbl_new setHidden:NO];
//        }
//        else {
//            [lbl_new setHidden:YES];
//        }
//    }
//    else {
//        [lbl_new setHidden:YES];
//        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
//    }
    
    // Mark mime as "new" if user has not previously seen it
    if ([mimeAnswer.state isEqualToNumber:[NSNumber numberWithInt:kANSWERED]])
    {
        cell.detailTextLabel.textColor = [UIColor blueColor];
        
        if ([mimeAnswer.hasseen boolValue] == NO) {
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
    else {
        cell.accessoryView = nil;
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    
//    UILabel *lbl_new = [[UILabel alloc] initWithFrame:CGRectMake(270.0f, 0.0f, 40.0f, 21.0f)];
//    [lbl_new setTag:101];
//    lbl_new.text = @"New!";
//    lbl_new.backgroundColor = [UIColor clearColor];
//    lbl_new.font =[UIFont systemFontOfSize:14.0f];
//    lbl_new.textColor = [UIColor redColor];
//    lbl_new.textAlignment = UITextAlignmentRight;
    
    NSInteger count = [[self.frc_mimeAnswers fetchedObjects]count];
    
    if (indexPath.row < count) {
        // Set mimeAmswer
        CellIdentifier = @"MimeAnswer";
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
            
//            [cell.contentView addSubview:lbl_new];
        }
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
    else {
        // Set None row
        CellIdentifier = @"NoMimeAnswers";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.shadowColor = [UIColor whiteColor];
            cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            cell.textLabel.textColor = [UIColor lightGrayColor];
            
            cell.textLabel.text = @"No answers!";
            
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
        LOG_MIME_MEANSWERSTABLEVIEWCONTROLLER(0,@"%@ Received NSFetechedResultsChangeDelete notification",activityName);
    }
    
    if (controller == self.frc_mimeAnswers) {
        LOG_MIME_MEANSWERSTABLEVIEWCONTROLLER(0, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
        
        if (indexPath.row < kMAXROWS) {
            [self.tbl_answers reloadData];
        }
    }
    else {
        LOG_MIME_MEANSWERSTABLEVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
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
        LOG_REQUEST(0, @"%@ MimeAnswer enumeration was successful", activityName);
        
    }
    else {
        //enumeration failed
        LOG_REQUEST(1, @"%@ MimeAnswer enumeration failure", activityName);
        
    }
}

#pragma mark - ImageManager Delegate Methods
- (void)onImageDownloadComplete:(CallbackResult*)result {
    NSString* activityName = @"Mime_meGuessFullTableViewController.onImageDownloadComplete:";
    NSDictionary* userInfo = result.context;
    
    ImageDownloadResponse* response = (ImageDownloadResponse*)result.response;
    
    if ([response.didSucceed boolValue] == YES) {
        
        UITableViewCell *cell = nil;
        
        NSNumber* mimeAnswerID = [userInfo valueForKey:kMIMEANSWERID];
        
        NSInteger count = [[self.frc_mimeAnswers fetchedObjects] count];
        for (int i = 0; i < count; i++) {
            MimeAnswer *mimeAnswer = [[self.frc_mimeAnswers fetchedObjects] objectAtIndex:i];
            if ([mimeAnswer.objectid isEqualToNumber:mimeAnswerID]) {
                cell = [self.tbl_answers cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                
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
+ (Mime_meAnswersTableViewController*)createInstanceForMimeWithID:(NSNumber *)mimeID {
    Mime_meAnswersTableViewController* instance = [[Mime_meAnswersTableViewController alloc]initWithNibName:@"Mime_meAnswersTableViewController" bundle:nil];
    [instance autorelease];
    instance.mimeID = mimeID;
    return instance;
}

@end
