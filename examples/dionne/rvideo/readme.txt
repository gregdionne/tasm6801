This program patches the MC-10's MICROCOLOR BASIC so that text renders in reverse video (light characters on dark background).  

To use it, load the .C10 file into your favorite emulator via CLOADM.

Once you type EXEC, then MICROCOLOR BASIC will use the reverse video.

You can then subsequently CLOAD or quicktype other BASIC programs and the effect should persist (until you load another machine language program).
calling EXEC again will invert the screen.

It works by patching the BASIC extension vectors:
  $421F  exec addr      handles EXEC
  $4221  warm boot      so the RESET button also clears the screen.
  $4285  console in     cleans up after the blinking cursor
  $4288  console out    handles INPUT, PRINT; and the BASIC editor
  $42A0  command ext    handles CLS 

