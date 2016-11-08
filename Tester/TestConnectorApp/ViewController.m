//
//  ViewController.m
//  TestConnectorApp
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import "ViewController.h"
#import <DataManager/DataManager.h>
#import <sqlite3.h>

#define ADATABASE_INFO_TABLE_NAME @"Info"
#define ADATABASE_VERSION 1
#define ADATABASE_VERSION_NAME @"Version"

#define CCC_TABLE_NAME @"Users"
#define CCOL_ROW_ID @"id"
#define CCOL_FIRST @"first"
#define CCOL_LAST @"last"
#define CCOL_PASSWORD @"password"



@interface ViewController ()

@property (nonatomic, copy) NSDictionary *receivedDictonary;
@property (copy, nonatomic) NSURLSession *session;
@property (nonatomic, copy) NSData *data;


@end

@implementation ViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // un-comment these examples of using the framework
    
    [self authenticateUser];

    
}

#pragma mark - calling methods to datamanager framework

-(void)authenticateUser
{
    /* example for authenticating user from web  */
    [[DataManagerAPI instance]authenticateWithEmail:@"ag@gmail.com" andPassword:@"bass" withCompletion:^(NSDictionary *response, NSError *error) {
        
        if (error)
        {
        }
        
        if (response)
        {
            int responseQualfier = [[response objectForKey:@"status"] intValue];
            
            if (responseQualfier)
            {
                NSLog(@"pass");
            }
            else
            {
                NSLog(@"fail");
            }
            
        }
        
    }];
}


-(void)getAllUsersFromWebHost
{
    /* example for getting all users from web store */
    
    [[DataManagerAPI instance]getUsersWithCompletion:^(NSArray *response, NSError *error) {
        NSLog(@"users: %@",response);
    }];
}

-(void)getAllLocalUsers
{
    /* Example for Getting all users from local data store */
    
    NSArray *users = [DataStoreManager getAllLocalUsers];
    NSLog(@"%@",users);
    
    [users enumerateObjectsUsingBlock:^(Users *obj, NSUInteger idx, BOOL *stop) {
        
        Users *user = obj;
        NSLog(@"ID %ld\nFirst %@\nLast %@\nEmail %@\n Password %@\n Status %@",(long)user.ID, user.first, user.last, user.email, user.password, user.status);
        
    }];
}

-(void)saveLocalUser
{
/* Example for saving a record to the local data store */
    NSDictionary *userDict = @{
                               @"ID":@"512552",
                               @"first":@"jeff",
                               @"last":@"smith",
                               @"email":@"js@gmail",
                               @"password":@"hello",
                               @"status":@"coding"
                               };
    
    
    Users *newuser = [[Users alloc] initWithPayload:userDict];
    DataStoreManager *dm = [[DataStoreManager alloc] init];
    [dm saveUserToDataStore:newuser];
  
}

-(void)createNewUser
{
    
/* Example for Creating a new user on the web host */
    
    NSDictionary *newUserDict = @{
                                  @"first":@"NewPerson",
                                  @"last":@"LastName",
                                  @"email":@"np@gmail",
                                  @"password":@"letmein",
                                  @"status":@"coding"
                                  };
    
    Users *newUser = [[Users alloc] initWithPayload:newUserDict];
    
    [[DataManagerAPI instance]createUserAccountForUser:newUser withCompletion:^(NSDictionary *resopnse, NSError *error) {
        
        NSLog(@"%@",resopnse);
        
    }];
}

-(void)saveUserToDataStore:(NSString *)queryString
{
    NSLog(@"saveUser Query %@",queryString);
    sqlite3 *db = [ViewController openDataStore];
    if(db != nil)
    {
        if (queryString.length)
        {
            NSString *insertSQL = queryString;
            
            const char *insert_stmt = [insertSQL UTF8String];
            
            sqlite3_stmt * statement;
            
            sqlite3_prepare_v2(db, insert_stmt, -1, &statement, NULL);
            
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"success");
            }
            else
            {
                NSLog(@"fail");
            }
//            sqlite3_finalize(statement);
        }
    }
    sqlite3_close(db);
}




