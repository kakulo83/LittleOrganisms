#    Life-Simulation
#
#	 Copyright (c) 2012 Robert Carter 
#	 
#	 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
#	 to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
#	 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#	 
#	 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#	 
#	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#	 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#	 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
#	 IN THE SOFTWARE.

require 'simulation_item'
require 'observer'

class Food < SimulationItem
	include Observable	

	attr_reader :activation_energy, :nutritional_content

	def initialize(x, y, activation_energy, nutritional_content)
		# Remember to call your parent and pay respect to your ancestors	
		super
		@x = x
		@y = y
		@width = 35 
		@height = 35
		@activation_energy = activation_energy					# Energy critters must expend to consume food
		@nutritional_capacity = nutritional_content				# Total capacity of energy food item contains
		@nutritional_content = nutritional_content				# Currrent amount of energy food contains
		@expiration_date = 300 + rand(200)							# Food shelf-life 
		@age = 0	
		@rate_of_rotting = 40

		if activation_energy <= 10 
			@easy_to_eat = true							 
			@image_name = "graphics/easy_food.png"	
		else 
			@easy_to_eat = false 
			@image_name = "graphics/hard_food.png"
		end
	end

	def update
		# Rapidly reduce the energy content and size of food items past their FDA shelf-life date. 
		@age += 1	
		if is_past_shelf_life?	
			@nutritional_content -= @rate_of_rotting 
			@width -= @rate_of_rotting * @width / @nutritional_capacity.to_f
			@height = @width
			if @nutritional_content <= 0	
				changed
				notify_observers self, :depleted
			end
		end
	end

	def is_easy_to_eat?
		@easy_to_eat
	end	

	def is_past_shelf_life?
		if @age >= @expiration_date
			true
		else
			false
		end	
	end

	def consume(bite_size) 
		# Decrease energy content of food	
		@nutritional_content -= bite_size 
		if @nutritional_content <= 0
			changed
			notify_observers self, :depleted
			return bite_size = 0
		else	
			@width  -= bite_size.to_f * @width / @nutritional_capacity.to_f
			@height -= bite_size.to_f * @height/ @nutritional_capacity.to_f
			bite_size
		end
	end

end
