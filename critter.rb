require 'simulation_item'
require 'simulation_data'
require 'observer'

class Critter < SimulationItem
	include Observable
	include SimulationData

	attr_reader :x, :y, :width, :height, :angle, :energy, :traits, :priorities

	def initialize(x, y, width, height, parent=nil)
		super
		@x = x
		@y = y
		@width = width
		@height = height	
		@image_name = "graphics/critter.png"
		@traits = {}	
		@is_alive = true
		@priorities = [:eat,:find_food,:reproduce,:idle,:charity]
		@purpose = :idle
		if parent
			inherit_parent_traits(parent)
		else
			standard_traits
		end

		@energy = @traits[:energy_capacity]
	end

	def standard_traits 
		@traits[:energy_capacity] = 300			# The total amount of energy, not including fat, a critter can store
		@traits[:energy_consumption_rate] = 1	# Rate of normal metabolic energy consumption
		@traits[:fat] = 20						# Energy stored in excess of normal storage
		@traits[:biological_clock] = 100 		# Minimum time between reproduction
		@traits[:hunger_point] = 150			# Threshold where critter becomes hungry for food energy
		@traits[:starvation_point] = 100		# Energy level where the need to consume food overrides all other purposes 
	    @traits[:smell_range] = 200 			# Maximum smell detection distance
		@traits[:smell_cost] = 2				# Energy cost to use smell ability
#		@traits[:cooperation] = 0
#		@traits[:aggressiveness] = 0
#		@traits[:risk] = 0
#		@traits[:prejudice] = 0
#		@traits[:similarity] = 0
#		@traits[:charity] = 0
#		@traits[:parenting] = 0
#		@traits[:lifespan] = 0		
		express_traits
		end

	def inherit_parent_traits(parent)
# 		Mutate traits from parents 
# =>	@energy = parent.traits[:parenting]
		express_traits	
	end

	def trait_to_trait_relationships
# =>	Increasing the smell_range should incur an energy cost
# =>	Modifying one trait should have an effect on other traits.
	end

	def update
		update_internal_state
		update_purpose
		move
		interact
	end

	private

	def express_traits
		# 'Express' the 'genes' through instance variables, so they can be easily used for logic/computation etc.
		@traits.keys.each do |trait|	
			self.instance_variable_set("@#{trait}", @traits[trait])
		end
	end

	def update_purpose
		# 		Basic Decision Making Framework
		#
		#
		#  		:eat :find_food :reproduce :idle :charity
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

		if is_starving?  
			@purpose = :find_food
		end 

		if is_hungry?
		
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

	def move
		@x += rand(20) - 10 
		@y += rand(20) - 10 
		@angle += (rand(90)*Math::PI/180)- (45*Math::PI/180)
#  		Add logic to determine movement type
#
#		move_idle	
#		move_orbit	
#		move_towards
# 		move_search
	end

	# Use of smell incurs energy cost
	# smell returns all food_items within detection range 
	def smell 
		@energy -= (@smell_range * @smell_cost/100.0).ceil

		food_in_range = []
		unless @all_food_items.size == 0
			@all_food_items.each do |food|
				if ((@x - food.x).abs < @smell_range) && ((@y - food.y).abs < @smell_range)
					food_in_range << food
				end
			end	
		end
		food_in_range
	end

	def interact

	end

	def consume

	end

	def reproduce
#		Create a new critter
#		offspring = Critter.new(@x,@y,@width,@height,self)
#		changed
#		notify_observers offspring, :born
#		@biological_clock = 100
	end

	def ask_for_energy

	end

	def give_energy

	end

	def receive_energy

	end

	def is_hungry?
		if @energy <= @hunger_point then true else false end 
	end

	def is_starving?
		if @energy <= @starvation_point then true else false end	
	end

	def is_reproduce?
		
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
