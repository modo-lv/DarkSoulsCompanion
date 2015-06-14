#
# MODULES
#
browserify = require "browserify"
del = require "del"
gulp = require "gulp"
include = require "gulp-file-include"
livescript = require "gulp-livescript"
vinyl_stream = require "vinyl-source-stream"

#
# CONFIG
#
cfg = require "./gulp-config"

#
# TASKS
#

gulp.task "wipe", ->
	del.sync cfg.dst.dir, force: true


gulp.task "copy-static-files", ->


gulp.task "copy-libs", ->
	gulp.src cfg.src.libs
		.pipe gulp.dest cfg.dst.libs

gulp.task "compile-html", ->
	gulp.src cfg.src.view
		.pipe include { prefix: '@@' }
		.pipe gulp.dest cfg.dst.dir


gulp.task "compile-scripts", ->
	browserify cfg.src.main, debug: true
		.transform "require-globify"
		.transform "liveify"
		.bundle! .on "error", (e) -> throw new Error(e)
		.pipe vinyl_stream(cfg.dst.mainFile)
		.pipe gulp.dest(cfg.dst.dir)


gulp.task "build", ["compile-html", "copy-libs", "compile-scripts"]