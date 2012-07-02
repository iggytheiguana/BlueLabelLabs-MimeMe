//
//  UICustomAlertView.h
//  Mime-me
//
//  Created by Jordan Gurrieri on 7/2/12.
//  Copyright (c) 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UICustomAlertView : UIAlertView {
    id  m_targetObject;
    id  m_withObject;
    SEL m_onFinishSelector;
}

@property (nonatomic, assign) id targetObject;
@property (nonatomic, assign) id withObject;
@property (nonatomic, assign) SEL onFinishSelector;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate onFinishSelector:(SEL)sel onTargetObject:(id)targetObject withObject:(id)parameter cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
