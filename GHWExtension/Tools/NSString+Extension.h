//
//  NSString+Extension.h
//  HJButtonAddExtension
//
//  Created by Sun Wen on 2018/5/17.
//  Copyright © 2018年 Sun Wen. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSString (Extension)


/*
 * 返回中间字符串
 * 如果 leftStr 为 nil , 则返回 rightStr 之前的字符串
 */
- (NSString *)stringBetweenLeftStr:(NSString *)leftStr andRightStr:(NSString *)rightStr;

@end
