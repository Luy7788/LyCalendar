//
//  LyCalendarCell.m
//  LyCalendar
//
//  Created by Lying on 2018/3/8.
//  Copyright © 2018年 Ly. All rights reserved.
//

#import "LyCalendarCell.h"
#import "UIColor+Hex.h"

@interface LyCalendarCell ()
@property (nonatomic ,strong)UIImageView  *dot ;
@end
@implementation LyCalendarCell

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 5, 32, 32)];
        [_dateLabel setTextAlignment:NSTextAlignmentCenter];
        [_dateLabel setFont:[UIFont systemFontOfSize:14]];
       
        [self addSubview:_dateLabel];
    }
    return _dateLabel;
}

-(void)setCurDay:(BOOL)curDay{
    if(curDay){
    //self.dateLabel.backgroundColor = [UIColor redColor];
    self.dateLabel.layer.cornerRadius = 16;
    self.dateLabel.layer.borderWidth = 1;
    self.dateLabel.layer.borderColor = RGBCOLORSTR(@"#67d0bd").CGColor;
    }
}
 
-(void)setState:(NSInteger)state{
    if(state==1){ 
        if(_dot==nil){
            _dot = [[UIImageView alloc]initWithFrame:CGRectMake(23, 32, 10, 10)];
            _dot.image = [UIImage imageNamed:@"ic_ordertime_dot"];
            [self addSubview:_dot];
        }else{
            [self addSubview:_dot];
        }
    }else if(state==2){
         //没有打开活动的
        self.dateLabel.layer.masksToBounds = YES;
        self.dateLabel.backgroundColor = RGBCOLORSTR(@"eeeeee");  
        self.dateLabel.layer.cornerRadius = 16;
        self.dateLabel.layer.borderWidth = 0;
    }else if(state==3){
        //有标记
        if(_dot==nil){
            _dot = [[UIImageView alloc]initWithFrame:CGRectMake(23, 2, 10, 10)];
            _dot.image = [UIImage imageNamed:@"ic_ordertime_dot"];
            [self addSubview:_dot];
        }else{
            [self addSubview:_dot];
        }
    }else {
        self.dateLabel.layer.cornerRadius = 16;
        self.dateLabel.layer.borderWidth = 0;
        self.dateLabel.backgroundColor = RGBCOLORSTR(@"ffffff");
        if(_dot){
            [_dot removeFromSuperview];
        }
    }
}


@end
