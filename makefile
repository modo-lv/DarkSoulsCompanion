REPORTER = spec
COMPILER = ls:LiveScript

test:
	@./node_modules/.bin/mocha --reporter $(REPORTER) --compilers $(COMPILER)