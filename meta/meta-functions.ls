browserify = require "browserify"
gulp = require "gulp"
livescript = require "gulp-livescript"
sass = require "gulp-sass"
vinyl_stream = require "vinyl-source-stream"
include = require 'gulp-file-include'
jsonmin = require 'gulp-jsonminify'
fs = require "fs"

cfg = require "./gulp-config"

module.exports.BuildStaticHtml = ->
	gulp.src cfg.Src.Html
		.pipe include { prefix: '@@' }
		.pipe gulp.dest cfg.Pub.Dir


/**
* Copy over static content to build directory.
*/
module.exports.BuildStaticContent = ->
	gulp.src cfg.Src.Static
		.pipe gulp.dest cfg.Pub.Dir



/**
* Compile LiveScript files (.ls) to JavaScript (.js) in the build directory.
*/
module.exports.CompileLiveScript = (cb, file = cfg.Src.Ls) ->
	gulp.src file
		.pipe livescript!
		.on "error", -> throw new Error it
		.pipe gulp.dest cfg.Pub.Dir


/**
* Browserify Main.js to make require()s work on the front-end
*/
module.exports.Browserify = ->
	browserify cfg.Pub.Main, debug: true
		.transform "require-globify"
		.bundle!on "error", (e) -> throw new Error(e)
		.pipe vinyl_stream(cfg.MainJs)
		.pipe gulp.dest(cfg.Pub.Dir)


/**
* Compile .sass -> .css
*/
module.exports.CompileSass = ->
	gulp.src cfg.Src.Dir + "/Style.sass"
		.pipe sass indentedSyntax: true
		.pipe gulp.dest(cfg.Pub.Dir)


/**
 * Compile .json includes
 */
module.exports.CompileGuide = ->
	gulp.src cfg.Src.Dir + "/Modules/Guide/Guide.json"
		.pipe include { prefix: '{}//' }
		.pipe gulp.dest cfg.Pub.Dir + "/Modules/Guide"


module.exports.MinifyJson = ->
	gulp.src cfg.Pub.Dir + "/Modules/Guide/Guide.json"
		.pipe jsonmin!
		.pipe gulp.dest cfg.Pub.Dir + "/Modules/Guide"


module.exports.BuildGuideView = ->
	genEntryHtml = (item) !->
		out = ""
		if item.Children?
			out += "<div class=\"EntryGroup\">\n"
			out += "<h3>#{item.Title }</h3>\n"
			for child in item.Children
				out += genEntryHtml child
			out += "</div>"
		else
			out += "<ul>\n"
			classes = (item.Labels ? []) ++ ["Entry"]
			classes = classes.join " "

			out += "<li class=\"#{classes }\">\n"
			out += "<div class=\"Header\">\n"
			out += "<div class=\"Title\">#{item.Title }</div>\n"
			out += "</div>\n"
			out += "<div class=\"Content\">#{item.Content }</div>\n"
			out += "</li>\n"
			out += "</ul>\n"
		return out

	data = require cfg.Pub.Dir + "/Modules/Guide/Guide.json"
	view = fs.readFileSync cfg.Pub.Dir + "/Modules/Guide/View.html", {'encoding': 'utf8'}

	html = ""
	for item in data
		html += genEntryHtml item

	content = view.replace '<!--__content-->', html

	fs.writeFileSync "#{cfg.Pub.Dir }/Modules/Guide/View.html", content
