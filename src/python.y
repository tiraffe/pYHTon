%{
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string>
#include <iostream>

int yylex();
void yyerror (char const *);
#define YYSTYPE std::string

#define ECHO std::cout << yyval << std::endl

struct Token {
  std::string value;
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

program: lines ENDMARKER ;
lines: import_stmt NEWLINE | lines import_stmt NEWLINE ;

import_stmt
  : import_name {ECHO;}
  | import_from {ECHO;}
  ; 

import_name
  : IMPORT dotted_as_names  {$$ = "(Import " + $2 + ")";}
  ;

dotted_as_names
  : dotted_as_name                      {$$ = $1;}
  | dotted_as_names ',' dotted_as_name  {$$ = $1 + " " + $3;}
  ;

dotted_name
  : NAME                    {$$ = $1;}
  | dotted_name '.' NAME    {$$ = $1 + $2 + $3; }
  ;

dotted_as_name
  : dotted_name             {$$ = "[" + $1 + " #f]";}          
  | dotted_name AS NAME     {$$ = "[" + $1 + " " + $3 + "]";}
  ;

dot_puls
  : '.'           {$$ = $1; } 
  | dot_puls '.'  {$$ = $1 + $2; } 
  ; 

dot_star
  : /* empty */   {$$ = ""; } 
  | dot_puls      {$$ = $1; } 
  ;

import_as_name
  : NAME          {$$ = "[" + $1 + " #f]"; }
  | NAME AS NAME  {$$ = "[" + $1 + " " + $3 + "]"; }
  ;

import_as_names
  : import_as_name                      {$$ = $1; }
  | import_as_names ',' import_as_name  {$$ = $1 + " " + $3; }
  ;

import_after_from
  : IMPORT '*'                      {$$ = "(names [* #f])";}
  | IMPORT '(' import_as_names ')'  {$$ = "(names " + $3 + ")";}
  | IMPORT import_as_names          {$$ = "(names " + $2 + ")";}
  ;

import_from
  : FROM dot_star dotted_name import_after_from {
    $$ = "(ImportFrom"; 
    $$ += " (module " + $3 + ")";
    $$ += " " + $4;
    $$ += " (level " + std::to_string($2.size()) + ")";
    $$ += ")";
  }
  | FROM dot_puls import_after_from {
    $$ = "(ImportFrom"; 
    $$ += " (module #f)";
    $$ += " " + $3;
    $$ += " (level " + std::to_string($2.size()) + ")";
    $$ += ")";
  }
  ;

// comp_op: '<' | '>' | EQ_OP | NE_OP | LE_OP | GE_OP | IN | NOT IN | IS | IS NOT ;

%%

void yyerror (char const *s) {
  fprintf (stderr, "%s\n", s);
}

int yylex() {
  std::string type, str;
  std::cin >> type;

  if (std::cin.eof()) {
    return 0;
  }

  if (type == "(NEWLINE)") {
    return NEWLINE;
  } else if (type == "(INDENT)") {
    return INDENT;
  } else if (type == "(DEDENT)") {
    return DEDENT;
  } else if (type == "(ENDMARKER)") {
    return ENDMARKER;
  } else if (type == "(LIT") {
    std::cin >> str;
    yylval = str.substr(0, str.size() - 1);

    if (str[0] == '\"') {
      return STRING;
    } else {
      return NUMBER;
    }
  } else if (type == "(ID") {
    std::cin >> str;
    yylval = str.substr(1, str.size() - 3);

    return NAME;
  } else if (type == "(KEYWORD") {
    std::cin >> str;
    yylval = str.substr(0, str.size() - 1);

    int length = sizeof(KEYWORD) / sizeof(KEYWORD[0]);
    for (int i = 0; i < length; i++) {
      if (yylval == KEYWORD[i].value) {
        return KEYWORD[i].type;
      }
    }
  } else if (type == "(PUNCT") {
    std::cin >> str;
    yylval = str.substr(1, str.size() - 3);

    if (yylval.size() == 1) {
      // single-char operator
      return yylval[0];
    } else {
      // multi-char operator
      int length = sizeof(OP) / sizeof(OP[0]);
      for (int i = 0; i < length; i++) {
        if (yylval == OP[i].value) {
          return OP[i].type;
        }
      }
    }
  } else {
    std::cout << "UNKNOWN TYPE: " << type << ", " << str << std::endl;
    return -1;
  }
  
  std::cout << "ERROR TOKEN: " << type << ", " << str << std::endl;
  return -1;
}

int main() {
  return yyparse ();
}