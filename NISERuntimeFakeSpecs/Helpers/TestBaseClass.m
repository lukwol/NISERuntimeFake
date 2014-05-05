//
//  TestBaseClass.m
//  NISERuntimeFakeSpecs
//
//  Created by Lukasz Wolanczyk on 4/30/14.
//  Copyright (c) 2014 Lukasz Wolanczyk. All rights reserved.
//

#import "TestBaseClass.h"

@implementation TestBaseClass

- (NSString *)doSomething {
    self.exampleStringProperty = @"Testing method implementation";
    return @"Old implementation";
}

@end
