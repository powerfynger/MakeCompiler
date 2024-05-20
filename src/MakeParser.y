%{
#include <stdio.h>
#include <stdlib.h>

int yyparse();
extern int yylex();
extern FILE* yyin;

%}

%token OBJECT_NAME, STR_ARG, SPECIAL_MODIFICATOR, AUTOMATIC, FILE_NAME, PATH
%token IFEQ, IFNEQ, ELSE, ENDIF, IFDEF, IFNDEF, ENDEF
%token INCLUDE, EXPORT, DEFINE
%token ASSIGNMENT
%token SHELL
%token ENDL
%token EMPTY

%start in

%%

in: 
            | in line
            ;

line: 
            ENDL
            |
            target
            |
            include
            |
            define
            |
            condition
            |
            variable
            ;

// --------------------- VARIABLES -----------------------
variable: 
            variableName ASSIGNMENT variableBody ENDL
            |
            EXPORT variable
            |
            EXPORT OBJECT_NAME ENDL
            |
            EXPORT ENDL

            ;

variableName:
            OBJECT_NAME
            |
            FILE_NAME {
                /* ERROR: Filename in variable name */
            }
            |
            PATH {
                /* ERROR: Path in variable name */
            }
            |
            AUTOMATIC {
                /* ERROR: Automatic variable in target */
            }
            ;

variableBody:
            EMPTY
            ;

variableValue:
            EMPTY
            ;
// -------------------------------------------------------

// ---------------------- TARGETS ------------------------
target:     
            targetVar prerequisites ENDL
            |
            targetVar prerequisites ';' ENDL
            |
            targetVar prerequisites ';' recipies ENDL
            ;

targetVar: 
            targetExpr ':'
            |
            targetExpr ':' ':'
            |
            // TODO
            // Остальные виды символов между модификатором и его значением
            // https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
            // Сравнить возможное наполнение токена ASSIGNMENT с тем, какие могут использоваться тут 
            SPECIAL_MODIFICATOR ':'
            |
            SPECIAL_MODIFICATOR '+' '='
            |
            SPECIAL_MODIFICATOR '='
            ;

            // Для учета "фейк" (пустых) целей
targetExpr:
            targetExpr targetName
            |
            targetName
            ;

targetName: 
            variableName
            |
            OBJECT_NAME
            |
            FILE_NAME
            |
            PATH
            |
            AUTOMATIC {
                /* ERROR: Automatic variable in target */
            }
            ;
// -------------------------------------------------------

// ------------------- PREREQUISITE ----------------------
prerequisite:
            prerequisites
            ;

            // Для учета множественных зависимостей
prerequisites:
            prerequisites prerequisiteName
            |
            prerequisiteName
            ;

prerequisiteName:
            variableName
            |
            OBJECT_NAME
            |
            FILE_NAME
            |
            PATH
            |
            AUTOMATIC {
                /* ERROR: Automatic variable in prerequisite */
            }
            ;
// -------------------------------------------------------

// ---------------------- DEFINES ------------------------
define:
            DEFINE OBJECT_NAME ENDL
            define_body 
            ENDEF ENDL
            ;

define_body:
            // ...
            SHELL
            |
            variableValue
            |
            OBJECT_NAME
            |
            AUTOMATIC
            |
            FILE_NAME
            |
            PATH
            |
            STR_ARG
            |
            ENDL
            ;
// -------------------------------------------------------

// -------------------- CONDITIONS -----------------------
condition:
            if '(' arg ',' arg ')' ENDL
            |
            if '(' arg ',' ')' ENDL
            |
            if '(' ',' arg ')' ENDL
            |
            if '(' ',' ')' ENDL
            |
            if STR_ARG STR_ARG ENDL
            |
            ifdef atomic ENDL
            |
            ELSE
            |
            ENDIF
            ;

if:
            IFEQ
            |
            IFNEQ
            ;

ifdef:
            IFDEF
            |
            IFNDEF
            ;

arg:
            atomic
            |
            STR_ARG
            ;
// -------------------------------------------------------

// ---------------------- INCLUDE ------------------------
include:
            INCLUDE filenames
            ;

filenames: 
            variableValue
            |
            OBJECT_NAME
            |
            FILE_NAME
            |
            PATH
            ;
// -------------------------------------------------------

// --------------------- RECIPIES ------------------------
recipies: 
            EMPTY
            ;
// -------------------------------------------------------

atomic:
            variableValue
            |
            OBJECT_NAME
            |
            FILE_NAME
            |
            PATH
            |
            AUTOMATIC
            ;

%%
