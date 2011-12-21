//
//  Bar.m
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

#import "Bar.h"

@implementation Bar

@synthesize someString = _someString;

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

- (BOOL) isEqual:(id)object
{
    if ([object isMemberOfClass:[self class]])
    {
        Bar *other = (Bar *)object;
        if([self.someString isEqualToString: other.someString])
            return YES;
        
        return NO;
    }
    
    return [super isEqual: object];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ someString={%@}",[self class], self.someString];
}

@end


@implementation BarBar

@synthesize someOtherString = _someOtherString;


@end

@implementation BarBarBar

@synthesize thirdString = _thirdString;

@end
