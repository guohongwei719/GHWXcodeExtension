//
//  GHWSortImportManager.m
//  GHWExtension
//
//  Created by 郭宏伟 on 2019/8/30.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import "GHWSortImportManager.h"

@interface GHWSortImportManager ()

@end

@implementation GHWSortImportManager

+ (GHWSortImportManager *)sharedInstane {
    static dispatch_once_t predicate;
    static GHWSortImportManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWSortImportManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    NSLog(@"sortImport");
}


@end
