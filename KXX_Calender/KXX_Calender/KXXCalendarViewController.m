//
//  KXXCalendarViewController.m
//  KXX_Calender
//
//  Created by Qingxu Kuang on 16/6/21.
//  Copyright © 2016年 Asahi Kuang. All rights reserved.
//

#import "KXXCalendarViewController.h"
#import "KXXCalenderCell.h"
#import "KXXCalendarTipView.h"

#define kDeviceWidth [[UIScreen mainScreen] bounds].size.width
#define kDeviceHeight [[UIScreen mainScreen] bounds].size.height
#define kValidDateColor [UIColor colorWithRed:135/255.f green:69/255.f blue:33/255.f alpha:1.f]
#define kCalendarHeight 300.f
#define PINK_TEMP [UIColor colorWithRed:245/255.f green:90/255.f blue:96/255.f alpha:1.f]

static NSString *const cellIdentifier = @"cellID";
@interface KXXCalendarViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong)UIView *calendarView;
@property (nonatomic, strong)UIView *headerView;
@property (nonatomic, strong)UICollectionView *calendarCollection;
@property (nonatomic, strong)NSArray *weakDays;
@property (nonatomic, strong)NSDate *dateCurrent;
@property (nonatomic, strong)UILabel *headerDateLabel;
@property (nonatomic, strong)UILabel *resultLabel;
@property (nonatomic, strong)KXXCalendarTipView *tipView;
@end

@implementation KXXCalendarViewController

#pragma mark - lazy loading
- (KXXCalendarTipView *)tipView {
    if (!_tipView) {
        _tipView = [[[NSBundle mainBundle] loadNibNamed:@"KXXCalendarTipView" owner:nil options:nil] firstObject];
    }
    return _tipView;
}

- (UIView *)calendarView {
    if (!_calendarView) {
        _calendarView = [[UIView alloc] initWithFrame:CGRectMake(0.f, (CGRectGetHeight(self.view.frame) - kCalendarHeight) / 2.5, kDeviceWidth, kCalendarHeight + 75)];
        [_calendarView setBackgroundColor:[UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f]];
    }
    return _calendarView;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 64.f, kDeviceWidth,80)];
        [_resultLabel setTextColor:PINK_TEMP];
        [_resultLabel setText:@"您还未选择日期"];
        [_resultLabel setNumberOfLines:0];
        [_resultLabel setFont:[UIFont systemFontOfSize:17.f weight:10.f]];
        [_resultLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _resultLabel;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kDeviceHeight, 48.f)];
        [_headerView setBackgroundColor:PINK_TEMP];
    }
    return _headerView;
}

