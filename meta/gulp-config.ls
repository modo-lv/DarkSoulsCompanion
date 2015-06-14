gulp = require "gulp"

module?.exports = cfg = {}
	# Root folder from which all other paths are derived
	..baseDir = ".."

	# Files, folders and other config common to both source and destiation
	..common = {}
		..libDir = "libs"

	# source files, folders, and other config
	..src = {}
		..dir = "#{cfg.baseDir }/src"
		..libs = "#{cfg.src.dir }/#{cfg.common.libDir }/**"
		..staticFiles = "#{cfg.src.dir }/**/*.html"
		..view = "#{cfg.src.dir }/index.html"
		..main = "#{cfg.src.dir }/main.ls"

	# destination (published) files, folder and other config
	..dst = {}
		..mainFile = "main.js"
		..dir = "#{cfg.baseDir }/pub"
		..libs = "#{cfg.dst.dir }/#{cfg.common.libDir }"
