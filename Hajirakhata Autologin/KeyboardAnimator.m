//
//  KeyboardAnimator.m
//  MissYouCall
//
//  Created by Ratul Sharker on 8/4/15.
//  Copyright (c) 2015 REVE Systems. All rights reserved.
//

#import "KeyboardAnimator.h"


@implementation KeyboardAnimator
{
    CGFloat animatedHeight;
    UIView *viewThatWillBeActuallyAnimated;
    NSArray *textFields;
    NSArray *targetTextFields;
    
    NSArray *verticalBottomConstraints;
    NSArray *verticalNonBottomConstraints;
    
    
    CGFloat squeezeViewAnimationHeight;
    UIView *squeezeView;
    
    
    //some optional params
    NSTimeInterval keyboardUpTimeInterval, keyboardDownTimeInterval;
    CGFloat        spacingBetweenKeyboardAndTarget;
    
    NSString *animKeyboard;
}

-(id)initKeyboardAnimatorWithTextFieldArray:(NSArray*)tf
                   AndWhichViewWillAnimated:(UIView*)view
                          bottomConstraints:(NSArray*)bottomConstraints
                       nonBottomConstraints:(NSArray*)nonBottomConstraints
{
    self = [super init];
    
    if(self != nil)
    {
        //do necessary initialization here
        animatedHeight = 0;
        textFields = tf;
        targetTextFields = tf;
        viewThatWillBeActuallyAnimated = view;
        
        squeezeViewAnimationHeight = 0;
        squeezeView = nil;
        
        
        verticalBottomConstraints = bottomConstraints;
        verticalNonBottomConstraints = nonBottomConstraints;
        
        //setting default values to the animation params
        keyboardUpTimeInterval = DEFAULT_KEYBOARD_UP_ANIMATION_DURATION;
        keyboardDownTimeInterval = DEFAULT_KEYBOARD_DOWN_ANIMATION_DURATION;
        spacingBetweenKeyboardAndTarget = DEFAULT_SPACING_BETWEEN_TEXTFIELD_AND_KEYBOARD;
    }
    
    return self;
}

-(id)initKeyboardAnimatorWithTextField:(NSArray*)tf
                   withTargetTextField:(NSArray*)targetTf
              AndWhichViewWillAnimated:(UIView*)animatedView
                     bottomConstraints:(NSArray*)bottomConstraints
                  nonBottomConstraints:(NSArray*)nonBottomConstraints
{
    
    self = [self initKeyboardAnimatorWithTextFieldArray:tf
                               AndWhichViewWillAnimated:animatedView
                                      bottomConstraints:bottomConstraints
                                   nonBottomConstraints:nonBottomConstraints];
    
    if(self != nil)
    {
        //additional param initializer values
        targetTextFields = targetTf;
        viewThatWillBeActuallyAnimated = animatedView;
    }
    
    return self;
}


//new feature experiment
-(id)initKeyboardAnimatorWithSqueezeView:(UIView*)sqView
{
    self = [super init];
    if(self)
    {
        //everything is ok
        squeezeViewAnimationHeight = 0;
        squeezeView = sqView;
    }
    return self;
}



#pragma mark public functionality
-(void)registerKeyboardEventListener
{
    //register keyboard on screen & off screen callback notification
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [notiCenter addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)unregisterKeyboardEventListener
{
    //de-register keyboard on screen & off screen callback notification
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter removeObserver:self];
}

#pragma mark optional public functionality
-(void) setKeyboardUpAnimationDuration:(NSTimeInterval)uptimeInterval
{
    keyboardUpTimeInterval = uptimeInterval;
}

-(void) setKeyboardDownAnimationDuration:(NSTimeInterval)downTimeInterval
{
    keyboardDownTimeInterval = downTimeInterval;
}

-(void) setSpacingBetweenKeyboardAndTargetedTextField:(CGFloat)spacing
{
    spacingBetweenKeyboardAndTarget = spacing;
}




