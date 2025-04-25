%{
#include "calculator.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define PI 3.14159265358979323846

void yyerror(const char *s);
char last_expression[256] = "";  /* To store the complete expression */
%}

digit       [0-9]
letter      [a-zA-Z]
identifier  {letter}({letter}|{digit})*
fraction    {digit}+\/{digit}+

%%

"jog"           { strcat(last_expression, " jog "); return ADD; }
"biyog"         { strcat(last_expression, " biyog "); return SUB; }
"gun"           { strcat(last_expression, " gun "); return MUL; }
"bhag"          { strcat(last_expression, " bhag "); return DIV; }
"borgo"         { strcat(last_expression, " borgo"); return SQUARE; }
"borgomul"      { strcat(last_expression, " borgomul"); return SQRT; }
"radian"        { strcat(last_expression, " radian"); return RADIAN; }
"fahrenheit"    { strcat(last_expression, " fahrenheit"); return FAHRENHEIT; }
"kmn"[ ]+"sonkh" { strcat(last_expression, " kmn sonkh"); return NUMBER_TYPE; }
"kmn"[ ]+"bhognagsho" { strcat(last_expression, " kmn bhognagsho"); return FRACTION_TYPE; }
"="             { strcat(last_expression, "="); return ASSIGN; }
"("             { strcat(last_expression, "("); return LPAREN; }
")"             { strcat(last_expression, ")"); return RPAREN; }
"{"             { strcat(last_expression, "{"); return LBRACE; }
"}"             { strcat(last_expression, "}"); return RBRACE; }
";"             { strcat(last_expression, ";"); return SEMICOLON; }
","             { strcat(last_expression, ","); return COMMA; }

{fraction}      {
                    strcat(last_expression, yytext);
                    // Parse the fraction and convert to decimal
                    char *numerator_str = strtok(strdup(yytext), "/");
                    char *denominator_str = strtok(NULL, "/");
                    
                    if (numerator_str && denominator_str) {
                        int num = atoi(numerator_str);
                        int denom = atoi(denominator_str);
                        
                        if (denom != 0) {
                            yylval.dval = (double)num / denom;
                            free(numerator_str); // Free the duplicated string
                            return NUMBER;
                        } else {
                            yyerror("Bhagfol shunno hote pare na");
                            free(numerator_str); // Free the duplicated string
                            yylval.dval = 0;
                            return NUMBER;
                        }
                    }
                }

{identifier}    {
                    strcat(last_expression, yytext);
                    yylval.sval = strdup(yytext);
                    return IDENTIFIER;
                }

{digit}+\.{digit}*  {
                    strcat(last_expression, yytext);
                    yylval.dval = atof(yytext);
                    return NUMBER;
                }

{digit}+        {
                    strcat(last_expression, yytext);
                    yylval.dval = atof(yytext);
                    return NUMBER;
                }

[ \t\n]         { 
                    if (yytext[0] != '\n') 
                        strcat(last_expression, " "); 
                } // Whitespace upeksha kora hobe

.               { 
                    strcat(last_expression, yytext);
                    return yytext[0]; 
                }

%%

int yywrap(void) {
    return 1;
}

void reset_expression() {
    last_expression[0] = '\0';
}
