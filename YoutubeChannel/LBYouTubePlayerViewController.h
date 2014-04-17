
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LBYouTubeExtractor.h"

@protocol LBYouTubePlayerControllerDelegate;

@interface LBYouTubePlayerViewController : MPMoviePlayerViewController <LBYouTubeExtractorDelegate>

@property (nonatomic, strong, readonly) LBYouTubeExtractor* extractor;
@property (nonatomic, weak) id <LBYouTubePlayerControllerDelegate> delegate;

-(id)initWithYouTubeID:(NSString*)youTubeID quality:(LBYouTubeVideoQuality)quality;

@end
@protocol LBYouTubePlayerControllerDelegate <NSObject>

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL;
-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error;

@end
