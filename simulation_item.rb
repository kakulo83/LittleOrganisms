class SimulationItem
	attr_accessor :image_name, :angel, :x, :y, :width, :height, :visible

	def initialize(x, y, width, height, visible=true, image_name=nil)
		@image_name = image_name
		@angle = 0
		@x = x || 0
		@y = y || 0
		@width = width
		@height = height
		@visible = visible
	end	
end
