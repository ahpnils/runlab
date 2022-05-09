test:
	shellcheck -x ./runlab.sh
install:
	install -m 755 ./runlab.sh /usr/local/bin/runlab
	install -m 644 ./runlabrc.example /etc/runlabrc
src-update:
	git pull -r
update:
	install -m 755 ./runlab.sh /usr/local/bin/runlab
