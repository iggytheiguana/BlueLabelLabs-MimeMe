//
//  Mime_meMenuViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meMenuViewController.h"
#import "Mime_meMimeViewController.h"

@interface Mime_meMenuViewController ()

@end

@implementation Mime_meMenuViewController
@synthesize btn_mime        = m_btn_mime;
@synthesize btn_guess       = m_btn_guess;
@synthesize btn_scrapbook   = m_btn_scrapbook;
@synthesize btn_settings    = m_btn_settings;
@synthesize btn_getGems     = m_btn_getGems;

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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.btn_mime = nil;
    self.btn_guess = nil;
    self.btn_scrapbook = nil;
    self.btn_settings = nil;
    self.btn_getGems = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIButton Handlers
- (IBAction) onMimeButtonPressed:(id)sender {
    Mime_meMimeViewController* mimeViewController = [Mime_meMimeViewController createInstance];
    
//    [self.navigationController pushViewController:mimeViewController animated:YES];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:mimeViewController] animated:YES];
//    [self addChildViewController:mimeViewController];
//    [mimeViewController didMoveToParentViewController:self];
//    [self.tabBarController setSelectedIndex:1];
    
}

- (IBAction) onGuessButtonPressed:(id)sender {
    
}

- (IBAction) onScrapbookButtonPressed:(id)sender {
    
}

- (IBAction) onSettingsButtonPressed:(id)sender {
    
}

#pragma mark - Static Initializers
+ (Mime_meMenuViewController*)createInstance {
    Mime_meMenuViewController* instance = [[Mime_meMenuViewController alloc]initWithNibName:@"Mime_meMenuViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
