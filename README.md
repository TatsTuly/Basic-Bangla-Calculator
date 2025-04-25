# About
It's a basic bangla calculator project which is implemented using flex,bison and c language.It has the feature of basic calculator but implemented in bangla.It also have some unique feature for example: It can identify a fraction type,Number type which a basic calculator doesn't provide.It can be implemented as a basic compiler design project too.

# Run this Command :
bison -d calculator.y

flex calculator.l

gcc -o calculator main.c calculator.tab.c lex.yy.c history.c -lm -Wl,--allow-multiple-definition
