//
//  ViewController.m
//  PhotoDemo
//
//  Created by DYL on 16/3/20.
//  Copyright © 2016年 iwevon. All rights reserved.
//

#import "ViewController.h"
#import "CapturePictureTool.h"

@interface ViewController ()

@property (nonatomic, strong) CapturePictureTool *capturePictureTool;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:btn];
        
        btn.frame = CGRectMake(100, 100, 100, 100);
        btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(btnClick) forControlEvents:(UIControlEventTouchUpInside)] ;
        
        btn;
    });
    
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.view addSubview:imageView];
        imageView.frame = CGRectMake(300, 100, 200, 200);
        
        imageView;
    });
    
    self.textView = ({
        UITextView *textView = [[UITextView alloc] init];
        [self.view addSubview:textView];
        textView.frame = CGRectMake(100, 400, 200, 200);
        
        textView;
    });
}
                        
- (void)btnClick {

    self.capturePictureTool =  [CapturePictureTool capturePictureWithViewController:self compled:^(UIImage *image, NSDictionary *editingInfo) {
        NSLog(@"%@", image);
        
        self.imageView.image = image;
        self.textView.text = [editingInfo description];
    }];
    
    [self.capturePictureTool show];

}

// 当屏幕发生旋转的时候会执行该方法
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.capturePictureTool dissMiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
