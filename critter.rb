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

require 'simulation_item'
require 'observer'
require 'set'

class Critter < SimulationItem
	include Observable

	attr_reader :energy, :traits, :priorities

	def initialize(x, y, simulation, parent=nil)
		super
		@x = x
		@y = y
		@image_name = "graphics/critter.png"
		@simulation = simulation	
		initialize_internal_variables

		if parent
			inherit_parent_traits(parent)
		else
			standard_traits
		end
	end

	# Initializes instance variables needed for internal book keepings and logic etc.
	def initialize_internal_variables
		@energy = 340 
		@width = 10 
		@height = 10 
		@traits = {}	
		@is_alive = true
		@step_size = 10.0 		
		@age = 0	
		@behavior = :idle
		@behavior_is_new = false				# Used in tracking how long the current behavior has been executing	
		@behavior_counter_start = 0				# Marks the start time for the new behavior
		@behavior_counter = 0					# Counter for how many cycles the current behavior has been running
		@elapsed_time_on_search_path = 0		# Should I stay or should I go.. on the current search path.. not The Clash	
		@search_direction = 0					# Used in the critter's search for food	
		@all_food = []							# All food item[s] critter has smelled (detected)
		@food = nil								# Food item critter will attempt to consume
		@paid_activation_energy = false			# Flag used in keeping track of state of activation energy payment.  No pay => we break your legs
		@made_decision = false					# Flag used to track the state of decision from one cycle to another... i.e coin flip in 
	end

	# Evantually some of these values should be supplied by the simulator based on the statistics it has collected.  The simulator will try to tweak these traits
	# so as to maximize the run-time of the simulation (how long the critters stay alive)
	def standard_traits 
		@traits[:energy_capacity] = 750			# The total amount of energy, not including fat, a critter can store
		@traits[:energy_consumption_rate] = 1	# Rate of normal metabolic energy consumption
#		@traits[:fat] = 200						# Energy stored in excess of normal storage
		@traits[:biological_clock] = 30 		# Minimum time between reprduction cycles
		@traits[:hunger_point] = 500			# Threshold where critter becomes hungry for food 
		@traits[:starvation_point] = 100		# Energy level where the need to consume food overrides all other behaviors 
	    @traits[:smell_range] = 170 			# Maximum detection range for smell 
		@traits[:smell_cost] = 2				# Energy cost to use smell ability
		@traits[:bite_size] = 10				# Size of the energetic bite critter can take out of food items
		@traits[:stubborness] = 15				# Determines how long critter will search on a path before it chooses a new one
		@traits[:self_reliance] = 0				# Used to determine if critter will ask for help in duress or not
#		@traits[:cooperativeness] = 0
#		@traits[:aggressiveness] = 0
#       @traits[:competitiveness] = 0			# Determines if critter is eager to compete for food
#   	@traits[:apatheticness] = 0				# Determines if critter is unwilling to compete for food
		@traits[:faith_in_charity] = 0			# Determines if critter is willing to idle while waiting for help instead of searching for food
		@traits[:cautiousness] = 10				# Competes with appetite_for_risk 
		@traits[:appetite_for_risk] = 10 		# Competes with cautiousness
#       @traits[:appetite_for_destruction] = 0  # Turn me around and take me back to the start, I must be losing my mind.
#		@traits[:prejudice] = 0
#		@traits[:similarity] = 0
#		@traits[:charity] = 0
#       @traits{:greediness] = 0				# Used in food interaction behavior.  Greedy critters will eat more than they need etc.
		@traits[:reproduction_minimum] = 400	# Minimum energy needed to reproduce.
		@traits[:reproduction_cost] = 200
		@traits[:lifespan] = 800				# Maximum lifespan of heatlhy critters	
		express_traits
	end

# 	Mutate traits from parents 
# 	@energy = parent.traits[:nurturing]
	def inherit_parent_traits(parent)
		# Add code to mutate traits from parent
		# Ensure trait values are positive and reasonably bounded
		@traits = parent.traits
		express_traits
		@energy = @reproduction_cost
	end

	# 'Express' the 'genes' through instance variables, so they can be easily used for logic/computation etc.
	def express_traits
		@traits.keys.each do |trait|	
			self.instance_variable_set("@#{trait}", @traits[trait])
		end
	end

	def update
		update_internal_state
		execute_behavior
		#p @behavior.to_s
	end