#pragma keyboard appearance
-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [[UIApplication sharedApplication].keyWindow convertRect:rawFrame fromView:nil];
    
    //NSLog(@"KEYBOARD FRAME: %@", NSStringFromCGRect(keyboardFrame));
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        
        //check for the squeeze view animation
        if(squeezeView != nil)
        {
            //there is something to squeeze :P
            NSLog(@"squeeze view %@", NSStringFromCGRect(squeezeView.frame));
            NSLog(@"keyboard frame %@", NSStringFromCGRect(keyboardFrame));
            
            //value will be minus
            squeezeViewAnimationHeight = keyboardFrame.origin.y -
            (squeezeView.frame.origin.y + squeezeView.frame.size.height + DEFAULT_SPACING_WHILE_SQUEEZING);
            
            [UIView animateWithDuration:DEFAULT_KEYBOARD_UP_ANIMATION_DURATION animations:^{
               
                squeezeView.frame = CGRectMake(squeezeView.frame.origin.x,
                                               squeezeView.frame.origin.y,
                                               squeezeView.frame.size.width,
                                               squeezeView.frame.size.height + squeezeViewAnimationHeight);
            }];
        }
        
        
        
        //find out which uitextField is responsible for this keyboard operation
        UITextField *responsibleTextField = nil;
        UIView *viewWhichWillAnimate = viewThatWillBeActuallyAnimated;
        
        for(unsigned int i = 0;i < textFields.count ; i++)
        {
            UITextField *textField = [textFields objectAtIndex:i];
            if([textField isFirstResponder])
            {
                responsibleTextField = [targetTextFields objectAtIndex:i];
                break;
            }
        }
        
        if(responsibleTextField != nil)
        {
            //now we calculate, do we need any animation or not

            CGPoint topLeftCorner = [responsibleTextField convertPoint:CGPointZero toView:[UIApplication sharedApplication].keyWindow];
            
            //NSLog(@"RESPONSIBLE FIELD FRAME %f %f %f", topLeftCorner.y, responsibleTextField.frame.size.height , keyboardFrame.origin.y);
            if(topLeftCorner.y + responsibleTextField.frame.size.height > keyboardFrame.origin.y)
            {
                CGFloat animatedDistance = 0;
                
                //NSLog(@"Animated distance %f Animated Height %f", animatedDistance, animatedHeight);
                
                //so now we actually need the animation
                if(animatedHeight == 0)
                {
                    animatedDistance = animatedHeight = responsibleTextField.frame.size.height + topLeftCorner.y - keyboardFrame.origin.y + spacingBetweenKeyboardAndTarget;
                }
                else
                {
                    animatedDistance = responsibleTextField.frame.size.height + topLeftCorner.y - keyboardFrame.origin.y + spacingBetweenKeyboardAndTarget;
                    animatedHeight += animatedDistance;
                }
                
                if(verticalBottomConstraints || verticalNonBottomConstraints)
                {
                    if(verticalBottomConstraints)
                    for(NSLayoutConstraint *verticalConstraint in verticalBottomConstraints)
                    {
                        [UIView animateWithDuration:keyboardUpTimeInterval animations:^{
                            verticalConstraint.constant += animatedDistance;
                            [viewWhichWillAnimate layoutIfNeeded];
                        }];
                    }
                    
                    if(verticalNonBottomConstraints)
                    for(NSLayoutConstraint *verticalConstraint in verticalNonBottomConstraints)
                    {
                        [UIView animateWithDuration:keyboardUpTimeInterval animations:^{
                            verticalConstraint.constant -= animatedDistance;
                            [viewWhichWillAnimate layoutIfNeeded];
                        }];
                    }
                    
                }
                else
                
                
                //NSLog(@"Animated distance %f Animated Height %f", animatedDistance, animatedHeight);
                if(animatedDistance != 0)
                {
                    
                    [UIView animateWithDuration:keyboardUpTimeInterval animations:^{
                        viewWhichWillAnimate.frame = CGRectMake(viewWhichWillAnimate.frame.origin.x
                                                                , viewWhichWillAnimate.frame.origin.y - animatedDistance
                                                                , viewWhichWillAnimate.frame.size.width
                                                                , viewWhichWillAnimate.frame.size.height);
                    }];
                }
            }
        }
        else
        {
            //these grp or field is not responsible for animating the keybaord up word
        }
    }];
}

-(void)keyboardOffScreen:(NSNotification *)notification
{
    
    if(squeezeView && squeezeViewAnimationHeight != 0)
    {
        [UIView animateWithDuration:DEFAULT_KEYBOARD_DOWN_ANIMATION_DURATION animations:^{
            
            squeezeView.frame = CGRectMake(squeezeView.frame.origin.x,
                                           squeezeView.frame.origin.y,
                                           squeezeView.frame.size.width,
                                           squeezeView.frame.size.height - squeezeViewAnimationHeight);
        }];
    }
    
    
    if(animatedHeight > 0)
    {
        
        if(verticalBottomConstraints || verticalNonBottomConstraints)
        {
            if(verticalBottomConstraints)
                for(NSLayoutConstraint *verticalConstraint in verticalBottomConstraints)
                {
                    [UIView animateWithDuration:keyboardUpTimeInterval animations:^{
                        verticalConstraint.constant -= animatedHeight;
                        [viewThatWillBeActuallyAnimated layoutIfNeeded];
                    }];
                }
            
            if(verticalNonBottomConstraints)
                for(NSLayoutConstraint *verticalConstraint in verticalNonBottomConstraints)
                {
                    [UIView animateWithDuration:keyboardUpTimeInterval animations:^{
                        verticalConstraint.constant += animatedHeight;
                        [viewThatWillBeActuallyAnimated layoutIfNeeded];
                    }];
                }
            
        }
        else
        {
            [UIView animateWithDuration:keyboardDownTimeInterval animations:^{
                viewThatWillBeActuallyAnimated.frame = CGRectMake(viewThatWillBeActuallyAnimated.frame.origin.x
                                                                  , viewThatWillBeActuallyAnimated.frame.origin.y + animatedHeight
                                                                  , viewThatWillBeActuallyAnimated.frame.size.width
                                                                  , viewThatWillBeActuallyAnimated.frame.size.height);
            }];
        }
        animatedHeight = 0;
    }
}




@end
