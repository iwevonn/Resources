//
//  CapturePictureTool.h
//  SmartHome
//
//  Created by iwevon on 16/3/21.
//  Copyright © 2016年 周秋阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CapturePictureTool : NSObject

+ (instancetype)capturePictureWithViewController:(UIViewController *)viewController compled:(void(^)(UIImage *image, NSDictionary *editingInfo))compled;

- (void)show;

- (void)dissMiss;

@end
