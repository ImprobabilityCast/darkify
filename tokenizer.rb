class Tokenizer

    private_class_method :new # prevent this class from being initialized

    def self.pre_process(text)
        newlines = /(\r\n)|\r|\f/
        # Not checking for surrogate chars because ruby doesn't allow them
        # in strings. Would have to do something more complicated,
        # e.g. not using strings.
        undefined = /\0/
        m = text.match(newlines, 0)

        while m != nil
            text[m.begin(0)..(m.end(0) - 1)] = "\n"
            m = text.match(newlines, m.end(0))
        end

        if text.match?(undefined)
            text[undefined] = "\u{FFFD}" # replacement character
        end
    end

end

if __FILE__ == $0
    a = "a\fa\ra\r\na"
    print("before: '#{a}'\n")
    Tokenizer.pre_process(a)
    print("after: '#{a}'\n")
end