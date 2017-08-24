//
//  LeZhuoGameUserInfomationActionView.h
//  leZhuoGameSDk
//
//  Created by xiang on 16/5/11.
//  Copyright © 2016年 ZhanxiangQu. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  声明代理
 */
@protocol LeZhuoGameUserInfomationActionOnLeftDelegate ;

@interface LeZhuoGameUserInfomationActionOnLeftView : UIView

@property (weak, nonatomic) IBOutlet UIButton *logoButton;



@property (weak, nonatomic) IBOutlet UIButton *userHeadButton;



@property (weak, nonatomic) IBOutlet UIButton *cancelButton;




@property (weak,nonatomic) id <LeZhuoGameUserInfomationActionOnLeftDelegate> delegate;


@end

@protocol LeZhuoGameUserInfomationActionOnLeftDelegate <NSObject>

@optional

- (void)touchLogo;

- (void)touchUserHead;

- (void)cancelAction;

@end
