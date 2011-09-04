//
//  AMCCollectionsTest.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AMCCollectionsTest.h"
#import "NSObject+AutomagicCoding.h"

// Test objects.
#import "Foo.h"
#import "FooWithCollections.h"
#import "FooWithMutableCollections.h"
#import "Bar.h"

@implementation AMCCollectionsTest
@synthesize fooWithCollections = _fooWithCollections;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.fooWithCollections = [[FooWithCollections new] autorelease];
}

- (void) testEmptyCollectionsInMemory
{
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray array];
    self.fooWithCollections.dict = [NSDictionary dictionary];
    
    // Save & Load.
    NSDictionary *fooDict = [self.fooWithCollections dictionaryRepresentation];   
    // Create new object from that dictionary.
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: fooDict] retain];
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be empty.
    STAssertTrue([newFoo.array count] == 0, @"newFoo.array is not empty!" );
    STAssertTrue([newFoo.dict count] == 0, @"newFoo.dict is not empty!" );
}

- (void) testEmptyCollectionsInFile
{
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray array];
    self.fooWithCollections.dict = [NSDictionary dictionary];    
    
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self testFilePathWithSuffix:@"Empty"];
    NSDictionary *dictRepr =[self.fooWithCollections dictionaryRepresentation];
    [dictRepr writeToFile: path atomically:YES]; 
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: path ])
        STFail(@"Test file with path = %@ not exist! Dictionary representation = %@", path, dictRepr);
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be empty.
    STAssertTrue([newFoo.array count] == 0, @"newFoo.array is not empty!" );
    STAssertTrue([newFoo.dict count] == 0, @"newFoo.dict is not empty!" );
}

- (void) testStringCollectionsInMemory
{
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray arrayWithObjects:@"one", @"three", @"two", @"ah!",  nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"obj1", @"obj2", @"obj3", nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", nil]];
    
    // Save & Load.
    NSDictionary *fooDict = [self.fooWithCollections dictionaryRepresentation];   
    // Create new object from that dictionary.
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: fooDict] retain];
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be the same size.
    STAssertTrue([newFoo.array count] == [self.fooWithCollections.array count], @"newFoo.array count is not wrong!" );
    STAssertTrue([newFoo.dict count] == [self.fooWithCollections.dict count], @"newFoo.dict count is not wrong!" );
    
    STAssertTrue([ self array:newFoo.array isEqualTo: self.fooWithCollections.array], @"newFoo.array is not equal with the original!" );
    STAssertTrue([ self dict: newFoo.dict isEqualTo: self.fooWithCollections.dict], @"newFoo.dict is not equal with the original!" );
}

- (void) testStringCollectionsInFile
{
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray arrayWithObjects:@"one", @"three", @"two", @"ah!",  nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"obj1", @"obj2", @"obj3", nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", nil]];
    
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self testFilePathWithSuffix:@"String"];
    NSDictionary *dictRepr =[self.fooWithCollections dictionaryRepresentation];
    [dictRepr writeToFile: path atomically:YES]; 
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: path ])
        STFail(@"Test file with path = %@ not exist! Dictionary representation = %@", path, dictRepr);
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be the same size.
    STAssertTrue([newFoo.array count] == [self.fooWithCollections.array count], @"newFoo.array count is not wrong!" );
    STAssertTrue([newFoo.dict count] == [self.fooWithCollections.dict count], @"newFoo.dict count is not wrong!" );
    
    STAssertTrue([ self array:newFoo.array isEqualTo: self.fooWithCollections.array], @"newFoo.array is not equal with the original!" );
    STAssertTrue([ self dict: newFoo.dict isEqualTo: self.fooWithCollections.dict], @"newFoo.dict = %@, self.foo.dict = %@", newFoo.dict, self.fooWithCollections.dict  );
}

