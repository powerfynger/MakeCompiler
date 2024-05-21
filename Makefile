CC = gcc
LEX = flex
YACC = bison

PARSER_FILE = ./src/MakeParser.y
FLEX_FILE = ./src/MakeLexer.l
RESULT_FILES = lex.yy.c MakeParser.tab.h MakeParser.tab.c logs.txt ./build/maker

log:
	$(YACC) -d $(PARSER_FILE) -Wcounterexamples 2> logs.txt

clean:
	rm -f $(RESULT_FILES)

run:
	$(YACC) -d $(PARSER_FILE)
	$(LEX) $(FLEX_FILE)
	$(CC) lex.yy.c MakeParser.tab.c -lm -o ./build/maker

all: clean run
