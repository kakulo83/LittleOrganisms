framework 'Cocoa'
require 'critter'
require 'food'
require 'simulation'
require 'simulation_data'
require 'image_layer'

class Application 

	include Simulation
	include SimulationData

	attr_reader :sim, :window, :frame, :gui, :data

	def applicationDidFinishLaunching(notification)
		start_simulation	
	end

	def initialize
		# Create Application	
		@sim = NSApplication.sharedApplication
		@sim.activationPolicy = NSApplicationActivationPolicyRegular
		@sim.activateIgnoringOtherApps(true)	
		@sim.delegate = self

		# Create Window
		@frame  = [0.0, 0.0, SIMULATION_WIDTH, SIMULATION_HEIGHT]	
		@window = NSWindow.alloc.initWithContentRect(frame,	
					styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask, 
					backing:NSBackingStoreBuffered, 
					defer:false)
		@window.delegate = self
		@window.title = "Unintelligent Design"
		@window.contentView.wantsLayer = true

		# Create Background Layer
		@background_layer = ImageLayer.alloc.initWithImageNamed("graphics/background.jpeg")		
		@background_layer.masksToBounds = true
		@background_layer.position = CGPointMake(SIMULATION_WIDTH/2, SIMULATION_HEIGHT/2)
		@background_layer.bounds = CGRectMake(0,0,SIMULATION_WIDTH, SIMULATION_HEIGHT)

		# Create View 
		@gui = NSView.alloc.initWithFrame(@frame)
		@gui.wantsLayer = true 
		@gui.layer.insertSublayer(@background_layer, atIndex: 0)

		# Connect Objects
		@window.contentView.addSubview(@gui)
		@window.center
		@window.display
		@window.makeKeyAndOrderFront(nil)
		@window.orderFrontRegardless
		@sim.run
	end
end

sim = Application.new
