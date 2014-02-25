#!/usr/bin/env coffee
go = (app) ->
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

	watch = (file,job) ->
		job()
		fs.watchFile file, interval:250, ->
			console.log file + ' changed!'
			job()

	watch 'webapp.coffee', (coffee 'webapp.coffee', js)
	watch 'webapp.jade', (jade 'webapp.jade', html)

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
