//
//  DataManagerAPI.m
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//
//
//


#import "DataManagerAPI.h"
#import "DBUtility.h"
#import "DataStoreManager.h"
//#import "Users.h"

// set these and forget them for the build
NSString *const DataManager_TestHost = @"localhost";

NSString *const DataManager_ProdHost = @"tbd";

NSString *const DataManager_BaseURL = @"http://localhost:8888/rest/";

// DreamFactory constants - perhaps set up an environment flag for switching
// Note: DreamFactory path is in a different location than http://localhost:8888:/rest/


NSString *const DataManager_AppName = @"add_ios";
NSString *const DataManager_SessionID = @"SessionId";

NSString *const DataManager_Email = @"UserEmail";
NSString *const DataManager_Password = @"UserPassword";
NSString *const DataManager_ContainerName = @"applications";
NSString *const DataManager_FolderName = @"uploaded_files";


// PHP WEB METHOD NAMES
//NSString *const AuthenticateUsernamePassword = @"AuthenticateUsernamePassword";
NSString *const GetUsers = @"getUsers.php";
NSString *const SignupUser = @"signup.php";
NSString *const AuthenticateUser = @"authenticateUser.php";

@class DMAImageData;
@class DataStoreManager;
@class Users;

@interface DataManagerAPI ()

@property (copy, nonatomic) NSURLSession *session;
@property (copy, nonatomic) NSURLSession *phpSession;

@property (nonatomic, strong) NSString *baseAPIHost;

-(void)sessionSetup;

-(NSURLSessionTask *)executeTaskWithURLRequest:(NSURLRequest *)request
                                withCompletion:(void(^)(NSDictionary *responseData, NSError *error))completion;

-(NSURLSessionTask *)executeGroupTaskWithURLRequest:(NSURLRequest *)request
                                     withCompletion:(void (^)(NSArray * responseData, NSError *error))completion;

@end

@implementation DataManagerAPI

static DataManagerAPI *_apiManager;
static id _sem;
static NSTimeInterval _timeout = 60;
static BOOL enableProdURL = NO;

-(NSURLSessionTask *)authenticateWithEmail:(NSString *)email
                               andPassword:(NSString *)password
                            withCompletion:(void(^)(NSDictionary *, NSError *))completion
{
    
    NSString *URLString = [NSString stringWithFormat:@"%@/%@",DataManager_BaseURL,AuthenticateUser];
    NSURL *url = [NSURL URLWithString:URLString];
    
    [self sessionFormSetup];
    
    NSString *dataString = [NSString stringWithFormat:@"email=%@&password=%@",email,password];
    NSString *cleansed = [dataString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    urlRequest.HTTPBody = [cleansed dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self executeTaskWithURLRequest:urlRequest
                            withCompletion:^(NSDictionary *responseData, NSError *error) {
                                if (completion)
                                {
                                    completion (responseData,error);
                                }
                            }];
}


-(instancetype)init
{
    if (self = [super init])
    {
        _sem = [[NSObject alloc]init];
        
        // set these for the target service environment
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{@"Content-Type": @"application/json",
                                                @"Accept":@"application/json"};
        [self setBaseHostURL];
        [DataStoreManager createLocalDatabase];
        
    }
    return self;
}

+(DataManagerAPI *)instance
{
    @synchronized(_sem)
    {
        if (_apiManager == nil)
        {
            _apiManager = [[DataManagerAPI alloc] init];
        }
        return _apiManager;
    }
}

#pragma mark - Setup & configuration methods

-(void)sessionSetup
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{@"Content-Type": @"application/json",
                                            @"Accept":@"application/json"};
    
    self.session = [NSURLSession sessionWithConfiguration:configuration];
}

-(void)sessionAddSetup
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:configuration];
}

-(void)sessionFormSetup
{
    // Used for passing multiple values to the server
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{@"Content-Type": @"application/x-www-form-urlencoded",
                                            @"Accept":@"application/json"};
    self.session = [NSURLSession sessionWithConfiguration:configuration];

}


- (BOOL)isProductionURLEnabled
{
    return enableProdURL;
}

- (void)setProductionURLEnabled:(BOOL)enableProductionURL
{
    enableProdURL = enableProductionURL;
    [self setBaseHostURL];
}

