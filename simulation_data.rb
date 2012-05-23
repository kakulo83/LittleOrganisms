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

#  This module contains common data used throughout the simulation.
require 'json'

module SimulationData

	SIMULATION_WIDTH = 1024 
	SIMULATION_HEIGHT = 1024 
	GRID_RESOLUTION = 10
	TIME_INCREMENT = 0.2
	MAX_POPULATION = 100
	CYCLES_PER_SEASON = 500
	MAX_AVAILABLE_ENERGY = 20000.0		# The total amount of energy available to the system at any given time (akin to sunshine) 
	INTERACTION_RANGE = 15.0			# The min distance two things have to be to interact w/each other

	def all_layers
		@all_layers ||= []	
	end

	def all_critters
		@all_critters ||= []	
	end

	def all_foods
		@all_foods ||= []	
	end

	def add_subLayer(item)
		# Add to all_layers	
		new_layer = ImageLayer.alloc.initWithItem(item)
		all_layers << new_layer
		@background_layer.addSublayer(new_layer)	
		new_layer
	end

	def remove_subLayer(item)
		# Remove from all_layers
		layer_to_remove = all_layers.detect{ |l| l.item == item}			
		if layer_to_remove
			layer_to_remove.removeFromSuperlayer if layer_to_remove.respond_to?(:removeFromSuperlayer)	
			all_layers.delete(layer_to_remove)
			@background_layer.refresh
		end
	end

	def add_critter(critter)
		all_critters << critter
		add_subLayer(critter)		
	end

	def add_food_item(food)
		all_foods << food
		add_subLayer(food)
	end

	def remove_critter(critter)
		all_critters.delete(critter)
		remove_subLayer(critter)
	end

	def remove_food(food)
		all_foods.delete(food)
		remove_subLayer(food)
	end

	def add_data_point(item,type,*additional)
		case item 
		when Critter
			case type
			when :born
				#File.open('data/aggregate.data',"a") { |f| f << item.traits.to_json + "\n" }
			when :dead
				#File.open('data/aggregate.data',"a") { |f| f << item.traits.to_json + "\n" }
			when :consume_decision

			when :consuming
				# Collect data on what the critter decided to eat
			when :asking_decision

			when :receiving	
		
			end
		when Food
			when :depleted
		end
	end

	def number_of_critters
		#@all_layers.find_all { |l| l.item.class == Critter }.size
		if @all_critters then @all_critters.size else 0 end
	end

	def number_of_foods
		if @all_foods then @all_foods.size else 0 end
	end

	def calculate_average_trait(trait)
		# calculate the current trait average 	
	end

	def calculate_standard_deviation(trait)
		# calculate standard deviation for trait
	end

end
