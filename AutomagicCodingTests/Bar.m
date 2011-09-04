//
//  Bar.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
