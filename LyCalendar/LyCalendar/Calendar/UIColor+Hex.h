//
//  UIColor+Hex.h
//  kuchun
//
//  Created by Lying on 15/11/28.
//  Copyright © 2015年 Lying. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (Hex)
#define RGBCOLORSTR(rgb)                [UIColor colorWithHexString:rgb]

+ (UIColor *)colorWithHexString:(NSString *)color;
 
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;
 
@end
