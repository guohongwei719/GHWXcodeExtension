//
//  NSMutableArray+GHWExtension.m
//  GHWExtension
//
//  Created by 郭宏伟 on 2019/8/30.
//  Copyright © 2019 Jingyao. All rights reserved.
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

- (void)insertItemsOfArray:(NSArray *)itemsArray fromIndex:(NSInteger)insertIndex {
    for (int i = 0; i < [itemsArray count]; i++) {
        NSString *str = itemsArray[i];
        [self insertObject:str atIndex:insertIndex];
        insertIndex = insertIndex + 1;
    }
}

- (NSString *)fetchClassName {
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
