//
//  AMCTest.h
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface AMCTest : SenTestCase

/** Returns path for testfile, that can be used in many testcases 
 * uses className prefix and given suffix.
 * So the filename will be something like AMCTestSimpleTest.plist
 */
- (NSString *) testFilePathWithSuffix: (NSString *) aSuffix;

- (BOOL) array: (NSArray *) arr1 isEqualTo: (NSArray *) arr2;
- (BOOL) dict: (NSDictionary *) dict1 isEqualTo: (NSDictionary *) dict2;

@end
