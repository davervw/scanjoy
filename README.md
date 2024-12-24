# scanjoy - irq (every jiffy) scan of keyboard and joysticks avoiding conflict

Since joystick #1 and keyboard inputs are read from the same ports, they can conflict when the same lines are in use.   Joystick inputs can be mistaken for keyboard inputs, and vice versa.  Giving priority to the joystick and reading with the keyboard outputs disabled, conflicts are addressed.  Joystick #1 is read accurately, and while joystick inputs are active, the keyboard will ignore those lines on its reads.   So the joystick will not trigger keyboard inputs, and keyboard inputs will not trigger the joystick.  The only caveat is not being able to detect certain keystrokes while some joystick inputs are active.  It is expected that the user is only using one at a time.  When developing a game for simultaneous inputs, avoiding certain conflicting keystrokes (lower 5 columns of the keyboard matrix) will be necessary.

See the [scankeys](../scankeys) project for a demo of scanning the keyboard and you can see how joystick inputs conflict.

**NOTE: WORK IN PROGRESS.  CURRENT STATE IS DEMO PROTOTYPE IS MANUAL SCANNING WITHOUT CONFLICT.  PLANNED WORK IS TO UPDATE IRQ SCANNING TO CHANGE DEFAULT BEHAVIOR.**

Usage:

````
LOAD "SCANJOY",8,1
SYS 49152
````

Optional (demo prototype test comparing addressing with default behavior):
````
LOAD "TEST",8
RUN
````

![scanjoy.png](scanjoy.png)
