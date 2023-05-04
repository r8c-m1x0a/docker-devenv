# r8c docker dev environment

This is docker image that can be used with Visual Studio Code remote development feature. If you just want to earn files for devcontainer to start your develoment, just go [here](https://github.com/r8c-m1x0a/devenv).

## Caveat

GCC 7.5.0 and later is not able to be built without tweaking. The following changes are incomporated:

### gcc/config/m32c/m32c.cc

GCC does not run without the following patch:

https://gcc.gnu.org/bugzilla//show_bug.cgi?id=83670

https://gcc.gnu.org/bugzilla//attachment.cgi?id=53966

### unable to find a register to spill in class 'A_REG'

When the compiler cannot find avaibale hardware registers to spill pseudo registers while optimization phase, it aborts compiling. As for the spec (https://gcc.gnu.org/onlinedocs/gccint/RTL-passes.html#RTL-passes), the compile should allocate memory slots on the stack instead of hardware registers. It seems the compiler's defect and I have applied temporary fix against it (reload1.cc). 

### Removed some files from the library.

Still some library sources cause internal compiler error. As they are not appropriate for R8C M1xAN, removed some files. For example:

* File access.
* Floating point numbers.
* Some printf/scanf functions.
* ...
