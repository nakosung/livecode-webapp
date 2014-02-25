ng.controller 'TestWebappMyCtrl', ($scope) ->
	$scope.some_value = "하하하!!!!!!!!!!!!!!!!!!!"
	$scope.$on '$destroy', ->
		console.log 'destroyed'