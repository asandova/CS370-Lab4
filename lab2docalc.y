%{

/*
 *			**** CALC ****
 *
 * This routine will function like a desk calculator
 * There are 26 integer registers, named 'a' thru 'z'
 *
 */

/* This calculator depends on a LEX description which outputs either VARIABLE or INTEGER.
   The return type via yylval is integer 

   When we need to make yylval more complicated, we need to define a pointer type for yylval 
   and to instruct YACC to use a new type so that we can pass back better values
 
   The registers are based on 0, so we substract 'a' from each single letter we get.

   based on context, we have YACC do the correct memmory look up or the storage depending
   on position

   Shaun Cooper
    January 2015

   problems  fix unary minus, fix parenthesis, add multiplication
   problems  make it so that verbose is on and off with an input argument instead of compiled in
*/


	/* begin specs */
#include <stdio.h>
#include <ctype.h>
#include "lex.yy.c"
//#include "symtable.c"
int regs[26];
int base, debugsw;
int dex = 0;
//int taddr;
void yyerror (s)  /* Called by yyparse on error */
     char *s;
{
  printf ("%s\n", s);
}


%}
/*  defines the start symbol, what values come back from LEX and how the operators are associated  */

%start program

%union{
 int value;
 char* string;
}

%token <value> INTEGER
%token <string> VARIABLE
%token INT
%type <value> expr stat

%left '|'
%left '&'
%left '+' '-'
%left '*' '/' '%'
%left UMINUS


%%	/* end specs, begin rules */

program : 	decls list
	;

decls	: 	/* empty */
	| 	decls dec 
	;

dec	:	INT VARIABLE ';' '\n'
		{
			if( Search($2) == -1 ){
				if(dex < 26){
					Insert($2,dex++);
				}else{
					fprintf(stderr,"Cannot enter Variable.\nReached maximum number of variables\n");	
				}
			}else{
				fprintf(stderr,"Variable already defined.\n");	
			}
	 	}	
	;

list	:	/* empty */
	|	list stat '\n'
	|	list error '\n'
			{ yyerrok; }
	;

stat	:	expr
			{ fprintf(stderr,"the anwser is %d\n", $1); }
	|	VARIABLE '=' expr
			{
				int taddr = Search($1);
				fprintf(stderr,"address %d\n", taddr);
				if(taddr != -1){
					fprintf(stderr,"assignment address %d\n", taddr);
					fprintf(stderr,"assignment value %d\n", $3);
					regs[taddr] = $3;
				}else{
					fprintf(stderr,"Variable \"%s\" has not been defined\nCannot be used", $1);
				}
			}
	;

expr	:	'(' expr ')'
			{ $$ = $2; }
	|	expr '-' expr
			{ $$ = $1 - $3; }
	|	expr '+' expr
			{ $$ = $1 + $3; }
	|	expr '/' expr
			{ $$ = $1 / $3; }
	|	expr '*' expr
			{ $$ = $1 * $3; }
	|	expr '%' expr
			{ $$ = $1 % $3; }
	|	expr '&' expr
			{ $$ = $1 & $3; }
	|	expr '|' expr
			{ $$ = $1 | $3; }
	|	'-' expr	%prec UMINUS
			{ $$ = -$2; }
	|	VARIABLE
			{ int taddr = Search($1);
				if(taddr != -1){
					$$ = regs[taddr]; fprintf(stderr,"found a variable value = %d\n",regs[taddr]);
				}
			}
	|	INTEGER { $$ = $1; }
	;



%%	/* end of rules, start of program */

main()
{ yyparse();
}
