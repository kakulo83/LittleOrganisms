framework 'Cocoa'

class GraphDrawer < NSDrawer

	def acceptFirstResponder
		true
	end

	def mouseDown(event)
		p "Mouse clicked on drawer"
	end

	def mouseUp(event)
		p "Mouse up on drawer"
	end

	def mouseEntered(event)
		p "Entered Drawer"
	end

end
