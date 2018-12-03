//
//  DYImagePickerVC.m
//  DYwardrobe
//
//  Created by wuning on 16/1/6.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "DYImagePickerVC.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MutiCollectionLayout.h"
#import "AlbumPhotoCell.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+Additions.h"
#import "UIImage+Additions.h"
#import "UIImage+COSAdtions.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImageEditVC.h"

#define SCALEMAX 2.0 //最大放大倍数
#define WIDTHHEIGHTLIMETSCALE 3.0/4.0 //限制得到图片的 长宽比例

@interface DYImagePickerVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    CGSize orginSize;
}
// 相册
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;
@property (weak, nonatomic) IBOutlet UIView *photoBgView;
@property (weak, nonatomic) IBOutlet MutiCollectionLayout *collectionLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionPhotos;
@end

//static long long time_stamp = 0;
//static long long time_stamp_now = 0;
//static NSMutableArray *temp = NULL;
//static NSNumber *random_n = NULL;
//static NSLock *theLock = NULL;

@implementation DYImagePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    _groups = [NSMutableArray array];
    self.navigationItem.title = NSLocalizedString(@"选择照片或拍照", nil);
    [self loadLibrary];
    
    _assets = [[NSMutableArray alloc] init];
    [self addGestureRecognizerToView:self.imageSelected];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initNavi];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

// 添加所有的手势
- (void) addGestureRecognizerToView:(UIView *)view
{
    // 旋转手势
    [view setUserInteractionEnabled:YES];
    [view setMultipleTouchEnabled:YES];
//    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
//    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [view addGestureRecognizer:panGestureRecognizer];
}

//// 处理旋转手势
//- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
//{
//    UIView *view = rotationGestureRecognizer.view;
//    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        
//        NSLog(@"%f",rotationGestureRecognizer.rotation);
//        
//        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
//        [rotationGestureRecognizer setRotation:0];
//    }
//}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat rule = view.width > view.height?view.width:view.height;
        CGFloat min = ScreenWidth * WIDTHHEIGHTLIMETSCALE;
        if (rule < ScreenWidth) {
            CGFloat width;
            CGFloat height;
            if (view.width > view.height) {
                width = ScreenWidth;
                height = ScreenWidth * view.height / view.width;
            }else{
                height = ScreenWidth;
                width = ScreenWidth * view.width / view.height;
            }
            
            if (width < min || height < min) {
                width = orginSize.width;
                height = orginSize.height;
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                view.width = width;
                view.height = height;
                view.center = CGPointMake(view.superview.width / 2.0, view.superview.height / 2.0);

            }];
        }else{
            CGFloat width = view.width;
            CGFloat height = view.height;
            if (width > SCALEMAX * orginSize.width || height > SCALEMAX * orginSize.height) {
                height = SCALEMAX * orginSize.height;
                width = SCALEMAX * orginSize.width;
            }
            if (width < min || height < min) {
                width = orginSize.width;
                height = orginSize.height;
            }
            [UIView animateWithDuration:0.2 animations:^{
                view.width = width;
                view.height = height;
                view.center = CGPointMake(view.superview.width / 2.0, view.superview.height / 2.0);
            }];
        }
        
    }
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint center = view.center;
        
        if (view.width <= ScreenWidth)
        {
            center.x = ScreenWidth / 2.0f;
        }else{
            if (view.originX > 0) {
                center.x -= view.originX;
            }else{
                if ((ScreenWidth - center.x) > view.width / 2.0f) {
                    center.x += (ScreenWidth - center.x) - view.width / 2.0f;
                }
            }
        }
        
        if (view.height <= ScreenWidth) {
            center.y = ScreenWidth / 2.0f;
        }else{
            if (view.originY > 0) {
                center.y -= view.originY;
            }else{
                if((ScreenWidth - center.y) > view.height / 2.0f){
                    CGFloat offSet =(ScreenWidth - center.y)-view.height / 2.0f;
                    center.y += offSet;
                }
            }
        }
        [UIView animateWithDuration:0.2 animations:^{
            view.center = center;
        }];
        
    }
}

