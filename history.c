#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void add_to_history(const char* input, double result) {
    FILE *fp = fopen("history.txt", "a");
    if (fp == NULL) {
        perror("Itihas file khulte byartho");
        return;
    }
    
    // Tarikh o somoy sonjojon
    time_t now = time(NULL);
    char time_str[30];
    strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", localtime(&now));
    
    fprintf(fp, "[%s] %s = %lf\n", time_str, input, result);
    fclose(fp);
}

void display_history(void) {
    FILE *fp = fopen("history.txt", "r");
    if (fp == NULL) {
        printf("Kono itihas paoa jaini!\n");
        return;
    }
    
    char line[256];
    int count = 0;
    
    printf("\nCalculator Itihas:\n");
    printf("-------------------\n");
    
    while (fgets(line, sizeof(line), fp) != NULL) {
        printf("%s", line);
        count++;
    }
    
    if (count == 0) {
        printf("Kono itihas nei!\n");
    }
    
    fclose(fp);
}
