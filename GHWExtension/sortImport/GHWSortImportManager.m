//
//  GHWSortImportManager.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019 黑化肥发灰. All rights reserved.
//

#import "GHWSortImportManager.h"
#import "GHWExtensionConst.h"

@interface GHWSortImportManager ()

@property (nonatomic, strong) NSString *classNameImportStr;

@property (nonatomic, strong) NSMutableArray *controllerArray;
@property (nonatomic, strong) NSMutableArray *viewsArray;
@property (nonatomic, strong) NSMutableArray *managerArray;
@property (nonatomic, strong) NSMutableArray *thirdLibArray;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) NSMutableArray *otherArray;
@property (nonatomic, strong) NSMutableIndexSet *indexSet;

@property (nonatomic, assign) BOOL hasSelectedImportLines;
@end

@implementation GHWSortImportManager

+ (GHWSortImportManager *)sharedInstane {
    static dispatch_once_t predicate;
    static GHWSortImportManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWSortImportManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    NSLog(@"sortImport");
    self.classNameImportStr = nil;
    [self.controllerArray removeAllObjects];
    [self.viewsArray removeAllObjects];
    [self.managerArray removeAllObjects];
    [self.thirdLibArray removeAllObjects];
    [self.modelArray removeAllObjects];
    [self.categoryArray removeAllObjects];
    [self.otherArray removeAllObjects];
    [self.indexSet removeAllIndexes];
    
    NSInteger endIndex = 0;
    NSInteger startIndex = 0;
    if ([invocation.buffer.selections count] == 0) {
        startIndex = [self indexOfFirstInsertLineOfArray:invocation.buffer.lines];
        endIndex = [invocation.buffer.lines count] - 1;
        self.hasSelectedImportLines = NO;
    } else {
        XCSourceTextRange *selectRange = invocation.buffer.selections[0];
        startIndex = selectRange.start.line;
        endIndex = selectRange.end.line;
        
        if (startIndex == endIndex) {
            startIndex = [self indexOfFirstInsertLineOfArray:invocation.buffer.lines];
            endIndex = [invocation.buffer.lines count] - 1;
            self.hasSelectedImportLines = NO;

        } else {
            self.hasSelectedImportLines = YES;
        }
        
    }
    
    NSInteger importStartIndex = startIndex < [self indexOfFirstInsertLineOfArray:invocation.buffer.lines] + 1 ? [self indexOfFirstInsertLineOfArray:invocation.buffer.lines] + 1 : startIndex;
    NSString *classNameStr = [[invocation.buffer.lines fetchClassName] lowercaseString];
    for (NSInteger i = startIndex; i <= endIndex; i++) {
        NSString *contentStr = [[invocation.buffer.lines[i] deleteSpaceAndNewLine] lowercaseString];
        if (![contentStr hasPrefix:@"#import"]) {
            if ([contentStr length] == 0 && self.hasSelectedImportLines) {
                [self.indexSet addIndex:i];
            }
            continue;
        }
        
        if ([contentStr checkHasContainsOneOfStrs:@[[NSString stringWithFormat:@"%@.h", classNameStr]]
                          andNotContainsOneOfStrs:@[@"+"]]) {
            self.classNameImportStr = invocation.buffer.lines[i];
        } else if ([contentStr checkHasContainsOneOfStrs:@[@"view.h\"", @"bar.h\"", @"cell.h\""]
                                 andNotContainsOneOfStrs:@[@"+"]]) {
            [self.viewsArray addObject:invocation.buffer.lines[i]];
        } else if ([contentStr checkHasContainsOneOfStrs:@[@"manager.h\"", @"logic.h\"", @"helper.h\"", @"services.h\"", @"service.h\""]
                                 andNotContainsOneOfStrs:@[@"+"]]) {
            [self.managerArray addObject:invocation.buffer.lines[i]];
        } else if ([contentStr checkHasContainsOneOfStrs:@[@"controller.h\"", @"VC.h\"", @"Vc.h\"", @"vc.h\""]
                                 andNotContainsOneOfStrs:@[@"+"]]) {
            [self.controllerArray addObject:invocation.buffer.lines[i]];
        } else if ([contentStr checkHasContainsOneOfStrs:@[@".h>"]
                                 andNotContainsOneOfStrs:@[]]) {
            [self.thirdLibArray addObject:invocation.buffer.lines[i]];
        } else if ([contentStr checkHasContainsOneOfStrs:@[@"model.h\"", @"models.h\""]
                                 andNotContainsOneOfStrs:@[@"+"]]) {
            [self.modelArray addObject:invocation.buffer.lines[i]];
        } else if ([contentStr containsString:@"+"]) {
            [self.categoryArray addObject:invocation.buffer.lines[i]];
        } else {
            [self.otherArray addObject:invocation.buffer.lines[i]];
        }
    }
    [invocation.buffer.lines printList];
    [invocation.buffer.lines removeObjectsAtIndexes:self.indexSet];
    
    [invocation.buffer.lines printList];
    [invocation.buffer.lines removeObject:self.classNameImportStr];
    
    [invocation.buffer.lines removeObjectsInArray:self.controllerArray];
    [invocation.buffer.lines printList];
    
    
    [invocation.buffer.lines removeObjectsInArray:self.viewsArray];
    [invocation.buffer.lines printList];
    
    [invocation.buffer.lines removeObjectsInArray:self.managerArray];
    [invocation.buffer.lines printList];
    
    [invocation.buffer.lines removeObjectsInArray:self.modelArray];
    [invocation.buffer.lines printList];
    
    [invocation.buffer.lines removeObjectsInArray:self.categoryArray];
    [invocation.buffer.lines printList];
    
    [invocation.buffer.lines removeObjectsInArray:self.thirdLibArray];
    [invocation.buffer.lines printList];
    
    [invocation.buffer.lines removeObjectsInArray:self.otherArray];
    
    if ([self.classNameImportStr length]) {
        NSMutableArray *mArr = [NSMutableArray arrayWithObject:self.classNameImportStr];
        [mArr addObject:@"\n"];
        [invocation.buffer.lines insertItemsOfArray:mArr fromIndex:importStartIndex];
        importStartIndex = importStartIndex + [mArr count];
        [invocation.buffer.lines printList];
    }
    
    if ([self.controllerArray count]) {
        self.controllerArray = [self.controllerArray arrayWithNoSameItem];
        [self.controllerArray addObject:@"\n"];
        [invocation.buffer.lines insertItemsOfArray:self.controllerArray fromIndex:importStartIndex];
        importStartIndex = importStartIndex + [self.controllerArray count];
        [invocation.buffer.lines printList];
    }
    
    if ([self.viewsArray count]) {
        self.viewsArray = [self.viewsArray arrayWithNoSameItem];
        [self.viewsArray addObject:@"\n"];
        [invocation.buffer.lines insertItemsOfArray:self.viewsArray fromIndex:importStartIndex];
        importStartIndex = importStartIndex + [self.viewsArray count];
        [invocation.buffer.lines printList];
    }
    if ([self.managerArray count]) {
        self.managerArray = [self.managerArray arrayWithNoSameItem];
        [self.managerArray addObject:@"\n"];
        [invocation.buffer.lines insertItemsOfArray:self.managerArray fromIndex:importStartIndex];
        importStartIndex = importStartIndex + [self.managerArray count];
        [invocation.buffer.lines printList];
    }
    
    if ([self.modelArray count]) {
        self.modelArray = [self.modelArray arrayWithNoSameItem];
        [self.modelArray addObject:@"\n"];
        [invocation.buffer.lines insertItemsOfArray:self.modelArray fromIndex:importStartIndex];
        importStartIndex = importStartIndex + [self.modelArray count];
        [invocation.buffer.lines printList];
    }
    if ([self.categoryArray count]) {
        self.categoryArray = [self.categoryArray arrayWithNoSameItem];
        [self.categoryArray addObject:@"\n"];
        [invocation.buffer.lines insertItemsOfArray:self.categoryArray fromIndex:importStartIndex];
        importStartIndex = importStartIndex + [self.categoryArray count];
        [invocation.buffer.lines printList];
    }
    if ([self.thirdLibArray count]) {
        self.thirdLibArray = [self.thirdLibArray arrayWithNoSameItem];
        [self.thirdLibArray addObject:@"\n"];
        [invocation.buffer.lines insertItemsOfArray:self.thirdLibArray fromIndex:importStartIndex];
        importStartIndex = importStartIndex + [self.thirdLibArray count];
        [invocation.buffer.lines printList];
    }
    if ([self.otherArray count]) {
        self.otherArray = [self.otherArray arrayWithNoSameItem];
        [self.otherArray addObject:@"\n"];
        [invocation.buffer.lines insertItemsOfArray:self.otherArray fromIndex:importStartIndex];
        importStartIndex = importStartIndex + [self.otherArray count];
        [invocation.buffer.lines printList];
    }
    
    NSMutableIndexSet *spaceDeleteSet = [[NSMutableIndexSet alloc] init];
    for (NSInteger i = importStartIndex; i < [invocation.buffer.lines count]; i++) {
        if ([[invocation.buffer.lines[i] deleteSpaceAndNewLine] length] == 0) {
            [spaceDeleteSet addIndex:i];
            [invocation.buffer.lines printList];
        } else {
            break;
        }
    }
    
    [invocation.buffer.lines removeObjectsAtIndexes:spaceDeleteSet];
    
    // 还需要把本类的import往前面挪动
}

