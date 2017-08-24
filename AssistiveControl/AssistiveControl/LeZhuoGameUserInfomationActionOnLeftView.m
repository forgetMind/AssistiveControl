//
//  LeZhuoGameUserInfomationActionView.m
//  leZhuoGameSDk
//
//  Created by xiang on 16/5/11.
//  Copyright © 2016年 ZhanxiangQu. All rights reserved.
//

#import "LeZhuoGameUserInfomationActionOnLeftView.h"


@interface LeZhuoGameUserInfomationActionOnLeftView ()

- (IBAction)logoButtonAction:(id)sender;

- (IBAction)userHeadAction:(id)sender;

- (IBAction)cancelAction:(id)sender;

@end



@implementation LeZhuoGameUserInfomationActionOnLeftView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)logoButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(touchLogo)])
    {
        [self.delegate touchLogo];
    }
}
- (IBAction)userHeadAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(touchUserHead)])
    {
        [self.delegate touchUserHead];
    }
}
- (IBAction)cancelAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cancelAction)])
    {
        [self.delegate cancelAction];
    }
}
@end
