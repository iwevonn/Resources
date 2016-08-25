//
//  YYFPSLabel.h
//  YYKitExample
//
//  Created by ibireme on 15/9/3.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Show Screen FPS...
 
 The maximum fps in OSX/iOS Simulator is 60.00.
 The maximum fps on iPhone is 59.97.
 The maxmium fps on iPad is 60.0.
 */
@interface YYFPSLabel : UILabel



/* Demo
 
     _fpsLabel = [YYFPSLabel new];
     [_fpsLabel sizeToFit];
     _fpsLabel.frame = CGRectMake(250, 20, 0, 0);
     _fpsLabel.alpha = 0;
     [self.view addSubview:_fpsLabel];
 
 
 
     - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
         if (_fpsLabel.alpha == 0) {
             [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
             _fpsLabel.alpha = 1;
             } completion:NULL];
         }
     }
     
     - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
         if (!decelerate) {
             if (_fpsLabel.alpha != 0) {
                 [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                 _fpsLabel.alpha = 0;
                 } completion:NULL];
             }
         }
     }
     
     - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
     if (_fpsLabel.alpha != 0) {
             [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
             _fpsLabel.alpha = 0;
             } completion:NULL];
         }
     }
     
     - (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
     if (_fpsLabel.alpha == 0) {
             [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
             _fpsLabel.alpha = 1;
             } completion:^(BOOL finished) {
             }];
         }
     }
 */


@end
