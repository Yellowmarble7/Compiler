/* definitions */

%{
#include <stdio.h>
#include <stdlib.h>
#include "tokendef.h"

 /* integers to track line and column numbers */
int scancol = 1;
int yycol = 1;
/* MAGDALENA replaced int scanlineno = 1; with int yylineno = 1; */
/* int yylineno = 1; */

 /* char pointer to pass error messages to driver.c */
char *yyerror;

 /* declaration of functions to update line and column numbers */
void updateCol();
void countLines();

 /* declaration of function to process a string literal */
int processString();

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
untermstring    \"([^\\\n]|\\[nt\"\\])*

comment         \/\*([^*]|\*+[^*/])*\*+\/
 /* multlncomment  */
untermcomment   \/\*([^*]|\*+[^*/])*


/* ILLIDENTIFIER TODO: regular expression for an illegal identifier */

identifier      [a-zA-Z][a-zA-Z0-9]*
illidentifier   [0-9][A-Za-z0-9]*



%%

 /* rules */

 /* Keywords */
 /* TODO: Support all keywords in mC */
"if"      { updateCol(); return KWD_IF; }
"else"    { updateCol(); return KWD_ELSE; }
"while"   { updateCol(); return KWD_WHILE; }
"int"     { updateCol(); return KWD_INT; }
"string"  { updateCol(); return KWD_STRING; }
"char"    { updateCol(); return KWD_CHAR; }
"return"  { updateCol(); return KWD_RETURN; }
"void"    { updateCol(); return KWD_VOID; }
 

 /* Operators */
 /* TODO: Support all operators in mC */

 /* multi-characters operators */
"++"    { updateCol(); return OPER_INC; }
"--"    { updateCol(); return OPER_DEC; }
"&&"    { updateCol(); return OPER_AND; }
"||"    { updateCol(); return OPER_OR; }
"<="    { updateCol(); return OPER_LTE; }
">="    { updateCol(); return OPER_GTE; }
"=="    { updateCol(); return OPER_EQ; }
"!="    { updateCol(); return OPER_NEQ; }

 /* single-character operators */
"="     { updateCol(); return OPER_ASGN; }
"+"     { updateCol(); return OPER_ADD; }
"-"     { updateCol(); return OPER_SUB; }
"*"     { updateCol(); return OPER_MUL; }
"/"     { updateCol(); return OPER_DIV; }
"%"     { updateCol(); return OPER_MOD; }
"<"     { updateCol(); return OPER_LT; }
">"     { updateCol(); return OPER_GT; }
"!"     { updateCol(); return OPER_NOT; }
"@"     { updateCol(); return AT; }

 /* Other punctuation */
"\["    { updateCol(); return LSQ_BRKT; }
"\]"    { updateCol(); return RSQ_BRKT; }
"\{"    { updateCol(); return LCRLY_BRKT; }
"\}"    { updateCol(); return RCRLY_BRKT; }
"\("    { updateCol(); return LPAREN; }
"\)"    { updateCol(); return RPAREN; }
","     { updateCol(); return COMMA; }
";"     { updateCol(); return SEMICLN; }

 /* Constants */
{integerlead0}  { updateCol(); yyerror = "Integer cannot start with 0"; return ILLEGAL_TOK; }
{integer}       { updateCol(); return INTCONST; }
{character}     { updateCol(); return CHARCONST; }

 /* MAGDALENA Comments */
{comment}       { updateCol(); }
{untermcomment} { yyerror = "Unterminated comment"; return ERROR;} 

 /* identifiers */
{identifier}    { updateCol(); return IDENTIFIER; }
{illidentifier} { updateCol(); yyerror = "Illegal Identifier"; return ILLEGAL_TOK; }


 /* MAGDALENA string rules */
{string}        {updateCol(); return processString();}
{untermstring}  {updateCol(); yyerror = "Unterminated string"; return ERROR;}




 /* MAGDALENA Other */
{newline}       { countLines(); }
{whitespace}    { updateCol(); } 
.               {return ILLEGAL_TOK;}

%%

/* user routines */

/* MAGDALENA
TODO:
Implement this function to keep track of column numbers
*/
void updateCol(){
    yycol += yyleng;
}

/* MAGDALENA 
TODO:
Implement this function to keep track of line numbers
Basically moves to the next line and resets the column to the start of the line
*/
void countLines(){
    yylineno++;
    yycol = 1; 
}


/* MAGDALENA TODO:
Implement this function to
check for illegal escape sequences in string literals
and
convert valid escape sequences into escaped characters
(string[0] == '\\' and string[1] == 'n', then string[0] should be '\n')
*/
int processString(){
    //malloc(yyleng + 1) to prevent possible memory overwrite
    // need space for the null terminator
    char *result = malloc(yyleng + 1);
    //error message
    if (!result){
        yyerror = "Memory allocation failed for processed string";
        return ERROR;
    }

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
                    yyerror = "Unrecognized escape character in String";
                    free(result); //avoid memory leaks with the use of malloc()
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
    // yytext = result; 
    return STRCONST;
}

int yywrap(void) {
    return 1;
}