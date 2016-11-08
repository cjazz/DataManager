//
//  DBUtility.m
//  DataManager
//
//  Created by Adam Chin on 5/31/15.
//  Copyright (c) 2015 Adam Chin. All rights reserved.
//

#import "DBUtility.h"

@interface DBUtility ()

@end

@implementation DBUtility

// currently makeQueryFromDictionary, and  makeQueryStringWithKeyArray are unused
+(NSString *)makeQueryFromDictionary:(NSDictionary *)receivedDict
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

+(NSString *)makeQueryStringWithKeyArray:(NSArray *)keyArray valueArray:(NSArray *)valueArray
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
        
        if (valueIndex == valueCount-1)
        {
            [workString appendString:[NSString stringWithFormat:@"\%@",valueString]];
        }
        else
        {
            [workString appendString:[NSString stringWithFormat:@"\%@,",valueString]];
        }
        valueIndex++;
    }
    
    [workString appendString:@")\""];
    
    return workString;
}



@end
