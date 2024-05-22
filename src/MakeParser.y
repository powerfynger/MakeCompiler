%{
#include "MakeHelper.h"

int yyparse();
extern int yylex();
extern FILE* yyin;
extern int yylineno;

void debugPrint(char* value);
%}

%define parse.error detailed

%union 
{
    char* str;
}

%token IFEQ IFNEQ ELSE ENDIF IFDEF IFNDEF ENDEF
%token INCLUDE EXPORT DEFINE
%token ASSIGNMENT
%token ENDL
%token <str> OBJECT_NAME OBJECT_STR OBJECT_SPECIAL FILE_NAME PATH OBJECT_RECIPIE AUTOMATIC FUNC

%start in

%%

in:
            | in line
            ;

line: 
            ENDL
            |
            target { setState(1); }
            |
            recipies { checkState(); }
            |
            variable { setState(0); }
            |
            include
            |
            define
            |
            condition
            |
            atomic ENDL {
                yyerror("an atomic object outside the expression");
            }
            ;

// ---------------------- TARGETS ------------------------
target:     
            targetVar ENDL
            |
            targetVar ';' ENDL
            |
            targetVar prerequisite ENDL
            |
            targetVar prerequisite ';' ENDL
            |
            targetVar prerequisite ';' atomics ENDL
            |
            targetVar variable
            |
            targetVar ';' recipies
            |
            targetVar prerequisite recipies
            |
            targetVar prerequisite ';' recipies
            ;

targetVar: 
            targetExpr ':'
            |
            targetExpr ':' ':'
            |
            OBJECT_SPECIAL ':'
            |
            OBJECT_SPECIAL '+' '='
            |
            OBJECT_SPECIAL '='
            ;

targetExpr:
            targetExpr targetName
            |
            targetExpr targetName '&' // Rules with Grouped Targets
            |
            targetName
            ;

targetName: 
            variableValue
            |
            OBJECT_NAME { addTarget((char*)$1); }
            |
            FILE_NAME { addTarget((char*)$1); }
            |
            PATH { addTarget((char*)$1); }
            |
            FUNC { addTarget((char*)$1); }
            |
            targetName '/' OBJECT_NAME
            |
            AUTOMATIC {
                yyerror("automatic variable in target");
            }
            ;
// -------------------------------------------------------

// ------------------- PREREQUISITE ----------------------
prerequisite:
            prerequisites
            ;

            // Для учета множественных prerequisites
prerequisites:
            prerequisites prerequisiteName
            |
            prerequisites '|' prerequisiteName // Предварительные условия "только для заказа"
            |
            '|' prerequisiteName
            |
            prerequisites ':' prerequisiteName // Syntax of Static Pattern Rules
            |
            prerequisiteName
            ;

prerequisiteName:
            variableValue
            |
            OBJECT_NAME
            |
            FILE_NAME
            |
            PATH
            |
            FUNC
            |
            AUTOMATIC
            ;
// -------------------------------------------------------

// --------------------- RECIPIES ------------------------
recipies: 
            recipiePart ENDL
            |
            recipiePart atomics ENDL
            ;

recipiePart:
            OBJECT_RECIPIE
            ;
// -------------------------------------------------------

// --------------------- VARIABLES -----------------------
variable: 
            variableName ASSIGNMENT variableBody ENDL
            |
            variableName ASSIGNMENT ENDL
            |
            EXPORT variable
            |
            EXPORT OBJECT_NAME ENDL
            |
            EXPORT ENDL
            ;

variableName:
            OBJECT_NAME { addVariable((char*)$1); }
            |
            FILE_NAME
            |
            PATH
            |
            AUTOMATIC {
                yyerror("automatic variable in variable name");
            }
            ;

variableBody:
            OBJECT_NAME {
                // char temp[512];
                // sprintf(temp, "variableBody: %s", (char*)$1);
                // debugPrint(temp);
            }
            |
            OBJECT_STR 
            |
            FILE_NAME
            |
            PATH
            |
            variablePart
            |
            variableBody variablePart
            |
            variableBody OBJECT_NAME 
            |
            variableBody OBJECT_STR
            |
            variableBody FILE_NAME 
            |
            variableBody PATH
            |
            '(' variableBody ')'
            |
            '{' variableBody '}'
            |
            variableBody '(' variableBody ')'
            |
            variableBody '{' variableBody '}'
            |
            variableBody ','
            ;

