# Compiling multifile programs with Make

Normally, without scripting, the compilation can be quite tedious when building multi filed software. Combined with external packages and different compilation flags often one will need to tweak the compilation process ever so slightly. This can get quite complicated very quickly making software development a chore. To combat this there exists software such as Make and Cmake which help to organize and simplify building of complicated software.

On top of making you workflow easier it also allows for better portability of software. For example in the case that someone might want to build and run your software, in the optimal situation, nothing else is required for compilation except a single command `make`.

## Notes about the example software

The software generates the mandelbrot set. Pixel density can be changed by tweaking the variable n in the parameters.f90 module.

**Compile and run**:

    make && ./mandelbrot

Generates the mandelbrot.txt file with the so called heatmap of the mandelbrot set.

**Plotting**:

    python3 plot.py

**Dependencies**:

- matplotlib.pyplot
- numpy

## Compiling without make

Now given the program in this directory one might build it by running the following command

    gfortran -o mandelbrot parameters.f90 mandelbrot.f90 input_output.f90 main.f90

or in parts

```lang-bash
gfortran -c parameters.f90
gfortran -c mandelbrot.f90
gfortran -c input_output.f90
gfortran -c main.f90
gfortran -o mandelbrot parameters.o mandelbrot.o input_output.o main.o
```

Which would generate the executable `./mandelbrot`. That's all fine and dandy and isn't even that complicated. But keep in mind, that this software is still relatively simple. Add 10 more module files and 10 more compile flags, partnered with external dependencies that need to be linked and on top of that support for various different compilers and the permutations of their compiler flags, the compilation will get much more complicated.

