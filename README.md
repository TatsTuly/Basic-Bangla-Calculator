# Run this Command :
bison -d calculator.y
flex calculator.l
gcc -o calculator main.c calculator.tab.c lex.yy.c history.c -lm -Wl,--allow-multiple-definition
