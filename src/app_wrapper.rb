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
require 'simulation_constants'
require 'simulation'
require 'image_layer'

class AppWrapper
	
	include SimulationConstants

	def applicationDidFinishLaunching(notification)
		# Create Simulation Object	
		@sim = Simulation.new(@simulation_layer)	
	
		# Finish binding button/window events to simulation event handlers
		@start_stop_btn.setAction('start_stop_btn_handler:')
		@start_stop_btn.setTarget(@sim)

		@history_data_btn.setAction('history_data_btn_handler:')
		@history_data_btn.setTarget(@sim)

		@instance_data_btn.setAction('instance_data_btn_handler:')
		@instance_data_btn.setTarget(@sim)	

		@window.setNextResponder(@sim)
		
		# Start simulation
		@sim.start_simulation	
	end

	def windowWillClose(notification)
		p "Exiting Simulation"
	end

	def initialize
		
		# Create NSApplication instance
		@app = NSApplication.sharedApplication
		@app.activationPolicy = NSApplicationActivationPolicyRegular
		@app.activateIgnoringOtherApps(true)	
		@app.delegate = self
	
		# Create Main Application Window
		@frame  = [0, 0, SIMULATION_WIDTH, SIMULATION_HEIGHT]	
		@window = NSWindow.alloc.initWithContentRect(@frame,	
					styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSTexturedBackgroundWindowMask, 
					backing:NSBackingStoreBuffered, 
					defer:false)
		@window.title = "Unintelligent Design"
		@window.contentView.wantsLayer = true

		# Create Simulation Background Layer
		@simulation_layer = ImageLayer.alloc.initWithImageNamed("../images/background.jpeg")		
		@simulation_layer.masksToBounds = true
		@simulation_layer.position = CGPointMake(SIMULATION_WIDTH/2, SIMULATION_HEIGHT/2)
		@simulation_layer.bounds = CGRectMake(0,0,SIMULATION_WIDTH, SIMULATION_HEIGHT)

		# Create Simulation View 
		@simulation_view = NSView.alloc.initWithFrame(@frame)
		@simulation_view.wantsLayer = true 
		@simulation_view.layer.insertSublayer(@simulation_layer, atIndex: 0)

		# Add Button to open simulation history data graphs 
		@history_data_btn = NSButton.alloc.initWithFrame([0,0,50,50])
		@history_data_btn.bezelStyle = 4
		history_btn_image =	NSImage.alloc.initWithContentsOfFile('../images/history.png')
		@history_data_btn.setImage(history_btn_image)
		
		# Add Button to open current simulation instance data graphs 
		@instance_data_btn = NSButton.alloc.initWithFrame([50,0,50,50])
		@instance_data_btn.bezelStyle = 4
		instance_btn_image = NSImage.alloc.initWithContentsOfFile('../images/instance.png')
		@instance_data_btn.setImage(instance_btn_image)

		# Add Button to start/stop simulation 
		@start_stop_btn = NSButton.alloc.initWithFrame([100,0,50,50])
		@start_stop_btn.bezelStyle = 4
		start_stop_image = NSImage.alloc.initWithContentsOfFile('../images/start_stop.png')
		@start_stop_btn.setImage(start_stop_image)

		# Create Data View
		@data_view = NSView.alloc.initWithFrame([0,0,200,52])
		@data_view.addSubview(@start_stop_btn)	
		@data_view.addSubview(@history_data_btn)
		@data_view.addSubview(@instance_data_btn)

		# Create Side-Drawer for graph/data interface
		@data_drawer = NSDrawer.alloc.initWithContentSize(NSMakeSize(0,52),preferredEdge:NSMinYEdge) 
		@data_drawer.setParentWindow(@window)
		@data_drawer.setTrailingOffset(SIMULATION_WIDTH - 240)	
		@data_drawer.setMaxContentSize(NSMakeSize(0,52))
		@data_drawer.setContentView(@data_view)
		#@data_drawer.contentView.setNextResponder self 
		@data_drawer.openOnEdge(NSMinYEdge)
		
		# Connect objects
		@window.contentView.addSubview(@simulation_view)
		@window.center
		@window.display
		@window.makeKeyAndOrderFront(nil)
		@window.orderFrontRegardless
	end

	def run
		@app.run
	end
end

app = AppWrapper.new
app.run 
