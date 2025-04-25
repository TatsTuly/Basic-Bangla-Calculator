%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define PI 3.14159265358979323846

void yyerror(const char *s);
int yylex(void);
extern char last_expression[];
void reset_expression(void);

// Function to check if a number is prime
int is_prime(int num) {
    if (num <= 1) return 0;  // Not prime
    if (num <= 3) return 1;  // 2 and 3 are prime
    
    // Check if divisible by 2 or 3
    if (num % 2 == 0 || num % 3 == 0) return 0;
    
    // Check for divisibility by numbers of form 6k ± 1
    for (int i = 5; i * i <= num; i += 6) {
        if (num % i == 0 || num % (i + 2) == 0) return 0;
    }
    
    return 1;  // Is prime
}

// Function to determine number type
char* get_number_type(double num) {
    static char result[100];
    
    // Initialize result
    strcpy(result, "");
    
    // Check if it's an integer
    int is_integer = (num == floor(num));
    
    // For real numbers (not complex), identify properties
    if (is_integer) {
        int n = (int)num;
        if (n % 2 == 0) {
            strcat(result, "Jor sonkha");
        } else {
            strcat(result, "Bijor sonkha");
        }
        
        // Check if it's prime
        if (is_prime(n)) {
            if (strlen(result) > 0) strcat(result, ", ");
            strcat(result, "Moulik sonkha");
        }
    } else {
        // It's a real number but not an integer
        strcat(result, "Bhognangsho sonkha");
    }
    
    return result;
}

// Function to identify fraction type
char* get_fraction_type(double num) {
    static char result[200];
    
    // Check if it's an integer (not a fraction)
    if (num == floor(num)) {
        strcpy(result, "Eta kono bhognangsho noy, eta ekti purno sonkha");
        return result;
    }
    
    // Attempt to find a "nice" fraction representation
    int num_int = 0;
    int denom_int = 0;
    double tolerance = 1e-10;
    
    // Try denominators up to 1000 for a close match
    for (int i = 1; i <= 1000; i++) {
        double numerator = num * i;
        double rounded_num = round(numerator);
        if (fabs(numerator - rounded_num) < tolerance) {
            num_int = (int)rounded_num;
            denom_int = i;
            break;
        }
    }
    
    // Determine fraction type based on fraction representation
    if (num_int != 0 && denom_int != 0) {
        // Get simple fraction by finding GCD
        int a = abs(num_int);
        int b = abs(denom_int);
        int temp;
        while (b) {
            temp = b;
            b = a % b;
            a = temp;
        }
        int gcd = a;
        
        int simplified_num = num_int / gcd;
        int simplified_denom = denom_int / gcd;
        
        sprintf(result, "Sonkha %d/%d (%.6g) er bhognangsho dhoron: ", 
                simplified_num, simplified_denom, num);
        
        if (abs(simplified_num) < simplified_denom) {
            strcat(result, "Prokrito bhognagsho");
        } else if (abs(simplified_num) > simplified_denom) {
            // Extract mixed number representation
            int whole_part = simplified_num / simplified_denom;
            int remainder = abs(simplified_num) % simplified_denom;
            
            if (remainder == 0) {
                strcat(result, "Eta kono bhognangsho noy, eta ekti purno sonkha");
            } else {
                char mixed_form[100];
                sprintf(mixed_form, " - Mixed form: %d %d/%d", 
                        whole_part, remainder, simplified_denom);
                
                strcat(result, "Oprokrito bhognagsho");
                strcat(result, mixed_form);
                
                // Add Missro bhognagsho for mixed fractions
                if (whole_part != 0 && remainder != 0) {
                    strcat(result, ", Missro bhognagsho");
                }
            }
        } else { // num == denom
            strcat(result, "Oprokrito bhognagsho - eta ekti purno sonkha 1");
        }
    } else {
        // Fallback to original function logic for non-representable fractions
        double intPart;
        double fracPart = modf(fabs(num), &intPart);
        
        if (intPart == 0) {
            strcpy(result, "Prokrito bhognagsho");
        } else if (fracPart == 0) {
            strcpy(result, "Eta kono bhognangsho noy, eta ekti purno sonkha");
        } else {
            strcpy(result, "Missro bhognagsho");
            
            // Also check if it's improper when expressed as a fraction
            if (fabs(num) > 1.0) {
                strcat(result, ", Oprokrito bhognagsho");
            }
        }
    }
    
    return result;
}

// Itihas function declaration
void add_to_history(const char* input, double result);
%}

%union {
    double dval;
    char* sval;
}

%token <dval> NUMBER
%token <sval> IDENTIFIER
%token ADD SUB MUL DIV SQUARE SQRT RADIAN FAHRENHEIT NUMBER_TYPE FRACTION_TYPE
%token ASSIGN LPAREN RPAREN LBRACE RBRACE SEMICOLON COMMA

%type <dval> expression term factor function_call

/* Define operator precedence and associativity */
%left ADD SUB
%left MUL DIV
%right UMINUS
%nonassoc SQUARE SQRT RADIAN FAHRENHEIT NUMBER_TYPE FRACTION_TYPE

%%

program:
    | program statement
    ;

statement:
    expression SEMICOLON {
        printf("Folafol: %lf\n", $1);
        // Use the stored expression instead of yytext
        add_to_history(last_expression, $1);
        reset_expression(); // Reset for next expression
    }
    ;

expression:
    term                           { $$ = $1; }
    | expression ADD term          { $$ = $1 + $3; }
    | expression SUB term          { $$ = $1 - $3; }
    ;

term:
    factor                         { $$ = $1; }
    | term MUL factor              { $$ = $1 * $3; }
    | term DIV factor              { 
                                     if ($3 == 0) {
                                         yyerror("Bhagfol shunno hote pare na");
                                         $$ = 0;
                                     } else {
                                         $$ = $1 / $3;
                                     }
                                   }
    ;

factor:
    NUMBER                         { $$ = $1; }
    | SUB factor %prec UMINUS      { $$ = -$2; }
    | LPAREN expression RPAREN     { $$ = $2; }
    | function_call                { $$ = $1; }
    ;

function_call:
    SQUARE LPAREN expression RPAREN { 
                                     $$ = $3 * $3; 
                                     printf("Borgo: %lf\n", $$);
                                   }
    | SQRT LPAREN expression RPAREN { 
                                     if ($3 < 0) {
                                         yyerror("Rinatmok sonkhar borgomul shombhob noy");
                                         $$ = 0;
                                     } else {
                                         $$ = sqrt($3);
                                         printf("Borgomul: %lf\n", $$);
                                     }
                                   }
    | RADIAN LPAREN expression RPAREN { 
                                     $$ = $3 * (PI / 180.0); 
                                     printf("Radian: %lf\n", $$);
                                   }
    | FAHRENHEIT LPAREN expression RPAREN { 
                                     $$ = ($3 * 9.0/5.0) + 32.0; 
                                     printf("Fahrenheit: %lf\n", $$);
                                   }
    | NUMBER_TYPE LPAREN expression RPAREN { 
                                     char* type = get_number_type($3);
                                     printf("Sonkha %g er dhoron: %s\n", $3, type);
                                     $$ = $3; // Return the original number
                                   }
    | FRACTION_TYPE LPAREN expression RPAREN { 
                                     char* type = get_fraction_type($3);
                                     // Don't show decimal value for fractions entered directly
                                     printf("%s\n", type);
                                     $$ = $3; // Return the original number
                                   }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parsing truti: %s\n", s);
}
