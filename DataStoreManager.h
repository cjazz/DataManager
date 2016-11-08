//
//  DataStoreManager.h
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Users.h"

#define CC_TABLE_NAME @"Users"
#define COL_ROW_ID @"ID"
#define COL_FIRST @"first"
#define COL_LAST @"last"
#define COL_EMAIL @"email"
#define COL_PASSWORD @"password"
#define COL_STATUS @"status"


@interface DataStoreManager : NSObject

-(instancetype)saveUserToDataStore:(Users *)user;

+(void)createLocalDatabase;
+(sqlite3 *)openDataStore;

+(NSMutableArray *)getAllLocalUsers;

@end
