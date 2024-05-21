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

%token AUTOMATIC
%token IFEQ IFNEQ ELSE ENDIF IFDEF IFNDEF ENDEF
%token INCLUDE EXPORT DEFINE
%token ASSIGNMENT
%token SHELL
%token ENDL
%token <str> OBJECT_NAME OBJECT_STR OBJECT_SPECIAL FILE_NAME PATH OBJECT_RECIPIE

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
            ;

// ---------------------- TARGETS ------------------------
target:     
            targetVar ENDL
            |
            targetVar prerequisite ENDL
            |
            targetVar prerequisite ';' ENDL
            |
            targetVar prerequisite ';' atomics ENDL
            ;

targetVar: 
            targetName ':'
            |
            targetName ':' ':'
            |
            OBJECT_SPECIAL ':'
            |
            OBJECT_SPECIAL '+' '='
            |
            OBJECT_SPECIAL '='
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
            AUTOMATIC {
                yyerror("automatic variable in target");
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
            variableValue
            |
            OBJECT_NAME
            |
            FILE_NAME
            |
            PATH
            |
            AUTOMATIC {
                yyerror("automatic variable in prerequisite");
            }
            ;
// -------------------------------------------------------

// --------------------- RECIPIES ------------------------
recipies: 
            recipiePart ENDL
            |
            recipiePart atomics ENDL
            ;

recipiePart:
            OBJECT_RECIPIE { 
                char temp[256];
                sprintf(temp, "recipies: %s", (char*)$1);
                debugPrint(temp); }
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
            FILE_NAME {
                yyerror("filename in variable name");
            }
            |
            PATH {
                yyerror("path in variable name");
            }
            |
            AUTOMATIC {
                yyerror("automatic variable in variable name");
            }
            ;

variableBody:
            OBJECT_NAME { 
                char temp[256];
                sprintf(temp, "variableBody: %s", (char*)$1);
                debugPrint(temp);
            }
            |
            OBJECT_STR{
                char temp[256];
                sprintf(temp, "variableBody: %s", (char*)$1);
                debugPrint(temp);
            }
            |
            FILE_NAME {char temp[256];
                sprintf(temp, "ariableBody: %s", (char*)$1);
                debugPrint(temp);}
            |
            PATH
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
            variablePart
            |
            variableBody variablePart
            ;

variablePart:
            SHELL
            |
            ASSIGNMENT
            |
            variableSigns
            |
            variableValue
            ;

            // Символы, которые могут встретиться в variableBody (например, -name; остальные - bash, cmd?)
variableSigns:
            '-' | '+' | ':' | '&' | '>' | '<' | '[' | ']' | ';' | '/'
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
            defineBody 
            ENDEF ENDL
            ;

defineBody:
            variableValue
            |
            defineSigns
            |
            ASSIGNMENT
            |
            SHELL
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
            '-' | '+' | ':' | '&' | '>' | '<' | '[' | ']' | ';' | '/'
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
            ;
// -------------------------------------------------------

// ---------------------- INCLUDE ------------------------
include:
            INCLUDE filenames // Включение/исключение make-файлов в глубину
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
    printf("[+] Analysis is completed successfully.\n");
}

int yyerror(const char *s)
{  
    fprintf(stderr, "[-] Line %u: error - %s\n", yylineno, s);
    fprintf(stderr, "[!] Finished.\n");
    exit(0);
}

void debugPrint(char* value)
{
    printf("[DEBUG]: %s\n", value);
}