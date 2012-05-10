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
		@step_size = 20 		
		@traits = {}	
		@is_alive = true
		@is_hungry = false	
		@priorities = [:consume_food, :search_for_food, :reproduce, :idle, :give_help]
		@purpose = :idle
		
		if parent
			inherit_parent_traits(parent)
		else
			standard_traits
		end

		@energy = @traits[:energy_capacity]
	end

	def standard_traits 
		@traits[:energy_capacity] = 350			# The total amount of energy, not including fat, a critter can store
		@traits[:energy_consumption_rate] = 1	# Rate of normal metabolic energy consumption
		@traits[:fat] = 20						# Energy stored in excess of normal storage
		@traits[:biological_clock] = 100 		# Minimum time between reproduction cycles
		@traits[:hunger_point] = 340			# Threshold where critter becomes hungry for food energy
		@traits[:starvation_point] = 100		# Energy level where the need to consume food overrides all other purposes 
	    @traits[:smell_range] = 200 			# Maximum detection range for smell 
		@traits[:smell_cost] = 2				# Energy cost to use smell ability
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

	def inherit_parent_traits(parent)
# 		Mutate traits from parents 
# =>	@energy = parent.traits[:nurturing]
		express_traits	
	end

	def trait_to_trait_relationships
# =>	Increasing the smell_range should incur an energy cost
# =>	Modifying one trait should have an effect on other traits.
	end

	def update
		update_internal_state
		update_purpose
		execute_purpose
	end

	def express_traits
		# 'Express' the 'genes' through instance variables, so they can be easily used for logic/computation etc.
		@traits.keys.each do |trait|	
			self.instance_variable_set("@#{trait}", @traits[trait])
		end
	end

#===================================================== Internal Behavior ================================================

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

	#		if is_starving?  
	#			@purpose = :search_for_food
	#		end 

	#		if is_hungry?
	#		
	#		end

		if is_hungry?
			@purpose = :search_for_food
		end
	end

	def update_internal_state 
		if is_alive?
			# decrease energy	
			@energy -= @energy_consumption_rate	
			# decrement reproduction counter	
			if @biological_clock > 0 then @biological_clock -= 1 end	
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
		# Add code to effectuate idling behavior:  arbitrary motion
		move_idle	
	end

	def search_for_food
		# Add code to effectuate movement and smelling that together are food searching behavior
		# Smell at current location, if food is detected move towards it
		# If no food is detected, initiate the search motion pattern whilst smelling for potential food
		# If after travelling n steps no food is detected, change course arbitrarily +/- 90 degrees to a new course

		# Randomly pick a target location and perform a smell sensor sweep along that path.
		# If after n number of cycles no food is detected, randomly move in a new direction that is perpendicular to the current
		# one and continue sensor sweep; just don't forget the beeps and the creeps and most importantly... don't get jammed!

		food = smell
		if food.size == 0
			move_searching
		else
			# With one or more food items available, the critter must decide if it should engage one or indeed any food items at all. 
			# Distance to food, activation energy, the critter's current store of energy all together ultimately define the probability
			# of the critter's success in engaging a particular food item. 
			# 
			# if decide == YES
			#     move_towards_fuzzily
			#
			# if decide == NO
			# 	  continue search for better prospects
			#
		end
	end

	def consume_food

	end

	def reproduce
#		Create a new critter
#		offspring = Critter.new(@x,@y,@width,@height,self)
#		changed
#		notify_observers offspring, :born
#		@biological_clock = 100
	end

	def ask_for_help

	end

	def receive_help

	end

	def give_help

	end

# ================================================== Motion & Detection ==========================================

	def move_idle
		@x += rand(@step_size) - 10 
		@y += rand(@step_size) - 10 
		# Keep critters within view
		keep_within_viewable	
		
		@angle += (rand(90)*Math::PI/180) - (45*Math::PI/180)
	end

	def move_towards_fuzzily(x,y)
		# Decrease the x distance from critter to target 
		delta_x = rand(@step_size/2)
		delta_y = rand(@step_size/2)
		if (x > @x) then @x += delta_x else @x -= delta_x end
		if (y > @y) then @y += delta_y else @y -= delta_y end
		# Determine critter's layer angle such that it looks like it's oriented toward the target 
		@angle = interception_angle(x,y)
	end

	def move_away_fuzzily(x,y)
		delta_x = rand(@step_size/2)
		delta_y = rand(@step_size/2)
		if (x > @x) then @x -= delta_x else @x += delta_x end
		if (y > @y) then @y -= delta_y else @y += delta_y end
		# Add PI to orient 180 degrees away from target
		@angle = interception_angle(x,y) + Math::PI
	end

	def keep_within_viewable
		# Keep critters within view
		if @x < 0 then @x += 15 end
		if @x > Simulation::SIMULATION_WIDTH then @x -= 15 end
		if @y < 0 then @y += 15 end
		if @y > Simulation::SIMULATION_HEIGHT then @y -= 15 end
	end

	def interception_angle(x,y)
		 #    
		#	  y
		#	  ^	    _____
		#	  |    (_____:)   (critter is oriented to the right with angle = 0 radians
		#	  |
		#	  |
		#	 (0,0) ----> x
		
		#  Interception angle in radians
		angle = 0
		if @x > x
			if @y > y
				angle = Math.atan((y-@y)/(x-@x)) + Math::PI 
			else
			 	angle = Math::PI - Math.atan((y-@y)/-(x-@x))
			end
		else 
			if @y > y 
				angle = Math.atan((y-@y)/(x-@x))	
			else
				angle = Math.atan((y-@y)/(x-@x))
			end	
		end
		angle
	end

	# Use of smell incurs energy cost.  Smell returns array of all food_items within range of detection
	def smell
		@energy -= (@smell_range * @smell_cost/100.0).ceil

		food_in_range = []

		unless @simulation.all_food_items.size == 0
			@simulation.all_food_items.each do |food|
				if ((@x - food.x).abs < @smell_range) && ((@y - food.y).abs < @smell_range)
					food_in_range << food
				end
			end	
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
		if @energy <= 0 && @is_alive
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
