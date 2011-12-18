//
//  FooWithSctructs.m
//  AutoMagicCoding-iOS
//
//   04.09.11.
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

#import "FooWithSctructs.h"
#import "NSObject+AutoMagicCoding.h"

NSString *NSStringFromCustomStruct(CustomStruct custom)
{
    return [NSString stringWithFormat:@"ui=%d, f=%f, d=%f, i=%d", custom.ui, custom.f, custom.d, custom.i];
}

CustomStruct CustomStructFromNSString(NSString *string)
{
    CustomStruct result;
    
    NSArray *components = [string componentsSeparatedByString:@", "];
    for (NSString *component in components)
    {
        NSArray *keyValue = [component componentsSeparatedByString:@"="];
        if ([keyValue count] > 1)
        {
            NSString *key = [keyValue objectAtIndex: 0];
            NSString *value = [keyValue objectAtIndex:1];
            
            if ([key isEqualToString:@"ui"])
            {
                result.ui = [value integerValue];
            }
            else if ([key isEqualToString:@"f"])
            {
                result.f = [value floatValue];
            }
            else if ([key isEqualToString:@"d"])
            {
                result.d = [value doubleValue];
            }
            else if ([key isEqualToString:@"i"])
            {
                result.i = [value integerValue];
            }
        }
    }
    
    return result;
}

@implementation FooWithSctructs

@synthesize rect = _rect, point = _point, size = _size;
@synthesize customStruct = _customStruct;

+ (BOOL) AMCEnabled
{
    return YES;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark Custom Struct Support

- (NSString *) AMCEncodeStructWithValue: (NSValue *) structValue withName: (NSString *) structName
{
    if ([structName isEqualToString: @"CustomStruct" ])
    {
        CustomStruct custom;
        [structValue getValue: &custom]; 
        
        return NSStringFromCustomStruct(custom);
    }
    
    return [super AMCEncodeStructWithValue: structValue withName: structName];
}

- (NSValue *) AMCDecodeStructFromString: (NSString *)value withName: (NSString *) structName
{
    if ([structName isEqualToString: @"CustomStruct" ])
    {
        CustomStruct custom = CustomStructFromNSString(value);
        return [NSValue valueWithBytes: &custom objCType:@encode(CustomStruct)];
    }
    
    return [super AMCDecodeStructFromString: value withName: structName];
}

@end
