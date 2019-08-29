//
//  SourceEditorCommand.m
//  GHWExtension
//
//  Created by 郭宏伟 on 2019/8/29.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "ASAutoLayoutViewCode.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
    NSString *identifier = invocation.commandIdentifier;
    if ([identifier hasPrefix:@"com.jingyao.GHWXcodeExtension.GHWExtension"]) {
        [[ASAutoLayoutViewCode sharedInstane] addAutoLayoutViewCodeWithInvocation:invocation];
    }
    completionHandler(nil);
}

@end
