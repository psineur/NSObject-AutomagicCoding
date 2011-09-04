//
//  FooWithMutableCollections.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FooWithMutableCollections.h"

@implementation FooWithMutableCollections

@synthesize array = _array;
@synthesize dict = _dict;

+ (BOOL) AMCEnabled
{
    return YES;
}

- (void) dealloc
{
    self.array = nil;
    self.dict = nil;
    
    [super dealloc];
}

@end
