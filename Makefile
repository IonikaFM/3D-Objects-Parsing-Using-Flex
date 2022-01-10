#Grosu Ioana Alexandra 335CC

build: tema.l
	flex tema.l && g++ -std=c++11 -DDEBUG lex.yy.c -o out -DDEBUG_COLOR
run: out
	./out in1 in2 in3 in4
clean: out lex.yy.c
	rm -rf out lex.yy.c
