%{
#include <stdio.h>
#include <stdlib.h>

int yyparse();
extern int yylex();
extern FILE* yyin;

%}

%token OBJECT_NAME OBJECT_STR SPECIAL_MODIFICATOR AUTOMATIC FILE_NAME PATH
%token IFEQ IFNEQ ELSE ENDIF IFDEF IFNDEF ENDEF
%token INCLUDE EXPORT DEFINE
%token ASSIGNMENT
%token SHELL CMD
%token ENDL

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
            recipies
            |
            variable
            |
            include
            |
            define
            |
            condition
            ;

// ---------------------- TARGETS ------------------------
target:     
            targetVar prerequisite ENDL
            |
            targetVar prerequisite ';' ENDL
            |
            targetVar prerequisite ';' atomics ENDL
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

// --------------------- RECIPIES ------------------------
recipies: 
            cmd ENDL
            |
            cmd atomics ENDL
            ;

cmd:
            CMD
            ;
// -------------------------------------------------------

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
            OBJECT_NAME
            |
            OBJECT_STR
            |
            FILE_NAME
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

// ----------------------  ------------------------


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
}

int yyerror(const char *s)
{  
    fprintf(stderr, "\n[-] Line %u: error - %s", yyline, s);
    fprintf(stderr, "\nProgram finished analysis\n");
    exit(0);
}