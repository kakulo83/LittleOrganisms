require 'simulation_item'

class Food < SimulationItem
	attr_reader :x, :y, :width, :height, :angle

	def initialize(x, y, width, height)
		super
		@x = x
		@y = y
		@width = width
		@height = height
		@image_name = "graphics/hoop_food.png"
	end

	def update
	end
end
