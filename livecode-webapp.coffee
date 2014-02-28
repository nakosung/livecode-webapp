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

	filters = []
	add_filter = (pattern,job) ->
		filters.push (path) ->
			if pattern.test path
				console.log path
				job()

	watcher.on 'change', (path,stats) ->
		filters.map (f) -> f path, stats

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
