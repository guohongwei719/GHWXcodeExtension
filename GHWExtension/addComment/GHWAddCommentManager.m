//
//  GHWAddCommentManager.m
//  GHWExtension
//
//  Created by 郭宏伟 on 2019/9/4.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import "GHWAddCommentManager.h"
#import "GHWExtensionConst.h"

@interface GHWAddCommentManager ()


@end

@implementation GHWAddCommentManager

+ (GHWAddCommentManager *)sharedInstane {
    static dispatch_once_t predicate;
    static GHWAddCommentManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWAddCommentManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    XCSourceTextRange *rang = invocation.buffer.selections[0];
    NSInteger insertIndex = rang.start.line;
    
    for (NSInteger i = insertIndex; i < [invocation.buffer.lines count]; i++) {
        if ([[invocation.buffer.lines[i] deleteSpaceAndNewLine] hasPrefix:@"-"] ||
            [[invocation.buffer.lines[i] deleteSpaceAndNewLine] hasPrefix:@"+"]) {
            insertIndex = i;
            break;
        }
    }
    
    NSMutableString *funcStr = [NSMutableString string];
    for (NSInteger i = insertIndex; i < [invocation.buffer.lines count]; i++) {
        NSString *contentStr = invocation.buffer.lines[i];
        if (![contentStr containsString:@"{"]) {
            [funcStr appendString:contentStr];
        } else {
            NSRange range = [contentStr rangeOfString:@"{"];
            [funcStr appendString:[contentStr substringToIndex:range.location]];
            break;
        }
    }
    
    NSArray *commentHeaderLines = [kAddCommentHeaderExtensionCode componentsSeparatedByString:@"\n"];
    NSArray *commentFooterLines = [kAddCommentFooterExtensionCode componentsSeparatedByString:@"\n"];
    NSArray *commentFooterNoParamsLines = [kAddCommentFooterNoParamsExtensionCode componentsSeparatedByString:@"\n"];
    
    NSArray *commentLines = [funcStr componentsSeparatedByString:@":"];
    
    
    NSMutableArray *mCommentLines = [NSMutableArray arrayWithArray:commentLines];
    [mCommentLines removeObjectAtIndex:0];
    
    NSMutableArray *argsArray = [NSMutableArray array];
    [argsArray addObjectsFromArray:commentHeaderLines];
    for (int i = 0; i < [mCommentLines count]; i++) {
        NSString *tempStr = [self fetchArgumentsWithStr:mCommentLines[i]];
        if (tempStr) {

            [argsArray addObject:[NSString stringWithFormat:@" *  @param %@", tempStr]];
        }
    }
    
    if ([[invocation.buffer.lines[insertIndex] deleteSpaceAndNewLine] containsString:@"(void)"]) {
        [argsArray addObject:@" */"];
    } else {
        if ([argsArray count] > [commentHeaderLines count]) {
            [argsArray addObjectsFromArray:commentFooterLines];
        } else {
            [argsArray addObjectsFromArray:commentFooterNoParamsLines];
        }
    }
    
    [invocation.buffer.lines insertObjects:argsArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertIndex, [argsArray count])]];
}

- (NSString *)fetchArgumentsWithStr:(NSString *)str {
    NSArray *tempArray = [str componentsSeparatedByString:@")"];
    NSString *argStr = nil;
    NSString *tempStr = @"";
    if ([tempArray count] == 2) {
        tempStr = [tempArray[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    NSArray *argArray = [tempStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([argArray count]) {
        argStr = argArray[0];
        if ([argStr containsString:@"{"]) {
            argStr = [argStr stringByReplacingOccurrencesOfString:@"{" withString:@""];
        }
    }
    return argStr;
}

@end
