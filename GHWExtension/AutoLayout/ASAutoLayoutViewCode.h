
//  ASAutoLayoutViewCode.h
//  ASXcodeSourceExtensioin
//
//  Created by Sun Wen on 2018/5/17.
//  Copyright © 2018年 Sun Wen. All rights reserved.


#import <XcodeKit/XcodeKit.h>

@interface ASAutoLayoutViewCode : NSObject

+(ASAutoLayoutViewCode *)sharedInstane;
/**
 自动添加视图布局 && 设置Getter方法 && 自动AddSubView
 @param invocation 获取选中的字符流
 */
- (void)addAutoLayoutViewCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end
