//
//  ZLPhotoPickerAssetsViewController.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-12.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import "ZLPhoto.h"
#import "ZLPhotoPickerCollectionView.h"
#import "ZLPhotoPickerGroup.h"
#import "ZLPhotoPickerCollectionViewCell.h"
#import "ZLPhotoPickerFooterCollectionReusableView.h"

static CGFloat CELL_ROW = 4;
static CGFloat CELL_MARGIN = 2;
static CGFloat CELL_LINE_MARGIN = 2;
static CGFloat TOOLBAR_HEIGHT = 44;

static NSString *const _cellIdentifier = @"cell";
static NSString *const _footerIdentifier = @"FooterView";
static NSString *const _identifier = @"toolBarThumbCollectionViewCell";
@interface ZLPhotoPickerAssetsViewController () <ZLPhotoPickerCollectionViewDelegate,UICollectionViewDataSource,ZLPhotoPickerBrowserViewControllerDataSource,ZLPhotoPickerBrowserViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

// View
// 相片View
@property (nonatomic , strong) ZLPhotoPickerCollectionView *collectionView;
// 标记View
@property (nonatomic , weak) UILabel *makeView;
@property (nonatomic , strong) UIButton *doneBtn;
@property (nonatomic , strong) UIButton *previewBtn;
@property (nonatomic , weak) UIToolbar *toolBar;

@property (assign,nonatomic) NSUInteger privateTempMaxCount;
// Datas
// 数据源
@property (nonatomic , strong) NSMutableArray *assets;
// 记录选中的assets
@property (nonatomic , strong) NSMutableArray *selectAssets;
// 拍照后的图片数组
@property (strong,nonatomic) NSMutableArray *takePhotoImages;
// 1 - 相册浏览器的数据源是 selectAssets， 0 - 相册浏览器的数据源是 assets
@property (nonatomic, assign) BOOL isPreview;
//
@end

@implementation ZLPhotoPickerAssetsViewController

#pragma mark - dealloc

- (void)dealloc{
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    // 赋值给上一个控制器,以便记录上次选择的照片
    if (self.selectedAssetsBlock) {
        self.selectedAssetsBlock(self.selectAssets);
    }
}

- (instancetype)initWithShowType:(XGShowImageType)showType{
    self = [super init];
    if (self) {
        self.showType = showType;
    }
    return self;
}

#pragma mark - getter
#pragma mark Get Data
- (NSMutableArray *)selectAssets{
    if (!_selectAssets) {
        _selectAssets = [NSMutableArray array];
    }
    return _selectAssets;
}

- (NSMutableArray *)takePhotoImages{
    if (!_takePhotoImages) {
        _takePhotoImages = [NSMutableArray array];
    }
    return _takePhotoImages;
}

#pragma mark Get View
- (UIButton *)doneBtn{
    if (!_doneBtn) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        rightBtn.enabled = YES;
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        rightBtn.frame = CGRectMake(0, 0, 45, 45);
        [rightBtn setTitle:@"发送" forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(doneBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn addSubview:self.makeView];
        self.doneBtn = rightBtn;
    }
    return _doneBtn;
}

