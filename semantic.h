#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "SymTable.h"

extern int line, wordcount;
extern char *yytext,currentlexval[100];
int typevalue,err=0,err1=0,floatcheck=3;
char currentparentfunction[100]="GLOBAL";

void addId()
{
	Table *s;
	s = Fetch (currentlexval,currentparentfunction);
	if (s == 0)
	s = Save (currentlexval,typevalue,currentparentfunction);
	else
	{
		printf( "\nFound an ERROR: Semantic error at position : %d : %d : %s is already declared as %s\n",line,wordcount,s->name,s->type );
		err1=1;
		exit(0);
	}
	
}

int Id_verify()
{
	Table *s;
	s = Fetch(currentlexval,currentparentfunction);
if(s == 0 )
{
		printf( "\nFound an ERROR: Semantic error at position : %d : %d : %s is an undeclared identifier\n",line,wordcount,currentlexval);
		err1=1;
		exit(0); }else
	{if(strcmp(s->type,"void")==0) return(1);
        if(strcmp(s->type,"int")==0) return(3);
        if(strcmp(s->type,"float")==0)  return(4);
        if(strcmp(s->type,"char")==0)  return(2); }
}

void typemismatch(int t1,int t2)
{
	if(t2 == 0) t2 = floatcheck;
	if(t1!=t2) {
		printf( "\nERROR: Semantic error : Type mismatch!\n\n");err1=1; exit(0); }
	floatcheck=3;
}
