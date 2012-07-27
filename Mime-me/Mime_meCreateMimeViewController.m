//
//  Mime_meCreateMimeViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meCreateMimeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"
#import "Mime_meFriendsPickerViewController.h"
#import "Mime_meGuessMenuViewController.h"
#import "Mime_meAppDelegate.h"
#import "Macros.h"
#import "Attributes.h"
#import "Word.h"
#import "Mime_meSettingsViewController.h"
#import "Mime.h"

@interface Mime_meCreateMimeViewController ()

@end

@implementation Mime_meCreateMimeViewController
@synthesize frc_words           = __frc_words;
@synthesize wordsCloudEnumerator = m_wordsCloudEnumerator;
@synthesize nv_navigationHeader = m_nv_navigationHeader;
@synthesize v_makeWordView      = m_v_makeWordView;
@synthesize tbl_words           = m_tbl_words;
@synthesize tc_header           = m_tc_header;
@synthesize btn_moreWords       = m_btn_moreWords;
@synthesize btn_makeWord        = m_btn_makeWord;
@synthesize wordsArray          = m_wordsArray;
@synthesize didMakeWord         = m_didMakeWord;
@synthesize chosenWord          = m_chosenWord;
@synthesize chosenWordStr       = m_chosenWordStr;
@synthesize cameraActionSheet   = m_cameraActionSheet;


#pragma mark - Properties
- (NSFetchedResultsController*)frc_words {
    NSString* activityName = @"Mime_meCreateMimeViewController.frc_words:";
    if (__frc_words != nil) {
        return __frc_words;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    Mime_meAppDelegate* app = (Mime_meAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:WORD inManagedObjectContext:app.managedObjectContext];
    
    // Sort in ascending order of number of times the word is used so the user is less likely to get words they have used already
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NUMBEROFTIMESUSED ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    // Fetch 100 words then we'll perform a random selection
    [fetchRequest setFetchBatchSize:100];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_words = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
        LOG_MIME_MECREATEMIMEVIEWCONTROLLER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
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
    
    NSString* message = @"Getting more words...";
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

- (Word*) getRandomWord {
    // We'll use an inverted Roulette Selection algorithm to find the 3 words to display to the user
    
    int wordCount = [[self.frc_words fetchedObjects] count];
    
    if (wordCount > 0) {
        NSMutableArray *fitnessArray = [[NSMutableArray alloc]init];
        
        float sum = 0.0;    // This is the sum of the population fitness
        
        for (int i = 0; i < wordCount; i++) {
            Word *word = [[self.frc_words fetchedObjects] objectAtIndex:i];
            
            // Get the fitness of the word and invert it
            float fitnessF = 1.0;   // the defualt fitness value is 1.0, therefore we need to add 1.0 to each fitness value
            if ([word.numberoftimesused floatValue] > 0.0) {
                // invert the fitness value for this word so it is less likely to be chosen
                fitnessF = (1.0 / ([word.numberoftimesused floatValue] + 1.0));
            }
            
            // Add the words fitness to the fitness total sum
            sum = sum + fitnessF;
            
            NSNumber *fitnessNSNUM = [NSNumber numberWithFloat:fitnessF];
            
            // Add the word's inverted fitness to the fitness array
            [fitnessArray addObject:fitnessNSNUM];
        }
        
        float random = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * sum);
        
        int wordIndex = 0;
        
        if (random > 0) {
            // So long as the random value retuned form the roulette selection is > 0
            // we can move forward with the algorithm. If it is less than or = to 0 it means 
            // the sum of the fitness values is 0.
            while (random > 0) {
                random = random - [[fitnessArray objectAtIndex:wordIndex] floatValue];
                wordIndex++;
            }
            wordIndex--;
        }
        else {
            // If the random value is 0, there is not enough information from the fitness values.
            // We need to use a standard random selection from the availalbe words.
            wordIndex = arc4random() % wordCount;
        }
        
        Word *randomWord = [[self.frc_words fetchedObjects] objectAtIndex:wordIndex];
        
        return randomWord;
    }
    else {
        return nil;
    }
}

- (void) makeWordsArray {
    // Release any existing array
    [self.wordsArray release];
    
    NSMutableArray *wordMtblArray = [[NSMutableArray alloc]init];
    
    // Get 3 random words from the words FRC
    for (int i = 0; i < 3; i++) {
        Word* randomWord = [self getRandomWord];
        if (randomWord != nil) 
        {
            [wordMtblArray addObject:randomWord];
        }
    }
    
    self.wordsArray = [wordMtblArray retain];
    [wordMtblArray release];
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
    [self.view.layer setMasksToBounds:YES];
    
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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.nv_navigationHeader = nil;
    self.v_makeWordView = nil;
    self.tbl_words = nil;
    self.tc_header = nil;
    self.btn_moreWords = nil;
    self.btn_makeWord = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nv_navigationHeader.btn_mime setHighlighted:YES];
    [self.nv_navigationHeader.btn_mime setUserInteractionEnabled:NO];
    
    // Enumerate for words if we don't already have some
    int wordCount = [[self.frc_words fetchedObjects] count];
    if (wordCount <= 0 ) {
        // There are no words, enumerate
        [self enumerateWords];
    }
    else {
        // Create the array of words to present to the user
        [self makeWordsArray];
    }
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Word *word = [self.wordsArray objectAtIndex:(indexPath.row - 1)];
    
    cell.textLabel.text = word.word1;
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
        int wordCount = [[self.frc_words fetchedObjects]count];
        
        if (indexPath.row <= wordCount) {
            static NSString *CellIdentifier = @"Word";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            
            [self configureCell:cell atIndexPath:indexPath];
            
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"NoWords";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                cell.textLabel.text = @"No words available!";
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.textLabel.shadowColor = [UIColor whiteColor];
                cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                cell.userInteractionEnabled = NO;
                
            }
            
            return cell;
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Store the chosen word locally for now
    self.didMakeWord = NO;
    self.chosenWord = [self.wordsArray objectAtIndex:(indexPath.row - 1)];
    self.chosenWordStr = self.chosenWord.word1;
    
    // Launch photo picker
    self.cameraActionSheet = [UICameraActionSheet createCameraActionSheetWithTitle:nil allowsEditing:NO];
    self.cameraActionSheet.a_delegate = self;
    [self.cameraActionSheet showInView:self.view];
    
}

