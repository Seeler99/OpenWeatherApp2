//
//  WeatherBuilder.h
//  OpenWeatherApp
//
//  Created by Albert Castro on 19/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WeatherObject;

@interface WeatherBuilder : NSObject

+ (WeatherObject *)weatherFromJSON:(NSData *)objectNotation error:(NSError **)error;
+ (NSArray *)forecastFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
