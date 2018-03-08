//
//  LyCalendar.m
//  LyCalendar
//
//  Created by Lying on 2018/3/8.
//  Copyright © 2018年 Ly. All rights reserved.
//

//模块每个控制区域的高度
#define LS_DIMENS_SECTION_HEIGHT   50
#define LS_DIMENS_MODULE_SCREEN_SPACING 15

#define LS_COLORS_NEW_THEME             RGBCOLORSTR(@"#67d0bd")
#define LS_COLORS_THEME                 RGBCOLORSTR(@"#67d0bd")
#define LS_COLORS_TXT_GRAY_DARK         RGBCOLORSTR(@"777777")
#define LS_COLORS_NEW_GOLD              RGBCOLORSTR(@"#67d0bd")
#define LS_COLORS_TXT_BLACK             RGBCOLORSTR(@"333333")
#define LS_COLORS_TXT_GRAY             RGBCOLORSTR(@"cccccc")


#import "LyCalendar.h"
#import "Masonry.h"
#import "UIColor+Hex.h"
#import "LyCalendarCell.h"

typedef void (^LSActionBlock)(UIButton *btn);
@interface LyCalendar ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSIndexPath *curIndexPath;
    NSInteger curMonth;
    NSInteger curYear;
}

@property (nonatomic , strong) UICollectionView *collectionView;
@property (nonatomic , strong) UIView       *topView; //顶部view
@property (nonatomic , strong) UIView       *weekView;//星期
@property (nonatomic , strong) UILabel      *monthLabel;     //当去月
@property (nonatomic , strong) UIButton     *previousButton; //上个月
@property (nonatomic , strong) UIButton     *nextButton;     //下个月
@property (nonatomic , strong) NSArray      *weekDayArray;   //@[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
@property (nonatomic , strong) NSDate       *date;
@end

NSString *const CalendarCellIdentifier = @"cell";

@implementation LyCalendar

#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self initView];
//    }
//    return self;
//}

-(void)layoutSubviews{
    [_collectionView reloadData];
}

-(void)initView{
    //顶部view
    [self initTopView];
    //日期view
    _weekDayArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    _weekView=[[UIView alloc]init];
    _weekView.backgroundColor = RGBCOLORSTR(@"#F6F6F6");
    [self addSubview:_weekView];
    [_weekView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topView.mas_bottom);
        make.width.equalTo(self);
        make.height.equalTo(@(LS_DIMENS_SECTION_HEIGHT*0.75));
    }];
    
    //日历的view
    [self initCalendarView];
    
    UILabel *lastLabel;
    for (NSUInteger i = 0; i < 7; i++){
        UILabel *weekLb = [[UILabel alloc] init];
        weekLb.text = _weekDayArray[i];
        weekLb.textColor = LS_COLORS_TXT_GRAY_DARK;
        weekLb.font = [UIFont systemFontOfSize:14];
        weekLb.textAlignment = NSTextAlignmentCenter;
        [_weekView addSubview:weekLb];
        if(i==0){
            [weekLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(_collectionView.mas_width).multipliedBy(0.142);
                make.left.equalTo(_weekView.mas_left);
                make.centerY.equalTo(_weekView);
            }];
        }else{
            [weekLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(_collectionView.mas_width).multipliedBy(0.142);
                make.left.equalTo(lastLabel.mas_right);
                make.centerY.equalTo(_weekView);
            }];
        }
        lastLabel = weekLb;
    }
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_weekView.mas_bottom);
        make.width.equalTo(self);
        make.height.equalTo(@(LS_DIMENS_SECTION_HEIGHT*5));
    }];
    [self setDate:[NSDate date]];
}

-(void)initTopView{
    
    _topView = [[UIView alloc]init];
    _topView.backgroundColor = [UIColor blackColor];
    [self addSubview:_topView];
    [self setUserInteractionEnabled:YES];
    [_topView setUserInteractionEnabled:YES];
    
    _previousButton = [self buttonWithTitle:@"上一月"];
    _previousButton.tag = 0;
    [_previousButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_previousButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
    
    _nextButton = [self buttonWithTitle:@"下一月" ];
    _nextButton.tag = 1;
    [_nextButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    _monthLabel = [[UILabel alloc]init];
    _monthLabel.text = @"月份";
    _monthLabel.textColor = LS_COLORS_THEME;
    [_topView addSubview:_monthLabel];
    
    [_topView addSubview:_previousButton];
    [_topView addSubview:_nextButton];
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.width.equalTo(self);
        make.height.equalTo(@(LS_DIMENS_SECTION_HEIGHT));
    }];
    [_previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_topView.mas_left).offset(LS_DIMENS_MODULE_SCREEN_SPACING);
        make.centerY.equalTo(_topView);
        make.height.equalTo(_topView);
    }];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_topView.mas_right).offset(-LS_DIMENS_MODULE_SCREEN_SPACING);
        make.centerY.equalTo(_topView);
        make.height.equalTo(_topView);
    }];
    [_monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_topView);
    }];
}


-(void)initCalendarView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen]bounds].size.width,300) collectionViewLayout:layout];
    [_collectionView registerClass:[LyCalendarCell class] forCellWithReuseIdentifier:CalendarCellIdentifier];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    CGFloat itemWidth = _collectionView.frame.size.width / 7;
    CGFloat itemHeight = _collectionView.frame.size.height / 6;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [_collectionView setCollectionViewLayout:layout animated:YES];
    
    _collectionView.backgroundColor=[UIColor whiteColor];
    [self addSubview:_collectionView];
}


