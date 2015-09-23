//
//  ZLPhotoPickerAssetsViewController.h
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotoPickerCommon.h"
#import "ZLPhotoPickerGroupViewController.h"
#import "ZLPhotoPickerCommon.h"

@class ZLPhotoPickerGroup;

@interface ZLPhotoPickerAssetsViewController : UIViewController

@property (weak,nonatomic) ZLPhotoPickerGroupViewController *groupVc;

@property (nonatomic , assign) PickerViewShowStatus status;
//决定以什么风格显示相册，有原图选择按钮？有多选功能？
@property (nonatomic) XGShowImageType showType;

@property (nonatomic , strong) ZLPhotoPickerGroup *assetsGroup;

@property (nonatomic , assign) NSInteger maxCount;
// 需要记录选中的值的数据
@property (strong,nonatomic) NSArray *selectPickerAssets;
// 置顶展示图片
@property (assign,nonatomic) BOOL topShowPhotoPicker;

@property (nonatomic, copy) void(^selectedAssetsBlock)(NSArray *selectedAssets);

- (instancetype)initWithShowType:(XGShowImageType)showType;

@end
