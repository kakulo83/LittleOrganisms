require 'simulation_data'

module Simulation
	include SimulationData 

	def start_simulation
		# Initialize simulation with critters
		init_number_critter(10)	
		
		# Start simulation loop
		@timer = NSTimer.scheduledTimerWithTimeInterval SimulationData::TIME_INCREMENT, 
			target: self, 
			selector: 'refresh', 
			userInfo: nil, 
			repeats: true
	end

	def init_number_critter(num)
		food0 = Food.new(456,378,50,50)	
		food1 = Food.new(324,876,50,50)	
		add_subLayer(food0)
		add_subLayer(food1)

		num.times do
			critter = Critter.new(rand(SIMULATION_WIDTH),rand(SIMULATION_HEIGHT),25,25)
			critter.add_observer self
			add_subLayer(critter)
		end
	end

	def refresh 
		all_layers.each { |layer| layer.update }
	end

	def add_subLayer(item)
		new_layer = ImageLayer.alloc.initWithItem(item)
		all_layers << new_layer
		@background_layer.addSublayer(new_layer)	
		new_layer
	end	
	
	def remove_subLayer(item=nil)
		# Remove any dead critters or depleted foods		
	end


	def update(critter,type)
		case type
		when :dead
			p "Critter has died"
		when :born
			p "Critter is born"
		when :ask_for_help
			p "Critter asks for help"
		else
			p "What the hell case is this?"
		end
	end
end



















