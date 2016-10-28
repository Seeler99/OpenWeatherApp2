//
//  ServerManager.m
//  OpenWeatherApp
//
//  Created by Albert Castro on 19/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import "ServerManager.h"
#import "ServerCommunicator.h"
#import "WeatherBuilder.h"
#import "WeatherObject.h"
#import <CoreLocation/CoreLocation.h>

@implementation ServerManager

static ServerCommunicator * _communicator;
static NSString * baseURLWeather = @"http://api.openweathermap.org/data/2.5/weather";
static NSString * APPID = @"d462cb0097592cde9ac0a409ba7d5833";


//Server Manager is a singleton
+ (id)sharedManager {
  static ServerManager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
    _communicator = [[ServerCommunicator alloc] init];
  });
  return sharedMyManager;
}


- (void) fetchWeatherForCity:(NSString *)city withCompletitionBlock:(WeatherArrayBlock)weatherArrayBlock {

  NSString *url = [NSString stringWithFormat:@"%@?q=%@&APPID=%@&units=metric",baseURLWeather,city,APPID] ;
  [self fetchWeatherForURL:url withCompletitionBlock:^(NSArray *weatherData, NSError *error) {
    weatherArrayBlock(weatherData,error);
  }];
}

- (void) fetchWeatherForCoordinates:(CLLocation *)location withCompletitionBlock:(WeatherArrayBlock)weatherArrayBlock {
  
  NSString *url = [NSString stringWithFormat:@"%@?lat=%f&lon=%f&APPID=%@&units=metric",baseURLWeather,location.coordinate.latitude,location.coordinate.longitude,APPID];
  [self fetchWeatherForURL:url withCompletitionBlock:^(NSArray *weatherData, NSError *error) {
    weatherArrayBlock(weatherData,error);
  }];
}


#pragma mark - Private Methods

- (void) fetchWeatherForURL:(NSString *)url withCompletitionBlock:(WeatherArrayBlock)weatherArrayBlock {
  
  //First we check the current weather and we add it to the array
  [_communicator fetchWeatherData:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] withCompletitionBlock:^(NSData *data, NSError *error) {
    
    if(error) {
      weatherArrayBlock(nil,error);
      return;
    }
    
    NSMutableArray *arrayMutableWeather = [NSMutableArray new];
    WeatherObject *weather = [WeatherBuilder weatherFromJSON:data error:&error];
    
    if(error) {
      weatherArrayBlock(nil,error);
      return;
    }
    
    [arrayMutableWeather addObject:weather];
    
    //After we add the forecast
    NSString *urlForecast = [url stringByReplacingOccurrencesOfString:@"/weather" withString:@"/forecast"];
    
    [_communicator fetchWeatherData:[urlForecast stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] withCompletitionBlock:^(NSData *data, NSError *error) {
      
      NSArray *arrayWeather = [WeatherBuilder forecastFromJSON:data error:&error];
      [arrayMutableWeather addObjectsFromArray:arrayWeather];
      weatherArrayBlock(arrayMutableWeather,error);
    }];
  }];
}


@end

