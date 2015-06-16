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
_ = cfg.configureModule "guide"
_.contentDir = "#{_.src.dir}/content"
_.contentSourceFile = "#{_.contentDir }/guide.json"
_.contentCompiledFile = "#{_.src.dir }/content.json"

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
	generateIds = (item) ->
		if item['children']?
			for item in item['children'] by -1
				generateIds item
		if (not item['title']?) or item['id']?
			return
		item['id'] = uuid.v4!


	glob "#{_.src.dir }/content/**/*.json", (error, files) !->
		if error?
			return cb error
		for file in files by -1
			data = require _.reqPath file
			if data.constructor == Array
				for item, index in data by -1
					generateIds item
			else if typeof data == "object"
				generateIds data
			fs.writeFileSync file, JSON.stringify(data, null, "\t")

		return cb!

	# Process includes
	include = (item) !->
		if item['children']?
			for child in item['children']
				include child
		else
			if item['$include']?
				item <<< require _.reqPath "#{_.contentDir }/#{item['$include'] }"

	data = require _.reqPath _.contentSourceFile

	for item in data by -1
		include item

	fs.writeFileSync _.contentCompiledFile, JSON.stringify(data)
