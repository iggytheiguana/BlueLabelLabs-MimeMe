//
//  Mime_meUIMakeWordView.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/10/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Mime_meUIMakeWordViewDelgate <NSObject>
@required

- (IBAction) onOkButtonPressed:(id)sender;

@end

@interface Mime_meUIMakeWordView : UIView < UITextFieldDelegate> {
    id<Mime_meUIMakeWordViewDelgate> m_delegate;
    
    UIView          *m_view;
    
    UIView          *m_v_makeWordContainer;
    UIView          *m_v_makeWordHeader;
    
    UITextField     *m_tf_newWord;
    
    UIButton        *m_btn_ok;
    UIButton        *m_btn_close;
}

@property (nonatomic, assign) id<Mime_meUIMakeWordViewDelgate>  delegate;

@property (nonatomic, retain) IBOutlet  UIView          *v_makeWordContainer;
@property (nonatomic, retain) IBOutlet  UIView          *v_makeWordHeader;

@property (nonatomic, retain) IBOutlet  UIView          *view;

@property (nonatomic, retain) IBOutlet  UITextField     *tf_newWord;

@property (nonatomic, retain) IBOutlet  UIButton        *btn_ok;
@property (nonatomic, retain) IBOutlet  UIButton        *btn_close;

- (IBAction) onCloseButtonPressed:(id)sender;

+ (CGRect)frameForMakeWordView;

@end
