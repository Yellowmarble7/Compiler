
/* definitions */

%{
#include <stdio.h>
#include <stdlib.h>
#string <string.h>
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

newline         (\r?\n) /*minimal definitions for flex(for now)*/
whitespace      [ \t]+
integer         (0|[1-9][0-9]*)
character       \'(\\([nt"\\\'])|[^\\'\n])\'

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */

string       \"([^\"\n\\]|\\[nt"\\])*\"


 /* If the end quote is not found in the same line the string is unterminated */
untermstring    \"([^\"\n\\]|\\[nt"\\])*

comment         /\*([^*]|\*+[^*/])*\*/
multlncomment   /\*([^*]|\*+[^*/])*\*/
untermcomment   /\*([^*]|\*+[^*/])*$

identifier      [A-Za-z][A-Za-z0-9]*
illidentifier   [0-9][A-Za-z0-9]*



%%

 /* rules */

 /* Keywords */
 /* TODO: Support all keywords in mC */
 "if" {updateCol();
 return KWD_IF;}

 "else" {
    updateCol();
    return KWD_ELSE;
 }

 "while" {
    updateCol();
    return KWD_WHILE;
 }

 "int" {
    updateCol();
    return KWD_INT;
 }

 "string" {
    updateCol();
    return KWD_STRING;
 }

 "char" {
    updateCol();
    return KWD_CHAR;
 }

"return" {
    updateCol();
    return KWD_RETURN;
}

"void"{
    updateCol();
    return KWD_VOID;
}

 /* Operators */
 /* TODO: Support all operators in mC */

 /* Identifiers */;
{identifier}    {
    updateCol();
    return ID;
}

{illidentifier} {
    updateCol();
    return ILLEGAL_TOK;
}

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
    yycol += yyleng;
    scancol = yycol; /*keeping track of column numbers */
}

/* TODO:
Implement this function to keep track of line numbers
*/
void countLines(){
    yylineno += 1;
    yycol = 1; /* reset to newline each time and keep track */
}


/* TODO:
Implement this function to
check for illegal escape sequences in string literals
and
convert valid escape sequences into escaped characters
(string[0] == '\\' and string[1] == 'n', then string[0] should be '\n')
*/
int processString(){
    int len = yyleng;
    if (len < 2) {
        yyerror = "Unterminated string";
        return ERROR;
    }
        char *in = yytext +1;
        int in_len =len -2;
        char *out = (char *)malloc(in_len +2);

        if (!out) {
            yyerror = "In error";
            return ERROR;
        }

        int i=0;
        int j=0;

        while(i < in_len){
            if (in[i] == '\\'){
                if (i+1 >= in_len){
                    free(out);
                    yyerror = "Unterminated string";
                    return ERROR;
                                }
                char esc = in[i+1];
                if(esc == 'n'){
                    out[j++] = '\n';
                } else if (esc == 't'){
                    out[j++] = '\t';
                } else if (esc == '"') {
                    out[j++] = '"';
                } else if (esc == '\\'){
                    out[j++] = '\\';
                } else {
                    free(out);
                    yyerror = "Unrecognized escape char in string";
                    return ERROR;
                }
                i +=2;
            } else {
                out[j++] = in[i++];
            }
        }
out [j]= '\0';
char *newstr = strdup(out);
free(out);
yytext = newstr;
 yycol += yyleng;
 scancol = yycol;

 return STRCONST;
    
}

