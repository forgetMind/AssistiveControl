//
//  AssistiveControl.m
//  
//
//  Created by xiang on 16/5/18.
//  Copyright © 2016年 ZhanxiangQu. All rights reserved.
//

#import "QZXAssistiveControl.h"

/* assistive Control Location and Position. */

struct Location {
    CGPoint Position;
    QZXAssistiveControlLocation assistiveControlLocation;
};
typedef struct Location Location;

@interface QZXAssistiveControl ()

@property (nonatomic) CGPoint previousTouchPoint, collapsedViewLastPosition;
@property (nonatomic) BOOL draggedAfterFirstTouch;

@property (nonatomic , strong ) NSLayoutConstraint * topLayoutConstraint;

@property (nonatomic , strong ) NSLayoutConstraint * leadingLayoutConstraint;

@property (nonatomic , strong ) NSLayoutConstraint * bottomLayoutConstraint;

@property (nonatomic , strong ) NSLayoutConstraint * trailingLayoutConstraint;


@property (nonatomic , strong ) NSLayoutConstraint * WidthLayoutConstraint;

@property (nonatomic , strong ) NSLayoutConstraint * HeightLayoutConstraint;


@property (nonatomic , strong ) NSLayoutConstraint * centerXLayoutConstraint;

@property (nonatomic , strong ) NSLayoutConstraint * centerYLayoutConstraint;


@property (nonatomic , strong ) NSLayoutConstraint * expandedViewHeightLayoutConstraint;

@property (nonatomic , strong ) NSLayoutConstraint * expandedViewWidthLayoutConstraint;

@property (nonatomic , strong ) NSLayoutConstraint * expandedViewCenterXLayoutConstraint;

@property (nonatomic , strong ) NSLayoutConstraint * expandedViewCenterYLayoutConstraint;

@end

@implementation QZXAssistiveControl

const static NSTimeInterval kAnimDuration = 0.3f;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        self.stickyEdge = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}



- (void)didMoveToSuperview
{
    // once the control is added to a superview and stickyEdge is true,
    // we need to calculate the correct position of the control
    [self adjustControlPositionForStickyEdgeWithCompletion:nil];
}

- (void)setStickyEdge:(BOOL)stickyEdge
{
    _stickyEdge = stickyEdge;
    [self adjustControlPositionForStickyEdgeWithCompletion:nil];
}

- (void)setCollapsedView:(UIView *)collapsedView
{
    [_collapsedView removeFromSuperview];
    _collapsedView = collapsedView;
    _collapsedView.userInteractionEnabled = NO;
    _collapsedViewLastPosition = collapsedView.frame.origin;
    
    if (_currentState == QZXAssistiveControlStateCollapsed)
    {
        [self showCollapsedView];
    }
}

- (void)setExpandedView:(UIView *)expandedView
{
    [_expandedView removeFromSuperview];
    _expandedView = expandedView;
    
    if (_currentState == QZXAssistiveControlStateExpanded)
    {
        [self showExpandedView];
    }
}

#pragma mark - Essential control action events
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _previousTouchPoint = [touch locationInView:self.superview];
    _draggedAfterFirstTouch = NO;
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self.superview];
    
    _draggedAfterFirstTouch = YES;
    
    if (_currentState == QZXAssistiveControlStateCollapsed)
    {
        CGSize movementDelta = CGSizeMake(touchPoint.x - _previousTouchPoint.x,touchPoint.y - _previousTouchPoint.y);
        self.center = CGPointMake(self.center.x + movementDelta.width, self.center.y + movementDelta.height);
    }
    
    _previousTouchPoint = touchPoint;
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_currentState == QZXAssistiveControlStateCollapsed)
    {
        if (_draggedAfterFirstTouch)
        {
            [self adjustControlPositionForStickyEdgeWithCompletion:nil];
        }
        else
        {
            [self showExpandedView];
        }
    }
    else
    {
        CGPoint touchPoint = [touch locationInView:self];
        if (CGRectContainsPoint(_expandedView.frame, touchPoint) == NO)
        {
            [self showCollapsedView];
        }
    }
    
}


