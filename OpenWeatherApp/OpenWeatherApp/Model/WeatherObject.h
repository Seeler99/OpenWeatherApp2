//
//  WeatherObject.h
//  OpenWeatherApp
//
//  Created by Albert Castro on 19/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *weatherDescription;
@property (nonatomic, strong) NSNumber *temp;
@property (nonatomic, strong) NSString *iconId;
@property (nonatomic, strong) NSString *date;
@end
