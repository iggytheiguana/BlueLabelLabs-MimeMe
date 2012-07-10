//
//  Mime_meUIMakeWordView.m
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/10/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Mime_meUIMakeWordView.h"
#import <QuartzCore/QuartzCore.h>

@implementation Mime_meUIMakeWordView
@synthesize view        = m_view;
@synthesize tf_newWord  = m_tf_newWord;
@synthesize btn_ok      = m_btn_ok;

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<Mime_meUIMakeWordViewDelgate>)del
{
    m_delegate = del;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray* topLevelObjs = nil;
        
        topLevelObjs = [[NSBundle mainBundle] loadNibNamed:@"Mime_meUIMakeWordView" owner:self options:nil];
        if (topLevelObjs == nil)
        {
            NSLog(@"Error! Could not load Mime_meUIMakeWordView file.\n");
        }
        
        [self addSubview:self.view];
        
        // Add rounded corners to navigation header
        [self.view.layer setCornerRadius:8.0f];
        
        // Add drop shadow to navigation header
        [self.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.view.layer setShadowOpacity:0.7f];
        [self.view.layer setShadowRadius:2.0f];
        [self.view.layer setShadowOffset:CGSizeMake(0.0f, 3.0f)];
        [self.view.layer setMasksToBounds:NO];
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
        [self.view.layer setShadowPath:shadowPath];

    }
    return self;
}

- (void)dealloc {
    self.view = nil;
    self.tf_newWord = nil;
    self.btn_ok = nil;
    
    [super dealloc];
}

#pragma mark - UIButton Handlers
- (IBAction) onOkButtonPressed:(id)sender {
    [self.delegate onOkButtonPressed:sender];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Statics
+ (CGRect)frameForMakeWordView {
    return CGRectMake(20, 20, 280, 155);
}

@end
