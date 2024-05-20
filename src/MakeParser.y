%token OBJECT_NAME, STR_ARG, SPECIAL_MODIFICATOR, AUTOMATIC, FILE_NAME, PATH

%token IFEQ, IFNEQ, ELSE, ENDIF, IFDEF, IFNDEF, ENDEF

%token INCLUDE
%token DEFINE

%token ASSIGNMENT

%token SHELL

%token ENDL

%token EMPTY

%%

input: | input line

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
            ;

// --------------------- VARIABLES -----------------------
variable: 
            variableName
            ;

variableName:
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
            targetName ':'
            |
            targetName ':' ':'
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

targetName: 
            variableName
            |
            OBJECT_NAME
            |
            FILE_NAME
            |
            PATH
            ;            
// -------------------------------------------------------

// ------------------- PREREQUISITE ----------------------
prerequisites:
            prerequisite
            ;

prerequisite:
            variableName
            |
            OBJECT_NAME
            |
            FILE_NAME
            |
            PATH
            ;
// -------------------------------------------------------
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
