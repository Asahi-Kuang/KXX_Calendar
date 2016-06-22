//
//  KXXCalenderCell.m
//  KXX_Calender
//
//  Created by Qingxu Kuang on 16/6/21.
//  Copyright © 2016年 Asahi Kuang. All rights reserved.
//

#import "KXXCalenderCell.h"
#define PINK_TEMP [UIColor colorWithRed:245/255.f green:90/255.f blue:96/255.f alpha:1.f]

static UIColor *originColor;
@interface KXXCalenderCell()
//@property (nonatomic, strong)UIColor *originColor;
@end
@implementation KXXCalenderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self animateSelected];
    }
    else {
        [self animateUnselected];
    }
}

- (void)animateSelected {
    if (![self.dataLabel.textColor isEqual:[UIColor whiteColor]]) {
        originColor = self.dataLabel.textColor;
    }
    [self.dataLabel setBackgroundColor:PINK_TEMP];
    [self.dataLabel.layer setCornerRadius:CGRectGetHeight(self.dataLabel.frame)/2];
    [self.dataLabel.layer setMasksToBounds:YES];
    [self.dataLabel setFont:[UIFont systemFontOfSize:20 weight:17.f]];
    [self.dataLabel setTextColor:[UIColor whiteColor]];
    
    [self.dataLabel setTransform:CGAffineTransformMakeScale(0.f, 0.f)];
    [UIView animateWithDuration:0.3 delay:0.f usingSpringWithDamping:0.7 initialSpringVelocity:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        //
        
        [self.dataLabel setTransform:CGAffineTransformMakeScale(1.f, 1.f)];
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)animateUnselected {
    [self.dataLabel setBackgroundColor:[UIColor whiteColor]];
    [self.dataLabel setFont:[UIFont systemFontOfSize:16.f]];
    [self.dataLabel setTextColor:originColor];
}

@end
