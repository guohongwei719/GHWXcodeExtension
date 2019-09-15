//
//  GHWAddImportManager.h
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/9/15.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GHWAddImportManager : NSObject

+ (GHWAddImportManager *)sharedInstane;

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
