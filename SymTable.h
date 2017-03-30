#define t_void	1
#define t_char	2
#define t_int	3
#define t_float	4
struct SymTable
{
	char *name;
	char *scope;
	char type[10];
	struct Table *next;
};
typedef struct SymTable Table;
Table *sym_table = (Table *)0;
Table *Save();
Table *Fetch();
Table *Save(char *sym_name,int sym_type, char *func)
{
	char type[10];
	switch(sym_type) {
		case 1: strcpy(type,"void");
			break;
		case 2: strcpy(type,"char");
			break;
		case 3:
			strcpy(type,"int");
			break;
		case 4:
			strcpy(type,"float");
			break;
	}
	Table *ptr;
	ptr=(Table *)malloc(sizeof(Table));
	ptr->name=(char *)malloc(strlen(sym_name)+1);
	ptr->scope=(char *)malloc(strlen(func)+1);
	strcpy(ptr->name,sym_name);
	strcpy(ptr->type,type);
	strcpy(ptr->scope,func);
	ptr->next=(struct Table *)sym_table;
	sym_table=ptr;
	return ptr;
}


Table *Fetch(char *sym_name,char *func)
{
	Table *ptr;
	for(ptr=sym_table;ptr!=(Table *)0;ptr=(Table *)ptr->next)
	if((strcmp(ptr->name,sym_name)==0&&strcmp(ptr->scope,func)==0)||(strcmp(ptr->name,sym_name)==0&&strcmp(ptr->scope,"GLOBAL")==0))
	return ptr;
	return 0;
}
