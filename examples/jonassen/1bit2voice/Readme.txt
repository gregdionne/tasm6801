This is a port of Simon Jonassen's "1bit2voice" program posted
in Facebook's TRS-80 MC-10 group.

Meaningful excerpt from the author:

    turn up the volume

    mini coco strikes back....

    about 5.6K of code/data running a timer irq of 7.5 Khz

    hey ma, you only gave me 1bit sound....

    go figure


Feel free to compile and run it.

tasm6801 can take multiple files, so you can do:

  tasm6801 1bit2voice.asm dyabit.asm

and it will happily concatenate the two source files in order.

If you want to have it run in the background while coding your
BASIC program you can just issue an RTS instruction at the 
"poop" label.  MICROCOLOR BASIC is generally interrupt safe
(except for file and other sound operations).

Good foot-tappin' 1-bit fun!