- (NSInteger)indexOfFirstInsertLineOfArray:(NSMutableArray *)mArray {
    NSInteger commentLastIndex = -1;
    for (int i = 0; i < [mArray count]; i++) {
        NSString *contentStr = [[mArray[i] deleteSpaceAndNewLine] lowercaseString];
        if ([contentStr hasPrefix:@"//"] || [contentStr length] == 0) {
            if ([contentStr hasPrefix:@"//"]) {
                commentLastIndex = i;
            }
            continue;
        }
        break;
    }
    if (commentLastIndex == -1) {
        return 0;
    } else {
        return commentLastIndex + 1;
    }
}

- (NSMutableArray *)controllerArray {
    if (!_controllerArray) {
        _controllerArray = [[NSMutableArray alloc] init];
    }
    return _controllerArray;
}

- (NSMutableArray *)viewsArray {
    if (!_viewsArray) {
        _viewsArray = [[NSMutableArray alloc] init];
    }
    return _viewsArray;
}

- (NSMutableArray *)managerArray {
    if (!_managerArray) {
        _managerArray = [[NSMutableArray alloc] init];
    }
    return _managerArray;
}

- (NSMutableArray *)thirdLibArray {
    if (!_thirdLibArray) {
        _thirdLibArray = [[NSMutableArray alloc] init];
    }
    return _thirdLibArray;
}

- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [[NSMutableArray alloc] init];
    }
    return _modelArray;
}

- (NSMutableArray *)categoryArray {
    if (!_categoryArray) {
        _categoryArray = [[NSMutableArray alloc] init];
    }
    return _categoryArray;
}

- (NSMutableArray *)otherArray {
    if (!_otherArray) {
        _otherArray = [[NSMutableArray alloc] init];
    }
    return _otherArray;
}

- (NSMutableIndexSet *)indexSet{
    if (!_indexSet) {
        _indexSet = [[NSMutableIndexSet alloc] init];
    }
    return _indexSet;
}


@end

