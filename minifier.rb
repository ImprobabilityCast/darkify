class Minifier

	def self.strip_whitespace!(text)
		i = 0
		while i < text.bytesize
			if text[i] == '@'
				i = trim_spaces_until_with_comma!(text, i, lambda { |c| c == '{'})
				i += 1
			else
				i = zero_prefix_spaces!(text, i)
				# now we should be at a selector, so keep 1st whitespace
				i = trim_spaces_until_with_comma!(text, i, lambda { |c| c == '{'})
				
				# now we should be inside the block of rules
				while i < text.bytesize && text[i] != '}'
					i = zero_spaces_until!(text, i, lambda { |c| c == ':'})
					# space before value
					i = zero_prefix_spaces!(text, i + 1)
					# need the '}' since last ';' is not required
					# keep spaces between value thingies for shorthand setters
					i = trim_spaces_until_with_comma!(text, i, lambda { |c| c == ';' || c == '}'})
				end
				i = zero_prefix_spaces!(text, i + 1)
			end
		end
		shift!(text)
		nil
	end

	def self.strip_comments!(text)
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

	def self.minify!(text)
		strip_comments!(text)
		strip_whitespace!(text)
		nil
    end
    
    @@flag = "\0".freeze

    private_class_method :new # prevent this class from being initialized

    private_class_method def self.is_whitespace?(c)
		c == " " || c == "\t" || c == "\n" || c == "\r" || c == "\f"
	end
	
	private_class_method def self.zero_spaces_until!(text, pos, condition_callback)
		until pos >= text.bytesize || condition_callback.call(text[pos])
			if is_whitespace?(text[pos])
				text[pos] = @@flag
			end
			pos += 1
		end
		pos
	end
	
	private_class_method def self.zero_prefix_spaces!(text, pos)
		while pos < text.bytesize && is_whitespace?(text[pos])
			text[pos] = @@flag
			pos += 1
		end
		pos
	end
	
	private_class_method def self.trim_spaces_until!(text, pos, condition_callback)
		w_count = 0
		until pos >= text.bytesize || condition_callback.call(text[pos])
			if is_whitespace?(text[pos])
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

	private_class_method def self.trim_spaces_until_with_comma!(text, pos, condition_callback)
		test_ch = text[pos]
		while pos < text.bytesize && condition_callback.call(test_ch)
			pos = trim_spaces_until!(text, pos,
					lambda { |c| c == ',' || condition_callback.call(c)})
			test_ch = text[pos]
			pos += 1
			pos = zero_prefix_spaces!(text, pos)
		end
		pos
	end

	private_class_method def self.shift!(text)
		left_pos = 0
		right_pos = 0
		while right_pos < text.bytesize
			while text[right_pos] == @@flag 
				right_pos += 1
			end
			if right_pos < text.bytesize
				text[left_pos] = text[right_pos]
				left_pos += 1
				right_pos += 1
			end
		end
		text.slice!(left_pos, right_pos)
		nil
	end
end

if __FILE__ == $0
	# test whitespace stripper
	# TODO - make this test more & be more automated
	text = IO.read("proton_theme.css")
    Minifier.minify!(text)
    print(text)
end
