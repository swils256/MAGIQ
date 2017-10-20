## -*- Makefile -*-
##
## User: ckiss
## Time: May 26, 2005 4:23:03 PM
## Makefile created by the Native Languages Module.
##
## This file is generated automatically -- Changes will be lost if regenerated
##


#### Compiler and tool definitions shared by all build targets #####
CCC = g++
CXX = g++
BASICOPTS = -g -dynamic
CCFLAGS = $(BASICOPTS)
CXXFLAGS = $(BASICOPTS)
CCADMIN = 


# Define the target directories.
TARGETDIR_4t_cv=./PC-Linux-run-GPP


all: $(TARGETDIR_4t_cv)/4t_cv

## Target: 4t_cv
OBJS_4t_cv =  \
	$(TARGETDIR_4t_cv)/h_swap.o \
	$(TARGETDIR_4t_cv)/read_procpar.o \
	$(TARGETDIR_4t_cv)/4t_cv.o \
	$(TARGETDIR_4t_cv)/preproc.o \
	$(TARGETDIR_4t_cv)/com_line.o \
	$(TARGETDIR_4t_cv)/fmtext_o.o \
	$(TARGETDIR_4t_cv)/read_fdf.o


# Link or archive
$(TARGETDIR_4t_cv)/4t_cv: $(TARGETDIR_4t_cv) $(OBJS_4t_cv)
	$(LINK.cc) $(CCFLAGS_4t_cv) $(CPPFLAGS_4t_cv) -o $@ $(OBJS_4t_cv) $(LDLIBS_4t_cv)


# Compile source files into .o files
$(TARGETDIR_4t_cv)/h_swap.o: $(TARGETDIR_4t_cv) h_swap.cpp
	$(COMPILE.cc) $(CCFLAGS_4t_cv) $(CPPFLAGS_4t_cv) -o $@ h_swap.cpp

$(TARGETDIR_4t_cv)/read_procpar.o: $(TARGETDIR_4t_cv) read_procpar.cpp
	$(COMPILE.cc) $(CCFLAGS_4t_cv) $(CPPFLAGS_4t_cv) -o $@ read_procpar.cpp

$(TARGETDIR_4t_cv)/4t_cv.o: $(TARGETDIR_4t_cv) 4t_cv.cpp
	$(COMPILE.cc) $(CCFLAGS_4t_cv) $(CPPFLAGS_4t_cv) -o $@ 4t_cv.cpp

$(TARGETDIR_4t_cv)/preproc.o: $(TARGETDIR_4t_cv) preproc.cpp
	$(COMPILE.cc) $(CCFLAGS_4t_cv) $(CPPFLAGS_4t_cv) -o $@ preproc.cpp

$(TARGETDIR_4t_cv)/com_line.o: $(TARGETDIR_4t_cv) com_line.cpp
	$(COMPILE.cc) $(CCFLAGS_4t_cv) $(CPPFLAGS_4t_cv) -o $@ com_line.cpp

$(TARGETDIR_4t_cv)/fmtext_o.o: $(TARGETDIR_4t_cv) fmtext_o.cpp
	$(COMPILE.cc) $(CCFLAGS_4t_cv) $(CPPFLAGS_4t_cv) -o $@ fmtext_o.cpp

$(TARGETDIR_4t_cv)/read_fdf.o: $(TARGETDIR_4t_cv) read_fdf.cpp
	$(COMPILE.cc) $(CCFLAGS_4t_cv) $(CPPFLAGS_4t_cv) -o $@ read_fdf.cpp



#### Clean target deletes all generated files ####
clean:
	rm -f \
		$(TARGETDIR_4t_cv)/4t_cv \
		$(TARGETDIR_4t_cv)/h_swap.o \
		$(TARGETDIR_4t_cv)/read_procpar.o \
		$(TARGETDIR_4t_cv)/4t_cv.o \
		$(TARGETDIR_4t_cv)/preproc.o \
		$(TARGETDIR_4t_cv)/com_line.o \
		$(TARGETDIR_4t_cv)/fmtext_o.o \
		$(TARGETDIR_4t_cv)/read_fdf.o
	$(CCADMIN)
	rm -f -r $(TARGETDIR_4t_cv)


# Create the target directory (if needed)
$(TARGETDIR_4t_cv):
	mkdir -p $(TARGETDIR_4t_cv)


# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.GNU-sparc-Linux

