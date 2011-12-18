//
//  AMCTest.m
//  AutoMagicCoding
//
//   02.09.11.
//  Copyright 2011 Stepan Generalov.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "AMCTest.h"
#import "NSObject+AutoMagicCoding.h"

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
