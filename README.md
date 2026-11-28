# Super-Merio-Game
COAL Lab Final Project

Instructor: Talha Dar

A 16-bit platform game written in x86 Assembly (NASM + DOSBox).

## Team

Name: Awaiz ur Rehman
Roll Number: 25F-3037
Modules: M1, M4, M5, M7, M8, M9



Name: Usman Habib
Roll Number: 25F-6503
Modules: M2, M3, M6, M10, M11, M12

## Build and run
Requirements: NASM and DOSBox 0.74-3 or later.

1. Open a command prompt in the project folder.
2. Run `build.bat`. It runs:
   ```
   nasm -f bin -i src\ src\mario.asm -o MARIO.COM -l mario.lst
   ```
3. `MARIO.COM` is created in the project folder.

## Run steps (DOSBox)

```
mount c C:\path\to\the\project\folder
c:
MARIO
```

## Controls
| Key | Action |
|---|---|
| Left / Right arrows | Walk left / right |
| Left Shift | Run (hold with an arrow key) |
| Space | Jump (hold for a higher jump, no double jump) |
| P | Pause and resume |
| Esc | Back to the title screen; exit from the title screen |
| Up / Down, Enter | Move in the menu and choose START GAME or EXIT |
| Enter | Continue on the Level Complete and Game Over screens |

There are no debug keys.

## Memory choices
- The program is one `.COM` segment (`ORG 100h`) that holds code, data and stack.
- At start-up the game checks PSP:0002 (the first segment after our memory block) to make sure DOS gave us enough memory for two more 64 KB segments. If not, it prints a message and exits.
- **Frame buffer:** segment `cs + 1000h` (our segment + 64 KB). All drawing goes here first, then it is copied to video memory (`0A000h`) with `REP MOVSW`.
- **HUD buffer:** segment `cs + 2000h`. It holds only the top HUD strip and is redrawn only when a number changes.
- The frame buffer is cleared with `REP STOSW`.
- Two copies of the level map are kept: `map_orig` (never changed) and `map_work` (changed by hit blocks and collected coins). A restart copies the original back with one `REP MOVSW`.


## Game states
- **TITLE:** start of the program and after Game Over or Level Complete. Up/Down move the highlight, Enter on START begins the game, Enter on EXIT or Esc leaves to DOS.
- **PLAYING:** the game itself. P pauses, Esc goes to the title, Mario dying goes to DYING, touching the flag goes to WIN.
- **PAUSED:** everything is frozen and the picture stays on screen with a PAUSED box. P resumes, Esc goes to the title.
- **DYING:** the death animation (Mario hops up and falls). Then it goes to LIFE LOST or GAME OVER.
- **LIFE LOST:** shows the world name and the lives left for about 2 seconds, then the level restarts.
- **WIN:** Mario slides down the pole and walks to the castle, then the Level Complete screen.
- **LEVEL COMPLETE:** shows score, coins and time bonus (time left x 50). Enter goes to the title.
- **GAME OVER:** shows the final score. Enter goes to the title.

## Deviations from the manual

- There is no own timer interrupt handler (INT 08h / INT 1Ch). The game speed comes from the VGA vertical retrace (port 3DAh): two screen refreshes make one frame, about 35 frames per second. No delay loops are used.
- Most procedures take their parameters on the stack, but some small helper procedures (for example the enemy record procedures) receive their input in registers such as SI.
- (Add any other differences you find while testing.)

## Bonus features

- Score pop-up of a coin above a hit "?" block.
- Walking pose animation of Mario (stand and run poses).
- (Add or remove items so that this list is true for your final version.)

## Known limitations

1. There is no sound.
2. The game has only one level.
3. The high score is not saved.
4. The game needs DOSBox (real mode) and its timing depends on the VGA retrace, not on the timer interrupt.
5. Enemy behaviour is simple (walk, turn, fall) and there is no fire flower.