-(NSURLSessionTask *)executeTaskWithURLRequest:(NSURLRequest *)request
                                withCompletion:(void(^)(NSData *responseData, NSError *error))completion
{
    
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (error)
          {
#ifdef DEBUG
              NSLog(@"%@",[error localizedDescription]);
#endif
              
              if (completion)
              {
                  completion(nil,error);
              }
              return;
          }
          else
          {
             
              
              if (completion)
              {
                  completion(data,error);
              }
          }
      }];
    [task resume];
    return task;
}



-(void)loginUser:(void(^)(NSData *, NSError *error))complete
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // this is key:  anytime you're passing more than 1 value, it's considered a form, so the below is necessary
    configuration.HTTPAdditionalHeaders = @{@"Content-Type": @"application/x-www-form-urlencoded",
                                            @"Accept":@"application/json"};
    
    
    // Setup a session object
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    //    NSString *URLString = @"http://localhost:8888/rest/pogo.php";
    //    NSURL *url = [NSURL URLWithString:URLString];
    //
    //    NSLog(@"UrlString: %@",URLString);
    //    NSLog(@"URL: %@",url);
    
    NSString *email = @"styler@gmail.com";
    NSString *password = @"hello";
    
    NSString *dataString = [NSString stringWithFormat:@"email=%@&password=%@",email,password];
    NSString *cleansed = [dataString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    [components setScheme:@"http"];
    [components setHost:@"localhost"];
    [components setPort:@8888];
    [components setPath:@"/rest/authenticateUser.php"];
    
    NSLog(@"components url: %@",components.URL);
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[components URL]];
    urlRequest.HTTPBody = [cleansed dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPMethod = @"POST";
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      if (error)
                                      {
                                          NSLog(@"%@",[error localizedDescription]);
                                      }
                                      if (response)
                                      {
                                          NSLog(@"URL RESPONSE: %@",response);
                                      }
                                      if (data)
                                      {
                                          if (complete)
                                          {
                                              complete(data,error);
                                          }
                                      }
                                  }];
    [task resume];
}

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



//-(void)createDatabase
//{
//    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"users.db"]];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath: databasePath ] == NO)
//    {
//        //it doesn't, need to create
//        const char *dbpath = [databasePath UTF8String];
//        
//        sqlite3 * db = nil;
//        
//        if (sqlite3_open(dbpath, &db) == SQLITE_OK)
//        {
//            //if we successfully opened
//            if(db != nil)
//            {
//                char *errMsg;
//                
//                const char *sql_stmt_data_table = [[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ int, %@ text , %@ text, %@ text)",
//                                                    CCC_TABLE_NAME,
//                                                    CCOL_ROW_ID,
//                                                    CCOL_FIRST,
//                                                    CCOL_LAST,
//                                                    CCOL_PASSWORD] cStringUsingEncoding:NSASCIIStringEncoding];
//                
//                //attempt to create the table
////                sqlite3_exec(db, sql_stmt_data_table, NULL, NULL, &errMsg);
//                
//                if (sqlite3_exec(db, sql_stmt_data_table, NULL, NULL, &errMsg) != SQLITE_OK)
//                {
//                    NSLog(@"error creating db");
//                }
//                
//                
//                //now close the db we opened
//                sqlite3_close(db);
//                
//            }
//        }
//    }
//}


