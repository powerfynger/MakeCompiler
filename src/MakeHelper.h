#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DEFAULT_TARGETS_ADD 128
#define DEFAULT_VARS_ADD 128

enum State {
    STATE_NONE,
    STATE_RECIPE,
    STATE_DEFINE,
    STATE_NORMAL
};

int yyerror(const char *s);

void addTarget(char* targetName);
void addVariable(char* varName);
int checkVariable(char* varName);
int checkTarget(char* targetName);

void setState(enum State state);
void checkStateRecipe();
void checkStateDefine();

enum State getState();

void printStats();
