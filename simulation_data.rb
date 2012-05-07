#  This module contains common data used throughout the simulation.

module SimulationData

	SIMULATION_WIDTH = 1024 
	SIMULATION_HEIGHT = 1024 
	GRID_RESOLUTION = 10
	TIME_INCREMENT = 0.2
	MAX_POPULATION = 100

	def all_layers
		@all_layers ||= []	
	end

	def add_subLayer(item)
		# Sync Critter array	
		case item.class
		when Critter
			@all_critters << item
		when Food
			@all_foods << item
		end
		# Add to all_layers	
		new_layer = ImageLayer.alloc.initWithItem(item)
		all_layers << new_layer
		@background_layer.addSublayer(new_layer)	
		new_layer
	end

	def remove_subLayer(item)
		layer_to_remove = all_layers.detect{ |l| l.item == item}			
		if layer_to_remove
			layer_to_remove.removeFromSuperlayer if layer_to_remove.respond_to?(:removeFromSuperlayer)	
			all_layers.delete(layer_to_remove)
			@background_layer.refresh
		end
	end

	def all_critters
		@all_critters ||= []	
	end

	def add_critter(critter)
		add_subLayer(critter)		
	end

	def remove_critter(critter)
		remove_subLayer(critter)
	end

	def all_food_items
		@all_foods ||= []	
	end

	def add_food_item(food)
		add_subLayer(food)
	end

	def number_of_critters
		# return the total critter population	
		all_critters = @all_layers.find_all { |l| l.item.class == Critter }.size
	end

	def calculate_average_trait(trait)
		# calculate the current trait average 	
	end

	def calculate_standard_deviation(trait)
		# calculate standard deviation for trait
	end
end
