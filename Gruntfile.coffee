'use strict'

# Configuration

libs = [
	'jquery/jquery'
	'underscore/underscore'
	'backbone/backbone'
	'marionette/backbone.marionette'
]

scripts = [
	'app'

]

preprocess = [
	'example.html'
]


builddir = 'build'
bowerlibdir = 'lib'
coffeedir = 'src/coffee'
lessdir = 'src/less'
ecodir = 'src/eco'
jadedir = 'src/jade'
templatedir = 'src/preprocess'

wwwdir = 'www' # is a merge from dist and static directories
staticdir = 'assets' # put images and other assets here
distdir = 'dist' # put final build here
releasefile = 'js/app.min.js'
releasestyle = 'style/style.css'



# create an object with a variable key
key = (k, p) ->
	o = {}
	o[k] = p
	o

module.exports = (grunt) ->
	require('time-grunt') grunt
	require('load-grunt-tasks') grunt

	inProduction = process.env.NODE_ENV == 'production'

	mapfiles = []

	scripts.forEach (f, i) ->
		# compilelist[builddir+'/js/'+f+'.js'] =
		scripts[i] = coffeedir+'/'+f+'.coffee'
		mapfiles[i] = builddir+'/js/'+f+'.js.map'

	libs.forEach (f, i) ->
		libs[i] = bowerlibdir+'/'+f+'.js'


	preplist = {}
	htmllist = {}
	preprocess.forEach (f, i) ->
		preplist[distdir+'/'+f] = templatedir+'/'+f
		if f.lastIndexOf '.html' == f.length - 5
			htmllist[distdir+'/'+f] = distdir+'/'+f;


	gruntconfig =

		pkg: grunt.file.readJSON 'package.json'

		uglify:
			release:
				options:
					mangle: false
					sourceMap: false
					banner: '// <%= pkg.name %> - v<%= pkg.version %> - ' +
					        '<%= grunt.template.today("yyyy-mm-dd") %> */\n'

				files: key distdir+'/'+releasefile, libs.concat [builddir+'/eco.js', builddir+'/core.js']

			libs:
				options:
					mangle: false
					sourceMap: true

				files: key builddir+'/libs.min.js', libs


		coffee:
			debug:
				options:
					sourceMap: true
				files: [
					expand: true
					cwd: coffeedir
					src: ['**/*.coffee']
					dest: builddir+'/js'
					ext: '.js'
				]

			release:
				files: key builddir+'/core.js', scripts

		mapcat:
			default:
				src: mapfiles
				dest: builddir+"/core.debug.js"


		coffeelint:
			app:
				files:
					src: [coffeedir+'/**/*.coffee']
				options:
					force: true
					'no_tabs':
						level: 'ignore'
					'indentation':
						level: 'ignore'

		less:
			development:
				options:
					paths: [lessdir]
					sourceMap: true
					sourceMapFilename: builddir+'/style.map'
					sourceMapRootpath: '../'
					sourceMapURL: '../../build/style.map'

				src: lessdir+'/style.less'
				dest: distdir+'/'+releasestyle

			production:
				options:
					paths: [lessdir]
					cleancss: true

				src: lessdir+'/style.less'
				dest: distdir+'/'+releasestyle

		eco:
			options:
				basePath: ecodir
			default:
				files: key(builddir+'/eco.js', [ecodir+'/**/*.eco'])

		jade:
			default:
				options:
					pretty: true
					data:
						env: process.env.NODE_ENV || 'development'
				files: [
					expand: true
					cwd: jadedir
					src: ['**/*.jade']
					dest: builddir+'/jade'
					ext: '.html'
					extDot: 'last'
				]


		preprocess:
			default:
				files: preplist

		htmlmin:
			options:
				collapseBooleanAttributes: inProduction
				collapseWhitespace: inProduction
				removeComments: inProduction
				removeAttributeQuotes: inProduction
				removeCommentsFromCDATA: inProduction
				removeEmptyAttributes: inProduction
				removeOptionalTags: false
				removeRedundantAttributes: inProduction
				useShortDoctype: true


			default:
				files: htmllist

			jade:
				files: [
					# input = output
					expand: true
					cwd: builddir+'/jade'
					src: ['**/*.html']
					dest: distdir
				]

		copy:
			jade:
				files: [
					expand: true
					cwd: builddir+'/jade'
					src: ['**/*.html']
					dest: distdir
				]
			static:
				files: [
					expand: true
					cwd: staticdir
					src: ['**']
					dest: wwwdir
				]
			dist:
				files: [
					expand: true
					cwd: distdir
					src: ['**']
					dest: wwwdir
				]

		clean:
			build: [builddir]

			js: [builddir+'/js']
			jade: [builddir+'/jade']
			dist: [distdir]
			www: [wwwdir]

		bower:
			install:
				options:
					targetDir: bowerlibdir
					cleanTargetDir: true
					bowerOptions:
						production: true

		watch:
