PROJECT=mikz/grafana

.PHONY : build

build:
	docker build -t $(PROJECT) .

bash: build
	docker run --interactive --tty $(PROJECT) bash

start: build
	docker run -P $(PROJECT) 