variablePart:
            FUNC
            |
            AUTOMATIC
            |
            ASSIGNMENT
            |
            variableSigns
            |
            variableValue
            ;

            // Символы, которые могут встретиться в variableBody (например, -name; остальные - bash, cmd?)
variableSigns:
            '-' | '+' | ':' | '&' | '>' | '<' | '[' | ']' | ';' | '/' | '|'
            ;

variableValue:
            '$' OBJECT_NAME
            |
            '$' '$' OBJECT_NAME // $$ Для передачи переменных в скрипты bash e.t.c.
            |
            '$' '(' OBJECT_NAME ')'
            |
            '$' '{' OBJECT_NAME '}'
            |
            '$' '$' '(' OBJECT_NAME ')'
            |
            '$' '$' '{' OBJECT_NAME '}'
            |
            '$' '(' variablePart ')'
            |
            '$' '{' variablePart '}'
            |
            '$' '(' OBJECT_NAME ':' substitution ASSIGNMENT substitution ')' // Ссылки на замену (Substitution References)
            |
            '$' '{' OBJECT_NAME ':' substitution ASSIGNMENT substitution '}'
            |
            '$' '(' variablePart ':' substitution ASSIGNMENT substitution ')'
            |
            '$' '{' variablePart ':' substitution ASSIGNMENT substitution '}'
            ;

substitution:
            OBJECT_NAME
            |
            FILE_NAME
            ;
// -------------------------------------------------------

// ---------------------- DEFINES ------------------------
define:
            DEFINE OBJECT_NAME ENDL
            defineBody ENDL
            ENDEF ENDL
            |
            DEFINE OBJECT_NAME ASSIGNMENT ENDL
            defineBody ENDL
            ENDEF ENDL
            ;

defineBody:
            definePart
            |
            defineBody definePart
            ;

definePart:
            variableValue
            |
            defineSigns
            |
            ASSIGNMENT
            |
            FUNC
            |
            OBJECT_NAME
            |
            AUTOMATIC
            |
            FILE_NAME
            |
            PATH
            |
            OBJECT_STR
            |
            ENDL
            ;

defineSigns:
            '-' | '+' | ':' | '&' | '>' | '<' | '[' | ']' | ';' | '/' | '|'
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
            if OBJECT_STR OBJECT_STR ENDL
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
            OBJECT_STR
            |
            FUNC
            ;
// -------------------------------------------------------

// ---------------------- INCLUDE ------------------------
include:
            INCLUDE filenames ENDL // Включение/исключение make-файлов в глубину
            ;

filenames:
            filenames filename
            |
            filename
            ;

filename: 
            variableValue
            |
            OBJECT_NAME
            |
            FILE_NAME
            |
            PATH
            ;
// -------------------------------------------------------

// -------------------------------------------------------

atomics:
            atomics atomic
            |
            atomic
            ;

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
#define DEFAULT_ERROR -1

int main(int argc, char* argv[])
{
    if (argc != 2)
    {
        printf("[-] argument with the name of the input file is missing\n");
        return DEFAULT_ERROR;
    }
    FILE* inputFile = fopen(argv[1], "r");
    if (inputFile == NULL)
    {
        printf("[-] makefile %s doesn't exist\n", argv[1]);
        return DEFAULT_ERROR;
    }
    yyin = inputFile;
    yyparse();
    fclose(yyin);
    printStats();
    printf("[+] Analysis is completed successfully.\n");
}

int yyerror(const char *s)
{  
    fprintf(stderr, "[Line %u] Error: %s\n", yylineno, s);
    fprintf(stderr, "[!] Finished.\n");
    exit(0);
}

void debugPrint(char* value)
{
    printf("[DEBUG]: %s\n", value);
}