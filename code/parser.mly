%{
  open File
%}
/*Token terminaux sans type*/
%token MOD REM AND OR XOR ABS NOT THEN ELSE LOOP END WHILE FOR REVERSE IN IF ELSIF ELSE CASE WHEN OTHERS GOTO EXIT RETURN RANGE CONSTANT TYPE IS SUBTYPE RENAMES PROCEDURE OUT FUNCTION BEGIN NULL NEQ LESSE DEB_ETIQ FIN_ETIQ PUISS GREATE AFFECT FLECHE PP COMMENT PLUS MOINS DIV FOIS EQ LESST GREATT LPAR RPAR VIR PVIR P DP SEP EOF
%token <float> CST_FLOAT
%token <int> CST_INT
%token <string> ID STR
%start s
%type <File.file> s


%left LOOP END WHILE FOR REVERSE IF ELSIF WHEN OTHERS GOTO EXIT RETURN RANGE INTEGER BOOLEAN CONSTANT TYPE IS SUBTYPE RENAMES PROCEDURE OUT FUNCTION NULL DEB_ETIQ FIN_ETIQ AFFECT PP COMMENT LPAR RPAR VIR P DP SEP EOF
%left AND OR XOR AND THEN OR ELSE
%left EQ NEQ LESSE LESST GREATE GREATT
%left PLUS MOINS PVIR 
%right FOIS DIV MOD REM
%nonassoc PUISS NOT ABS FLECHE IN




%%

s:s_prime EOF{$1}

s_prime: 
    |PROCEDURE ID IS d_list BEGIN i_list END ID PVIR  {File($2,Some($4),$6)}
    |PROCEDURE ID IS BEGIN i_list END ID PVIR  {File($2,None,$5)}


i_list:
  |i {[$1]}
  |i i_list{$1::$2}

d_list:
  |d {[$1]}
  |d d_list{$1::$2}

e:
    |e PLUS e { Plus($1,$3) }
    |e FOIS e { Fois($1,$3) }
    |e MOINS e { Moins($1,$3) }
    |e DIV e { Div($1,$3) }
    |LPAR e RPAR { $2 }
    |e PUISS e { Puiss($1,$3) }
    |e EQ e { Eq($1,$3) }
    |e NEQ e { Neq($1,$3) }
    |e LESSE e { LessE($1,$3) }
    |e GREATE e { GreatE($1,$3) }
    |e LESST e { LessT($1,$3) }
    |e GREATT e { GreatT($1,$3) }
    |e MOD e { Mod($1,$3) }   
    |e REM e { Rem($1,$3) }
    |e AND e { And($1,$3) }
    |e OR e { Or($1,$3) }
    |e XOR e { Xor($1,$3) }
    |e AND THEN e { AndThen($1,$4) }
    |e OR ELSE e { OrElse($1,$4) }
    |MOINS e { Nega($2) }
    |ABS e { Abs($2) }
    |NOT e { Not($2) }
    |CST_INT { Int($1) }
    |CST_FLOAT {Float($1)}
    |STR {Str($1)}
    |ID { Id($1) }
    |ID LPAR e_list RPAR { ConvOuAppelFct($1,$3) }

e_list:
  |e {[$1]}
  |e VIR e_list{$1::$3}

elsif_list:
    |ELSIF e THEN i_list { [($2,$4)] }
    |ELSIF e THEN i_list elsif_list { ($2,$4)::$5 }

case_choix:
    |e { Expr($1) }
    |e PP e { Range($1,$3) }
    |OTHERS { Other }

case_choix_list:
    |case_choix {[$1]}
    |case_choix SEP case_choix_list {$1::$3}

case_ligne:
    |case_choix_list FLECHE i_list PVIR  {$1,$3}

case_ligne_list:
    |case_ligne {[$1]}
    |case_ligne case_ligne_list {$1::$2}

etiquette:
    | {None}
    |DEB_ETIQ ID FIN_ETIQ { Some($2) }

id_option:
    |ID { Some($1) }
    | {None}



