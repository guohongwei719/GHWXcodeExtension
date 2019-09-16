//
//  GHWAddImportManager.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/9/15.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import "GHWAddImportManager.h"
#import "GHWExtensionConst.h"

@implementation GHWAddImportManager

+ (GHWAddImportManager *)sharedInstane {
    static dispatch_once_t predicate;
    static GHWAddImportManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWAddImportManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    if (![invocation.buffer.selections count]) {
        return;
    }
    
    XCSourceTextRange *selectRange = invocation.buffer.selections[0];
    NSInteger startLine = selectRange.start.line;
    NSInteger endLine = selectRange.end.line;
    NSInteger startColumn = selectRange.start.column;
    NSInteger endColumn = selectRange.end.column;
    
    if (startLine != endLine || startColumn == endColumn) {
        return;
    }
    
    NSString *selectLineStr = invocation.buffer.lines[startLine];
    NSString *selectContentStr = [[selectLineStr substringWithRange:NSMakeRange(startColumn, endColumn - startColumn)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([selectContentStr length] == 0) {
        return;
    }
    NSString *insertStr = [NSString stringWithFormat:@"#import \"%@.h\"", selectContentStr];
    
    NSInteger lastImportIndex = -1;
    for (NSInteger i = 0; i < [invocation.buffer.lines count]; i++) {
        NSString *contentStr = [invocation.buffer.lines[i] deleteSpaceAndNewLine];
        if ([contentStr hasPrefix:@"#import"]) {
            lastImportIndex = i;
        }
    }
    
    NSInteger alreadyIndex = [invocation.buffer.lines indexOfFirstItemContainStr:insertStr];
    if (alreadyIndex != NSNotFound) {
        return;
    }
    
    NSInteger insertIndex = 0;
    if (lastImportIndex != -1) {
        insertIndex = lastImportIndex + 1;
    }
    [invocation.buffer.lines insertObject:insertStr atIndex:insertIndex];
}

@end
