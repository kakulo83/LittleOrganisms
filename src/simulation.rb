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


# Simulation contains the main loop that invokes the update method for all simulation items.  The Simulation Object also
# updates the environmen (food), responds to critter/food issued events, and also the mouse/button clicks that open up
# the data windows 

require 'src/gui/data_gui'
require 'simulation_constants'
require 'simulation_data'
require 'critter'
require 'food'

class Simulation

	include SimulationData
	include SimulationConstants 

	attr_accessor :simulation_layer

	def start_simulation
		# Init simulation time to zero
		$simulation_time = 0
		# Setup the relationship between new food and the simulation time 
		init_environment()
		# Add the initial food and critters to the simulation
		init_simulation(1,8)	
		# Create the object that will manage the data windows
		@data_gui = DataGUI.new(self)
		@timer = NSTimer.scheduledTimerWithTimeInterval TIME_INCREMENT, 
			target: self, 
			selector: 'global_update', 
			userInfo: nil, 
			repeats: true
	end

	def pause_simulation
		@timer.invalidate
	end

	def continue_simulation
		@timer = NSTimer.scheduledTimerWithTimeInterval TIME_INCREMENT, 
			target: self, 
			selector: 'global_update', 
			userInfo: nil, 
			repeats: true
	end

	def restart_simulation
		# Add code so simulation can be restarted whilst running
	end

	def end_simulation
		#add_global_data which includes the total run time of the simulation 
		exit	
	end

	def init_environment()
		@seasonal_multiplier = []	# Used to wax/wane the TOTAL_AVAILABLE_ENERGY energy throughout time; just like variable sun-light
		CYCLES_PER_SEASON.times do |time|
			# What is this equation?   I just made this crap up		
			@seasonal_multiplier[time] = (0.25 + (0.75/2) + (0.75/2) * Math.cos(2*Math::PI*time/CYCLES_PER_SEASON.to_f)).round(2)
		end
	end

	def init_simulation(num_critter, num_food)
		# These two food items are added right next to the 1st critter to ensure it survives the first few cycles.
		# Life in this simulation is pretty rough as it is, it's the least we can do. 	
		food0 = Food.new(645,730,5,50.0)
		food0.add_observer self	
		add_food_item(food0)

		food1 = Food.new(550,670,35,1000.0)	
		food1.add_observer self	
		add_food_item(food1)

		num_food.times do
			food = Food.new(rand(SIMULATION_WIDTH), rand(SIMULATION_HEIGHT),rand(20),300.0)
			food.add_observer self
			add_food_item(food)
		end
		
		num_critter.times do
			critter = Critter.new(600,700,self)
			critter.add_observer self
			add_critter(critter)
		end
	end

	def global_update 
		update_time	
		update_environment
		all_layers.each { |layer| layer.update }
		update_data_windows
	end

	def update_time
		if $simulation_time <= CYCLES_PER_SEASON-1 then $simulation_time += 1 else $simulation_time = 0 end	
	end

	def update_environment
		if $simulation_time == 20 || $simulation_time == 166 || $simulation_time == 333 || $simulation_time == 499 
			# Add new food items taking into consideration the population food items and the seasonal energy available.	
			total_food_cost = 0.0
		   	all_foods.each {|food| total_food_cost += food.nutritional_content }
			available_energy = MAX_AVAILABLE_ENERGY * @seasonal_multiplier[$simulation_time] - total_food_cost
			
			max_number_of_new_food = (available_energy / 450.0).ceil
		
			if max_number_of_new_food < number_of_foods 
				number_of_new = max_number_of_new_food
			else
				number_of_new = number_of_foods 
			end

			number_of_new.times do
				parent_food = all_foods[rand(number_of_foods-1)]
				# New food items should be somewhat clustered around their parents	
				new_food_x, new_food_y = parent_food.x + rand(200)-100, parent_food.y + rand(200) - 100

				# Ensure new food items are within simulation boundary
				if new_food_x < 0 then new_food_x = 0 end
				if new_food_x > SIMULATION_WIDTH then new_food_x = SIMULATION_WIDTH end 

				if new_food_y < 0 then new_food_x = 0 end
				if new_food_y > SIMULATION_HEIGHT then new_food_y = SIMULATION_HEIGHT end

				food = Food.new(new_food_x, new_food_y, rand(20),300.0+rand(200))
				food.add_observer self
				add_food_item(food)
			end
		end
	end

	def update_data_windows
		#  Add code to update any windows
	end

	# Listener for Critter and Food issued events, observer pattern added in critter/food requires listener handler method
	# to be called 'update' 
	def update(item, type, *additional)
		case item
		when Critter
			case type
			when :dead
				remove_critter item 
				add_local_data item, type
				if all_critters.empty? then pause_simulation end
			when :born
				if all_critters.size < MAX_POPULATION 
					item.add_observer self	
					add_critter item 
					add_local_data item, type
				end
			when :ask_for_help
			
			when :eating
	
			when :made_decision

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

	def mouseUp(event)
		# Check if click is on or closet enough to a critter 

		#p event.locationInWindow.x.to_s + " " + event.locationInWindow.y.to_s
		all_critters.each do |critter|
			# if click distance is less than closest critter
			#    then this critter is the new closest critter 
			# else
			# 	 continue searching
			#
			# issue a request to DataGUI for a new_simulation_item_data_window (DataGUI will then make a new data window if one for this critter does not already exist
		end

		@data_gui = DataGUI.new(self)
		@data_gui.new_simulation_item_data_window
	end

	def mouseDown(event)
	end

	def mouseDragged(event)
	end

	def flagsChanged(event)
		# Raised when keys like "control" "shift" are pressed
	end

	def keyUp(event)
	end

	def keyDown(event)
	end

	def scrollWheel(event)
	end

	def start_stop_btn_handler(sender)
		p "toggling simulation"	
	end

	def history_data_btn_handler(sender)
		p "Showing simulation history data"		
	end

	def instance_data_btn_handler(sender)
		p "Showing instance data"
	end
end
