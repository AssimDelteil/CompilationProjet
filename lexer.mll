{ 
    open Printf
    open Parser 
}

rule decoupe = parse 
  |"mod" {MOD}
  |"rem" {REM}
  |"and" {AND}
  |"or" {OR}
  |"xor" {XOR}
  |"abs" {ABS}
  |"not" {NOT}
  |"then" {THEN}
  |"else" {ELSE}
  |"loop" {LOOP}
  |"end" {END}
  |"while" {WHILE} 
  |"for" {FOR}
  |"reverse" {REVERSE}
  |"in" {IN}
  |"if" {IF}
  |"elsif" {ELSIF}
  |"else" {ELSE}
  |"case" {CASE}
  |"when" {WHEN}
  |"others" {OTHERS}
  |"goto" {GOTO}
  |"exit" {EXIT}
  |"return" {RETURN}
  |"range" {RANGE}
  |"Integer" {INTEGER}  
  |"Boolean" {BOOLEAN}
  |"constant" {CONSTANT}
  |"type" {TYPE}  
  |"is" {IS}
  |"subtype" {SUBTYPE}
  |"renames" {RENAMES}  
  |"procedure" {PROCEDURE}
  |"out" {OUT}
  |"function" {FUNCTION}  
  |"begin" {BEGIN}
  |"null" {NULL}
  |"!=" {NEQ}
  |"<=" {LESSE}
  |"<<" {DEB_ETIQ}
  |">>" {FIN_ETIQ}
  |"**" {PUISS}
  |">=" {GREATE}
  |":=" {AFFECT}  
  |"=>" {FLECHE}
  |".." {PP}
  |"--" {COMM}
  |'+' {PLUS}
  |'-' {MOINS}
  |'/' {DIV}
  |'*' {FOIS}
  |'=' {EQ}
  |'<' {LESS}
  |'>' {GREATT}
  |'(' {LPAR}
  |')' {RPAR}
  |',' {VIR}
  |';' {PVIR}
  |'.' {P}
  |':' {DP} 
  |'|' {SEP}
  |'\n' {EOL}
  |[' ''\t']+ {decoupe lexbuf}
  /* Reconnais entier basique et float basique et id basique, pas le truc compliqué*/
  |['0'-'9']+ as i {CST_INT (int_of_string i)}
  |['0'-'9']+(.['0'-'9']+)?(['e'|'E']['0'-'9']+)? as f {CST_FLOAT (float_of_string f)}
  |['a'-'z''A'-'Z''_']['a'-'z''A'-'Z''_''0'-'9']* as s {ID s}