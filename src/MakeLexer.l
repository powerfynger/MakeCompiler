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

^\.DEFAULT                      { return SPECIAL_MODIFICATOR; }
^\.DELETE_ON_ERROR              { return SPECIAL_MODIFICATOR; }
^\.EXPORT_ALL_VARIABLES         { return SPECIAL_MODIFICATOR; }
^\.IGNORE                       { return SPECIAL_MODIFICATOR; }
^\.INTERMEDIATE                 { return SPECIAL_MODIFICATOR; }
^\.LOW_RESOLUTION_TIME          { return SPECIAL_MODIFICATOR; }
^\.NOTINTERMEDIATE              { return SPECIAL_MODIFICATOR; }
^\.NOTPARALLEL                  { return SPECIAL_MODIFICATOR; }
^\.ONESHELL                     { return SPECIAL_MODIFICATOR; }
^\.PHONY                        { return SPECIAL_MODIFICATOR; }
^\.POSIX                        { return SPECIAL_MODIFICATOR; }
^\.PRECIOUS                     { return SPECIAL_MODIFICATOR; }
^\.SECONDARY                    { return SPECIAL_MODIFICATOR; }
^\.SECONDEXPANSION              { return SPECIAL_MODIFICATOR; }
^\.SILENT                       { return SPECIAL_MODIFICATOR; }
^\.SUFFIXES                     { return SPECIAL_MODIFICATOR; }
^\.RECIPEPREFIX                 { return SPECIAL_MODIFICATOR; }
^\.INCLUDE_DIRS                 { return SPECIAL_MODIFICATOR; }
^\.LIBPATTERNS                  { return SPECIAL_MODIFICATOR; }
^\.DELETE_ON_ERROR              { return SPECIAL_MODIFICATOR; }

/* Нужно тестирование */
.                               { 
                                    int pos = yycolumn;
                                    fprintf(stderr, "Unrecognized symbol '%s' in line %d, position %d\n", yytext, yylineno, pos);
                                }


%%