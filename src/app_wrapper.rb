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

	attr_reader :sim, :window, :frame, :gui, :data

	def applicationDidFinishLaunching(notification)
		@sim = Simulation.new(@simulation_layer)	
		@sim.start_simulation	
	end

	def windowWillClose(notification)
		p "Exiting Simulation"
	end

	def acceptsFirstResponder
		true
	end

	def initialize
		# Create NSApplication instance
		@app = NSApplication.sharedApplication
		@app.activationPolicy = NSApplicationActivationPolicyRegular
		@app.activateIgnoringOtherApps(true)	
		@app.delegate = self
	
		# Create Main Application Window
		@frame  = [0, 0, SIMULATION_WIDTH, SIMULATION_HEIGHT]	
		@window = NSWindow.alloc.initWithContentRect(frame,	
					styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSTexturedBackgroundWindowMask, 
					backing:NSBackingStoreBuffered, 
					defer:false)
		@window.title = "Unintelligent Design"
		@window.contentView.wantsLayer = true

		# Create Simulation Background Layer
		@simulation_layer = ImageLayer.alloc.initWithImageNamed("../graphics/background.jpeg")		
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
		@history_data_btn.target = self
		@history_data_btn.action = 'history_data_btn_handler:'	
		history_btn_image =	NSImage.alloc.initWithContentsOfFile('../graphics/history.png')
		@history_data_btn.setImage(history_btn_image)
		
		# Add Button to open current simulation instance data graphs 
		@instance_data_btn = NSButton.alloc.initWithFrame([50,0,50,50])
		@instance_data_btn.bezelStyle = 4
		@instance_data_btn.target = self
		@instance_data_btn.action = 'instance_data_btn_handler:'
		instance_btn_image = NSImage.alloc.initWithContentsOfFile('../graphics/instance.png')
		@instance_data_btn.setImage(instance_btn_image)
	
		# Create Data View
		@data_view = NSView.alloc.initWithFrame([0,0,200,52])
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
		
		# Connect Objects
		@window.contentView.addSubview(@simulation_view)
		@window.setNextResponder(self)
		@window.center
		@window.display
		@window.makeKeyAndOrderFront(nil)
		@window.orderFrontRegardless
	end

	def run
		@app.run
	end

	def mouseUp(event)
		p event.locationInWindow.x.to_s + " " + event.locationInWindow.y.to_s
		p "Showing all information about critter"
	end

	def mouseDown(event)
	end

	def mouseDragged(event)
	end

	def flagsChanged(event)
		# Raised when keys like "control" "shift" are pressed
	end

	def keyUp(event)
		# Raised when keyboard key is released 
	end

	def keyDown(event)
		# Raised when keyboard key is pressed down
	end

	def history_data_btn_handler(sender)
		#pause_simulation
		p "Showing all simulation history data"		
	end

	def instance_data_btn_handler(sender)
		#continue_simulation
		p "Showing simulation instance data"
	end

end

app = AppWrapper.new
app.run 
