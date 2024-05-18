%token ENDL
%token OBJECT_NAME, SPECIAL

%token FILE_NAME, PATH, 

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

include:
            EMPTY;

define:
            EMPTY;

condition:
            EMPTY;

// ---------------------- TARGETS ------------------------

target:     
            targetVar prerequisites ENDL
            |
            targetVar prerequisites ';' ENDL
            |
            targetVar prerequisites ';' recipies
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

variable: 
            variableName
            ;

variableName:
            EMPTY
            ;

// -------------------------------------------------------

recipies: 
            EMPTY
            ;

%%
