# need to git clone the picon include submodules
# git clone --recurse-submodules https://github.com/ANSSI-FR/picon

# modify picon/Makefile change the llvm version 3.8 to 3.6
# run make under picon
# the make will do follwings:
# [ 25%] Building CXX object CFI/CMakeFiles/CFI.dir/CFI.cpp.o
# [ 50%] Building CXX object CFI/CMakeFiles/CFI.dir/CFIInjector.cpp.o
# [ 75%] Building CXX object CFI/CMakeFiles/CFI.dir/CFIModulePass.cpp.o
# [100%] Linking CXX shared module libCFI.so


# go to picon/example/unit_tests/
# rm build.cfi/*
# need to create build.cfi under picon/examples/unit_tests/


# Use “clang” to make cltest_rop.c
clang -I/usr/include -Wall \
-Wextra -Wtype-limits \
-fstrict-overflow -Wsign-compare \
-DCFI_DEBUG -c -emit-llvm \
-o build.cfi/test_rop.bc src/test_rop.c
#generate test_rop.bc


# Generate cfi bc file by “opt”
# run the Picon LLVM pass on each bitcode file, to produced the processed bitcode file, and the temporary Picon files
opt -load /home/wes/picon/llvm_pass/build/CFI/libCFI.so \
-cfi -cfi-level=1 \
-cfi-ignore=ignored_functions.txt \
-cfi-prefix=build.cfi/test_rop_cfi \
-S -o build.cfi/test_rop_cfi.bc build.cfi/test_rop.bc
#generate test_rop_cfi.*
#test_rop_cfi.bbtrans
#test_rop_cfi.bc
#test_rop_cfi.fctid
#test_rop_cfi.ipdom
#test_rop_cfi.lock
#test_rop_cfi.trans


#run picon-prelink on the temporary picon files to produce the injected source code
/home/wes/picon/prelink/picon-prelink build.cfi/test_rop_cfi > build.cfi/cfi_injected_test_rop.c
#generate cfi_injected_test_rop.c


# I copy the header files in need to current path
clang-3.6 -I/usr/include \
-Wall -Wextra -Wtype-limits -fstrict-overflow \
-Wsign-compare -DCFI_DEBUG -c \
-o build.cfi/cfi_injected_test_rop.o build.cfi/cfi_injected_test_rop.c



clang-3.6 -I/usr/include \
-Wall -Wextra -Wtype-limits -fstrict-overflow \
-Wsign-compare -DCFI_DEBUG -c \
-o build.cfi/test_rop.o build.cfi/test_rop_cfi.bc



clang-3.6  -o \
build.cfi/test_rop \
build.cfi/cfi_injected_test_rop.o \
build.cfi/test_rop.o
# generate test_rop with cfi


/home/wes/picon/monitor/build/picon-monitor \
/home/wes/picon/examples/unit_tests/build.cfi/test_rop

# output
# [debug]	[ client]	sending loading packet (size = 5)
# [debug]	[ client]	waiting for monitor to loading packet
# [debug]	[ client]	sending loading packet (size = 63)
# [debug]	[ client]	sending loading packet (size = 17)
# [debug]	[ client]	sending loading packet (size = 12)
# [debug]	[ client]	sending loading packet (size = 12)
# [debug]	[ client]	sending loading packet (size = 12)
# [debug]	[ client]	sending loading packet (size = 69)
# [debug]	[ client]	sending loading packet (size = 0)
# [debug]	[ client]	sending loading packet (size = 0)
# [debug]	[ client]	sending signal
# [debug]	[ client]	waiting for answer
# [debug]	[ client]	sending signal
# [debug]	[ client]	waiting for answer
# [debug]	[ client]	sending signal
# [debug]	[ client]	waiting for answer
# fun called
# [debug]	[ client]	sending signal
# [debug]	[ client]	waiting for answer
# [debug]	[ client]	sending signal
# [debug]	[ client]	waiting for answer
# [error]	[monitor]	run failed with error = 4

echo "Now run the ./build.cfi/test_rop"
./build.cfi/test_rop

###################################################################
##for nocfi
#rm build.no_cfi/*
#need to create build.no_cfi under picon/examples/unit_tests/
clang-3.6 -I/usr/include -Wall \
-Wextra -Wtype-limits -fstrict-overflow \
-Wsign-compare -DCFI_DEBUG -c \
-o build.no_cfi/test_rop.o src/test_rop.c
#generate test_rop.o


clang-3.6  -o build.no_cfi/test_rop build.no_cfi/test_rop.o
#generate test_rop without cfi


/home/wes/picon/monitor/build/picon-monitor \
/home/wes/picon/examples/unit_tests/build.no_cfi/test_rop

# output
# fun called
# fun_should_not_be_called
# [error] [monitor]       failed to read loading packet (err = 1)
# [error] [monitor]       failed to load monitor data


echo "Now run the ./build.no_cfi/test_rop"
./build.no_cfi/test_rop

# output 
# fun called
# fun_should_not_be_called

