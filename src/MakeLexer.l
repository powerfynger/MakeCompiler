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
SPEC_CHAR [!@#\^&*()_+=-`~\[\]{};'"\\|,.<>\/?]
OBJECT_NAME ({LETTER}|{SPEC_CHAR})+

%%

/* Обработка комментариев*/
\#."*"       {}

[(){}[\]$\-+"\|/&<>`!?,:;]       { return *yytext; }
\$[@%\<?^+*]                      { return AUTOMATIC; }


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
^"define"                       { return EXPORT; }
^"override"                     { return EXPORT; }

^"include"                      { return INCLUDE; }

/* Обработка специальных целей */
/* TODO: В .y добавить проверку на существование заданной спец. цели */
^"."(({LETTER}|{SPEC_CHAR})+)    { return SPECIAL_MODIFICATOR; }

/* Обработка имён целей, файлов, путей к файлам */
({LETTER}|{DIGIT}|{SPEC_CHAR})+  { yylval.str = strdup(yytext); return OBJECT_NAME; }
\%({LETTER}|{DIGIT}|{SPEC_CHAR})*    {yylval.str = strdup(yytext); return OBJECT_NAME; }    

({LETTER}|{DIGIT}|{SPEC_CHAR}|".")+ { yylval.str = strdup(yytext); return FILE_NAME; }


/* Обработка абсолютного пути для Windows */
{LETTER}{DIGIT}?:\\({LETTER}|{DIGIT}|{SPEC_CHAR})+\\({LETTER}|{DIGIT}|{SPEC_CHAR})+ { yylval.str = strdup(yytext); return PATH; }
/* Обработка абсолютного пути для Unix */
\/({LETTER}|{DIGIT}|{SPEC_CHAR})+(\/({LETTER}|{DIGIT}|{SPEC_CHAR})+)+               { yylval.str = strdup(yytext); return PATH; }
/* Обработка относительного пути для Unix */
({LETTER}|{DIGIT}|{SPEC_CHAR})+\\({LETTER}|{DIGIT}|{SPEC_CHAR})+                    { yylval.str = strdup(yytext); return PATH; }
/* Обработка относительного пути для Windows */
({LETTER}|{DIGIT}|{SPEC_CHAR})+(\/({LETTER}|{DIGIT}|{SPEC_CHAR})+)+                 { yylval.str = strdup(yytext); return PATH; }


/* Обработка команд шелл-оболочки https://www.gnu.org/software/make/manual/html_node/Shell-Function.html */
\$\((shell[^)]*\))                { return SHELL; }


"::="|[":!?+"]?"="           { return ASSIGNMENT; }

/* Обработка разных значений переменных */
\"[^\"]*\"|\'[^\']*\'           { yylval.str = strdup(yytext); return STR_ARG; }

/* Нужно тестирование */
.                               { 
                                    int pos = yycolumn;
                                    yyerror("Unrecognized symbol");
                                    fprintf(stderr, "Unrecognized symbol '%s' in line %d, position %d\n", yytext, yylineno, pos);
                                }


%%