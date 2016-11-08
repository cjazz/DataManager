# Data Manager
Data Manager Framework

This Framework includes:

DataStoreManager

    SqlLite client store for simple local storage - See "SqlLite_Install_Instructions"
    DBUtility with two convenience methods:

        +(NSString *)makeQueryFromDictionary:(NSDictionary *)receivedDict;
        +(NSString *)makeQueryStringWithKeyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray;

DataManagerAPI
    
    -(NSURLSessionTask *)getUsersAndStoreLocallyWithCompletion:(void (^)(NSArray *response, NSError *error))completion;

    -(NSURLSessionTask *)createUserAccountForUser:(Users *)user withCompletion:(void(^)(NSDictionary *resopnse, NSError *error))completion;

    -(NSURLSessionTask *)getUsersWithCompletion:(void(^)(NSArray *response, NSError *error))completion;

    -(NSURLSessionTask *)authenticateWithEmail:(NSString *)email andPassword:(NSString *)password withCompletion:(void(^)(NSDictionary *response, NSError *error))completion;

This example calls a locally installed web service with the following methods:

    getUsers.php
    signup.php
    authenticateuser.php

Also these are installed and running here:  @"http://localhost:8888/rest/"


The resulting generated framework can be tested with the app in the "Tester" folder after replacing the framework generated from DataManager.
