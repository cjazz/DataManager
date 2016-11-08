//
//  DataManagerAPI.h
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMAImageData.h"
#import "DataStoreManager.h"
#import "Users.h"

@interface DataManagerAPI : NSObject

+(DataManagerAPI *)instance;

/**
 Convenience check to evaluate if production URL is set. Default is set to False and the system will use the Test URL
 */
@property (nonatomic, getter = isProductionURLEnabled) BOOL productionURLEnabled;

/**
 The timeout for requests in seconds.
 Default is 60 seconds.
 */
@property(nonatomic) NSTimeInterval requestTimeout;


-(NSURLSessionTask *)getUsersAndStoreLocallyWithCompletion:(void (^)(NSArray *response, NSError *error))completion;

-(NSURLSessionTask *)createUserAccountForUser:(Users *)user
                               withCompletion:(void(^)(NSDictionary *resopnse, NSError *error))completion;

-(NSURLSessionTask *)getUsersWithCompletion:(void(^)(NSArray *response, NSError *error))completion;

-(NSURLSessionTask *)authenticateWithEmail:(NSString *)email
                               andPassword:(NSString *)password
                            withCompletion:(void(^)(NSDictionary *response, NSError *error))completion;


@end
