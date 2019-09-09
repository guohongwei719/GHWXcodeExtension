//
//  GHWInitViewManager.m
//  GHWExtension
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019 黑化肥发灰. All rights reserved.
//

#import "GHWInitViewManager.h"
#import "GHWExtensionConst.h"

@interface GHWInitViewManager ()

@property (nonatomic, strong) NSMutableIndexSet *indexSet;

@end

@implementation GHWInitViewManager

+ (GHWInitViewManager *)sharedInstane {
    static dispatch_once_t predicate;
    static GHWInitViewManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWInitViewManager alloc] init];
    });
    return sharedInstane;
}

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    [self.indexSet removeAllIndexes];
    
    // 添加 extension 代码
    NSString *className = [invocation.buffer.lines fetchClassName];
    if ([invocation.buffer.lines indexOfFirstItemContainStr:[NSString stringWithFormat:@"@interface %@ ()", className]] == NSNotFound) {
        NSString *extensionStr = [NSString stringWithFormat:kInitViewExtensionCode, className];
        NSArray *contentArray = [extensionStr componentsSeparatedByString:@"\n"];
        NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation];
        [invocation.buffer.lines insertItemsOfArray:contentArray fromIndex:impIndex];
    }
    
    if ([[className lowercaseString] hasSuffix:@"view"] ||
        [[className lowercaseString] hasSuffix:@"bar"] ||
        [[className lowercaseString] hasSuffix:@"collectioncell"] ||
        [[className lowercaseString] hasSuffix:@"collectionviewcell"]) {
        // 添加 Life Cycle 代码
        if ([invocation.buffer.lines indexOfFirstItemContainStr:@"- (instancetype)initWithFrame"] == NSNotFound) {
            [self deleteCodeWithInvocation:invocation];
            NSInteger lifeCycleIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation];
            if (lifeCycleIndex != NSNotFound) {
                lifeCycleIndex = lifeCycleIndex + 1;
                NSString *lifeCycleStr = kInitViewLifeCycleCode;
                NSArray *lifeCycleContentArray = [lifeCycleStr componentsSeparatedByString:@"\n"];
                [invocation.buffer.lines insertItemsOfArray:lifeCycleContentArray fromIndex:lifeCycleIndex];
            }
        }
    } else if ([[className lowercaseString] hasSuffix:@"tableviewcell"] ||
               [[className lowercaseString] hasSuffix:@"tablecell"]) {
        // 添加 Life Cycle 代码
        if ([invocation.buffer.lines indexOfFirstItemContainStr:@"(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier"] == NSNotFound) {
            [self deleteCodeWithInvocation:invocation];
            NSInteger lifeCycleIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation];
            if (lifeCycleIndex != NSNotFound) {
                lifeCycleIndex = lifeCycleIndex + 1;
                NSString *lifeCycleStr = kInitTableViewCellLifeCycleCode;
                NSArray *lifeCycleContentArray = [lifeCycleStr componentsSeparatedByString:@"\n"];
                [invocation.buffer.lines insertItemsOfArray:lifeCycleContentArray fromIndex:lifeCycleIndex];
            }
        }
    } else if ([[className lowercaseString] hasSuffix:@"controller"] ||
               [className hasSuffix:@"VC"] ||
               [className hasSuffix:@"Vc"]) {
        // 添加 Life Cycle 代码
        if ([invocation.buffer.lines indexOfFirstItemContainStr:kGetterSetterPragmaMark] == NSNotFound) {
            [self deleteCodeWithInvocation:invocation];
            NSInteger lifeCycleIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation];
            if (lifeCycleIndex != NSNotFound) {
                lifeCycleIndex = lifeCycleIndex + 1;
                NSString *lifeCycleStr = kInitViewControllerLifeCycleCode;
                NSArray *lifeCycleContentArray = [lifeCycleStr componentsSeparatedByString:@"\n"];
                [invocation.buffer.lines insertItemsOfArray:lifeCycleContentArray fromIndex:lifeCycleIndex];
            }
        }
    }

}

- (void)deleteCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    NSInteger impIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kImplementation];
    NSInteger endIndex = [invocation.buffer.lines indexOfFirstItemContainStr:kEnd fromIndex:impIndex];
    if (impIndex != NSNotFound && endIndex != NSNotFound) {
        for (NSInteger i = impIndex + 1; i < endIndex - 1; i++) {
            NSString *contentStr = [invocation.buffer.lines[i] deleteSpaceAndNewLine];
            if ([contentStr length]) {
                [self.indexSet addIndex:i];
            }
        }
    }
    if ([self.indexSet count]) {
        [invocation.buffer.lines removeObjectsAtIndexes:self.indexSet];
    }
}


- (NSMutableIndexSet *)indexSet{
    if (!_indexSet) {
        _indexSet = [[NSMutableIndexSet alloc] init];
    }
    return _indexSet;
}

@end
