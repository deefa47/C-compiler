%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "semantic.h"
#include "icg.h"

int icg=1;
%}

%start START_CFG
%token Void Char Int Float
%token ID Const FloatConst 
%token Str SizeOf Character
%token If Else While Do For 
%token Continue Break Return
%token PlusPlus MinusMinus LessEqual 
%token GreaterEqual EqualEqual NotEqual 
%token AndAnd OrOr
%token Printf Scanf Typedef Extern


%%
START_CFG	: Global_outside | START_CFG Global_outside ;
Global_outside	: definingfuncblock {strcpy(currentparentfunction,"GLOBAL");} | decl ;
BasicIdorConst : ID	{$$=Id_verify(); if(icg==1){push(currentlexval);}} | FloatConst {floatcheck=4; } 
					| Const {if(icg==1){push(currentCons);}} | Str | '(' exp ')' {$$= $2;} ;

stmt : cstmt | expstmt | Ifcondition | WhileandForLoops | controljumps ;

cstmt : '{' '}' | '{' stmts '}' ;
declist : decl | declist decl ;
stmtlist : stmt | stmtlist stmt ;
expstmt : ';' {icg=0;} | exp ';' {icg=0;};
stmts : stmtlist | Decc ;
Decc : declist | declist stmtlist ;

Ifcondition	: If '(' exp ')' {condition_if();} stmt ELSE {ending_if();} ;

ELSE : Else {inside_else();} stmt | ;

WhileandForLoops	: While {before_while();} '(' exp ')'{condition_while();} stmt {ending_while();} | Do {start_dowhile();} stmt While '(' exp ')' ';' {ending_dowhile();} | ForLoop ;

ForLoop :  For '(' expstmt {initial_for();} expstmt {condition_for();} exp {increment_for();}')' stmt {inside_for();} ;

controljumps	: Continue ';'| Break ';'| ReturnStmt;

ReturnStmt	: Return ';'| Return exp ';';

definingfuncblock
	: typespecs varnames declist {printf("function BEGIN %s\n",currentparentfunction);} cstmt	{printf("function END \n");} 
	| typespecs varnames {printf("function BEGIN %s\n",currentparentfunction);} cstmt	{printf("function END \n");} ;

Basicexp	: BasicIdorConst	{$$=$1;icg=1;}	| Basicexp {icg=1;}'[' exp ']' {array_expression_code();}				 	| functioncall	| incrdecr ;
incrdecr : Basicexp PlusPlus {pop();push(currentlexval); push("+"); push("1"); incremen_expression_code();} | Basicexp MinusMinus {push("-");push("1");incremen_expression_code();};	
functioncall : Basicexp '(' ')'	| Basicexp '(' args ')' ;
args	: equaltoexp	| args ',' equaltoexp	;
unexp	: Basicexp	{$$=$1;}
	| PlusPlus unexp {push("+");push("1");incremen_expression_code();}| MinusMinus unexp {push("-"); push("1"); incremen_expression_code();}
	| unop typecast {unary_expression_code();}| SizeOf unexp | SizeOf '(' datatypes ')' ;

unop : '&' {push("&");}| '*' {push("*");}| '+' {push("+");}| '-' {push("-");}| '~' {push("~");}| '!' {push("!");};
typecast	: unexp	{$$=$1;}	| '(' datatypes ')' typecast ;

Fpo	: typecast	{$$=$1;} | Fpo op typecast {expression_code();} ;
op : '*' {push("*");}| '/' {push("/");}| '%' {push("%");};

Spo	: Fpo	{$$=$1;} | Spo PlusMinus Fpo {expression_code();};
PlusMinus : '+' {push("+");}| '-' {push("-");};

Tpo	: Spo	{$$=$1;}	| Tpo {icg=1;} RelationOp Spo	{typemismatch($1,$3);expression_code();} ;
RelationOp : '<' {push("<");}| '>' {push(">");}| LessEqual {push("<=");}| GreaterEqual {push(">=");};

Fourpo	: Tpo	{$$=$1;}	| Fourpo EqNotEq Tpo	{typemismatch($1,$3);expression_code();} ;
EqNotEq : EqualEqual {push("==");}| NotEqual {push("!=");};

Fivepo : Fourpo	{$$=$1;}| Fivepo bitwiseOp Fourpo {expression_code();};
bitwiseOp : '&' {push("&");}| '^' {push("^");}| '|' {push("|");};

Sixpo : Fivepo	{$$=$1;}| Sixpo logicalOp Fivepo {expression_code();};
logicalOp : AndAnd {push("&&");}| OrOr {push("||");};

Ternary : Sixpo	{$$=$1;} | Sixpo '?' exp ':' Ternary;

equaltoexp : Ternary	{$$=$1;} | unexp {push(currentlexval);icg=1;} '='{push("=");} equaltoexp	{ 							$$=$3; typemismatch($1,$3); equalto_expression_code();};


exp : equaltoexp	{$$=$1;} | exp ',' equaltoexp;
decl : typespecs ';' | typespecs varlist ';' ;
typespecs	: typedeforextern | typedeforextern typespecs
	| datatypes | datatypes typespecs ;
varlist : Declarations	| varlist ',' Declarations;
Declarations : varnames | varnames {push(currentlexval);icg=1;} '=' {push("=");} equaltoexp  {equalto_expression_code();};
typedeforextern	: Typedef | Extern;
datatypes	: Void	{typevalue=1;} | Char	{typevalue=2;} | Int	{typevalue=3;} | Float	{typevalue=4;};

varnames	: ID	{addId();}	| '(' varnames ')'	| arrays 
	| varnames {strcpy(currentparentfunction,currentlexval);} list	 
	;

list : '(' paralist ')' | '(' IDList ')' | '(' ')';
arrays : varnames {icg=1;push(currentlexval);} '[' arrexp {icg=1;} ']' {array_expression_code();};
arrexp : Ternary{icg=1;} | ;
paralist	: PD	| paralist ',' PD	;
PD : typespecs varnames | typespecs;
IDList	: ID	{addId();}	| IDList ',' ID	{addId();}	;
decl : error ';'
%%
extern FILE *yyin;
extern FILE *yyout;
yyerror(s)
char *s;
{
	fflush(stdout);err=1;
	printf("Error at Pos : %d : %d\n",line,wordcount);
	exit(0);
}
void main(argc,argv)
int argc;
char **argv;
{

	char *fname;
	++argv,--argc;
	if(argc>0)
	{
		yyin=fopen(argv[0],"r");
		fname=argv[0];
		strcat(fname,"-p");
		yyout=fopen(fname,"w");
	}
	else
	{
		printf("Please give the c filename as an argument.\n");
	}
	printf("Start of ICG!\n\n");
	yyparse();
	if(err==0 && err1==0)
	printf("\nEnd of ICG!\n");
	fname=argv[0];strcat(fname,"-symtable");
	FILE *sym_tab=fopen(fname,"w");
	Table *ptr;
	fprintf(sym_tab,"\n\n\t\t\t\tSYMBOL TABLE\n\n\n");
	fprintf(sym_tab,"TYPE\t\t\t    SYMBOL\t\t\t   SCOPE\n\n");
	for(ptr=sym_table;ptr!=(Table *)0;ptr=(Table *)ptr->next)
	{
		fprintf(sym_tab,"%s\t\t\t%10s\t\t\t%10s\n",ptr->type,ptr->name,ptr->scope);
	}
	fclose(sym_tab);

}