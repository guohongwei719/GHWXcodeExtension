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

- (NSInteger)indexOfFirstItemContainStr:(NSString *)str;
- (void)insertItemsOfArray:(NSArray *)itemsArray fromIndex:(NSInteger)insertIndex;
- (NSString *)fetchClassName;
- (NSInteger)indexOfImplementation;
- (void)deleteItemsFromFirstItemContains:(NSString *)firstStr andLastItemsContainsStr:(NSString *)lastStr;
@end

NS_ASSUME_NONNULL_END
