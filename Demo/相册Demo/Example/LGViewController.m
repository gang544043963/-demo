//
//  LGViewController.m
//  ZLAssetsPickerDemo
//
//  Created by ligang on 15/9/17.
//  Copyright (c) 2015年 com.zixue101.www. All rights reserved.
//

#import "LGViewController.h"
#import "Example1TableViewCell.h"
#import "ZLPhoto.h"
#import "ZLPhotoAssets.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LGViewController ()<ZLPhotoPickerViewControllerDelegate>

@property (nonatomic , strong) NSMutableArray *selectedAssets;

@end

@implementation LGViewController

- (NSMutableArray *)selectedAssets{
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    return _selectedAssets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self presentPhotoPickerViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - select Photo Library
- (void)presentPhotoPickerViewController {
    // 创建控制器
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] initWithShowType:kXGImagePicker];
    // 默认显示相册里面的内容SavePhotos
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.selectPickers = self.selectedAssets;
    // 最多能选9张图片
    pickerVc.maxCount = 9;
    pickerVc.delegate = self;
    [pickerVc showPickerVc:self];
}


#pragma mark - ZLPhotoPickerViewControllerDelegate

- (void)pickerViewControllerDoneAsstes:(NSArray *)assets isOriginal:(BOOL)original
{

}

@end
