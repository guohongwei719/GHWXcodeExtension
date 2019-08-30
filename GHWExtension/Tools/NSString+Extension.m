//
//  NSString+Extension.m
//  HJButtonAddExtension
//
//  Created by guohongwei on 2019/8/30.
//  Copyright © 2019年 guohongwei. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSString *)stringBetweenLeftStr:(NSString *)leftStr andRightStr:(NSString *)rightStr {
    NSString *str = @"";
    NSArray *arr = [NSArray array];
    if (!leftStr) {
        arr = [self componentsSeparatedByString:rightStr];
        if (arr.count > 0) {
            str = arr.firstObject;
        }
    } else {
        arr = [self componentsSeparatedByString:leftStr];
        if (arr.count > 1) {
            NSArray * subArr = [arr[1] componentsSeparatedByString:rightStr];
            if (subArr.count > 0) {
                str = subArr.firstObject;
                if ([str containsString:@"_"]) {
                    str = [str stringByReplacingOccurrencesOfString:@"_" withString:@""];
                }
            }
        }
    }
    return str;
}

@end