- (UIButton *)previewBtn
{
    if (!_previewBtn) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setTitleColor:[UIColor colorWithRed:0/255.0 green:91/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        leftBtn.enabled = YES;
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        leftBtn.frame = CGRectMake(0, 0, 45, 45);
        [leftBtn setTitle:@"预览" forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(previewBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        self.previewBtn = leftBtn;
    }
    return _previewBtn;
}

- (void)previewBtnTouched
{
    [self setupPhotoBrowserInCasePreview:YES CurrentIndexPath:0];
}

/**
 *  跳转照片浏览器
 *
 *  @param preview YES - 从‘预览’按钮进去，浏览器显示的时被选中的照片
 *                  NO - 点击cell进去，浏览器显示所有照片
 *  @param CurrentIndexPath 进入浏览器后展示图片的位置
 */
- (void) setupPhotoBrowserInCasePreview:(BOOL)preview
                       CurrentIndexPath:(NSIndexPath *)indexPath{
    
    self.isPreview = preview;
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 动画方式
    // 数据源/delegate
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    // 数据源可以不传，传photos数组 photos<里面是ZLPhotoPickerBrowserPhoto>
//    pickerBrowser.photos = self.selectAssets;
    // 是否可以删除照片
    pickerBrowser.editing = NO;
    // 当前选中的值
    pickerBrowser.currentIndexPath = indexPath;    // 展示控制器
    [pickerBrowser showPushPickerVc:self];
//    [self.navigationController pushViewController:pickerBrowser animated:NO];
//    [self presentViewController:pickerBrowser animated:YES completion:nil];
    
}

- (void)setSelectPickerAssets:(NSArray *)selectPickerAssets{
    NSSet *set = [NSSet setWithArray:selectPickerAssets];
    _selectPickerAssets = [set allObjects];
    
    if (!self.assets) {
        self.assets = [NSMutableArray arrayWithArray:selectPickerAssets];
    }else{
        [self.assets addObjectsFromArray:selectPickerAssets];
    }
    
    for (ZLPhotoAssets *assets in selectPickerAssets) {
        if ([assets isKindOfClass:[ZLPhotoAssets class]] || [assets isKindOfClass:[UIImage class]]) {
            [self.selectAssets addObject:assets];
        }
    }

    self.collectionView.lastDataArray = nil;
    self.collectionView.isRecoderSelectPicker = YES;
    self.collectionView.selectAssets = self.selectAssets;
    NSInteger count = self.selectAssets.count;
    self.makeView.hidden = !count;
    self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
    self.doneBtn.enabled = (count > 0);
    self.previewBtn.enabled = (count > 0);
}

- (void)setTopShowPhotoPicker:(BOOL)topShowPhotoPicker{
    _topShowPhotoPicker = topShowPhotoPicker;

    if (self.topShowPhotoPicker == YES) {
        NSMutableArray *reSortArray= [[NSMutableArray alloc] init];
        for (id obj in [self.collectionView.dataArray reverseObjectEnumerator]) {
            [reSortArray addObject:obj];
        }
        
        ZLPhotoAssets *zlAsset = [[ZLPhotoAssets alloc] init];
        [reSortArray insertObject:zlAsset atIndex:0];
        
        self.collectionView.status = ZLPickerCollectionViewShowOrderStatusTimeAsc;
        self.collectionView.topShowPhotoPicker = topShowPhotoPicker;
        self.collectionView.dataArray = reSortArray;
        [self.collectionView reloadData];
    }
}

#pragma mark collectionView
- (ZLPhotoPickerCollectionView *)collectionView{
    if (!_collectionView) {
        
        CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, TOOLBAR_HEIGHT * 2);
        
        ZLPhotoPickerCollectionView *collectionView = [[ZLPhotoPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        // 时间置顶
        collectionView.status = ZLPickerCollectionViewShowOrderStatusTimeDesc;
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [collectionView registerClass:[ZLPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        // 底部的View
        [collectionView registerClass:[ZLPhotoPickerFooterCollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
        
        collectionView.contentInset = UIEdgeInsetsMake(5, 0,TOOLBAR_HEIGHT, 0);
        collectionView.collectionViewDelegate = self;
        [self.view insertSubview:_collectionView = collectionView belowSubview:self.toolBar];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
        
        NSString *widthVfl = @"H:|-0-[collectionView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        
        NSString *heightVfl = @"V:|-0-[collectionView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
        
    }
    return _collectionView;
}

#pragma mark makeView 红点标记View
- (UILabel *)makeView{
    if (!_makeView) {
        UILabel *makeView = [[UILabel alloc] init];
        makeView.textColor = [UIColor whiteColor];
        makeView.textAlignment = NSTextAlignmentCenter;
        makeView.font = [UIFont systemFontOfSize:13];
        makeView.frame = CGRectMake(-5, -5, 20, 20);
        makeView.hidden = YES;
        makeView.layer.cornerRadius = makeView.frame.size.height / 2.0;
        makeView.clipsToBounds = YES;
        makeView.backgroundColor = [UIColor redColor];
        [self.view addSubview:makeView];
        self.makeView = makeView;
        
    }
    return _makeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.bounds = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
    // 获取相册
    [self setupAssets];
    // 初始化按钮
    [self setupButtons];
    // 初始化底部ToorBar
    [self setupToorBar];
}

#pragma mark - setter
#pragma mark 初始化按钮
- (void) setupButtons{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
}

#pragma mark 初始化所有的组
- (void) setupAssets{
    if (!self.assets) {
        self.assets = [NSMutableArray array];
    }
    
    __block NSMutableArray *assetsM = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [[ZLPhotoPickerDatas defaultPicker] getGroupPhotosWithGroup:self.assetsGroup finished:^(NSArray *assets) {
            
            [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
                ZLPhotoAssets *zlAsset = [[ZLPhotoAssets alloc] init];
                zlAsset.asset = asset;
                [assetsM addObject:zlAsset];
            }];
            weakSelf.collectionView.dataArray = assetsM;
            [self.assets setArray:assetsM];
        }];
    });
}

- (void)pickerCollectionViewDidCameraSelect:(ZLPhotoPickerCollectionView *)pickerCollectionView{
    
    
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.delegate = self;
    ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:ctrl animated:YES completion:nil];
    
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_PHOTO object:nil];
//    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 处理
        UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
        
        [self.assets addObject:image];
        [self.selectAssets addObject:image];
        [self.takePhotoImages addObject:image];
        
        NSInteger count = self.selectAssets.count;
        self.makeView.hidden = !count;
        self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
        self.doneBtn.enabled = (count > 0);
        self.previewBtn.enabled = (count > 0);
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"请在真机使用!");
    }
}

