require 'simulation_item'
require 'simulation_data'
require 'observer'

class Critter < SimulationItem
	include Observable
	include SimulationData

	attr_reader :x, :y, :width, :height, :angle, :energy, :traits

	def initialize(x, y, width, height, parent=nil)
		super
		# Standard traits, override if inheriting from parent	
		@x = x
		@y = y
		@width = width
		@height = height	
		@traits = {}	

		# Initialize standard traits	
		standard_traits
	
		# Inherit stuff from parents 
		unless parent.nil?	
			inherit_parent_traits(parent)
		end	
	end

	def standard_traits 
		@image_name = "graphics/critter.png"
		@energy = 500 
		@traits[:total_energy] = 500
		@traits[:fat] = 20
		@isAlive = true
#		@traits[:cooperation] = 0
#		@traits[:aggressiveness] = 0
#		@traits[:risk] = 0
#		@traits[:prejudice] = 0
#		@traits[:dissimilarity] = 0
#		@traits[:generosity] = 0
#		@traits[:parenting] = 0
	end

	def inherit_parent_traits(parent)
		@traits = parent.traits	
		@traits["total_energy"] += 500	
	end

	def update
# 		update_purpose
		metabolism
		move
	end

	private

	def update_purpose
#		idle 
#		search for food
#		consuming food
#		reproducing
#		giving assistance 
#		asking for assistance
	end

	def metabolism
		@energy -= 5	
		if @energy <= 0 && @isAlive
			@energy = 0
			changed
			notify_observers self,:dead
			@isAlive = false
		end
	end

	def move
		@x += rand(20) - 10 
		@y += rand(20) - 10 
		@angle += (rand(40) - 20) * Math::PI / 180
#  		Add logic to determine movement type

#		fuzzy orbiting
#		fuzzy movement towards..
#		fuzzy search/find
	end

	def move_idle
		@energy -= 0.5 
	end

	def move_orbit
		@energy -= 1.5	
	end

	def move_towards
		@energy -= 2	
	end

	def move_search

	end

	def search_for_food 
		
	end

	def consume

	end

	def reproduce

	end

	def ask_for_energy

	end

	def give_energy

	end

	def receive_energy

	end
end
