SET root=%1
"%root%/node_modules/.bin/mocha" --compilers=ls:livescript --require="%root%/meta/test-setup.ls" "%root%/tests/**/*.ls" --reporter=spec