#
# MODULES
#
fs = require "fs"
glob = require "glob"
gulp = require "gulp"
del = require "del"
include = require "gulp-file-include"
uuid = require "node-uuid"

#
# CONFIGURATION
#
_ = cfg.configureModule "items"
_.contentDir = "#{_.src.dir}/content"
_.targetFile = "#{_.dst.dir}/content/idNameIndex.json"

$ = {}


#
# TASKS
#
_.task "wipe", ->
	del.sync _.dst.dir, force: true


_.task "build", (cb) ->
	$.buildIdNameIndex cb


_.task "cleanup", ->
	del.sync _.contentCompiledFile, force: true


#
# FUNCTIONS
#

$.buildIdNameIndex = (cb) !->
	result = []
	for itemType in [\items \weapons \armors]
		items = require _.reqPath "#{_.contentDir}/#{itemType}.json"
		for item in items
			result.push {id : item.id, name : item.name}

	fs.writeFileSync _.targetFile, JSON.stringify result

	cb!