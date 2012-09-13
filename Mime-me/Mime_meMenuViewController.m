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
@synthesize gad_bannerView  = m_gad_bannerView;


#pragma mark - Helper Methods
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
    
    // Initialize Google AdMob Banner view
    [self initializeGADBannerView];
    
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
    
    self.gad_bannerView = nil;
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
