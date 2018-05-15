//
//  SJMovieDecode.h
//  SJPlayerController
//
//  Created by sensetimesunjian on 2018/5/15.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

extern NSString *SJMovieErrorMomain;

typedef NS_ENUM(NSUInteger, SJMovieError) {
    SJMovieErrorNone,
    SJMovieErrorOpenFile,
    SJMovieErrorStreamInfoNotFound,
    SJMovieErrorStreamNotFound,
    SJMovieErrorCodecNotFound,
    SJMovieErrorOpenCodec,
    SJMovieErrorAllocateFrame,
    SJMovieErrorSetupScaler,
    SJMovieErrorReSampler,
    SJMovieErrorUnsupported,
};


typedef NS_ENUM(NSUInteger, SJMovieFrameType) {
    SJMovieFrameTypeAudio,
    SJMovieFrameTypeVideo,
    SJMovieFrameTypeArtwork,
    SJMovieFrameTypeSubtitle,
};

typedef NS_ENUM(NSUInteger, SJVideoFrameFormat) {
    SJVideoFrameFormatRGB,
    SJVideoFrameFormatYUV,
};

@interface SJMovieFrame : NSObject
@property (nonatomic, readonly) SJMovieFrameType type;
@property (nonatomic, readonly) CGFloat position;
@property (nonatomic, readonly) CGFloat duration;
@end

@interface SJAudioFrame : SJMovieFrame
@property (nonatomic, readonly, strong) NSData *samples;
@end

@interface SJVideoFrame : SJMovieFrame
@property (nonatomic, readonly) SJVideoFrameFormat format;
@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@end

@interface SJVideoFrameRGB : SJVideoFrame
@property (nonatomic, readonly) NSUInteger lineSize;
@property (nonatomic, readonly, strong) NSData *rgb;
- (UIImage *)asImage;
@end

@interface SJVideoFrameYUV : SJVideoFrame
@property (nonatomic, readonly, strong) NSData *luma;
@property (nonatomic, readonly, strong) NSData *chromaB;
@property (nonatomic, readonly, strong) NSData *chromaR;
@end

@interface SJArtworkFrame : SJMovieFrame
@property (nonatomic, readonly, strong) NSData *picture;
- (UIImage *)asImage;
@end

@interface SJSubtileFrame : SJMovieFrame
@property (nonatomic, readonly, copy) NSString *text;
@end

typedef BOOL(^SJMovieDecoderInterruptCallback)(void);

@interface SJMovieDecode : NSObject
@property (nonatomic, readonly, strong) NSString *path;
@property (nonatomic, readonly) BOOL isEOF;
@property (nonatomic, readonly) CGFloat position;
@property (nonatomic, readonly) CGFloat duration;
@property (nonatomic, readonly) CGFloat fps;
@property (nonatomic, readonly) CGFloat sampleRate;
@property (nonatomic, readonly) int frameWidth;
@property (nonatomic, readonly) int frameHeight;
@property (nonatomic, readonly) NSUInteger audioStreamsCount;
@property (nonatomic, readonly) NSUInteger selectedAudioStream;
@property (nonatomic, readonly) NSUInteger subtitleStreamsCount;
@property (nonatomic, readonly) NSUInteger selectedSubtitleStream;
@property (nonatomic, readonly) BOOL validVideo;
@property (nonatomic, readonly) BOOL validAudio;
@property (nonatomic, readonly) BOOL validSubtitle;
@property (nonatomic, readonly, strong) NSDictionary *info;
@property (nonatomic, readonly, copy) NSString *videoStreamFromatName;
@property (nonatomic, readonly) BOOL isNetwork;
@property (nonatomic, readonly) float startTime;
@property (nonatomic, readonly) BOOL disableDeinterlacing;
@property (nonatomic, copy)     SJMovieDecoderInterruptCallback interruptCallback;
+ (id)movieDecodeWithContentPath:(NSString *)path
                           error:(NSError **)error;
- (BOOL)openFile:(NSString *)path
           error:(NSError **)error;
- (void)closeFile;
- (BOOL)setupVideoFrameFormat:(SJVideoFrameFormat)format;
- (NSArray *)decodeFrames:(float)minDuration;
@end

@interface SJMovieSubtitleASSParser : NSObject
+ (NSArray *)parseEvents:(NSString *)events;
+ (NSArray *)parseDialogue:(NSString *)dialogue
                 numFields:(NSUInteger)numFields;
+ (NSString *)removeCommandsFromEventText:(NSString *)text;
@end
