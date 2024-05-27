#include <stdio.h>
#include <stdlib.h>

#define DEFAULT_TARGETS_ADD 128
#define DEFAULT_VARS_ADD 128

int yyerror(const char *s);

void addTarget(char* targetName);
void addVariable(char* varName);
int checkVariable(char* varName);
int checkTarget(char* targetName);

void setState(int state);
void checkState();
int getState();

void printStats();
