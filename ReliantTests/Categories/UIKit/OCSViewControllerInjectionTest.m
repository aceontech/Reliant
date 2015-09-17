//
//  OCSViewControllerInjectionTest.m
//  Reliant
//
//  Created by Michael Seghers on 27/10/13.
//
//

#define LOG_RELIANT 1
#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import "OCSObjectContext.h"
#import "OCSConfigurator.h"
#import "OCSScope.h"
#import "OCSScopeFactory.h"
#import "OCSDefinition.h"
#import "OCSContextRegistry.h"
#import "OCSConfigurator.h"

@interface SimpleViewController : UIViewController

- (id)initWithContext:(OCSObjectContext *) context;

@property (nonatomic) BOOL viewWasLoaded;
@property (nonatomic, strong) NSString *injected;

@end

@interface OCSViewControllerInjectionTest : XCTestCase {
    id<OCSConfigurator> _configurator;
    id<OCSScopeFactory> _scopeFactory;
    id<OCSContextRegistry> _contextRegistry;
    id<OCSScope> _scope;
    OCSObjectContext *_context;

}

@end

@implementation OCSViewControllerInjectionTest

- (void)setUp
{
    [super setUp];

    _scopeFactory = mockProtocol(@protocol(OCSScopeFactory));
    _configurator = mockProtocol(@protocol(OCSConfigurator));
    _contextRegistry = mockProtocol(@protocol(OCSContextRegistry));

    _scope = mockProtocol(@protocol(OCSScope));
    _context = [[OCSObjectContext alloc] initWithConfigurator:_configurator scopeFactory:_scopeFactory contextRegistry:_contextRegistry];
    [given([_scopeFactory scopeForName:anything()]) willReturn:_scope];
    [given([_configurator objectKeysAndAliases]) willReturn:@[@"injected"]];
}

- (void) testViewShouldNotLoad {
    SimpleViewController *svc = [[SimpleViewController alloc] initWithContext:_context];
    XCTAssertFalse(svc.viewWasLoaded, @"View should not be loaded after mere initialization");
}

- (void) testViewControllerIsBeingInjected {
    [given([_scope objectForKey:@"injected"]) willReturn:@"InjectedString"];

    OCSDefinition *definition = [[OCSDefinition alloc] init];
    definition.key = @"injected";
    definition.scope = @"singleton";

    [given([_configurator definitionForKeyOrAlias:@"injected"]) willReturn:definition];

    SimpleViewController *svc = [[SimpleViewController alloc] initWithContext:_context];
    XCTAssertEqual(svc.injected, @"InjectedString", @"The injectable property was not injected");
}

- (void) testViewControllerInjectionExcludesExcludedProperties {
    UIViewController *controller = [[SimpleViewController alloc] initWithContext:_context];
    XCTAssertNotNil(controller, @"Controller should init");

    [verify(_configurator) definitionForKeyOrAlias:@"injected"];
    [verifyCount(_configurator, never()) definitionForKeyOrAlias:isNot(@"injected")];
}

@end

@implementation SimpleViewController

- (id)initWithContext:(OCSObjectContext *) context
{
    self = [super init];
    if (self) {
        [context performInjectionOn:self];
    }
    return self;
}

- (void)viewDidLoad {
    self.viewWasLoaded = YES;
}


@end