For example take a look at this software ([CloverLeaf](https://github.com/UK-MAC/CloverLeaf_Serial/tree/b9a2b9c496b5eb1e7e30912d58e32d9dce930a0c)) and it's Makefile. Compiling that on the command line every time you make a change to a singular module is quite annoying.

## Compiling with make

To compile software with make you simply run

    make

This would generate the executable `./mandelbrot`. Now to cleanup the executable and mod files run

    make clean

Now when for example developing your software, every time you made a small change to it, you could simply run:

    make

## Brakedown of Makefile

Here is what a simple makefile would look like:

```Makefile
FC = gfortran

CFLAGS = -O3

SOURCES = parameters.f90 mandelbrot.f90 input_output.f90 main.f90
OBJECTS = $(subst .f90,.o,$(SOURCES))

PROGRAM = mandelbrot

$(PROGRAM): $(OBJECTS)
	$(FC) $(CFLAGS) -o $@ $^

%.o %.mod: %.f90
	$(FC) $(CFLAGS) -c -o $*.o $<
	@touch $@

mandelbrot.o: parameters.mod
input_output.o: parameters.mod
main.o: parameters.mod mandelbrot.mod input_output.mod


.PHONY: clean
clean: 
	rm -rf *.o *.mod $(PROGRAM) mandelbrot.txt mandelbrot.png
```

In make we can create variables just by assigning `VAR = something`. It is common practice to name these variables fully capitalized to be consistent with environment variables. This is something you don't need to worry about at the moment.

Now in the beginning we declare some variables

```Makefile
#Fortran compiler
FC = gfortran
#Compiler flags
CFLAGS = -O3
#Source files
SOURCES = parameters.f90 mandelbrot.f90 input_output.f90 main.f90
#Object files
#takes list of source files and swaps f90 with o
OBJECTS = $(subst .f90,.o,$(SOURCES))
#Final executable
PROGRAM = mandelbrot
```

This is so that adding modules or compiler flags or even changing the compiler can be done swiftly.

Now the general idea of make is that it generates new files based on existing files. Thus how you would interpret the line `$(PROGRAM): $(OBJECTS)` is that it generates the executable `$(PROGRAM)` based on the object (.o) files. Make will execute these statements linearly. When running `make` the first such command is the aforementioned  

```Makefile
$(PROGRAM): $(OBJECTS)
```

Which can be interpreted as

```Makefile
mandelbrot: parameters.o mandelbrot.o input_output.o main.o
```
Make will then search for the .o files in the current working directory (directory where the command make is executed) and proceed with the instruction

```Makefile
$(FC) $(CFLAGS) -o $@ $^
```

Now since the object and mod files don't exist yet, make will search for a command to generate the necessary files. Now since we have an arbitrary amount of `.f90` files and their corresponding `.o`/`.mod` files, make will proceed to find the instruction to generate each `.o`/`.mod` file. Thus make will arrive at the block

```Makefile
%.o %.mod: %.f90
    $(FC) $(CFLAGS) -c -o $*.o $<
	@touch $@
```

This will generate each independent `.o` and `.mod` files for their corresponding `.f90` file. Now since all of the `.f90` files exists make can proceed with the instruction. Now for example given the object file `parameters.o` the above could be interpreted as:

```Makefile
parameters.o parameters.mod: parameters.f90
    gfortran -O3 -c -o parameters.o parameters.f90
```

Where the argument `$<` means the first prerequisite, thus in this case all the independent `.f90` files. This section will generate the script:

```lang-bash
gfortran -O3 -c -o parameters.o parameters.f90
gfortran -O3 -c -o mandelbrot.o mandelbrot.f90
gfortran -O3 -c -o input_output.o input_output.f90
gfortran -O3 -c -o main.o main.f90
```

Now that all the object files exist make can revert back to the original target instruction:

```Makefile
$(PROGRAM): $(OBJECTS)
    $(FC) $(CFLAGS) -o $@ $^
```

Where `$@` refers to the target `$@ = $(PROGRAM) = mandelbrot` and `$^` all of the prerequisites, not just one of them. Thus this codeblock will generate the script

    gfortran -O3 -o mandelbrot parameters.o mandelbrot.o input_output.o main.o

Now during this course you don't need to worry about compiler flags, they are just there to point out the possible necessary modularity that make can offer.

The final part to note is the section:

```Makefile
.PHONY: clean
clean: 
    rm -rf *.o *.mod $(PROGRAM)
```

Here the `.PHONY` instruction is to declare targets that don't depend on files. The most common one is clean, which in our case will generate the script:
```Makefile
rm -rf *.o *.mod mandelbrot
```

This will just delete the executable and object files so that you can recompile from scratch.

The last part to note is the block that determines dependencies. Now if you happened to make a change for example in the paramteres.f90 file, you wouldn't want to recompile the whole program from scratch. Of course this program is so small in size that it wouldn't take very long but in full fledged software the building process can become a chore. Thus we arrive at the code block:

```Makefile
mandelbrot.o: parameters.mod
input_output.o: parameters.mod
main.o: parameters.mod mandelbrot.mod input_output.mod
```

This tells make the dependencies of each module. Parameters.f90 doesn't depend on anything, thus it doesn't have a separate section. Mandelbrot.f90 and input_output.f90 depend both on parameters.f90, and main depends on everything. Thus if you happened to make a change to one of these files, make will be able to detect it, and during the generation of the `.o/.mod` files it will be able to determine what object files need to be regenerated.

## Using the makefile

This makefile should be general enough to be able to use with any software built during TILAII. If the previous section seemed confusing, here I will lay out specifically what needs to be changed for it to work with anything. Firstly you need to change the list of source files on line 12:

```Makefile
    SOURCES = parameters.f90 mandelbrot.f90 input_output.f90 main.f90
```

Order shouldn't be of importance since the dependencies section will handle that. Next define the name of your output executable on line 16:

```Makefile
    PROGRAM = mandelbrot
```

Lastly you need to define the order of dependencies at the block:
```
mandelbrot.o: parameters.mod
input_output.o: parameters.mod
main.o: parameters.mod mandelbrot.mod input_output.mod
```

On the left side name the file that your defining dependencies for and on the right side list them. If a file is independent of everything you can leave it out.

Lastly you can either comment out the compile flags on line 9, or you can leave them be. They might add a little performance and optimization to your software, but it isn't relevant to this course.

Also note if you are using a different compiler, like clang or intel, then you must redefine your compile on line 6.
