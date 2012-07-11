//
//  Mime_meShareMimeViewController.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/6/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meShareMimeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Mime_meMenuViewController.h"

@interface Mime_meShareMimeViewController ()

@end

@implementation Mime_meShareMimeViewController
@synthesize v_sentContainer     = m_v_sentContainer;
@synthesize v_sentHeader        = m_v_sentHeader;

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
    
    // Add drop shadow to container view
    [self.v_sentContainer.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.v_sentContainer.layer setShadowOpacity:0.7f];
    [self.v_sentContainer.layer setShadowRadius:5.0f];
    [self.v_sentContainer.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [self.v_sentContainer.layer setMasksToBounds:NO];
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:self.v_sentContainer.layer.bounds].CGPath;
    [self.v_sentContainer.layer setShadowPath:shadowPath];
    
    // Add rounded corners to container view
    [self.v_sentContainer.layer setCornerRadius:8.0f];
    [self.v_sentContainer.layer setOpaque:NO];
    
    // Add rounded corners to top part of header view
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.v_sentHeader.bounds 
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(8.0, 8.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.v_sentHeader.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    self.v_sentHeader.layer.mask = maskLayer;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.v_sentContainer = nil;
    self.v_sentHeader = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIButton Handlers
- (IBAction) onHomeButtonPressed:(id)sender {
    Mime_meMenuViewController *menuViewController = [Mime_meMenuViewController createInstance];
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:YES];
                     }];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:menuViewController] animated:NO];
}


#pragma mark - Static Initializers
+ (Mime_meShareMimeViewController*)createInstance {
    Mime_meShareMimeViewController* instance = [[Mime_meShareMimeViewController alloc]initWithNibName:@"Mime_meShareMimeViewController" bundle:nil];
    [instance autorelease];
    return instance;
}

@end
