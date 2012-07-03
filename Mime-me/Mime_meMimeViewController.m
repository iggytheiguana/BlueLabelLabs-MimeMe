//
//  Mime_meMimeViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meMimeViewController.h"

@interface Mime_meMimeViewController ()

@end

@implementation Mime_meMimeViewController
@synthesize btn_home    = m_btn_home;

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
    
    self.btn_home = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIButton Handlers
- (IBAction) onHomeButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
//    [self removeFromParentViewController];
}

#pragma mark - Static Initializers
+ (Mime_meMimeViewController*)createInstance {
    Mime_meMimeViewController* instance = [[Mime_meMimeViewController alloc]initWithNibName:@"Mime_meMimeViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
