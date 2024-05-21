%{
#include "MakeParser.tab.h"
int yyerror(const char *s);
%}

%option yylineno
%option noyywrap

LETTER [[:alpha:]]
DIGIT [[:digit:]]
SPEC_CHAR [!@#\^&*()_+=-`~\[\]{};'"\\|,.<>\/?]
OBJECT_RECIPIE ^(\@[^\@]*\@)?\t[^\n]*      

%%
{OBJECT_RECIPIE}                        { return OBJECT_RECIPIE; }



\#.*       {} /* Обработка комментариев */

[(){}[\]$\-+"\|/&<>`!?,:;]       { return *yytext; }
\$[@%\<?^+*]                     { return AUTOMATIC; }

\n              { return ENDL; }
[ \t]+\n        { return ENDL; }

^"ifdef"                         { return IFDEF; } /* Обработка условных операторов */
^"ifndef"                        { return IFNDEF; }
^"endef"                         { return ENDEF; }
^"ifeq"                          { return IFEQ; }
^"ifneq"                         { return IFNEQ; }
^"else"                          { return ELSE; }
^"endif"                         { return ENDIF; }

^"unexport"                     { return EXPORT; }
^"export"                       { return EXPORT; }
^"override"                     { return EXPORT; }

^"define"                       { return DEFINE; }

^"include"                      { return INCLUDE; }

^"."(({LETTER}|{SPEC_CHAR})+)    { return OBJECT_SPECIAL; } /* Обработка специальных целей; TODO: В .y добавить проверку на существование заданной спец. цели */

"::="|[":!?+"]?"="                { return ASSIGNMENT; }

({LETTER}|{DIGIT}|{SPEC_CHAR})+  { yylval.str = strdup(yytext); return OBJECT_NAME; } /* Обработка имён целей, файлов, путей к файлам */
\%({LETTER}|{DIGIT}|{SPEC_CHAR})*    { yylval.str = strdup(yytext); return OBJECT_NAME; }

({LETTER}|{DIGIT}|{SPEC_CHAR}|".")+ { yylval.str = strdup(yytext); return FILE_NAME; }

{LETTER}{DIGIT}?:\\({LETTER}|{DIGIT}|{SPEC_CHAR})+\\({LETTER}|{DIGIT}|{SPEC_CHAR})+ { yylval.str = strdup(yytext); return PATH; } /* Обработка абсолютного пути для Windows */

\/({LETTER}|{DIGIT}|{SPEC_CHAR})+(\/({LETTER}|{DIGIT}|{SPEC_CHAR})+)+               { yylval.str = strdup(yytext); return PATH; } /* Обработка абсолютного пути для Unix */

({LETTER}|{DIGIT}|{SPEC_CHAR})+\\({LETTER}|{DIGIT}|{SPEC_CHAR})+                    { yylval.str = strdup(yytext); return PATH; } /* Обработка относительного пути для Unix */

({LETTER}|{DIGIT}|{SPEC_CHAR})+(\/({LETTER}|{DIGIT}|{SPEC_CHAR})+)+                 { yylval.str = strdup(yytext); return PATH; } /* Обработка относительного пути для Windows */


\$\((shell[^)]*\))                { return SHELL; } /* Обработка команд шелл-оболочки https://www.gnu.org/software/make/manual/html_node/Shell-Function.html */


\"[^\"]*\"|\'[^\']*\'           { yylval.str = strdup(yytext); return OBJECT_STR; } /* Обработка разных значений переменных */

[ \t]
.                               {
                                    yyerror("Unrecognized symbol");
                                    fprintf(stderr, "Unrecognized symbol '%s' in line %d\n", yytext, yylineno);
                                }

%%