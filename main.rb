class CSSParser

	def toDark(hexColor)
	
	end

	def parseColor(color)
		# if rgb(a)
		# if hsl(a)
		# if hex
	end
	
	def parseBorder(text)
	
	end
	
	def parseBoxShadow(text)
	
	end
	
	def findColor(text)

	end

	def parse(text)
		# look for {
		# parse looking for colored things
		# keys (contains word color) or background, box-shadow, border
		# call color switcher
		# note that @media things can have nested
		# brackets
		# return to top when } found
	end


end

if __FILE__ == $0
	# main thingy aqui
