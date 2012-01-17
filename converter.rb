# Based on doctohtml, by Brad Choate
require "plist"

theme = Plist::parse_xml($stdin)
settings = theme["settings"]
theme_comment = theme['comment']
theme_name = theme['name']
theme_class = ""
theme_class.replace(theme_name)
theme_class.downcase!
theme_class.gsub!(/[^a-z0-9_-]/, '_')
theme_class.gsub!(/_+/, '_')

def to_rgba(color)
    colors = color.scan /^#(..)(..)(..)(..)/
    r = colors[0][0].hex
    g = colors[0][1].hex
    b = colors[0][2].hex
    a = colors[0][3].hex
    return "rgba(#{r}, #{g}, #{b}, #{ format '%0.02f', a / 255.0 })"
end

pre_selector = "pre.textmate-highlight.#{theme_class}"

body_bg = ""
body_fg = ""
selection_bg = ""

# Find the main settings block
settings.each { |d|
    if (!d['name'] and d['settings'])
        body_bg = d['settings']['background'] || '#ffffff'
        body_fg = d['settings']['foreground'] || '#000000'
        selection_bg = d['settings']['selection']
        body_bg = to_rgba(body_bg) if body_bg =~ /#.{8}/
        body_fg = to_rgba(body_fg) if body_fg =~ /#.{8}/
        selection_bg = to_rgba(selection_bg) if selection_bg && selection_bg =~ /#.{8}/
        break
    end
}

print """/* Stylesheet generated from TextMate theme
 *
 * #{theme_name}
 * #{theme_comment}
 *
 */

pre.textmate-highlight.#{theme_class}
{
    background-color: #{body_bg};
    color: #{body_fg};
}

pre.textmate-highlight.#{theme_class} ::selection
{
    background-color: #{selection_bg};
}

pre.textmate-highlight.#{theme_class}
{
    margin: 0;
    padding: 0 0 0 0px;
    line-height: 1.3em;
    word-wrap: break-word;
    white-space: pre;
    white-space: pre-wrap;
    white-space: -moz-pre-wrap;
    white-space: -o-pre-wrap;
    font-family: 'Menlo Regular', monospace;
    font-size: 11pt;
}

pre.textmate-highlight.#{theme_class} span
{
    padding-top: 0.2em;
    padding-bottom: 0.1em;
}

pre.textmate-highlight.#{theme_class} span.line_number
{
    width: 75px;
    padding: 0.1em 0.6em 0.2em 0;
    color: #888;
    background-color: #eee;    
}
"""

settings.each { |d|
    name = d["name"]
    scope = d["scope"]

    next unless scope and name
    
    print "/* #{name} */\n"

    scope_name = scope.strip
    scope_name.gsub! /(^|[ ])-[^ ]+/, '' # strip negated scopes
    scope_name.gsub! /\./, '_' # change inner '.' to '_'
    scope_name.gsub! /(^|[ ])/, '\1.'
    scope_name.gsub! /(^|,\s+)/m, '\1' + pre_selector + ' '

    print scope_name
    print "\n"
    print "{\n"
    s = d["settings"]
    if s.key?"foreground" then
        color = s["foreground"]
        color = to_rgba(color) if color =~ /#.{8}/
        print "    color: #{color};\n"
    end
    if s.key?"background" then
        color = s["background"]
        color = to_rgba(color) if color =~ /#.{8}/
        print "    background-color: #{color};\n"
    end
    if s.key?"fontStyle" then
        style = s["fontStyle"]
        print "    font-style: italic;\n" if style =~ /\bitalic\b/i
        print "    text-decoration: underline;\n" if style =~ /\bunderline\b/i
        print "    font-weight: bold;\n" if style =~ /\bbold\b/i
    end
    print "}\n\n"
}
