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

 /* TODO: functions to update line and column numbers */
void updateCol();
void countLines();

 /* TODO: function to process a string literal */
int processString();

%}

/* MAGDALENA Handle newlines */
newline        \n 
whitespace     [ \t]+
/* PLACEHOLDER change below the integerlead0 integer and character*/ 
integerlead0    0[0-9]+
integer         [0-9]+
character       '.'

 /* String can contain any characters between the double quotes */
 /* other than a newline or unescaped doublequotes */
 /* MAGDALENA TODO string can contain any character except backlash or newline,
  accepts valid escape sequences, allows zero or more of these characters inside */


string          \"([^\\\n]|\\[nt\"\\])*\"


 /* If the end quote is not found in the same line the string is unterminated */
untermstring    \"([^\\\n]|\\[nt\"\\])*

comment         \/\\*([^*]|\*+[^*/])*\*+\/
untermcomment   \/\\*([^*]|\*+[^*/])*

/* PLACEHOLDER change below the identifier and illidentifier */
/* PLACEHOLDER ILLIDENTIFIER TODO: regular expression for an illegal identifier */

identifier      [a-zA-Z_][a-zA-Z0-9_]*



%%

 /* rules */

 /* Keywords */
 /* TODO: Support all keywords in mC */

 /* Operators */
 /* TODO: Support all operators in mC */

 /* PLACEHOLDERS CHANGE IDENTIFIER AND ILLIDENTIFIER Identifiers */
{identifier}    { updateCol(); return IDENTIFIER; }


 /* PLACEHOLDERS CHANGE INTEGER INTEGERLEAD AND CHARACTER Constants */
{character}     { updateCol(); return CHARACTER; }
{integerlead0}  { updateCol(); return INTEGERLEAD0; } 
{integer}       { updateCol(); return INTEGER; } 


 /* MAGDALENA string rules */
{string}        {updateCol(); return processString();}
{untermstring}  {updateCol(); yyerror = "Unterminated string"; return ERROR;}

 /* MAGDALENA Comments */
{comment}       { updateCol(); }
{untermcomment} { yyerror = "Unterminated comment"; return ERROR;}

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
    yytext = result; //replace yytext
    return STRCONST;
}

int yywrap(void) {
    return 1;
}