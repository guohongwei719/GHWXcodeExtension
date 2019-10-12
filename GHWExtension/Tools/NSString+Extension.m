//
//  NSString+Extension.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019年 黑化肥发灰. All rights reserved.
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
            NSArray * subArr = [arr.lastObject componentsSeparatedByString:rightStr];
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
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return str;
}

- (NSString *)fetchClassNameStr {
    NSString *tempStr = [self deleteSpaceAndNewLine];
    NSString *classNameStr = nil;
    if ([tempStr containsString:@"*"]) {
        //判断NSMutableArray<NSString *> *testArray 这样的情况来处理
        if ([tempStr containsString:@"NSMutableArray<"]) {
            classNameStr = [tempStr stringBetweenLeftStr:@")" andRightStr:@"*>"];
            classNameStr = [classNameStr stringByAppendingString:@"*>"];
        } else if ([tempStr containsString:@")"]) {
            classNameStr = [tempStr stringBetweenLeftStr:@")" andRightStr:@"*"];
        } else {
            classNameStr = [tempStr stringBetweenLeftStr:nil andRightStr:@"*"];
        }
        return [classNameStr deleteSpaceAndNewLine];
    } else {
        NSString *tempStr0 = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *itemArray = [tempStr0 componentsSeparatedByString:@" "];
        if (![tempStr0 hasPrefix:@"@property"] && [itemArray count] == 2) {
            classNameStr = [itemArray[0] deleteSpaceAndNewLine];
            return classNameStr;
        }
    }
    return classNameStr;
}

- (NSString *)fetchPropertyNameStr {
    NSString *propertyNameStr = nil;

    if ([self containsString:@"*"]) {
        NSString *tempStr = [self deleteSpaceAndNewLine];
        NSString *propertyNameStr = [tempStr stringBetweenLeftStr:@"*" andRightStr:@";"];
        return [propertyNameStr deleteSpaceAndNewLine];
    } else {
        NSString *tempStr0 = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *itemArray = [tempStr0 componentsSeparatedByString:@" "];
        if (![tempStr0 hasPrefix:@"@property"] && [itemArray count] == 2) {
            propertyNameStr = [itemArray[1] deleteSpaceAndNewLine];
            NSRange tempRange = [propertyNameStr rangeOfString:@";"];
            if (tempRange.location != NSNotFound) {
                propertyNameStr = [propertyNameStr substringToIndex:tempRange.location];
            }
            return propertyNameStr;
        }
    }
    return propertyNameStr;
}

- (BOOL)checkHasContainsOneOfStrs:(NSArray *)strArray andNotContainsOneOfStrs:(NSArray *)noHasStrsArray {
    BOOL tag0Success = NO;
    BOOL tag1Success = YES;
    for (NSString *tempStr in strArray) {
        if ([self containsString:tempStr]) {
            tag0Success = YES;
        }
    }
    for (NSString *tempStr in noHasStrsArray) {
        if ([self containsString:tempStr]) {
            tag1Success = NO;
        }
    }
    return tag0Success && tag1Success;
}

@end
