//
//  MIYouTubeChannelViewController.h
//  YoutubeChannel
//
//  Created by Istvan Szabo on 2013.04.22..
//  Copyright (c) 2013 Istvan Szabo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBYouTube.h"

@interface MIYouTubeChannelViewController : UITableViewController<LBYouTubePlayerControllerDelegate>
@property (strong, nonatomic) NSMutableArray *channelArray;
@property (nonatomic) BOOL highQuality;
@property (nonatomic, strong, readonly) LBYouTubeExtractor* extractor;
- (void) fetchEntries;




@end
