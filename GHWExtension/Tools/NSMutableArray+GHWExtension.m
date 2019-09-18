//
//  NSMutableArray+GHWExtension.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019 黑化肥发灰. All rights reserved.
//

#import "NSMutableArray+GHWExtension.h"
#import "NSString+Extension.h"
#import "GHWExtensionConst.h"

@implementation NSMutableArray (GHWExtension)

- (NSInteger)indexOfFirstItemContainStr:(NSString *)str {
    str = [str deleteSpaceAndNewLine];
    NSInteger index = NSNotFound;
    for (int i = 0; i < self.count; i++) {
        NSString *contentStr = [[self objectAtIndex:i] deleteSpaceAndNewLine];
        NSRange range = [contentStr rangeOfString:str];
        if (range.location != NSNotFound) {
            index = i;
            break;
        }
    }
    return index;
}

- (NSInteger)indexOfFirstItemContainStrsArray:(NSArray *)strsArray {
    NSInteger index = NSNotFound;
    for (int i = 0; i < self.count; i++) {
        NSString *contentStr = [[self objectAtIndex:i] deleteSpaceAndNewLine];
        BOOL isOk = YES;
        for (int j = 0; j < [strsArray count]; j++) {
            NSString *tempStr = strsArray[j];
            if (![contentStr containsString:tempStr]) {
                isOk = NO;
            }
        }

        if (isOk) {
            index = i;
            break;
        }
        
    }
    return index;
}

- (NSInteger)indexOfFirstItemContainStr:(NSString *)str fromIndex:(NSInteger)fromIndex {
    str = [str deleteSpaceAndNewLine];
    NSInteger index = NSNotFound;
    for (NSInteger i = fromIndex; i < self.count; i++) {
        NSString *contentStr = [[self objectAtIndex:i] deleteSpaceAndNewLine];
        NSRange range = [contentStr rangeOfString:str];
        if (range.location != NSNotFound) {
            index = i;
            break;
        }
    }
    return index;
}

- (NSInteger)indexOfFirstItemContainStr:(NSString *)str fromIndex:(NSInteger)fromIndex andToIndex:(NSInteger)toIndex {
    str = [str deleteSpaceAndNewLine];
    NSInteger index = NSNotFound;
    for (NSInteger i = fromIndex; i <= toIndex; i++) {
        NSString *contentStr = [[self objectAtIndex:i] deleteSpaceAndNewLine];
        NSRange range = [contentStr rangeOfString:str];
        if (range.location != NSNotFound) {
            index = i;
            break;
        }
    }
    return index;
}

- (void)insertItemsOfArray:(NSArray *)itemsArray fromIndex:(NSInteger)insertIndex {
    for (int i = 0; i < [itemsArray count]; i++) {
        NSString *str = itemsArray[i];
        [self insertObject:str atIndex:insertIndex];
        insertIndex = insertIndex + 1;
    }
}

// 注释里面的类名字
- (NSString *)fetchReferenceClassName {
    NSString *className = nil;
    NSRange range;
    NSString *str0 = [self[1] deleteSpaceAndNewLine];
    if ([str0 hasPrefix:@"//"] && [str0 hasSuffix:@".m"]) {
        if ([str0 containsString:@"+"]) {
            range = [str0 rangeOfString:@"+"];
        } else {
            range = [str0 rangeOfString:@"."];
        }
        className = [str0 substringWithRange:NSMakeRange(2, range.location - 2)];
    }
    return className;
}


// 本文件类名
- (NSString *)fetchClassName {
    NSString *referenceClassName = [self fetchReferenceClassName];
    NSString *className = @"";
    for (int i = 0; i < [self count]; i++) {
        NSString *tempStr = [self[i] deleteSpaceAndNewLine];
        if ([tempStr hasPrefix:kImplementation]) {
            if ([tempStr containsString:@"("]) {
                className = [tempStr stringBetweenLeftStr:kImplementation andRightStr:@"("];
            } else {
                className = [tempStr substringFromIndex:[kImplementation length]];
            }
        } else if ([tempStr hasPrefix:kInterface]) {
            if ([tempStr containsString:@":"]) {
                className = [tempStr stringBetweenLeftStr:kInterface andRightStr:@":"];

            } else if ([tempStr containsString:@"("]) {
                className = [tempStr stringBetweenLeftStr:kInterface andRightStr:@"("];

            }
        }
        if (referenceClassName && [referenceClassName isEqualToString:className]) {
            return referenceClassName;
        }
    }
    return className;
}

- (NSString *)fetchCurrentClassNameWithCurrentIndex:(NSInteger)currentIndex {
    NSString *className = nil;
    for (NSInteger i = currentIndex; i >= 0; i--) {
        NSString *tempStr = [self[i] deleteSpaceAndNewLine];
        if ([tempStr hasPrefix:kImplementation]) {
            if ([tempStr containsString:@"("]) {
                className = [tempStr stringBetweenLeftStr:kImplementation andRightStr:@"("];
            } else {
                className = [tempStr substringFromIndex:[kImplementation length]];
            }
            break;
        } else if ([tempStr hasPrefix:kInterface]) {
            if ([tempStr containsString:@":"]) {
                className = [tempStr stringBetweenLeftStr:kInterface andRightStr:@":"];
                
            } else if ([tempStr containsString:@"("]) {
                className = [tempStr stringBetweenLeftStr:kInterface andRightStr:@"("];
                
            }
            break;
        }
    }
    return className;
}

- (void)deleteItemsFromFirstItemContains:(NSString *)firstStr andLastItemsContainsStr:(NSString *)lastStr {
    NSInteger deleteFirstLine = 0;
    NSInteger deleteLastLine = 0;
    for (int i = 0; i < [self count]; i++) {
        NSString *tempStr = self[i];
        tempStr = [tempStr deleteSpaceAndNewLine];
        if ([tempStr hasPrefix:@"/*"]) {
            deleteFirstLine = i;
        } else if ([tempStr hasPrefix:@"*/"]) {
            deleteLastLine = i;
        }
    }
    if (deleteLastLine != deleteFirstLine) {
        [self removeObjectsInRange:NSMakeRange(deleteFirstLine, deleteLastLine - deleteFirstLine + 1)];
    }
}

- (void)printList {
    for (NSInteger i = 0; i < [self count]; i++) {
        NSLog(@"%@", self[i]);
    }
}

- (NSMutableArray *)arrayWithNoSameItem {
    NSSet *set = [NSSet setWithArray:self];
    return [NSMutableArray arrayWithArray:[set allObjects]];
}

@end