#pragma mark -初始化底部ToorBar
- (void) setupToorBar{
    UIToolbar *toorBar = [[UIToolbar alloc] init];
    toorBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toorBar];
    self.toolBar = toorBar;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toorBar);
    NSString *widthVfl =  @"H:|-0-[toorBar]-0-|";
    NSString *heightVfl = @"V:[toorBar(44)]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    // 左视图 中间距 右视图
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.previewBtn];
    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    
    toorBar.items = @[leftItem,fiexItem,rightItem];
    
}

#pragma mark - setter
-(void)setMaxCount:(NSInteger)maxCount{
    _maxCount = maxCount;
    
    if (!_privateTempMaxCount) {
        _privateTempMaxCount = maxCount;
    }

    if (self.selectAssets.count == maxCount){
        maxCount = 0;
    }else if (self.selectPickerAssets.count - self.selectAssets.count > 0) {
        maxCount = _privateTempMaxCount;
    }
    
    self.collectionView.maxCount = maxCount;
}

- (void)setAssetsGroup:(ZLPhotoPickerGroup *)assetsGroup{
    if (!assetsGroup.groupName.length) return ;
    
    _assetsGroup = assetsGroup;
    
    self.title = assetsGroup.groupName;
    
    // 获取Assets
//    [self setupAssets];
}

#pragma mark - ZLPhotoPickerCollectionViewDelegate

//cell被点击会调用
- (void) pickerCollectionCellTouchedIndexPath:(NSIndexPath *)indexPath
{
    [self setupPhotoBrowserInCasePreview:NO CurrentIndexPath:indexPath];
}

