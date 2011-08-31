//
//  AutomagicCodingTests.h
//  AutomagicCodingTests
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class Foo;
@interface AutomagicCodingTests : SenTestCase
{
    Foo *_foo;
}
@property(readwrite, retain) Foo *foo;

@end