#pragma mark - UIButton Handlers
- (IBAction) onMoreWordsButtonPressed:(id)sender {
    //We only download new words if we haven't done so recently and the enumerator is ready
    if ((!self.wordsCloudEnumerator.isLoading) && ([self.wordsCloudEnumerator canEnumerate])) {
        // Enumerate for new words
        [self enumerateWords];
    }
    else {
        // Get a new selection of words from the existing words in the FRC
        [self makeWordsArray];
        [self.tbl_words reloadData];
    }
}

- (IBAction) onMakeWordButtonPressed:(id)sender {
    self.v_makeWordView = [[[Mime_meUIMakeWordView alloc] initWithFrame:[Mime_meUIMakeWordView frameForMakeWordView]] autorelease];
    self.v_makeWordView.delegate = self;
    
    [self.view addSubview:self.v_makeWordView];
    
}

#pragma mark - Mime_meUIMakeWordView Delegate Methods
- (IBAction) onOkButtonPressed:(id)sender {
    // Store the new word locally for now
    self.didMakeWord = YES;
    NSString *string = self.v_makeWordView.tf_newWord.text;
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.chosenWordStr = trimmedString;
    
    // Launch photo picker
    self.cameraActionSheet = [UICameraActionSheet createCameraActionSheetWithTitle:nil allowsEditing:NO];
    self.cameraActionSheet.a_delegate = self;
    [self.cameraActionSheet showInView:self.view];
}

#pragma mark - UICameraActionSheetDelegate methods
- (void) displayPicker:(UIImagePickerController*) picker {
    // Make sure the status bar remains hidden, otherwise it comes back after the image picker is dismissed
    
    [self presentModalViewController:picker animated:YES];
}

- (void) onPhotoTakenWithThumbnailImage:(UIImage*)thumbnailImage 
                          withFullImage:(UIImage*)image {
    //we handle back end processing of the image from the camera sheet here
    
    // Update the chosen word object
    if (self.didMakeWord == YES) {
        self.chosenWord = [Word createWordWithString:self.chosenWordStr];
    }
    else {
        // Increment the counter for the number of times this word has been used
        NSInteger numTimesUsed = [self.chosenWord.numberoftimesused intValue] + 1;
        self.chosenWord.numberoftimesused = [NSNumber numberWithInt:numTimesUsed];
    }
    
    // Create the Mime object
    Mime *mime = [Mime createMimeWithWordID:self.chosenWord.objectid withImage:image withThumbnail:thumbnailImage];
    
    // Launch the friends picker
    Mime_meFriendsPickerViewController *friendsViewController = [Mime_meFriendsPickerViewController createInstanceWithMimeID:mime.objectid];
    [self.navigationController pushViewController:friendsViewController animated:YES];
    
}

- (void) onCancel {
    // we deal with cancel operations from the action sheet and image picker here
    
    // Set the new word textfield as the first responder again to launch the keyboard
    for (UIView *checkView in [self.view subviews] ) {
        if ((id)checkView == (id)self.v_makeWordView) {
           [self.v_makeWordView.tf_newWord becomeFirstResponder];
        }
    }
}

#pragma mark -  MBProgressHUD Delegate
-(void)hudWasHidden:(MBProgressHUD *)hud {
    NSString* activityName = @"Mime_meCreateMimeViewController.hudWasHidden";
    [self hideProgressBar];
    
    UIProgressHUDView* progressView = (UIProgressHUDView*)hud;
    
    if (progressView.didSucceed) {
        //enumeration was sucessful
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
        [self makeWordsArray];
        [self.tbl_words reloadData];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void) controller:(NSFetchedResultsController *)controller 
    didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
      forChangeType:(NSFetchedResultsChangeType)type 
       newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSString* activityName = @"Mime_meCreateMimeViewController.controller.didChangeObject:";
    
    if (controller == self.frc_words) {
        LOG_MIME_MECREATEMIMEVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController. %p", activityName, &controller);
        
    }
    else {
        LOG_MIME_MECREATEMIMEVIEWCONTROLLER(1, @"%@Received a didChange message from a NSFetchedResultsController that isnt mine. %p", activityName, &controller);
    }
}

#pragma mark - Static Initializers
+ (Mime_meCreateMimeViewController*)createInstance {
    Mime_meCreateMimeViewController* instance = [[Mime_meCreateMimeViewController alloc]initWithNibName:@"Mime_meCreateMimeViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
