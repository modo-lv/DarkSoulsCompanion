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
		..staticFiles = "#{cfg.src.dir }/**/*.{woff,ttf,eot,png}"
		..staticModuleFiles = "#{cfg.src.dir }/modules/**/*.{html,json}"
		..staticRequireFiles = "#{cfg.src.dir }/**/*.json"
		..view = "#{cfg.src.dir }/index.html"
		..viewFiles = "#{cfg.src.dir}/**/*.html"
		..main = "#{cfg.src.dir }/app.ls"
		..scriptFiles = "#{cfg.src.dir }/**/*.ls"
		..jadeFiles = "#{cfg.src.dir }/**/*.jade"

	# destination (published) files, folder and other config
	..dst = {}
		..dir = "#{cfg.baseDir }/pub"

		..mainFile = "app.js"
		..tempDir = "#{cfg.dst.dir }/_temp_"
		..mainTempFile = "#{cfg.dst.tempDir }/#{cfg.dst.mainFile }"
		..libs = "#{cfg.dst.dir }/#{cfg.common.libDir }"
		..moduleDir = "#{cfg.dst.dir }/modules"
		..cleanup = ["#{cfg.dst.dir}/modules"]

	..modules = {}

cfg.configureModule = (name) ->	$_ = cfg.modules[name] = {}
	..dir = "modules/#{name }"

	..name = name

	..src = {}
		..dir = "#{cfg.src.dir }/#{$_.dir }"

	..dst = {}
		..dir = "#{cfg.dst.dir }/#{$_.dir }"

	# Create a wrapper for gul.task() that automatically adds module's name as prefix to the task name
	..task = (...args) !->
		args.0 = "#{$_.name }/#{args.0 }"
		if typeof args.1.indexOf == "function"
			for task, key in args.1 by -1
				args.1[key] = "#{$_.name }/#{task }"

		return gulp.task.apply gulp, args

	# Since module gulp files are in a sub-folder, all require() paths must start from one level up
	..reqPath = -> "../#{it }"