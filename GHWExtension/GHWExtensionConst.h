//
//  GHWExtensionConst.h
//  ASXcodeSourceExtensioin
//
//  Created by guohongwei on 2019/8/30.
//  Copyright © 2019年 guohongwei. All rights reserved.
//


/*
 * 需要在如下标记下自动插入代码,可以根据业务需求自行更改标记内容。可以插入单个标记也可以插入多个标记同时自动生成代码
 *
 * kGetterFormater     设置属性的懒加载方法标记格式
 * kAddSubviewFormater 设置UI控件添加
 * kMasonryFormater    设置UI控件设置布局
 * kInitFormater       设置UI控件初始化方法
*/
#import "NSString+Extension.h"
#import "NSMutableArray+GHWExtension.h"

static NSString *const kGetterFormater = @"#pragma mark - Getter";
static NSString *const kAddSubviewFormater = @"- (void)addSubviews" ;
static NSString *const kMasonryFormater = @"- (void)addConstraints";
static NSString *const kInitFormater = @"[self bindViewModel]";

/*************************************************************************/

static NSString *const kCommand = @"Command";
static NSString *const kButton =  @"Button";
static NSString *const kUIButton =  @"UIButton";
static NSString *const kUILabel =  @"UILabel";
static NSString *const kView = @"View";
static NSString *const kViewModel = @"ViewModel";
static NSString *const kLabel = @"Label";
static NSString *const kUIImageView = @"UIImageView";
static NSString *const kTextField = @"TextField";
static NSString *const kTextView = @"TextView";


/******************************* initView ******************************************/
static NSString * const kInitViewExtensionCode = @"@interface %@ ()\n\n@end\n";
static NSString * const kInitViewLifeCycleCode = @"\n- (instancetype)initWithFrame:(CGRect)frame {\n    self = [super initWithFrame:frame];\n    if (self) {\n        [self configViews];\n    }\n    return self;\n}\n\n- (void)configViews {\n\n}\n";


/*************************************************************************/
//自定义内容格式
static NSString *const kASButtonFormater = @"- (%@ *)%@{\n    if (_%@ == nil) {\n        _%@ = [[%@ alloc] init];\n        [_%@ setTitle:<#(nullable NSString *)#> forState:UIControlStateNormal];\n        [_%@ setImage:[UIImage imageNamed:<#(nullable NSString *)#>] forState:UIControlStateNormal];\n        [_%@ setTitleColor:<#(nullable UIColor *)#> forState:UIControlStateNormal];\n        _%@.titleLabel.font =  <#UIFONT_IOS_DEFAULT_6#>;\n        _%@.layer.cornerRadius = <#EVO_PIX_5#>;\n        _%@.layer.masksToBounds = YES;\n    }\n    return _%@;\n}";

static NSString *const kASUILabelFormater = @"- (%@ *)%@{\n    if (_%@ == nil) {\n        _%@ = [[%@ alloc] init];\n        _%@.text = <#(nullable NSString *)#>;\n        _%@.font = <#UIFONT_IOS_DEFAULT_6#>;\n        _%@.textColor = <#UICOLOR_SOHU_PHE_G5#>;\n        _%@.textAlignment = <#NSTextAlignmentLeft#>;\n   }\n    return _%@;\n}";

static NSString *const kASMasonryFormater = @"    [self.%@ mas_makeConstraints:^(MASConstraintMaker *make) {\n        make.top.equalTo(self.<#UIView#>).offset(<#EVO_PIX_4#>);\n        make.bottom.equalTo(self.<#UIView#>).offset(<#EVO_PIX_4#>);\n        make.left.equalTo(self.<#UIView#>).offset(<#EVO_PIX_4#>);\n        make.right.equalTo(self.<#UIView#>).offset(<#EVO_PIX_4#>);\n        make.height.mas_equalTo(<#EVO_PIX_4#>);\n        make.width.mas_equalTo(<#EVO_PIX_4#>);\n    }];";

static NSString *const kASCommandFormater = @"-(RACCommand *)%@{  \n   if (!_%@) {\n        @weakify(self);\n         _%@ = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id x) {\n            @strongify(self);\n            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {\n                [subscriber sendNext:x];\n                [subscriber sendCompleted];\n                return nil;\n            }];\n        }];\n    }\n    return _%@;\n}";

static NSString *const kASAddsubviewFormater = @"    [<#UIView#> addSubview:self.%@];";

static NSString *const kASCommonFormater = @"- (%@ *)%@{\n    if (_%@ == nil) {\n        _%@ = [[%@ alloc] init];\n    }\n    return _%@;\n}";

static NSString *const kLabelInitFormater = @"        self.%@.text = <#(nullable NSString *)#>;";

static NSString *const kUIButtonInitFormater = @"        [self.%@ setTitle:<#(nullable NSString *)#> forState:UIControlStateNormal];\n        [self.%@ setImage:[UIImage imageNamed:<#(nullable NSString *)#>] forState:UIControlStateNormal];";

static NSString *const kUIImageViewInitFormater = @"        [self.%@ sd_setImageWithURL:[NSURL URLWithString:<#(nullable NSString *)#>] placeholderImage:[UIImage imageNamed:<#(nullable NSString *)#>]];";

