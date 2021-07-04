test:
	shellcheck -x ./runlab.sh
install:
	cp ./runlab.sh /usr/local/bin/runlab
	chown root:root /usr/local/bin/runlab
	chmod 0755 /usr/local/bin/runlab
	cp ./runlabrc.example /etc/runlabrc
	chown root:root /etc/runlabrc
	chmod 0644 /etc/runlabrc
src-update:
	git pull -r
update:
	cp -fp ./runlab.sh /usr/local/bin/runlab
