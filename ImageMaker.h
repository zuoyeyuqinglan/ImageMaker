//
//  ImageMaker.h
//  MBM
//
//  Created by Guan on 15/11/27.
//  Copyright © 2015年 meibumei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageMaker;

@protocol ImageMakerDelegate <NSObject>

- (void)ImageMakerDidFinishImageMake:(ImageMaker *)ImageMaker editedImage:(UIImage *)editedImage;

- (void)ImageMakerDidCancleImageMake:(ImageMaker *)ImageMaker;

@end

@interface ImageMaker : UIViewController

+ (instancetype)ImageMakerWithImage:(UIImage *)image delegate:(id<ImageMakerDelegate>)delegate;

@property (weak ,nonatomic)id<ImageMakerDelegate> delegate ;

@end
