# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

DEST=/usr

PACKAGE=nss_ndb

DEBUG=""
#DEBUG="-DDEBUG=2"

VERSION=1.0.14
INCARGS=
LIBARGS=

#VERSION=1.4
#INCARGS=-I/usr/local/include/db48
#LIBARGS=-L/usr/local/lib/db48 -ldb

#VERSION=1.5
#INCARGS=-I/usr/local/include/db5
#LIBARGS=-L/usr/local/lib/db5 -ldb

#VERSION=1.6
#INCARGS=-I/usr/local/include/db6
#LIBARGS=-L/usr/local/lib/db6 -ldb

CPPFLAGS=-DVERSION="\"$(VERSION)\"" $(INCARGS) 

CFLAGS=-pthread -fPIC -O -g -Wall -DVERSION="\"$(VERSION)\"" $(INCARGS)

#LDFLAGS=-g -G $(LIBARGS) 
LDFLAGS=--shared $(LIBARGS) 

LIB=nss_ndb.so.$(VERSION)
LIBOBJS=nss_ndb.o

BINS=makendb

TESTS=nsstest
TESTUSER=peter86
TESTUID=1003258
TESTGROUP=isy-ifm
TESTGID=100001000

all: $(LIB) $(BINS)

$(LIB): $(LIBOBJS)
	$(LD) $(LDFLAGS) -o $(LIB) $(LIBOBJS)

makendb.o: makendb.c ndb.h

makendb: makendb.o nss_ndb.o
	$(CC) -g -o makendb makendb.o nss_ndb.o $(LIBARGS)

clean:
	-rm -f *~ \#* *.o *.core core

distclean: clean
	-rm -f *.so.* $(BINS) $(TESTS)

install: $(LIB) $(BINS)
	$(INSTALL) -o root -g wheel -m 0755 $(LIB) $(DEST)/lib && ln -sf $(LIB) $(DEST)/lib/nss_ndb.so.1
	$(INSTALL) -o root -g wheel -m 0755 $(BINS) $(DEST)/bin
	$(INSTALL) -o root -g wheel -m 0444 makendb.1 $(DEST)/share/man/man1

push:	distclean
	git commit -a && git push

dist:	distclean
	(cd ../dist && ln -sf ../$(PACKAGE) $(PACKAGE)-$(VERSION) && tar zcf $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)/* && rm $(PACKAGE)-$(VERSION))


nsstest:	nsstest.o
	$(CC) -g -o nsstest nsstest.o -lpthread


NSSTEST=./nsstest
TESTOPTS=

tests: $(TESTS)
	$(NSSTEST) $(TESTOPTS) getpwnam $(TESTUSER)
	$(NSSTEST) $(TESTOPTS) -x getpwnam no-such-user
	$(NSSTEST) $(TESTOPTS) getpwuid $(TESTUID)
	$(NSSTEST) $(TESTOPTS) -x getpwuid -4711
	$(NSSTEST) $(TESTOPTS) getpwent
	$(NSSTEST) $(TESTOPTS) getgrnam $(TESTGROUP)
	$(NSSTEST) $(TESTOPTS) getgrgid $(TESTGID)
	$(NSSTEST) $(TESTOPTS) getgrent
	$(NSSTEST) $(TESTOPTS) getgrouplist $(TESTUSER)

valgrind: $(TESTS)
	valgrind --leak-check=full --error-exitcode=1 $(NSSTEST) $(TESTOPTS) getpwnam $(TESTUSER)
	valgrind --leak-check=full --error-exitcode=1 $(NSSTEST) $(TESTOPTS) -x getpwnam no-such-user
	valgrind --leak-check=full --error-exitcode=1 $(NSSTEST) $(TESTOPTS) getpwuid $(TESTUID)
	valgrind --leak-check=full --error-exitcode=1 $(NSSTEST) $(TESTOPTS) -x getpwuid -4711
	valgrind --leak-check=full --error-exitcode=1 $(NSSTEST) $(TESTOPTS) getpwent
	valgrind --leak-check=full --error-exitcode=1 $(NSSTEST) $(TESTOPTS) getgrnam $(TESTGROUP)
	valgrind --leak-check=full --error-exitcode=1 $(NSSTEST) $(TESTOPTS) getgrgid $(TESTGID)
	valgrind --leak-check=full --error-exitcode=1 $(NSSTEST) $(TESTOPTS) getgrent
	valgrind --leak-check=full --error-exitcode=1 $(NSSTEST) $(TESTOPTS) getgrouplist $(TESTUSER)


