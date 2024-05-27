%{
#include "MakeParser.tab.h"
#define YYSTYPE unsigned long long
int yyerror(const char *s);
unsigned int currLine = 1;
static void skipLines();
static void parseFunction(char **text);
void LexerDebugPrint(char* lexema);

%}

%option yylineno
%option noyywrap

LETTER [[:alpha:]]
DIGIT [[:digit:]]
SPEC_CHAR [.\-*\<>!_@`\\/+?%~]
CONTINUE_LINE (\\\n[ \t]*[^\n]*)* 
OBJECT_RECIPIE ^(@[^@]*@)?\t[^\n]*      

%%
{OBJECT_RECIPIE}                    { yylval.str = strdup(yytext); return OBJECT_RECIPIE; }  
{OBJECT_RECIPIE}{CONTINUE_LINE}     { skipLines(); yylval.str = strdup(yytext); return OBJECT_RECIPIE;}



\#.*       {} /* Обработка комментариев */

\$\$?\([@%\<?^+*][DF]?\)            { yylval.str = strdup(yytext);}
\$\$?[@%\<?^+*][DF]?                { yylval.str = strdup(yytext); }

\n                                  { ++currLine; return ENDL; }
[ \t]+\n                            { ++currLine; return ENDL; }

^"vpath".*
^"ifdef"                            { return IFDEF;     }
^"ifndef"                           { return IFNDEF;    }
^"endef"                            { return ENDEF;     }
^"ifeq"                             { return IFEQ;      }
^"ifneq"                            { return IFNEQ;     }
^"else"                             { return ELSE;      }
^"endif"                            { return ENDIF;     }

^"unexport"                         { return EXPORT;    }
^"export"                           { return EXPORT;    }
"override"                          { return EXPORT;    }

^"define"                           { return DEFINE;    }
^[\-]?"include"                     { return INCLUDE;   }

\$\$?\(("foreach"|"wildcard"|"patsubst"|"addprefix"|"subst"|"patsubst"|"strip"|"findstring") {   
                                      char* text = NULL;
                                      parseFunction(&text);
                                      yylval.str = text;
                                      return FUNC;
                                    }
\$\$?\(("filter"|"filter-out"|"sort"|"word"|"words"|"wordlist"|"firstword"|"lastword"|"dir") {   
                                      char* text = NULL;
                                      parseFunction(&text);
                                      yylval.str = text;
                                      return FUNC;
                                    }
\$\$?\(("notdir"|"suffix"|"basename"|"addsuffix"|"join"|"realpath"|"abspath"|"origin"|"flavor") {   
                                      char* text = NULL;
                                      parseFunction(&text);
                                      yylval.str = text;
                                      return FUNC;
                                    }
\$\$?\(("let"|"if"|"or"|"and"|"intcmp"|"call"|"eval"|"file"|"value"|"shell"|"error"|"warning") {   
                                      char* text = NULL;
                                      parseFunction(&text);
                                      yylval.str = text;
                                      return FUNC;
                                    }


\"[^\"]*\"{CONTINUE_LINE}|\'[^\']*\'{CONTINUE_LINE}|\`[^\`]*\`{CONTINUE_LINE}           { skipLines(); yylval.str = strdup(yytext); return OBJECT_STR; } /* Обработка разных значений переменных */

"::="|":::="|[":!?+"]?"="           { return ASSIGNMENT; }

\/({LETTER}|{DIGIT}|{SPEC_CHAR})+(\/({LETTER}|{DIGIT}|{SPEC_CHAR})+)+               { yylval.str = strdup(yytext); return PATH; } /* Обработка абсолютного пути для Unix */

({LETTER}|{DIGIT}|{SPEC_CHAR})+\\({LETTER}|{DIGIT}|{SPEC_CHAR})+                    { yylval.str = strdup(yytext); return PATH; } /* Обработка относительного пути для Unix */

({LETTER}|{DIGIT}|{SPEC_CHAR})+(\/({LETTER}|{DIGIT}|{SPEC_CHAR})+)+                 { yylval.str = strdup(yytext); return PATH; } /* Обработка относительного пути для Windows */

({LETTER}|{DIGIT}|{SPEC_CHAR})+"."({LETTER}|{DIGIT}|{SPEC_CHAR})+{CONTINUE_LINE}  { skipLines(); yylval.str = strdup(yytext); return FILE_NAME; }

\@({LETTER}|{DIGIT}|{SPEC_CHAR})+\@{CONTINUE_LINE}   {  } /* Обработка имён целей, файлов, путей к файлам */

({LETTER}|{DIGIT}|{SPEC_CHAR})+{CONTINUE_LINE}   { skipLines(); yylval.str = strdup(yytext); return OBJECT_NAME; } /* Обработка имён целей, файлов, путей к файлам */


[(){}[\]$\-+"\|/&\<>`!?,:;]         { return *yytext; } 

{LETTER}{DIGIT}?:\\({LETTER}|{DIGIT}|{SPEC_CHAR})+\\({LETTER}|{DIGIT}|{SPEC_CHAR})+ { yylval.str = strdup(yytext); return PATH; } /* Обработка абсолютного пути для Windows */

\\[\r]?\n[ \t]*                     { ++currLine; }

[ \t]                               ;
.                                   { char errorMsg[128] = {0}; sprintf(errorMsg, "Unrecognized symbol: %c", yytext); yyerror(errorMsg); }

%%

static void parseFunction(char **text)
{
    int c = 0; 
    int sc_count = 1; 
    int prev = 0;
    size_t len = 0;
    *text = NULL;
    while((c=input())) 
    { 
        switch (c)
        {
            case ')': 
            { 
                if(--sc_count == 0) 
                {
                    *text = realloc(*text, len + 2);
                    (*text)[len++] = (char)c; 
                    (*text)[len] = '\0';
                    return;
                }
                break;
            }
            case '(':
            { 
                ++sc_count;
                break;
            }
            case '\n':
            {
                if (prev == '\\')
                {
                    ++currLine;
                    *text = realloc(*text, len + 3);
                    (*text)[len++] = '\\'; 
                    (*text)[len++] = '\n'; 
                }
                else if (prev == ',')
                {
                    ++currLine;
                    *text = realloc(*text, len + 3);
                    (*text)[len++] = ','; 
                    (*text)[len++] = '\n'; 
                }
                else
                {
                    char errorMsg[128] = {0};
                    sprintf(errorMsg, "Unexpcted symbol, at the end of line: %c", prev);
                    yyerror(errorMsg);                

                }
                break;
            }
            default:
            {
                *text = realloc(*text, len + 2);
                (*text)[len++] = (char)c; 
                prev = c; 
                break;
            }
        }
    }
}

static void skipLines() 
{
    int line = currLine;

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
    currLine = line;
}

void LexerDebugPrint(char* lexema)
{
    printf("%s: %s Line: %d\n", lexema, yytext, yylineno);
}