- (void) testCustomObjectsCollectionInMemory
{
    // Prepare custom object for collections.
    Foo *one = [[Foo new] autorelease];
    Foo *two = [[Foo new] autorelease];
    Foo *three = [[Foo new] autorelease];
    one.integerValue = 1;
    two.integerValue = 2;
    three.integerValue = 3;
    
    Bar *obj1 = [[Bar new] autorelease];
    Bar *obj2 = [[Bar new] autorelease];
    Bar *obj3 = [[Bar new] autorelease];
    obj1.someString = @"object numero uno!";
    obj2.someString = @"object numero dvuno!";
    obj3.someString = @"object numero trino!";
    
    
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray arrayWithObjects: one, two, three, nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: obj1, obj2, obj3, nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", nil]];
    
    
    if ( kAMCFieldTypeCollectionArray != [self.fooWithCollections AMCFieldTypeForValueWithKey: @"array"] )
        STFail(@"fieldTypeForValueWithKey: doesn't recognize NSArray as array collection!");
    
    if ( kAMCFieldTypeCollectionHash != [self.fooWithCollections AMCFieldTypeForValueWithKey: @"dict"] )
        STFail(@"fieldTypeForValueWithKey: doesn't recognize NSArray as array collection!");
    
    // Save & Load.
    NSDictionary *fooDict = [self.fooWithCollections dictionaryRepresentation];   
    // Create new object from that dictionary.
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: fooDict] retain];
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be the same size.
    STAssertTrue([newFoo.array count] == [self.fooWithCollections.array count], @"newFoo.array count is not wrong!" );
    STAssertTrue([newFoo.dict count] == [self.fooWithCollections.dict count], @"newFoo.dict count is not wrong!" );
    
    STAssertTrue([ self array:newFoo.array isEqualTo: self.fooWithCollections.array], @"newFoo.array is not equal with the original!" );
    STAssertTrue([ self dict: newFoo.dict isEqualTo: self.fooWithCollections.dict], @"newFoo.dict is not equal with the original!" );
}

- (void) testCustomObjectsCollectionInFile
{
    // Prepare custom object for collections.
    Foo *one = [[Foo new] autorelease];
    Foo *two = [[Foo new] autorelease];
    Foo *three = [[Foo new] autorelease];
    one.integerValue = 1;
    two.integerValue = 2;
    three.integerValue = 3;
    
    one.publicBar = [[Bar new] autorelease];
    one.publicBar.someString = @"someString in one.publicBar";
    Bar *onePrivateBar = [[Bar new] autorelease];
    onePrivateBar.someString = @"someString in onePrivateBar";
    [one setValue:onePrivateBar forKey:@"privateBar"];
    
    two.publicBar = [[Bar new] autorelease];
    two.publicBar.someString = @"someString in two.publicBar";
    Bar *twoPrivateBar = [[Bar new] autorelease];
    twoPrivateBar.someString = @"someString in twoPrivateBar";
    [two setValue:twoPrivateBar forKey:@"privateBar"];
    
    Bar *obj1 = [[Bar new] autorelease];
    Bar *obj2 = [[Bar new] autorelease];
    Bar *obj3 = [[Bar new] autorelease];
    obj1.someString = @"object numero uno!";
    obj2.someString = @"object numero dvuno!";
    obj3.someString = @"object numero trino!";
    
    
    
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray arrayWithObjects: one, two, three, nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: obj1, obj2, obj3, nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", nil]];
    
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self testFilePathWithSuffix:@"Custom"];
    NSDictionary *dictRepr =[self.fooWithCollections dictionaryRepresentation];    
    [dictRepr writeToFile: path atomically:YES]; 
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: path ])
        STFail(@"Test file with path = %@ not exist! Dictionary representation = %@", path, dictRepr);
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be the same size.
    STAssertTrue([newFoo.array count] == [self.fooWithCollections.array count], @"newFoo.array count is not wrong!" );
    STAssertTrue([newFoo.dict count] == [self.fooWithCollections.dict count], @"newFoo.dict count is not wrong!" );
    
    STAssertTrue([ self array:newFoo.array isEqualTo: self.fooWithCollections.array], @"self.fooWithCollections.array = %@, newFoo.array = %@", self.fooWithCollections.array, newFoo.array  );
    STAssertTrue([ self dict: newFoo.dict isEqualTo: self.fooWithCollections.dict], @"newFoo.dict is not equal with the original!" );
    
    // Test Foo#isEqual & Bar#isEqual for negative reaction
    twoPrivateBar.someString = @"someString in twoPrivateBar messed up";
    STAssertFalse([ self array:newFoo.array isEqualTo: self.fooWithCollections.array], @"self.fooWithCollections.array = %@, newFoo.array = %@", self.fooWithCollections.array, newFoo.array  );
    
}

