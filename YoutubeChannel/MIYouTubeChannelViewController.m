//
//  MIYouTubeChannelViewController.m
//  YoutubeChannel
//
//  Created by Istvan Szabo on 2013.04.22..
//  Copyright (c) 2013 Istvan Szabo. All rights reserved.
//

#import "MIYouTubeChannelViewController.h"
#import "SMXMLDocument.h"
#import "VideoItem.h"
#import "YouTubeCell.h"
#import "Reachability.h"
#import "NSString+MD5.h"
#import "ISCache.h"
#import "ISCustomAccessory.h"
#import "MIYouTubeConfig.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MIYouTubeChannelViewController ()

@property (nonatomic, strong) LBYouTubeExtractor* extractor;

@end

@implementation MIYouTubeChannelViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchEntries];
     self.title = CHANNEL_TITLE;
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
}

- (void)fetchEntries
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:CHANNEL_URL]];
	
	NSError *error;
	SMXMLDocument *document = [SMXMLDocument documentWithData:data error:&error];
    
    // check for errors
    if (error) {
        NSLog(@"Error while parsing the document: %@", error);
        return;
    }
    
	// demonstrate document element classes
	NSLog(@"Document:\n %@", document);
	
    SMXMLElement *mainxml = [document.root childNamed:@"channel"];
    
       _channelArray = [NSMutableArray new];
    
    for (SMXMLElement *channel in [mainxml childrenNamed:@"item"]) {
		
        VideoItem *info = [VideoItem new];
		
		info.title = [channel valueWithPath:@"title"];
        info.videoUrl = [channel valueWithPath:@"link"];
        info.dateTime = [channel valueWithPath:@"pubDate"];
        
        NSLog(@"Title: %@", info.title);
        [_channelArray addObject:info];
        
	}
    
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_channelArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCell";
    
    YouTubeCell *cell = (YouTubeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    
    VideoItem *videoItem = [_channelArray objectAtIndex:indexPath.row];
    
    cell.ytTitle.text =videoItem.title;
    
    NSString *youTubeID = [videoItem.videoUrl substringFromIndex:31];
    NSString *youTubeID2 = [youTubeID substringToIndex:([videoItem.videoUrl length] - 53)];
    
    NSLog(@"YouTubeID: %@", youTubeID2);
    
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://i4.ytimg.com/vi/%@/hqdefault.jpg",youTubeID2]];
	NSString *key = [[NSString stringWithFormat:@"http://i4.ytimg.com/vi/%@/hqdefault.jpg",youTubeID2] MD5Hash];
	NSData *data = [ISCache objectForKey:key];
	if (data) {
		UIImage *image = [UIImage imageWithData:data];
		cell.ytThumbnail.image = image;
	} else {
		cell.ytThumbnail.image = [UIImage imageNamed:@"hqdefault.jpg"];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			NSData *data = [NSData dataWithContentsOfURL:imageURL];
			[ISCache setObject:data forKey:key];
			UIImage *image = [UIImage imageWithData:data];
			dispatch_sync(dispatch_get_main_queue(), ^{
				cell.ytThumbnail.image = image;
			});
		});
	}
    
    NSString *dateString = videoItem.dateTime;
    
    cell.ytDate.text = [dateString substringToIndex:([videoItem.dateTime length] - 14)];
    cell.ytAuthor.text = CHANNEL_TITLE;
    
    return cell;
    
    
}
- (void)tableView: (UITableView *)tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *)indexPath
{
    

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ISCustomAccessory *accessory = [ISCustomAccessory accessoryWithColor:ACCESSORY_COLOR];
    accessory.highlightedColor = ACCESSORY_COLOR_HIGHLIGHTED;
    cell.accessoryView =accessory;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoItem *videoItem = [_channelArray objectAtIndex:indexPath.row];
    NSString *youTubeID = [videoItem.videoUrl substringFromIndex:31];
    NSString *youTubeID2 = [youTubeID substringToIndex:([videoItem.videoUrl length] - 53)];
    
    _extractor = [[LBYouTubeExtractor alloc] initWithID:youTubeID2 quality:LBYouTubeVideoQualityLarge];
    
        
    // Setup the player controller and add it's view as a subview:
    
    
     Reachability *reachability = [Reachability reachabilityForInternetConnection];
     [reachability startNotifier];
     
     NetworkStatus status = [reachability currentReachabilityStatus];
     
     if (status == ReachableViaWiFi)
     {
     self.highQuality= LBYouTubeVideoQualityLarge;
     }
     else if (status == ReachableViaWWAN)
     {
     self.highQuality = LBYouTubeVideoQualitySmall;
     }
    
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    LBYouTubePlayerViewController* controller = [[LBYouTubePlayerViewController alloc] initWithYouTubeID:youTubeID2 quality:self.highQuality];
    controller.delegate = self;
    [self presentMoviePlayerViewControllerAnimated:controller];
    UIGraphicsEndImageContext();
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (setCategoryError) {  }
    
    NSError *activationError = nil;
    [audioSession setActive:YES error:&activationError];
    if (activationError) {  }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}


-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    // Refresh table here...
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self fetchEntries];
    [self.tableView reloadData];
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh
{
    [self.refreshControl endRefreshing];
    // show in the status bar that network activity is stoping
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"You must have an active network connection in order to Video" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
    
}


#pragma mark LBYouTubePlayerViewControllerDelegate

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    //NSLog(@"Did extract video source:%@", videoURL);
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error {
    //NSLog(@"Failed loading video due to error:%@", error);
}

#pragma mark -


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
