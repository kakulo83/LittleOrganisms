require 'simulation_item'

class Food < SimulationItem
	attr_reader :x, :y, :width, :height, :angle, :activation_energy

	def initialize(x, y, width, height, activation_energy)
		super
		@x = x
		@y = y
		@width = width
		@height = height
		@activation_energy = activation_energy
		if activation_energy <= 10 
			@easy_to_eat = true 
			@image_name = "graphics/easy_food.png"	
		else 
			@easy_to_eat = false 
			@image_name = "graphics/hard_food.png"
		end
	end

	def update
		# reduce the CALayer in proportion to how much of food
		# item is depleted 
	end

	def is_hard_to_eat?
		@easy_to_eat
	end	

end
