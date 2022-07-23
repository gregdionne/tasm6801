screen_height=16
screen_width=32

set fs=createobject("scripting.filesystemobject")
set f=fs.createtextfile("tunnelmap.txt")

for y = 0 to screen_height - 1

    f.write(chr(9) & "fdb" & chr(9))
    
    for x = 0 to screen_width - 1
    
        relative_x = x - (screen_width*0.5) + 0.5
        relative_y = y - (screen_height*0.5) + 0.5

      
        relative_y = relative_y / 3		

        angle = atn(relative_x/relative_y)*(256/2)/3.1415

	angle=(angle*2) AND 255		'spokes = 4


        angle=hex(cint(angle))

        angle=cstr(angle)
        
        if len(angle) > 2 then
          angle=right(angle,2)
        end if

        if len(angle)=1 then angle = "0" & angle


	depth = 420/(sqr((relative_x^2)+(relative_y^2))+8)

        depth=hex(cint(depth *4) and 255)	'rings = 4

	if len(depth)=1 then depth = "0" & depth


        f.write("$" & depth & angle & ",")

    next 
    
    f.writeline
next

f.close
