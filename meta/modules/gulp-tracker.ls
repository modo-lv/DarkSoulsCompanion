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
_ = cfg.configureModule "tracker"
_.contentDir = "#{_.src.dir}/content"

$ = {}


#
# TASKS
#
_.task "wipe", ->
	del.sync _.dst.dir, force: true


_.task "build", (cb) ->
	$.preprocessGuideData cb


_.task "cleanup", ->
	del.sync _.contentCompiledFile, force: true


#
# FUNCTIONS
#

$.preprocessGuideData = (cb) !->
	# Generate IDs for items that don't have them
	processEntries = (item) ->
		if item['title']? and not item['id']?
			item['id'] = uuid.v4!

		if item.labels? and item.labels.@@ == Array
			item.labels = sort item.labels

		if item['children']?
			for item in item['children'] by -1
				processEntries item


	files = glob.sync "#{_.contentDir}/**/*.json"

	for file in files by -1
		data = require _.reqPath file
		if data.@@ == Array
			data |> each processEntries
		else if typeof data == "object"
			processEntries data
		fs.writeFileSync file, JSON.stringify(data, null, "  ")

	cb!