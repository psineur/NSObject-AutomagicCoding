//
//  AMCExceptionsTest.h
//  AutomagicCoding
//
//  03.12.11.
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

#import "AMCExceptionsTest.h"
#import "NSObject+AutomagicCoding.h"

@implementation AMCExceptionsTest

// All code under test must be linked into the Unit Test bundle
- (void)testEncodeCrash
{
    BOOL crashed = NO; //< should be YES to pass the test.
    
    BadClass *object = [BadClass new];
    @try {
        [object dictionaryRepresentation];
    }
    @catch (NSException *exception) {
        crashed = YES;
        STAssertTrue([[exception name] isEqualToString: AMCEncodeException], 
                     @"Wrong exception name, should be %@ but is %@ instead", AMCEncodeException, [exception name] );
    }
    
    STAssertTrue(crashed, @"");
}

- (void)testDecodeCrash
{
    STFail(@"Not implemented");
}

@end

@implementation BadClass

// Note: structs can't be just ivars - they must be properties.
// This is needed, because AMC uses property runtime info for getting
// structName;
//@synthesize struct = _struct;

+ (BOOL) AMCEnabled
{
    return YES;
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [NSArray arrayWithObjects: @"struct", nil];
}

- (AMCFieldType) AMCFieldTypeForValueWithKey: (NSString *) aKey
{
    if ([aKey isEqualToString:@"struct"])
    {
        return kAMCFieldTypeStructure;
    }
    
    return [super AMCFieldTypeForValueWithKey: aKey];
}


@end
