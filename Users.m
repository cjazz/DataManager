//
//  Users.m
//  DataManager
//
//  Created by Adam Chin on 6/1/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import "Users.h"

@interface Users ()

@end


@implementation Users

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.first = @"";
        self.last = @"";
        self.email = @"";
        self.password = @"";
        self.status = @"";
        self.ID = 0;
    }
    return self;
}


-(instancetype)initWithPayload:(NSDictionary *)payload
{
    self.first = [payload valueForKey:@"first"];
    self.last = [payload valueForKey:@"last"];
    self.email = [payload valueForKey:@"email"];
    self.password = [payload valueForKey:@"password"];
    self.status = [payload valueForKey:@"status"];
    self.ID = (NSInteger)[payload valueForKey:@"ID"];
    return self;
}

@end
