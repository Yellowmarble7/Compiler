
/* definitions */

%{
#include <stdio.h>
#include <stdlib.h>
#include "tokendef.h"

 /* integers to track line and column numbers */
int scancol = 1;
int yycol = 1;
int scanlineno = 1;
int yylineno = 1;

 /* char pointer to pass error messages to driver.c */
char *yyerror;

 /* TODO: functions to update line and column numbers */
void updateCol();
void countLines();

 /* TODO: function to process a string literal */
int processString();

%}

newline         (\r?\n) //minimal definitions for flex(for now)
whitespace      [ \t]+
integer         (0|[1-9][0-9]*)
character       \'(\\([nt"\\\'])|[^\\'\n])\'

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */

string       \"([^\"\n\\]|\\[nt"\\])*\"


 /* If the end quote is not found in the same line the string is unterminated */
untermstring    \"([^\"\n\\]|\\[nt"\\])*

comment         /\*([^*]|\*+[^*/])*\*/
multlncomment   //TODO
untermcomment   /\*([^*]|\*+[^*/])*$

identifier      [A-Za-z][A-Za-z0-9]*
illidentifier   [0-9][A-Za-z0-9]*



%%

 /* rules */

 /* Keywords */
 /* TODO: Support all keywords in mC */

 /* Operators */
 /* TODO: Support all operators in mC */

 /* Identifiers */;
{identifier}    //TODO
{illidentifier} //TODO

 /* Constants */;
{integer}       //TODO
{integerlead0}  //TODO: "Integers may not have leading zeros"
{character}     //TODO
{string}        {updateCol(); return processString();}
{untermstring}  {updateCol(); yyerror = "Unterminated string"; return ERROR;}

 /* Comments */
{comment}       //TODO
{untermcomment} //TODO
{multlncomment} //TODO

 /* Other */
{newline}       //TODO
{whitespace}    //TODO
.               {return ILLEGAL_TOK;}

%%

/* user routines */

/* TODO:
Implement this function to keep track of column numbers
*/
void updateCol(){
}

/* TODO:
Implement this function to keep track of line numbers
*/
void countLines(){
}


/* TODO:
Implement this function to
check for illegal escape sequences in string literals
and
convert valid escape sequences into escaped characters
(string[0] == '\\' and string[1] == 'n', then string[0] should be '\n')
*/
int processString(){
}
