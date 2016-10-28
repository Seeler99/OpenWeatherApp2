//
//  OpenWeatherAppTests.m
//  OpenWeatherAppTests
//
//  Created by Albert Castro on 19/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ServerManager.h"
#import "WeatherObject.h"

@interface OpenWeatherAppTests : XCTestCase

@end

@implementation OpenWeatherAppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testFetchingWeatherFromApi {
  XCTestExpectation *responseExpectation = [self expectationWithDescription:@"Array with weather info returned"];
  
  ServerManager *server = [ServerManager sharedManager];
  [server fetchWeatherForCity:@"vancouver" withCompletitionBlock:^(NSArray *weatherData,NSError *error) {
    
    //Test1: We have the weather and the forecast
    XCTAssert([weatherData count] > 0);
    
    //Test2: The first object is the current weather
    WeatherObject *weather = [weatherData objectAtIndex:0];
    XCTAssert([weather.name isEqualToString:@"Vancouver"]);
    
    [responseExpectation fulfill];
  }];
  
  //Test3: We receive a response in less than 10 seconds
  [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
  }];
}


- (void)testFetchingWeatherFromApiError {
  
  XCTestExpectation *responseExpectation = [self expectationWithDescription:@"Array with weather info returned"];
  
  ServerManager *server = [ServerManager sharedManager];
  [server fetchWeatherForCity:@"sjdajfksdjf;sjf;fdslf;jsf" withCompletitionBlock:^(NSArray *weatherData,NSError *error) {
    
    //Test1: We have the weather array empty
    XCTAssert(weatherData == nil);
    
    //Test2: We receive an error
    XCTAssert(error != nil);
    
    //Test3: We receive an error of no city found
    XCTAssert([error.localizedDescription isEqualToString:@"Error: Not found city"]);
    
    [responseExpectation fulfill];
  }];
  
  //Test4: We receive a response in less than 10 seconds
  [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
  }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
