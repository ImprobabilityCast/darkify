require_relative 'color'
require_relative 'minifier'

class CSSTheme
	def self.darkify(text)
		text_arr = []
		i = 0
		while i < text.bytesize
			prev_i = i
			i = text.index('{', i)
			if i == nil
				i = text.bytesize - 1
			end
			text_arr.push(text[prev_i..i])
			i += 1

			# if not @media, @keyframes, and others
			if i < text.bytesize && text[prev_i] != '@'
				# now we should be inside the block of rules
				color_count = 0
				while i < text.bytesize
					# get property
					prop_end = text.index(':', i)
					prop = text[i..(prop_end - 1)]
					prop_end += 1

					# get value
					val_end = text.index(';', prop_end)
					val_end2 = text.index('}', prop_end)
					if val_end == nil || val_end2 < val_end
						val_end = val_end2
					end
					val = text[prop_end..(val_end - 1)]
					i = val_end

					new_val = process_pair(prop, val)
					text_arr.push(prop)
					text_arr.push(':')
					text_arr.push(new_val)
					text_arr.push(text[i])
					color_count += 1
					i += 1
					# leave loop if at end of block
					break if text[i] == '}' || text[i - 1] == '}'
				end
				#if text_arr[-1] != '}' then text_arr.push('}') end
			end
		end
		text_arr.join
	end

	private_class_method def self.process_pair(prop, val)
		if is_simple_color_prop(prop)
			find_color(val)
		elsif prop == "background"
			val #bg_val(val)
		else
			val
		end
	end

	private_class_method def self.find_color(val_str)
		vals = val_str.split(" ")
		vals.each_index { |a|
			imp = vals[a].rindex("!important")
			current = if imp != nil
				[vals[a][0..(imp-1)], "!important"]
			else
				[vals[a]]
			end
			if Color.is_color?(current[0])
				current[0] = Color.new(current[0]).to_inv_s
				vals[a] = current.join
			end
		}.join(" ")
	end

	private_class_method def self.split(val, split_ch, op_quote_ch, end_quote_ch)
		arr = []
		prev = 0
		quotes = 0
		i = 0
		while i < val.bytesize
			if val[i] == split_ch && quotes == 0
				arr.push(val[prev..(i - 1)])
				prev = i + 1
			elsif val[i] == op_quote_ch
				quotes += 1
			elsif val[i] == end_quote_ch
				quotes -= 1
			end
			i += 1
		end
		if prev != i
			arr.push(val[prev..-1])
		end
		arr
	end

	private_class_method def self.bg_val(val)
		vals = split(val, ",", "(", ")")
		i = 0
		while i < vals.length
			arr = vals[i].split("gradient")
			if arr.length == 2
				grad_args = split(arr[1][1..-2], ",", "(", ")")
				arr[1] = "(" << grad_args.each_index { |i|
					grad_args[i] = if Color.is_color?(grad_args[i])
						Color.new(grad_args[i]).to_inv_s
					else
						grad_args[i]
					end
				}.join(",") << ")"
			end
			vals[i] = arr.join("gradient")
			i += 1
		end
		vals.join(",")
	end

	private_class_method def self.is_simple_color_prop(prop)
		# Things that can have color:
		# https://developer.mozilla.org/en-US/docs/Web/HTML/Applying_color#Things_that_can_have_color
		prop.end_with?("color") || prop.start_with?("border") ||
			prop.start_with?("text") || prop == "column-rule" ||
			prop == "outline" || prop == "box-shadow"
	end
end

if __FILE__ == $0
	text = IO.read(ARGF.argv[0])
	Minifier.minify!(text)
	print(CSSTheme.darkify(text))
end
