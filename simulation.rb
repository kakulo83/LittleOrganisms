framework 'Cocoa'
require 'critter'
require 'environment'
require 'food'
require 'gui'
require 'json'
require 'simulation_data'


class Simulation

	include SimulationData

	attr_reader :sim, :window, :frame, :gui, :data

	def applicationDidFinishLaunching(notification)
		#start
	end
	
	def initialize
		# Create Simulation Objects
		@grid = Array.new(SIMULATION_WIDTH)
		@grid.map! { Array.new(SIMULATION_HEIGHT) } 
		@critter = Critter.new(@grid)	

		# Create Application	
		@sim = NSApplication.sharedApplication
		@sim.activationPolicy = NSApplicationActivationPolicyRegular
		@sim.activateIgnoringOtherApps(true)	
		@sim.delegate = self

		# Create Window
		@frame  = [0.0, 0.0, SIMULATION_WIDTH, SIMULATION_HEIGHT]	
		@window = NSWindow.alloc.initWithContentRect(frame,	styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask, backing:NSBackingStoreBuffered, defer:false)
		@window.delegate = self
		@window.title = "Unintelligent Design"

		# Create GUI
		@gui = GUI.alloc.initWithFrame(@frame,self)
		@window.contentView = @gui

		@window.center
		@window.display
		@window.makeKeyAndOrderFront(nil)
		@window.orderFrontRegardless
		@sim.run
	end

	def start
		@timer = NSTimer.scheduledTimerWithTimeInterval SimulationData::TIME_INCREMENT, 
			target: self, 
			selector: 'update', 
			userInfo: nil, 
			repeats: true
	end

	def update 
		@critter.update
		# critters.update
		# food.update
		# environment.update 
		# mechanisms.update
	end
end

sim = Simulation.new
