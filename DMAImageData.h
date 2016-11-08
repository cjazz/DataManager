//
//  DMAImageData.h
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DMAImageData : NSObject

@property (strong, nonatomic) UIImage *imageToTransform;

-(instancetype)initWithImage:(UIImage *)image;

- (void)resizeImageByAmount:(float)amount;
- (NSString*)base64Image;
- (NSArray*)byteImage;


@end
