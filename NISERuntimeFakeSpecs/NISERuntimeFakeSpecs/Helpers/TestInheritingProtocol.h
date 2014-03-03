/*
 * Copyright 2014 Taptera Inc. All rights reserved.
 */


#import <Foundation/Foundation.h>
#import "TestBaseProtocol.h"

@protocol TestInheritingProtocol <TestBaseProtocol>

-(void)testInheritingRequiredMethod;

@optional

- (void)testInheritingOptionalMethod;

@end
