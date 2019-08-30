//
//  GHWSortImportManager.m
//  GHWExtension
//
//  Created by 郭宏伟 on 2019/8/30.
//  Copyright © 2019 Jingyao. All rights reserved.
//

#import "GHWSortImportManager.h"
#import "GHWExtensionConst.h"

@interface GHWSortImportManager ()

@property (nonatomic, strong) NSMutableArray *controllerArray;
@property (nonatomic, strong) NSMutableArray *viewsArray;
@property (nonatomic, strong) NSMutableArray *thirdLibArray;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) NSMutableArray *otherArray;
@property (nonatomic, strong) NSMutableIndexSet *indexSet;

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
    if ([invocation.buffer.selections count] == 0) {
        return;
    }
    XCSourceTextRange *selectRange = invocation.buffer.selections[0];
    NSInteger startIndex = selectRange.start.line;
    NSInteger endIndex = selectRange.end.line;
    
    NSInteger importStartIndex = -1;
    
    for (NSInteger i = startIndex; i <= endIndex; i++) {
        NSString *contentStr = [[invocation.buffer.lines[i] deleteSpaceAndNewLine] lowercaseString];
        if (![contentStr hasPrefix:@"#import"]) {
            if ([contentStr length] == 0) {
                [self.indexSet addIndex:i];
            }
            continue;
        }
        if (importStartIndex == -1) {
            importStartIndex = i;
        }
        if ([contentStr hasSuffix:@"view.h\""]) {
            [self.viewsArray addObject:invocation.buffer.lines[i]];
        } else if ([contentStr hasSuffix:@"controller.h\""]) {
            [self.controllerArray addObject:invocation.buffer.lines[i]];
        } else if ([contentStr hasSuffix:@".h>"]) {
            [self.thirdLibArray addObject:invocation.buffer.lines[i]];
        } else if ([contentStr hasSuffix:@"model.h\""]) {
            [self.modelArray addObject:invocation.buffer.lines[i]];
        } else if ([contentStr containsString:@"+"]) {
            [self.categoryArray addObject:invocation.buffer.lines[i]];
        } else {
            [self.otherArray addObject:invocation.buffer.lines[i]];
        }
    }
    [invocation.buffer.lines printList];
    [invocation.buffer.lines removeObjectsAtIndexes:self.indexSet];
    

    [invocation.buffer.lines removeObjectsInArray:self.controllerArray];
    [invocation.buffer.lines printList];
    

    [invocation.buffer.lines removeObjectsInArray:self.viewsArray];
    [invocation.buffer.lines printList];

    [invocation.buffer.lines removeObjectsInArray:self.modelArray];
    [invocation.buffer.lines printList];

    [invocation.buffer.lines removeObjectsInArray:self.categoryArray];
    [invocation.buffer.lines printList];

    [invocation.buffer.lines removeObjectsInArray:self.thirdLibArray];
    [invocation.buffer.lines printList];

    [invocation.buffer.lines removeObjectsInArray:self.otherArray];

    NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStr:@"@interface"];
    if (importStartIndex > impIndex) {
        importStartIndex = impIndex;
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
