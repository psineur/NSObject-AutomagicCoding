//
//  AMCTest.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AMCTest.h"

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

@end
