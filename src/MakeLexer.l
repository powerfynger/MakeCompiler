%{
    #include <stdio.h>
%}

OBJECT_NAME [a-zA-Z_]
DIGIT [0-9]

[(){}[\]$\-+"|/&<>`!?,:;] { return *yytext; }
