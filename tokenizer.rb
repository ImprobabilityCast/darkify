require_relative 'token.rb'

class Tokenizer

    def initialize(str)
        @stream = StringIO.new(pre_process!(str))
        @simple_token_map = {
            '(' => Token.new(Token::OPEN_PARAN),
            ')' => Token.new(Token::CLOSE_PARAN),
            ',' => Token.new(Token::COMMA),
            ':' => Token.new(Token::COLON),
            ';' => Token.new(Token::SEMICOLON),
            '[' => Token.new(Token::OPEN_BRACKET),
            ']' => Token.new(Token::CLOSE_BRACKET),
            '{' => Token.new(Token::OPEN_BRACE),
            '}' => Token.new(Token::CLOSE_BRACE)
        }
        @complex_token_map = {
            '"' => self.method(:strtok_double),
            "'" => self.method(:strtok_single),
            '#' => self.method(:hash_token),
            '+' => self.method(:plus_token),
            '-' => self.method(:dash_token),
            '.' => self.method(:dot_token)
        }
    end

    def self.pre_process!(str)
        newlines = /(\r\n)|\r|\f/
        # Not checking for surrogate chars because ruby doesn't allow them
        # in strings. Would have to do something more complicated,
        # e.g. not using strings.
        undefined = /\0/
        m = str.match(newlines, 0)

        while m != nil
            str[m.begin(0)..(m.end(0) - 1)] = "\n"
            m = str.match(newlines, m.end(0))
        end

        if str.match?(undefined)
            str[undefined] = "\u{FFFD}" # replacement character
        end
    end

    def self.is_whitespace?(ch)
        ch == "\n" || ch == "\t" || ch == " "
    end

    def self.peek(text)
        text.string[text.pos]
    end

    def self.string_token(text, end_ch)
        start = text.pos
        type = Token.STRING
        loop
            ch = text.getc
            if ch == end_ch
                break
            elsif ch == "\n" || ch == nil
                text.seek(-1, IO:SEEK_CUR)
                type = Token.BAD_STRING  # parse err
                break
            elsif ch == "\\"
                if peek(text) == "\n"
                    text.getc
                elsif valid_esc?(ch, peek(text))
                    consume_esc_code_pt(text)
                end
            end
        end
        Token.new(type, [start, text.pos - 1])
    end

    def self.hash_token(text)
        s = text.string
        if (name_point?(s[text.pos]) ||
                valid_esc?(s[text.pos], s[text.pos + 1]))
            Token.new(Token::HASH, {"name" => consume_name(text),
                "is_id" => id_start?(s.slice(text.pos, 3)))
        else
            Token.new(Token::DELIM, text.string[text.pos - 1])
        end
    end

    def self.consume_name(text)
        start = text.pos
        loop
            ch = text.getc
            if valid_esc?(ch, peek(text))
                consume_esc_code_pt(text)
            elsif !name_point?(ch)
                text.seek(-1, IO::SEEK_CUR)
                break
            end
        end
        [start, text.pos - 1]
    end

    def self.consume_number(text)
        start = text.pos
        is_integer = true
        ch = peek(text)
        if ch == '-' || ch == '+'
            text.getc
        end

        while digit_char?(peek(text))
            text.getc
        end

        if text.string.slice(text.pos, 2).match?(/\.[0-9]/)
            text.seek(2, IO::SEEK_CUR)
            is_intger = false
        end

        if text.string.slice(text.pos, 3).match?(/(E|e)(\+|-)?[0-9]/)
            is_intger = false
            while !digit_char(peek(text)) do text.getc end
            while digit_char(peek(text)) do text.getc end
        end

        s = text.string[start, text.pos - 1]
        num = is_intger ? s.to_i : s.to_f
        {"is_integer" => is_intger, "number" => num}
    end

    # this assumes the initial 'url(' has been consumed
    def self.consume_url(text)
        start = text.pos
        loop
            while is_whitespace?(peek(text))
                text.seek(1, IO::SEEK_CUR)
            end
            ch = text.getc
            if ch == '"' || ch == "'" || ch == '('
                return consume_bad_url(text)
            elsif ch == "\\"
                if valid_esc?(ch, peek(text))
                    consume_esc_code_pt(text)
                else
                    return consume_bad_url(text)
                end
            else
                break if ch == ')' || ch == nil # nil is a parse err
            end
        end
        Token.new(Token::URL, [start, text.pos - 1])
    end

    def self.hex_digit?(ch)
        digit_char?(ch) || ch.match?(/A-F/i)
    end

    # assumes that '\' has already been consumed
    def self.consume_esc_code_pt(text)
        text.getc
        i = 1
        ch = text.getc
        while i < 6 && hex_digit?(ch)
            ch = text.getc
            i += 1
        end
        # if ch == nil # parse err
        # not replacing any invalid escapes b/c idc
        nil
    end

    def self.consume_bad_url(text)
        loop
            ch = text.getc
            break if ch == ')' || ch == nil
            if valid_esc?(ch, peek(text))
                consume_esc_code_pt(text)
            end
        end
        Token.new(Token::BAD_URL)
    end

    def self.consume_ident(text)
        name = consume_name(text)
        if name.casecmp?("url") && peek(text) == '('
            loop
                text.seek(1, IO::SEEK_CUR)
                chrs = text.string.slice(text.pos, 2)
                break if !is_whietspace(chrs[0]) || !is_whietspace(chrs[1])
            end
            chrs = text.string.slice(text.pos, 2)
            i = is_whitespace(chrs[0]) ? 1 : 0
            if chrs[i] == '"' || chrs[i] == "'"
                Token.new(Token::FUNCTION, name)
            else
                consume_url(text)
            end
        elsif peek(text) == '('
            text.seek(1, IO::SEEK_CUR)
            Token.new(Token::FUNCTION, name)
        else
            Token.new(Token::IDENTIFIER, name)
        end
    end

    def self.num_token(text)
        value = consume_number(text)
        if id_start?(text.slice(text.pos, 3))
            value["unit"] = consume_name(text)
            Token.new(Token::DIMENSION, value)
        elsif peek(text) == '%'
            Token.new(Token::PERCENTAGE, value)
        else
            Token.new(Token.NUMBER, value)
        end
    end

    def self.skip_comments(text)
        pos = text.pos
        while text.string[pos..(pos + 1)] == '/*'
            pos = text.string.index('*/', text.pos + 2)
            pos = if pos == nil
                text.string.length # parse err
            else
                pos + 2
            end
        end
        text.seek(pos, IO::SEEK_SET)
        nil
    end

    def self.name_start_point?(ch)
        ch == '_' || ch.match?(/[a-zA-Z]/) || ch >= "\x80"
    end

    def self.digit_char?(ch)
        ch >= '0' && ch <= '9'
    end

    def self.num_start?(chrs)
        i = 0
        if chrs[i] == '+' || chrs[i] == '-'
            i += 1
        end
        if chrs[i] == '.'
            i += 1
        end
        digit_char?(chrs[i])
    end

    def self.name_point?(ch)
        name_start_point?(ch) || digit_char?(ch) || ch == '-'
    end

    def self.valid_esc?(ch0, ch1)
        ch0 == "\\" && ch1 != "\n"
    end

    # checks if the first 3 chars in chrs start an id
    def self.id_start?(chrs)
         i = 0
        if chrs[i] == '-'
            i += 1
        end
        chrs[i] == '-' || name_start_point?(chrs[i]) ||
            valid_esc?(chrs[i], chrs[i += 1])
    end

    def self.strtok_single(text)
        string_token(text, "'")
    end

    def self.strtok_double(text)
        string_token(text, '"')
    end

    def self.plus_token(text)
        if num_start?(text.string.slice(text.pos, 3))
            text.seek(-1 IO::SEEK_CUR)
            num_token(text)
        else
            Token.new(Token::DELIM, '+')
        end
    end

    def self.dash_token(text)
        chrs = text.string.slice(text.pos, 3)
        if num_start?(chrs)
            text.seek(-1, IO::SEEK_CUR)
            num_token(text)
        elsif chrs[0..1] == "->"
            text.seek(2, IO::SEEK_CUR)
            Token.new(Token::CDC)
        elsif id_start?(chrs)
            text.seek(-1, IO::SEEK_CUR)
            consume_ident(text)
        else
            Token.new(Token::DELIM, '-')
        end
    end

    def self.dot_token(text)
        if num_start?(text.string.slice(text.pos, 3))
            text.seek(-1, IO::SEEK_CUR)
            num_token(text)
        else
            Token.new(Token::DELIM, ch)
        end
    end

    def self.next_token(text)
        skip_comments(text)
        ch = text.getc
        if is_whitespace?(ch)
            loop do
                ch = text.getc
                break if !is_whitespace?(ch)
            end
            Token.new(Token::WHITESPACE)
        elsif ch == '<'
            if text.string.slice(text.pos, 3) == "!--"
                Token.new(Token::CDO)
            else
                Token.new(Token::DELIM, '<')
            end
        elsif ch == '@'
            if id_start?(text.string.slice(text.pos, 3))
                Token.new(Token::AT_KEYWORD, consume_name(text))
            else
                Token.new(Token::DELIM)
            end
        elsif ch == "\\"
            if valid_esc?(ch, peek(text))
                text.seek(-1, IO::SEEK_CUR)
                consume_ident(text)
            else
                Token.new(Token::DELIM)
            end
        elsif digit_char?(ch)

        elsif name_start_point?(ch)

        elsif ch == nil # EOF

        else
            Token.new(Token::DELIM, ch)
        end
    end

end

if __FILE__ == $0
    a = "a\fa\ra\r\na"
    print("before: '#{a}'\n")
    Tokenizer.pre_process(a)
    print("after: '#{a}'\n")
end