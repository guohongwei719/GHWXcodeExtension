//
//  SourceEditorCommand.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/29.
//  Copyright © 2019 黑化肥发灰. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "GHWInitViewManager.h"
#import "GHWAddLazyCodeManager.h"
#import "GHWSortImportManager.h"
#import "GHWAddCommentManager.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation
                   completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    NSString *identifier = invocation.commandIdentifier;
    [invocation.buffer.lines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@", obj);
    }];
    if ([identifier hasPrefix:@"com.jingyao.GHWXcodeExtension.GHWExtension.sortImport"]) {
        [[GHWSortImportManager sharedInstane] processCodeWithInvocation:invocation];
    } else if ([identifier hasPrefix:@"com.jingyao.GHWXcodeExtension.GHWExtension.initView"]) {
        [[GHWInitViewManager sharedInstane] processCodeWithInvocation:invocation];
    } else if ([identifier hasPrefix:@"com.jingyao.GHWXcodeExtension.GHWExtension.addLazyCode"]) {
        [[GHWAddLazyCodeManager sharedInstane] processCodeWithInvocation:invocation];
    }
    completionHandler(nil);
}

@end
