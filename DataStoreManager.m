//
//  DataStoreManager.m
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import "DataStoreManager.h"


#define DATABASE_INFO_TABLE_NAME @"Info"
#define DATABASE_VERSION 1
#define DATABASE_VERSION_NAME @"Version"

@class Users;

@interface DataStoreManager ()

+(void)createLocalDatabase;


@property (nonatomic, strong) Users *user;

@end

@implementation DataStoreManager

//TODO:  expand this to receive ds string name
+(sqlite3 *)openDataStore
{
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"users.db"]];
    const char *dbpath = [databasePath UTF8String];
    sqlite3 * db = nil;
    
    if (sqlite3_open(dbpath, &db) == SQLITE_OK)
    {
        //success, return the opened database
        return db;
    }
    else if (db != nil)
    {
        sqlite3_close(db);
    }
    return nil;
}

//TODO:  expand this to receive ds string name
+(void)createLocalDatabase
{
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"users.db"]];

    if ([[NSFileManager defaultManager] fileExistsAtPath: databasePath ] == NO)
    {
        //it doesn't, need to create
        const char *dbpath = [databasePath UTF8String];
        
        sqlite3 * db = nil;
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
        {
            //if we successfully opened
            if(db != nil)
            {
                char *errMsg;
                
                // users table  Add others as necessary
                const char *sql_stmt_data_table = [[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ int, %@ text , %@ text, %@ text, %@ text,%@ text)",
                                                    CC_TABLE_NAME,
                                                    COL_ROW_ID,
                                                    COL_FIRST,
                                                    COL_LAST,
                                                    COL_EMAIL,
                                                    COL_STATUS,
                                                    COL_PASSWORD] cStringUsingEncoding:NSASCIIStringEncoding];
                
                //attempt to create the table
                sqlite3_exec(db, sql_stmt_data_table, NULL, NULL, &errMsg);
                
                
                //create a table to hold the version
                const char *sql_stmt_version_table = [[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ int)", DATABASE_INFO_TABLE_NAME, DATABASE_VERSION_NAME]cStringUsingEncoding:NSASCIIStringEncoding];
                
                //attempt to create the table∑
                sqlite3_exec(db, sql_stmt_version_table, NULL, NULL, &errMsg);
                
                //now insert the version into the right table
                const NSString * const insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", DATABASE_INFO_TABLE_NAME, DATABASE_VERSION_NAME];
                
                sqlite3_stmt * statement;
                //compile the sql statement
                int result = sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &statement, NULL);
                if(result == SQLITE_OK)
                {
                    if(sqlite3_bind_int(statement, 1, DATABASE_VERSION) == SQLITE_OK)
                    {
                        //success
                        if(sqlite3_step(statement) == SQLITE_DONE)
                        {
                          
                        
                        }
                    }
                }
                sqlite3_close(db);
            }
        }
    }
}


-(instancetype)saveUserToDataStore:(Users *)user
{
    self.user = user;
    sqlite3 *db = [DataStoreManager openDataStore];
    
    if (user)
    {
        if(db != nil)
        {
            
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO users (first, last, email, password, status, ID) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%i\")",
                                   self.user.first,
                                   self.user.last,
                                   self.user.email,
                                   self.user.password,
                                   self.user.status,
                                   (int)self.user.ID];
            
            
            sqlite3_stmt * statement;
            
            sqlite3_prepare_v2(db, [insertSQL UTF8String], -1, &statement, NULL);
            
            if(sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"saved user");
            }
            else
            {
                NSLog(@"fail");
            }
            sqlite3_finalize(statement);
            
        }
        sqlite3_close(db);
    }
    return self;
}

+(NSMutableArray *)getAllLocalUsers
{
    sqlite3 *db = [DataStoreManager openDataStore];
    
    NSMutableArray *userCollection;
    
    if (db != nil)
    {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT ID, first, last, email, password, status FROM users"];
        
        sqlite3_stmt *statement;
        
        int result = sqlite3_prepare_v2(db, [selectSQL UTF8String], -1, &statement, NULL);
        
        if (result == SQLITE_OK)
        {
            userCollection = [[NSMutableArray alloc] init];
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                Users *usr = [[Users alloc] init];
                
                int index = 0;
                usr.ID = (NSInteger)sqlite3_column_int64(statement, index);
                index ++; //advance to next column ->
                
                const char * text = (const char * const)sqlite3_column_text(statement, index);
                if (text)
                {
                    usr.first = [NSString stringWithUTF8String: text];
                }
                index ++; //advance to next column ->
                
                text = (const char * const)sqlite3_column_text(statement, index);
                if (text)
                {
                    usr.last = [NSString stringWithUTF8String: text];
                }
                index ++; //advance to next column ->
                
                text = (const char * const)sqlite3_column_text(statement, index);
                if (text)
                {
                    usr.email = [NSString stringWithUTF8String: text];
                }
                index ++; //advance to next column ->
                
                text = (const char * const)sqlite3_column_text(statement, index);
                if (text)
                {
                    usr.password= [NSString stringWithUTF8String: text];
                }
                index ++; //advance to next column ->
                
                text = (const char * const)sqlite3_column_text(statement, index);
                if (text)
                {
                    usr.status= [NSString stringWithUTF8String: text];
                }
                index ++; //advance to next column ->
                
                [userCollection addObject: usr];
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(db);
    return userCollection;
}


@end
