//
//  Users.h
//  DataManager
//
//  Created by Adam Chin on 6/1/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Users : NSObject

@property (nonatomic, copy) NSString *first;
@property (nonatomic, copy) NSString *last;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) NSInteger ID;

-(instancetype)initWithPayload:(NSDictionary *)payload;

@end
