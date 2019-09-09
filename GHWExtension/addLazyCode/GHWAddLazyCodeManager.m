//
//  GHWAddLazyCodeManager.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019年 黑化肥发灰. All rights reserved.
//

#import "GHWAddLazyCodeManager.h"
#import "NSString+Extension.h"
#import "GHWExtensionConst.h"

@interface GHWAddLazyCodeManager ()

@property (nonatomic, copy) NSMutableArray *lazyArray;
@property (nonatomic, copy) NSMutableArray *delegateMethodsArray;

@end

@implementation GHWAddLazyCodeManager

+(GHWAddLazyCodeManager *)sharedInstane{
    static dispatch_once_t predicate;
    static GHWAddLazyCodeManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWAddLazyCodeManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    for (XCSourceTextRange *rang in invocation.buffer.selections) {
        [self initWithFormaterArray:rang invocation:invocation];
    }
}
-(void)initWithFormaterArray:(XCSourceTextRange *)selectedTextRange invocation:(XCSourceEditorCommandInvocation *)invocation {
    [self.lazyArray removeAllObjects];
    [self.delegateMethodsArray removeAllObjects];
    NSInteger startLine = selectedTextRange.start.line;
    NSInteger endLine = selectedTextRange.end.line;
    
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSString *contentStr = invocation.buffer.lines[i];
        
        if ([[contentStr deleteSpaceAndNewLine] length] == 0) {
            continue;
        }
        // 获取类名
        NSString *classNameStr = [contentStr fetchClassNameStr];
        // 获取属性名或者变量名
        NSString *propertyNameStr = [contentStr fetchPropertyNameStr];
        if (!classNameStr || !propertyNameStr) {
            continue;
        }

        
        
        // 修改对应属性行, 规范化
        NSString *replaceStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@", classNameStr, propertyNameStr];
        if (![contentStr containsString:@"*"]) {
            replaceStr = [NSString stringWithFormat:@"@property (nonatomic, assign) %@ %@", classNameStr, propertyNameStr];
        }
        NSRange suffixRange = [contentStr rangeOfString:@";"];
        if (suffixRange.location != NSNotFound) {
            NSString *suffixStr = [contentStr substringFromIndex:suffixRange.location];
            [invocation.buffer.lines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@%@", replaceStr, suffixStr]];
        } else {
            [invocation.buffer.lines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@%@", replaceStr, @";"]];
        }
        if (![invocation.buffer.lines[i] containsString:@"*"]) {
            continue;
        }
        
        
        
        //懒加载
        NSArray *lazyGetArray = [self fetchGetterForClassName:classNameStr andPropertyName:propertyNameStr];
        if (lazyGetArray.count > 1) {
            __block NSString *firstStr = lazyGetArray[1];
            [lazyGetArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[(NSString *)obj deleteSpaceAndNewLine] hasPrefix:@"-"]) {
                    firstStr = (NSString *)obj;
                }
            }];
            
            NSString *currentClassName = [invocation.buffer.lines fetchCurrentClassNameWithCurrentIndex:startLine];
            NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStrsArray:@[kImplementation, currentClassName]];
            NSInteger endIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kEnd fromIndex:impIndex];
            NSInteger existIndex = [invocation.buffer.lines indexOfFirstItemContainStr:firstStr fromIndex:impIndex andToIndex:endIndex];
            BOOL alreadyExistLazyMethod = [self alreadyExistsLazyMethodWithClassName:classNameStr andPropertyName:propertyNameStr andInvocation:invocation andStartLine:startLine];
            if (existIndex == NSNotFound && alreadyExistLazyMethod == NO) {
                [self.lazyArray addObject:lazyGetArray];
                // 协议方法
                NSArray *delegateMethodLinesArray = [self fetchMethodsLinesArrayWithClassName:classNameStr andFromIndex:startLine andInvocation:invocation];
                if ([delegateMethodLinesArray count]) {
                    [self.delegateMethodsArray addObject:delegateMethodLinesArray];
                }
            } else {
//                [self fixPropertyWithStartLine:i andEndLine:i andInvocation:invocation];
            }

        }

        // 在 <>里面加上 UITableViewDelegate 等
        [self addDelegateDeclareWithClassName:classNameStr andInvocation:invocation andStartIndex:startLine];
    }
    [self addAllDelegateMethodList:invocation andStartLine:startLine];
    [self addBufferInsertInvocation:invocation andFromIndex:startLine];
    
    // 修改对应属性行, 规范化

//    [self fixPropertyWithStartLine:startLine andEndLine:endLine andInvocation:invocation];
}

