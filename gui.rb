framework 'Cocoa'
require 'graphics'

class GUI < NSView
	include MRGraphics

	def initWithFrame(rect, parent)
		super(rect)
		@parent = parent
		self
	end

	attr_accessor :data

	def drawRect(rect)
		dimensions = [CGRectGetWidth(rect), CGRectGetHeight(rect)]
		Canvas.for_current_context(:size => dimensions) do |c|
			NSColor.blueColor.set	
			NSBezierPath.fillRect(rect)
		end
	end

end
