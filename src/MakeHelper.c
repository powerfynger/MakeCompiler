#include "MakeHelper.h"

extern int yylineno;
int yyerrors = 0; 

char** targetList = NULL;
int targetSize = 0;
char** variableList = NULL;
int variableSize = 0;

int targetCounts = 1;
int variableCounts = 1;

int currState = STATE_NORMAL;

void addTarget(char* targetName)
{
    if (!targetSize)
        targetList = (char**)malloc(sizeof(char*) * DEFAULT_TARGETS_ADD);
    else if (targetSize % DEFAULT_TARGETS_ADD == 0)
    {
        targetList = (char**)realloc(targetList, sizeof(char*) * DEFAULT_TARGETS_ADD * (targetCounts + 1));
        targetCounts++;
    }
    if (!checkTarget(targetName)) 
    {
        targetList[targetSize] = targetName;
        targetSize++;
    }
}

void addVariable(char* varName)
{
    if (!variableSize)
        variableList = (char**)malloc(sizeof(char*) * DEFAULT_VARS_ADD);
    else if (variableSize % DEFAULT_VARS_ADD == 0)
    {
        variableList = (char**)realloc(variableList, sizeof(char*) * DEFAULT_VARS_ADD * (variableCounts + 1));
        variableCounts++;
    }
    if (!checkTarget(varName)) 
    {
        variableList[variableSize] = varName;
        variableSize++;
    }
}

int checkTarget(char* targetName)
{
    int result = 0;
    for (int i = 0; i < targetSize; i++)
    {
        if (targetName == targetList[i]) 
        {
            result = 1;
            break;
        }
    }
    return result;    
}

int checkVariable(char* varName)
{
    if (getState() == STATE_DEFINE) return 0;

    int result = 0;
    for (int i = 0; i < variableSize; i++)
    {
        if (!strcmp(varName, variableList[i])) 
        {
            result = 1;
            break;
        }
    }
    return result;    
}

void setState(enum State state) {
    currState = state;
}

enum State getState() {
    return currState;
}

void checkStateRecipe()
{
    if (getState() != STATE_RECIPE)
    {
        yyerror("recipie not in target");
    }
}

void printStats()
{
    printf("\nStatistics of the analyzed makefile:\n\n"
           "Lines: %d\n"
           "Targets: %d\n"
           "Variables: %d\n"
           "------------------------------------\n"
           "[!] Conflicts: %d\n\n", 
           yylineno, targetSize, variableSize, yyerrors);
}