#===================================================== Internal Behavior ================================================

	def update_internal_state 
		@age += 1 
		# Critter reaches adult size at roughly 100 units of age
		if @age <= 100 
			@width = (-14.0 + 24 * Math.log10(@age + 10)).ceil	
			@height = @width
		else
			# I'm a big kid look what I can do	
			@width, @height = 35,35
		end	

		@energy -= @energy_consumption_rate
		is_alive?	
		if @biological_clock > 0 then @biological_clock -= 1 end
		
		# When an internal condition warrants a change of behavior, ask the brain what to do	
		if is_hungry? then ask_the_brain_what_to_do :search_for_food end		
		if is_starving?	then ask_the_brain_what_to_do :ask_for_help end
		if can_reproduce? then ask_the_brain_what_to_do :reproduce end	
	end
	
	def ask_the_brain_what_to_do(potential_new_behavior=nil)
		# When potentially switching between behaviors 
		# With 6 basic behaviors there are 15 (6*5/2) combination comparisons to make (actually fewer, some don't make sense)
		if potential_new_behavior	
			behavior_set = [@behavior, potential_new_behavior].to_set	
			case behavior_set 
				when [:idle, :search_for_food].to_set
					idle_or_search
				when [:idle, :consume_food].to_set	
					idle_or_consume	
				when [:idle, :give_help].to_set
					idle_or_help
				when [:idle, :ask_for_help].to_set
					idle_or_ask
				when [:idle, :reproduce].to_set
					idle_or_reproduce
				when [:search_for_food, :consume_food].to_set
					search_or_consume
				when [:search_for_food, :give_help].to_set	
					search_or_help
				when [:search_for_food, :ask_for_help].to_set	
					search_or_ask
				when [:search_for_food, :reproduce].to_set	
					search_or_reproduce
				when [:consume_food, :give_help].to_set
					consume_or_help	
				when [:consume_food, :ask_for_help].to_set
					consume_or_ask
				when [:consume_food, :reproduce].to_set
					consume_or_reproduce
				when [:give_help, :ask_for_help].to_set
					help_or_ask
				when [:give_help, :reproduce].to_set	
					help_or_reproduce
				when [:ask_for_help, :reproduce].to_set
					ask_or_reproduce
			end
		# When not switching between behaviors 
		else
			if is_hungry?
				@behavior = :search_for_food
				search_or_ask	
			elsif can_reproduce?	
				@behavior = :reproduce	
			else
				@behavior = :idle	
			end
		end
	end

	def execute_behavior
		case @behavior 
		when :consume_food
			consume_food
		when :search_for_food
			search_for_food
		when :reproduce
			reproduce
		when :idle
			idle
		when :give_help
			give_help
		end
	end

#===================================================== External Behaviors ================================================

	def idle
		move_idle	
	end

#	Randomly pick a target location and perform a smell sensor sweep along that path.
#	If after n number of cycles no food is detected, randomly move in a new direction that is perpendicular to the current
#	one and continue sensor sweep; just don't forget the beeps and the creeps and most importantly... don't get jammed!
	def search_for_food
		detected_food = smell
		if detected_food.size == 0
			@elapsed_time_on_search_path += 1			
			# If the current search direction has been unsuccessful for too long try out a new direction; this goes for the critter too
			
			# Start the search with a random path 
			if @elapsed_time_on_search_path == 1	
				@search_direction = rand(2 * Math::PI)
				move_fuzzily_towards(@search_direction)
			# Continue search on current path	
			elsif @elapsed_time_on_search_path < @stubborness
				move_fuzzily_towards(@search_direction)
			# Search on a new path perpendicular to the current
			else @elapsed_time_on_search_path >= @stubborness
				coin_flip = rand(2)
				if coin_flip == 0 then @search_direction += Math::PI/2.0 else @search_direction -= Math::PI/2.0 end
				# reset the time spent on the new search path
				@elapsed_time_on_search_path = 1	
			end
		else	
			@all_foods = detected_food
			# Ask the brain if any of the foods are suitable for consumption.
			ask_the_brain_what_to_do :consume_food
			# If the behavior is to still seach, then the food found is not suitable.
			if @behavior == :search_for_food
				# Start the search with a random path 
				@elapsed_time_on_search_path += 1	
				if @elapsed_time_on_search_path == 1	
					@search_direction = rand(2 * Math::PI)
					move_fuzzily_towards(@search_direction)
				# Continue search on current path	
				elsif @elapsed_time_on_search_path < @stubborness
					move_fuzzily_towards(@search_direction)
				# Search on a new path perpendicular to the current
				else @elapsed_time_on_search_path >= @stubborness
					coin_flip = rand(2)
					if coin_flip == 0 then @search_direction += Math::PI/2.0 else @search_direction -= Math::PI/2.0 end
					# reset the time spent on the new search path
					@elapsed_time_on_search_path = 1	
				end
			end	
		end
	end
	
	# Eat the food (increment critter energy level, decrement food energy content)	
	# If the critter has satisfied the minimum amount of consumption to stave off hunger, how much more should it consume.  
	# Should it consume to 100% energy and fat?	
	def consume_food
		
		if @food.nil? 
			ask_the_brain_what_to_do :search_for_food 
			return	
		end

		# If the critter is not close enough to interact with food, move closer
		if ((@x - @food.x).abs > Simulation::INTERACTION_RANGE) || ((@y - @food.y).abs > Simulation::INTERACTION_RANGE)
			angle = interception_angle(@food.x, @food.y)
			move_fuzzily_towards(angle)
			return
		end

		# If the activation energy has been paid	
		if @paid_activation_energy 	
			bite = @food.consume(@bite_size)	
			# If the bite is empty the food no longer exists 
			if bite == 0
				@food = nil	
				ask_the_brain_what_to_do :search_for_food
				return
			else
				@energy += bite 
			end
			# If the last bite resulted in the critter being full, ask the brain what to do now
			if @energy >= @energy_capacity 
				ask_the_brain_what_to_do :idle 
			end
		# Pay the activation energy cost for the food item, start consumption in the next cycle
		else	
			@energy -= @food.activation_energy
			@paid_activation_energy = true
		end	
	end

	def reproduce
		offspring = Critter.new(@x,@y,@simulation,self)
		changed
		notify_observers offspring, :born
		@biological_clock = @traits[:biological_clock]
		@energy -= @reproduction_cost 
		ask_the_brain_what_to_do 
	end

	def ask_for_help

	end

	def receive_help

	end

	def give_help

	end

