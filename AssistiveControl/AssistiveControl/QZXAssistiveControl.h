//
//  AssistiveControl.h
//  
//
//  Created by xiang on 16/5/18.
//  Copyright © 2016年 ZhanxiangQu. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, QZXAssistiveControlLocation)
{
    QZXAssistiveControlLocationCenter                               = 0,
    QZXAssistiveControlLocationTop                                  = 1 << 1,
    QZXAssistiveControlLocationLeading                              = 1 << 2,
    QZXAssistiveControlLocationBottom                               = 1 << 3,
    QZXAssistiveControlLocationTrailing                             = 1 << 4,
    QZXAssistiveControlExpandedLocationAgainstCollapsed             = 1 << 5
};

typedef NS_ENUM(NSInteger, QZXAssistiveControlState)
{
    QZXAssistiveControlStateCollapsed,
    QZXAssistiveControlStateExpanded
};



@interface QZXAssistiveControl : UIControl

/**
 *  whether to keep to the side
 */
@property (nonatomic) BOOL stickyEdge;

@property (nonatomic) QZXAssistiveControlLocation expandedLocation;
@property (nonatomic, readonly) QZXAssistiveControlState currentState;

@property (nonatomic, strong) UIView *collapsedView;
@property (nonatomic, strong) UIView *expandedView;

/**
 *  show collapsed view
 */
- (void)showCollapsedView;

+ (QZXAssistiveControl *)addSuperView:(UIView *) superView withCollapsedView:(UIView *) collapsedView andExpandedView:(UIView *) expandedView;
+ (QZXAssistiveControl *)addWindowWithCollapsedView:(UIView *) collapsedView andExpandedView:(UIView *) expandedView;


@end
