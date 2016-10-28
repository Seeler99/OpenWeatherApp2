//
//  ServerCommunicator.m
//  OpenWeatherApp
//
//  Created by Albert Castro on 19/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import "ServerCommunicator.h"

@implementation ServerCommunicator


- (void) fetchWeatherData:(NSString *)urlString withCompletitionBlock:(DataBlock)dataBlock {
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
  
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:60.0];
  
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setHTTPMethod:@"GET"];
  
  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
    dataBlock(data,error);
  }];
  [dataTask resume];
  
  //To avoid memory leak
  [session finishTasksAndInvalidate];
}

@end
