#include "MakeHelper.h"

char** targetList = NULL;
int targetCount = 0;
char** variableList = NULL;
int variableCount = 0;

int currState = 0;

void addTarget(char* targetName)
{
    if (!targetCount)
        targetList = (char**)malloc(sizeof(char*) * DEFAULT_TARGETS_ADD);
    else if (targetCount % DEFAULT_TARGETS_ADD == 0)
        targetList = (char**)realloc(targetList, sizeof(char*) * DEFAULT_TARGETS_ADD);
    targetList[targetCount] = targetName;
    printf("%s\n", targetList[targetCount]);
    targetCount++;
}

void addVariable(char* varName)
{
    if (!variableCount)
        variableList = (char**)malloc(sizeof(char*) * DEFAULT_VARS_ADD);
    else if (variableCount % DEFAULT_VARS_ADD == 0)
        variableList = (char**)realloc(variableList, sizeof(char*) * DEFAULT_VARS_ADD);
    variableList[variableCount] = varName;
    printf("[temp]: %s\n", variableList[variableCount]);
    variableCount++;
}

int checkTarget(char* targetName)
{
    int result = 0;
    for (int i = 0; i < targetCount; i++)
    {
        if (targetName == targetList[i]) 
        {
            result = 1;
            break;
        }
    }
    return result;    
}

void setState(int state)
{
    currState = state;
}

int getState()
{
    return currState;
}

void checkState()
{
    if (currState == 0)
        yyerror("recipie not in target");
}