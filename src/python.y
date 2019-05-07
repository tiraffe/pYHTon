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
  // TODO
};

%}

// keywords
%token FALSE AWAIT ELSE IMPORT PASS NONE BREAK EXCEPT IN RAISE TRUE CLASS FINALLY 
%token IS RETURN AND CONTINUE FOR LAMBDA TRY AS DEF FROM NONLOCAL WHILE ASSERT DEL 
%token GLOBAL NOT WITH ASYNC ELIF IF OR YIELD 

// operators

// value
%token NUMBER STRING NAME

// delimiter
%token NEWLINE INDENT DEDENT ENDMARKER

%%

exps
  : exp
  | exps exp
  ;

exp:
  STRING  { printf("STRING: %s\n", $1); }
  | NUMBER  { printf("NUM: %s\n", $1); } 
  | TRUE { printf("KK: %s\n", $1); } 
  | FALSE { printf("KK: %s\n", $1); } 
;


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
  char type[10], str[1024];

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
  } else if (strcmp(str, "(PUNCT") == 0) {
    scanf("%s", str);
    str[strlen(str) - 2] = '\0'; // remove '")' from end.
    yylval = strdup(str + 1);

    int length = sizeof(OP) / sizeof(OP[0]);
    for (int i = 0; i < length; i++) {
      if (strcmp(str, OP[i].value) == 0) {
        return OP[i].type;
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
  return yyparse ();
}