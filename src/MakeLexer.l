%{
#include <stdio.h>
#include "MakeParser.tab.h"

int yyerror(const char *error)
{  
    printf("\n-----Error occured-----\n%s\n", error);
}
%}

%option yylineno
%option noyywrap

LETTER [[:alpha:]]
DIGIT [[:digit:]]
SPEC_CHAR [_@(){}[\]\-+\|/&<>`!?,;]
OBJECT_NAME ({LETTER}|{SPEC_CHAR})+

%%



[(){}[\]$\-+"\|/&<>`!?,:;]       { return *yytext; }
$[@%\<?^+*]                      { return AUTOMATIC; }


/* Обработка условных операторов */
^"ifdef"                         { return IFDEF; }
^"ifndef"                        { return IFNDEF; }
^"endef"                         { return ENDEF; }
^"ifeq"                          { return IFEQ; }
^"ifneq"                         { return IFNEQ; }
^"else"                          { return ELSE; }
^"endif"                         { return ENDIF; }



^"unexport"                     { return EXPORT; }
^"export"                       { return EXPORT; }
^"include"                      { return INCLUDE; }
^"define"                       { return DEFINE; }

/* Обработка специальных целей */
/* TODO: В .y добавить проверку на существование заданной спец. цели */
^"."(({LETTER}|{SPEC_CHAR})+)    { return SPECIAL_MODIFICATOR; }

/* Обработка имён целей, файлов, путей к файлам */
({LETTER}|{DIGIT}|{SPEC_CHAR})+  { yylval.str = strdup(yytext); return OBJECT_NAME; }
({LETTER}|{DIGIT}|{SPEC_CHAR}|".")+ { yylval.str = strdup(yytext); return FILE_NAME; }



/* Обратока комманд шелл-оболочки https://www.gnu.org/software/make/manual/html_node/Shell-Function.html */
\$\((shell[^)]*\))                { return SHELL; }


"::="|[":!?+"]?"="           { return ASSIGNMENT; }


/* Нужно тестирование */
.                               { 
                                    int pos = yycolumn;
                                    yyerror("Unrecognized symbol");
                                    fprintf(stderr, "Unrecognized symbol '%s' in line %d, position %d\n", yytext, yylineno, pos);
                                }


%%