- (void) testCollectionsOfCollectionsInMemory
{
    // Prepare custom objects for collections.
    Foo *one = [[Foo new] autorelease];
    Foo *two = [[Foo new] autorelease];
    Foo *three = [[Foo new] autorelease];
    one.integerValue = 1;
    two.integerValue = 2;
    three.integerValue = 3;
    
    Bar *obj1 = [[Bar new] autorelease];
    Bar *obj2 = [[Bar new] autorelease];
    Bar *obj3 = [[Bar new] autorelease];
    obj1.someString = @"object numero uno!";
    obj2.someString = @"object numero dvuno!";
    obj3.someString = @"object numero trino!";
    
    // Prepare objects for collections in collections.
    Foo *fourOne = [[Foo new] autorelease];
    Foo *fourTwo = [[Foo new] autorelease];
    Foo *fourThree = [[Foo new] autorelease];
    fourOne.integerValue = 41;
    fourTwo.integerValue = 42;
    fourThree.integerValue = 43;
    
    Bar *obj4obj1 = [[Bar new] autorelease];
    Bar *obj4obj2 = [[Bar new] autorelease];
    Bar *obj4obj3 = [[Bar new] autorelease];
    obj4obj1.someString = @"incapsulated dict. Object - 1";
    obj4obj2.someString = @"incapsulated dict. Object - 2";
    obj4obj3.someString = @"incapsulated dict. Object - 3";
    
    // Prepare collections in collections.
    NSArray *four = [NSArray arrayWithObjects:fourOne, fourTwo, fourThree, nil];
    NSDictionary *obj4 = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:obj4obj1, obj4obj2,obj4obj3, nil] 
                                                     forKeys:[NSArray arrayWithObjects:@"obj4key1",@"obj4key2",@"obj4key3", nil]];
    
    
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray arrayWithObjects: one, two, three, four, nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: obj1, obj2, obj3, obj4, nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", @"key4-collection", nil]];
    
    // Save & Load.
    NSDictionary *fooDict = [self.fooWithCollections dictionaryRepresentation];   
    // Create new object from that dictionary.
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: fooDict] retain];
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be the same size.    
    STAssertTrue([newFoo.array count] == [self.fooWithCollections.array count], @"newFoo.array count is wrong!" );
    STAssertTrue([newFoo.dict count] == [self.fooWithCollections.dict count], @"newFoo.dict count is wrong!" );
    
    STAssertTrue([ self array:newFoo.array isEqualTo: self.fooWithCollections.array], @"newFoo.array is not equal with the original!" );
    STAssertTrue([ self dict: newFoo.dict isEqualTo: self.fooWithCollections.dict], @"newFoo.dict is not equal with the original!" );
}

