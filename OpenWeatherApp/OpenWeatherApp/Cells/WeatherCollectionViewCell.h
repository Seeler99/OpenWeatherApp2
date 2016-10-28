//
//  WeatherCollectionViewCell.h
//  OpenWeatherApp
//
//  Created by Albert Castro on 20/10/2016.
//  Copyright © 2016 AlbertCastro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
