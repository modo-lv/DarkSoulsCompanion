#
# MODULES
#
fs = require "fs"
gulp = require "gulp"
del = require "del"
include = require "gulp-file-include"


#
# CONFIGURATION
#
_ = cfg.ConfigureModule "ItemData"
_.Pub.ViewFile = "#{_.Pub.Dir }/View.html"

$ = {}


#
# TASKS
#
_.task "wipe", ->
	del.sync _.Pub.Dir, force: true


_.task "copy-everything", ->
	gulp.src _.Src.Files
		.pipe gulp.dest _.Pub.Dir


_.task "build", ["copy-everything"]


_.task "cleanup", ["build"], ->
	del.sync _.Pub.ViewFile, force: true



#
# FUNCTIONS
#
