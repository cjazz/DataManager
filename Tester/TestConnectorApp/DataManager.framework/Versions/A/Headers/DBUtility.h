//
//  DBUtility.h
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//
//  Database Utility

#import <Foundation/Foundation.h>

@interface DBUtility : NSObject

+(NSString *)makeQueryFromDictionary:(NSDictionary *)receivedDict;
+(NSString *)makeQueryStringWithKeyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray;

@end
