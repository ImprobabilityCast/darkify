require_relative 'color'
require_relative 'minifier'

class CSSTheme
	def self.darkify(text)
		text_arr = []
		i = 0
		while i < text.bytesize
			prev_i = i
			i = text.index('{', i)
			text_arr.push(text[prev_i..i])
			i += 1

			# if not @media, @keyframes, and others
			if text[prev_i] != '@'
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
					text_arr.push(
						if is_simple_color_prop(prop)
							find_color(val)
						elsif prop == "background"
							bg_val(val)
						else
							val
						end
					)
					text_arr.push(text[i])
					i += 1
				end
				if i < text.bytesize
					text_arr.push(text[i])
					i += 1
				end
			end
		end
		text_arr.join
	end

	private_class_method def self.find_color(val_str)
		vals = val_str.split(" ")
		vals.each_index { |a|
			vals[a] = if Color.is_color?(vals[a])
				Color.new(vals[a]).to_inv_s
			else
				vals[a]
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
			prop == "outline"
	end
end

if __FILE__ == $0
	text = IO.read("lightStyle.css")
	print(text)
	Minifier.minify!(text)
	print(CSSTheme.darkify(text))
end
