%{
#include <stdio.h>
#include "MakeParser.tab.h"
%}

%option yylineno
%option noyywrap

%%

OBJECT_NAME [a-zA-Z_]
DIGIT [0-9]

[(){}[\]$\-+"\|/&<>`!?,:;]       { return *yytext; }
$[@%\<?^+*]                      { return AUTOMATIC; }

%%