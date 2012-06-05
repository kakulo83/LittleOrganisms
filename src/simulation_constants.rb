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

#  This module contains data and methods used throughout the simulation.

module SimulationConstants
	SIMULATION_WIDTH = 1024 			# Width of Main Simulation Window
	SIMULATION_HEIGHT = 1024 
	DATA_WIDTH = 341					# Default width for new data windows
	DATA_HEIGHT = 341					
	TIME_INCREMENT = 0.2				# Time between simulation updates (used in main simulation loop)
	MAX_POPULATION = 100				
	CYCLES_PER_SEASON = 500				 
	MAX_AVAILABLE_ENERGY = 60000.0		# The total amount of energy in the system available for the expressions of life
	INTERACTION_RANGE = 15.0			# The min distance two things have to be to interact w/each other
end
