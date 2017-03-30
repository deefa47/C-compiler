D			[0-9]
L			[a-zA-Z_]
Hexa			[a-fA-F0-9]
Exponent			[Ee][+-]?{D}+

%{
#include <stdio.h>
#include "y.tab.h"
int wordcount=1,line=1,scope=0;
char currentlexval[100],currentCons[100];
%}
commentstart (\/\/.*)
commentcontinue (\/\*)
commentend (\*\/)
%x CommentProc


%%
"#include<".*\n		{line++;}
"printf"							{wordcount+=yyleng;return(Printf); }
"scanf"								{wordcount+=yyleng;   return(Scanf); }
"break"								{ wordcount+=yyleng;   return(Break); }
"char"								{ wordcount+=yyleng;   return(Char); }
"continue"						{ wordcount+=yyleng; return(Continue); }
"do"									{ wordcount+=yyleng;   return(Do); }
"else"								{ wordcount+=yyleng;   return(Else); }
"extern"							{ wordcount+=yyleng;   return(Extern); }
"float"								{ wordcount+=yyleng;   return(Float); }
"for"									{ wordcount+=yyleng;   return(For); }
"if"									{ wordcount+=yyleng;   return(If); }
"int"									{ wordcount+=yyleng;   return(Int); }
"return"							{ wordcount+=yyleng;  ; return(Return); }
"sizeof"							{ wordcount+=yyleng;  ; return(SizeOf); }
"typedef"							{ wordcount+=yyleng;  ; return(Typedef); }
"void"								{ wordcount+=yyleng;  ; return(Void); }
"while"								{ wordcount+=yyleng;  ; return(While); }
(['])+({L}|{D})+(['])			{ wordcount+=yyleng;  ; return(Character); }
{L}({L}|{D})*							{ wordcount+=yyleng;  ; strcpy(currentlexval,yytext);return(ID); }

0[xX]{Hexa}+							{ wordcount+=yyleng;  strcpy(currentCons,yytext); return(Const); }
0{D}+											{ wordcount+=yyleng;  strcpy(currentCons,yytext); return(Const); }
{D}+											{ wordcount+=yyleng;  strcpy(currentCons,yytext); return(Const); }
L?'(\\.|[^\\'])+'					{ wordcount+=yyleng;  strcpy(currentCons,yytext); return(Const); }

{D}+{Exponent}						{ wordcount+=yyleng;  strcpy(currentCons,yytext); return(FloatConst); }
{D}*"."{D}+({Exponent})?	{ wordcount+=yyleng;  strcpy(currentCons,yytext); return(FloatConst); }
{D}+"."{D}*({Exponent})?	{ wordcount+=yyleng;  strcpy(currentCons,yytext); return(FloatConst); }

L?\"(\\.|[^\\"])*\"				{ wordcount+=yyleng;  ; return(Str); }

"++"			{ wordcount+=yyleng;  ; return(PlusPlus); }
"--"			{ wordcount+=yyleng;  ; return(MinusMinus); }
"&&"			{ wordcount+=yyleng;  ; return(AndAnd); }
"||"			{ wordcount+=yyleng;  ; return(OrOr); }
"<="			{ wordcount+=yyleng;  ; return(LessEqual); }
">="			{ wordcount+=yyleng;  ; return(GreaterEqual); }
"=="			{ wordcount+=yyleng;  ; return(EqualEqual); }
"!="			{ wordcount+=yyleng;  ; return(NotEqual); }
";"				{ wordcount+=yyleng;  ; return(';'); }
("{"|"<%")		{ wordcount+=yyleng;  ; return('{'); }
("}"|"%>")		{ wordcount+=yyleng;  ; return('}'); }
","			{ wordcount+=yyleng;  ; return(','); }
":"			{ wordcount+=yyleng;  ; return(':'); }
"="			{ wordcount+=yyleng;  ; return('='); }
"("			{ wordcount+=yyleng;  ; return('('); }
")"			{ wordcount+=yyleng;  ; return(')'); }
("["|"<:")		{ wordcount+=yyleng;  ; return('['); }
("]"|":>")		{ wordcount+=yyleng;  ; return(']'); }
"."			{ wordcount+=yyleng;  ; return('.'); }
"&"			{ wordcount+=yyleng;  ; return('&'); }
"!"			{ wordcount+=yyleng;  ; return('!'); }
"~"			{ wordcount+=yyleng;  ; return('~'); }
"-"			{ wordcount+=yyleng;  ; return('-'); }
"+"			{ wordcount+=yyleng;  ; return('+'); }
"*"			{ wordcount+=yyleng;  ; return('*'); }
"/"			{ wordcount+=yyleng;  ; return('/'); }
"%"			{ wordcount+=yyleng;  ; return('%'); }
"<"			{ wordcount+=yyleng;  ; return('<'); }
">"			{ wordcount+=yyleng;  ; return('>'); }
"^"			{ wordcount+=yyleng;  ; return('^'); }
"|"			{ wordcount+=yyleng;  ; return('|'); }
"?"			{ wordcount+=yyleng;  ; return('?'); }

[ ]			{wordcount+=yyleng;  ;}
[\t\v\f]		{ wordcount+=yyleng; }
[\n]			{line++;wordcount=1;}
.			{}
{commentstart}      {}
{commentcontinue}            { BEGIN(CommentProc); }
<CommentProc>{commentend} { BEGIN(INITIAL);}
<CommentProc>\n {line++;}
<CommentProc>. {}

%%
int yywrap()
{
	return(1);
}
