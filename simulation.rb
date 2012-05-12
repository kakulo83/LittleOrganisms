require 'simulation_data'

module Simulation
	include SimulationData 

	def start_simulation
		# Initialize simulation with critters
		init_simulation(1)	
		
		# Start simulation loop
		@timer = NSTimer.scheduledTimerWithTimeInterval SimulationData::TIME_INCREMENT, 
			target: self, 
			selector: 'refresh', 
			userInfo: nil, 
			repeats: true
	end

	def init_simulation(num)
		food0 = Food.new(456,378,35,35)
		food1 = Food.new(324,876,35,35,false)
		food2 = Food.new(678,400,35,35)

		add_food_item(food0)
		add_food_item(food1)
		add_food_item(food2)	

		num.times do
			critter = Critter.new(600,700,25,25,self)
			critter.add_observer self
			add_critter(critter)
		end
	end

	def refresh 
		all_layers.each { |layer| layer.update }
	end

	# Listener for Critter issued events
	def update(critter,type)
		case type
		when :dead
			remove_critter critter
		when :born
			if all_critters < MAX_POPULATION then add_critter critter end
		when :ask_for_help
			p "Critter asks for help"
		when :eating
			p "Critter is eating"
		else
			p "What the hell case is this?"
		end
	end
end