#pragma mark - Private
- (void)adjustControlPositionForStickyEdgeWithCompletion:(void (^)(BOOL frameChanged))completion
{
    if (_stickyEdge && self.superview != nil)
    {
        Location location = [self calculateStickyEdgeDestinationPosition];
        CGPoint destPosition = location.Position;
        
        if (CGPointEqualToPoint(self.frame.origin, destPosition) == NO)
        {
            [UIView animateWithDuration:kAnimDuration animations:^(){
     
                [self changeAssistiveControlConstraintPriority];
                
            } completion:^(BOOL finished){
                if (completion != nil)
                {
                    completion(YES);
                }
            }];
        }
        else if (completion != nil)
        {
            completion(NO);
        }
    }
    else if (completion != nil)
    {
        completion(NO);
    }
}

- (Location)calculateStickyEdgeDestinationPosition
{
    CGRect containerBounds = self.superview.bounds;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(self.frame.origin.y, self.frame.origin.x, containerBounds.size.height - (self.frame.origin.y + self.frame.size.height), containerBounds.size.width - (self.frame.origin.x + self.frame.size.width));
    CGFloat edgeDistance = edgeInsets.top;
    Location location ;
    CGPoint destPosition = CGPointMake(self.frame.origin.x, 0);
    location.assistiveControlLocation = QZXAssistiveControlLocationTop;
    
    if (edgeInsets.bottom < edgeDistance)
    {
        edgeDistance = edgeInsets.bottom;
        destPosition = CGPointMake(self.frame.origin.x, containerBounds.size.height - self.frame.size.height);
        location.assistiveControlLocation = QZXAssistiveControlLocationBottom;

    }
    if (edgeInsets.left < edgeDistance)
    {
        edgeDistance = edgeInsets.left;
        destPosition = CGPointMake(0, self.frame.origin.y);
        location.assistiveControlLocation = QZXAssistiveControlLocationLeading;
    }
    if (edgeInsets.right < edgeDistance)
    {
        destPosition = CGPointMake(containerBounds.size.width - self.frame.size.width, self.frame.origin.y);
        location.assistiveControlLocation = QZXAssistiveControlLocationTrailing;
    }
    
    if (self.frame.origin.x < 0)
    {
        destPosition.x = 0;
        location.assistiveControlLocation = QZXAssistiveControlLocationLeading;
    }
    else if (self.frame.origin.x > containerBounds.size.width - self.frame.size.width)
    {
        destPosition.x = containerBounds.size.width - self.frame.size.width;
        location.assistiveControlLocation = QZXAssistiveControlLocationTrailing;
    }
    if (destPosition.y < 0)
    {
        destPosition.y = 0;
        location.assistiveControlLocation = QZXAssistiveControlLocationTrailing;
    }
    else if (destPosition.y > containerBounds.size.height - self.frame.size.height)
    {
        destPosition.y = containerBounds.size.height - self.frame.size.height;
        location.assistiveControlLocation = QZXAssistiveControlLocationLeading;
    }
    
    location.Position = destPosition;
    return location;
}

