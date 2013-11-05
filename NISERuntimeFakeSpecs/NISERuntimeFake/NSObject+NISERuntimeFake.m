//
//  Copyright (c) 2013 Lukasz Wolanczyk. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+NISERuntimeFake.h"

@implementation NSObject (NISERuntimeFake)

+ (id)fake {
    NSString *className = [NSString stringWithFormat:@"Fake%@", NSStringFromClass([self class])];
    Class class = objc_allocateClassPair(self.class, [className cStringUsingEncoding:NSUTF8StringEncoding], 0);
    return [[class alloc] init];
}

+ (Class)fakeClass{
    NSString *className = [NSString stringWithFormat:@"Fake%@", NSStringFromClass([self class])];
    Class class = objc_allocateClassPair(self.class, [className cStringUsingEncoding:NSUTF8StringEncoding], 0);
    return class;
}

+ (id)fakeDelegate:(Protocol *)protocol withOptionalMethods:(BOOL)optional {
    NSString *className = [NSString stringWithFormat:@"Fake%@", NSStringFromProtocol(protocol)];
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
    if (method == nil) {
        return;
    }
    IMP implementation = imp_implementationWithBlock(block);
    class_replaceMethod([self class], selector, implementation, method_getTypeEncoding(method));
}

@end