# ================================================== Motion & Detection ==========================================

	def move_idle
		@x += rand(@step_size*2) - @step_size 
		@y += rand(@step_size*2) - @step_size 
		# Keep critters within view
		keep_within_viewable	
		@angle += (rand(90) * Math::PI/180) - (45 * Math::PI/180)
	end

	def move_wait_for_help
		# Conserve energy while waiting for help
		# Should oscillate like a metrinome
	end

	# Maybe this can be used for forming herds? 
	def move_fuzzy_orbit(x,y)
		#  Add code to enable fuzzy orbiting
	end

	# Angle argument from 0 to 2PI
	def move_fuzzily_towards(angle)
		@angle = angle	
		@x += Math.cos(angle) * @step_size
		@y += Math.sin(angle) * @step_size 
		keep_within_viewable
	end

	# Keep the critters within viewable boundaries of the simulation 
	#
	# Oh give me land lots of land with no microscopes above, don't petri dish me in.
	# Let me wander over yonder to the colonies that I love, don't petri dish me in.
	# Let me wiggle to the edge where the medium commences, 
	# infect the grad students with my vessicular dispenses.
	# Disinfect my world with your bleaching offenses, but please, don't petri dish me in.
	def keep_within_viewable
		if @x < 0 then @x += 15 end
		if @x > Simulation::SIMULATION_WIDTH then @x -= 15 end
		if @y < 0 then @y += 15 end
		if @y > Simulation::SIMULATION_HEIGHT then @y -= 15 end
	end

	# Interception angle in radians
	#	  y
	#	  ^	    _____
	#	  |    (_____:)   (critter is oriented to the right with angle = 0 radians
	#	  |
	#	  |
	#	 (0,0) ----> x
	def interception_angle(x,y)
		angle = 0
		if x == @x	
			if y >= @y	
				angle = Math::PI / 2.0	
			else
				angle = 3.0 * Math::PI / 2.0
			end	
		elsif x < @x
			angle = Math::PI + Math.atan((y-@y)/(x-@x))
		else
			angle = Math.atan((y-@y)/(x-@x))
		end	
		angle
	end

  	# Smell returns array of all food_items within range of detection in order from closest to farthest
	def smell
		@energy -= (@smell_range * @smell_cost/100.0).ceil

		food_in_range = []

		unless @simulation.all_foods.size == 0
			@simulation.all_foods.each do |food|
				if ((@x - food.x).abs < @smell_range) && ((@y - food.y).abs < @smell_range)
					food_in_range << food
				end
			end	
			food_in_range = food_in_range.sort_by {|f| [(f.x-@x).abs, (f.y-@y).abs]}
		end
		food_in_range
	end

