//
//  AMCTest.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AMCTest.h"
#import "NSObject+AutomagicCoding.h"

@implementation AMCTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (NSString *) testFilePathWithSuffix: (NSString *) aSuffix
{
    if (!aSuffix)
        aSuffix = @"";
    
    NSString *filename = [NSString stringWithFormat:@"%@%@.plist", [self className], aSuffix ];
    
    NSArray *paths					= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory	= [paths objectAtIndex:0];
	NSString *fullPath				= [documentsDirectory stringByAppendingPathComponent: filename ];
	return fullPath;
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (BOOL) array: (NSArray *) arr1 isEqualTo: (NSArray *) arr2
{
    if (!arr1 || !arr2)
        return NO;
    
    if ([arr1 count] != [arr2 count])
        return NO;
    
    for (NSUInteger i = 0; i < [arr1 count]; ++i)
        if (![[arr1 objectAtIndex: i] isEqual: [arr2 objectAtIndex:i] ] )
            return NO;
    
    return YES;
}

- (BOOL) dict: (NSDictionary *) dict1 isEqualTo: (NSDictionary *) dict2
{
    if (!dict1 || !dict2)
        return NO;
    
    if ([dict1 count] != [dict2 count])
        return NO;
    
    for (NSString *key in dict1)
    {
        id value1 = [dict1 objectForKey: key];
        id value2 = [dict2 objectForKey: key];
        if ( ![value1 isEqual: value2] )
            return NO;
    }
    
    return YES;
}

@end
