PREFIX ?= /usr/local
MANDIR ?= ${PREFIX}/share/man
DOCDIR ?= ${PREFIX}/share/doc
INSTALL_PROGRAM ?= install -m 755
INSTALL_DATA ?= install -m 644
INSTALL_MAN ?= install -m 644

test:
	shellcheck -x ./runlab.sh
	shellcheck -x ./hooks/pre-commit
configure-hooks:
	cd .git/hooks
	ln -s ../../hooks/pre-commit
gen-man:
	pandoc ./doc/runlab.1.md -s -t man -o ./man/runlab.1
	pandoc ./doc/runlabrc.5.md -s -t man -o ./man/runlabrc.5
src-update:
	git pull -r
install:
	${INSTALL_PROGRAM} ./runlab.sh ${PREFIX}/bin/runlab
	${INSTALL_MAN} ./man/runlab.1 ${MANDIR}/man1/runlab.1 && \
		gzip -9 -f ${MANDIR}/man1/runlab.1
	${INSTALL_MAN} ./man/runlabrc.5 ${MANDIR}/man5/runlabrc.5 && \
		gzip -9 -f ${MANDIR}/man5/runlabrc.5
	mkdir -p ${DOCDIR}/runlab/examples/
	${INSTALL_DATA} ./runlabrc.example ${DOCDIR}/runlab/examples/
	${INSTALL_DATA} ./doc/runlab.1.md ${DOCDIR}/runlab/
	${INSTALL_DATA} ./doc/runlabrc.5.md ${DOCDIR}/runlab/
	${INSTALL_DATA} ./README.md ${DOCDIR}/runlab/
	${INSTALL_DATA} ./LICENSE ${DOCDIR}/runlab/
uninstall:
	rm -f ${PREFIX}/bin/runlab \
		${MANDIR}/man1/runlab.1.gz \
		${MANDIR}/man5/runlabrc.5.gz
	rm -rf ${DOCDIR}/runlab/

