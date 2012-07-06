//
//  Mime_meMimeViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meMimeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime_meFriendsPickerViewController.h"
#import "Mime_meGuessMenuViewController.h"
#import "Mime_meAppDelegate.h"
#import "Macros.h"
#import "Attributes.h"

@interface Mime_meMimeViewController ()

@end

@implementation Mime_meMimeViewController
@synthesize frc_words           = __frc_words;
@synthesize wordsCloudEnumerator = m_wordsCloudEnumerator;
@synthesize nv_navigationHeader = m_nv_navigationHeader;
@synthesize tbl_words           = m_tbl_words;
@synthesize tc_header           = m_tc_header;
@synthesize btn_getWords        = m_btn_getWords;
@synthesize wordsArray          = m_wordsArray;
@synthesize cameraActionSheet   = m_cameraActionSheet;


#pragma mark - Properties
- (NSFetchedResultsController*)frc_words {
    NSString* activityName = @"Mime_meMimeViewController.frc_words:";
    if (__frc_words != nil) {
        return __frc_words;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:WORD inManagedObjectContext:app.managedObjectContext];
    
    // Sort in ascending order of number of times the word is used so the user does not get words they have already used before
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NUMBEROFTIMESUSED ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    // Fetch 100 words then perform a random selection 
    [fetchRequest setFetchBatchSize:100];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_words = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MEMIMEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_words;
    
}

- (void)showHUDForWordsDownload {
    Mime_meAppDelegate* appDelegate =(Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    UIProgressHUDView* progressView = appDelegate.progressView;
    ApplicationSettings* settings = [[ApplicationSettingsManager instance]settings];
    progressView.delegate = self;
    
    NSString* message = @"Downloading words...";
    [self showProgressBar:message withCustomView:nil withMaximumDisplayTime:settings.http_timeout_seconds];
    
}

- (void) enumerateWords {    
    if (self.wordsCloudEnumerator != nil) {
        [self.wordsCloudEnumerator enumerateUntilEnd:nil];
    }
    else 
    {
        self.wordsCloudEnumerator = nil;
        self.wordsCloudEnumerator = [CloudEnumerator enumeratorForWords];
        self.wordsCloudEnumerator.delegate = self;
        [self.wordsCloudEnumerator enumerateUntilEnd:nil];
    }
    
    [self showHUDForWordsDownload];
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
    self.nv_navigationHeader = navigationHeader;
    [self.view addSubview:self.nv_navigationHeader];
    [navigationHeader release];
    
    // Set up cloud enumerator for words
    self.wordsCloudEnumerator = [CloudEnumerator enumeratorForWords];
    self.wordsCloudEnumerator.delegate = self;
    
    // TEMP: Data arrays for tableview
    self.wordsArray = [NSArray arrayWithObjects:@"high-five", @"ghost", @"waldo", nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.nv_navigationHeader = nil;
    self.tbl_words = nil;
    self.tc_header = nil;
    self.btn_getWords = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nv_navigationHeader.btn_mime setHighlighted:YES];
    [self.nv_navigationHeader.btn_mime setUserInteractionEnabled:NO];
    
    // Enumerate words
    [self enumerateWords];
    
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
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    if (indexPath.row == 0) {
        // Set the header
        static NSString *CellIdentifier = @"Header";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = self.tc_header;
            
            cell.userInteractionEnabled = NO;
        }
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"Word";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            cell.textLabel.text = [self.wordsArray objectAtIndex:(indexPath.row - 1)];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Launch photo picker
    self.cameraActionSheet = [UICameraActionSheet createCameraActionSheetWithTitle:nil allowsEditing:NO];
    self.cameraActionSheet.a_delegate = self;
    [self.cameraActionSheet showInView:self.view];
    
}

#pragma mark - UIButton Handlers
- (IBAction) onHomeButtonPressed:(id)sender {
    Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
                     }];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
}

- (IBAction) onMimeButtonPressed:(id)sender {
    
}

- (IBAction) onGuessButtonPressed:(id)sender {
    Mime_meGuessMenuViewController *guessMenuViewController = [Mime_meGuessMenuViewController createInstance];
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:guessMenuViewController] animated:NO];
}

- (IBAction) onScrapbookButtonPressed:(id)sender {
    
}

- (IBAction) onSettingsButtonPressed:(id)sender {
    
}

#pragma mark - UICameraActionSheetDelegate methods
- (void) displayPicker:(UIImagePickerController*) picker {
    // Make sure the status bar remains hidden, otherwise it comes back after the image picker is dismissed
    
    [self presentModalViewController:picker animated:YES];
}

- (void) onPhotoTakenWithThumbnailImage:(UIImage*)thumbnailImage 
                          withFullImage:(UIImage*)image {
    //we handle back end processing of the image from the camera sheet here
    
    // Make sure the status bar remains hidden, otherwise it comes back after the image picker is dismissed
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    Mime_meFriendsPickerViewController *friendsViewController = [Mime_meFriendsPickerViewController createInstance];
    [self.navigationController pushViewController:friendsViewController animated:YES];
    
}

- (void) onCancel {
    // we deal with cancel operations from the action sheet here
    
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meMimeViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed) {
        //enumeration was sucesful
        LOG_REQUEST(0, @"%@ Enumeration request was successful", activityName);
        
    }
    else {
        //enumeration failed
        LOG_REQUEST(0, @"%@ Enumeration request failure", activityName);
        
    }
}

#pragma mark - CloudEnumeratorDelegate
- (void) onEnumerateComplete:(CloudEnumerator*)enumerator 
                 withResults:(NSArray *)results 
                withUserInfo:(NSDictionary *)userInfo
{
    if (enumerator == self.wordsCloudEnumerator) {
        [self hideProgressBar];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"Mime_meMimeViewController.controller.didChangeObject:";
    if (controller == self.frc_words) {
        
    }
    else {
        LOG_MIME_MEMIMEVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - Static Initializers
+ (Mime_meMimeViewController*)createInstance {
    Mime_meMimeViewController* instance = [[Mime_meMimeViewController alloc]initWithNibName:@"Mime_meMimeViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
