# GHWXcodeExtension

## 一. 实现的功能
#### 1. 初始化view、viewController，自动删除无用代码和添加默认代码；

![(image)](https://github.com/guohongwei719/GHWXcodeExtension/blob/master/resources/initView.gif)


#### 2. 为属性自动添加懒加载代码、对应协议声明和协议方法，主要有 UITableView\UICollectionView\UIScrollView；  

![(image)](https://github.com/guohongwei719/GHWXcodeExtension/blob/master/resources/addLazyCode.gif)

#### 3. 给 import 分组排序，从上到下为 viewController、view、manager & logic、第三方库、model、category、其他。
  
![(image)](https://github.com/guohongwei719/GHWXcodeExtension/blob/master/resources/sortImport.gif)

## 二. 使用方法
#### 1. 将项目 clone 下来
#### 2. 编译成功，到 Products 下，选择 GHWXcodeExtension.app 右键，选择 Show in Finder
![](./resources/6.png)

#### 3. 将 GHWXcodeExtension 复制到应用程序下面，双击打开
![](./resources/7.png)
#### 4. 到 系统偏好设置 找到 扩展，选择 Xcode Source Editor，选中 GHWExtension
![](./resources/8.png)
![](./resources/9.png)

#### 5. 打开项目以后，可以在 Xcode 菜单栏，选择 Editor, 可以看到 GHWExtension 出现在最下面
![](./resources/4.png)

#### 6. 选择 GHWExtension，出现可以使用的功能选项，顾名思义
![](./resources/5.png)

## 三. 使用注意事项
#### 1. 使用 addLazyCode 功能的时候，如果添加了代码后想撤销，使用 command + z，这时候 Xcode 可能会 crash，这应该是 Xcode 本身的一个 bug，所以需要注意一下，正常情况下添加以后也不会撤销，如果要撤销手动删除也很方便。希望苹果能尽快修复这个 bug。

## 四. 调试 GHWXcodeExtension
#### 1. 选择 GHWExtension scheme
![](./resources/1.png)

#### 2. 运行，选择 xcode，点击 run
![](./resources/2.png)

#### 3. 选择一个项目
![](./resources/3.png)

