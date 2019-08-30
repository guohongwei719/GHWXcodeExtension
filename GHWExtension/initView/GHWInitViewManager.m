//
//  GHWInitViewManager.m
//  GHWExtension
//
//  Created by 郭宏伟 on 2019/8/30.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import "GHWInitViewManager.h"
#import "GHWExtensionConst.h"

@interface GHWInitViewManager ()

@end

@implementation GHWInitViewManager

+ (GHWInitViewManager *)sharedInstane {
    static dispatch_once_t predicate;
    static GHWInitViewManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWInitViewManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    NSLog(@"initView");
    
    // 删除默认代码
    [invocation.buffer.lines deleteItemsFromFirstItemContains:@"/*" andLastItemsContainsStr:@"*/"];
    
    // 添加 extension 代码
    
    NSString *className = [invocation.buffer.lines fetchClassName];
    if ([invocation.buffer.lines indexOfFirstItemContainStr:[NSString stringWithFormat:@"@interface %@ ()", className]] == NSNotFound) {
        NSInteger impIndex = [invocation.buffer.lines indexOfImplementation];
        NSString *extensionStr = [NSString stringWithFormat:kInitViewExtensionCode, className];
        NSArray *contentArray = [extensionStr componentsSeparatedByString:@"\n"];
        [invocation.buffer.lines insertItemsOfArray:contentArray fromIndex:impIndex];
    }
    
    // 添加 Life Cycle 代码
    if ([invocation.buffer.lines indexOfFirstItemContainStr:@"- (instancetype)initWithFrame"] == NSNotFound) {
        NSInteger lifeCycleIndex = [invocation.buffer.lines indexOfFirstItemContainStr:@"@implementation"];
        
        if (lifeCycleIndex != NSNotFound) {
            lifeCycleIndex = lifeCycleIndex + 1;
            NSString *lifeCycleStr = kInitViewLifeCycleCode;
            NSArray *lifeCycleContentArray = [lifeCycleStr componentsSeparatedByString:@"\n"];
            [invocation.buffer.lines insertItemsOfArray:lifeCycleContentArray fromIndex:lifeCycleIndex];
        }
    }
}


@end
