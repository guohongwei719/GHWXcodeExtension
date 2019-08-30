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

@property(nonatomic,copy)NSMutableArray *lazyArray;

@property(nonatomic,copy)NSMutableArray *containtsArray;

@property(nonatomic,copy)NSMutableArray *subviewsArray;

@property(nonatomic,copy)NSMutableArray *propertyValueArray;
//字符流的行数
@property(nonatomic,assign)NSUInteger lineCount;

@end

@implementation GHWAddLazyCodeManager

- (void)processCodeWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
    for (XCSourceTextRange *rang in invocation.buffer.selections) {
        [self initWithFormaterArray:rang invocation:invocation];
        [self addBufferInsertInvocation:invocation];
    }
}
-(void)initWithFormaterArray:(XCSourceTextRange *)rang invocation:(XCSourceEditorCommandInvocation *)invocation {
    [self.lazyArray removeAllObjects];
//    [self.containtsArray removeAllObjects];
//    [self.propertyValueArray removeAllObjects];
//    [self.subviewsArray removeAllObjects];
    
    NSInteger startLine = rang.start.line;
    NSInteger endLine = rang.end.line;
//    self.lineCount = invocation.buffer.lines.count;
    
    for (NSInteger i = startLine; i <= endLine; i++) {
        NSString *contentStr = invocation.buffer.lines[i];
        
        if ([contentStr isEqualToString:@"\n"] || ![contentStr containsString:@";"]) {
            continue;
        }
        // 获取类名
        NSString *classNameStr = [contentStr fetchClassNameStr];
        // 获取属性名或者变量名
        NSString *propertyNameStr = [contentStr fetchPropertyNameStr];
        NSString *replaceStr = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;\n", classNameStr, propertyNameStr];
        invocation.buffer.lines[i] = replaceStr;
        //懒加载
        NSArray *lazyGetArray = [self getterForClassName:classNameStr andPropertyName:propertyNameStr];
        if (lazyGetArray.count>0) {
            [self.lazyArray addObject:lazyGetArray];
        }
        
        if ([classNameStr isEqualToString:@"UITableView"]) {
            NSArray *formaterArr = [[kAddLazyCodeTableViewDataSourceAndDelegate componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
            NSInteger insertIndex = [invocation.buffer.lines indexOfFirstItemContainStr:@"#pragma mark - Setter / Getter"];
            [invocation.buffer.lines insertItemsOfArray:formaterArr fromIndex:insertIndex - 1];
        }
        
        
        
        
//         //获取布局
//        NSArray *constraintsArr = [self addConstraintsForClassName:classNameStr PropertyName:propertyNameStr];
//        if (constraintsArr.count>0) {
//            [self.containtsArray addObject:constraintsArr];
//        }
//        //获取添加subView
//        NSArray *viewsArr = [self addSubViewForClassName:classNameStr PropertyName:propertyNameStr];
//        if (viewsArr.count>0) {
//            [self.subviewsArray addObject:viewsArr];
//        }
//        //初始化所有属性
//        NSArray *propertyArr = [self propertyInitForClassName:classNameStr PropertyName:propertyNameStr];
//        if (propertyArr.count>0) {
//            [self.propertyValueArray addObject:propertyArr];
//        }
    }
}
//进行判断进行替换
-(void)addBufferInsertInvocation:(XCSourceEditorCommandInvocation *)invocation{
//    for (NSInteger i = 0; i < self.lineCount; i ++) {
//        NSString *lineStr = invocation.buffer.lines[i];
//        if ([self checkCurrentString:lineStr isContainsString:kGetterSetterFormater]) {
//            [self addCheckLineCoutWithCurrentIndex:i formaterArray:self.lazyArray];
//            [self addBufferWithCurrentLineIndex:i formaterArray:self.lazyArray invocation:invocation];
//        }
//    }
    
    NSInteger settterIndex = [invocation.buffer.lines indexOfFirstItemContainStr:@"#pragma mark - Setter / Getter"];
    if (settterIndex == NSNotFound) {
        return;
    }
    settterIndex = settterIndex + 1;
    for (int i = 0; i < [self.lazyArray count]; i++) {
        NSArray *tempArray = [self.lazyArray objectAtIndex:i];
        [invocation.buffer.lines insertItemsOfArray:tempArray fromIndex:settterIndex];
        settterIndex = settterIndex + [tempArray count];
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
-(BOOL)checkCurrentString:(NSString *)lineString isContainsString:(NSString *)isContainsString{
    if ([lineString containsString:isContainsString]){
        return YES;
    }
    return NO;
}
-(void)addCheckLineCoutWithCurrentIndex:(NSInteger)currentIndex formaterArray:(NSMutableArray *)formaterArray{
    for (NSInteger i = currentIndex + 1; i < formaterArray.count + currentIndex + 1; i ++) {
        NSArray *formatArr = [formaterArray objectAtIndex:formaterArray.count - i - 1  + (currentIndex + 1 )];
        self.lineCount += formatArr.count;
    }
}
//懒加载
- (NSArray *)getterForClassName:(NSString *)className andPropertyName:(NSString *)propertyName{
    NSString *str = @"";
    if ([className containsString:kUIButton]){
        str = [NSString stringWithFormat:kASButtonFormater,className,propertyName,propertyName,propertyName,className,
               propertyName,propertyName,propertyName,propertyName,propertyName,propertyName,propertyName];
    }else if ([className containsString:kUILabel]){
        str = [NSString stringWithFormat:kASUILabelFormater,className,propertyName,propertyName,propertyName,className,
               propertyName,propertyName,propertyName,propertyName,propertyName];
    }else if ([className containsString:kCommand]){
        str = [NSString stringWithFormat:kASCommandFormater,propertyName,propertyName,propertyName,propertyName];
    }else{
        str = [NSString stringWithFormat:kASCommonFormater,className,propertyName,propertyName,propertyName,className,propertyName];
    }
    NSArray *formaterArr = [[str componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
    return formaterArr;
}
//获取布局
- (NSArray *)addConstraintsForClassName:(NSString *)className PropertyName:(NSString *)propertyName {
    if ([className containsString:kViewModel]) {
          return [NSMutableArray array];
    }else if ([className containsString:kButton] || [className containsString:kView] ||[className containsString:kLabel] || [className containsString:kUIImageView] || [className containsString:kTextField] || [className containsString:kTextView]) {
        NSString *str = [NSString stringWithFormat:kASMasonryFormater,propertyName];
        NSArray *conArr = [[str componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
        return conArr;
    }
    return [NSMutableArray array];
}
 //获取添加subView
- (NSArray *)addSubViewForClassName:(NSString *)className PropertyName:(NSString *)propertyName {
    if ([className containsString:kViewModel]) {
        return [NSMutableArray array];
    }else if ([className containsString:kButton] || [className containsString:kView] ||[className containsString:kLabel] || [className containsString:kUIImageView] || [className containsString:kTextField] || [className containsString:kTextView]) {
        NSString *str = [NSString stringWithFormat:kASAddsubviewFormater,propertyName];
        NSArray *conArr = [[str componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
        return conArr;
    }
    return [NSMutableArray array];
}
//初始化所有属性
- (NSArray *)propertyInitForClassName:(NSString *)className PropertyName:(NSString *)propertyName {
     NSString *str = @"";
    if ([className containsString:kButton]) {
       str = [NSString stringWithFormat:kUIButtonInitFormater,propertyName,propertyName];
    }else if([className containsString:kLabel]){
        str = [NSString stringWithFormat:kLabelInitFormater,propertyName];
    }else if([className containsString:kUIImageView]){
        str = [NSString stringWithFormat:kUIImageViewInitFormater,propertyName];
    }
    NSArray *conArray = [[str componentsSeparatedByString:@"\n"] arrayByAddingObject:@""];
    return conArray;
}
#pragma mark - Get
-(NSMutableArray *)lazyArray{
    if (_lazyArray == nil) {
        _lazyArray = [[NSMutableArray alloc] init];
    }
    return _lazyArray;
}
-(NSMutableArray *)containtsArray{
    if (_containtsArray == nil) {
        _containtsArray = [[NSMutableArray alloc] init];
    }
    return _containtsArray;
}
-(NSMutableArray *)subviewsArray{
    if (_subviewsArray == nil) {
        _subviewsArray = [[NSMutableArray alloc] init];
    }
    return _subviewsArray;
}
- (NSMutableArray *)propertyValueArray{
    if (_propertyValueArray == nil) {
        _propertyValueArray = [[NSMutableArray alloc] init];
    }
    return _propertyValueArray;
}
+(GHWAddLazyCodeManager *)sharedInstane{
    static dispatch_once_t predicate;
    static GHWAddLazyCodeManager * sharedInstane;
    dispatch_once(&predicate, ^{
        sharedInstane = [[GHWAddLazyCodeManager alloc] init];
    });
    return sharedInstane;
}
@end