- (NSArray *)weakDays {
    if (!_weakDays) {
        _weakDays = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    }
    return _weakDays;
}
#pragma mark --

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1.f]];
    [self buildUpElements];
    [self addGesture];
    
    [self setDateCurrent:[NSDate date]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animationForCalendarViewWithScaleX:1.f y:1.f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --

#pragma mark - Methods
- (void)buildUpElements {
    
    [self.view addSubview:self.calendarView];
    [self.calendarView setTransform:CGAffineTransformMakeScale(0.f, 0.f)];
    
    // header view
    // 上个月
    UIButton *preciousMonth = [UIButton buttonWithType:UIButtonTypeCustom];
    [preciousMonth setFrame:CGRectMake(20.f, 10.f, CGRectGetHeight(self.headerView.frame) - 20.f, CGRectGetHeight(self.headerView.frame) - 20.f)];
    [preciousMonth setImage:[UIImage imageNamed:@"precious"] forState:UIControlStateNormal];
    [preciousMonth addTarget:self action:@selector(precious:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:preciousMonth];
    
    // 下个月
    UIButton *nextMonth = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextMonth setFrame:CGRectMake(kDeviceWidth - 40.f, 10.f, CGRectGetHeight(self.headerView.frame) - 20.f, CGRectGetHeight(self.headerView.frame) - 20.f)];
    [nextMonth setImage:[UIImage imageNamed:@"nextMonth"] forState:UIControlStateNormal];
    [nextMonth addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:nextMonth];
    
    // 当前年月日
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, CGRectGetHeight(self.headerView.frame))];
    [dateLabel setCenter:CGPointMake(kDeviceWidth/2, CGRectGetHeight(self.headerView.frame)/2)];
    [dateLabel setTextAlignment:NSTextAlignmentCenter];
    [dateLabel setTextColor:[UIColor whiteColor]];
    [dateLabel setFont:[UIFont systemFontOfSize:20.f weight:5.f]];
    
    NSDate *now = [NSDate date];
    NSString *dateString = [NSString stringWithFormat:@"%ld年%ld月", [self year:now], [self month:now]];
    [dateLabel setText:dateString];
    _headerDateLabel = dateLabel;
    [self.headerView addSubview:_headerDateLabel];
    
    [self.calendarView addSubview:self.headerView];
    
    
    // collection view
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setItemSize:CGSizeMake(kDeviceWidth / 7, (kCalendarHeight - CGRectGetHeight(self.headerView.frame)) / 7)];
    [flow setSectionInset:UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f)];
    [flow setMinimumLineSpacing:0.f];
    [flow setMinimumInteritemSpacing:0.f];
    
    UICollectionView *calendar = [[UICollectionView alloc] initWithFrame:CGRectMake(0.f, CGRectGetHeight(self.headerView.frame), kDeviceWidth, kCalendarHeight - CGRectGetHeight(self.headerView.frame)) collectionViewLayout:flow];
    [calendar setDelegate:self];
    [calendar setDataSource:self];
    [calendar setBackgroundColor:[UIColor whiteColor]];
    [calendar registerNib:[UINib nibWithNibName:@"KXXCalenderCell" bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
    _calendarCollection = calendar;
    [self.calendarView addSubview:_calendarCollection];
    
    //    // 选择日期显示
    //    [self.view addSubview:self.resultLabel];
    
    // 提示说明视图
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(calendar.frame) + 1.5f, kDeviceWidth, 75.f)];
    [tipView setBackgroundColor:[UIColor whiteColor]];
    [tipView addSubview:self.tipView];
    [self.calendarView addSubview:tipView];
}

// 手势翻日历
- (void)addGesture {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipCalendar:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.calendarView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(flipCalendar:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.calendarView addGestureRecognizer:swipeLeft];
    
}

- (void)animationForCalendarViewWithScaleX:(CGFloat)x y:(CGFloat)y {
    [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.6 initialSpringVelocity:20.f options:UIViewAnimationOptionCurveLinear animations:^{
        //
        [self.calendarView setTransform:CGAffineTransformMakeScale(x, y)];
    } completion:^(BOOL finished) {
        //
        // 选择日期显示
        [self.view addSubview:self.resultLabel];
        
    }];
}

- (BOOL)date:(NSDate *)date isEqualToAnotherDate:(NSDate *)dateAnother {
    if (date == nil || dateAnother == nil) return NO;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStrOne = [formatter stringFromDate:date];
    NSString *dateStrTwo = [formatter stringFromDate:dateAnother];
    NSDate   *dateOne    = [formatter dateFromString:dateStrOne];
    NSDate   *dateTwo    = [formatter dateFromString:dateStrTwo];
    if ([dateOne isEqualToDate:dateTwo]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)setDateCurrent:(NSDate *)dateCurrent {
    _dateCurrent = dateCurrent;
    [_headerDateLabel setText:[NSString stringWithFormat:@"%ld年%ld月", [self year:_dateCurrent], [self month:_dateCurrent]]];
    
    [self.calendarCollection reloadData];
}
#pragma mark --

#pragma mark - selectors
- (void)precious:(UIButton *)sender {
    [UIView transitionWithView:self.calendarView duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
        self.dateCurrent = [self lastMonth:self.dateCurrent];
    } completion:nil];
}

- (void)next:(UIButton *)sender {
    [UIView transitionWithView:self.calendarView duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        //
        self.dateCurrent = [self nextMonth:self.dateCurrent];
    } completion:nil];
}

- (void)flipCalendar:(UISwipeGestureRecognizer *)swipe {
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self next:nil];
    }
    else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        [self precious:nil];
    }
}
#pragma mark --

