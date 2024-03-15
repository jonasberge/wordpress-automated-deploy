.PHONY: all clean install download conf run

all:

run: conf
	cd script-server; \
		. venv/bin/activate; \
		python3 launcher.py

conf:
	mkdir -p script-server
	rm -rf script-server/conf || true
	cp -r conf script-server

download: clean
	mkdir -p script-server && cd script-server; \
		python3 -m venv venv; \
		. venv/bin/activate; \
		which python3 && python3 -V; \
		wget https://github.com/bugy/script-server/releases/latest/download/script-server.zip; \
		unzip script-server.zip; \
		pip install -r requirements.txt

install: download conf

install-service:
	sudo systemctl disable --now script-server.service && sudo systemctl daemon-reload || true
	sudo cp scripts/script-server.service /etc/systemd/system/script-server.service
	sudo systemctl enable --now script-server.service

clean:
	mkdir .tmp
	mkdir -p script-server/conf
	mv script-server/conf .tmp/
	rm -rf script-server
	mkdir script-server
	mv .tmp/conf script-server/
	rm -rf .tmp
