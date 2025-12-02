%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "prac_parser.tab.h"

extern int lineNumber;
%}

%option noyywrap

digit [0-9]
letter [a-zA-Z_]
num {digit}+
id {letter}({letter}|{digit})*

%%

"if"        {printf("TOKEN: IF\n"); return IF;}
"goto"      {printf("TOKEN: GOTO\n"); return GOTO;}
"="         {printf("TOKEN: ASSIGN\n"); return ASSIGN;}
"<="        {printf("TOKEN: LE\n"); return LE;}
">="        {printf("TOKEN: GE\n"); return GE;}
"=="        {printf("TOKEN: EQ\n"); return EQ;}
"!="        {printf("TOKEN: NE\n"); return NE;}
"<"         {printf("TOKEN: LT\n"); return LT;}
">"         {printf("TOKEN: GT\n"); return GT;}
"+"         {printf("TOKEN: PLUS\n"); return PLUS;}
"-"         {printf("TOKEN: MINUS\n"); return MINUS;}
"*"         {printf("TOKEN: MUL\n"); return MUL;}
"/"         {printf("TOKEN: DIV\n"); return DIV;}
";"         {printf("TOKEN: SEMI\n"); return SEMI;}
":"         {printf("TOKEN: COLON\n"); return COLON;}
"("         {printf("TOKEN: LPAREN\n"); return LPAREN;}
")"         {printf("TOKEN: RPAREN\n"); return RPAREN;}
"{"         {printf("TOKEN: LBRACE\n"); return LBRACE;}
"}"         {printf("TOKEN: RBRACE\n"); return RBRACE;}

{id}        {printf("TOKEN: ID (%s)\n", yytext); yylval.sval = strdup(yytext); return ID;}
{num}       {printf("TOKEN: NUM (%s)\n", yytext); yylval.sval = strdup(yytext); return NUM;}

[ \t\r]+    { /* skip whitespace */ }
\n          {printf("TOKEN: NEWLINE (line %d)\n", lineNumber); lineNumber++;}

.           {printf("ERROR: Unmatched Character: '%s' (ASCII %d)\n", yytext, yytext[0]);}

%%