// 修改对应属性行, 规范化
- (void)fixPropertyWithStartLine:(NSInteger)startLine
                      andEndLine:(NSInteger)endLine
                   andInvocation:(XCSourceEditorCommandInvocation *)invocation {
    
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSString *contentStr = invocation.buffer.lines[i];
        
        if ([[contentStr deleteSpaceAndNewLine] length] == 0) {
            continue;
        }
        // 获取类名
        NSString *classNameStr = [contentStr fetchClassNameStr];
        // 获取属性名或者变量名
        NSString *propertyNameStr = [contentStr fetchPropertyNameStr];
        if (!classNameStr || !propertyNameStr) {
            continue;
        }
        
        // 修改对应属性行, 规范化
        NSString *replaceStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@", classNameStr, propertyNameStr];
        if (![contentStr containsString:@"*"]) {
            replaceStr = [NSString stringWithFormat:@"@property (nonatomic, assign) %@ %@", classNameStr, propertyNameStr];
        }
        NSRange suffixRange = [contentStr rangeOfString:@";"];
        if (suffixRange.location != NSNotFound) {
            NSString *suffixStr = [contentStr substringFromIndex:suffixRange.location];
            [invocation.buffer.lines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@%@", replaceStr, suffixStr]];
        } else {
            [invocation.buffer.lines replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@%@", replaceStr, @";"]];
        }
        if (![invocation.buffer.lines[i] containsString:@"*"]) {
            continue;
        }
    }
}

- (BOOL)alreadyExistsLazyMethodWithClassName:(NSString *)className
                             andPropertyName:(NSString *)propertyName
                               andInvocation:(XCSourceEditorCommandInvocation *)invocation
                                andStartLine:(NSInteger)startLine{
    NSString *lazyHeadStr = [NSString stringWithFormat:@"-(%@*)%@", className, propertyName];
    NSString *lazyHeadStr1 = [NSString stringWithFormat:@"-(%@*)%@{", className, propertyName];

    NSString *currentClassName = [invocation.buffer.lines fetchCurrentClassNameWithCurrentIndex:startLine];
    NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStrsArray:@[kImplementation, currentClassName]];
    NSInteger endIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kEnd fromIndex:impIndex];
    BOOL existLazyMethod = NO;
    for (NSInteger i = impIndex; i < endIndex; i++) {
        NSString *contentStr = [invocation.buffer.lines[i] deleteSpaceAndNewLine];
        if ([contentStr isEqualToString:lazyHeadStr] || [contentStr isEqualToString:lazyHeadStr1]) {
            existLazyMethod = YES;
        }
    }
    return existLazyMethod;
}