#			gruntfile:
#				files: ['Gruntfile.coffee']

			preprocess:
				files: [templatedir+'/**']
				tasks: ['clean:www', 'build:preprocess', 'copy:static', 'copy:dist']
				options:
					debounceDelay: 250
					spawn: false

			jade:
				files: [jadedir+'/**/*.jade']
				tasks: ['clean:www', 'build:jade', 'copy:static', 'copy:dist']
				options:
					debounceDelay: 250
					spawn: false

			less:
				files: [lessdir+'/**/*.less']
				tasks: ['clean:www', 'build:less', 'copy:static', 'copy:dist']
				options:
					debounceDelay: 250
					spawn: false
					livereload: true

			static:
				files: [staticdir+'/**']
				tasks: ['clean:www', 'copy:static', 'copy:dist']
				options:
					debounceDelay: 250
					spawn: false
			# env specific watchers below

		concurrent:
			options:
				logConcurrentOutput: true

			production: [
				'build:release'
				'build:jade'
				'build:preprocess'
				'build:less'
			]
			development: [
				'build:debug'
				'build:jade'
				'build:preprocess'
				'build:less'
			]

	if inProduction
		gruntconfig.watch.core =
			files: [coffeedir+'/**/*.coffee']
			tasks: ['clean:www', 'coffee:release', 'uglify:release', 'copy:static', 'copy:dist', 'coffeelint']
			options:
				debounceDelay: 250
				spawn: false

		gruntconfig.watch.eco =
			files: [ecodir+'/**/*.eco']
			tasks: ['clean:www', 'eco', 'uglify:release', 'copy:static', 'copy:dist']
			options:
				debounceDelay: 250
				spawn: false


	else
		gruntconfig.watch.core =
			files: [coffeedir+'/**/*.coffee']
			tasks: ['clean:www', 'clean:js', 'debug', 'copy:static', 'copy:dist', 'coffeelint']
			options:
				debounceDelay: 250
				spawn: false

		gruntconfig.watch.eco =
			files: [ecodir+'/**/*.eco']
			tasks: ['clean:www', 'eco', 'copy:static', 'copy:dist']
			options:
				debounceDelay: 250
				spawn: false


	grunt.initConfig gruntconfig

	if inProduction
		grunt.registerTask 'build:default', [
			'build:production'
		]

		grunt.registerTask 'build:jade', [
			'jade'
			'htmlmin:jade'
		]

		grunt.registerTask 'build:less', [
			'less:production'
		]

	else
		grunt.registerTask 'build:default', [
			'build:development'
		]

		grunt.registerTask 'build:jade', [
			'jade'
			'copy:jade'
		]

		grunt.registerTask 'build:less', [
			'less:development'
		]

	grunt.registerTask 'default', ['build:default']
	grunt.registerTask 'build', ['default']

	grunt.registerTask 'edit', [
		'build:default'
		'watch'
	]

	grunt.registerTask 'libs', [
		'uglify:libs'
	]

	grunt.registerTask 'debug', [
		'coffee:debug'
		'mapcat'
	]

	grunt.registerTask 'build:preprocess', [
		'preprocess'
		'htmlmin:default'
	]

	grunt.registerTask 'build:debug', [
		'libs'
		'eco'
		'debug'
	]
	grunt.registerTask 'build:release', [
		'coffee:release'
		'eco'
		'uglify:release'
	]

	grunt.registerTask 'build:production', [
		'clean'
		'concurrent:production'
		'copy:static'
		'copy:dist'
		'coffeelint'
	]

	grunt.registerTask 'build:development', [
		'clean'
		'concurrent:development'
		'copy:static'
		'copy:dist'
		'coffeelint'
	]


	### replaced with load-grunt-tasks
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-mapcat'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-coffeelint'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-eco'
	grunt.loadNpmTasks 'grunt-preprocess'
	grunt.loadNpmTasks 'grunt-contrib-htmlmin'
	grunt.loadNpmTasks 'grunt-contrib-jade'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-bower-task'
	###


