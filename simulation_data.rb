#  This module contains common data used throughout the simulation.

module SimulationData

	SIMULATION_WIDTH = 1024 
	SIMULATION_HEIGHT = 1024 
	GRID_RESOLUTION = 10
	TIME_INCREMENT = 0.2
	MAX_POPULATION = 100
	INTERACTION_RANGE = 15.0	# The min distance two things have to be to interact w/each other

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
		# Sync Critter/Food arrays	
		case item
		when Critter
			all_critters << item
		when Food
			all_foods << item
		end
		# Add to all_layers	
		new_layer = ImageLayer.alloc.initWithItem(item)
		all_layers << new_layer
		@background_layer.addSublayer(new_layer)	
		new_layer
	end

	def remove_subLayer(item)
		# Sync Critter/Food arrays
		case item
		when Critter
			p "Removing critter from all_critters array"	
			all_critters.delete(item)
		when Food
			p "Removing food from all_foods array"
			all_foods.delete(item)
		end
		# Remove from all_layers
		layer_to_remove = all_layers.detect{ |l| l.item == item}			
		if layer_to_remove
			layer_to_remove.removeFromSuperlayer if layer_to_remove.respond_to?(:removeFromSuperlayer)	
			all_layers.delete(layer_to_remove)
			@background_layer.refresh
		end
	end

	def add_critter(critter)
		add_subLayer(critter)		
	end

	def add_food_item(food)
		add_subLayer(food)
	end

	def remove_critter(critter)
		remove_subLayer(critter)
		#@all_critters.delete(critter)
	end

	def remove_food(food)
		remove_subLayer(food)
		#@all_foods.delete(food)
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
