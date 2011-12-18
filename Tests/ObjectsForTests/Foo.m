//
//  Foo.m
//  AutoMagicCoding
//
//   31.08.11.
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

#import "Foo.h"
#import "NSObject+AutoMagicCoding.h"

@implementation Foo

@synthesize integerValue = _integerValue;
@synthesize publicBar = _publicBar;

+ (BOOL) AMCEnabled
{
    return YES;
}

- (id)initWithDictionaryRepresentation: (NSDictionary *) aDict
{
    self = [super initWithDictionaryRepresentation: aDict];
    if (self) {
        [_publicBar retain];
    }
    
    return self;
}

- (AMCFieldType) AMCFieldTypeForValueWithKey: (NSString *) aKey
{
    if ([aKey isEqualToString:@"privateBar"])
    {
        return kAMCFieldTypeCustomObject;
    }
    
    return [super AMCFieldTypeForValueWithKey: aKey];
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    NSArray *array = [super AMCKeysForDictionaryRepresentation];
    return [array arrayByAddingObject:@"privateBar"];
}

- (void) dealloc
{
    [_publicBar release]; 
    _publicBar = nil;
    
    [super dealloc];
}

- (BOOL) isEqual:(id)object
{
    if ([object isMemberOfClass:[self class]])
    {
        Foo *other = (Foo *)object;
        if(self.integerValue == other.integerValue)
        {
            BOOL equal = YES;
            
            if (self.publicBar != other.publicBar)
            {
                if (![self.publicBar isEqual: other.publicBar])
                    equal = NO;
            }
            
            if ( _privateBar != [other valueForKey: @"privateBar" ])
            {
                if (![_privateBar isEqual:  [other valueForKey: @"privateBar" ]])
                    equal = NO;
            }
                
            
            return equal;
        }
        
        return NO;
    }
    
    return [super isEqual: object];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ integerValue={%d}, publicBar = %@, pribateBar = %@",
            [self class], 
            self.integerValue,
            self.publicBar,
            _privateBar ];
}

@end