#pragma mark - date
- (void)setDate:(NSDate *)date{
    _date = date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY.MM"];
    
    _monthLabel.text=[formatter stringFromDate:_date];
    
    NSDate *pMonth = [self lastMonth:_date];
    [_previousButton setTitle:[formatter stringFromDate:pMonth] forState:UIControlStateNormal];
    
    NSDate *nMonth = [self nextMonth:_date];
    [_nextButton setTitle:[formatter stringFromDate:nMonth] forState:UIControlStateNormal];
    
    curYear = [self year:_date];
    curMonth = [self month:_date];
    curIndexPath = nil;
    [_collectionView reloadData];
    
    //设置行高
    NSInteger daysInThisMonth = [self totaldaysInMonth:date];
    NSInteger firstWeekday = [self firstWeekdayInThisMonth:date];
    if(daysInThisMonth+firstWeekday>35){
        [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(LS_DIMENS_SECTION_HEIGHT*6));
        }];
    }else{
        [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(LS_DIMENS_SECTION_HEIGHT*5));
        }];
    }
}

#pragma mark - 按键
-(void)buttonAction:(UIButton *)btn{
    if (btn.tag == 0) {
        [UIView transitionWithView:self duration:0.6 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
            [self setDate:[self lastMonth:_date]];
            NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
            NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
            if(daysInThisMonth + firstWeekday>35){
                //超出就是5个星期
                [self mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@388);
                }];
            }
            else{
                //不超出就是4个
                [self mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@338);
                }];
            }
        } completion:nil];
        
    }else if (btn.tag == 1){
        [UIView transitionWithView:self duration:0.6 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
            [self setDate:[self nextMonth:_date]];
            NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
            NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
            if(daysInThisMonth + firstWeekday>35){
                //超出就是5个星期
                [self mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@388);
                }];
            }
            else{
                //不超出就是4个
                [self mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@338);
                }];
            }
        } completion:nil];
    }
}
-(UIButton *)buttonWithTitle:(NSString *)title{
    UIButton * btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTitleColor:LS_COLORS_THEME forState:UIControlStateHighlighted];
    return btn;
}


#pragma mark - collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
    NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
    if(daysInThisMonth+firstWeekday>35)
        return 42;
    else
        return 35;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LyCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CalendarCellIdentifier forIndexPath:indexPath];
    
    NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
    NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
    
    NSInteger day = 0;
    NSInteger i = indexPath.row;
    cell.curDay=NO;
    cell.state=0;
    if (i < firstWeekday) {
        [cell.dateLabel setText:@""];
        
    }else if (i > firstWeekday + daysInThisMonth - 1){
        [cell.dateLabel setText:@""];
    }else{
        day = i - firstWeekday + 1;
        cell.day = day;
        cell.year = curYear;
        cell.month = curMonth;
        cell.date = [NSString stringWithFormat:@"%li-%02zd-%02zd",cell.year,cell.month,cell.day];
        
        [cell.dateLabel setText:[NSString stringWithFormat:@"%li",(long)day]];
        [cell.dateLabel setTextColor:LS_COLORS_TXT_GRAY];
        
        //比今天早的置灰
        int compare = [self compareDate:[self dateStrChangeWithDate:[NSDate date]] withDate:cell.date];
        if (compare == -1) {
            //cell日期 比 date开始日期小
        }else{
            //cell日期 比 date 大
            [cell.dateLabel setTextColor:LS_COLORS_TXT_BLACK];
        }
        
        //画选中的金色圆圈
        if(curIndexPath!=nil&&curIndexPath ==indexPath){
            cell.curDay=YES;
        }else{
            cell.curDay=NO;
        }
        
        //MARK:这里是测试
        if(cell.day==4 && cell.month==3) cell.state = 0;
        if(cell.day==22 && cell.month==3) cell.state = 1;
        if(cell.day==9 && cell.month==3) cell.state = 2;
        if(cell.day==8 && cell.month==3) cell.state = 2;
//        if(cell.day==14 && cell.month==3) cell.state = 3;
    }
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    LyCalendarCell *cell = (LyCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    curIndexPath=indexPath;
    [collectionView reloadData];
}

-(void)reloadCollectionView{
    [self.collectionView reloadData];
}

//比较两个日期
-(int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:date01];
    dt2 = [df dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result) {
            //date02比date01大
        case NSOrderedAscending:
            ci=1;
            break;
            //date02比date01小
        case NSOrderedDescending:
            ci=-1;
            break;
            //date02=date01
        case NSOrderedSame:
            ci=0;
            break;
        default: NSLog(@"erorr dates %@, %@", dt2, dt1);
            break;
    }
    return ci;
}


#pragma mark - date 相关
- (NSInteger)day:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}

- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}

- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

- (NSInteger)totaldaysInThisMonth:(NSDate *)date{
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

- (NSInteger)totaldaysInMonth:(NSDate *)date{
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

- (NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

- (NSDate*)nextMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

//日期类型转字符串
-(NSString *)dateStrChangeWithDate:(NSDate*)inputDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:inputDate];
}
//字符串转日期类型
-(NSDate *)DateChangeWithdateStr:(NSString*)DateStr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *currentDate = [dateFormatter dateFromString:DateStr];
    return currentDate;
}

@end
