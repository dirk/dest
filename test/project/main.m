// Adapted from http://www.cocoawithlove.com/2010/09/minimalist-cocoa-programming.html
// Updated to work with ARC.

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

int main ()
{
  [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  // Set up the menubar
  id menubar = [NSMenu new];
  id appMenuItem = [NSMenuItem new];
  [menubar addItem:appMenuItem];
  [NSApp setMainMenu:menubar];
  // Set up the menu
  id appMenu = [NSMenu new];
  id appName = [[NSProcessInfo processInfo] processName];
  id quitTitle = [@"Quit " stringByAppendingString:appName];
  id quitMenuItem = [[NSMenuItem alloc] initWithTitle:quitTitle
                                              action:@selector(terminate:)
                                       keyEquivalent:@"q"];
  [appMenu addItem:quitMenuItem];
  [appMenuItem setSubmenu:appMenu];
  // Create our window
  id window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 200, 200)
                                          styleMask:NSTitledWindowMask
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
  [window cascadeTopLeftFromPoint:NSMakePoint(20,20)];
  [window setTitle:appName];
  [window makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
  [NSApp run];
  return 0;
}
