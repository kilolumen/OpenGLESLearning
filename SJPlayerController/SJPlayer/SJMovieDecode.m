//
//  SJMovieDecode.m
//  SJPlayerController
//
//  Created by sensetimesunjian on 2018/5/15.
//  Copyright © 2018年 sensetimesj. All rights reserved.
//

#import "SJMovieDecode.h"
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>
#import <libswresample/swresample.h>
#import <libavutil/pixdesc.h>

NSString * SJMovieErrorDomain = @"sensetime.sjplayer";
static void FFLog(void *context, int level, const char *format, va_list args);

static NSError * sjMovieError(NSInteger code, id info)
{
    NSDictionary *userInfo = nil;
    if ([info isKindOfClass:[NSDictionary class]]) {
        userInfo = info;
    }else if ([info isKindOfClass:[NSString class]]){
        userInfo = @{NSLocalizedDescriptionKey : info};
    }
    return [NSError errorWithDomain:SJMovieErrorDomain
                               code:code
                           userInfo:userInfo];
}

static NSString * errorMessage (SJMovieError errorCode)
{
    switch (errorCode) {
        case SJMovieErrorNone:
            return @"";
        case SJMovieErrorOpenFile:
            return NSLocalizedString(@"Unable to open file", nil);
        case SJMovieErrorStreamInfoNotFound:
            return NSLocalizedString(@"Unable to find stream infomation", nil);
        case SJMovieErrorStreamNotFound:
            return NSLocalizedString(@"Unable to find stream", nil);
        case SJMovieErrorCodecNotFound:
            return NSLocalizedString(@"Unable to find codec", nil);
        case SJMovieErrorOpenCodec:
            return NSLocalizedString(@"Unable to open codec", nil);
        case SJMovieErrorAllocateFrame:
            return NSLocalizedString(@"Unable to allocate frame", nil);
        case SJMovieErrorSetupScaler:
            return NSLocalizedString(@"Unable to setup scaler", nil);
        case SJMovieErrorReSampler:
            return NSLocalizedString(@"Unable to setup resampler", nil);
        case SJMovieErrorUnsupported:
            return NSLocalizedString(@"The ability is not supported", nil);
    }
}

//timeBase && fps
static void avStreamFPSTimeBase(AVStream *st, CGFloat defaultTimeBase, CGFloat *pFPS, CGFloat *pTimeBase)
{
    CGFloat fps, timebase;
    if (st->time_base.den && st->time_base.num) {//den:分母 num：分数
        timebase = av_q2d(st->codec->time_base);//AVRational-->double
    }else if(st->codec->time_base.den && st->codec->time_base.num){
        timebase = av_q2d(st->codec->time_base);
    }else{
        timebase = defaultTimeBase;
    }
    
    if (st->avg_frame_rate.den && st->avg_frame_rate.num) {
        fps = av_q2d(st->avg_frame_rate);
    }else if (st->r_frame_rate.den && st->r_frame_rate.num){
        fps = av_q2d(st->r_frame_rate);
    }else{
        fps = 1.0/timebase;
    }
    
    if (pFPS) {
        *pFPS = fps;
    }
    if (pTimeBase) {
        *pTimeBase = timebase;
    }
}

static NSArray *collectStreams(AVFormatContext *formatCtx, enum AVMediaType codecType)
{
    NSMutableArray *ma = [NSMutableArray array];
    for (int i = 0; i < formatCtx->nb_streams; ++i) {
        if (codecType == formatCtx->streams[i]->codec->codec_type) {
            [ma addObject:[NSNumber numberWithInt:i]];
        }
    }
    return [ma copy];
}

static NSData * copyFrameData(UInt8 *src, int linesize, int width, int height)
{
    width  = MIN(linesize, width);
    NSMutableData *md = [NSMutableData dataWithLength:width * height];
    Byte *dst = md.mutableBytes;
    for(int i = 0; i < height; ++i){
        memcpy(dst, src, width);
        dst += width;
        src += linesize;
    }
    return md;
}

static BOOL isNetworkPath (NSString *path)
{
    NSRange r = [path rangeOfString:@":"];
    if (r.location == NSNotFound) {
        return NO;
    }
    NSString *scheme = [path substringToIndex:r.length];
    if ([scheme isEqualToString:@"file"]) {
        return NO;
    }
    return YES;
}

static int interrupt_callback(void *ctx);

////////////////////////////////////////////////////

@interface SJMovieFrame ()
@property (nonatomic, readwrite) CGFloat position;
@property (nonatomic, readwrite) CGFloat duration;
@end
@implementation SJMovieFrame
@end

@interface SJAudioFrame ()
@property (nonatomic, readwrite, strong) NSData *samples;
@end
@implementation SJAudioFrame
- (SJMovieFrameType)type{
    return SJMovieFrameTypeAudio;
}
@end

