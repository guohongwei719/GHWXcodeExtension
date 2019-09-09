//
//  GHWInitViewManager.h
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019 黑化肥发灰. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface GHWInitViewManager : NSObject

+ (GHWInitViewManager *)sharedInstane;

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
