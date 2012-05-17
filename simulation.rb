require 'simulation_data'

module Simulation
	include SimulationData 

	def start_simulation
		# Initialize simulation with critters
		init_simulation(1,8)	
		
		# Start simulation loop
		@timer = NSTimer.scheduledTimerWithTimeInterval SimulationData::TIME_INCREMENT, 
			target: self, 
			selector: 'refresh', 
			userInfo: nil, 
			repeats: true
	end

	def restart_simulation
		# Add code so simulation can be restarted whilst running
	end

	def init_simulation(num_critter, num_food)
		food0 = Food.new(645,730,35,35,5,300.0)
		food0.add_observer self	
		add_food_item(food0)

		food1 = Food.new(550,670,35,35,10,300.0)	
		food1.add_observer self	
		add_food_item(food1)

		num_food.times do
			food = Food.new(rand(SIMULATION_WIDTH),rand(SIMULATION_HEIGHT),35,35,rand(20),300.0)
			food.add_observer self
			add_food_item(food)
		end
		
		num_critter.times do
			critter = Critter.new(600,700,25,25,self)
			critter.add_observer self
			add_critter(critter)
		end
	end

	def refresh 
		# Update season (availability of and type of food)	
		# update_environment
		
		# Update all simulation	items
		all_layers.each { |layer| layer.update }
	end

	def update_environment
		# update the season	
	end

	# Listener for Critter and Food issued events
	def update(item,type)
		case item
		when Critter
			case type
			when :dead
				remove_critter item 
			when :born
				if all_critters.size < MAX_POPULATION then add_critter item end
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
				p "Simulation removing food"	
				remove_food item
			end
		end	
	end
end
