class Token

    attr_reader :type, :value
    def initialize(type, value = nil)
        @type = type
        @value = value
    end

    # https://www.w3.org/TR/css-syntax-3/#tokenization
    IDENTIFIER = 1
    FUNCTION = 2
    AT_KEYWORD = 3
    HASH = 4
    STRING = 5
    BAD_STRING = 6
    URL = 7
    BAD_URL = 8
    DELIM = 9
    NUMBER = 10
    PERCENTAGE = 11
    DIMENSION = 12
    WHITESPACE = 13
    CDO = 14
    CDC = 15
    COLON = 16
    SEMICOLON = 17
    COMMA = 18
    OPEN_BRACKET = 19
    CLOSE_BRACKET = 20
    OPEN_PARAN = 21
    CLOSE_PARAN = 22
    OPEN_BRACE = 23
    CLOSE_BRACE = 24
end
