//
//  ASAutoLayoutViewCode.m
//  ASXcodeSourceExtensioin
//
//  Created by guohongwei on 2019/8/30.
//  Copyright © 2019年 guohongwei. All rights reserved.
//

#import "GHWAddLazyCodeManager.h"
#import "NSString+Extension.h"
#import "GHWExtensionConst.h"

@interface GHWAddLazyCodeManager()

@property (nonatomic, copy) NSMutableArray *lazyArray;
@property (nonatomic, copy) NSMutableArray *delegateMethodsArray;

//字符流的行数
@property(nonatomic, assign) NSUInteger lineCount;

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
            invocation.buffer.lines[i] = [NSString stringWithFormat:@"%@%@", replaceStr, suffixStr];

        } else {
            invocation.buffer.lines[i] = [NSString stringWithFormat:@"%@%@", replaceStr, @";"];
        }
        if (![invocation.buffer.lines[i] containsString:@"*"]) {
            continue;
        }
        
        
        
        //懒加载
        NSArray *lazyGetArray = [self getterForClassName:classNameStr andPropertyName:propertyNameStr];
        if (lazyGetArray.count > 1) {
            __block NSString *firstStr = lazyGetArray[1];
            [lazyGetArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[(NSString *)obj deleteSpaceAndNewLine] hasPrefix:@"-"]) {
                    firstStr = (NSString *)obj;
                }
            }];
            NSInteger firstStrIndex = [invocation.buffer.lines indexOfFirstItemContainStr:firstStr];
            if (firstStrIndex == NSNotFound) {
                [self.lazyArray addObject:lazyGetArray];
                // 协议方法
                NSArray *delegateMethodLinesArray = [self fetchMethodsLinesArrayWithClassName:classNameStr];
                if ([delegateMethodLinesArray count]) {
                    [self.delegateMethodsArray addObject:delegateMethodLinesArray];
                }

            }
        }

        // 在 <>里面加上 UITableViewDelegate 等
        [self addDelegateDeclareWithClassName:classNameStr andInvocation:invocation andStartIndex:startLine];
    }
    [self addAllDelegateMethodList:invocation andStartLine:startLine];
    [self addBufferInsertInvocation:invocation andFromIndex:startLine];

}

- (void)addDelegateDeclareWithClassName:(NSString *)className
                          andInvocation:(XCSourceEditorCommandInvocation *)invocation
                          andStartIndex:(NSInteger)startIndex {
    if ([[self fetchDelegateDeclareStrWithClassName:className] length] == 0) {
        return;
    }
    for (NSInteger i = startIndex; i > 0; i--) {
        NSString *contentStr = invocation.buffer.lines[i];
        if ([contentStr containsString:kInterface] &&
            [contentStr containsString:@"("] &&
            [contentStr containsString:@")"]) {
            
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

- (NSArray *)fetchMethodsLinesArrayWithClassName:(NSString *)classNameStr {
    if ([classNameStr isEqualToString:kUITableView]) {
        NSArray *formaterArr = [[kAddLazyCodeTableViewDataSourceAndDelegate componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
        return formaterArr;
    } else if ([classNameStr isEqualToString:kUICollectionView]) {
        NSArray *formaterArr = [[kAddLazyCodeUICollectionViewDelegate componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
        return formaterArr;
    } else if ([classNameStr isEqualToString:kUIScrollView]) {
        NSArray *formaterArr = [[kAddLazyCodeUIScrollViewDelegate componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
        return formaterArr;
    }
    return nil;
}

//进行判断进行替换
-(void)addBufferInsertInvocation:(XCSourceEditorCommandInvocation *)invocation andFromIndex:(NSInteger)startIndex {
    NSInteger settterIndex = [invocation.buffer.lines indexOfFirstItemContainStr:@"#pragma mark - Setter / Getter" fromIndex:startIndex];
    if (settterIndex == NSNotFound) {
        NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation fromIndex:startIndex];
        settterIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kEnd fromIndex:impIndex];
    } else {
        settterIndex = settterIndex + 1;
    }
    for (int i = 0; i < [self.lazyArray count]; i++) {
        NSArray *tempArray = [self.lazyArray objectAtIndex:i];
        [invocation.buffer.lines insertItemsOfArray:tempArray fromIndex:settterIndex];
        settterIndex = settterIndex + [tempArray count];
    }
}

- (void)addAllDelegateMethodList:(XCSourceEditorCommandInvocation *)invocation andStartLine:(NSInteger)startLine {
    NSInteger insertIndex = [invocation.buffer.lines indexOfFirstItemContainStr:@"#pragma mark - Setter / Getter" fromIndex:startLine];
    if (insertIndex == NSNotFound) {
        NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation fromIndex:startLine];
        insertIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kEnd fromIndex:impIndex];
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
- (NSArray *)getterForClassName:(NSString *)className andPropertyName:(NSString *)propertyName{
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
        str = [NSString stringWithFormat:kASCommonFormater,className,propertyName,propertyName,propertyName,className,propertyName];
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
