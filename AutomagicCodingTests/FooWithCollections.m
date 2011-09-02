//
//  FooWithCollections.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FooWithCollections.h"

@implementation FooWithCollections
@synthesize array = _array;
@synthesize dict = _dict;

+ (BOOL) isAutomagicCodingEnabled
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
