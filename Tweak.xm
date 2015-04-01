#import "BioKit.h"
#import <SpringBoard/SpringBoard.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <IOKit/hid/IOHIDEvent.h>

int held=0;

%hook SBUIBiometricEventMonitor


- (void)setMatchingDisabled:(bool)arg1 requester:(id)arg2{

NSLog(@"setMatchingDisabled");
NSLog(@"arg1=%d",arg1);
NSLog(@"%@",arg2);
%orig;
}
- (void)_setDeviceLocked:(bool)arg1{
%orig;
NSLog(@"_setDeviceLocked");
}
- (void)_setMatchingEnabled:(bool)arg1{
if(!self.matchingEnabled){
%orig(1);
}
NSLog(@"arg1=%d",arg1);
NSLog(@"_setMatchingEnabled");
}
- (void)_startMatching{
%orig;
NSLog(@"_startMatching");
}

- (void)setFingerDetectEnabled:(bool)arg1 requester:(id)arg2{
%orig;
NSLog(@"setFingerDetectEnabled");
}
- (void)_stopFingerDetection{
//%orig;
NSLog(@"_stopFingerDetection");
}
- (void)_startFingerDetection{
%orig;
NSLog(@"_startFingerDetection");
}

%end


#define TouchIDFingerDown  1
#define TouchIDFingerUp    0
#define TouchIDFingerHeld  2
#define TouchIDMatched     4
#define TouchIDNotMatched  9 // or 10 for iOS 7.1 & iOS 8.x, probably from now on
@interface AwesomeTouchIDController : NSObject <SBUIBiometricEventMonitorDelegate>{
BOOL _wasMatching;
BOOL isMonitoringEvents;
}
@end
@implementation AwesomeTouchIDController

-(void)biometricEventMonitor: (id)monitor handleBiometricEvent: (unsigned)touchEvent
{
SpringBoard *springboard = (SpringBoard *)[%c(SpringBoard) sharedApplication];
uint64_t abTime = mach_absolute_time();
IOHIDEventRef event;

switch (touchEvent)
{
case TouchIDFingerDown:
NSLog(@"TouchIDFingerDown");
event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, *(AbsoluteTime *)&abTime, 0xC, 0x40, YES, 0);
[springboard _menuButtonDown:event];
CFRelease(event);
held=1;
break;


case TouchIDFingerUp:
//[springboard _handleMenuButtonEvent];
event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, *(AbsoluteTime *)&abTime, 0xC, 0x40, YES, 0);
[springboard _menuButtonUp:event];
CFRelease(event);
held=0;
NSLog(@"TouchIDFingerUp");
break;
case TouchIDFingerHeld:
// finger was held
[springboard handleMenuDoubleTap];


NSLog(@"TouchIDFingerHeld");

break;
case TouchIDMatched:
{
NSLog(@"TouchIDMatched");

event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, *(AbsoluteTime *)&abTime, 0xC, 0x40, YES, 0);
[springboard _menuButtonUp:event];
CFRelease(event);
held=0;

break;
}
}
}
-(void)startMonitoringEvents
{
if(isMonitoringEvents)
{
NSLog(@"already monitored");
return;
}
NSLog(@"try to monitor");
isMonitoringEvents=YES;
id monitor=[objc_getClass("SBUIBiometricEventMonitor") sharedInstance];
NSLog(@"monitor=%@",monitor);

[[objc_getClass("BiometricKit") manager] setDelegate:monitor];
_wasMatching=[[monitor valueForKey:@"_matchingEnabled"] boolValue];
NSLog(@"%d",_wasMatching);
[monitor addObserver:self];
[monitor _setMatchingEnabled:YES];
[monitor _startMatching];
}

-(void)stoptMonitoringEvents
{
if (!isMonitoringEvents)
{
return;
}
id monitor=[[objc_getClass("BiometricKit") manager] delegate];
NSLog(@"monitor=%@",monitor);

[monitor removeObserver:self];
[monitor _setMatchingEnabled:_wasMatching];
isMonitoringEvents=NO;
}

-(void)dealloc{
[super dealloc];
NSLog(@"dealloc");
}

@end

%hook SpringBoard

AwesomeTouchIDController *touchIdController;

-(void)applicationDidFinishLaunching:(id)application{
%orig;
NSLog(@"run here");
touchIdController=[AwesomeTouchIDController alloc];
[touchIdController startMonitoringEvents];
NSLog(@"%@",touchIdController);
}
-(void)_menuButtonWasHeld{
if(!held){
%orig;
}
}


%end



