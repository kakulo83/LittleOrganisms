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

	def number_of_critters
		# return the total critter population	
	end

	def calculate_average_trait(trait)
		# calculate the current trait average 	
	end

	def calculate_standard_deviation(trait)
		# calculate standard deviation for trait
	end
end
