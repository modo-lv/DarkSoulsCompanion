angular? .module "dsc" .service "notificationSvc", ($rootScope, $sce) ->
	new NotificationService ...


class NotificationService
	(@$rootScope, @$sce) ->
		@log = @$rootScope.[]notificationLog


	clear : !~>
		@log.length = 0


	addInfo : (text) ~>
		@log.push {
			type : \info
			text : if @$sce? then @$sce.trustAsHtml text else text
		}

	addError : (text) ~>
		@log.push {
			type : \error
			text : if @$sce? then @$sce.trustAsHtml text else text
		}


module? .exports = NotificationService