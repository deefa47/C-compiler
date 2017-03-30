#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
char SS[100][30],steps[2]="0",stepvar[2]="T";
extern char currentCons[100];
int t=0,LStack[20],Labelno=0,LStackTop=0,stepvarTop=0,lnum =0,top = 0;

void push(char * c)
{
	top++;
	strcpy(SS[top],c);
}

void pop(){
	top--;
	if(top<0)
		top=0;
}

char * peek()
{
	return SS[top];
}


char * peek2()
{
    return SS[top-1];
}
void equalto_expression_code()
 {
 printf("%s = %s\n",SS[top-2],SS[top]);
 top-=2;
 }

void incremen_expression_code()
{
    printf("%s = %s%s%s\n",SS[top-2],SS[top-2],SS[top-1],SS[top]);
    top-=2;
}

void unary_expression_code()
 {

 strcpy(stepvar,"T");
 strcat(stepvar,steps);
 printf("%s = %s %s\n",stepvar,SS[top-1],SS[top]); 
 top--;
 strcpy(SS[top],stepvar);
 if(steps[0]=='9')    {steps[0]='1';steps[1]='0';t=1;}
 else
 steps[t]++;
 }

void array_expression_code()
{
    strcpy(stepvar, "T"); strcat(stepvar, steps);
    printf("%s = %s * 4\n", stepvar, SS[top] );
    strcpy(SS[top], stepvar);
    if(steps[0]=='9')    {steps[0]='1';steps[1]='0';t=1;}
 else
    steps[t]++;
    strcpy(stepvar, "T"); strcat(stepvar, steps);
    printf("%s = addr   %s + %s \n", stepvar, SS[top-1], SS[top]);
    top -= 1; strcpy(SS[top], stepvar);
    if(steps[0]=='9')    {steps[0]='1';steps[1]='0';t=1;}
 else
    steps[t]++;
    return;
}

void expression_code()
 {
 strcpy(stepvar,"T");
 strcat(stepvar,steps);
 printf("%s = %s %s %s\n",stepvar,SS[top-2],SS[top-1],SS[top]);
 top-=2;
 strcpy(SS[top],stepvar);
 if(steps[0]=='9')    {steps[0]='1';steps[1]='0';t=1;}
 else
 steps[t]++;
 }


void  initial_for()
{
    printf("L%d: \n",Labelno++);
}
void condition_for()
{
    strcpy(stepvar,"T");
    strcat(stepvar,steps);
    printf("%s = ! %s \n",stepvar,SS[top]);
    //top-=1;
    printf("if %s goto L%d\n",stepvar,Labelno);
    if(steps[0]=='9')    {steps[0]='1';steps[1]='0';t=1;}
 else
    steps[t]++;
    LStack[++LStackTop]=Labelno; 
    Labelno++;
    printf("goto L%d\n",Labelno);
    LStack[++LStackTop]=Labelno; 
    printf("L%d: \n",++Labelno);
 }
void increment_for()
{
    int x;
    x=LStack[LStackTop--];
    printf("goto L%d \n",stepvarTop);
    printf("L%d: \n",x);
}

void inside_for()
{
    int x;
    x=LStack[LStackTop--];
    printf("goto L%d \n",Labelno);    
    printf("L%d: \n",x);
}
void condition_if()
{
 lnum++;
 strcpy(stepvar,"T");
 strcat(stepvar,steps);
 printf("%s = ! %s\n",stepvar,SS[top]);
 printf("if %s goto L%d\n",stepvar,lnum);
 if(steps[0]=='9')    {steps[0]='1';steps[1]='0';t=1;}
 else
 steps[t]++;
 LStack[++LStackTop]=lnum;
}

void inside_else()
{
int x;
lnum++;
x=LStack[LStackTop--];
printf("goto L%d\n",lnum);
printf("L%d: \n",x); 
LStack[++LStackTop]=lnum;
}

void ending_if()
{
int y;
y=LStack[LStackTop--];
printf("L%d: \n",y);
}

void before_while()
{
printf("L%d: \n",lnum++);
}


void condition_while()
{
 strcpy(stepvar,"T");
 strcat(stepvar,steps);
 printf("%s = ! %s\n",stepvar,SS[top]);
 printf("if %s goto L%d\n",stepvar,lnum);
 //top-=2;
 if(steps[0]=='9')    {steps[0]='1';steps[1]='0';t=1;}
 else
 steps[t]++;
 }

void ending_while()
{
printf("goto L%d \n",stepvarTop);
printf("L%d: \n",lnum);
}

void start_dowhile()
{
    lnum++;
    printf("L%d: \n",lnum);
    LStack[++LStackTop] = lnum;
    return;
}

void ending_dowhile()
{
    printf("if %s goto L%d\n",SS[top],LStack[LStackTop--]);
    return;
}