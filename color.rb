class Color

    # Should work with all CSS3 color strings with no whitespace
    def initialize(str)
        if str.start_with?("rgb")
            from_rgb_str!(str)
        elsif str.start_with?("hsl")
            from_hsl_str!(str)
        elsif str.start_with?("#")
            from_hex!(str)
        else # assume named color
            from_named_color!(str)
        end
    end

    def to_s
        "hsla(" << @hue.round(2).to_s << ", " <<
            @sat.round(2).to_s << "%, " <<
            @light.round(2).to_s << "%, " <<
            @alpha.round(2).to_s << ")"
    end

    def to_inv_s
        @light = 100 - @light
        inv_s = to_s
        @light = 100 - @light # restore @light
        inv_s
    end

    # is probably a color
    def self.is_color?(color)
        @@color_table.has_key?(color) || color.start_with?("#") ||
            color.start_with?("rgb(") || color.start_with?("rgba(") ||
            color.start_with?("hsl(") || color.start_with?("hsla(")
    end

    # Using hex strings because it's convenient.
    # Stole this from https://www.w3.org/TR/css-color-3/#svg-color.
    @@color_table = {
        "aliceblue" => "#F0F8FF",
        "antiquewhite" => "#FAEBD7",
        "aqua" => "#00FFFF",
        "aquamarine" => "#7FFFD4",
        "azure" => "#F0FFFF",
        "beige" => "#F5F5DC",
        "bisque" => "#FFE4C4",
        "black" => "#000000",
        "blanchedalmond" => "#FFEBCD",
        "blue" => "#0000FF",
        "blueviolet" => "#8A2BE2",
        "brown" => "#A52A2A",
        "burlywood" => "#DEB887",
        "cadetblue" => "#5F9EA0",
        "chartreuse" => "#7FFF00",
        "chocolate" => "#D2691E",
        "coral" => "#FF7F50",
        "cornflowerblue" => "#6495ED",
        "cornsilk" => "#FFF8DC",
        "crimson" => "#DC143C",
        "cyan" => "#00FFFF",
        "darkblue" => "#00008B",
        "darkcyan" => "#008B8B",
        "darkgoldenrod" => "#B8860B",
        "darkgray" => "#A9A9A9",
        "darkgreen" => "#006400",
        "darkgrey" => "#A9A9A9",
        "darkkhaki" => "#BDB76B",
        "darkmagenta" => "#8B008B",
        "darkolivegreen" => "#556B2F",
        "darkorange" => "#FF8C00",
        "darkorchid" => "#9932CC",
        "darkred" => "#8B0000",
        "darksalmon" => "#E9967A",
        "darkseagreen" => "#8FBC8F",
        "darkslateblue" => "#483D8B",
        "darkslategray" => "#2F4F4F",
        "darkslategrey" => "#2F4F4F",
        "darkturquoise" => "#00CED1",
        "darkviolet" => "#9400D3",
        "deeppink" => "#FF1493",
        "deepskyblue" => "#00BFFF",
        "dimgray" => "#696969",
        "dimgrey" => "#696969",
        "dodgerblue" => "#1E90FF",
        "firebrick" => "#B22222",
        "floralwhite" => "#FFFAF0",
        "forestgreen" => "#228B22",
        "fuchsia" => "#FF00FF",
        "gainsboro" => "#DCDCDC",
        "ghostwhite" => "#F8F8FF",
        "gold" => "#FFD700",
        "goldenrod" => "#DAA520",
        "gray" => "#808080",
        "green" => "#008000",
        "greenyellow" => "#ADFF2F",
        "grey" => "#808080",
        "honeydew" => "#F0FFF0",
        "hotpink" => "#FF69B4",
        "indianred" => "#CD5C5C",
        "indigo" => "#4B0082",
        "ivory" => "#FFFFF0",
        "khaki" => "#F0E68C",
        "lavender" => "#E6E6FA",
        "lavenderblush" => "#FFF0F5",
        "lawngreen" => "#7CFC00",
        "lemonchiffon" => "#FFFACD",
        "lightblue" => "#ADD8E6",
        "lightcoral" => "#F08080",
        "lightcyan" => "#E0FFFF",
        "lightgoldenrodyellow" => "#FAFAD2",
        "lightgray" => "#D3D3D3",
        "lightgreen" => "#90EE90",
        "lightgrey" => "#D3D3D3",
        "lightpink" => "#FFB6C1",
        "lightsalmon" => "#FFA07A",
        "lightseagreen" => "#20B2AA",
        "lightskyblue" => "#87CEFA",
        "lightslategray" => "#778899",
        "lightslategrey" => "#778899",
        "lightsteelblue" => "#B0C4DE",
        "lightyellow" => "#FFFFE0",
        "lime" => "#00FF00",
        "limegreen" => "#32CD32",
        "linen" => "#FAF0E6",
        "magenta" => "#FF00FF",
        "maroon" => "#800000",
        "mediumaquamarine" => "#66CDAA",
        "mediumblue" => "#0000CD",
        "mediumorchid" => "#BA55D3",
        "mediumpurple" => "#9370DB",
        "mediumseagreen" => "#3CB371",
        "mediumslateblue" => "#7B68EE",
        "mediumspringgreen" => "#00FA9A",
        "mediumturquoise" => "#48D1CC",
        "mediumvioletred" => "#C71585",
        "midnightblue" => "#191970",
        "mintcream" => "#F5FFFA",
        "mistyrose" => "#FFE4E1",
        "moccasin" => "#FFE4B5",
        "navajowhite" => "#FFDEAD",
        "navy" => "#000080",
        "oldlace" => "#FDF5E6",
        "olive" => "#808000",
        "olivedrab" => "#6B8E23",
        "orange" => "#FFA500",
        "orangered" => "#FF4500",
        "orchid" => "#DA70D6",
        "palegoldenrod" => "#EEE8AA",
        "palegreen" => "#98FB98",
        "paleturquoise" => "#AFEEEE",
        "palevioletred" => "#DB7093",
        "papayawhip" => "#FFEFD5",
        "peachpuff" => "#FFDAB9",
        "peru" => "#CD853F",
        "pink" => "#FFC0CB",
        "plum" => "#DDA0DD",
        "powderblue" => "#B0E0E6",
        "purple" => "#800080",
        "rebeccapurple" => "#663399",
        "red" => "#FF0000",
        "rosybrown" => "#BC8F8F",
        "royalblue" => "#4169E1",
        "saddlebrown" => "#8B4513",
        "salmon" => "#FA8072",
        "sandybrown" => "#F4A460",
        "seagreen" => "#2E8B57",
        "seashell" => "#FFF5EE",
        "sienna" => "#A0522D",
        "silver" => "#C0C0C0",
        "skyblue" => "#87CEEB",
        "slateblue" => "#6A5ACD",
        "slategray" => "#708090",
        "slategrey" => "#708090",
        "snow" => "#FFFAFA",
        "springgreen" => "#00FF7F",
        "steelblue" => "#4682B4",
        "tan" => "#D2B48C",
        "teal" => "#008080",
        "thistle" => "#D8BFD8",
        "tomato" => "#FF6347",
        "transparent" => "#0000",
        "turquoise" => "#40E0D0",
        "violet" => "#EE82EE",
        "wheat" => "#F5DEB3",
        "white" => "#FFFFFF",
        "whitesmoke" => "#F5F5F5",
        "yellow" => "#FFFF00",
        "yellowgreen" => "#9ACD32"
    }.freeze # prevent any subclasses from modifying it

    private def parse_color_fn(c)
        old_idx = c.index('(') + 1
        idx = c.index(',', old_idx)
        red = c[old_idx..idx]

        old_idx = idx + 1
        idx = c.index(',', old_idx)
        green = c[old_idx..idx]

        old_idx = idx + 1
        idx = c.index(',', old_idx)
        blue = c[old_idx..-1]

        alpha = idx == nil ? 1.0 : c[(idx + 1)..-1].to_f

        # CSS4 compatibility - alpha channel can be a percent
        if alpha > 1.000001 then alpha /= 100.0 end

        [red, green, blue, alpha]
    end

    private def parse_hsl(c)
        hue, sat, light, alpha = parse_color_fn(c)
        [hue.to_f, sat.to_f, light.to_f, alpha]
    end

    private def parse_short_hex(c, radix)
        factor = radix + 1

        red = c[1].to_i(radix) * factor
        green = c[2].to_i(radix) * factor
        blue = c[3].to_i(radix) * factor
         # Alpha channels in hex are in CSS4 draft at the time of writing,
        # but they are supported by most browsers.
        alpha = c.length == 5 ? c[4].to_i(radix) * factor / 255.0 : 1.0

        [red, green, blue, alpha]
    end

    private def parse_long_hex(c, radix)
        red = c[1..2].to_i(radix)
        green = c[3..4].to_i(radix)
        blue = c[5..6].to_i(radix)
        alpha = c.length == 9 ? c[7..8].to_i(radix) / 255.0 : 1.0

        [red, green, blue, alpha]
    end

    private def from_rgb_str!(c)
        red, green, blue, alpha = parse_color_fn(c)
        from_rgb_arr!([red.to_i, green.to_i, blue.to_i, alpha])
    end

    private def from_rgb_arr!(colors)
        @alpha = colors.pop

        max_col = colors.max
        min_col = colors.min
        @light = 100.0 * (max_col + min_col) / 510 # 510 = 255 * 2

        delta = max_col - min_col
        @sat = (max_col + min_col) == 0 ? 0.0 : 100.0 * delta / (max_col + min_col)

        max_idx = colors.index(max_col)

        # ([color above max_col on color wheel] - [color below max on color wheel])
        # * 60.0 because it needs to be float & 60 deg is the farthest it can be from the max
        # / (max - min) to scale it
        # 120 * max_idx to shift it to the proper place on the color wheel
        @hue = if delta == 0
            0
        else
            ((colors[max_idx - 2] - colors[max_idx - 1]) \
                * (60.0 / delta) + 120 * max_idx + 360) % 360
        end

        # Pretend that I didn't modify colors
        colors.push(@alpha)
        nil
    end

    private def from_hsl_str!(c)
        @hue, @sat, @light, @alpha = parse_hsl(c)
        nil
    end

    private def from_hex!(c)
        radix = 16

        colors = if c.length >= 7
            parse_long_hex(c, radix)
        else
            parse_short_hex(c, radix)
        end
        from_rgb_arr!(colors)
        nil
    end

    private def from_named_color!(c)
        from_hex!(@@color_table[c.downcase])
    end

end

if __FILE__ == $0
    print("#{Color.new("rgb(123,12,65)")}\n")
    print("#{Color.new("rgba(3,52,255,0.3)")}\n")
    print("#{Color.new("hsl(52,57%,2%)")}\n")
    print("#{Color.new("hsla(123,50%,72%,0.2)")}\n")
    print("#{Color.new("#34E")}\n")
    print("#{Color.new("#34ED")}\n")
    print("#{Color.new("#3490A0")}\n")
    print("#{Color.new("#3490A056")}\n")
    print("#{Color.new("blue")}\n")
    print("#{Color.new("BlUe")}\n")
    print("#{Color.new("goldenrod")}\n")
    print("#{Color.new("rgb(123,12,65,0.4)")}\n")
    print("#{Color.new("rgb(123,12,65,40%)")}\n")
end
