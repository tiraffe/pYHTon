%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
int yylex (void);
void yyerror (char const *);
#define YYSTYPE char*

struct Token {
  char* value;
  int type;
};

struct Token KEYWORD[] = {
  {"False", FALSE},
  {"await", AWAIT},
  {"else", ELSE},
  {"import", IMPORT},
  {"pass", PASS},
  {"None", NONE},
  {"break", BREAK},
  {"except", EXCEPT},
  {"in", IN},
  {"raise", RAISE},
  {"True", TRUE},
  {"class", CLASS},
  {"finally", FINALLY},
  {"is", IS},
  {"return", RETURN},
  {"and", AND},
  {"continue", CONTINUE},
  {"for", FOR},
  {"lambda", LAMBDA},
  {"try", TRY},
  {"as", AS},
  {"def", DEF},
  {"from", FROM},
  {"nonlocal", NONLOCAL},
  {"while", WHILE},
  {"assert", ASSERT},
  {"del", DEL},
  {"global", GLOBAL},
  {"not", NOT},
  {"with", WITH},
  {"async", ASYNC},
  {"elif", ELIF},
  {"if", IF},
  {"or", OR},
  {"yield", YIELD}
};

struct Token OP[] = {
  {">>=", RIGHT_ASSIGN},
  {"<<=", LEFT_ASSIGN},
  {"+=", ADD_ASSIGN},
  {"-=", SUB_ASSIGN},
  {"*=", MUL_ASSIGN},
  {"/=", DIV_ASSIGN},
  {"%=", MOD_ASSIGN},
  {"&=", AND_ASSIGN},
  {"^=", XOR_ASSIGN},
  {"|=", OR_ASSIGN},
  {">>", RIGHT_OP},
  {"<<", LEFT_OP},
  {"->", PTR_OP},
  {"<=", LE_OP},
  {">=", GE_OP},
  {"==", EQ_OP},
  {"!=", NE_OP},
  {"**", POW},
  {"**=", POW_ASSIGN},
  {"//", FLOORDIV},
  {"//=", FLOORDIV_ASSIGN},
};

%}

// keywords
%token FALSE AWAIT ELSE IMPORT PASS NONE BREAK EXCEPT IN RAISE TRUE CLASS FINALLY 
%token IS RETURN AND CONTINUE FOR LAMBDA TRY AS DEF FROM NONLOCAL WHILE ASSERT DEL 
%token GLOBAL NOT WITH ASYNC ELIF IF OR YIELD 

// operators
%token RIGHT_ASSIGN LEFT_ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN  
%token MOD_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN RIGHT_OP LEFT_OP PTR_OP LE_OP GE_OP 
%token EQ_OP NE_OP POW POW_ASSIGN FLOORDIV FLOORDIV_ASSIGN

// value
%token NUMBER STRING NAME

// delimiter
%token NEWLINE INDENT DEDENT ENDMARKER

%%

program: lines ENDMARKER;
lines: import_stmt NEWLINE | lines import_stmt NEWLINE 

import_stmt
  : import_name { printf("import_name\n"); }
  | import_from { printf("import_from\n"); }
  ; 

import_name: IMPORT dotted_as_names ;
dotted_as_names: dotted_as_name | dotted_as_names ',' dotted_as_name ;
dotted_name: NAME | dotted_name '.' NAME ;
dotted_as_name: dotted_name | dotted_name AS NAME ;

dot_puls: '.' | dot_puls '.' ; 
dot_star: /* empty */ | dot_puls ;

import_as_name: NAME | NAME AS NAME ;
import_as_names: import_as_name | import_as_names ',' import_as_name ;
import_in_from: IMPORT '*' | IMPORT '(' import_as_names ')' | IMPORT import_as_names ;
import_from: FROM dot_star dotted_name import_in_from | dot_puls import_in_from ;

// comp_op: '<' | '>' | EQ_OP | NE_OP | LE_OP | GE_OP | IN | NOT IN | IS | IS NOT ;

%%
#include <stdio.h>
#include <ctype.h>

void
yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}

int
yylex (void)
{
  int c;
  char type[20], str[1024];

  if (scanf("%s", type) == EOF) {
    return 0;
  }

  if (strcmp(type, "(NEWLINE)") == 0) {
    return NEWLINE;
  } else if (strcmp(type, "(INDENT)") == 0) {
    return INDENT;
  } else if (strcmp(type, "(DEDENT)") == 0) {
    return DEDENT;
  } else if (strcmp(type, "(ENDMARKER)") == 0) {
    return ENDMARKER;
  } else if (strcmp(type, "(LIT") == 0) {
    scanf("%s", str);
    str[strlen(str) - 1] = '\0'; // remove ')' from end.
    yylval = strdup(str);

    if (str[0] == '\"') {
      return STRING;
    } else {
      return NUMBER;
    }
  } else if (strcmp(type, "(ID") == 0) {
    scanf("%s", str);
    str[strlen(str) - 2] = '\0'; // remove '")' from end.
    yylval = strdup(str + 1);
    return NAME;
  } else if (strcmp(type, "(KEYWORD") == 0) {
    scanf("%s", str);
    str[strlen(str) - 1] = '\0'; // remove ')' from end.
    yylval = strdup(str);

    int length = sizeof(KEYWORD) / sizeof(KEYWORD[0]);
    for (int i = 0; i < length; i++) {
      if (strcmp(str, KEYWORD[i].value) == 0) {
        return KEYWORD[i].type;
      }
    }
  } else if (strcmp(type, "(PUNCT") == 0) {
    scanf("%s", str);
    str[strlen(str) - 2] = '\0'; // remove '")' from end.
    yylval = strdup(str + 1);
    
    if (strlen(yylval) == 1) {
      // single-char operator
      return yylval[0];
    } else {
      // multi-char operator
      int length = sizeof(OP) / sizeof(OP[0]);
      for (int i = 0; i < length; i++) {
        if (strcmp(yylval, OP[i].value) == 0) {
          return OP[i].type;
        }
      }
    }
  } else {
    printf("UNKNOWN TYPE: %s\n", type);
    return -1;
  }
  
  printf("ERROR TOKEN: (%s, %s)\n", type + 1, str);
  return -1;
}

int
main (void)
{
  yyparse ();
  puts("DONE.");
  return 0;
}