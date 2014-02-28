#!/usr/bin/env coffee
go = (app) ->
	chokidar = require 'chokidar'
	watcher = chokidar.watch '.', ignored : /[\/\\]\./, persistent:true
	zko = (require 'zk-observable')()
	js = zko '/dyn-webapps/'+app+'/js'
	html = zko '/dyn-webapps/'+app+'/html'

	fs = require 'fs'


	jade = (full_path,html) ->
		->
			jade = require 'jade'

			jade.renderFile full_path, (err,content) ->
				unless err
					html content
					console.log 'html uploaded'
				else
					console.error err


	coffee = (full_path,js) ->
		->
			webmake = require 'webmake'
			require 'webmake-coffee'

			webmake 'webapp.coffee', {ext:['coffee'],sourceMap:true,cache:true}, (err,content) ->			
				unless err
					content = "function() { #{content} }"
					js content
					console.log 'js uploaded'
				else
					console.error err	

	bounce = (fn,timeout) ->
		timer = undefined
		body = ->
			timer = undefined
			fn()
		->
			clearTimeout timer if timer
			timer = setTimeout body, timeout			
	
	filters = []
	add_filter = (pattern,job) ->
		job = bounce job, 0
		filters.push (path) ->
			if pattern.test path
				console.log path
				job()

	worker = (path,stats) ->
		filters.map (f) -> f path, stats

	watcher.on 'change', worker
	watcher.on 'add', worker

	add_filter /\.coffee$/, (coffee 'webapp.coffee', js)
	add_filter /\.jade$/, (jade 'webapp.jade', html)

program = require 'commander'

program
	.version '0.0.0'
	.usage 'app-name'
	.parse process.argv

app = program.args[0]

unless app?
	program.help() 
else
	go app
