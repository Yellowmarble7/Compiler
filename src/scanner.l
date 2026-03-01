/* for flex purposes */
%option yylineno

/* definitions */

%{
#include <stdio.h>
#include <stdlib.h>
#include "tokendef.h"

 /* integers to track line and column numbers */
int yycol = 1;

 /* char pointer to pass error messages to driver.c */
char *yyerror;

/* start column of token for printing in driver.c */
int startCol;

 /* declaration of functions to update line and column numbers */
void updateCol();
void countLines();

 /* declaration of function to process a string literal */
int processString();

extern YYSTYPE yylval;

%}

/* MAGDALENA Handle newlines */
newline        \n 
whitespace     [ \t]+


integerlead0    0[0-9]+
integer         0|[1-9][0-9]*
character       \'[^'\n]\'

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */
 /* MAGDALENA TODO string can contain any character except backlash or newline,
  accepts valid escape sequences, allows zero or more of these characters inside */


string          \"([^\\\n]|\\[nt\"\\])*\"


 /* If the end quote is not found in the same line the string is unterminated */
untermstring    \"([^\\\n]|\\.)*


comment         /\*([^*]|\*+[^*/])*\*/

untermcomment   /\*([^*]|\*+[^*/])* 

/* ILLIDENTIFIER TODO: regular expression for an illegal identifier */

identifier      [a-zA-Z][a-zA-Z0-9]*
illidentifier   [0-9][A-Za-z0-9]*



%%

 /* rules */



 /* Keywords */
 /* TODO: Support all keywords in mC */
"if"      { startCol = yycol; updateCol(); return KWD_IF; }
"else"    { startCol = yycol; updateCol(); return KWD_ELSE; }
"while"   { startCol = yycol; updateCol(); return KWD_WHILE; }
"int"     { startCol = yycol; updateCol(); return KWD_INT; }
"string"  { startCol = yycol; updateCol(); return KWD_STRING; }
"char"    { startCol = yycol; updateCol(); return KWD_CHAR; }
"return"  { startCol = yycol; updateCol(); return KWD_RETURN; }
"void"    { startCol = yycol; updateCol(); return KWD_VOID; }
 


 /* Operators */
 /* TODO: Support all operators in mC */

 /* multi-characters operators */
"++"    { startCol = yycol; updateCol(); return OPER_INC; }
"--"    { startCol = yycol; updateCol(); return OPER_DEC; }
"&&"    { startCol = yycol; updateCol(); return OPER_AND; }
"||"    { startCol = yycol; updateCol(); return OPER_OR; }
"<="    { startCol = yycol; updateCol(); return OPER_LTE; }
">="    { startCol = yycol; updateCol(); return OPER_GTE; }
"=="    { startCol = yycol; updateCol(); return OPER_EQ; }
"!="    { startCol = yycol; updateCol(); return OPER_NEQ; }

 /* single-character operators */
"="     { startCol = yycol; updateCol(); return OPER_ASGN; }
"+"     { startCol = yycol; updateCol(); return OPER_ADD; }
"-"     { startCol = yycol; updateCol(); return OPER_SUB; }
"*"     { startCol = yycol; updateCol(); return OPER_MUL; }
"/"     { startCol = yycol; updateCol(); return OPER_DIV; }
"%"     { startCol = yycol; updateCol(); return OPER_MOD; }
"<"     { startCol = yycol; updateCol(); return OPER_LT; }
">"     { startCol = yycol; updateCol(); return OPER_GT; }
"!"     { startCol = yycol; updateCol(); return OPER_NOT; }
"@"     { startCol = yycol; updateCol(); return OPER_AT; }

 /* Other punctuation */
"\["    { startCol = yycol; updateCol(); return LSQ_BRKT; }
"\]"    { startCol = yycol; updateCol(); return RSQ_BRKT; }
"\{"    { startCol = yycol; updateCol(); return LCRLY_BRKT; }
"\}"    { startCol = yycol; updateCol(); return RCRLY_BRKT; }
"\("    { startCol = yycol; updateCol(); return LPAREN; }
"\)"    { startCol = yycol; updateCol(); return RPAREN; }
","     { startCol = yycol; updateCol(); return COMMA; }
";"     { startCol = yycol; updateCol(); return SEMICLN; }

 /* comments */
 /* MAGDALENA Comments */
{comment}       { updateCol(); }
{untermcomment} { startCol = yycol; yyerror = "Unterminated comment"; return ERROR; }


 /* Constants */
{integerlead0}  { startCol = yycol; updateCol(); yyerror = "Integer cannot start with 0"; return ILLEGAL_TOK; }
{integer}       { startCol = yycol; updateCol(); yylval.intVal = atoi(yytext); return INTCONST; }
{character}     { startCol = yycol; updateCol(); yylval.charVal = yytext[1]; return CHARCONST; }


 /* identifiers */
{identifier}    { startCol = yycol; updateCol(); yylval.strVal = strdup(yytext); return ID; }
{illidentifier} { startCol = yycol; updateCol(); yyerror = "Illegal Identifier"; return ILLEGAL_TOK; }


 /* MAGDALENA string rules */
{string}        { startCol = yycol; updateCol(); return processString(); }
{untermstring}  { startCol = yycol; yyerror = "Unterminated string constant"; return ERROR; }



 /* MAGDALENA Other */
{newline}       { countLines(); }
{whitespace}    { updateCol(); }

 /* illegal token */
.               { startCol = yycol; yyerror = "Illegal token"; updateCol(); return ERROR; }

%%

/* user routines */

/* MAGDALENA
TODO:
Implement this function to keep track of column numbers
*/
void updateCol() { yycol += yyleng; }

/* MAGDALENA 
TODO:
Implement this function to keep track of line numbers
Basically moves to the next line and resets the column to the start of the line
*/
void countLines() { yylineno++; yycol = 1; }


/* MAGDALENA TODO:
Implement this function to
check for illegal escape sequences in string literals
and
convert valid escape sequences into escaped characters
(string[0] == '\\' and string[1] == 'n', then string[0] should be '\n')
*/
int processString(){
    char *result = malloc(yyleng - 1);
    //error message
    if (!result) { yyerror = "Memory allocation failed"; return ERROR; }

    //two integer variables for the loop and for the output string
    int i; //will be set by the for loop
    int j = 0; //index for the new processed string

    //skips the starting (i=1;) and ending quotes (i < yyleng - 1;)
    for ( i = 1; i < yyleng - 1; i++){
        //handling the escape sequence
        if (yytext[i] == '\\'){
            i++; //moves to the character after the backlash

            switch (yytext[i]){
                case 'n': result[j++] = '\n'; break;
                case 't': result[j++] = '\t'; break;
                case '"': result[j++] = '"'; break;
                case '\\': result[j++] = '\\'; break;
                default:
                    free(result); 
                    yyerror = "Unrecognized escape character in String";
                    return ERROR;
            }
        } 
        else {
            /* copies a normal character (not part of the escape sequence)
            from the original string into the processed string */
            result[j++] = yytext[i];
        }
    }

    result[j] = '\0'; //null
    yylval.strVal = result; 
    return STRCONST;
}

int yywrap() { return 1; }