- (void) testCollectionsOfCollectionsInFile
{
    // Prepare custom objects for collections.
    Foo *one = [[Foo new] autorelease];
    Foo *two = [[Foo new] autorelease];
    Foo *three = [[Foo new] autorelease];
    one.integerValue = 1;
    two.integerValue = 2;
    three.integerValue = 3;
    
    Bar *obj1 = [[Bar new] autorelease];
    Bar *obj2 = [[Bar new] autorelease];
    Bar *obj3 = [[Bar new] autorelease];
    obj1.someString = @"object numero uno!";
    obj2.someString = @"object numero dvuno!";
    obj3.someString = @"object numero trino!";
    
    // Prepare objects for collections in collections.
    Foo *fourOne = [[Foo new] autorelease];
    Foo *fourTwo = [[Foo new] autorelease];
    Foo *fourThree = [[Foo new] autorelease];
    fourOne.integerValue = 41;
    fourTwo.integerValue = 42;
    fourThree.integerValue = 43;
    
    Bar *obj4obj1 = [[Bar new] autorelease];
    Bar *obj4obj2 = [[Bar new] autorelease];
    Bar *obj4obj3 = [[Bar new] autorelease];
    obj4obj1.someString = @"incapsulated dict. Object - 1";
    obj4obj2.someString = @"incapsulated dict. Object - 2";
    obj4obj3.someString = @"incapsulated dict. Object - 3";
    
    // Prepare collections in collections.
    NSArray *four = [NSArray arrayWithObjects:fourOne, fourTwo, fourThree, nil];
    NSDictionary *obj4 = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:obj4obj1, obj4obj2,obj4obj3, nil] 
                                                     forKeys:[NSArray arrayWithObjects:@"obj4key1",@"obj4key2",@"obj4key3", nil]];
    
    
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray arrayWithObjects: one, two, three, four, nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: obj1, obj2, obj3, obj4, nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", @"key4-collection", nil]];
    
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self testFilePathWithSuffix:@"CollectionWithCollectionOfCustom"];
    NSDictionary *dictRepr =[self.fooWithCollections dictionaryRepresentation];    
    [dictRepr writeToFile: path atomically:YES]; 
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: path ])
        STFail(@"Test file with path = %@ not exist! Dictionary representation = %@", path, dictRepr);
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be the same size.
    STAssertTrue([newFoo.array count] == [self.fooWithCollections.array count], @"newFoo.array count is not wrong!" );
    STAssertTrue([newFoo.dict count] == [self.fooWithCollections.dict count], @"newFoo.dict count is not wrong!" );
    
    STAssertTrue([ self array:newFoo.array isEqualTo: self.fooWithCollections.array], @"newFoo.array is not equal with the original!" );
    STAssertTrue([ self dict: newFoo.dict isEqualTo: self.fooWithCollections.dict], @"newFoo.dict is not equal with the original!" );
}


- (void) testFieldTypeDetection
{
    // Prepare custom object for collections.
    Foo *one = [[Foo new] autorelease];
    Foo *two = [[Foo new] autorelease];
    Foo *three = [[Foo new] autorelease];
    one.integerValue = 1;
    two.integerValue = 2;
    three.integerValue = 3;
    
    Bar *obj1 = [[Bar new] autorelease];
    Bar *obj2 = [[Bar new] autorelease];
    Bar *obj3 = [[Bar new] autorelease];
    obj1.someString = @"object numero uno!";
    obj2.someString = @"object numero dvuno!";
    obj3.someString = @"object numero trino!";
    
    
    // Test immutable collection detection.
    self.fooWithCollections.array =[NSArray arrayWithObjects: one, two, three, nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: obj1, obj2, obj3, nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", nil]];
    
    
    if ( kAMCFieldTypeCollectionArray != [self.fooWithCollections AMCFieldTypeForValueWithKey: @"array"] )
        STFail(@"fieldTypeForValueWithKey: doesn't recognize NSArray as array collection!");
    
    if ( kAMCFieldTypeCollectionHash != [self.fooWithCollections AMCFieldTypeForValueWithKey: @"dict"] )
        STFail(@"fieldTypeForValueWithKey: doesn't recognize NSDictionary as hash collection!");
    
    // Test mutable collection detection.
    self.fooWithCollections = [[FooWithMutableCollections new] autorelease];
    self.fooWithCollections.array =[NSMutableArray arrayWithObjects: one, two, nil];
    [(NSMutableArray *)self.fooWithCollections.array addObject: three ];
    self.fooWithCollections.dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects: obj1, obj2, nil] 
                                                                      forKeys:[NSArray arrayWithObjects: @"key1", @"key2", nil]];
    [(NSMutableDictionary *)self.fooWithCollections.dict setObject: obj3 forKey: @"key3" ];
    
    if ( kAMCFieldTypeCollectionArrayMutable != [self.fooWithCollections AMCFieldTypeForValueWithKey: @"array"] )
        STFail(@"fieldTypeForValueWithKey: doesn't recognize NSArray as array collection!");
    
    if ( kAMCFieldTypeCollectionHashMutable != [self.fooWithCollections AMCFieldTypeForValueWithKey: @"dict"] )
        STFail(@"fieldTypeForValueWithKey: doesn't recognize NSDictionary as hash collection!");
    
    if ( kAMCFieldTypeSimple != [one AMCFieldTypeForValueWithKey:@"integerValue"])
        STFail(@"fieldTypeForValueWithKey: doesn't recognize int as scalar/struct!");
    
    if ( kAMCFieldTypeCustom != [one AMCFieldTypeForValueWithKey:@"publicBar"])
        STFail(@"fieldTypeForValueWithKey: doesn't recognize Bar as Custom!");
}

