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
		if item['title']? and not item['id']?
			item['id'] = uuid.v4!

		if item['children']?
			for item in item['children'] by -1
				generateIds item


	files = glob.sync "#{_.src.dir }/content/**/*.json"

	for file in files by -1
		data = require _.reqPath file
		if data.constructor == Array
			for item, index in data by -1
				generateIds item
		else if typeof data == "object"
			generateIds data
		fs.writeFileSync file, JSON.stringify(data, null, "  ")


	# Process includes
	include = (item) !->
		if item['$include']?
			console.log "Including #{item['$include'] }..."
			item = require _.reqPath "#{_.contentDir }/#{item['$include'] }"
		if item['children']?
			for child, index in item['children']
				item['children'][index] = include child

		return item

	data = require _.reqPath _.contentSourceFile

	for item, index in data
		data[index] = include item

	fs.writeFileSync _.contentCompiledFile, JSON.stringify(data)