- (void)addDelegateDeclareWithClassName:(NSString *)className
                          andInvocation:(XCSourceEditorCommandInvocation *)invocation
                          andStartIndex:(NSInteger)startIndex {
    if ([[self fetchDelegateDeclareStrWithClassName:className] length] == 0) {
        return;
    }
    for (NSInteger i = startIndex; i > 0; i--) {
        NSString *contentStr = invocation.buffer.lines[i];
        if ([contentStr containsString:kInterface]) {
            NSString *tempStr = [self fetchDelegateDeclareStrWithClassName:className];
            NSString *tempStr0 = @"";
            if ([tempStr containsString:@","]) {
                NSArray *tempArray = [tempStr componentsSeparatedByString:@","];
                tempStr0 = [tempArray[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            } else {
                tempStr0 = tempStr;
            }
            if ([contentStr containsString:tempStr0]) {
                break;
            }
            
            if ([contentStr containsString:@"<"] && [contentStr containsString:@">"]) {
                NSRange tempRange = [contentStr rangeOfString:@"<"];
                NSString *frontStr = [contentStr substringToIndex:tempRange.location];
                NSString *endStr = [contentStr substringFromIndex:tempRange.location + 1];
                invocation.buffer.lines[i] = [NSString stringWithFormat:@"%@<%@, %@", frontStr, [self fetchDelegateDeclareStrWithClassName:className], endStr];
            } else {
                invocation.buffer.lines[i] = [NSString stringWithFormat:@"%@ <%@>", [contentStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], [self fetchDelegateDeclareStrWithClassName:className]];
            }
            
            break;
        }
    }
}

- (NSString *)fetchDelegateDeclareStrWithClassName:(NSString *)classNameStr {
    if ([classNameStr isEqualToString:kUITableView]) {
        return @"UITableViewDelegate, UITableViewDataSource";
    } else if ([classNameStr isEqualToString:kUICollectionView]) {
        return @"UICollectionViewDelegate, UICollectionViewDataSource";
    } else if ([classNameStr isEqualToString:kUIScrollView]) {
        return @"UIScrollViewDelegate";
    }
    return @"";
}

- (NSArray *)fetchMethodsLinesArrayWithClassName:(NSString *)classNameStr andFromIndex:(NSInteger)startLine andInvocation:(XCSourceEditorCommandInvocation *)invocation {
    NSString *currentClassName = [invocation.buffer.lines fetchCurrentClassNameWithCurrentIndex:startLine];
    NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStrsArray:@[kImplementation, currentClassName]];
    NSInteger endIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kEnd fromIndex:impIndex];
    NSString *insertStr = nil;
    NSArray *formaterArr = nil;
    if ([classNameStr isEqualToString:kUITableView]) {
        formaterArr = [[kAddLazyCodeTableViewDataSourceAndDelegate componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
        insertStr = @"- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section";
    } else if ([classNameStr isEqualToString:kUICollectionView]) {
        formaterArr = [[kAddLazyCodeUICollectionViewDelegate componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
        insertStr = @"- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section";
    } else if ([classNameStr isEqualToString:kUIScrollView]) {
        formaterArr = [[kAddLazyCodeUIScrollViewDelegate componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
        insertStr = @"- (void)scrollViewDidScroll:(UIScrollView *)scrollView";
    }
    if (insertStr) {
        NSInteger alreadyIndex = [invocation.buffer.lines indexOfFirstItemContainStr:insertStr fromIndex:impIndex andToIndex:endIndex];
        if (alreadyIndex != NSNotFound) {
            formaterArr = nil;
        }
    }
    
    return formaterArr;
}

//进行判断进行替换
-(void)addBufferInsertInvocation:(XCSourceEditorCommandInvocation *)invocation andFromIndex:(NSInteger)startLine {
    NSString *currentClassName = [invocation.buffer.lines fetchCurrentClassNameWithCurrentIndex:startLine];
    NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStrsArray:@[kImplementation, currentClassName]];
    NSInteger endIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kEnd fromIndex:impIndex];
    NSInteger insertIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kGetterSetterPragmaMark fromIndex:impIndex andToIndex:endIndex];
    if (insertIndex == NSNotFound) {
        insertIndex = endIndex;
    } else {
        insertIndex = insertIndex + 1;
    }
    for (int i = 0; i < [self.lazyArray count]; i++) {
        NSArray *tempArray = [self.lazyArray objectAtIndex:i];
        [invocation.buffer.lines insertItemsOfArray:tempArray fromIndex:insertIndex];
        insertIndex = insertIndex + [tempArray count];
    }
}


-(void)addBufferWithCurrentLineIndex:(NSInteger)currentLineIndex formaterArray:(NSMutableArray *)formaterArray  invocation:(XCSourceEditorCommandInvocation *)invocation {
    //这里的循环主要就是开始 在检测到的下一行开始轮询
    for (NSInteger i = currentLineIndex + 1; i < formaterArray.count + currentLineIndex + 1; i ++) {
        NSArray *formatArr = [formaterArray objectAtIndex:formaterArray.count - i - 1  + (currentLineIndex + 1 )];
        for (int j = 0; j <formatArr.count ; j ++) {
            [invocation.buffer.lines insertObject:formatArr[j] atIndex:currentLineIndex + 1  + j];
        }
    }
}

- (void)addAllDelegateMethodList:(XCSourceEditorCommandInvocation *)invocation andStartLine:(NSInteger)startLine {
    NSString *currentClassName = [invocation.buffer.lines fetchCurrentClassNameWithCurrentIndex:startLine];
    NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStrsArray:@[kImplementation, currentClassName]];
    NSInteger endIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kEnd fromIndex:impIndex];
    NSInteger insertIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kGetterSetterPragmaMark fromIndex:impIndex andToIndex:endIndex];
    if (insertIndex == NSNotFound) {
        insertIndex = endIndex;
    } else {
        insertIndex = insertIndex - 1;
    }
    for (int i = 0; i < [self.delegateMethodsArray count]; i++) {
        NSArray *tempArray = [self.delegateMethodsArray objectAtIndex:i];
        [invocation.buffer.lines insertItemsOfArray:tempArray fromIndex:insertIndex];
        insertIndex = insertIndex + [tempArray count];
    }
}

//懒加载
- (NSArray *)fetchGetterForClassName:(NSString *)className andPropertyName:(NSString *)propertyName{
    NSString *str = @"";
    if ([className containsString:kUIButton]) {
        str = [NSString stringWithFormat:kLazyButtonCode, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName];
    } else if ([className containsString:kUILabel]) {
        str = [NSString stringWithFormat:kLazyLabelCode, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName];
    } else if ([className containsString:kUIScrollView]) {
        str = [NSString stringWithFormat:kLazyScrollViewCode, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName];
    } else if ([className containsString:kUITableView]) {
        str = [NSString stringWithFormat:kLazyUITableViewCode, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName, propertyName];
    } else if ([className containsString:kUICollectionView]) {
        str = [NSString stringWithFormat:kLazyUICollectionViewCode, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName, propertyName];
    }  else if ([className containsString:kUIImageView]) {
        str = [NSString stringWithFormat:kLazyImageViewCode, className, propertyName, propertyName, propertyName, className, propertyName, propertyName, propertyName];
    } else {
        str = [NSString stringWithFormat:kLazyCommonCode,className,propertyName,propertyName,propertyName,className,propertyName];
    }
    NSArray *formaterArr = [[str componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
    return formaterArr;
}
#pragma mark - Get

-(NSMutableArray *)lazyArray{
    if (!_lazyArray) {
        _lazyArray = [[NSMutableArray alloc] init];
    }
    return _lazyArray;
}

-(NSMutableArray *)delegateMethodsArray{
    if (!_delegateMethodsArray) {
        _delegateMethodsArray = [[NSMutableArray alloc] init];
    }
    return _delegateMethodsArray;
}

@end
