## -*- Makefile -*-
##
## User: ckiss
## Time: May 17, 2005 1:58:42 PM
## Makefile created by the Native Languages Module.
##
## This file is generated automatically -- Changes will be lost if regenerated
##


#### Compiler and tool definitions shared by all build targets #####
CCC = CC
CXX = CC
BASICOPTS = -g -Bstatic
CCFLAGS = $(BASICOPTS)
CXXFLAGS = $(BASICOPTS)
CCADMIN = CCadmin -clean


# Define the target directories.
TARGETDIR_sim2fitman=./SPARC-SunOS-run-CC


all: $(TARGETDIR_sim2fitman)/sim2fitman

## Target: sim2fitman
OBJS_sim2fitman =  \
	$(TARGETDIR_sim2fitman)/sim2fitman_com_line.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_fmtext_o.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_preproc.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_read_procpar.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_sup.o \
	$(TARGETDIR_sim2fitman)/sim2fitman_error.o \
	$(TARGETDIR_sim2fitman)/sim2fitman.o


# Link or archive
$(TARGETDIR_sim2fitman)/sim2fitman: $(TARGETDIR_sim2fitman) $(OBJS_sim2fitman)
	$(LINK.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ $(OBJS_sim2fitman) $(LDLIBS_sim2fitman)


# Compile source files into .o files
$(TARGETDIR_sim2fitman)/sim2fitman_com_line.o: $(TARGETDIR_sim2fitman) sim2fitman_com_line.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_com_line.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_fmtext_o.o: $(TARGETDIR_sim2fitman) sim2fitman_fmtext_o.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_fmtext_o.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_preproc.o: $(TARGETDIR_sim2fitman) sim2fitman_preproc.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_preproc.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_read_procpar.o: $(TARGETDIR_sim2fitman) sim2fitman_read_procpar.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_read_procpar.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_sup.o: $(TARGETDIR_sim2fitman) sim2fitman_sup.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_sup.cpp

$(TARGETDIR_sim2fitman)/sim2fitman_error.o: $(TARGETDIR_sim2fitman) sim2fitman_error.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman_error.cpp

$(TARGETDIR_sim2fitman)/sim2fitman.o: $(TARGETDIR_sim2fitman) sim2fitman.cpp
	$(COMPILE.cc) $(CCFLAGS_sim2fitman) $(CPPFLAGS_sim2fitman) -o $@ sim2fitman.cpp



#### Clean target deletes all generated files ####
clean:
	rm -f \
		$(TARGETDIR_sim2fitman)/sim2fitman \
		$(TARGETDIR_sim2fitman)/sim2fitman_com_line.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_fmtext_o.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_preproc.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_read_procpar.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_sup.o \
		$(TARGETDIR_sim2fitman)/sim2fitman_error.o \
		$(TARGETDIR_sim2fitman)/sim2fitman.o
	$(CCADMIN)
	rm -f -r $(TARGETDIR_sim2fitman)


# Create the target directory (if needed)
$(TARGETDIR_sim2fitman):
	mkdir -p $(TARGETDIR_sim2fitman)


# Enable dependency checking
.KEEP_STATE:
.KEEP_STATE_FILE:.make.state.Sun-sparc-Solaris