-(void)setBaseHostURL
{
    if (enableProdURL == TRUE)
    {
        self.baseAPIHost = DataManager_ProdHost;
    }
    else
    {
        self.baseAPIHost = DataManager_TestHost;
    }
}

- (NSTimeInterval)requestTimeout
{
    return _timeout;
}

- (void)setTimeout:(NSTimeInterval)timeout
{
    _timeout = timeout;
}

#pragma Mark - Web service primary completion methods NSURLSessionDataTask

-(NSURLSessionTask *)executeTaskWithURLRequest:(NSURLRequest *)request
                                withCompletion:(void(^)(NSDictionary *responseData, NSError *error))completion
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
              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                  
                  completion(nil, error);
                  
              }];
          }
          return;
      }
      else
      {
          NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
          
          if (completion)
          {
              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                  completion(responseData,error);
              }];
          }
      }
    }];
    [task resume];
    return task;
}

-(NSURLSessionTask *)executeGroupTaskWithURLRequest:(NSURLRequest *)request
                                     withCompletion:(void (^)(NSArray * responseData, NSError *error))completion
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
              [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                  
                  completion(nil, error);
                  
              }];
          }
          return;
      }
      else if (data !=nil)
      {
          
          NSError *error = nil;
          
          NSArray *responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
          
          if (!responseData)
          {
              return;
          }
          else
          {
              if (completion)
              {
                  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                      completion(responseData,error);
                  }];
              }
          }
      }
    }];
    [task resume];
    return task;
}

-(NSURLSessionDownloadTask *)executeDownloadTaskWithURLRequest:(NSURLRequest*)request
                                        withCompletion:(void(^)(NSDictionary *responseData, NSError *error))completion
{
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
       
        // download the file
        
    }];

    return task;
    
}


#pragma mark - Public DataManager API methods

-(NSURLSessionTask *)createUserAccountForUser:(Users *)user withCompletion:(void(^)(NSDictionary *, NSError *))completion
{

    NSString *URLString = [NSString stringWithFormat:@"%@/%@",DataManager_BaseURL,SignupUser];
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    [self sessionAddSetup];
    
    // TO DO Above in these fields need to filter out the single quotes before they get into the message
    //  because they fail miserably!  Ex:  NSString *status = @"What chillin"  add a " ' ". and it will barf.
    
    NSString *dataString = [NSString stringWithFormat:@"first=%@&last=%@&email=%@&password=%@&status=%@",
                            user.first,
                            user.last,
                            user.email,
                            user.password,
                            user.status];
    
    NSString *cleansed = [dataString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = [cleansed dataUsingEncoding:NSUTF8StringEncoding];
    
    
    return [self executeTaskWithURLRequest:urlRequest withCompletion:^(NSDictionary *responseData, NSError *error) {
    
        if (completion)
        {
            completion (responseData,error);
        }
    }];
}

-(NSURLSessionTask *)getUsersWithCompletion:(void(^)(NSArray *, NSError *))completion
{
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",DataManager_BaseURL,GetUsers];
    
    NSLog(@"-->> URL: %@",URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    
    if (!self.session)
    {
        [self sessionSetup];
    }
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];

    return [self executeGroupTaskWithURLRequest:urlRequest withCompletion:^(NSArray *responseData, NSError *error) {
        if (completion)
        {
            completion (responseData,error);
        }
    }];
}

-(NSURLSessionTask *)getUsersAndStoreLocallyWithCompletion:(void (^)(NSArray *, NSError *))completion
{
    NSString *URLString = [NSString stringWithFormat:@"%@/%@",DataManager_BaseURL,GetUsers];
    NSURL *url = [NSURL URLWithString:URLString];
    
    if (!self.session)
    {
        [self sessionSetup];
    }
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    return [self executeGroupTaskWithURLRequest:urlRequest withCompletion:^(NSArray *responseData, NSError *error) {
        
        if (completion)
        {
            [responseData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                // perform the operation to write to the database here with each iteration of the
                // returned array
                if (obj)
                {
                    Users *user = [[Users alloc]initWithPayload:obj];
                    
                    DataStoreManager *dsm = [[DataStoreManager alloc] init];
                    [dsm saveUserToDataStore:user];
                }
            }];
            completion (responseData,error);
        }
    }];
}



@end
