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

require 'simulation_data'

module Simulation
	include SimulationData 

	$simulation_time

	def start_simulation
		$simulation_time = 0
		init_environment()
		init_simulation(1,10)	

		# Start the all important simulation loop
		@timer = NSTimer.scheduledTimerWithTimeInterval SimulationData::TIME_INCREMENT, 
			target: self, 
			selector: 'refresh', 
			userInfo: nil, 
			repeats: true
	end

	def restart_simulation
		# Add code so simulation can be restarted whilst running
	end

	def init_environment()
		@seasonal_multiplier = []	# Used to wax/wane the TOTAL_AVAILABLE_ENERGY energy throughout time; just like variable sun-light output
		CYCLES_PER_SEASON.times do |time|
			@seasonal_multiplier[time] = (0.25 + (0.75/2) + (0.75/2) * Math.cos(2*Math::PI*time/CYCLES_PER_SEASON.to_f)).round(2)
		end
	end

	def init_simulation(num_critter, num_food)
		# These two food items are added right next to the 1st critter to ensure it survives the first few cycles.
		# Life in this simulation is pretty rough as it is, it's the least we can do. 	
		food0 = Food.new(645,730,35,35,5,1000.0)
		food0.add_observer self	
		add_food_item(food0)

		food1 = Food.new(550,670,35,35,10,2000.0)	
		food1.add_observer self	
		add_food_item(food1)

		num_food.times do
			food = Food.new(rand(SIMULATION_WIDTH),rand(SIMULATION_HEIGHT),35,35,rand(20),300.0)
			food.add_observer self
			add_food_item(food)
		end
		
		num_critter.times do
			critter = Critter.new(600,700,self)
			critter.add_observer self
			add_critter(critter)
		end
	end

	def refresh 
		if $simulation_time <= CYCLES_PER_SEASON-1 then $simulation_time += 1 else $simulation_time = 0 end	
		update_environment
		all_layers.each { |layer| layer.update }
	end

	def update_environment
		if $simulation_time == 166 || $simulation_time == 333 || $simulation_time == 499 
			food_growth_multiplier = 1.0 + @seasonal_multiplier[$simulation_time]
			num_of_new_food_items = (number_of_foods * food_growth_multiplier).ceil
			# Simulation has X number of Food items.  For this particular point in time, the available energy in the system is 
			# @seasonal_multiplier * TOTAL_AVAILABLE_ENERGY
	
			# If the sum of all the food energy < the instantaneous available total energy (sunlight), then what remains is available to the system 
			# as new food items.  The number of which is only bounded by the food_growth_multiplier 

			available_energy = @seasonal_multiplier * MAX_AVAILABLE_ENERGY 

			all_foods.each do |food| { sum += food.nutritional_content }

			num_of_new_food_items.times do
				food = Food.new(rand(SIMULATION_WIDTH),rand(SIMULATION_HEIGHT),35,35,rand(20),300+rand(300))
				food.add_observer self
				add_food_item(food)
			end
		end
	end

	# Listener for Critter and Food issued events
	def update(item,type,*additional)
		case item
		when Critter
			case type
			when :dead
				remove_critter item 
			when :born
				if all_critters.size < MAX_POPULATION 
					item.add_observer self	
					add_critter item 
					add_data_point item
				end
			when :ask_for_help
				p "Critter asks for help"
			when :eating
				p "Critter is eating"
			else
				p "Simulation.rb: What the hell critter event is this?"
			end
		when Food
			case type
			when :depleted
				remove_food item
			end
		end	
	end
end
