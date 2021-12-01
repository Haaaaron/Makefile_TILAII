###################################
# FOR INSTRUCTIONS READ README.md #
###################################

#Fortran compiler 
FC = gfortran

#Compile flags
CFLAGS = -O3

#Source files
SOURCES = parameters.f90 mandelbrot.f90 input_output.f90 main.f90 
OBJECTS = $(subst .f90,.o,$(SOURCES))

#Final executable
PROGRAM = mandelbrot

$(PROGRAM): $(OBJECTS)
	$(FC) $(CFLAGS) -o $@ $^

## compilation rules
%.o %.mod: %.f90
	$(FC) $(CFLAGS) -c -o $*.o $<
	@touch $@

mandelbrot.o: parameters.mod
input_output.o: parameters.mod
main.o: parameters.mod mandelbrot.mod input_output.mod


.PHONY: clean
clean: 
	rm -rf *.o *.mod $(PROGRAM) mandelbrot.txt mandelbrot.png