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
		@search_direction = 0					# Used in the critter's search for food	
		@food = nil								# Food item critter will attempt to consume
		if parent
			inherit_parent_traits(parent)
		else
			standard_traits
		end

		@energy = @traits[:energy_capacity]
	end

	def standard_traits 
		@traits[:energy_capacity] = 550			# The total amount of energy, not including fat, a critter can store
		@traits[:energy_consumption_rate] = 1	# Rate of normal metabolic energy consumption
		@traits[:fat] = 20						# Energy stored in excess of normal storage
		@traits[:biological_clock] = 100 		# Minimum time between reproduction cycles
		@traits[:hunger_point] = 530			# Threshold where critter becomes hungry for food 
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
		update_purpose
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
			if @biological_clock > 0 then @biological_clock -= 1 end	
		end
	end

	def update_purpose
	# 		Basic Decision Making Framework
	#
	#
	#  		:eat :find_food :reproduce :idle :give_help
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
	
		if is_hungry? 
			if old_purpose == :consume_food	
				return	
			else	
				@purpose = :search_for_food
				if @is_hungry == false	
					@elapsed_time_without_finding_food = 0
					@is_hungry = true
				end
			end
		end

		if old_purpose != @purpose 
			@purpose_is_new = true 
			@purpose_counter_start, @purpose_counter = @lifespan, @lifespan
		else 
			@purpose_is_new = false 
			@purpose_counter += 1	
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
#   
#   When the critter decides to start searching for food, it has to keep some sort of counter capturing how long it has been searching
#   on its current path.  If the search has been unsuccessful for too long, it should switch to and search along a new path. 
	def search_for_food
		detected_food = smell
		if detected_food.size == 0
			@elapsed_time_without_finding_food += 1			
			# If the current search direction has been unsuccessful for too long try out a new direction;
			# Oh yeah, do this for the critter as well good luck! :)
	
			if @elapsed_time_without_finding_food > @stubborness
				# Move perpendicular left or right relative to the current search direction	
				@elapsed_time_without_finding_food = 0	
				@search_direction += (rand(2)-1) * Math::PI/2.0
				move_fuzzily_towards(@search_direction)	
			elsif @elapsed_time_without_finding_food == 1
				# Pick a random new direction to start the adventure 
				@search_direction = rand(2 * Math::PI)	
				move_fuzzily_towards(@search_direction)
			else
				move_fuzzily_towards(@search_direction)
			end
		else	
			# With one or more food items available, the critter must decide if it should engage one or indeed any food items at all. 
			# Distance to food, activation energy, the critter's current store of energy all together ultimately define the probability
			# of the critter's success in engaging a particular food item. 

			@elapsed_time_without_finding_food = 0
			@food = detected_food[0]	
			@purpose = :consume_food
		end
	end

	def consume_food
		# If not within interaction distance keep moving towards the food
		if (@x - @food.x).abs > Simulation::INTERACTION_RANGE && (@y - @food.y).abs > Simulation::INTERACTION_RANGE
			angle = interception_angle(@food.x, @food.y)
			move_fuzzily_towards(angle)
		# If close enough to interact stop motion and start critter/food interaction/messaging
		else
			move_idle
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

	# Used for forming herds
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

	def keep_within_viewable
		if @x < 0 then @x += 15 end
		if @x > Simulation::SIMULATION_WIDTH then @x -= 15 end
		if @y < 0 then @y += 15 end
		if @y > Simulation::SIMULATION_HEIGHT then @y -= 15 end
	end

	#  Interception angle in radians
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
