global? <<< require "prelude-ls"

#
# MODULES
#
browserify = require "browserify"
del = require "del"
gulp = require "gulp"
include = require "gulp-file-include"
livescript = require "gulp-livescript"
sass = require "gulp-sass"
requireDir = require "require-dir"
vinyl_stream = require "vinyl-source-stream"
jade = require "gulp-jade"

#
# CONFIG
#
global.cfg = require "./gulp-config"


#
# MODULE TASKS
#
requireDir "./modules"

gulp.task "build-modules", ["guide/build"]


#
# TASKS
#

gulp.task "wipe", ->
	del.sync cfg.dst.dir, force: true


gulp.task "copy-libs", ->
	gulp.src cfg.src.libs
		.pipe gulp.dest cfg.dst.libs



gulp.task "compile-jade", ->
	gulp.src cfg.src.jadeFiles
		.pipe jade!
		.pipe gulp.dest cfg.dst.dir


gulp.task "compile-html", ["compile-jade"] ->
	gulp.src cfg.src.view
		#.pipe include { prefix: '@@' }
		.pipe gulp.dest cfg.dst.dir
	gulp.src cfg.src.staticModuleFiles
		.pipe gulp.dest cfg.dst.moduleDir


gulp.task "compile-stylesheets", ->
	gulp.src cfg.src.dir + "/style.sass"
		.pipe sass outputStyle: \compressed
		.pipe gulp.dest(cfg.dst.dir)


# Copy static files used in require() calls over to the temp directory
gulp.task "copy-static-files", ->
	gulp.src cfg.src.staticRequireFiles
		.pipe gulp.dest cfg.dst.tempDir



# Compile .ls scripts into .js
gulp.task "compile-scripts", ->
	gulp.src cfg.src.scriptFiles
		.pipe livescript!
		.on "error", !-> throw new Error it
		.pipe gulp.dest cfg.dst.tempDir


# Combine .js scripts into one file.
gulp.task "compile-and-browserify", ["copy-static-files", "compile-scripts"], ->
	browserify cfg.dst.mainTempFile, debug: true
		.transform "require-globify"
		.bundle! .on "error", (e) -> throw new Error(e)
		.pipe vinyl_stream(cfg.dst.mainFile)
		.pipe gulp.dest(cfg.dst.dir)


gulp.task "build", ["compile-html", "copy-libs", "compile-and-browserify", "compile-stylesheets"], ->
	# Once everything is done, delete the temp directory
	del.sync cfg.dst.tempDir, force : true


gulp.task "build-everything", ["build-modules", "build"]