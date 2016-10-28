//
//  ServerCommunicator.h
//  OpenWeatherApp
//
//  Created by Albert Castro on 19/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DataBlock)(NSData *data,NSError *error);

@interface ServerCommunicator : NSObject

- (void) fetchWeatherData:(NSString *)urlString withCompletitionBlock:(DataBlock)dataBlock;

@end
