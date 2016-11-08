//
//  DataManagersTests.m
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DataManager.h"
#import "Users.h"

@class Users;

@interface DataManagersTests : XCTestCase

@end

@implementation DataManagersTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testAuthentication
{
    NSString *email = @"chinjazz@gmail.com"; // get these values from MySQL datastore
    NSString *password = @"bassman";
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"login user from client to host"];

    [[DataManagerAPI instance]authenticateWithEmail:email andPassword:password withCompletion:^(NSDictionary *response, NSError *error) {
        
        if (error != nil)
        {
            XCTAssertNil(error, "Error should not be nil");
        }
        else if (response != nil)
        {
            NSLog(@"PASSED! response data %@",response);
        }
        else
        {
            XCTAssertNotNil(response, "data should not be nil");
        }
        
        [expectation fulfill];
        
    }];
       
    /* wait for the asynchronous block callback was called expectation to be fulfilled
     fail after 5 seconds */
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error)
     {
         // handler is called on _either_ success or failure
         
         if (error != nil)
         {
             XCTFail(@"timeout error: %@", error);
         }
         else
             
         {
             XCTAssert(YES, @"Passed network method pass");
         }
     }];

}
-(void)testCreateUser
{
    Users *aUser = [[Users alloc] init];
    aUser.first = @"bruce";
    aUser.last = @"lee";
    aUser.email = @"bl@yahoo.com";
    aUser.password = @"password";
    aUser.status = @"jkd allday";
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Add User"];
    
    [[DataManagerAPI instance]createUserAccountForUser:aUser withCompletion:^(NSDictionary *resopnse, NSError *error)
    {
       
    if (error != nil)
    {
        XCTAssertNil(error, "Error should not be nil");
    }
    else if (resopnse != nil)
    {
        NSLog(@"response data %@",resopnse);

    }
    else
    {
        XCTAssertNotNil(resopnse, "data should not be nil");
    }
    
        [expectation fulfill];
    }];
    
        [self waitForExpectationsWithTimeout:5
                                     handler:^(NSError *error)
         {
             if (error != nil)
             {
                 XCTFail(@"timeout error: %@", error);
             }
             else
                 
             {
                 XCTAssert(YES, @"Passed network method pass");
             }
         }];
}


-(void)testOnlyGetUsers
{
    
     XCTestExpectation *expectation = [self expectationWithDescription:@"get users from host"];
    
    [[DataManagerAPI instance]getUsersWithCompletion:^(NSArray *response, NSError *error) {
       
        if (error != nil)
        {
            XCTAssertNil(error, "Error should not be nil");
        }
        else if (response != nil)
        {
            NSLog(@"response data %@",response);
            
        }
        else
        {
            XCTAssertNotNil(response, "data should not be nil");
        }
        
        [expectation fulfill];
    }];
 
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error)
     {
         // handler is called on _either_ success or failure
         
         if (error != nil)
         {
             XCTFail(@"timeout error: %@", error);
         }
         else
             
         {
             XCTAssert(YES, @"Passed network method pass");
         }
     }];

    
}

// This is a successful test to retrieve users from the host
-(void)testGetUsers
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"get users from host"];
    
    [[DataManagerAPI instance]getUsersAndStoreLocallyWithCompletion:^(NSArray *response, NSError *error)
    {
        if (error != nil)
        {
            XCTAssertNil(error, "Error should not be nil");
        }
        else if (response != nil)
        {
            NSLog(@"response data %@",response);
            
        }
        else
        {
            XCTAssertNotNil(response, "data should not be nil");
        }
        
        [expectation fulfill];
        
    }];
    
    /* wait for the asynchronous block callback was called expectation to be fulfilled
     fail after 5 seconds */
    
    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error)
    {
        // handler is called on _either_ success or failure

        if (error != nil)
        {
            XCTFail(@"timeout error: %@", error);
        }
        else
            
        {
            XCTAssert(YES, @"Passed network method pass");
        }
    }];
    
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
