
//  GHWAddLazyCodeManager.h
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019年 黑化肥发灰. All rights reserved.


#import <XcodeKit/XcodeKit.h>

@interface GHWAddLazyCodeManager : NSObject

+(GHWAddLazyCodeManager *)sharedInstane;
/**
 自动添加视图布局 && 设置Getter方法 && 自动AddSubView
 @param invocation 获取选中的字符流
 */
- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end
