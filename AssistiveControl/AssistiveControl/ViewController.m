//
//  ViewController.m
//  testNavigationController
//
//  Created by xiang on 16/5/18.
//  Copyright © 2016年 ZhanxiangQu. All rights reserved.
//

#import "ViewController.h"
#import "QZXAssistiveControl.h"
#import "LeZhuoGameLogoView.h"
#import "LeZhuoGameUserInfomationActionOnLeftView.h"
@interface ViewController ()<LeZhuoGameUserInfomationActionOnLeftDelegate>
/**
 *  logo头像视图,关于头像部分的操作和属性请查看HMYAssistiveControl
 */


@property (strong, nonatomic)  QZXAssistiveControl *assistiveControlView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    LeZhuoGameLogoView * collapsedView = [[[NSBundle mainBundle]loadNibNamed:@"LeZhuoGameLogoView" owner:nil options:nil]lastObject];
    
    LeZhuoGameUserInfomationActionOnLeftView * expandedView = [[[NSBundle mainBundle]loadNibNamed:@"LeZhuoGameUserInfomationActionOnLeftView" owner:nil options:nil]lastObject];
//    expandedView.delegate = self;
//    self.assistiveControlView = [QZXAssistiveControl addSuperView:self.view withCollapsedView:collapsedView andExpandedView:expandedView];
    self.assistiveControlView = [QZXAssistiveControl addWindowWithCollapsedView:collapsedView andExpandedView:expandedView];
    self.assistiveControlView.expandedLocation = QZXAssistiveControlExpandedLocationAgainstCollapsed;
    expandedView.delegate = self;
    self.assistiveControlView.backgroundColor = [UIColor cyanColor];
}


#pragma mark - LeZhuoGameUserInfomationActionOnLeftDelegate

- (void)touchLogo
{
    [self.assistiveControlView showCollapsedView];
    
}

- (void)touchUserHead
{

    self.assistiveControlView.hidden = YES ;
    
}

- (void)cancelAction
{
    self.assistiveControlView.hidden = YES ;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
