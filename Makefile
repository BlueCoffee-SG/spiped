.POSIX:

PROGS=		spiped spipe
TESTS=		tests/dnsthread-resolve tests/nc-client tests/nc-server	\
		tests/valgrind
BINDIR_DEFAULT=	/usr/local/bin
CFLAGS_DEFAULT=	-O2
LIBCPERCIVA_DIR=	libcperciva
TEST_CMD=	tests/test_spiped.sh

### Shared code between Tarsnap projects.

all:	cpusupport-config.h
	export CFLAGS="$${CFLAGS:-${CFLAGS_DEFAULT}}";	\
	export "LDADD_POSIX=`export CC=\"${CC}\"; cd ${LIBCPERCIVA_DIR}/POSIX && command -p sh posix-l.sh \"$$PATH\"`";	\
	export "CFLAGS_POSIX=`export CC=\"${CC}\"; cd ${LIBCPERCIVA_DIR}/POSIX && command -p sh posix-cflags.sh \"$$PATH\"`";	\
	. ./cpusupport-config.h;			\
	for D in ${PROGS} ${TESTS}; do			\
		( cd $${D} && ${MAKE} all ) || exit 2;	\
	done

cpusupport-config.h:
	if [ -e ${LIBCPERCIVA_DIR}/cpusupport/Build/cpusupport.sh ];	\
	then								\
		( export CC="${CC}"; command -p sh 			\
		    ${LIBCPERCIVA_DIR}/cpusupport/Build/cpusupport.sh	\
		    "$$PATH" ) > cpusupport-config.h;			\
	else								\
		: > cpusupport-config.h;				\
	fi

install:	all
	export BINDIR=$${BINDIR:-${BINDIR_DEFAULT}};	\
	for D in ${PROGS}; do				\
		( cd $${D} && ${MAKE} install ) || exit 2;	\
	done

clean:
	rm -f cpusupport-config.h
	for D in ${PROGS} ${TESTS}; do				\
		( cd $${D} && ${MAKE} clean ) || exit 2;	\
	done

.PHONY:	test test-clean
test:	all
	${TEST_CMD}

test-clean:
	rm -rf tests-output/ tests-valgrind/

# Developer targets: These only work with BSD make
Makefiles:
	${MAKE} -f Makefile.BSD Makefiles

publish:
	${MAKE} -f Makefile.BSD publish
