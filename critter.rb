require 'simulation_item'
require 'observer'
require 'json'

class Critter < SimulationItem
	include Observable

	attr_reader :x, :y, :width, :height, :angle, :energy, :traits, :priorities

	def initialize(x, y, width, height, simulation, parent=nil)
		super
		@x = x
		@y = y
		@width = width
		@height = height	
		@image_name = "graphics/critter.png"
		@simulation = simulation	
		@step_size = 10.0 		
		@traits = {}	
		@is_alive = true
		@age = 0	
		@is_hungry = false	
		@priorities = [:consume_food, :search_for_food, :reproduce, :idle, :give_help]
		@purpose = :idle
		@purpose_is_new = false					# Used in tracking how long the current purpose has been executing	
		@purpose_counter_start = 0				# Marks the start time for the new purpose
		@purpose_counter = 0					# Counter for how many cycles the current purpose has been running
		@elapsed_time_on_search_path = 0		# Should I stay or should I go.. on the current search path.. not The Clash	
		@search_direction = 0					# Used in the critter's search for food	
		@food = nil								# Food item critter will attempt to consume
		@paid_activation_energy = false			# Flag used in keeping track of state of activation energy payment.  No pay => we break your legs
		@energy = 340 
		
		if parent
			inherit_parent_traits(parent)
		else
			standard_traits
		end
	end

	def standard_traits 
		@traits[:energy_capacity] = 550			# The total amount of energy, not including fat, a critter can store
		@traits[:energy_consumption_rate] = 1	# Rate of normal metabolic energy consumption
		@traits[:fat] = 20						# Energy stored in excess of normal storage
		@traits[:biological_clock] = 100 		# Minimum time between reproduction cycles
		@traits[:hunger_point] = 300			# Threshold where critter becomes hungry for food 
		@traits[:starvation_point] = 100		# Energy level where the need to consume food overrides all other purposes 
	    @traits[:smell_range] = 170 			# Maximum detection range for smell 
		@traits[:smell_cost] = 2				# Energy cost to use smell ability
		@traits[:stubborness] = 15				# Determines how long critter will search on a path before it chooses a new one
#		@traits[:cooperation] = 0
#		@traits[:aggressiveness] = 0
#		@traits[:risk] = 0
#		@traits[:prejudice] = 0
#		@traits[:similarity] = 0
#		@traits[:charity] = 0
#       @traits{:greediness] = 0				# Used in food interaction behavior.  Greedy critters will eat more than they need etc.
#		@traits[:nurturing] = 0
		@traits[:lifespan] = 800				# Maximum lifespan of heatlhy critters	
		express_traits
	end

# 	Mutate traits from parents 
# 	@energy = parent.traits[:nurturing]
	def inherit_parent_traits(parent)
		express_traits	
	end

# 	Increasing the smell_range should incur an energy cost
# 	Modifying one trait should have an effect on other traits.
	def trait_to_trait_relationships
#   Don't know what to put here yet, if anything
	end

	def update
		update_internal_state
		execute_purpose
	end

	# 'Express' the 'genes' through instance variables, so they can be easily used for logic/computation etc.
	def express_traits
		@traits.keys.each do |trait|	
			self.instance_variable_set("@#{trait}", @traits[trait])
		end
	end

