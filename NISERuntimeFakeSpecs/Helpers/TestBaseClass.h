//
//  TestBaseClass.h
//  NISERuntimeFakeSpecs
//
//  Created by Lukasz Wolanczyk on 4/30/14.
//  Copyright (c) 2014 Lukasz Wolanczyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestBaseClass : NSObject

@property (nonatomic, strong) NSString *exampleStringProperty;

- (NSString *)doSomething;

@end
