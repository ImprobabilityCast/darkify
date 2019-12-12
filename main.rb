class CSSTheme
	def darkify(text)
		text_arr = []
		i = 0
		while i < text.bytesize
			prev_i = i
			i = text.index('{', i)
			text_arr.push(text[prev_i..i])
			i += 1

			# if @media, @keyframes, and others
			if text[i] != '@'
				# now we should be inside the block of rules
				while i < text.bytesize && text[i] != '}'
					# get property
					prop_end = text.index(':', i)
					text_arr.push(text[i..prop_end])
					prop = text[i..(prop_end - 1)]
					prop_end += 1

					# get value
					val_end = text.index(';', prop_end)
					val_end2 = text.index('}', val_end)
					val = if val_end == nil || val_end2 < val_end
						text[prop_end..(val_end2 - 1)]
					else
						text[prop_end..(val_end - 1)]
					end

					# if possible, change color
					i = prop_end + val.length
					if @@color_props.has_key(prop)
						text_arr.push(@@color_props[prop].call(val))
					else
						text_arr.push(val)
					end
					text_arr.push(text[i])
				end
			end
		end
		text_arr.join
	end

	# Things that can have color:
	# https://developer.mozilla.org/en-US/docs/Web/HTML/Applying_color#Things_that_can_have_color
	@@color_props = {
		"color" => Proc.new,
		"background" => Proc.new,
		"background-color" => Proc.new,
		"border" => Proc.new,
		"border-color" => Proc.new,
		"border-left" => Proc.new,
		"border-top" => Proc.new,
		"border-right" => Proc.new,
		"border-bottom" => Proc.new,
		"border-left-color" => Proc.new,
		"border-top-color" => Proc.new,
		"border-right-color" => Proc.new,
		"border-bottom-color" => Proc.new,
		"text-shadow" => Proc.new,
		"text-decoration" => Proc.new,
		"text-decoration-color" => Proc.new,
		"text-emphasis" => Proc.new,
		"text-emphasis-color" => Proc.new,
		"caret-color" => Proc.new,
		"column-rule" => Proc.new,
		"column-rule-color" => Proc.new,
		"outline" => Proc.new,
		"outline-color" => Proc.new,
	}.freeze
end

if __FILE__ == $0

end
