CC = gcc
LEX = flex
YACC = bison
MOVE = mv

objects = "as"\
"asd"\
"asd"\
"asd"\
"asd"\
"a"

PARSER_FILE = ./src/MakeParser.y
FLEX_FILE = ./src/MakeLexer.l
RESULT_FILES = ./build/lex.yy.c ./build/MakeParser.tab.c ./build/MakeParser.tab.h logs.txt ./build/maker
BUILD_FILES = ./build/lex.yy.c ./build/MakeParser.tab.c ./src/MakeHelper.c

log:
	$(YACC) -d $(PARSER_FILE) -Wcounterexamples 2> logs.txt
	$(MOVE) MakeParser.tab.h ./build
	$(MOVE) MakeParser.tab.c ./build

clean:
	rm -f $(RESULT_FILES)

run:
	$(YACC) -d $(PARSER_FILE)
	$(LEX) $(FLEX_FILE)
	$(MOVE) lex.yy.c ./build
	$(MOVE) MakeParser.tab.h ./build
	$(MOVE) MakeParser.tab.c ./build
	$(CC) $(BUILD_FILES) -I ./src/ -lm -o ./build/maker

all: clean run
