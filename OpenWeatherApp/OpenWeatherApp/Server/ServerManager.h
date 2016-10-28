//
//  ServerManager.h
//  OpenWeatherApp
//
//  Created by Albert Castro on 19/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WeatherObject;
@class ServerCommunicator;
@class CLLocation;

typedef void (^WeatherBlock)(WeatherObject *weather, NSError *error);
typedef void (^WeatherArrayBlock)(NSArray *weatherData, NSError *error);


@interface ServerManager : NSObject

+ (id)sharedManager;
- (void) fetchWeatherForCity:(NSString *)city withCompletitionBlock:(WeatherArrayBlock)weatherArrayBlock;
- (void) fetchWeatherForCoordinates:(CLLocation *)location withCompletitionBlock:(WeatherArrayBlock)weatherArrayBlock;

@end
