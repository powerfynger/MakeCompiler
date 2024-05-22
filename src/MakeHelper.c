#include "MakeHelper.h"

char** targetList = NULL;
int targetSize = 0;
char** variableList = NULL;
int variableSize = 0;

int targetCounts = 1;
int variableCounts = 1;

int currState = 0;

void addTarget(char* targetName)
{
    if (!targetSize)
        targetList = (char**)malloc(sizeof(char*) * DEFAULT_TARGETS_ADD);
    else if (targetSize % DEFAULT_TARGETS_ADD == 0)
    {
        targetList = (char**)realloc(targetList, sizeof(char*) * DEFAULT_TARGETS_ADD * (targetCounts + 1));
        targetCounts++;
    }
    targetList[targetSize] = targetName;
    //printf("New target: %s\n", targetList[targetSize]);
    targetSize++;
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
    variableList[variableSize] = varName;
    //printf("New var: %s\n", variableList[variableSize]);
    variableSize++;
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