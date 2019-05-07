bin/yacc: src/python.tab.c bin/lexer
	gcc -o bin/yacc src/python.tab.c

src/python.tab.c: src/python.y
	yacc -o src/python.tab.c src/python.y

bin/lexer: src/lex.yy.c
	gcc -o bin/lexer src/lex.yy.c

src/lex.yy.c: src/python.l
	lex -o src/lex.yy.c src/python.l

test: bin/lexer
	bash tests/test-lexer.sh