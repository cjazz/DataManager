//
//  Utility.m
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import "Utility.h"

@implementation Utility

// can be used for a simple form of encryption

+(NSArray *)convertStringToByteArray:(NSString *)string
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    const unsigned char * bytes = [stringData bytes];
    
    const NSUInteger length = [stringData length];
    NSMutableArray * const byteData = [[NSMutableArray alloc]initWithCapacity:length];
    
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    for (int i = 0; i < length;)
    {
        byteChars[0] = bytes[i++];
        byteChars[1] = bytes[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [byteData addObject:[NSNumber numberWithUnsignedLong:wholeByte]];
    }
    return byteData;
}

@end
