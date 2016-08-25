//
//  CapturePictureTool.m
//  SmartHome
//
//  Created by iwevon on 16/3/21.
//  Copyright © 2016年 周秋阳. All rights reserved.
//

#import "CapturePictureTool.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


// en
const NSString * kSelectImageModeEN = @"Choose the picture mode";
const NSString * kCameraEN= @"Camera";
const NSString * kPhotoLibraryEN= @"Photo library";
const NSString * kOkEN = @"OK";
const NSString * kCancelEN = @"Cancel";

const NSString * kTipTitleEN = @"Tip";
const NSString * kCameraMessageEN = @"Please allow access to the camera in the device \"Settings - Privacy - Camera \"";
const NSString * kPhotosMessageEN = @"Please allow access to photos in the device \"Settings - Privacy - Camera \"";

// zh-Hans
const NSString * kSelectImageModeZH = @"选择图片方式";
const NSString * kCameraZH = @"相机";
const NSString * kPhotoLibraryZH = @"相册";
const NSString * kOkZH = @"确定";
const NSString * kCancelZH = @"取消";

const NSString * kTipTitleZH = @"提示";
const NSString * kCameraMessageZH = @"请在设备的\"设置-隐私-相机\"中允许访问相机";
const NSString * kPhotosMessageZH = @"请在设备的\"设置-隐私-照片\"中允许访问照片";


typedef void(^DidFinishTakeMediaCompledBlock)(UIImage *image, NSDictionary *editingInfo);

@interface CapturePictureTool ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) DidFinishTakeMediaCompledBlock didFinishTakeMediaCompled;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) UIActionSheet *photoSheet;

@end

#pragma mark - 让UIImagePickerController支持屏幕旋转

@interface UIImagePickerController (Nonrotating)

@end

@implementation UIImagePickerController (Nonrotating)

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end


#pragma mark - CapturePictureTool

@implementation CapturePictureTool

#pragma mark - Public

+ (instancetype)capturePictureWithViewController:(UIViewController *)viewController compled:(void(^)(UIImage *image, NSDictionary *editingInfo))compled {
    
    CapturePictureTool * cpTool = [[self alloc] init];
    cpTool.viewController = viewController;
    cpTool.didFinishTakeMediaCompled = [compled copy];
    return cpTool;
}


#pragma mark - Private

- (BOOL)isChineseLanguageEnvironment {
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    // YES:中文 NO:英文
    return [currentLanguage rangeOfString:@"zh"].location != NSNotFound;
}


#pragma mark - ActionSheet

- (void)show {
    
    NSString * selectImageModeStr = [self isChineseLanguageEnvironment] ? [kSelectImageModeZH copy]: [kSelectImageModeEN copy];
    NSString * cameraStr = [self isChineseLanguageEnvironment] ? [kCameraZH copy]: [kCameraEN copy];
    NSString * photoLibraryStr = [self isChineseLanguageEnvironment] ? [kPhotoLibraryZH copy] : [kPhotoLibraryEN copy];
    NSString * cancelStr = [self isChineseLanguageEnvironment] ? [kCancelZH copy] : [kCancelEN copy];
    
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:selectImageModeStr delegate:self cancelButtonTitle:cancelStr destructiveButtonTitle:nil otherButtonTitles:cameraStr, photoLibraryStr, nil];
    self.photoSheet = photoSheet;
    [photoSheet showInView:self.viewController.view];
    
}

- (void)dissMiss {
    
    NSLog(@"dissMiss");
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    NSString *messageStr = nil;
    
    switch (buttonIndex) {
            
        case 0:
        {
            // 判断用户是否有权限访问相机
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
                messageStr = [self isChineseLanguageEnvironment] ? [kCameraMessageZH copy] : [kCameraMessageEN copy];
            } else {
                
                sourceType = UIImagePickerControllerSourceTypeCamera;
            }
        }
            break;
            
        case 1:
        {
            // 判断用户是否有权限访问相册
            ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
            if (authStatus == ALAuthorizationStatusRestricted || authStatus ==ALAuthorizationStatusDenied){
                //无权限
                messageStr =[self isChineseLanguageEnvironment] ? [kPhotosMessageZH copy] : [kPhotosMessageEN copy];
            } else {
                
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
        }
            break;
            
        default:
            return;
    }

    if (messageStr) {
        NSString * tipTitleStr =[self isChineseLanguageEnvironment] ? [kTipTitleZH copy] : [kTipTitleEN copy];
        NSString * okStr = [self isChineseLanguageEnvironment] ? [kOkZH copy] : [kOkEN copy];
        
        //无权限
        [[[UIAlertView alloc] initWithTitle:tipTitleStr
                                    message:messageStr
                                   delegate:nil
                          cancelButtonTitle:okStr
                          otherButtonTitles:nil] show];
        return;
    }
    
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        self.didFinishTakeMediaCompled ? self.didFinishTakeMediaCompled(nil, nil) : nil;
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.editing = YES;
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.mediaTypes =  [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    [self.viewController presentViewController:imagePickerController animated:YES completion:NULL];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)dismissPickerViewController:(UIImagePickerController *)picker {
    
    typeof(self) __weak weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        weakSelf.didFinishTakeMediaCompled = nil;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    NSMutableDictionary * dict= [NSMutableDictionary dictionaryWithDictionary:editingInfo];
    
    [dict setObject:image forKey:@"UIImagePickerControllerEditedImage"];

    [self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage* originalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        //如果是 来自照相机的image，那么先保存
        UIImageWriteToSavedPhotosAlbum(originalImage, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:),
                                       nil);
    }
    
    UIImage *theImage = [self imageWithImageSimple:originalImage scaledToSize:CGSizeMake(450.0, 450.0)];
    if (self.didFinishTakeMediaCompled) {
        self.didFinishTakeMediaCompled(theImage, info);
    }
    [self dismissPickerViewController:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissPickerViewController:picker];
}


//压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - dealloc

- (void)dealloc {
    self.didFinishTakeMediaCompled = nil;
}

@end
