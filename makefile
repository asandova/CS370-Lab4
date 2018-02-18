all: Lab4

Lab4: YACC symtable.o
	gcc y.tab.c symtable.o -o lab4
YACC: LEX
	yacc -d lab2docalc.y
LEX: lab2docalc.l
	lex lab2docalc.l

symtable.o: symtable.c
	gcc -c symtable.c
