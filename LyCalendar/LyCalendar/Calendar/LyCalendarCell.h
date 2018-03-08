//
//  LyCalendarCell.h
//  LyCalendar
//
//  Created by Lying on 2018/3/8.
//  Copyright © 2018年 Ly. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LyCalendarCell  : UICollectionViewCell


@property (nonatomic , strong) UILabel *dateLabel;

@property(nonatomic,copy)NSString *date;

@property(nonatomic,assign)NSInteger year;

@property(nonatomic,assign)NSInteger month;

@property(nonatomic,assign)NSInteger day; 
/**
 *  集中显示状态
 */
@property(nonatomic,assign)NSInteger state;
/**
 *  是否选中的当天
 */
@property(nonatomic)BOOL curDay; 

@end