- (void)changeAssistiveControlConstraintPriority
{

    Location location = [self calculateStickyEdgeDestinationPosition];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.collapsedView.translatesAutoresizingMaskIntoConstraints = NO;
    [self setNeedsLayout];

    switch (location.assistiveControlLocation)
    {
        case QZXAssistiveControlLocationTop:
        {
            [self.superview removeConstraint: self.centerXLayoutConstraint];
            

            
            self.centerXLayoutConstraint = nil;
            self.centerXLayoutConstraint = [NSLayoutConstraint
                                                                 constraintWithItem:self
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 multiplier:(location.Position.x + self.collapsedView.bounds.size.width / 2.0f) / (self.superview.bounds.size.width / 2.0f)
                                                                 constant:0.0f];
            
            self.centerXLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
            [self.superview addConstraint:self.centerXLayoutConstraint];
            
            
            
            self.centerYLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.topLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
            self.leadingLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.bottomLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.trailingLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            
        }
            break;
            
        case QZXAssistiveControlLocationLeading:
        {
            [self.superview removeConstraint: self.centerYLayoutConstraint];
            self.centerYLayoutConstraint = nil;
            self.centerYLayoutConstraint = [NSLayoutConstraint
                                                                  constraintWithItem:self
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  multiplier:(location.Position.y + self.collapsedView.bounds.size.height / 2.0f) / (self.superview.bounds.size.height / 2.0f)
                                                                  constant:0.0f];
            
            self.centerYLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
            [self.superview addConstraint:self.centerYLayoutConstraint];
            
            self.centerXLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.topLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.leadingLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
            self.bottomLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.trailingLayoutConstraint.priority = UILayoutPriorityDefaultLow;
        }
            break;
            
        case QZXAssistiveControlLocationBottom:
        {
            [self.superview removeConstraint: self.centerXLayoutConstraint];
            self.centerXLayoutConstraint = nil;
            self.centerXLayoutConstraint = [NSLayoutConstraint
                                                                 constraintWithItem:self
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 multiplier:(location.Position.x + self.collapsedView.bounds.size.width / 2.0f) / (self.superview.bounds.size.width / 2.0f)
                                                                 constant:0.0f];
            
            self.centerXLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
            [self.superview addConstraint:self.centerXLayoutConstraint];
            
            self.centerYLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.topLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.leadingLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.bottomLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
            self.trailingLayoutConstraint.priority = UILayoutPriorityDefaultLow;
        }
            break;
            
        case QZXAssistiveControlLocationTrailing:
        {
            [self.superview removeConstraint: self.centerYLayoutConstraint];
            self.centerYLayoutConstraint = nil;
            self.centerYLayoutConstraint = [NSLayoutConstraint
                                                                  constraintWithItem:self
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  multiplier:(location.Position.y + self.collapsedView.bounds.size.height / 2.0f) / (self.superview.bounds.size.height / 2.0f)
                                                                  constant:0.0f];
            
            self.centerYLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
            [self.superview addConstraint:self.centerYLayoutConstraint];
            
            self.centerXLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.topLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.leadingLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.bottomLayoutConstraint.priority = UILayoutPriorityDefaultLow;
            self.trailingLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
        }
            break;
            
        default:
            break;
    }

    [self layoutIfNeeded];
}

