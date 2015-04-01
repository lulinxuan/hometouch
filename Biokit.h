

@interface BiometricKit : NSObject

+ (id)manager;

- (void)homeButtonPressed;

@end

@protocol SBUIBiometricEventMonitorDelegate
@required
-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event;
@end


@interface SBUIBiometricEventMonitor{
    bool _matchingEnabled;
    bool _fingerDetectionEnabled;
    bool _screenIsOff;
    bool _deviceLocked;
    bool _lockScreenTopmost;
    bool _shouldSendFingerOffNotification;
}

@property(getter=isMatchingEnabled,readonly) bool matchingEnabled;
@property(readonly) unsigned long long lockoutState;

+ (id)sharedInstance;
- (void)setMatchingDisabled:(bool)arg1 requester:(id)arg2;
- (void)_setDeviceLocked:(bool)arg1;
- (void)_setMatchingEnabled:(bool)arg1;
- (void)_startMatching;

- (void)setFingerDetectEnabled:(bool)arg1 requester:(id)arg2;

- (void)_stopFingerDetection;
- (void)_startFingerDetection;

- (bool)isMatchingEnabled;

- (void)setDelegate:(id)arg1;
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;


@end