- (void)initNavi
{
    [self.collectionPhotos registerNib:[UINib nibWithNibName:@"AlbumPhotoCell" bundle:nil] forCellWithReuseIdentifier:@"AlbumPhotoCell"];
    self.collectionLayout.widthHeightScale = 1;
    self.collectionLayout.lineSpacing = 0;
    self.collectionLayout.interitemSpacing = 0;
    self.collectionLayout.numberOfItemForLine = 4;
    self.collectionLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStylePlain target:self action:@selector(leftBarAction)];
//    leftItem.tintColor = [UIColor colorWithHexString:@"777777"];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"确定", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarAction)];
//    rightItem.tintColor = [UIColor colorWithHexString:@"C90039"];
    self.navigationItem.rightBarButtonItem = rightItem;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 加载资源库
- (void)loadLibrary
{
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
//        headerView.hidden = YES;
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
            {
                errorMessage = @"The user has declined access to it.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"当前不能查看照片，请进入设置->隐私->照片->在XXX应用后面打开开关", nil) message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
                [alert show];
            }
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *assetsFilter = nil;
        assetsFilter = [ALAssetsFilter allAssets];
        [group setAssetsFilter:assetsFilter];
        if ([group numberOfAssets] > 0)
        {
            [self.groups addObject:group];
            //            [_collectionView reloadData];
            
            //            [NSObject cancelPreviousPerformRequestsWithTarget:_collectionView selector:@selector(reloadData) object:nil];
            [self performSelectorOnMainThread:@selector(loadLibraryComplete) withObject:nil waitUntilDone:NO];
        }
        else
        {
            
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    groupTypes = ALAssetsGroupAll; // 遍历全部相册
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (void)loadLibraryComplete
{
    // 结束以后,如果没有选中的相册，加载第一个相册的照片并显示
    if (_groups.count > 0 && !_assetsGroup) {
        [self loadAssetGroup:[_groups lastObject]];
    }
}

#pragma mark 加载相册
- (void)loadAssetGroup:(ALAssetsGroup *)group
{
    _assetsGroup = group;
    
    [self.assets removeAllObjects];
    
//    NSString *title = [group valueForProperty:ALAssetsGroupPropertyName];
//    [self configTitleViewWithTitle:title];
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self.assets addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = nil;
     onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
    self.assets = [NSMutableArray arrayWithArray:[[self.assets reverseObjectEnumerator] allObjects]];
    [self implement:self.assets];
    
}

- (void)implement:(NSMutableArray *)array
{
    [_collectionPhotos reloadData];
    if (array.count > 1) {
        [_collectionPhotos selectItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    if (array.count > 0) {
        ALAsset *asset = [_assets objectAtIndex:0];
        
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                                       scale:[assetRepresentation scale]
                                                 orientation:(int)[assetRepresentation orientation]];
        [self setCoverImage:fullScreenImage];
    }
}

- (void)setCoverImage:(UIImage *)theImage
{
    CGFloat WHScale = theImage.size.width / theImage.size.height;
    
    CGFloat rule = ScreenWidth * WIDTHHEIGHTLIMETSCALE;
    CGSize imageViewSize;
    if (WHScale > 1) {
        CGFloat height = ScreenWidth/WHScale;
        if (height < rule) {
            height = rule;
            imageViewSize = CGSizeMake(height*WHScale, height);
        }else{
            imageViewSize = CGSizeMake(ScreenWidth, height);
        }
    }else{
        CGFloat width = ScreenWidth*WHScale;
        if (width < rule) {
            width = rule;
            imageViewSize = CGSizeMake(width, width/WHScale);
        }else{
            imageViewSize = CGSizeMake(width, ScreenWidth);
        }
    }
    self.imageSelected.contentMode = UIViewContentModeScaleToFill;
    [self.imageSelected setImage:theImage];
    [self.imageSelected setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.imageSelected.frame = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
    self.imageSelected.center = CGPointMake(self.imageSelected.superview.width / 2.0f, self.imageSelected.superview.height / 2.0f);
    
    orginSize = self.imageSelected.frame.size;
}

//UICollectionViewDelegate and datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumPhotoCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.imageCover.image = [UIImage imageNamed:@"CAM1"];
    }else{
        ALAsset *asset = [_assets objectAtIndex:indexPath.row - 1];
        
        CGImageRef thumbnailImageRef = [asset thumbnail];
        UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
        
        // apply the image to the cell
        cell.imageCover.image = thumbnail;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"当前不能查看照片，请进入设置->隐私->照片->在XXX应用后面打开开关", nil) message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
            [alert show];
            return;
        }
        [self useCamera];
    }else{
        ALAsset *asset = [_assets objectAtIndex:indexPath.row - 1];
        
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullResolutionImage]
                                                       scale:[assetRepresentation scale]
                                                 orientation:(int)[assetRepresentation orientation]];
        [self setCoverImage:fullScreenImage];
        [UIView animateWithDuration:0.25 animations:^{
            self.collectionPhotos.frame = CGRectMake(0, self.photoBgView.height, self.view.width, self.view.height - self.photoBgView.height);
            self.photoBgView.originY = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionPhotos) {
        if (scrollView.contentOffset.y > 10 && self.photoBgView.originY == 0) {
            [UIView animateWithDuration:0.25 animations:^{
                self.collectionPhotos.frame = self.view.bounds;
                self.photoBgView.originY = self.photoBgView.height * -1;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
        }
        
        if (scrollView.contentOffset.y < -20 && self.photoBgView.originY == -self.photoBgView.height) {
            [UIView animateWithDuration:0.25 animations:^{
                self.collectionPhotos.frame = CGRectMake(0, self.photoBgView.height, self.view.width, self.view.height - self.photoBgView.height);
                self.photoBgView.originY = 0;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}
#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self setCoverImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [self setCoverImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self implement:self.assets];
}

#pragma mark -- GestureMethod
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{

    return self.imageSelected;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{

    [scrollView addSubview:self.imageSelected];
}

#pragma mark -- ActionMethod
- (void)leftBarAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(cancel:)]) {

        [self.delegate cancel:self];
    }
}

- (void)rightBarAction
{
    CGFloat scraled = self.imageSelected.image.size.width / self.imageSelected.frame.size.width;
    
//    CGPoint center = self.imageSelected.center;
    CGFloat imgX;
    CGFloat imgY;
    CGFloat imgW;
    CGFloat imgH;
    
    if (self.imageSelected.width <= ScreenWidth)
    {
        imgX = 0;
        imgW = self.imageSelected.width;
    }else{
        imgX = -self.imageSelected.originX;
        imgW = ScreenWidth;
    }
    
    if (self.imageSelected.height <= ScreenWidth) {
        imgY = 0;
        imgH = self.imageSelected.height;
    }else{
        imgY = - self.imageSelected.originY;
        imgH = ScreenWidth;
    }
    
    CGRect rect = CGRectMake(imgX*scraled, imgY*scraled, imgW*scraled, imgH*scraled);
    
    UIImage *imageCroped = [self.imageSelected.image getSubImage:rect];
    
    NSData *data = UIImageJPEGRepresentation(imageCroped, 0.8);
    
    float f = 0.8;
    
    for (int i = 0; i < 8; i ++) {
        f -= 0.1;
        data = UIImageJPEGRepresentation(imageCroped, f);
        if (data.length < 200000) {
            break;
        }
    }
    
    
//    NSString *key = [self getId];// 自己计算的 id 用于上传用的Id 根据业务后台获取

    ImageEditVC *vc = [[ImageEditVC alloc]init];
    vc.image = imageCroped;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)useCamera
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    [self presentViewController:pickerController animated:YES completion:nil];
}

//- (NSString *)getId
//{
//    NSString *objectId;
//    if(theLock == NULL)
//        theLock = [[NSLock alloc]init];
//    
//    if(temp == NULL)
//        temp = [[NSMutableArray alloc]init];
//    
//    @synchronized(theLock){
//        time_stamp_now = [[NSDate date] timeIntervalSince1970];
//        if(time_stamp_now != time_stamp){
//            //清空缓存，更新时间戳
//            [temp removeAllObjects];
//            time_stamp = time_stamp_now;
//        }
//        
//        //判断缓存中是否存在当前随机数
//        while ([temp containsObject:(random_n = [NSNumber numberWithLong:arc4random() % 8999 + 1000])])
//            ;
//        
//        if ([temp containsObject:random_n]) {
//            return nil;
//        }
//        
//        [temp addObject:[NSNumber numberWithLong:[random_n longValue]]];
//    }
//    
//    long long timeId = (time_stamp * 10000) + [random_n longValue];
//    objectId = [NSString stringWithFormat:@"%lld",timeId];
//    return objectId;
//}
@end
