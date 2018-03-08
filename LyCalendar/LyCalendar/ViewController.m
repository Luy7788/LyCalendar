//
//  ViewController.m
//  LyCalendar
//
//  Created by Lying on 2018/3/8.
//  Copyright © 2018年 Ly. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "LyCalendar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    LyCalendar *calendar = [[LyCalendar alloc]init];
    [self.view addSubview:calendar];
    [calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.width.equalTo(self.view);
        make.height.equalTo(@388);
    }];
} 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
