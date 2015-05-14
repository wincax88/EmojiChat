//
//  YBAudioManager.m
//  ObjectALDemo
//
//  Created by michaelwong on 9/19/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import "YBAudioManager.h"
#import "OALSimpleAudio.h"

@interface YBAudioManager()

@property(nonatomic, retain) AVAudioPlayer *player;

@end

@implementation YBAudioManager

- (id)init
{
    self = [super init];
    if (self) {
        ;
    }
    return self;
}

#pragma mark Background Music

// Preload background music.
- (bool) preloadBg:(NSString*) path
{
    return [[OALSimpleAudio sharedInstance] preloadBg:path];
}

// Preload background music.
- (bool) preloadBg:(NSString*) path seekTime:(NSTimeInterval)seekTime
{
    return [[OALSimpleAudio sharedInstance] preloadBg:path seekTime:seekTime];
}

// Play whatever background music is preloaded.
- (bool) playBg
{
    return [[OALSimpleAudio sharedInstance] playBg];
}

// Play whatever background music is preloaded.
- (bool) playBgWithLoop:(bool) loop
{
    return [[OALSimpleAudio sharedInstance] playBgWithLoop:loop];
}

// Play the background music at the specified path.
- (bool) playBg:(NSString*) path
{
    return [[OALSimpleAudio sharedInstance] playBg:path];
}

// Play the background music at the specified path.
- (bool) playBg:(NSString*) path loop:(bool) loop
{
    return [[OALSimpleAudio sharedInstance] playBg:path loop:loop];
}

// Stop the background music playback and rewind.
- (void) stopBg
{
    return [[OALSimpleAudio sharedInstance] stopBg];
}

// play remote audio file
- (BOOL)playUrl:(NSString*)audioUrl
{
    if ([audioUrl length] <= 0) {
        return NO;
    }
    if (_player) {
        [_player stop];
        _player = nil;
    }
    if(!_player){
        NSData *audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:audioUrl]];
        if (audioData) {
            _player = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        }
        
    }
    if (_player) {
        NSError *setCategoryError = nil;
        if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                              withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                                    error:&setCategoryError]) {
            // handle error
            return NO;
        }
        _player.numberOfLoops=0;
        [_player prepareToPlay];
        [_player play];
    }
    return YES;
}

- (void)stopAvAudio
{
    if (_player) {
        [_player stop];
        _player = nil;
    }
}

// pause status
- (void)setBgPaused:(BOOL)value
{
    return [[OALSimpleAudio sharedInstance] setBgPaused:value];
}
- (BOOL)isBgPaused
{
    return [[OALSimpleAudio sharedInstance] bgPaused];
}
- (BOOL)isBgPlaying
{
    return [OALSimpleAudio sharedInstance].backgroundTrack.playing;
}

// mute status
- (void)setBgMuted:(BOOL)value
{
    return [[OALSimpleAudio sharedInstance] setBgMuted:value];
}
- (BOOL)isBgMuted
{
    return [[OALSimpleAudio sharedInstance] bgMuted];
}

// bg volume
- (void) setBgVolume:(float) value
{
    [[OALSimpleAudio sharedInstance] setBgVolume:value];
}

- (float) getBgVolume
{
    return [[OALSimpleAudio sharedInstance] bgVolume];
}

// time status
- (NSTimeInterval)getDuration
{
    return [OALSimpleAudio sharedInstance].backgroundTrack.duration;
}
- (NSTimeInterval)getCurrentTime
{
    return [OALSimpleAudio sharedInstance].backgroundTrack.currentTime;
}
- (void)setCurrentTime:(NSTimeInterval)value
{
    return [[OALSimpleAudio sharedInstance].backgroundTrack setCurrentTime:value];
}

#pragma mark Sound Effects

// Preload and cache a sound effect for later playback.
- (ALBuffer*) preloadEffect:(NSString*) filePath
{
    return [[OALSimpleAudio sharedInstance] preloadEffect:filePath];
}

// Unload a preloaded effect. Only unloads if no source is currently playing
- (bool) unloadEffect:(NSString*) filePath
{
    return [[OALSimpleAudio sharedInstance] unloadEffect:filePath];
}

// Unload all preloaded effects that are not currently being played (paused or not).
- (void) unloadAllEffects
{
    return [[OALSimpleAudio sharedInstance] unloadAllEffects];
}

// Play a sound effect with volume 1.0, pitch 1.0, pan 0.0, loop NO. The sound will be loaded
// and cached if it wasn't already.
- (id<ALSoundSource>) playEffect:(NSString*) filePath
{
    return [self playEffect:filePath loop:NO];
}

// Play a sound effect with volume 1.0, pitch 1.0, pan 0.0. The sound will be loaded and cached
// if it wasn't already.
- (id<ALSoundSource>) playEffect:(NSString*) filePath loop:(bool) loop
{
    if (self.soundOff) {
        return nil;
    }
    else {
        return [[OALSimpleAudio sharedInstance] playEffect:filePath loop:loop];
    }
}

// Stop ALL sound effect playback.
- (void) stopAllEffects
{
    return [[OALSimpleAudio sharedInstance] stopAllEffects];
}

- (void)playVibrateSound
{
    if (!self.soundOff) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

#pragma mark Utility

/** Stop all effects and bg music.
 */
- (void) stopEverything
{
    return [[OALSimpleAudio sharedInstance] stopEverything];
}

/** Reset everything in this object to its default state.
 */
- (void) resetToDefault
{
    return [[OALSimpleAudio sharedInstance] resetToDefault];
}

@end
