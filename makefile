bin/lexer: src/lex.yy.c
	gcc -o bin/lexer src/lex.yy.c

src/lex.yy.c: src/python.l
	lex -o src/lex.yy.c src/python.l

test-lex: bin/lexer
	bin/lexer < tests/lex.py
