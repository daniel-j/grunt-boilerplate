

@App = do (Backbone, Marionette) ->
	'use strict'

	#Backbone.emulateHTTP = true
	#Backbone.fetchCache.localStorage = false

	App = new Marionette.Application

	App.addRegions
		# your regions

	App.reqres.setHandler "default:region", ->
		# App.mainRegion

	App.on 'initialize:before', (options) ->
		# stuff

	App.addInitializer ->
		# footer, header, menu etc.. static modules
		# @module('Module').start
		#	region: @myRegion


	#App.commands.setHandler "register:instance", (instance, id) ->
	#	App.register instance, id

	#App.commands.setHandler "unregister:instance", (instance, id) ->
	#	App.unregister instance, id


	App.on "initialize:after", (options) ->
		@startHistory()

	App

