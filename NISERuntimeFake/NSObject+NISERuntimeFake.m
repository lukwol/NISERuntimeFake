//
//  Copyright (c) 2013 Lukasz Wolanczyk. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+NISERuntimeFake.h"

@implementation NSObject (NISERuntimeFake)

+ (id)fake {
    Class fakeClass = [self fakeClass];
    return [[fakeClass alloc] init];
}

+ (Class)fakeClass {

    NSString *className = [NSString stringWithFormat:@"NISEFake%@", NSStringFromClass([self class])];
    [self assertClassNotExists:NSClassFromString(className)];

    Class class = objc_allocateClassPair(self.class, [className cStringUsingEncoding:NSUTF8StringEncoding], 0);
    return class;
}

+ (id)fakeObjectWithProtocol:(Protocol *)protocol optionalMethods:(BOOL)optional {
    NSString *className = [NSString stringWithFormat:@"NISEFake%@", NSStringFromProtocol(protocol)];
    [self assertClassNotExists:NSClassFromString(className)];

    Class class = objc_allocateClassPair(self.class, [className cStringUsingEncoding:NSUTF8StringEncoding], 0);
    class_addProtocol(class, protocol);
    void (^enumerate)(BOOL) = ^(BOOL isRequired) {
        unsigned int descriptionCount;
        struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(protocol, isRequired, YES, &descriptionCount);
        for (int i = 0; i < descriptionCount; i++) {
            struct objc_method_description methodDescription = methodDescriptions[i];
            IMP implementation = imp_implementationWithBlock(^id {
                return nil;
            });
            class_addMethod(class, methodDescription.name, implementation, methodDescription.types);
        }
    };
    enumerate(YES);
    if (optional) {
        enumerate(NO);
    }
    return [[class alloc] init];
}

- (void)overrideInstanceMethod:(SEL)selector withImplementation:(id)block {
    Method method = class_getInstanceMethod([self class], selector);
    [self assertMethodExists:method];
    if (method) {
        IMP implementation = imp_implementationWithBlock(block);
        class_replaceMethod([self class], selector, implementation, method_getTypeEncoding(method));
    }
}

#pragma mark - Assertions

- (void)assertClassNotExists:(Class)aClass {
    NSString *description = [NSString stringWithFormat:@"Could not create %@ class, because class with such name already exists",
                                                       NSStringFromClass(aClass)];
    NSAssert(!aClass, description);
}

- (void)assertMethodExists:(Method)method {
    NSString *description = [NSString stringWithFormat:@"Could not override method %@, because such method does not exist in %@ class",
                                                       NSStringFromSelector(method_getName(method)),
                                                       NSStringFromClass([self class])];
    NSAssert(method, description);
}

@end