# =================================================== Regarding State ==========================================

	def is_hungry?
		if @energy <= @hunger_point 
			true
		else
			@is_hungry = false
		    false
		end	   
	end

	def can_reproduce?
		if @biological_clock == 0 && @energy >= @reproduction_minimum
			true
		else
			false
		end
	end

	def is_starving?
		if @energy <= @starvation_point then true else false end	
	end

	def is_idle?

	end

	def is_helping?

	end

	def is_alive?
		if @energy <= 0  # || @age == @lifespan 
			@energy = 0
			# Inform the simulation object that the critter is dead	
			changed
			notify_observers self,:dead
			false
		else
			true
		end
	end

	def reset_elapsed_time_on_search_path 
		@elapsed_time_on_search_path = 0	
	end

#=================================================== IDLE DECISIONS =================================================

	def idle_or_search
		if is_hungry?
			if @behavior == :idle 
				@behavior = :search_for_food 
				reset_elapsed_time_on_search_path	
			end
		else 
			@behavior = :idle 
		end
	end

	def idle_or_consume
		if is_hungry?
			@behavior = :consume
		else
			@behavior = :idle
		end	
	end

	def idle_or_help
		# Decision should be based on whether helping is valued, and if helping is valued at what point of risk is that value negated.
	end

	def idle_or_ask

	end

	def idle_or_reproduce
		if can_reproduce? then @behavior = :reproduce  else @behavior = :idle end
	end

#=================================================== SEARCH DECISIONS =================================================

	# Whether the critter searches or consumes depends on what's available to it.  If there are 0 food items within range then obviously it needs to search.
	# If there is only 1 item within range, what it does depends on what type of food item it is.  If the food is easy, then the critter should try and eat it.
	# If the only food item is hard, then the critter should try and consume it if it has an appetite for risk or search instead if the critter is more cautious.	
	# When the critter is hungry it should always be closing in on its food leads. Glengarry Glen Ross leads are only for critters that close.  
	def search_or_consume
		@all_foods = smell
		if is_hungry?
			if @all_foods.size == 1
				# If the food is easy
				if @all_foods[0].is_easy_to_eat?
					@behavior = :consume_food
					@food = @all_foods[0]
				# If the food is hard
				else 
					# If the critter is more cautiousness than risk-seeking keep searching for easier food	
					if @appetite_for_risk > @cautiousness
						@behavior = :consume_food						
					elsif @appetite_for_risk < @cautiousness
						reset_elapsed_time_on_search_path unless @behavior == :search_for_food	
						@behavior = :search_for_food
					# If the critter is neutral, than flip a coin
					else
						coin_toss = rand(2)
						if coin_toss.odd?	
							@behavior = :consume_food	
						else	
							reset_elapsed_time_on_search_path unless @behavior == :search_for_food	
							@behavior = :search_for_food 
						end
					end
				end	
			elsif @all_foods.size > 1
				easy_food = @all_foods.select {|food| food.is_easy_to_eat? == true }
				hard_food = @all_foods.select {|food| food.is_easy_to_eat? == false }
				# Only hard foods
				if easy_food.empty? 
					if @appetite_for_risk > @cautiousness 
						@behavior = :consume_food
						@food = hard_food[0]
				   	else 
						# only reset the elapsed time on the path when switching from some other behavior to searching for food	
						reset_elapsed_time_on_search_path unless @behavior == :search_for_food
						@behavior = :search_for_food 
					end
				# Only easy foods	
				elsif hard_food.empty?
					@behavior = :consume_food
					@food = easy_food[0]	
				# Mixture of easy and hard foods
				else
					# Willing to risk the hard food	
					if @appetite_for_risk > @cautiousness
						@behavior = :consume_food
						@food = hard_food[0]
					elsif @appetite_for_risk < @cautiousness
						@behavior = :consume_food 
						@food = easy_food[0]
					else
						coin_toss = rand(2)
						if coin_toss.odd? 
							@behavior = :consume_food 
						else 
							reset_elapsed_time_on_search_path unless @behavior == :search_for_food	
							@behavior = :search_for_food 
						end
					end
				end	
			else 
				@paid_activation_energy = false	
				@behavior = :search_for_food 
			end 
		else
			ask_the_brain_what_to_do
		end
	end

	def search_or_help

	end

	def search_or_ask

	end

	def search_or_reproduce

	end

#=================================================== CONSUME DECISIONS =================================================
	def consume_or_help

	end

	def consume_or_ask

	end

	def consume_or_reproduce

	end

#=================================================== HELP DECISIONS =================================================
	def help_or_ask

	end

	def help_or_reproduce

	end

	
#=================================================== ASK DECISIONS =================================================
	def ask_or_reproduce

	end
end
