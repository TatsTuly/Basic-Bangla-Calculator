#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>     // For _dup, _dup2 functions
#include <math.h>   // For floor function

// Function prototypes from calculator.y
extern char* get_number_type(double num);
extern char* get_fraction_type(double num);

// Flex o Bison dwara generated function
extern int yyparse(void);
extern void yyerror(const char *s);
extern FILE* yyin;
extern void reset_expression(void);

// Itihas function
void display_history(void);

// Menu prodorshoner function
void display_menu(void);

// New function to process input based on menu choice
void process_input_by_choice(int choice);

int main(void) {
    int choice;
    char input[256];
    int width = 60; // Width for centering
    char line[61] = "------------------------------------------------------------";
    char welcome[] = "Bangla Calculator e Swagotom!";

    // Display centered welcome message
    printf("\n%*s\n", (width + strlen(line)) / 2, line);
    printf("%*s\n", (width + strlen(welcome)) / 2, welcome);
    printf("%*s\n", (width + strlen(line)) / 2, line);

    while (1) {
        display_menu();
        printf("\n%*s", (width - 45) / 2, "");
        printf("Apnar option nirbaochon korun (0 prosthan korte): ");
        if (scanf("%d", &choice) != 1) {
            while (getchar() != '\n'); // Input buffer porishkar kora
            printf("\n%*s", (width - 52) / 2, "");
            printf("Oboidho input. Anugraha kore ekti sonkha prodan korun.\n");
            continue;
        }

        while (getchar() != '\n'); // Input buffer porishkar kora

        if (choice == 0) {
            printf("\n%*s", (width - 30) / 2, "");
            printf("Prosthan kora hocche. Dhonnobad!\n");
            printf("%*s\n", (width + strlen(line)) / 2, line);
            break;
        } else if (choice == 8) {
            display_history();
            continue;
        }

        // Process input based on the selected menu option
        process_input_by_choice(choice);
    }

    return 0;
}

