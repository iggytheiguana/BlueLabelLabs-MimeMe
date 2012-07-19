//
//  Mime_meMenuViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meCreateMimeViewController.h"
#import "Mime_meGuessMenuViewController.h"
#import "Mime_meScrapbookMenuViewController.h"
#import "Mime_meSettingsViewController.h"

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
    
    // Add rounded corners to view
    [self.view.layer setCornerRadius:8.0f];
    
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
    Mime_meCreateMimeViewController* mimeViewController = [Mime_meCreateMimeViewController createInstance];
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:mimeViewController] animated:YES];
}

- (IBAction) onGuessButtonPressed:(id)sender {
    Mime_meGuessMenuViewController* mimeViewController = [Mime_meGuessMenuViewController createInstance];
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:mimeViewController] animated:YES];
}

- (IBAction) onScrapbookButtonPressed:(id)sender {
    Mime_meScrapbookMenuViewController *scrapbookMenuViewController = [Mime_meScrapbookMenuViewController createInstance];
    
    [self.navigationController setViewControllers:[NSArray arrayWithObject:scrapbookMenuViewController] animated:YES];
}

- (IBAction) onSettingsButtonPressed:(id)sender {
    Mime_meSettingsViewController *settingsViewController = [Mime_meSettingsViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:YES];
                     }];
    
    [self.navigationController pushViewController:settingsViewController animated:NO];
}

#pragma mark - Static Initializers
+ (Mime_meMenuViewController*)createInstance {
    Mime_meMenuViewController* instance = [[Mime_meMenuViewController alloc]initWithNibName:@"Mime_meMenuViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
