user:
	@./node_modules/.bin/mocha --require coffee:coffee-script/register

connect-mongo:
	@./node_modules/.bin/mocha --compilers coffee:coffee-script/register

.PHONY: user

.PHONY: connect-mongo