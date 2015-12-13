 //
//  NameContextMultipleInstancesTests.m
//  Reliant
//
//  Created by Alex Manarpies on 13/12/15.
//
//

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>

#import "OCSObjectContext.h"
#import "NSObject+OCSReliantContextBinding.h"
#import "NCMIConfiguration.h"
#import "NCMIChildConfiguration.h"

@interface NameContextMultipleInstancesTests : XCTestCase
@end

@implementation NameContextMultipleInstancesTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMultipleInstances {
    // These are the context holding objects
    UIViewController *viewControllerA = [[UIViewController alloc] init];
    UIViewController *viewControllerB = [[UIViewController alloc] init];

    // Bootstrap the first two contexts, independently from each other
    [viewControllerA ocsBootstrapAndBindObjectContextWithConfiguratorFromClass:[NCMIConfiguration class]];
    [viewControllerB ocsBootstrapAndBindObjectContextWithConfiguratorFromClass:[NCMIConfiguration class]];

    // Contexts should be different
    expect(viewControllerA.ocsObjectContext).notTo.beIdenticalTo(viewControllerB.ocsObjectContext);

    // Objects requested from either context should be different
    expect([viewControllerA.ocsObjectContext objectForKey:@"testObject"]).notTo.beIdenticalTo([viewControllerB.ocsObjectContext objectForKey:@"testObject"]);

    // Context 3 derives from NCMIConfiguration
    UIViewController *viewControllerC = [[UIViewController alloc] init];
    [viewControllerB addChildViewController:viewControllerC];
    [viewControllerC ocsBootstrapAndBindObjectContextWithConfiguratorFromClass:[NCMIChildConfiguration class]];

    // Derived testObject should be fetched from its parent;
    // In the current system, the parent will be the last context bootstrapped, which can be variable at runtime
    expect([viewControllerC.ocsObjectContext objectForKey:@"testObject"]).to.beIdenticalTo([viewControllerB.ocsObjectContext objectForKey:@"testObject"]);
    expect([viewControllerC.ocsObjectContext objectForKey:@"testObject"]).notTo.beIdenticalTo([viewControllerA.ocsObjectContext objectForKey:@"testObject"]);
}

@end
