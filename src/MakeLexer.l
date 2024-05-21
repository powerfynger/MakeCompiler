%{
#include "MakeParser.tab.h"
#include "MakeHelper.h"
#define YYSTYPE unsigned long long
int yyerror(const char *s);

unsigned int currLine = 1;
static void UpdateLine();

%}

%option yylineno
%option noyywrap

LETTER [[:alpha:]]
DIGIT [[:digit:]]
SPEC_CHAR [.\-*<>!_@`\\/+]
CONTINUE_LINE (\\\n[ \t]*[^\n]*)* 
OBJECT_RECIPIE \t[^\n]*      

%%
{OBJECT_RECIPIE}                            { yylval.str = strdup(yytext); return OBJECT_RECIPIE; }  /* SPEC_CHAR [!@#\^&*()_+=\-`~\[\]{};'"\\\|,<>\/?] */
{OBJECT_RECIPIE}                            { UpdateLine(); yylval.str = strdup(yytext); return OBJECT_RECIPIE;}



\#.*       {} /* Обработка комментариев */

[(){}[\]$\-+"\|/&<>`!?,:;]       { return *yytext; }
\$[@%\<?^+*]                     { return AUTOMATIC; }

\n              { ++currLine; return ENDL; }
[ \t]+\n        { ++currLine;return ENDL; }

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

\"[^\"]*\"{CONTINUE_LINE}|\'[^\']*\'{CONTINUE_LINE}           { UpdateLine(); yylval.str = strdup(yytext); return OBJECT_STR; } /* Обработка разных значений переменных */
"::="|":::="|[":!?+"]?"="              { return ASSIGNMENT; }

\/({LETTER}|{DIGIT}|{SPEC_CHAR})+(\/({LETTER}|{DIGIT}|{SPEC_CHAR})+)+               { yylval.str = strdup(yytext); return PATH; } /* Обработка абсолютного пути для Unix */

({LETTER}|{DIGIT}|{SPEC_CHAR})+\\({LETTER}|{DIGIT}|{SPEC_CHAR})+                    { yylval.str = strdup(yytext); return PATH; } /* Обработка относительного пути для Unix */

({LETTER}|{DIGIT}|{SPEC_CHAR})+(\/({LETTER}|{DIGIT}|{SPEC_CHAR})+)+                 { yylval.str = strdup(yytext); return PATH; } /* Обработка относительного пути для Windows */

({LETTER}|{DIGIT}|{SPEC_CHAR})+"."({LETTER}|{DIGIT}|{SPEC_CHAR})+{CONTINUE_LINE}  { UpdateLine(); yylval.str = strdup(yytext); return FILE_NAME; }

({LETTER}|{DIGIT}|{SPEC_CHAR})+{CONTINUE_LINE}   { UpdateLine(); yylval.str = strdup(yytext); return OBJECT_NAME; } /* Обработка имён целей, файлов, путей к файлам */

^"."(({LETTER}|{SPEC_CHAR})+)    { yylval.str = strdup(yytext); return OBJECT_SPECIAL; } /* Обработка специальных целей; TODO: В .y добавить проверку на существование заданной спец. цели */

\%({LETTER}|{DIGIT}|{SPEC_CHAR})*    { yylval.str = strdup(yytext); return OBJECT_NAME; }


{LETTER}{DIGIT}?:\\({LETTER}|{DIGIT}|{SPEC_CHAR})+\\({LETTER}|{DIGIT}|{SPEC_CHAR})+ { yylval.str = strdup(yytext); return PATH; } /* Обработка абсолютного пути для Windows */

\\[\r]?\n[ \t]*                                                             { ++currLine;}


\$\((shell[^)]*\))                { return SHELL; } /* Обработка команд шелл-оболочки https://www.gnu.org/software/make/manual/html_node/Shell-Function.html */



[ \t]
.                               {
                                    yyerror("Unrecognized symbol");
                                    fprintf(stderr, "Unrecognized symbol '%s' in line %d\n", yytext, yylineno);
                                }

%%

static void UpdateLine() {
    int line = currLine;
    // printf("Line: %d\n", line);

    char *p = yytext + strlen(yytext) - 1;
    while (p >= yytext && *p == '\n') {
        p--;
    }
    while (p >= yytext && *p == '\\' && *(p - 1) == '\n') {
        p -= 2;
    }
    while (p >= yytext && *p == '\n') {
        line++;
        p--;
    }
    // printf("Line: %d\nChar: %s", line, p);
    currLine = line;
}
