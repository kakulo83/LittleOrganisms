#    Life-Simulation
#
#	 Copyright (c) 2012 Robert Carter 
#	 
#	 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
#	 to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
#	 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#	 
#	 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#	 
#	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#	 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#	 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
#	 IN THE SOFTWARE.

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
