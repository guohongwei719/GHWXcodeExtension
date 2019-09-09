//
//  GHWExtensionConst.h
//
//
//  Created by 黑化肥发灰 on 2019/8/30.
//  Copyright © 2019年 黑化肥发灰. All rights reserved.
//

#import "NSString+Extension.h"
#import "NSMutableArray+GHWExtension.h"


/*************************************************************************/

static NSString *const kUIButton =  @"UIButton";
static NSString *const kUILabel =  @"UILabel";
static NSString *const kUIScrollView =  @"UIScrollView";
static NSString *const kUITableView =  @"UITableView";
static NSString *const kUICollectionView =  @"UICollectionView";
static NSString *const kUIImageView =  @"UIImageView";
static NSString *const kImplementation = @"@implementation";
static NSString *const kInterface = @"@interface";
static NSString *const kEnd = @"@end";
static NSString *const kGetterSetterPragmaMark = @"#pragma mark - Setter / Getter";


/*******************************  addComment  ******************************************/
static NSString * const kAddCommentExtensionCode = @"/**\n *\n *\n *\n *\n *\n *\n *\n *\n */";
static NSString * const kAddCommentHeaderExtensionCode = @"/**\n *  Description\n *";
static NSString * const kAddCommentFooterExtensionCode = @" *\n *  @return return value description\n */";
static NSString * const kAddCommentFooterNoParamsExtensionCode = @" *  @return return value description\n */";

/******************************* initView ******************************************/
static NSString * const kInitViewExtensionCode = @"@interface %@ ()\n\n\n\n@end\n";
static NSString * const kInitViewLifeCycleCode = @"\n- (instancetype)initWithFrame:(CGRect)frame {\n    self = [super initWithFrame:frame];\n    if (self) {\n        [self configViews];\n    }\n    return self;\n}\n\n- (void)configViews {\n\n}\n\n#pragma mark - Public Methods\n\n#pragma mark - Private Methods\n\n#pragma mark - Setter / Getter";

static NSString * const kInitTableViewCellLifeCycleCode = @"\n- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {\n    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];\n    if (self) {\n        [self configViews];\n    }\n    return self;\n}\n\n- (void)configViews {\n    self.selectionStyle = UITableViewCellSelectionStyleNone;\n}\n\n- (void)configWithData {\n\n\n}";

static NSString * const kInitViewControllerLifeCycleCode = @"\n#pragma mark - Life Cycle\n\n- (void)viewDidLoad {\n    [super viewDidLoad];\n    [self configViews];\n    [self configData];\n}\n\n- (void)viewWillAppear:(BOOL)animated {\n    [super viewWillAppear:animated];\n\n}\n\n#pragma mark - Setup View / Data\n\n- (void)configViews {\n\n}\n\n- (void)configData {\n\n}\n\n#pragma mark - Observer\n\n#pragma mark - Notification\n\n#pragma mark - Event Response\n\n#pragma mark - Override Methods\n\n#pragma mark - Delegate\n\n#pragma mark - Public Methods\n\n#pragma mark - Private Methods\n\n#pragma mark - Setter / Getter\n\n#pragma mark - Network";

/*******************************  addlazyCode  ******************************************/
//自定义内容格式


static NSString * const kAddLazyCodeTableViewDataSourceAndDelegate = @"\n#pragma mark - tableView DataSource\n\n- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {\n    return 5;\n}\n\n- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {\n    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@\"UITableViewCell\"];\n    if (indexPath.row % 2 == 0) {\n        cell.contentView.backgroundColor = [UIColor blueColor];\n     } else {\n        cell.contentView.backgroundColor = [UIColor redColor];\n    }\n    return cell;\n}\n\n#pragma mark - tableView Delegate\n\n- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {\n    return 60;\n}\n\n-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {\n\n}";

static NSString * const kAddLazyCodeUICollectionViewDelegate = @"#pragma mark - UICollectionViewDataSource\n\n- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {\n    return 0;\n}\n\n- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {\n    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@\"UICollectionViewCell\" forIndexPath:indexPath];\n    return cell;\n}\n\n#pragma mark - UICollectionViewDelegate\n\n- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {\n\n}";

static NSString * const kAddLazyCodeUIScrollViewDelegate = @"#pragma mark - UIScrollviewDelegate\n\n- (void)scrollViewDidScroll:(UIScrollView *)scrollView {\n\n\n}";

//static NSString * const kLazyImageViewCode = @"- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] initWithImage:ni”;
//
//static NSString * const kLazyScrollViewCode = @"- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] init];\n        _%@.alwaysBounceVertical = YE";

static NSString *const kLazyCommonCode = @"\n- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] init];\n    }\n    return _%@;\n}";


static NSString * const kLazyImageViewCode = @"- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] initWithImage:nil];\n        _%@.contentMode = UIViewContentModeScaleAspectFill;\n        _%@.clipsToBounds = YES;\n    }\n    return _%@;\n}";

static NSString *const kLazyLabelCode = @"- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] initWithFrame:CGRectZero];\n        _%@.textAlignment = NSTextAlignmentLeft;\n        _%@.textColor = [UIColor blackColor];\n        _%@.font = [UIFont systemFontOfSize:18];\n        _%@.text = @\"test\";\n    }\n    return  _%@;\n}";

static NSString *const kLazyButtonCode = @"- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [%@ buttonWithType:UIButtonTypeCustom];\n        [_%@ setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];\n        _%@.titleLabel.font = [UIFont systemFontOfSize:14];\n        [_%@ setTitle:@\"test\" forState:UIControlStateNormal];\n         [_%@ addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];\n     }\n    return _%@;\n}";

static NSString * const kLazyScrollViewCode = @"- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] init];\n        _%@.alwaysBounceVertical = YES;\n        _%@.backgroundColor = [UIColor lightGrayColor];\n        _%@.delegate = self;\n    }\n    return _%@;\n}\n";

static NSString * const kLazyUITableViewCode = @"- (%@ *)%@ {\n    if (!_%@) {\n        _%@ = [[%@ alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];\n        _%@.delegate = self;\n        _%@.dataSource = self;\n        _%@.backgroundColor = [UIColor whiteColor];\n        _%@.separatorStyle = UITableViewCellSeparatorStyleNone;\n        if (@available(iOS 11.0, *)) {\n            _%@.estimatedRowHeight = 0;\n            _%@.estimatedSectionFooterHeight = 0;\n            _%@.estimatedSectionHeaderHeight = 0;\n            _%@.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;\n        }\n        [_%@ registerClass:[UITableViewCell class] forCellReuseIdentifier:@\"UITableViewCell\"];\n    }\n    return _%@;\n}\n";

static NSString * const kLazyUICollectionViewCode = @"- (%@ *)%@ {\n    if (!_%@) {\n        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];\n        layout.itemSize = CGSizeMake(10, 10);\n        layout.minimumLineSpacing = 0;\n        layout.minimumInteritemSpacing = 0;\n        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;\n\n        _%@ = [[%@ alloc] initWithFrame:CGRectZero collectionViewLayout:layout];\n        _%@.dataSource = self;\n        _%@.delegate = self;\n        [_%@ registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@\"UICollectionViewCell\"];\n    }\n    return _%@;\n}";
