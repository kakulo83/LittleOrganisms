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

framework 'QuartzCore'

class ImageLayer < CALayer
	attr_reader :item
	attr_accessor :x, :y, :width, :height

	def initWithImageNamed(file_name)
		init
		backgroundColor = CGColorCreateGenericRGB(0,10,0,1)
		# The anchorPoint defines the anchor point of the layer's bounds rectangle
		# (0.5,0.5) => the center of the rectangle	
		anchorPoint = CGPointMake(0.5,0.5)	
		@image_name = file_name
		refresh	
		self
	end

	def initWithItem(item)
		init
		@item = item
		@image_name = item.image_name	
		refresh
		update
		self
	end

	def image_name
		# Ternary Operators ex.
		# puts x == 10 ? "x is ten" : "x is not ten" 

		# ternary operator reads:  if item is nil, then return @image_name
		# otherwise return the image bound to the item (item.image_name)	
		item ? item.image_name : @image_name	
	end

	def change_image(image_name=nil, width=nil, height=nil)
		# Not sure if needed		
	end

	def update
		item.update if item.respond_to?(:update)	
		@x = item.x
		@y = item.y
		@width = item.width
		@height = item.height
		angle = item.angle	
		self.bounds = CGRectMake(0,0,@width,@height)
		self.position = CGPointMake(@x,@y)
		self.transform = CATransform3DMakeRotation(angle, 0, 0, 1.0)
		#self.transform = CATransform3DMakeScale(item.scale,item.scale,item.scale)
		#CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(angle), CGAffineTransformMakeScale(item.scale, item.scale))
		#setAffineTransform(transform)
		context = NSGraphicsContext.currentContext		
	end

	def refresh
		setNeedsDisplay
	end

	def drawInContext(ctx)
		return unless image_name
		old_context = NSGraphicsContext.currentContext
		context = NSGraphicsContext.graphicsContextWithGraphicsPort(ctx, flipped:false)
		NSGraphicsContext.currentContext = context                                    
		image = NSImage.alloc.initWithContentsOfFile(@image_name)
		raise "Image missing, can't draw the item #{self}" if image == nil
		image.drawInRect(NSRectFromCGRect(bounds), fromRect: image.alignmentRect, operation: NSCompositeSourceOver, fraction: 1.0)
		NSGraphicsContext.currentContext = old_context              
	end

	def collide_width?(other_rect)
		NSIntersectsRect(rect_version, other_rect)
	end

	def rect_version                                                
		NSMakeRect( @x - 0.5 * @width, @y - 0.5 * @height, @width, @height )                                            
	end    
end
