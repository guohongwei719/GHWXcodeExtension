//
//  GHWInitViewManager.m
//  GHWExtension
//
//  Created by 郭宏伟 on 2019/8/30.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import "GHWInitViewManager.h"

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

    
}


@end
