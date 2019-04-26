%{
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#define MAX_DEPTH 72

int nesting = 0;
unsigned int indent_stack[MAX_DEPTH];
unsigned int level = 0;

unsigned int first = 1;

void process_indent(char* line);

#define NEWLINE {printf("(NEWLINE)\n");}
#define INDENT {printf("(INDENT)\n");}
#define DEDENT {printf("(DEDENT)\n");}
#define LIT {printf("(LIT "); ECHO; printf(")\n");}
#define KEYWORD {printf("(KEYWORD "); ECHO; printf(")\n");}
#define ID {printf("(ID \""); ECHO; printf("\")\n");}
#define PUNCT {printf("(PUNCT \""); ECHO; printf("\")\n");}

%}

PUNCT [-+*/=<>:^&|%!]*
ID  [A-Za-z_][A-Za-z0-9_]*
INT [0-9]+
STRING \"([^\\\"]|\\.|\\\n)*\"
KEYWORD False|await|else|import|pass|None|break|except|in|raise|True|class|finally|is|return|and|continue|for|lambda|try|as|def|from|nonlocal|while|assert|del|global|not|with|async|elif|if|or|yield

%option noyywrap
%x INSTRING INCOMMENT

%%

{PUNCT} {PUNCT;}
{KEYWORD} {KEYWORD;}
{STRING}|{INT} {LIT;}
{ID} {ID;}

[ ]*#.*\n     {/* Ignore comments. */}
^[ ]*\n       {/* Ignore blank lines. */}
^[ ]*[^ \n]+  {int last = yyleng - 1;
               process_indent(yytext);
               while ((last >= 0) &&
                      (yytext[last] != ' ')) {
                unput(yytext[last]);
                last--;}}

"\\\n" {}
"\n" {NEWLINE;}
"("  {PUNCT; nesting++; }
")"  {PUNCT; nesting--; }

[ \t\r]   {/* Ignore blank */}

. {ECHO;}
<<EOF>>  { process_indent(""); printf("(ENDMARKER)"); return 0; }


%%

unsigned int white_count(char* line) {
  unsigned int count = 0;
  while (*line == ' ')
    count++, line++;
  return count;
}

void process_indent(char* line) {
  if (nesting)
    /* Ignore indents while nested. */
    return;

  unsigned int indent = white_count(line);

  if (indent == indent_stack[level]) {
    // if (!first) printf(";");
    first = 0;
    return;
  }

  if (indent > indent_stack[level]) {
    INDENT;
    assert(level+1 < MAX_DEPTH);
    indent_stack[++level] = indent;
    return;
  }

  while (indent < indent_stack[level]) {
    --level;
    DEDENT;
  }

  assert(level >= 0);
}

int main(int argc, char* argv[]) {
  indent_stack[0] = 0;
  yylex();
  printf("\n");
}