#pragma mark - collection view delegate && data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? [self.weakDays count] : 42;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    KXXCalenderCell *kCell = (KXXCalenderCell *)cell;
    if (indexPath.section == 0) {
        [kCell.dataLabel setBackgroundColor:[UIColor whiteColor]];
        [kCell.dataLabel setTextColor:PINK_TEMP];
        [kCell.dataLabel setText:[self.weakDays objectAtIndex:indexPath.row]];
    }
    else {
        [kCell.dataLabel setBackgroundColor:[UIColor whiteColor]];
        NSInteger totalDaysOfMonth = [self totalDaysInMonthWithDate:_dateCurrent];
        NSInteger firstWeakDay     = [self firstDayWithDate:_dateCurrent];
        NSInteger row              = indexPath.row;
        NSDate    *now              = [NSDate date];
        if (row < firstWeakDay) {
            [kCell.dataLabel setText:@""];
            [kCell setUserInteractionEnabled:NO];
        }
        else if (row > totalDaysOfMonth + firstWeakDay - 1) {
            [kCell.dataLabel setText:@""];
            [kCell setUserInteractionEnabled:NO];
        }
        else {
            //
            [kCell setUserInteractionEnabled:YES];
            NSInteger date = row - firstWeakDay + 1;
            [kCell.dataLabel setText:[NSString stringWithFormat:@"%ld", date]];
            
            if ([_dateCurrent compare:now] == NSOrderedAscending) {
                if (![self date:now isEqualToAnotherDate:_dateCurrent]) {
                    [kCell.dataLabel setTextColor:[UIColor lightGrayColor]];
                    [kCell setUserInteractionEnabled:NO];
                }
                else {
                    if (date < [self day:now]) {
                        [kCell.dataLabel setTextColor:[UIColor lightGrayColor]];
                        [kCell setUserInteractionEnabled:NO];
                    }
                    else {
                        [kCell.dataLabel setTextColor:kValidDateColor];
                        [kCell setUserInteractionEnabled:YES];
                    }
                }
            }
            else {
                [kCell.dataLabel setTextColor:kValidDateColor];
                [kCell setUserInteractionEnabled:YES];
            }
        }
    }
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return NO;
    
    NSInteger totalDaysOfMonth = [self totalDaysInMonthWithDate:_dateCurrent];
    NSInteger firstWeakDay     = [self firstDayWithDate:_dateCurrent];
    NSInteger row              = indexPath.row;
    
    if (row < firstWeakDay || row > totalDaysOfMonth + firstWeakDay - 1) {
        return NO;
    }
    else {
        
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return;
    
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.dateCurrent];
    NSInteger firstWeekday = [self firstDayWithDate:self.dateCurrent];
    
    NSInteger day = 0;
    NSInteger i = indexPath.row;
    day = i - firstWeekday + 1;
    
    NSString *resultString = [NSString stringWithFormat:@"您选择的日期是：%ld年%ld月%ld日", [comp year], [comp month], day];
    [self.resultLabel setText:resultString];
}
#pragma mark --

#pragma mark - calendar calculate
// 获取年
- (NSInteger)year:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date];
    return [components year];
    
}

// 获取月份
- (NSInteger)month:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:date];
    return [components month];
}

// 获取日期
- (NSInteger)day:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
    return [components day];
}

// 获取月份总共天数
- (NSInteger)totalDaysInMonthWithDate:(NSDate *)date {
    NSRange totalDays = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totalDays.length;
}

// 获取月份的第一天是星期几
- (NSInteger)firstDayWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1]; // 1: 日 2: 一 3: 二 ...
    
    NSDateComponents *com = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    [com setDay:1];
    NSDate *firstDayDate = [calendar dateFromComponents:com];
    NSUInteger firstDay = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayDate];
    return firstDay - 1;
}

// 上个月
- (NSDate *)lastMonth:(NSDate *)date {
    NSDateComponents *components = [NSDateComponents new];
    [components setMonth:-1];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
    return newDate;
}

// 下个月
- (NSDate *)nextMonth:(NSDate *)date {
    NSDateComponents *components = [NSDateComponents new];
    [components setMonth:+1];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
    return newDate;
}
#pragma mark --
@end
