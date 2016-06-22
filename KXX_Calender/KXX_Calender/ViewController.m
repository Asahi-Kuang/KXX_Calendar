//
//  ViewController.m
//  KXX_Calender
//
//  Created by Qingxu Kuang on 16/6/21.
//  Copyright © 2016年 Asahi Kuang. All rights reserved.
//

#import "ViewController.h"
#import "KXXCalendarViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showCalendar:(UIButton *)sender {
    KXXCalendarViewController *calendar = [KXXCalendarViewController new];
    [self.navigationController pushViewController:calendar animated:YES];
}
@end
