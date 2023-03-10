
#import <Foundation/Foundation.h>

extern NSString* const LBYouTubePlayerExtractorErrorDomain;
extern NSInteger const LBYouTubePlayerExtractorErrorCodeInvalidHTML;
extern NSInteger const LBYouTubePlayerExtractorErrorCodeNoStreamURL;
extern NSInteger const LBYouTubePlayerExtractorErrorCodeNoJSONData;

typedef void (^LBYouTubeExtractorCompletionBlock)(NSURL *videoURL, NSError *error);


typedef enum {
    LBYouTubeVideoQualitySmall    = 0,
    LBYouTubeVideoQualityMedium   = 1,
    LBYouTubeVideoQualityLarge    = 2,
} LBYouTubeVideoQuality;

@protocol LBYouTubeExtractorDelegate;

@interface LBYouTubeExtractor : NSObject

@property (nonatomic, readonly) LBYouTubeVideoQuality quality;
@property (nonatomic, strong, readonly) NSURL* youTubeURL;
@property (nonatomic, strong, readonly) NSURL *extractedURL;
@property (nonatomic, unsafe_unretained) IBOutlet id <LBYouTubeExtractorDelegate> delegate;
@property (nonatomic, strong) LBYouTubeExtractorCompletionBlock completionBlock;

-(id)initWithURL:(NSURL*)videoURL quality:(LBYouTubeVideoQuality)quality;
-(id)initWithID:(NSString*)videoID quality:(LBYouTubeVideoQuality)quality;

-(void)startExtracting;
-(void)stopExtracting;

@end
@protocol LBYouTubeExtractorDelegate <NSObject>

-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL;
-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor failedExtractingYouTubeURLWithError:(NSError *)error;

@end
