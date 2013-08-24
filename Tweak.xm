//SliderKiller by Julian "insanj" Weiss
//(c) 2013 Julian Weiss, see full license in README.md

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface SBAwayView
-(void)lockBarUnlocked:(id)unlocked;
@end

@interface SBAwayBulletinCell
-(void)lockBarUnlocked:(id)unlocked;
@end

@interface SBAwayBulletinListController
-(id)unlockActionContext;
-(id)visibleActionContext;
@end

%hook SBAwayView
-(void)lockBarUnlocked:(id)unlocked{
	NSLog(@"SliderKiller: unlocked using lockbar.");
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"unlockedWithBulletin"];
	%orig(unlocked);
}
%end

%hook SBAwayBulletinCell
-(void)lockBarUnlocked:(id)unlocked{
	NSLog(@"SliderKiller: unlocked using bulletin.");
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"unlockedWithBulletin"];
	%orig(unlocked);
}
%end

%hook SBAwayBulletinListController
-(id)unlockActionContext{
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"unlockedWithBulletin"])
		return %orig;
	return nil;
}

-(id)visibleActionContext{
	return nil;
}
%end


/*
//Sets default boolean "bulletinSlide" to YES if a lockscreen bulletin was swiped
-(void)lockBarStoppedTracking:(id)tracking{
	NSLog(@"\n\n\nstoppedtracking");
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"bulletinSlide"];
	%orig(tracking);
}

//Sets default boolean "bulletinSlide" to NO if a lockscreen bulletin returned to origin
-(void)lockBarSlidBackToOrigin:(id)origin{
	NSLog(@"\n\n\nslidback");
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"bulletinSlide"];
	%orig(origin);
}
%end

/*
%hook SBAwayListActionContext

@interface SBAwayListActionContext
-(id)unlockAction;
@end

//Prevents the lockscreen slider from opening into an application.
-(id)unlockAction{

	//Creates a block for the current unlockAction.
	void (^orig)() = %orig();
	void (^wrapper)() = ^{
		orig();
	};

	if(%orig != nil)
		lastAction = [[wrapper copy] retain];	//Store the unchanged action.

	if([[NSUserDefaults standardUserDefaults] boolForKey:@"bulletinSlide"])
		return lastAction;

	return nil;
}
%end


/*
%hook SBAwayListActionContext

//Prevents the lockscreen slider from opening into an application.
-(id)unlockAction{

	//Creates a block for the current unlockAction.
	void (^orig)() = %orig();
	void (^wrapper)() = ^{
		orig();
	};

	if(%orig != nil)
		lastAction = [[wrapper copy] retain];	//Store the unchanged action.

	if([[NSUserDefaults standardUserDefaults] boolForKey:@"bulletinSlide"])
		return lastAction;

	return %orig;
}
%end



/*
static NSObject* lastAction;

@interface TPBottomLockBar
-(void)setKnobWellWidth:(float)width;
-(void)setKnobWellWidthToDefault;
-(void)knobDragged:(float)dragged;
@end

@interface SBAwayLockBar
-(void)setShowsCameraGrabber:(BOOL)grabber;
@end

@interface SBAwayListActionContext
-(id)unlockAction;
-(id)lockLabel;
-(id)bulletinID;
-(id)_initWithLockLabel:(id)lockLabel shortLockLabel:(id)label unlockAction:(id)action bulletinID:(id)anId;
@end

@interface TPLockTextView
- (id)initWithLabel:(id)arg1 fontSize:(float)arg2 trackWidthDelta:(float)arg3;
@end

@interface SBAwayBulletinCell
-(void)lockBarStoppedTracking:(id)tracking;
-(void)lockBarSlidBackToOrigin:(id)origin;
@end

%hook TPBottomLockBar

//Sets the well-width to the lowest possible value it would usually be. This
//is to avoid conflicting with any other settings (or visibility of the grabber)
//that have been made in regards to the slider (and should help with iPad 
//compatibility later on). Usually this method would simply be "%orig(232)",
//where 232 is the default width of the well with the camera grabber present.
-(void)setKnobWellWidth:(float)width{
	if( ([[NSUserDefaults standardUserDefaults] floatForKey:@"wellWidth"] > width && width != 0) || ([[NSUserDefaults standardUserDefaults] floatForKey:@"wellWidth"] == 0) )
		[[NSUserDefaults standardUserDefaults] setFloat:width forKey:@"wellWidth"];

	float wellWidth = [[NSUserDefaults standardUserDefaults] floatForKey:@"wellWidth"];
	%orig(wellWidth);
}


//Circumvents the setting of the well-width to the default size, and makes it
//set to the size that was predicated by the method above (which should be)
//the ideal size for the slider w/out a notification.
-(void)setKnobWellWidthToDefault{
	[self setKnobWellWidth:[[NSUserDefaults standardUserDefaults] floatForKey:@"wellWidth"]];
}

%end


%hook SBAwayLockBar

//Records what the default visibility of the grabber is (on first launch), and
//makes sure that is always the state of the grabber. So, if the grabber is visible
//the first time that SliderKiller is active, then it will always be visible, and
//vice-versa.
-(void)setShowsCameraGrabber:(BOOL)grabber{
	if([[NSUserDefaults standardUserDefaults] floatForKey:@"grabberValue"] == 0){
		if(grabber)
			[[NSUserDefaults standardUserDefaults] setFloat:1 forKey:@"grabberValue"];
		else
			[[NSUserDefaults standardUserDefaults] setFloat:2 forKey:@"grabberValue"];
	}//end if

	float grabberValue = [[NSUserDefaults standardUserDefaults] floatForKey:@"grabberValue"];
	if(grabberValue == 1)
		%orig(YES);
	else
		%orig(NO);
}
%end



%hook SBAwayListActionContext

//Prevents the lockscreen slider from opening into an application.
-(id)unlockAction{

	//Creates a block for the current unlockAction.
	void (^orig)() = %orig();
	void (^wrapper)() = ^{
		orig();
	};

	//If the current value of unlockAction has been unchanged by SliderKiller.
	if(%orig != nil){
		lastAction = [[wrapper copy] retain];	//Store the unchanged action.

		//If the user was sliding on a bulletin, instead of the oridinary style, check
		//then return the unchanged unlockAction -- there's a catch here where unlockAction
		//will run twice, and so the first time we go into this if we have to check if it
		//has already just run ("resetBulletin" will be false the first run-through).
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"bulletinSlide"]) {
			if([[NSUserDefaults standardUserDefaults] boolForKey:@"resetBulletin"]){
				[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"bulletinSlide"];
				[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"resetBulletin"];
			}

			else
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"resetBulletin"];
			
			return lastAction;
		}//end if
	}//end papa if

	//If SliderKiller has already "killed" the original action.
	if(%orig == nil)
		return lastAction;

	return nil;
}

/*
-(id)_initWithLockLabel:(id)lockLabel shortLockLabel:(id)label unlockAction:(id)action bulletinID:(id)anId{
	NSLog(@"\n\ninit!\n\naction:%@", action);
	return %orig(lockLabel, label, action, anId);
}//

%end


%hook TPLockTextView

//Records the default values for the slider label and font size (what was set
//initially), and always sets the respective values to that in future instances.
-(id)initWithLabel:(id)arg1 fontSize:(float)arg2 trackWidthDelta:(float)arg3{
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"labelValue"] == nil){
		[[NSUserDefaults standardUserDefaults] setObject:arg1 forKey:@"labelValue"];
		[[NSUserDefaults standardUserDefaults] setFloat:arg2 forKey:@"sizeValue"];
		
		return %orig(arg1, arg2, arg3);
	}//end if

	return %orig([[NSUserDefaults standardUserDefaults] objectForKey:@"labelValue"], [[NSUserDefaults standardUserDefaults] floatForKey:@"sizeValue"], arg3);
}
%end

%hook SBAwayBulletinCell

//Sets default boolean "bulletinSlide" to YES if a lockscreen bulletin was swiped
-(void)lockBarStoppedTracking:(id)tracking{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"bulletinSlide"];
	%orig(tracking);
}

//Sets default boolean "bulletinSlide" to NO if a lockscreen bulletin returned to origin
-(void)lockBarSlidBackToOrigin:(id)origin{
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"bulletinSlide"];
	%orig(origin);
}
%end*/