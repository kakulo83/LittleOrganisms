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

# Add life-simulation root dir to the path of the MacRuby interpreter for easier file referencing etc.
$LOAD_PATH.unshift(File.dirname(File.expand_path(File.dirname(__FILE__))))

require 'src/gui/simulation_gui'
require 'src/gui/image_layer'
require 'simulation_constants'
require 'simulation'

class AppWrapper
	
	include SimulationConstants

	def initialize
		# Create NSApplication instance
		@app = NSApplication.sharedApplication
		@app.activationPolicy = NSApplicationActivationPolicyRegular
		@app.activateIgnoringOtherApps(true)	
		@app.delegate = self
		
		# Create Simulation Object	
		@sim = Simulation.new

		# Create Main Application Window
		@window = SimulationGUI.new(@sim)

		# Give the simulation object a copy of the main layer in the simulation used for drawing etc.
		@sim.simulation_background_layer = @window.simulation_background_layer
	end

	def applicationDidFinishLaunching(notification)
		# Start simulation
		@sim.start_simulation	
	end

	def run
		@app.run
	end
end

app = AppWrapper.new
app.run 
