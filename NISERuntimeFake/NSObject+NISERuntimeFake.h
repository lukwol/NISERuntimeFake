//
//  Copyright (c) 2013 Lukasz Wolanczyk. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `NISERuntimeFake` is an `NSObject` category which creates fake objects at runtime.
 */
@interface NSObject (NISERuntimeFake)


///-------------------------------
/// @name Creating Fake Objects
///-------------------------------

/**
 Creates fake object which can override instance methods.

 @return A new fake object.
*/
+ (id)fake;

/**
 Creates fake object which can override instance methods. This object can override methods from selected protocol.
 After creation this object has empty implementation of protocol methods.

 @param protocol The protocol, which methods will be implemented.
 @param optional Switch specifying if fake needs to implement optional methods.

 @return A new fake object with implemented protocol methods.
 */
+ (id)fakeObjectWithProtocol:(Protocol *)protocol includeOptionalMethods:(BOOL)optional;

///-------------------------------
/// @name Overriding Instance Methods
///-------------------------------

/**
 Overrides implementation of selected instance method.

 @param selector The method selector, which implementation we want to override.
 @param block Block which will be executed when overridden method will be called.

 @warning This method should be called only on fake objects
 @warning First block argument will always be fake object's future self, other arguments will be in the same order as in the method.
 */
- (void)overrideInstanceMethod:(SEL)selector withImplementation:(id)block;

@end
