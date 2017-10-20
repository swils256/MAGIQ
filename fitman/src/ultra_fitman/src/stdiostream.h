/*
	Copyright 04 Aug 1993 Sun Microsystems, Inc. All Rights Reserved
*/
/*  stdiostream.h -- class stdiobuf and stdiostream declarations

    Copyright 1991 by TauMetric Corporation      ALL RIGHTS RESERVED

    @(#)stdiostream.h	1.4  04 Aug 1993 14:08:36

    NOTE: These are inefficient and obsolete.  Use the standard classes
	  and functions in <fstream.h> instead.
*/

#ifndef _STDSTREAM_H_
#define _STDSTREAM_H_

#include <iostream.h>
#include <stdio.h>

class stdiobuf : public streambuf {
public:
		stdiobuf(FILE*);
	FILE*	stdiofile();
		~stdiobuf();

virtual	int	overflow(int=EOF);
virtual	int	pbackfail(int);
virtual	int	sync();
virtual	streampos seekoff(streamoff, ios::seek_dir, int);
virtual	int	underflow();

private:
	FILE*	sio;			
	char	lahead[2];
};
inline	FILE*	stdiobuf::stdiofile() { return sio; }


class stdiostream : public ios {
public:
		stdiostream(FILE*);
		~stdiostream();
	stdiobuf* rdbuf();

private:
	stdiobuf buf;
};
inline	stdiobuf* stdiostream::rdbuf() { return &buf; }

#endif /* _STDSTREAM_H_ */
