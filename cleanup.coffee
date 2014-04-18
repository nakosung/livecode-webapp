_ = require 'underscore'
async = require 'async'

module.exports = (client,next) ->
	clear = (path,next) ->
		client.getChildren path, (err,children) ->
			return next() if err?.code == -101
			return next err if err

			# console.log children.length
			client.getData path+'/sha1', (err,data) ->
				return next() if err?.code == -101
				return next err if err

				sha1 = data.toString()
				console.log 'latest version:', path, sha1
				toDelete = _.without children, sha1, 'sha1'
				jobs = toDelete.map (child) ->
					(next) -> client.remove path+'/'+child, next
				if jobs.length
					console.log 'deleting ', jobs.length
					async.parallel jobs, next
				else
					next()

	clear_exts = (path,next) ->
		exts = 'js html'.split ' '
		jobs = exts.map (x) ->
			(next) -> clear [path,x].join('/'), next
		async.parallel jobs, next

	clear_all = (path,next) ->
		client.getChildren path, (err,children) ->
			return next err if err 

			jobs = children.map (x) ->
				(next) ->
					clear_exts [path,x].join('/'), next

			async.parallel jobs, next

	clear_all '/dyn-webapps', next