@interface SJVideoFrame ()
@property (nonatomic, readwrite) NSUInteger width;
@property (nonatomic, readwrite) NSUInteger height;
@end
@implementation SJVideoFrame
-(SJMovieFrameType)type{
    return SJMovieFrameTypeVideo;
}
@end

@interface SJVideoFrameRGB ()
@property (nonatomic, readwrite) NSUInteger linesize;
@property (nonatomic, readwrite, strong) NSData *rgb;
@end
@implementation SJVideoFrameRGB
- (SJVideoFrameFormat)format{
    return SJVideoFrameFormatRGB;
}
- (UIImage *)asImage
{
    UIImage *image = nil;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(_rgb));
    if (provider) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace) {
            CGImageRef imageRef = CGImageCreate(self.width, self.height, 8, 24, self.lineSize, colorSpace, kCGBitmapByteOrderDefault, provider, NULL, YES, kCGRenderingIntentDefault);
            if (imageRef) {
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
            CGColorSpaceRelease(colorSpace);
        }
        CGDataProviderRelease(provider);
    }
    return image;
}
@end

@interface SJVideoFrameYUV()
@property (readwrite, nonatomic, strong) NSData *luma;
@property (readwrite, nonatomic, strong) NSData *chromaB;
@property (readwrite, nonatomic, strong) NSData *chromaR;
@end

@implementation SJVideoFrameYUV
- (SJVideoFrameFormat) format { return SJVideoFrameFormatYUV; }
@end

@interface SJArtworkFrame()
@property (readwrite, nonatomic, strong) NSData *picture;
@end

@implementation SJArtworkFrame
- (SJMovieFrameType) type { return SJMovieFrameTypeArtwork;
}
- (UIImage *) asImage
{
    UIImage *image = nil;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(_picture));
    if (provider) {
        
        CGImageRef imageRef = CGImageCreateWithJPEGDataProvider(provider,
                                                                NULL,
                                                                YES,
                                                                kCGRenderingIntentDefault);
        if (imageRef) {
            
            image = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        CGDataProviderRelease(provider);
    }
    
    return image;
    
}
@end

@interface SJSubtileFrame()
@property (readwrite, nonatomic, strong) NSString *text;
@end

@implementation SJSubtileFrame
- (SJMovieFrameType) type { return SJMovieFrameTypeSubtitle; }
@end

@interface SJMovieDecode ()
{
    AVFormatContext *_formatCtx;
    AVCodecContext  *_videoCodecCtx;
    AVCodecContext  *_audioCodecCtx;
    AVCodecContext  *_subtitleCodecCtx;
    AVFrame         *_videoFrame;
    AVFrame         *_audioFrame;
    NSInteger       _videoStream;
    NSInteger       _audioStream;
    NSInteger       _subtitleStream;
    AVPicture       _picture;
    BOOL            _pictureValid;
    struct SwsContext *_swsContext;
    CGFloat         _videoTimeBase;
    CGFloat         _audioTimeBase;
    CGFloat         _position;
    NSArray         *_videoStreams;
    NSArray         *_audioStreams;
    NSArray         *_subtitleStreams;
    SwrContext      *_swrContext;
    void            *_swrBuffer;
    NSUInteger      _swrBufferSize;
    NSDictionary    *_info;
    NSUInteger      _artwrokStream;
    SJVideoFrameFormat _videoFrameFormat;
    NSUInteger      _artworkStream;
    NSInteger       _subtitleASSEvent;
    
}
@end
@implementation SJMovieDecode
- (CGFloat)duration
{
    if (!_formatCtx) {
        return 0;
    }
    if (_formatCtx->duration == AV_NOPTS_VALUE) {
        return MAXFLOAT;
    }
    return (CGFloat)_formatCtx->duration/AV_TIME_BASE;
}

- (CGFloat)position
{
    return _position;
}

- (void)setPosition:(CGFloat)position
{
    _position = position;
    _isEOF = NO;
    if (_videoFrame != -1) {
        int64_t ts = (int64_t)(position/_videoTimeBase);
        avformat_seek_file(_formatCtx, _videoStream, ts, ts, ts, AVSEEK_FLAG_FRAME);
        avcodec_flush_buffers(_videoCodecCtx);
    }
    if (_audioStream != -1) {
        int64_t ts = (int64_t)(position/_audioTimeBase);
        avformat_seek_file(_formatCtx, _audioStream, ts, ts, ts, AVSEEK_FLAG_FRAME);
        avcodec_flush_buffers(_audioCodecCtx);
    }
}

- (int)frameWidth
{
    return _videoCodecCtx ? _videoCodecCtx->width : 0;
}

- (int)frameHeight
{
    return _videoCodecCtx ? _videoCodecCtx->height : 0;
}

- (CGFloat)sampleRate
{
    return _audioCodecCtx ? _audioCodecCtx->sample_rate : 0;
}

- (NSUInteger)audioStreamsCount
{
    return [_audioStreams count];
}