void process_input_by_choice(int choice) {
    char input[256];
    char processed_input[300];
    double number;
    char fraction[50];
    int width = 60; // Width for centering
    char line[61] = "------------------------------------------------------------";
    int suppress_folafol = 0; // Flag to control whether to suppress only "Folafol:" output
    FILE* modified_parsed_file = NULL; // For options 6 and 7 to capture modified parse output

    // Reset expression buffer before reading new input
    reset_expression();

    // Center the header for the selected operation
    printf("\n");
    
    switch(choice) {
        case 1:
            // Basic arithmetic - keep the original behavior
            printf("%*s", (width - 40) / 2, "");
            printf("Apnar gonit somossa likhun (Uda: 5 jog 3;): ");
            fgets(input, sizeof(input), stdin);
            strcpy(processed_input, input);
            break;
        
        case 2:
            // Square - borgo
            printf("%*s", (width - 18) / 2, "");
            printf("Ekti sonkha likhun: ");
            if (scanf("%lf", &number) != 1) {
                while (getchar() != '\n');
                printf("%*s", (width - 15) / 2, "");
                printf("Oboidho input.\n");
                return;
            }
            while (getchar() != '\n');
            sprintf(processed_input, "borgo(%g);", number);
            break;
        
        case 3:
            // Square root - borgomul
            printf("%*s", (width - 18) / 2, "");
            printf("Ekti sonkha likhun: ");
            if (scanf("%lf", &number) != 1) {
                while (getchar() != '\n');
                printf("%*s", (width - 15) / 2, "");
                printf("Oboidho input.\n");
                return;
            }
            while (getchar() != '\n');
            sprintf(processed_input, "borgomul(%g);", number);
            break;
        
        case 4:
            // Degree to radian
            printf("%*s", (width - 28) / 2, "");
            printf("Degrees e ekti sonkha likhun: ");
            if (scanf("%lf", &number) != 1) {
                while (getchar() != '\n');
                printf("%*s", (width - 15) / 2, "");
                printf("Oboidho input.\n");
                return;
            }
            while (getchar() != '\n');
            sprintf(processed_input, "radian(%g);", number);
            break;
        
        case 5:
            // Celsius to Fahrenheit
            printf("%*s", (width - 28) / 2, "");
            printf("Celsius e ekti sonkha likhun: ");
            if (scanf("%lf", &number) != 1) {
                while (getchar() != '\n');
                printf("%*s", (width - 15) / 2, "");
                printf("Oboidho input.\n");
                return;
            }
            while (getchar() != '\n');
            sprintf(processed_input, "fahrenheit(%g);", number);
            break;
        
        case 6:
            // Number type - kmn sonkh
            printf("%*s", (width - 18) / 2, "");
            printf("Ekti sonkha likhun: ");
            if (scanf("%lf", &number) != 1) {
                while (getchar() != '\n');
                printf("%*s", (width - 15) / 2, "");
                printf("Oboidho input.\n");
                return;
            }
            while (getchar() != '\n');
            sprintf(processed_input, "kmn sonkh(%g);", number);
            suppress_folafol = 1; // Suppress the "Folafol:" output
            break;
        
        case 7:
            // Fraction type - kmn bhognagsho
            printf("%*s", (width - 30) / 2, "");
            printf("Ekti bhognagsho likhun (Uda: 3/4): ");
            fgets(fraction, sizeof(fraction), stdin);
            // Remove newline if present
            size_t len = strlen(fraction);
            if (len > 0 && fraction[len-1] == '\n')
                fraction[len-1] = '\0';
            
            sprintf(processed_input, "kmn bhognagsho(%s);", fraction);
            suppress_folafol = 1; // Suppress the "Folafol:" output
            break;
        
        default:
            printf("%*s", (width - 15) / 2, "");
            printf("Oboidho option.\n");
            return;
    }
    
    // Create a temporary file for flex to read from
    FILE* temp = tmpfile();
    if (!temp) {
        printf("%*s", (width - 30) / 2, "");
        perror("Osthayi file toiri korte byartho");
        return;
    }
    
    fputs(processed_input, temp);
    rewind(temp);
    yyin = temp;
    
    // For option 6 and 7, capture output in a temporary file to filter out "Folafol:" line
    if (suppress_folafol) {
        // Create a temporary file to capture parser output
        modified_parsed_file = tmpfile();
        if (!modified_parsed_file) {
            suppress_folafol = 0; // Fall back to normal method if tmpfile fails
        } else {
            // Redirect stdout to our temporary file
            int old_stdout = _dup(fileno(stdout));
            freopen("NUL", "w", stdout); // First redirect to NUL to avoid displaying during parsing
            
            // Parse the input
            yyparse();
            
            // Restore stdout
            fflush(stdout);
            _dup2(old_stdout, fileno(stdout));
            _close(old_stdout);
            
            // Now we can manually display the appropriate results without "Folafol:" line
            if (choice == 6) {
                char* type = get_number_type(number);
                printf("Sonkha %g er dhoron: %s\n", number, type);
            } else if (choice == 7) {
                double fraction_value;
                // Try to parse the fraction (3/4, etc.)
                if (strchr(fraction, '/')) {
                    char *numerator_str = strtok(strdup(fraction), "/");
                    char *denominator_str = strtok(NULL, "/");
                    
                    if (numerator_str && denominator_str) {
                        int num = atoi(numerator_str);
                        int denom = atoi(denominator_str);
                        
                        if (denom != 0) {
                            fraction_value = (double)num / denom;
                            free(numerator_str);
                        } else {
                            printf("Bhagfol shunno hote pare na\n");
                            free(numerator_str);
                            fraction_value = 0;
                        }
                    } else {
                        fraction_value = atof(fraction);
                    }
                } else {
                    fraction_value = atof(fraction);
                }
                
                char* type = get_fraction_type(fraction_value);
                printf("%s\n", type);
            }
            fclose(modified_parsed_file);
        }
    } else {
        // Normal case for all other options (1-5)
        yyparse();
    }
    
    fclose(temp);
    
    // Add a separator line after the result
    printf("\n%*s\n", (width + strlen(line)) / 2, line);
}

void display_menu(void) {
    int width = 60; // Width for centering
    char line[61] = "------------------------------------------------------------";
    char title[] = "Bangla Calculator Menu";
    int leftMargin = 20; // Consistent left margin for all menu items
    
    printf("\n%*s\n", (width + strlen(line)) / 2, line);
    printf("%*s\n", (width + strlen(title)) / 2, title);
    printf("%*s\n\n", (width + strlen(line)) / 2, line);
    
    printf("%*s%s\n", leftMargin, "", "1. Ganitik operation (jog, biyog, gun, bhag)");
    printf("%*s%s\n", leftMargin, "", "2. Sonkha borgo");
    printf("%*s%s\n", leftMargin, "", "3. Sonkha borgomul");
    printf("%*s%s\n", leftMargin, "", "4. Degree theke radian");
    printf("%*s%s\n", leftMargin, "", "5. Celsius theke Fahrenheit");
    printf("%*s%s\n", leftMargin, "", "6. Sonkha dhoron (Jor/Bijor/Moulik sonkha)");
    printf("%*s%s\n", leftMargin, "", "7. Bhognagsho dhoron");
    printf("%*s%s\n", leftMargin, "", "8. Itihas prodorshon");
    printf("%*s%s\n", leftMargin, "", "0. Prosthan");
    
    printf("\n%*s\n", (width + strlen(line)) / 2, line);
}
