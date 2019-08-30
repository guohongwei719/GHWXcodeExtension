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
    return [str deleteSpaceAndNewLine];
}

- (NSString *)deleteSpaceAndNewLine {
    NSString *str = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return str;
}

- (NSString *)fetchClassNameStr {
    NSString *tempStr = [self deleteSpaceAndNewLine];
    NSString *classNameStr = nil;
    //判断NSMutableArray<NSString *> *testArray 这样的情况来处理
    if ([tempStr containsString:@"NSMutableArray<"]) {
        classNameStr = [tempStr stringBetweenLeftStr:@")" andRightStr:@"*>"];
        classNameStr = [classNameStr stringByAppendingString:@"*>"];
    }else if ([tempStr containsString:@")"]) {
        classNameStr = [tempStr stringBetweenLeftStr:@")" andRightStr:@"*"];
    }else{
        classNameStr = [tempStr stringBetweenLeftStr:nil andRightStr:@"*"];
    }
    return [classNameStr deleteSpaceAndNewLine];
}

- (NSString *)fetchPropertyNameStr {
    NSString *tempStr = [self deleteSpaceAndNewLine];
    NSString *propertyNameStr = [tempStr stringBetweenLeftStr:@"*" andRightStr:@";"];
    return [propertyNameStr deleteSpaceAndNewLine];
}

@end