- (void)showExpandedView
{
    [_collapsedView removeFromSuperview];
    
    _collapsedViewLastPosition = self.frame.origin;
    
    // work out where to put expanded view
    UIView *container = self.superview;
    CGRect containerBounds = container.bounds;
    CGRect destFrame = _expandedView.frame;
    
    if (_expandedLocation == QZXAssistiveControlLocationCenter)
    {
        destFrame.origin = CGPointMake((containerBounds.size.width - destFrame.size.width) / 2, (containerBounds.size.height - destFrame.size.height) / 2);
    }
    else
    {
        if (_expandedLocation & QZXAssistiveControlLocationTrailing)
        {
            destFrame.origin.y = 0;
        }
        if (_expandedLocation & QZXAssistiveControlLocationTop)
        {
            destFrame.origin.x = containerBounds.size.width - destFrame.size.width;
        }
        if (_expandedLocation & QZXAssistiveControlLocationBottom)
        {
            destFrame.origin.y = containerBounds.size.height - destFrame.size.height;
        }
        if (_expandedLocation & QZXAssistiveControlLocationLeading)
        {
            destFrame.origin.x = 0;
        }
        if (_expandedLocation & QZXAssistiveControlExpandedLocationAgainstCollapsed)
        {
            if ((containerBounds.size.width - _collapsedViewLastPosition.x) < destFrame.size.width)
            {
                destFrame.origin.x = containerBounds.size.width - destFrame.size.width;
                destFrame.origin.y = _collapsedViewLastPosition.y;
            }
            else
            {
                destFrame.origin = _collapsedViewLastPosition;
            }
            
        }
    }
    
    
    [self addSubview:_expandedView];

    self.WidthLayoutConstraint.constant = self.superview.bounds.size.width;
    self.HeightLayoutConstraint.constant = self.superview.bounds.size.height;
    self.WidthLayoutConstraint.priority = UILayoutPriorityDefaultLow;
    self.HeightLayoutConstraint.priority = UILayoutPriorityDefaultLow;
//    [self.superview removeConstraint: self.centerYLayoutConstraint];
//    self.centerYLayoutConstraint = nil;
//    self.centerYLayoutConstraint = [NSLayoutConstraint
//                                    constraintWithItem:self
//                                    attribute:NSLayoutAttributeCenterY
//                                    relatedBy:NSLayoutRelationEqual
//                                    toItem:self.superview
//                                    attribute:NSLayoutAttributeCenterY
//                                    multiplier:1
//                                    constant:0.0f];
//    self.centerYLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
//    [self.superview addConstraint:self.centerYLayoutConstraint];
//    
//    [self.superview removeConstraint: self.centerXLayoutConstraint];
//    self.centerXLayoutConstraint = nil;
//    self.centerXLayoutConstraint = [NSLayoutConstraint
//                                    constraintWithItem:self
//                                    attribute:NSLayoutAttributeCenterX
//                                    relatedBy:NSLayoutRelationEqual
//                                    toItem:self.superview
//                                    attribute:NSLayoutAttributeCenterX
//                                    multiplier:1
//                                    constant:0.0f];
//    self.centerXLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
//    [self.superview addConstraint:self.centerXLayoutConstraint];
    self.centerXLayoutConstraint.priority = UILayoutPriorityDefaultLow;
    self.centerYLayoutConstraint.priority = UILayoutPriorityDefaultLow;
    self.topLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    self.leadingLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    self.bottomLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    self.trailingLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    
    
    //expandedView NSLayoutAttributeCenterY LayoutConstraint
    self.expandedViewCenterYLayoutConstraint = [NSLayoutConstraint
                                                constraintWithItem:self.expandedView
                                                attribute:NSLayoutAttributeCenterY
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:self
                                                attribute:NSLayoutAttributeCenterY
                                                multiplier:(destFrame.origin.y + self.expandedView.bounds.size.height / 2.0f) / (self.superview.bounds.size.height / 2.0f)
                                                constant:0.0f];
    //expandedView NSLayoutAttributeCenterX LayoutConstraint
    self.expandedViewCenterXLayoutConstraint = [NSLayoutConstraint
                                                constraintWithItem:self.expandedView
                                                attribute:NSLayoutAttributeCenterX
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:self
                                                attribute:NSLayoutAttributeCenterX
                                                multiplier:(destFrame.origin.x + self.expandedView.bounds.size.width / 2.0f) / (self.superview.bounds.size.width / 2.0f)
                                                constant:0.0f];
    
    [self addConstraintToExpandedView];
    _currentState = QZXAssistiveControlStateExpanded;
}
- (void)addConstraintToExpandedView
{
    self.expandedView.translatesAutoresizingMaskIntoConstraints = NO;

    //expandedView NSLayoutAttributeWidth LayoutConstraint
    NSLayoutConstraint * expandedViewWidthLayoutConstraint = [NSLayoutConstraint
                                                                       constraintWithItem:self.expandedView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:0.0f
                                                                       constant:self.expandedView.bounds.size.width];
    [self addConstraint:expandedViewWidthLayoutConstraint];
    //expandedView NSLayoutAttributeHeight LayoutConstraint
    NSLayoutConstraint * expandedViewHeightLayoutConstraint = [NSLayoutConstraint
                                                           constraintWithItem:self.expandedView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0f
                                                           constant:self.expandedView.bounds.size.height];
    [self addConstraint:expandedViewHeightLayoutConstraint];
    UIView *container = self.superview;
    CGRect containerBounds = container.bounds;
    CGRect destFrame = _expandedView.frame;
    if (_expandedLocation == QZXAssistiveControlLocationCenter)
    {
        //expandedView NSLayoutAttributeCenterY LayoutConstraint

        [self addConstraint:self.expandedViewCenterYLayoutConstraint];
        //expandedView NSLayoutAttributeCenterX LayoutConstraint

        [self addConstraint:self.expandedViewCenterXLayoutConstraint];
    }
    else
    {
        if (_expandedLocation & QZXAssistiveControlLocationTrailing)
        {
            //expandedView NSLayoutAttributeTrailing LayoutConstraint
            NSLayoutConstraint * expandedViewTrailingLayoutConstraint = [NSLayoutConstraint
                                                                      constraintWithItem:self.expandedView
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0f
                                                                      constant: 0.0f ];
            [self addConstraint:expandedViewTrailingLayoutConstraint];
            //expandedView NSLayoutAttributeCenterY LayoutConstraint
            
            [self addConstraint:self.expandedViewCenterYLayoutConstraint];
        }
        if (_expandedLocation & QZXAssistiveControlLocationTop)
        {
            //expandedView NSLayoutAttributeTop LayoutConstraint
            NSLayoutConstraint * expandedViewTopLayoutConstraint = [NSLayoutConstraint
                                                                 constraintWithItem:self.expandedView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                                 attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0f
                                                                 constant:0.0f ];
            [self addConstraint:expandedViewTopLayoutConstraint];
            [self addConstraint:self.expandedViewCenterXLayoutConstraint];

        }
        if (_expandedLocation & QZXAssistiveControlLocationBottom)
        {
            //expandedView NSLayoutAttributeBottom LayoutConstraint
            NSLayoutConstraint * expandedViewBottomLayoutConstraint = [NSLayoutConstraint
                                                                    constraintWithItem:self.expandedView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                    attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0f
                                                                    constant:0.0f ];
            [self addConstraint:expandedViewBottomLayoutConstraint];
            [self addConstraint:self.expandedViewCenterXLayoutConstraint];
        }
        if (_expandedLocation & QZXAssistiveControlLocationLeading)
        {
            //expandedView NSLayoutAttributeLeading LayoutConstraint
            NSLayoutConstraint * expandedViewLeadingLayoutConstraint = [NSLayoutConstraint
                                                                     constraintWithItem:self.expandedView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                     attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0f
                                                                     constant:0.0f ];
            [self addConstraint:expandedViewLeadingLayoutConstraint];
            [self addConstraint:self.expandedViewCenterYLayoutConstraint];
        }
        if (_expandedLocation & QZXAssistiveControlExpandedLocationAgainstCollapsed)
        {
            if ((containerBounds.size.width - _collapsedViewLastPosition.x) < destFrame.size.width)
            {
                //expandedView NSLayoutAttributeTrailing LayoutConstraint
                NSLayoutConstraint * expandedViewTrailingLayoutConstraint = [NSLayoutConstraint
                                                                             constraintWithItem:self.expandedView
                                                                             attribute:NSLayoutAttributeTrailing
                                                                             relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                             attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1.0f
                                                                             constant: 0.0f ];
                [self addConstraint:expandedViewTrailingLayoutConstraint];
                //expandedView NSLayoutAttributeCenterY LayoutConstraint
                
                [self addConstraint:self.expandedViewCenterYLayoutConstraint];
            }
            else
            {
                [self addConstraint:self.expandedViewCenterXLayoutConstraint];
                [self addConstraint:self.expandedViewCenterYLayoutConstraint];
            }
            
        }
    }
    

}

