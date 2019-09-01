//
//  NSMutableArray+GHWExtension.h
//  GHWExtension
//
//  Created by 郭宏伟 on 2019/8/30.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (GHWExtension)

- (NSInteger)indexOfFirstItemContainStrsArray:(NSArray *)strsArray;
- (NSInteger)indexOfFirstItemContainStr:(NSString *)str;
- (NSInteger)indexOfFirstItemContainStr:(NSString *)str fromIndex:(NSInteger)fromIndex;
- (NSInteger)indexOfFirstItemContainStr:(NSString *)str fromIndex:(NSInteger)fromIndex andToIndex:(NSInteger)toIndex;
- (void)insertItemsOfArray:(NSArray *)itemsArray fromIndex:(NSInteger)insertIndex;
- (NSString *)fetchClassName;
- (NSString *)fetchCurrentClassNameWithCurrentIndex:(NSInteger)currentIndex;
- (void)deleteItemsFromFirstItemContains:(NSString *)firstStr andLastItemsContainsStr:(NSString *)lastStr;
- (void)printList;
- (NSMutableArray *)arrayWithNoSameItem;

@end

NS_ASSUME_NONNULL_END
