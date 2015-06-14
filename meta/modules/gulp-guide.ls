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
_ = cfg.ConfigureModule "Guide"
_.Pub.DataFile = "#{_.Pub.Dir }/Guide.json"
_.Pub.ViewFile = "#{_.Pub.Dir }/View.html"

$ = {}


#
# TASKS
#
_.task "wipe", ->
	del.sync _.Pub.Dir, force: true


_.task "preprocess-guide-data", (cb) ->
	$.PreprocessGuideData cb


_.task "copy-everything", ["preprocess-guide-data"], ->
	gulp.src _.Src.Files
		.pipe gulp.dest _.Pub.Dir


_.task "compile-data", ["copy-everything"], ->
	$.CompileData!


_.task "build", ["compile-data"], ->
	$.BuildGuideView!


_.task "cleanup", ["build"], ->
	del.sync "#{_.Pub.Dir }/Data", force: true
	del.sync _.Pub.ViewFile, force: true


#
# FUNCTIONS
#
$.PreprocessGuideData = (cb) !->
	generateIds = (item) ->
		if item.Children?
			for item in item.Children by -1
				generateIds item
		if (not item.Title?) or item.Id?
			return
		item.Id = uuid.v4!


	glob "#{_.Src.Dir }/**/*.json", (error, files) ->
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

		cb!


$.CompileData = ->
	include = (item) !->
		if item.Children?
			for child in item.Children
				include child
		else
			if item.$include?
				item <<< require _.reqPath "#{_.Pub.Dir }/#{item.$include }"

	data = require _.reqPath _.Pub.DataFile
	for item in data by -1
		include item

	fs.writeFileSync _.Pub.DataFile, JSON.stringify(data)


$.BuildGuideView = !->
	genEntryHtml = (item) !->
		out = ""
		classes = "Entry"
		classes += " empty" if not (item.Content? or item.Children?)
		classes += " EntryGroup" if item.Children?
		item.Labels ?= []
		out += "<li class=\"#{classes }\" data-id=\"#{item.Id }\" data-labels='#{JSON.stringify item.Labels }'>\n"
		out += "<div class=\"Header\">"
		out += "<div class=\"Title\">#{item.Title }</div>"
		for label in item.Labels
			out += "<span class=\"Label\">#{label }</span>"
		out += "</div>\n"
		out += "<div class=\"Content\">"
		if item.Children?
			out += "<ul>"
			for child in item.Children
				out += genEntryHtml child
			out += "</ul>"
		else
			out += "#{item.Content ? "" }"
		out += "</div>\n"
		out += "</li>\n"
		return out

	data = require _.reqPath _.Pub.DataFile
	view = fs.readFileSync _.Pub.ViewFile, {'encoding': 'utf8'}

	html = ""
	for item in data
		html += genEntryHtml item

	content = view.replace '<!--__content-->', html

	return fs.writeFile _.Pub.ViewFile, content