- (void)showCollapsedView
{
    [_expandedView removeFromSuperview];
    
    CGRect destFrame = _collapsedView.frame;
    destFrame.origin = _collapsedViewLastPosition;
    
    self.frame = destFrame;
    _collapsedView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    [self setNeedsLayout];
    self.WidthLayoutConstraint.constant = self.collapsedView.bounds.size.width;
    self.HeightLayoutConstraint.constant = self.collapsedView.bounds.size.height;
    self.WidthLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    self.HeightLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    [self changeAssistiveControlConstraintPriority];
    [self layoutIfNeeded];
    [self addConstraintToCollapsedView];
    

    
    [self adjustControlPositionForStickyEdgeWithCompletion:nil];
    
    _currentState = QZXAssistiveControlStateCollapsed;
}

- (void)addConstraintToCollapsedView
{
    _collapsedView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_collapsedView];
    
    //collapsedView NSLayoutAttributeWidth LayoutConstraint
    NSLayoutConstraint * collapsedViewWidthLayoutConstraint = [NSLayoutConstraint
                                                               constraintWithItem:self.collapsedView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:0.0f
                                                               constant:self.bounds.size.width];
    [self addConstraint:collapsedViewWidthLayoutConstraint];
    //collapsedView NSLayoutAttributeHeight LayoutConstraint
    NSLayoutConstraint * collapsedViewHeightLayoutConstraint = [NSLayoutConstraint
                                                                constraintWithItem:self.collapsedView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:0.0f
                                                                constant:self.bounds.size.height];
    [self addConstraint:collapsedViewHeightLayoutConstraint];
    //collapsedView NSLayoutAttributeCenterY LayoutConstraint
    NSLayoutConstraint * collapsedViewCenterYLayoutConstraint = [NSLayoutConstraint
                                                                 constraintWithItem:self.collapsedView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 multiplier: 1.0f
                                                                 constant:0.0f];
    [self addConstraint:collapsedViewCenterYLayoutConstraint];
    //collapsedView NSLayoutAttributeCenterX LayoutConstraint
    NSLayoutConstraint * collapsedViewCenterXLayoutConstraint = [NSLayoutConstraint
                                                                 constraintWithItem:self.collapsedView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0f
                                                                 constant:0.0f];
    [self addConstraint:collapsedViewCenterXLayoutConstraint];
}