//cell的右上角选择框被点击会调用
- (void) pickerCollectionViewDidSelected:(ZLPhotoPickerCollectionView *) pickerCollectionView deleteAsset:(ZLPhotoAssets *)deleteAssets{
    
    if (self.selectPickerAssets.count == 0){
        self.selectAssets = [NSMutableArray arrayWithArray:pickerCollectionView.selectAssets];
    }else if (deleteAssets == nil){
        [self.selectAssets addObject:[pickerCollectionView.selectAssets lastObject]];
    }
    
    [self.selectAssets addObjectsFromArray:self.takePhotoImages];
    
//    self.selectAssets = [NSMutableArray arrayWithArray:[[NSSet setWithArray:self.selectAssets] allObjects]];

    NSInteger count = self.selectAssets.count;
    self.makeView.hidden = !count;
    self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
    self.doneBtn.enabled = (count > 0);
    self.previewBtn.enabled = (count > 0);
    
    if (self.selectPickerAssets.count || deleteAssets) {
        ZLPhotoAssets *asset = [pickerCollectionView.lastDataArray lastObject];
        if (deleteAssets){
            asset = deleteAssets;
        }
        
        NSInteger selectAssetsCurrentPage = -1;
        for (NSInteger i = 0; i < self.selectAssets.count; i++) {
            ZLPhotoAssets *photoAsset = self.selectAssets[i];
            if ([photoAsset isKindOfClass:[UIImage class]]) {
                continue;
            }
            if([[[[asset.asset defaultRepresentation] url] absoluteString] isEqualToString:[[[photoAsset.asset defaultRepresentation] url] absoluteString]]){
                selectAssetsCurrentPage = i;
                break;
            }
        }
        
        if (
            (self.selectAssets.count > selectAssetsCurrentPage)
            &&
            (selectAssetsCurrentPage >= 0)
            ){
            if (deleteAssets){
                [self.selectAssets removeObjectAtIndex:selectAssetsCurrentPage];
            }
            
            [self.collectionView.selectsIndexPath removeObject:@(selectAssetsCurrentPage)];

            self.makeView.text = [NSString stringWithFormat:@"%ld",(unsigned long)self.selectAssets.count];
        }
        // 刷新下最小的页数
        self.maxCount = self.selectAssets.count + (_privateTempMaxCount - self.selectAssets.count);
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selectAssets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    
    if (self.selectAssets.count > indexPath.item) {
        UIImageView *imageView = [[cell.contentView subviews] lastObject];
        // 判断真实类型
        if (![imageView isKindOfClass:[UIImageView class]]) {
            imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
        }
        imageView.tag = indexPath.item;
        if ([self.selectAssets[indexPath.item] isKindOfClass:[ZLPhotoAssets class]]) {
            imageView.image = [self.selectAssets[indexPath.item] thumbImage];
        }else if ([self.selectAssets[indexPath.item] isKindOfClass:[UIImage class]]){
            imageView.image = (UIImage *)self.selectAssets[indexPath.item];
        }
    }

    return cell;
}

#pragma mark - ZLPhotoPickerBrowserViewControllerDataSource

- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser{
    return 1;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    if (self.isPreview) {
        return self.selectAssets.count;
    } else {
        return self.assets.count;
    }
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZLPhotoAssets *imageObj = [[ZLPhotoAssets alloc] init];
    if (self.isPreview && self.selectAssets.count) {
        imageObj = [self.selectAssets objectAtIndex:indexPath.row];
    } else if (!self.isPreview && self.assets.count){
        imageObj = [self.assets objectAtIndex:indexPath.row];
    }
    // 包装下imageObj 成 ZLPhotoPickerBrowserPhoto 传给数据源
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    
    ZLPhotoPickerCollectionViewCell *cell = (ZLPhotoPickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    photo.toView = [[UIImageView alloc] initWithImage:cell.cellImage];
    photo.thumbImage = cell.cellImage;
    
    return photo;
}



- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath{
    
    // 删除选中的照片
    ALAsset *asset = self.selectAssets[indexPath.row];
    NSInteger currentPage = indexPath.row;
    for (NSInteger i = 0; i < self.collectionView.dataArray.count; i++) {
        ALAsset *photoAsset = self.collectionView.dataArray[i];
        if ([photoAsset isKindOfClass:[ZLPhotoAssets class]] && [asset isKindOfClass:[ZLPhotoAssets class]]) {
                ZLPhotoAssets *photoAssets = (ZLPhotoAssets *)photoAsset;
                ZLPhotoAssets *assets = (ZLPhotoAssets *)asset;
                if([[[[assets.asset defaultRepresentation] url] absoluteString] isEqualToString:[[[photoAssets.asset defaultRepresentation] url] absoluteString]]){
                    currentPage = i;
                    break;
                }
            }
        else{
            continue;
            break;
        }
    }

    [self.selectAssets removeObjectAtIndex:indexPath.row];
    [self.collectionView.selectsIndexPath removeObject:@(currentPage)];
    [self.collectionView reloadData];
    
    self.makeView.text = [NSString stringWithFormat:@"%ld",(unsigned long)self.selectAssets.count];
}

#pragma mark -<Navigation Actions>
#pragma mark -开启异步通知
- (void) back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) doneBtnTouched {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_DONE object:nil userInfo:@{@"selectAssets":self.selectAssets}];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
