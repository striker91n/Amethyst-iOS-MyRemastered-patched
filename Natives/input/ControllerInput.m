#import "ControllerInput.h"
#import "../LauncherPreferences.h"
#import "../PLProfiles.h"
#import "../SurfaceViewController.h"
#import "../utils.h"

#include "../glfw_keycodes.h"

// Left thumbstick directions
#define DIRECTION_EAST 0
#define DIRECTION_NORTH_EAST 1
//#define DIRECTION_NORTH 2
#define DIRECTION_NORTH_WEST 3
//#define DIRECTION_WEST 4
#define DIRECTION_SOUTH_WEST 5
//#define DIRECTION_SOUTH 6
#define DIRECTION_SOUTH_EAST 7
#define MOUSE_MAX_ACCELERATION 2

CFAbsoluteTime lastFrameTime;
CGFloat lastXValue; // lastHorizontalValue
CGFloat lastYValue; // lastVerticalValue

@implementation ControllerInput

NSMutableDictionary *gameMap, *menuMap;
BOOL leftShiftHeld;
static GCController *currentController;

+ (void)initKeycodeTable {
    if (gameMap && menuMap) {
        return;
    }
    
    NSString *controlFile = [PLProfiles resolveKeyForCurrentProfile:@"defaultGamepadCtrl"];
    NSString *gamepadPath = [NSString stringWithFormat:@"%s/controlmap/gamepads/%@", getenv("POJAV_HOME"), controlFile];
    NSMutableDictionary *gamepadJSON = parseJSONFromFile(gamepadPath);
    
    gameMap = gamepadJSON[@"mGameMappingList"];
    menuMap = gamepadJSON[@"mMenuMappingList"];
}

+ (void)sendKeyEvent:(int)controllerKeycode pressed:(BOOL)pressed {
    int keycode;
    __block NSMutableDictionary *mapping;
    if (isGrabbing) {
        mapping = gameMap;
    } else {
        mapping = menuMap;
    }
    
    for (NSMutableDictionary *buttonDict in mapping) {
        if(controllerKeycode == [buttonDict[@"gamepad_button"] intValue]) {
            keycode = [buttonDict[@"keycode"] intValue];
        }
    }

    switch (keycode) {
        case GLFW_KEY_UNKNOWN:
            // Do nothing
            break;
        case -GLFW_KEY_LEFT_SHIFT:
            if (!pressed) {
                leftShiftHeld = !leftShiftHeld;
                CallbackBridge_nativeSendKey(GLFW_KEY_LEFT_SHIFT, 0, leftShiftHeld, 0);
            }
            break;
        case SPECIALBTN_MOUSEPRI:
            CallbackBridge_nativeSendMouseButton(GLFW_MOUSE_BUTTON_LEFT, pressed, 0);
            break;
        case SPECIALBTN_MOUSEMID:
            CallbackBridge_nativeSendMouseButton(GLFW_MOUSE_BUTTON_MIDDLE, pressed, 0);
            break;
        case SPECIALBTN_MOUSESEC:
            CallbackBridge_nativeSendMouseButton(GLFW_MOUSE_BUTTON_RIGHT, pressed, 0);
            break;
        case SPECIALBTN_SCROLLUP:
            CallbackBridge_nativeSendScroll(0, pressed ? 1 : 0);
            break;
        case SPECIALBTN_SCROLLDOWN:
            CallbackBridge_nativeSendScroll(0, pressed ? -1 : 0);
            break;
        default:
            if (keycode == GLFW_KEY_LEFT_SHIFT) {
                leftShiftHeld = pressed;
            }
            CallbackBridge_nativeSendKey(keycode, 0, pressed, 0);
            break;
    }
}

+ (void)registerControllerCallbacks:(GCController *)controller {
    currentController = controller;
    // Disabled - Controllable handles input directly
}

/**
 * Send the new mouse position, computing the delta
 */
+ (void)tick {
    // Disabled - Controllable handles input directly
}

+ (void)unregisterControllerCallbacks:(GCController *)controller {
    currentController = nil;
}

@end
