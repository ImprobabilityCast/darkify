class Color

    @hue

    @sat

    @light

    @alpha

    # Should work with all CSS3 color strings with no whitespace
    def initialize(str)
        if str.start_with?("rgb(")
            colors = parse_rgb(str)
            from_rgb!(colors)
            @alpha = 1.0
        elsif str.start_with?("rgba(")
            colors = parse_rgb(str)
            from_rgb!(colors)
            idx = str.rindex(',')
            @alpha = str.slice(idx + 1, str.bytesize - (idx + 3)).to_f
        elsif str.start_with?("hsl(")

        elsif str.start_with?("hsla(")

        elsif str.start_with?("#")

        else # assume named color

        end

    end

    def parse_rgb(c)
        old_idx = c.index('(') + 1
        idx = c.index(',', old_idx)
        red = c.slice(old_idx..idx).to_i

        old_idx = idx + 1
        idx = c.index(',', old_idx)
        green = c.slice(old_idx..idx).to_i

        old_idx = idx + 1
        idx = c.index(',', old_idx)
        idx = idx == nil ? c.index(')', old_idx) : idx
        blue = c.slice(old_idx..idx).to_i

        [red, green, blue]
    end

    def from_rgb!(colors)
        max_col = colors.max
        min_col = colors.min

        @light = (max_col + min_col) / 510.0 # 510 = 255 * 2

        delta = max_col - min_col
        @sat =  1.0 * delta / (max_col + min_col)

        max_idx = colors.index(max_col)

        # ([color above max_col on color wheel] - [color below max on color wheel])
        # * 60.0 because it needs to be float & 60 deg is the farthest it can be from the max
        # / (max - min) to scale it
        # 120 * max_idx to shift it to the proper place on the color wheel
        @hue = if delta == 0
            0
        else
            (colors[max_idx - 2] - colors[max_idx - 1]) \
                * (60.0 / delta) + 120 * max_idx
        end

        #nil
    end

    def from_hsl!(c)

    end

    def from_named_color!(c)

    end

    def from_hex!(c)

    end
end

if __FILE__ == $0
    print(Color.new("rgba(12,0,255,0.23)").from_rgb!([25,32,2]))
end
