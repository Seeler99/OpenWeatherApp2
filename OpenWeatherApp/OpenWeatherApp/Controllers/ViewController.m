//
//  ViewController.m
//  OpenWeatherApp
//
//  Created by Albert Castro on 19/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import "ViewController.h"
#import "ServerManager.h"
#import "WeatherObject.h"
#import "WeatherCollectionViewCell.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <UITextFieldDelegate,CLLocationManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;


@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *weatherArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic)  NSCache *iconsCache;


@end

@implementation ViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.weatherArray = [NSMutableArray new];
  self.iconsCache = [[NSCache alloc] init];
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  [self.locationManager requestWhenInUseAuthorization];
  [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  NSLog(@"didUpdateToLocation: %@", newLocation);
  CLLocation *currentLocation = newLocation;
  
  if (currentLocation != nil) {
    [self.locationManager stopUpdatingLocation];
    [self fetchServerDataForCoordinates:currentLocation];
  }
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  
  //Minimum 3 characters to search for  city weather.
  if([textField.text length] >= 3)
    [self fetchServerDataForCity:textField.text];
  else {
    [textField setText:@""];
    [self showAlert:@"Please enter at least 3 characters"];
  }
  return YES;
}


#pragma mark - UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  //We need to substract the first element which is the current weeather
  return [self.weatherArray count] - 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  //We need to substract the first element which is the current weeather
  WeatherObject *weather = [self.weatherArray objectAtIndex:indexPath.row + 1];
  static NSString *cellIdentifier = @"weatherCell";
  WeatherCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
  [cell.tempLabel setText:[NSString stringWithFormat:@"%.f \u00B0C",[weather.temp floatValue]]];
  
  
  NSDateFormatter *f = [[NSDateFormatter alloc] init];
  [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  NSDate *date = [f dateFromString:weather.date];
  
  NSDateFormatter *f2 = [[NSDateFormatter alloc] init];
  [f2 setDateFormat:@"EEE HH:mm"];
  NSString *displayDateString = [f2 stringFromDate:date];
  
  [cell.dateLabel setText:displayDateString];
  
  
  // If the image is not in the NSCache we get the new icon
  if([self.iconsCache objectForKey:weather.iconId] == NULL) {
    // download the image asynchronously
    [self downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png",weather.iconId]] completionBlock:^(BOOL succeeded, UIImage *image) {
      if (succeeded) {
        dispatch_async(dispatch_get_main_queue(), ^{

          //We store the Image in the cache
          [self.iconsCache setObject:image forKey:weather.iconId];
          [cell.iconImageView setImage:image];
        });
      }
    }];
  } else {
    [cell.iconImageView setImage:[self.iconsCache objectForKey:weather.iconId]];
  }
  return cell;
}


#pragma mark - Server

-(void)fetchServerDataForCity:(NSString *)city {
  ServerManager *server = [ServerManager sharedManager];
  [server fetchWeatherForCity:city withCompletitionBlock:^(NSArray *weatherData,NSError *error) {
    [self showWeatherData:weatherData withError:error];
  }];
}

-(void)fetchServerDataForCoordinates:(CLLocation *)location {
  ServerManager *server = [ServerManager sharedManager];
  
  [server fetchWeatherForCoordinates:location withCompletitionBlock:^(NSArray *weatherData,NSError *error) {
    [self showWeatherData:weatherData withError:error];
  }];
}


#pragma mark - Private methods

-(void)showWeatherData:(NSArray *)weatherData withError:(NSError *)error {
  
  dispatch_async(dispatch_get_main_queue(), ^{
   
    if (error) {
      [self showAlert:error.localizedDescription];
    } else {
      
      [self.weatherArray removeAllObjects];
      self.weatherArray = (NSMutableArray *) weatherData;

      
      //Current Weather
      WeatherObject *weather = [self.weatherArray objectAtIndex:0];
      [self.cityLabel setText:weather.name];
      [self.descriptionLabel setText:weather.weatherDescription];
      
      //We add the degree symbol to the string with unicode \u00B0
      [self.tempLabel setText:[NSString stringWithFormat:@"%.f \u00B0C",[weather.temp floatValue]]];
      
      // download the image asynchronously
      [self downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png",weather.iconId]] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
          dispatch_async(dispatch_get_main_queue(), ^{
            //We store the Image in the cache
            [self.iconsCache setObject:image forKey:weather.iconId];
            [self.iconImageView setImage:image];
          });
        }
      }];
      
      //Forecast
      [self.collectionView reloadData];
    }
  });
}

-(void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock {

  NSURLSessionDataTask *downloadTask =
    [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      dispatch_async(dispatch_get_main_queue(),^{
        if(!error)
        {
          UIImage *image = [[UIImage alloc] initWithData:data];
          completionBlock(YES,image);
        }
        else
          completionBlock(NO,nil);
      });
  }];
  [downloadTask resume];
}


-(void)showAlert:(NSString *)errorMessage{
  
  UIAlertController * alert = [UIAlertController
                               alertControllerWithTitle:@"Error"
                               message:errorMessage
                               preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction* okButton = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                               [alert dismissViewControllerAnimated:TRUE completion:nil];
                             }];
  
  [alert addAction:okButton];
  [self presentViewController:alert animated:YES completion:nil];
}


@end