-(NSString *)prepareDictionaryForQuery:(NSDictionary *)receivedDict
{
    
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
    
    // 2. grab the key and value from each Dict row and add them to the arrays
    
    [receivedDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         NSString *keyString = [NSString stringWithFormat:@"%@",key];
         
         [keyArray addObject:keyString];
         
         NSString *valueString = [NSString stringWithFormat:@"%@",obj];
         
         [valueArray addObject:valueString];
         
     }];
    
    // Because the arrays need to be kept in parrallel th use of a permutation array is in order
    //
    // http://stackoverflow.com/questions/12436927/sorting-two-nsarrays-together-side-by-side
    
    // need a permutation array to manage 2 of these
    NSMutableArray *p = [NSMutableArray arrayWithCapacity:keyArray.count];
    
    for (NSUInteger i = 0 ; i != keyArray.count ; i++)
    {
        [p addObject:[NSNumber numberWithInteger:i]];
    }
    
    [p sortWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        // Modify this to use [first objectAtIndex:[obj1 intValue]].name property
        NSString *lhs = [keyArray objectAtIndex:[obj1 intValue]];
        // Same goes for the next line: use the name
        NSString *rhs = [keyArray objectAtIndex:[obj2 intValue]];
        return [lhs compare:rhs];
    }];
    NSMutableArray *sortedFirst = [NSMutableArray arrayWithCapacity:keyArray.count];
    NSMutableArray *sortedSecond = [NSMutableArray arrayWithCapacity:keyArray.count];
    [p enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger pos = [obj intValue];
        [sortedFirst addObject:[keyArray objectAtIndex:pos]];
        [sortedSecond addObject:[valueArray objectAtIndex:pos]];
    }];
    
    //    NSLog(@"sorted first %@", sortedFirst);
    //    NSLog(@"sorted second %@", sortedSecond);
    //
    keyArray = nil;
    valueArray = nil;
    // since I like the name of the first set of NSMutableArrays......:)
    keyArray = sortedFirst;
    valueArray = sortedSecond;
    
    //    NSString *executableQueryString = [self makeQueryStringWithKeyArray:keyArray valueArray:valueArray];
    
    return [self makeQueryStringWithKeyArray:keyArray valueArray:valueArray];
}
-(NSString *)makeQueryStringWithKeyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray
{
    /*
     Note these two for loops below should be replaced with
     
     enumerateKeysAndObjectsUsingBlock - just more modern
     
     */
    NSMutableString *workString = [[NSMutableString alloc] initWithString:@"@\"insert into users ("];
    
    // key string
    NSUInteger keyindex = 0;
    NSUInteger keycount = keyArray.count;
    
    for (id element in keyArray)
    {
        NSString *keyString = [NSString stringWithFormat:@"%@",element];
        
        if (keyindex == keycount-1)
        {
            [workString appendString:[NSString stringWithFormat:@"%@",keyString]];
        }
        else
        {
            [workString appendString:[NSString stringWithFormat:@"%@, ",keyString]];
        }
        keyindex++;
    }
    // value string
    [workString appendString:@") values("];
    
    NSUInteger valueIndex = 0;
    NSUInteger valueCount = valueArray.count;
    
    for (id object in valueArray)
    {
        NSString *valueString = [NSString stringWithFormat:@"%@",object];

       
       // NSString *someotherString = [NSString stringWithFormat: @"INSERT INTO CONTACTS (name, address, phone) VALUES (\"%@\", \"%@\", \"%@\")", @"One", @"two", @"three"];
        
        
        if (valueIndex == valueCount-1)
        {
            [workString appendString:[NSString stringWithFormat:@"\"%@\"",valueString]];
        }
        else
        {
            [workString appendString:[NSString stringWithFormat:@"\"%@\",",valueString]];
        }

//        if (valueIndex == valueCount-1)
//        {
//            [workString appendString:[NSString stringWithFormat:@"'%@'",valueString]];
//        }
//        else
//        {
//            [workString appendString:[NSString stringWithFormat:@"'%@',",valueString]];
//        }
        valueIndex++;
    }
    
    [workString appendString:@")\""];
    
    return workString;
}

-(void)downloadDataFromURLWithCompletionHandler:(void (^)(NSData *, NSError *))completionHandler
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Setup a session object
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // create a data task
    
    NSString *URLString = [NSString stringWithFormat:@"http://localhost:8888/getUsers.php"];
    NSURL *url = [NSURL URLWithString:URLString];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data,
                                                                                  NSURLResponse *response,
                                                                                  NSError *error){
        if (error!=nil)
        {
            // if any error occurred then jsut display the description
            NSLog(@"%@",[error localizedDescription]);
        }
        else
        {
            // If no error occurs, check the HTTP status code.
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
            
            // If it's other than 200, then show it on the console.
            if (HTTPStatusCode != 200)
            {
                NSLog(@"HTTP status code = %ld", (long)HTTPStatusCode);
            }
            
            // Call the completion handler with the returned data on the main thread.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler(data,error);
            }];
        }
    }];
    
    [task resume];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(sqlite3 *)openDataStore
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


-(NSMutableArray *)getUsers
{
    sqlite3 *db = [self openDataStore];
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