- (void) testMutableCollections
{
    // Set-up code here.
    self.fooWithCollections = [[FooWithMutableCollections new] autorelease];
    
    // Prepare custom objects for collections.
    Foo *one = [[Foo new] autorelease];
    Foo *two = [[Foo new] autorelease];
    Foo *three = [[Foo new] autorelease];
    one.integerValue = 1;
    two.integerValue = 2;
    three.integerValue = 3;
    
    Bar *obj1 = [[Bar new] autorelease];
    Bar *obj2 = [[Bar new] autorelease];
    Bar *obj3 = [[Bar new] autorelease];
    obj1.someString = @"object numero uno!";
    obj2.someString = @"object numero dvuno!";
    obj3.someString = @"object numero trino!";
    
    // Prepare objects for collections in collections.
    Foo *fourOne = [[Foo new] autorelease];
    Foo *fourTwo = [[Foo new] autorelease];
    Foo *fourThree = [[Foo new] autorelease];
    fourOne.integerValue = 41;
    fourTwo.integerValue = 42;
    fourThree.integerValue = 43;
    
    Bar *obj4obj1 = [[Bar new] autorelease];
    Bar *obj4obj2 = [[Bar new] autorelease];
    Bar *obj4obj3 = [[Bar new] autorelease];
    obj4obj1.someString = @"incapsulated dict. Object - 1";
    obj4obj2.someString = @"incapsulated dict. Object - 2";
    obj4obj3.someString = @"incapsulated dict. Object - 3";
    
    // Prepare collections in collections.
    NSArray *four = [NSArray arrayWithObjects:fourOne, fourTwo, fourThree, nil];
    NSDictionary *obj4 = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:obj4obj1, obj4obj2,obj4obj3, nil] 
                                                     forKeys:[NSArray arrayWithObjects:@"obj4key1",@"obj4key2",@"obj4key3", nil]];
    
    
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray arrayWithObjects: one, two, three, four, nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: obj1, obj2, obj3, obj4, nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", @"key4-collection", nil]];
    
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self testFilePathWithSuffix:@"CollectionWithCollectionOfCustom"];
    NSDictionary *dictRepr =[self.fooWithCollections dictionaryRepresentation];    
    [dictRepr writeToFile: path atomically:YES]; 
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: path ])
        STFail(@"Test file with path = %@ not exist! Dictionary representation = %@", path, dictRepr);
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithMutableCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithMutableCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be the same size.
    STAssertTrue([newFoo.array count] == [self.fooWithCollections.array count], @"newFoo.array count is not wrong!" );
    STAssertTrue([newFoo.dict count] == [self.fooWithCollections.dict count], @"newFoo.dict count is not wrong!" );
    
    STAssertTrue([ self array:newFoo.array isEqualTo: self.fooWithCollections.array], @"newFoo.array is not equal with the original!" );
    STAssertTrue([ self dict: newFoo.dict isEqualTo: self.fooWithCollections.dict], @"newFoo.dict is not equal with the original!" );
    
    // Test if newFoo has mutable collections
    STAssertTrue([newFoo.array isKindOfClass: [NSMutableArray class]], @"newFoo.array = %@", newFoo.array);
    STAssertTrue([newFoo.dict isKindOfClass: [NSMutableDictionary class]], @"newFoo.dict = %@", newFoo.dict);
    
    FooWithMutableCollections *newFooMutable = (FooWithMutableCollections *) newFoo;
    NSUInteger prevArrayCount = [newFoo.array count];
    NSUInteger prevDictCount = [newFoo.dict count];
    
    @try {
        [newFooMutable.array addObject: @"blablaObject"];
        [newFooMutable.dict setObject:@"testingMutable" forKey:@"addedAfter"];
        
        STAssertFalse([newFoo.array count] == prevArrayCount, @"");
        STAssertFalse([newFoo.dict count] == prevDictCount, @"");
    }
    @catch (NSException *exception) {
        STFail(@"Mutable collections crashed while trying to modify them");
    }
}

- (void)tearDown
{
    // Tear-down code here.
    self.fooWithCollections = nil;
    
    [super tearDown];
}

@end
