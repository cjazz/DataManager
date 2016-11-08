//
//  DMAImageData.m
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import "DMAImageData.h"

@implementation DMAImageData

-(instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

-(instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        self.imageToTransform = image;
    }
    return self;
}

-(void)resizeImageByAmount:(float)amount
{
    if (self.imageToTransform)
    {
        CGSize newSize = CGRectMake(0, 0, self.imageToTransform.size.width * amount, self.imageToTransform.size.height * amount).size;
        UIGraphicsBeginImageContext(newSize);
        [self.imageToTransform drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.imageToTransform = newImage;
    }
}

- (NSString *)base64Image
{
    if (self.imageToTransform)
    {
        return [UIImageJPEGRepresentation(self.imageToTransform, 1.0) base64EncodedStringWithOptions:kNilOptions];
    }
    return nil;
}

- (NSArray *)byteImage
{
    if (self.imageToTransform)
    {
        NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(self.imageToTransform, 0.5)];
        const unsigned char * bytes = [imageData bytes];
        NSUInteger length = [imageData length];
        NSMutableArray *byteData = [[NSMutableArray alloc]initWithCapacity:length];
        
        for(int i = 0; i < length; i++)
        {
            [byteData addObject:[NSNumber numberWithUnsignedChar: bytes[i]]];
        }
        return byteData;
    }
    return nil;
}


@end