#===================================================== Internal Behavior ================================================

	def update_internal_state 
		if is_alive?	
			@energy -= @energy_consumption_rate
			@age += 1 
			@biological_clock -= 1 
		
			if @energy <= @hunger_point then ask_the_brain_what_to_do(:search_for_food) end
			
			if @biological_clock == 0 then ask_the_brain_what_to_do(:reproduce) end	
		end
	end

	def ask_the_brain_what_to_do(potential_new_purpose)
		# 		Basic Decision Making Framework for all critter behavior occur here
		#
		#
		#  		Possible behaviors:   :eat :find_food :reproduce :idle :give_help
		#
		#		Precedence of purpose should eventually be flexible.  Some critters might value reproduction over eating
		#		while others value food intake as most important.
		#
		#  		Check if at starvation point, if yes finding food/eating trumps all other purposes.
		#	
		#  		Check if the critter is hungry.  If hungry, is the current purpose finding food, eating, helping?
		# 		If no, make a decision as to whether to continue with current purpose or switch to finding food/eating. 
		#
		#  		If the critter is not starving/hungry then it can idle, help other critters, or reproduce.   
		#	
		#	
		#       If a critter is not hungry and another critter at some distance issues an energy request that this critter is considering:
		#        
		#			1.  How does critter A "decide" to help critter B.  Moving to critter B requires energy for motion.
		#			2.  How much does critter A give to B?
		#			3.  What if critter A becomes hungry before reaching B?  What if after giving energy it becomes hungry, does that factor
		# 			  	into the decision to help B in the first place?
		old_purpose = @purpose

		case potential_new_purpose 
		when :idle
			# Critter should idle if it is not hungry.  The critter then must decide, based on its preferences between 
			# reproducing (if it can) and giving help (if it has been asked)
			
			@purpose = :idle
		when :search_for_food
			# If the critter is starving, the search and consumption of food trumps all other behaviors.  If the critter is merely
			# hungry the relative priority of eating vs helping others or reproducing will be factors in it deciding to search 
			# for food.  The magnitude of the hunger also serves as a factor.  
	
			# If the critter has already found food, it shouldn't revert to trying to find it	
			if old_purpose == :consume_food then return end

			if is_hungry?
				@purpose = :search_for_food
				# When the search is just starting, initialize elapsed time on search to zero.	
				if old_purpose != @purpose 
					@elapsed_time_on_search_path = 0
					@paid_activation_energy = false
			   	end 
			end
		when :consume_food
			# There are several things to consider here.  If only 1 food item was detected it can be an easy to consume or hard to 
			# consume item.  Either way, a judgment must be made as to whether it is worth it for the critter to try and consume it	
			# or if the critter is better off continuing to search for a more advantageous scenario.	
			
			# Eventually allow critters to consume food when they don't need it, every system needs a douchebag to keep things evolving.	


			# Scenarios: 
			#
			# The critter is only somewhat hungry and it has been asked to help out another critter in need.  That other
			# critter is very close by.  This critter may decide to suspend the satisfying of its hunger in order to help the other
			# critter.  

			# The critter is confronted with a hard to eat item.  It may either try to eat it or not.  This will depend on its 
			# tolerance for risk.  If it is very risk averse it may decide to seek out another food item.

			# If the critter decides to consume the food item, it then invokes the food's activation energy requirement method.  The
			# value

			@purpose = :consume_food
		when :reproduce	
			# @purpose = :reproduce	
		when :give_help
			# Determine if purpose should be to :give_help
			# Determine how much energy should be given	
			@purpose = :give_help
		end
	end

	def execute_purpose
		case @purpose 
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
			# With one or more food items available, the critter must decide if it should engage one or indeed any food items at all. 
			# Distance to food, activation energy, the critter's current store of energy all together ultimately define the probability
			# of the critter's success in engaging a particular food item. 
			@food = detected_food[0]	
			
			proximity_x = (@x - @food.x).abs
			proximity_y = (@y - @food.y).abs

			if (proximity_x > Simulation::INTERACTION_RANGE) ||(proximity_y > Simulation::INTERACTION_RANGE)
				angle = interception_angle(@food.x, @food.y)
				move_fuzzily_towards(angle)
			else
				# Obtain the activation energy requirement from the food item, make a final decision on whether to consume it or not	
				ask_the_brain_what_to_do(:consume_food)
			end
		end
	end

	def consume_food
		# Eat the food (increment critter energy level, decrement food energy content)	
		# If the critter has satisfied the minimum amount of consumption to stave off hunger, how much more should it consume.  
		# Should it consume to 100% energy and fat?	
		if @paid_activation_energy 	
			@energy += 10	
			if @energy >= @energy_capacity then ask_the_brain_what_to_do(:idle) end
		# Pay the activation energy cost for the food item, start consumption in the next cycle
		else	
			requirement = @food.activation_energy
			@energy -= requirement
			@paid_activation_energy = true
			return
		end	
	end

	def reproduce
		offspring = Critter.new(@x,@y,@width,@height,@simulation,self)
		changed
		notify_observers offspring, :born
		@biological_clock = 100
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
	# Oh give me land lots of land with no microscopes above.. don't petri dish me in.
	# Let me wander over yonder to the colonies that I love.. don't petri dish me in.
	# Let me wiggle to the edge where the medium commences, infect the grad students with my
	# vessicular dispenses
	# Disinfect my world with your bleach offenses, but please, don't petri dish me in.
	#
	def keep_within_viewable
		if @x < 0 then @x += 15 end
		if @x > Simulation::SIMULATION_WIDTH then @x -= 15 end
		if @y < 0 then @y += 15 end
		if @y > Simulation::SIMULATION_HEIGHT then @y -= 15 end
	end

	# Interception angle in radians
	def interception_angle(x,y)
		#	  y
		#	  ^	    _____
		#	  |    (_____:)   (critter is oriented to the right with angle = 0 radians
		#	  |
		#	  |
		#	 (0,0) ----> x
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
		# Use of smell incurs energy cost	
		@energy -= (@smell_range * @smell_cost/100.0).ceil

		food_in_range = []

		unless @simulation.all_food_items.size == 0
			@simulation.all_food_items.each do |food|
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
		if @energy <= @hunger_point then true else false end 
	end

	def is_starving?
		if @energy <= @starvation_point then true else false end	
	end

	def is_reproducing?
		
	end

	def is_idle?

	end

	def is_helping?

	end

	def is_alive?
		if @energy <= 0 || @age == @lifespan 
			p "Critter is dead"	
			@energy = 0
			changed
			notify_observers self,:dead
			@is_alive = false
			false
		else
			true
		end
	end

end
