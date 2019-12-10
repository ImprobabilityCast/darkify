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
            idx = str.rindex(',') + 1
            @alpha = str.slice(idx..-1).to_f
        elsif str.start_with?("hsl(")
            colors = parse_hsl(str)
            from_hsl!(colors)
            @alpha = 1.0
        elsif str.start_with?("hsla(")
            colors = parse_hsl(str)
            from_hsl!(colors)
            idx = str.rindex(',') + 1
            @alpha = str.slice(idx..-1).to_f
        elsif str.start_with?("#")
            # valid string lengths 4, 5, 7, 9
            
        else # assume named color

        end

    end

    def to_s
        "hsla(" + @hue.to_s + ", " + (@sat * 100).to_s + "%, " +
            (@light * 100).to_s + "%, " + @alpha.to_s + ")"
    end

    private def parse_rgb(c)
        old_idx = c.index('(') + 1
        idx = c.index(',', old_idx)
        red = c.slice(old_idx..idx).to_i

        old_idx = idx + 1
        idx = c.index(',', old_idx)
        green = c.slice(old_idx..idx).to_i

        old_idx = idx + 1
        blue = c.slice(old_idx..-1).to_i

        [red, green, blue]
    end

    private def parse_hsl(c)
        old_idx = c.index('(') + 1
        idx = c.index(',', old_idx)
        hue = c.slice(old_idx..idx).to_i

        old_idx = idx + 1
        idx = c.index('%', old_idx)
        sat = c.slice(old_idx..idx).to_f / 100.0

        old_idx = idx + 2
        light = c.slice(old_idx..-1).to_f / 100.0

        [hue, sat, light]
    end

    private def from_rgb!(colors)
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

        nil
    end

    private def from_hsl!(colors)
        @hue, @sat, @light = colors
    end

    private def from_named_color!(c)

    end

    private def from_hex!(c)

    end

end

if __FILE__ == $0
    print(Color.new("hsla(123,50%,72%,0.2)"))
end
