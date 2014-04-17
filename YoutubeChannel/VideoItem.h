//
//  VideoItem.h
//  VideoPlayer
//
//  Created by Istvan Szabo on 2012.11.23..
//
//

#import <Foundation/Foundation.h>

@interface VideoItem : NSObject


@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) NSString *dateTime;
@property (strong, nonatomic) NSString *author;

@end