+ (QZXAssistiveControl *)addSuperView:(UIView *) superView withCollapsedView:(UIView *) collapsedView andExpandedView:(UIView *) expandedView
{

    QZXAssistiveControl * assistiveControl = [[QZXAssistiveControl alloc]initWithFrame:collapsedView.frame];
    [superView addSubview:assistiveControl];

    
    assistiveControl.translatesAutoresizingMaskIntoConstraints = NO;

    
    //setting constraints
    //collapsedView NSLayoutAttributeWidth LayoutConstraint
    assistiveControl.WidthLayoutConstraint = [NSLayoutConstraint
                                                           constraintWithItem:assistiveControl
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:0.0f
                                                           constant:collapsedView.bounds.size.width];
    assistiveControl.WidthLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    [superView addConstraint:assistiveControl.WidthLayoutConstraint];
    //collapsedView NSLayoutAttributeHeight LayoutConstraint
    assistiveControl.HeightLayoutConstraint = [NSLayoutConstraint
                                                            constraintWithItem:assistiveControl
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                            constant:collapsedView.bounds.size.height];
    assistiveControl.HeightLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    [superView addConstraint:assistiveControl.HeightLayoutConstraint];
    //collapsedView NSLayoutAttributeCenterY LayoutConstraint
    assistiveControl.centerYLayoutConstraint = [NSLayoutConstraint
                                              constraintWithItem:assistiveControl
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:superView
                                              attribute:NSLayoutAttributeCenterY
                                              multiplier:(collapsedView.frame.origin.y + collapsedView.bounds.size.height / 2.0f) / (superView.bounds.size.height / 2.0f)
                                              constant:0.0f];
    assistiveControl.centerYLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    [superView addConstraint:assistiveControl.centerYLayoutConstraint];
    //collapsedView NSLayoutAttributeCenterX LayoutConstraint
    assistiveControl.centerXLayoutConstraint = [NSLayoutConstraint
                                              constraintWithItem:assistiveControl
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                              toItem:superView
                                              attribute:NSLayoutAttributeCenterX
                                              multiplier:(collapsedView.frame.origin.x + collapsedView.bounds.size.width / 2.0f) / (superView.bounds.size.width / 2.0f)
                                              constant:0.0f];
    assistiveControl.centerXLayoutConstraint.priority = UILayoutPriorityDefaultLow;
    [superView addConstraint:assistiveControl.centerXLayoutConstraint];
    
    //collapsedView NSLayoutAttributeTop LayoutConstraint
    assistiveControl.topLayoutConstraint = [NSLayoutConstraint
                                                             constraintWithItem:assistiveControl
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                             toItem:superView
                                                             attribute:NSLayoutAttributeTop
                                                             multiplier:1.0f
                                                             constant:0.0f ];
    assistiveControl.topLayoutConstraint.priority = UILayoutPriorityDefaultLow;
    [superView addConstraint:assistiveControl.topLayoutConstraint];
    //collapsedView NSLayoutAttributeLeading LayoutConstraint
    assistiveControl.leadingLayoutConstraint = [NSLayoutConstraint
                                                             constraintWithItem:assistiveControl
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                             toItem:superView
                                                             attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0f
                                                             constant:0.0f ];
    assistiveControl.leadingLayoutConstraint.priority = UILayoutPriorityDefaultHigh;
    [superView addConstraint:assistiveControl.leadingLayoutConstraint];
    
    //collapsedView NSLayoutAttributeTrailing LayoutConstraint
    assistiveControl.trailingLayoutConstraint = [NSLayoutConstraint
                                            constraintWithItem:assistiveControl
                                            attribute:NSLayoutAttributeTrailing
                                            relatedBy:NSLayoutRelationEqual
                                            toItem:superView
                                            attribute:NSLayoutAttributeTrailing
                                            multiplier:1.0f
                                            constant: 0.0f ];
    assistiveControl.trailingLayoutConstraint.priority = UILayoutPriorityDefaultLow;
    [superView addConstraint:assistiveControl.trailingLayoutConstraint];
    //collapsedView NSLayoutAttributeBottom LayoutConstraint
    assistiveControl.bottomLayoutConstraint = [NSLayoutConstraint
                                             constraintWithItem:assistiveControl
                                             attribute:NSLayoutAttributeBottom
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:superView
                                             attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                             constant:0.0f ];
    assistiveControl.bottomLayoutConstraint.priority = UILayoutPriorityDefaultLow;
    [superView addConstraint:assistiveControl.bottomLayoutConstraint];


    

    assistiveControl.collapsedView = collapsedView;
    [assistiveControl addConstraintToCollapsedView];
    assistiveControl.expandedView  = expandedView;
    
    
    collapsedView.translatesAutoresizingMaskIntoConstraints = NO;
    expandedView.translatesAutoresizingMaskIntoConstraints  = NO;
    
    return assistiveControl;
}
+ (QZXAssistiveControl *)addWindowWithCollapsedView:(UIView *) collapsedView andExpandedView:(UIView *) expandedView
{
    UIView * windowView = [[[UIApplication sharedApplication] delegate] window];

    return [self addSuperView:windowView withCollapsedView:collapsedView andExpandedView:expandedView];
}

@end
