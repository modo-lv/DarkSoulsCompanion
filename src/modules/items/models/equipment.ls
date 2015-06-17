module?.exports = class Equipment extends (require './item.ls')
	->
		@weight = 0.0

		# How far the equipment has been upgraded (+1, +2, etc.)
		@level = 0


	fullName :~ -> @name + if @level > 0 then " #{@levelText }" else ""


	levelText :~ -> if @level > 0 then "+#{@level }" else ""


