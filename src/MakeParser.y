%token ENDL
%token OBJECT_NAME, STR_ARG, SPECIAL, AUTOMATIC
%token FILE_NAME, PATH

%token IFEQ, IFNEQ, ELSE, ENDIF, IFDEF, IFNDEF, ENDEF

%token INCLUDE

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

define:
            EMPTY
            ;

condition:
            EMPTY
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
            SPECIAL ':'
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

recipies: 
            EMPTY
            ;

//

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
