extends Node

class_name Lexer

var token_ptr = 0
var input_line : String = ""

func reset_lexer():
    token_ptr = 0

func are_tokens_remaining() -> bool:
    return token_ptr < input_line.length() 

func get_token() -> String:
    var token_buffer : String = ""
    var inside_quotes : bool = false

    var escape_spaces : bool = false

    while are_tokens_remaining():
        var ch = input_line[token_ptr] 

        token_ptr += 1

        if (not escape_spaces) and ch == " ":
            if token_buffer.empty():
                continue     
            else:
                break    
            continue
        elif ch == "\"":
            inside_quotes = not inside_quotes
            escape_spaces = inside_quotes
        elif ch == "(":
            escape_spaces = true
        elif ch == ")":
            escape_spaces = false

        token_buffer += ch

    return token_buffer            

# Returns the parsed function name and parameters.
# For eg:
# 	line 10 20 40 50 -> [line, 10, 20, 40, 50]
# 	line 10 20 40 50 Color(200,200,200) -> [line, 10, 20, 40, 50, Color(200,200,200)]
#   text 10 20 \"Hello World\" -> [text, 10, 20, "Hello World"]
func all_tokens_from_line(line : String) -> PoolStringArray:
    reset_lexer()
    input_line = line

    var tokens : PoolStringArray = []
    while are_tokens_remaining():
        var tk = get_token()
        tokens.append(tk)
    return tokens


