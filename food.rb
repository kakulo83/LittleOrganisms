require 'simulation_item'
require 'observer'

class Food < SimulationItem
	include Observable	

	attr_reader :x, :y, :width, :height, :angle, :activation_energy

	def initialize(x, y, width, height, activation_energy, nutritional_content)
		super
		@x = x
		@y = y
		@width = width
		@height = height
		@activation_energy = activation_energy
		@nutritional_capacity = nutritional_content	
		@nutritional_content = nutritional_content

		if activation_energy <= 10 
			@easy_to_eat = true 
			@image_name = "graphics/easy_food.png"	
		else 
			@easy_to_eat = false 
			@image_name = "graphics/hard_food.png"
		end
	end

	def update
		# The relevant interaction and updating occurs in consume	
	end

	def is_hard_to_eat?
		@easy_to_eat
	end	

	def consume(bite_size) 
		# Decrease energy content of food	
		@nutritional_content -= bite_size 
		if @nutritional_content <= 0
			p "Food depleted"
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
