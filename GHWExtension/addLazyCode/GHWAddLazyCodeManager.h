
//  ASAutoLayoutViewCode.h
//  ASXcodeSourceExtensioin
//
//  Created by guohongwei on 2019/8/30.
//  Copyright © 2019年 guohongwei. All rights reserved.


#import <XcodeKit/XcodeKit.h>

@interface GHWAddLazyCodeManager : NSObject

+(GHWAddLazyCodeManager *)sharedInstane;
/**
 自动添加视图布局 && 设置Getter方法 && 自动AddSubView
 @param invocation 获取选中的字符流
 */
- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end
