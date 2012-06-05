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

require 'src/simulation_constants'
require 'src/gui/graph'

class DataGUI

	include SimulationConstants

	def initialize(sim)
		@sim = sim
		@all_item_windows = []
	end

	def update
		# Add code to update each of the windows managed by DataGui
	end

	def new_item_data_window_for(selected_item)
		unless window_already_exists? selected_item			
			# Create ComboxBox
			item_combo_box = NSComboBox.alloc.initWithFrame([0, 0 ,DATA_WIDTH / 2, 25])

			# Create Scroller
			item_scroller = NSScroller.alloc.initWithFrame([0, 0, 25, DATA_HEIGHT])
			item_scroller.setEnabled(true)  # New Scrollers are disabled by default.. who knew
			item_scroller.setKnobProportion(0.5)

			# Create Scrollable View Container (will hold all the graphs)
			item_scroll_container_view = NSView.alloc.initWithFrame([0, 0, DATA_WIDTH, 2*DATA_HEIGHT])
			item_scroll_container_view.addSubview(Graph.alloc.initWithFrame([0,   0, 316, 210]))
			item_scroll_container_view.addSubview(Graph.alloc.initWithFrame([0, 220, 316, 210]))
			item_scroll_container_view.addSubview(Graph.alloc.initWithFrame([0, 440, 316, 210]))

			# Create Scrollable View
			item_scroll_view = NSScrollView.alloc.initWithFrame([0, 25, DATA_WIDTH, DATA_HEIGHT - 25])
			item_scroll_view.setVerticalScroller(item_scroller)
			item_scroll_view.setHasVerticalScroller(true)
			item_scroll_view.setBackgroundColor(NSColor.colorWithDeviceRed(0.0, green:149.0, blue:186.0, alpha:0.6))
			item_scroll_view.setAutoresizingMask(NSViewWidthSizable|NSViewHeightSizable)	
			item_scroll_view.setDocumentView(item_scroll_container_view)

			# Create Window Container View (contains both scrollable view and combo box)
			item_container_view = NSView.alloc.initWithFrame([0, 0, DATA_WIDTH, DATA_HEIGHT])		
			item_container_view.addSubview(item_scroll_view)
			item_container_view.addSubview(item_combo_box)

			# Create Window	
			win_frame = [100, 500, DATA_WIDTH, DATA_HEIGHT]		
			item_window = NSWindow.alloc.initWithContentRect(win_frame,
					styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
					backing:NSBackingStoreBuffered,
					defer:false)
			item_window.title = "Data for critter"
			item_window.setContentView(item_container_view)
			item_window.display
			item_window.makeKeyAndOrderFront(nil)
			item_window.orderFrontRegardless
			# Set DataGUI as the responder for item_window mouse/keyboard events
			#item_window.setNextResponder(self)
			# Add newly created window to DataGUI's array of all windows
			new_window = {:item => selected_item, :window => item_window, :scroll_container => item_scroll_container_view }
			@all_item_windows << new_window
		end
	end

	def new_instance_data_window
		
	end

	def new_history_data_window

	end

	def window_already_exists? selected_item
		if @all_item_windows.empty? then return false end
		exists = false
		@all_item_windows.detect {|window| if window[:item].equal? selected_item then exists = true end } 
		exists
	end

	def add_new_graph(target,*data)

	end

	def mouseUp(event)
		p "Clicked on Window number: " + event.window.to_s
		# Ascertain the identity of the parent/owner of the event and respond accordingly
	end

	def mouseDown(event)
	end

	def mouseDragged(event)
	end

	def flagsChanged(event)
	end

	def keyUp(event)
	end

	def keyDown(event)
	end

	def scrollWheel(event)
	end

end
#- (id)initWithFrame:(NSRect)frame {
#	[super initWithFrame:frame];
#	center.x = 50.0;
#	center.y = 50.0;
#	radius = 10.0;
#	color = [[NSColor redColor] retain];
#	frame.origin.x = frame.origin.y = 0;
#	frame.size.height = [NSScroller scrollerWidth];
#	scroller = [[NSScroller alloc] initWithFrame:frame];
#	[self addSubview:scroller];
#	[scroller setTarget:self];
#	[scroller setAction:@selector(doSomething:)];
#	[scroller setFloatValue:.50 knobProportion:.25];
#	return self;
#}
#
#- (void)doSomething:(id)sender {
#	NSNumber *num = [NSNumber numberWithDouble:[scroller floatValue]];
#	NSLog([num stringValue]);
#}