i:
    |etiquette NULL PVIR  { NullInstr($1) }
    |etiquette ID AFFECT e PVIR  { Affect($1,$2,$4) }
    |etiquette ID LPAR e_list RPAR PVIR  { AppelProc($1,$2,Some($4)) }
    |etiquette ID PVIR { AppelProc($1,$2,None) }
    |etiquette id_option LOOP i_list END LOOP id_option PVIR  { Loop($1,$2,$4,$7) }
    |etiquette id_option WHILE e LOOP i_list END LOOP id_option PVIR  { While($1,$2,$4,$6,$9) }
    |etiquette id_option FOR ID IN REVERSE e PP e LOOP i_list END LOOP id_option PVIR  {For($1,$2,$4,true,$7,$9,$11,$14)}
    |etiquette id_option FOR ID IN e PP e LOOP i_list END LOOP id_option PVIR  { For($1,$2,$4,false,$6,$8,$10,$13) }

    |etiquette IF e THEN i_list END IF PVIR  { If($1,$3,$5,None,None) }
    |etiquette IF e THEN i_list ELSE i_list END IF PVIR  { If($1,$3,$5,None,Some($7)) }
    |etiquette IF e THEN i_list elsif_list END IF PVIR  { If($1,$3,$5,Some($6),None) }
    |etiquette IF e THEN i_list elsif_list ELSE i_list END IF PVIR  { If($1,$3,$5,Some($6),Some($8)) }


    |etiquette CASE e IS case_ligne_list END CASE PVIR  { Case($1,$3,$5) }
    |etiquette GOTO ID PVIR  { Goto($1,$3) }
    |etiquette EXIT id_option WHEN e PVIR  { Exit($1,$3,Some($5)) }
    |etiquette EXIT PVIR  { Exit($1,None,None) }
    |etiquette RETURN PVIR  { ReturnProc($1) }
    |etiquette RETURN e PVIR  {ReturnFct($1,$3) }


id_list:
  |ID { Fin($1) }
  |ID VIR id_list { List($1,$3) }

mode:
    | { Null }
    |IN { In }
    |OUT { Out }
    |IN OUT { In_out }

parametre:
  |id_list DP mode ID { LastPara($1,$3,$4) }
  |id_list DP mode ID PVIR parametre { ParaList($1,$3,$4,$6) }
  
d:
    |ID DP CONSTANT ID AFFECT e PVIR { Objet($1,true,Some($4),Some($6)) }
    |ID DP PVIR { Objet($1,false,None,None) }
    |ID DP ID PVIR { Objet($1,false,Some($3),None) }
    |ID DP CONSTANT PVIR { Objet($1,true,None,None) }
    |ID DP AFFECT e PVIR  { Objet($1,false,None,Some($4)) }
    |ID DP CONSTANT ID PVIR { Objet($1,true,Some($4),None) }
    |ID DP ID AFFECT e PVIR { Objet($1,false,Some($3),Some($5)) }
    |ID DP CONSTANT AFFECT e PVIR { Objet($1,true,None,Some($5)) }
    


    |TYPE ID IS RANGE e PP e PVIR  { Type($2,$5,$7) }
    |SUBTYPE ID IS ID RANGE e PP e PVIR  { Sous_type($2,$4,$6,$8) }
    |ID DP ID RENAMES ID PVIR  { Rename($1,$3,$5) }

    |PROCEDURE ID LPAR parametre RPAR PVIR  { Procedure($2,Some($4)) }
    |PROCEDURE ID PVIR  { Procedure($2,None) }

    |FUNCTION ID LPAR parametre RPAR RETURN ID PVIR  { Function($2,Some($4),$7) }
    |FUNCTION ID RETURN ID PVIR  { Function($2,None,$4) }

    |PROCEDURE ID LPAR parametre RPAR IS d_list BEGIN i_list END ID PVIR  { DefProcedure($2,Some($4),Some($7),$9,$11) }
    |PROCEDURE ID LPAR parametre RPAR IS BEGIN i_list END ID PVIR  { DefProcedure($2,Some($4),None,$8,$10) }
    |PROCEDURE ID IS d_list BEGIN i_list END ID PVIR  { DefProcedure($2,None,Some($4),$6,$8) }
    |PROCEDURE ID IS BEGIN i_list END ID PVIR  { DefProcedure($2,None,None,$5,$7) }
    |FUNCTION ID LPAR parametre RPAR RETURN ID IS d_list BEGIN i_list END ID PVIR  { DefFunction($2,Some($4),$7,Some($9),$11,$13) }
    |FUNCTION ID LPAR parametre RPAR RETURN ID IS BEGIN i_list END ID PVIR  { DefFunction($2,Some($4),$7,None,$10,$12) }
    |FUNCTION ID RETURN ID IS d_list BEGIN i_list END ID PVIR  { DefFunction($2,None,$4,Some($6),$8,$10) }
    |FUNCTION ID RETURN ID IS BEGIN i_list END ID PVIR  { DefFunction($2,None,$4,None,$7,$9) }


