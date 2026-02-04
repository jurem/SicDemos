SIC = java -cp sictools.jar

OBJS = init.obj loop.obj v.obj inout.obj map.obj stack.obj

.SUFFIXES: .asm .obj
.asm.obj:
	$(SIC) sic.Asm $<

out.obj: $(OBJS)
	$(SIC) sic.Link -o $@ $(OBJS)

run:
	$(SIC) sic.Sim -text 80x25 -keyb 0xc000 -freq 5000000 out.obj

clean:
	rm -f *.log *.lst *.obj
