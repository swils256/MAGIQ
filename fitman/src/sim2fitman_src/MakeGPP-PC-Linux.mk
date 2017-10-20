## -*- Makefile -*-
##
## User: ckiss
## Time: Jun 16, 2005 12:36:59 PM
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
TARGETDIR_sim2fitman=PC-Linux-run-GPP


all: $(TARGETDIR_sim2fitman)/sim2fitman

## Target: sim2fitman
OBJS_sim2fitman =  \
	$(TARGETDIR_sim2fitman)/sim2fitman.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_fmtext_o.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_preproc.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_com_line.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_read_procpar.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_error.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_sup.o


# Link or archive
$(TARGETDIR_sim2fitman)/sim2fitman: $(TARGETDIR_sim2fitman) $(OBJS_sim2fitman)
	$(LINK.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ $(OBJS_sim2fitman) $(LDLIBS_sim2fitman)


# Compile source files into .o files
$(TARGETDIR_sim2fitman)/sim2fitman.o: $(TARGETDIR_sim2fitman) sim2fitman.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_fmtext_o.o: $(TARGETDIR_sim2fitman) sim2fitman_fmtext_o.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_fmtext_o.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_preproc.o: $(TARGETDIR_sim2fitman) sim2fitman_preproc.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_preproc.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_com_line.o: $(TARGETDIR_sim2fitman) sim2fitman_com_line.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_com_line.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_read_procpar.o: $(TARGETDIR_sim2fitman) sim2fitman_read_procpar.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_read_procpar.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_error.o: $(TARGETDIR_sim2fitman) sim2fitman_error.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_error.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_sup.o: $(TARGETDIR_sim2fitman) sim2fitman_sup.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_sup.cpp



#### Clean target deletes all generated files ####
clean:
	rm -f \
		$(TARGETDIR_sim2fitman)/sim2fitman \
		$(TARGETDIR_sim2fitman)/sim2fitman.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_fmtext_o.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_preproc.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_com_line.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_read_procpar.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_error.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_sup.o
	$(CCADMIN)
	rm -f -r $(TARGETDIR_sim2fitman)


# Create the target directory (if needed)
$(TARGETDIR_sim2fitman):
	mkdir -p $(TARGETDIR_sim2fitman)


# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.GNU-sparc-Linux

