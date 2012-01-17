require 'textpow'

class HTMLProcessor
    def open_tag name, position
        # Print out the bit before the current position
        if position-1 >= @line_pos
            print CGI::escapeHTML(@line[@line_pos..position-1])
        end
        @line_pos = position

        classes = name.split(/\./)
        list = []
        begin
            list.push(classes.join('_'))
        end while classes.pop
        
        print "<span class=\"#{ list.reverse.join(' ').lstrip }\">"
    end

    def close_tag name, position
        print CGI::escapeHTML(@line[@line_pos..position-1])
        @line_pos = position
        print "</span>"
    end

    def new_line line
        finish_line if @open_line

        @line = line
        @line_pos = 0
        @open_line = true
        @line_number += 1
        print "<span class='line_number' id='line#{@line_number}'>#{sprintf("%3d", @line_number)}:</span>"
    end

    def finish_line
        r = @line[@line_pos..-1]
        print CGI::escapeHTML(r) unless r == nil
    end

    def start_parsing name
        @line_number = 0
    end

    def end_parsing name
        finish_line if @open_line
    end
end

Textpow::SyntaxNode.load("CSPM.tmSyntax").parse($stdin, HTMLProcessor.new)
