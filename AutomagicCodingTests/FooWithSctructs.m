//
//  FooWithSctructs.m
//  AutoMagicCoding-iOS
//
//  Created by Stepan Generalov on 04.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FooWithSctructs.h"

@implementation FooWithSctructs

@synthesize rect = _rect, point = _point, size = _size;

+ (BOOL) isAutomagicCodingEnabled
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

@end
