# r8c dev environment

## Quick start

* Intall docker.
* Install Visual Studio Code.
* Add remote development extention to you Visual Studio Code.
* Open 'vscode' folder by Visual Studio Code then click 'Reopen in Container' button.

## Tags

* gcc-6.5.0<br/>
GCC 6.5.0

* gcc-7.5.0<br/>
GCC 7.5.0

* gcc-12.2.0<br/>
GCC 12.2.0

## Caveat

GCC 7.5.0 and later is not able to be built without tweaking. The following changes are incomporated:

### gcc/config/m32c/m32c.cc

GCC does not run without the following patch:

https://gcc.gnu.org/bugzilla//show_bug.cgi?id=83670

https://gcc.gnu.org/bugzilla//attachment.cgi?id=53966

### Compiler sometimes aborts with -O2.

While building libraries, the compiler sometimes aborts. Added the following attribute to some functions to remedy this.

    __attribute__((optimize("O0")))

### Removed some files from the library.

Since some functions are not appropriate for R8C M1xAN, removed some files. For example:

* Complex type.
* File access.
* Copy on Write strings.
* ...
