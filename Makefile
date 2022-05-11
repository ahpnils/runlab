PREFIX ?= /usr/local
SYSCONFDIR ?= /etc
MANDIR ?= ${PREFIX}/share/man/man1
INSTALL_PROGRAM ?= install -m 755
INSTALL_DATA ?= install -m 644
INSTALL_MAN ?= install -m 644

test:
	shellcheck -x ./runlab.sh
gen-man:
	pandoc ./doc/runlab.1.md -s -t man -o ./man/runlab.1
install:
	install -m 755 ./runlab.sh ${PREFIX}/bin/runlab
	${INSTALL_DATA} ./runlabrc.example ${SYSCONFDIR}/runlabrc
src-update:
	git pull -r
update:
	install -m 755 ./runlab.sh ${PREFIX}/bin/runlab
