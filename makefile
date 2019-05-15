bin/yacc: src/python.tab.cpp bin/lexer
	g++ -o bin/yacc src/python.tab.cpp

src/python.tab.cpp: src/python.y
	yacc -o src/python.tab.cpp src/python.y

bin/lexer: src/lex.yy.c
	g++ -o bin/lexer src/lex.yy.c

src/lex.yy.c: src/python.l
	lex -o src/lex.yy.c src/python.l

test: bin/lexer
	bash tests/test-lexer.sh