- (NSUInteger)subtitleStreamsCount
{
    return [_subtitleStreams count];
}

- (NSUInteger)selectedAudioStream
{
    if (_audioStream == -1) {
        return -1;
    }
    NSNumber *n = [NSNumber numberWithInteger:_audioStream];
    return [_audioStreams indexOfObject:n];
}

- (void)setSelectedAudioStream:(NSUInteger)selectedAudioStream
{
    NSInteger audioStream = [_audioStreams[selectedAudioStream] integerValue];
    [self closeAudioStream];
    SJMovieError errorCode = [self openAudioStream:audioStream];
    if (SJMovieErrorNone != errorCode) {
        NSLog(@"SJPlayer %@", errorMessage(errorCode));
    }
}

- (NSUInteger)selectedSubtitleStream
{
    if (_subtitleStream == -1) {
        return -1;
    }
    return [_subtitleStreams indexOfObject:!(_subtitleStream)];
}

- (void)setSelectedSubtitleStream:(NSUInteger)selectedSubtitleStream
{
    [self closeSubtitleStream];
    if (selectedSubtitleStream == -1) {
        _subtitleStream = -1;
    }else{
        NSInteger subtitleStream = [_subtitleStreams[selectedSubtitleStream] integerValue];
        SJMovieError errorCode = [self openSubtitleStream:subtitleStream];
        if (SJMovieErrorNone != errorCode) {
            NSLog(@"SJPlayer %@", errorMessage(errorCode));
        }
    }
}

- (BOOL)validAudio
{
    return _audioStream != -1;
}

- (BOOL)validVideo
{
    return _videoStream != -1;
}

- (BOOL)validSubtitle
{
    return _subtitleStream != -1;
}

- (NSDictionary *)info
{
    if (!_info) {
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        if (_formatCtx) {
            const char *formatName = _formatCtx->iformat->name;
            [md setValue:[NSString stringWithCString:formatName encoding:NSUTF8StringEncoding] forKey:@"format"];
            if (_formatCtx->bit_rate) {
                [md setValue:[NSNumber numberWithInt:_formatCtx->bit_rate] forKey:@"bitrate"];
            }
            if (_formatCtx->metadata) {
                NSMutableDictionary *md1 = [NSMutableDictionary dictionary];
                AVDictionaryEntry *tag = NULL;
                while ((tag = av_dict_get(_formatCtx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX))) {
                    [md1 setValue:[NSString stringWithCString:tag->value encoding:NSUTF8StringEncoding] forKey:[NSString stringWithCString:tag->key encoding:NSUTF8StringEncoding]];
                }
                [md setValue:[md1 copy] forKey:@"metadata"];
            }
            char buf[256];
            if (_videoStreams.count) {
                NSMutableArray *ma = [NSMutableArray array];
                for (NSNumber *n in _videoStreams) {
                    AVStream *st = _formatCtx->streams[n.integerValue];
                    avcodec_string(buf, sizeof(buf), st->codec, 1);
                    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    if ([s hasPrefix:@"Video: "]) {
                        s = [s substringFromIndex:@"Video: ".length];
                    }
                    [ma addObject:s];
                }
                md[@"video"] = ma.copy;
            }
            if (_audioStreams.count) {
                NSMutableArray *ma = [NSMutableArray array];
                for(NSNumber *n in _audioStreams){
                    AVStream *st = _formatCtx->streams[n.integerValue];
                    NSMutableString *ms = [NSMutableString string];
                    AVDictionaryEntry *lang = av_dict_get(st->metadata, "language", NULL, 0);
                    if (lang && lang->value) {
                        [ms appendFormat:@"%s", lang->value];
                    }
                    avcodec_string(buf, sizeof(buf), st->codec, 1);
                    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    if ([s hasPrefix:@"Audio: "]) {
                        s = [s substringFromIndex:@"Audio: ".length];
                    }
                    [ms appendString:s];
                    [ma addObject:ms.copy];
                }
                md[@"audio"] = ma.copy;
            }
            if (_subtitleStreams.count) {
                NSMutableArray *ma = [NSMutableArray array];
                for(NSNumber *n in _subtitleStreams){
                    AVStream *st = _formatCtx->streams[n.integerValue];
                    NSMutableString *ms = [NSMutableString string];
                    AVDictionaryEntry *lang = av_dict_get(st->metadata, "language", NULL, 0);
                    if (lang && lang->value) {
                        [ms appendFormat:@"%s ", lang->value];
                    }
                    avcodec_string(buf, sizeof(buf), st->codec, 1);
                    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    if ([s hasPrefix:@"Subtitle: "]) {
                        s = [s substringFromIndex:@"Subtitle: ".length];
                    }
                    [ms appendString:s];
                    [ma addObject:ms.copy];
                }
                md[@"subtitle"] = ma.copy;
            }
        }
        _info = [md copy];
    }
    return _info;
}

@end
