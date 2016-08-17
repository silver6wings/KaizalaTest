//
//  ViewController.m
//  ImageZoom
//
//  Created by JunchaoYU on 16/8/15.
//  Copyright © 2016年 Microsoft. All rights reserved.
//

#define EGHE_Y 110

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView, *imageView2;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *button, * button2;
@property (nonatomic, strong) UITextField *txtWidth, *txtHeight, *txtJPG;
@property (nonatomic, strong) UILabel *lbSize;
@property (nonatomic, strong) UIBarButtonItem *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(320, 600);
    [self.view addSubview:_scrollView];
    
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _button.frame = CGRectMake(10, 30, 80, 30);
    _button.backgroundColor = [UIColor yellowColor];
    [_button setTitle:@"GET" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(getImageFromIpc:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_button];
    
    _button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _button2.frame = CGRectMake(100, 30, 80, 30);
    _button2.backgroundColor = [UIColor yellowColor];
    [_button2 setTitle:@"JPG" forState:UIControlStateNormal];
    [_button2 addTarget:self action:@selector(setImageCompress:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_button2];
    
    _txtWidth = [[UITextField alloc] initWithFrame:CGRectMake(10, 70, 80, 30)];
    _txtWidth.placeholder = @"width";
    _txtWidth.backgroundColor = [UIColor yellowColor];
    [_scrollView addSubview:_txtWidth];
    
    _txtHeight = [[UITextField alloc] initWithFrame:CGRectMake(100, 70, 80, 30)];
    _txtHeight.placeholder = @"height";
    _txtHeight.backgroundColor = [UIColor yellowColor];
    [_scrollView addSubview:_txtHeight];
    
    _txtJPG = [[UITextField alloc] initWithFrame:CGRectMake(190, 70, 80, 30)];
    _txtJPG.placeholder = @"ratio";
    _txtJPG.backgroundColor = [UIColor yellowColor];
    [_scrollView addSubview:_txtJPG];
    
    _lbSize = [[UILabel alloc] initWithFrame:CGRectMake(190, 30, 130, 30)];
    [_scrollView addSubview:_lbSize];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 110, 300, 500)];
    [_scrollView  addSubview:self.imageView];
}

- (void)getImageFromIpc:(id)sender
{
    // 1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    // 2. 创建图片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    /**
     typedef NS_ENUM(NSInteger, UIImagePickerControllerSourceType) {
     UIImagePickerControllerSourceTypePhotoLibrary, // 相册
     UIImagePickerControllerSourceTypeCamera, // 用相机拍摄获取
     UIImagePickerControllerSourceTypeSavedPhotosAlbum // 相簿
     }
     */
    // 3. 设置打开照片相册类型(显示所有相簿)
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    // 照相机
    // ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    // 4.设置代理
    ipc.delegate = self;
    // 5.modal出这个控制器
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)setImageCompress:(id)sender
{
    float ratio = [_txtJPG.text floatValue];
    float width = [_txtWidth.text intValue];
    float height = [_txtHeight.text intValue];
    
    UIImage * image = [_image copy];
    
    if (width > 0 && height > 0)
    {
        NSLog(@"%f", width);
        NSLog(@"%f", height);
        image = [self scaleToSize:image size:CGSizeMake(width, height)];
    }
    
    if (ratio > 0)
    {
        NSLog(@"%f", ratio);
        image = [self compressImage:image ratio:ratio];
    }
    
    [self refreshImageView:image];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)compressImage:(UIImage *)image ratio:(float)ratio
{
    NSData *data = UIImageJPEGRepresentation(image, ratio);
    self.title = [NSString stringWithFormat:@"JPG:%.2fK", data.length/1024.0f];
    
    [self.view endEditing:YES];
    
    return [UIImage imageWithData:data];
}

- (void)refreshImageView:(UIImage *)image
{
    _imageView.frame = CGRectMake(10, EGHE_Y, image.size.width ,image.size.height);
    _imageView.image = image;
    _scrollView.contentSize = CGSizeMake(MAX(320, image.size.width + 20), image.size.height + 150);
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 设置图片
    _image = info[UIImagePickerControllerOriginalImage];
    [self refreshImageView:_image];
    
    NSData *data = UIImagePNGRepresentation(self.image);
    _lbSize.text = [NSString stringWithFormat:@"PNG:%.2fK", data.length/1024.0f];

}


@end
