require 'simulation_item'

class Food < SimulationItem
	attr_reader :x, :y, :width, :height, :angle

	def initialize(x, y, width, height, easy_to_eat=true, activation_energy=nil)
		super
		@x = x
		@y = y
		@width = width
		@height = height
		if easy_to_eat 
			@image_name = "graphics/easy_food.png" 
		else
			@image_name = "graphics/hard_food.png"
		end
	end

	def update

	end

	def is_hard_to_eat?
		if easy_to_eat then true else false end
	end	
end
