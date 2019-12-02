class CSSParser

	@@flag = "\0"

	def to_dark(hexColor)
	
	end

	def parse_color(color)
		# if rgb(a)
		# if hsl(a)
		# if hex
		# if color
	end
	
	def parse_border(text)
	
	end
	
	def parse_box_shadow(text)
	
	end
	
	def find_color(text)

	end
	
	def parse_bglock(text)
	
	end
	
	def is_whitespace(c)
		c == " " || c == "\t" || c == "\n" || c == "\r" || c == "\f"
	end
	
	def zero_spaces_until(text, pos, condition_callback)
		until pos >= text.bytesize || condition_callback.call(text[pos])
			if is_whitespace(text[pos])
				text[pos] = @@flag
			end
			pos += 1
		end
		pos
	end
	
	def zero_prefix_spaces(text, pos)
		while pos < text.bytesize && is_whitespace(text[pos])
			text[pos] = @@flag
			pos += 1
		end
		pos
	end
	
	def trim_spaces_until(text, pos, condition_callback)
		w_count = 0
		until pos >= text.bytesize || condition_callback.call(text[pos])
			if is_whitespace(text[pos])
				w_count += 1
				if w_count > 1
					text[pos] = @@flag
				end
			else
				w_count = 0
			end
			pos += 1
		end

		# don't keep last space
		if w_count > 0
			text[pos - w_count] = @@flag 
		end
		pos
	end

	def trim_spaces_until_with_comma(text, pos, condition_callback)
		test_ch = text[pos]
		while pos < text.bytesize && condition_callback.call(test_ch)
			pos = trim_spaces_until(text, pos,
					lambda { |c| c == ',' || condition_callback.call(c)})
			test_ch = text[pos]
			pos += 1
			pos = zero_prefix_spaces(text, pos)
		end
		pos
	end

	def shift(text)
		left_pos = 0
		right_pos = 0
		while right_pos < text.bytesize
			while text[right_pos] == @@flag 
				right_pos += 1
			end
			text[left_pos] = text[right_pos]
			left_pos += 1
			right_pos += 1
		end
		text.slice!(left_pos, right_pos)
		nil
	end
	
	def strip_whitespace(text)
		i = 0
		while i < text.bytesize
			if text[i] == '@'
				i = trim_spaces_until_with_comma(text, i, lambda { |c| c == '{'})
				i += 1
			else
				i = zero_prefix_spaces(text, i)
				# now we should be at a selector, so keep 1st whitespace
				i = trim_spaces_until_with_comma(text, i, lambda { |c| c == '{'})
				
				# now we should be inside the block of rules
				while i < text.bytesize && text[i] != '}'
					i = zero_spaces_until(text, i, lambda { |c| c == ':'})
					# space before value
					i = zero_prefix_spaces(text, i + 1)
					# need the '}' since last ';' is not required
					# keep spaces between value thingies for shorthand setters
					i = trim_spaces_until_with_comma(text, i, lambda { |c| c == ';' || c == '}'})
				end
				i = zero_prefix_spaces(text, i + 1)
			end
		end
		shift(text)
	end

	def strip_comments(text)
		i = text.index("/*", 0)
		while i != nil
			j = text.index("*/", i)
			if j == nil
				j = text.bytesize
			else
				j += 1
			end
			text.slice!(i..j);
			i = text.index("/*", i)
		end
		nil
	end

	def minify(text)
		strip_comments(text)
		strip_whitespace(text)
		nil
	end

	def parse(text)
		i = 0
		while i < text.bytesize
			# if @media, @keyframes, and others
			if text[i] == '@'
				i = text.index('{', i) + 1
			else
				i = text.index('{', i) + 1
				# now we should be inside the block of rules
				while i < text.bytesize && text[i] != '}'
					i = text.index(':', i)
					val_end = text.index(';', i)
					val_end2 = text.index('}', i)
					if val_end < val_end2
						
					else
					
					end
				end
				# parse looking for colored things
				# keys (contains word color) or background, box-shadow, border
				# call color switcher
				# note that @media things can have nested
				# brackets
				# return to top when } found
			end
		end
		nil
	end
	
end

if __FILE__ == $0
	# test whitespace stripper
	# TODO - make this test more & be more automated
	text = IO.read("super.css")
	print(text)
	CSSParser.new.minify(text)
	print(text)
end
