//
//  YBAudioManager.h
//  ObjectALDemo
//
//  Created by michaelwong on 9/19/14.
//  Copyright (c) 2014 taomee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALBuffer;
@protocol ALSoundSource;

@interface YBAudioManager : NSObject

#pragma mark Properties
@property(nonatomic, readwrite, assign) BOOL soundOff;

#pragma mark Background Music

// Preload background music.
- (bool) preloadBg:(NSString*) path;

// Preload background music.
- (bool) preloadBg:(NSString*) path seekTime:(NSTimeInterval)seekTime;

// Play whatever background music is preloaded.
- (bool) playBg;

// Play whatever background music is preloaded.
- (bool) playBgWithLoop:(bool) loop;

// Play the background music at the specified path.
- (bool) playBg:(NSString*) path;

// Play the background music at the specified path.
- (bool) playBg:(NSString*) path loop:(bool) loop;

// Stop the background music playback and rewind.
- (void) stopBg;

// play remote audio file
- (BOOL)playUrl:(NSString*)audioUrl;

// stop audio
- (void)stopAvAudio;

// pause status
- (void)setBgPaused:(BOOL)value;
- (BOOL)isBgPaused;
- (BOOL)isBgPlaying;

// mute status
- (void)setBgMuted:(BOOL)value;
- (BOOL)isBgMuted;

// bg volume
- (void) setBgVolume:(float) value;
- (float) getBgVolume;

// time status
- (NSTimeInterval)getDuration;
- (NSTimeInterval)getCurrentTime;
- (void)setCurrentTime:(NSTimeInterval)value;

#pragma mark Sound Effects

// Preload and cache a sound effect for later playback.
- (ALBuffer*) preloadEffect:(NSString*) filePath;

// Unload a preloaded effect. Only unloads if no source is currently playing
- (bool) unloadEffect:(NSString*) filePath;

// Unload all preloaded effects that are not currently being played (paused or not).
- (void) unloadAllEffects;

// Play a sound effect with volume 1.0, pitch 1.0, pan 0.0, loop NO. The sound will be loaded
// and cached if it wasn't already.
- (id<ALSoundSource>) playEffect:(NSString*) filePath;

// Play a sound effect with volume 1.0, pitch 1.0, pan 0.0. The sound will be loaded and cached
// if it wasn't already.
- (id<ALSoundSource>) playEffect:(NSString*) filePath loop:(bool) loop;

// Stop ALL sound effect playback.
- (void) stopAllEffects;

//  On some iOS devices, you can call this method to invoke vibration.
//  On other iOS devices this functionaly is not available, and calling this method does nothing.
- (void)playVibrateSound;


#pragma mark Utility

/** Stop all effects and bg music.
 */
- (void) stopEverything;

/** Reset everything in this object to its default state.
 */
- (void) resetToDefault;

@end
