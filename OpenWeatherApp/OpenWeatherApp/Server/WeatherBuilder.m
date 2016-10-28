//
//  WeatherBuilder.m
//  OpenWeatherApp
//
//  Created by Albert Castro on 19/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import "WeatherBuilder.h"
#import "WeatherObject.h"

@implementation WeatherBuilder

+ (WeatherObject *)weatherFromJSON:(NSData *)objectNotation error:(NSError **)error {
 
  NSError *localError = nil;
  NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
  NSLog(@"WEATHER Data :%@",parsedObject);
  
  //Check error in JSON parsing
  if (localError != nil) {
    *error = localError;
    return nil;
  }
  
  //Check response error
  //JSON return example { cod = 502; message = "Error: Not found city" };
  if([parsedObject objectForKey:@"message"] != nil) {
    NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : [parsedObject objectForKey:@"message"]};
    *error = [NSError errorWithDomain:@"openWeatherApp" code:[[parsedObject objectForKey:@"cod"] intValue] userInfo:errorDictionary];
    return nil;
  }
  
  return [self weatherObjectFromDicctionary:parsedObject];
}


+ (NSArray *)forecastFromJSON:(NSData *)objectNotation error:(NSError **)error {
  
  NSError *localError = nil;
  NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
  NSLog(@"WEATHER Data :%@",parsedObject);
  
  //Check error in JSON parsing
  if (localError != nil) {
    *error = localError;
    return nil;
  }
  
  NSMutableArray *forecastList = [[NSMutableArray alloc] init];
  NSArray *listForecastFromData = [parsedObject objectForKey:@"list"];
  
  for (NSDictionary *forecast in listForecastFromData) {
   [forecastList addObject:[self weatherObjectFromDicctionary:forecast]];
  }
  return forecastList;
}


+ (WeatherObject *)weatherObjectFromDicctionary:(NSDictionary *)weatherDic {
  
  WeatherObject *weather = [[WeatherObject alloc] init];
  weather.name = [weatherDic objectForKey:@"name"];
  
  if([weatherDic objectForKey:@"dt_txt"])
    weather.date = [weatherDic objectForKey:@"dt_txt"];
  
  NSDictionary *mainObject = [weatherDic objectForKey:@"main"];
  weather.temp = [mainObject objectForKey:@"temp"];
  
  NSArray *descriptionObject = [weatherDic objectForKey:@"weather"];
  NSDictionary *descriptionObjectArray = [descriptionObject objectAtIndex:0];
  weather.weatherDescription = [descriptionObjectArray objectForKey:@"description"];
  weather.iconId = [descriptionObjectArray objectForKey:@"icon"];
  return weather;
}

@end
