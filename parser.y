%{

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define MAX_TAC 1000
#define MAX_NAME 50

typedef struct{
    char lhs[MAX_NAME];
    char op[10];
    char arg1[MAX_NAME];
    char arg2[MAX_NAME];
} TAC;

TAC tacTable[MAX_TAC];
int tacCount = 0;
int labelCount = 0;
int tempCount = 0;
int lineNumber = 1;

char* tempLabel;

// Function prototypes
char* newTemp();
char* newLabel();
void emitTAC(char* lhs, char* op, char* arg1, char* arg2);
void printTAC();
void optimizeTAC();
void printAssembly();

char* newTemp(){
    static char temp[32];
    sprintf(temp,"t%d",tempCount++);
    return strdup(temp);
}

char* newLabel(){
    static char label[32];
    sprintf(label,"l%d",labelCount++);
    return strdup(label);
}

void emitTAC(char* lhs, char* op, char* arg1, char* arg2){
    if (tacCount >= MAX_TAC){
        printf("TAC Overflow\n");
    }
    else{
        strncpy(tacTable[tacCount].lhs, lhs, MAX_NAME-1);
        strncpy(tacTable[tacCount].op, op, 9);
        strncpy(tacTable[tacCount].arg1, arg1, MAX_NAME-1);
        strncpy(tacTable[tacCount].arg2, arg2, MAX_NAME-1);
        tacTable[tacCount].lhs[MAX_NAME-1] = '\0';
        tacTable[tacCount].op[9] = '\0';
        tacTable[tacCount].arg1[MAX_NAME-1] = '\0';
        tacTable[tacCount].arg2[MAX_NAME-1] = '\0';
        tacCount++;
    }
}

void printTAC(){
    for (int i=0; i<tacCount; i++){
        if (strcmp(tacTable[i].op,"if") == 0){
            printf("if %s goto %s\n", tacTable[i].lhs, tacTable[i].arg2);
        }
        else if (strcmp(tacTable[i].op,"goto") == 0){
            printf("goto %s\n", tacTable[i].arg1);
        }
        else if(strcmp(tacTable[i].op,"label") == 0){
            printf("\nlabel %s\n\n", tacTable[i].arg1);
        }
        else if (strcmp(tacTable[i].op,"=") == 0){
            printf("%s = %s\n", tacTable[i].lhs, tacTable[i].arg1);
        }
        else{
            printf("%s = %s %s %s\n", tacTable[i].lhs, tacTable[i].arg1, tacTable[i].op, tacTable[i].arg2);
        }
    }
}

int isNumeric(char* s){
    if (*s == '-') s++;
    while (*s){
        if (!isdigit(*s)) return 0;
        s++;
    }
    return 1;
}

void constantFolding(){
    for (int i=0; i<tacCount; i++){
        char* op = tacTable[i].op;
        char* arg1 = tacTable[i].arg1;
        char* arg2 = tacTable[i].arg2;

        if (isNumeric(arg1) && isNumeric(arg2)){
            int res = 0;
            int v1 = atoi(arg1);
            int v2 = atoi(arg2);

            if (strcmp(op,"+") == 0) res = v1 + v2;
            else if (strcmp(op,"-") == 0) res = v1 - v2;
            else if (strcmp(op,"*") == 0) res = v1 * v2;
            else if (strcmp(op,"/") == 0 && v2 != 0) res = v1 / v2;
            else if (strcmp(op,"<") == 0) res = v1 < v2;
            else if (strcmp(op,">") == 0) res = v1 > v2;
            else if (strcmp(op,"<=") == 0) res = v1 <= v2;
            else if (strcmp(op,">=") == 0) res = v1 >= v2;
            else if (strcmp(op,"==") == 0) res = v1 == v2;
            else if (strcmp(op,"!=") == 0) res = v1 != v2;
            else continue;

            sprintf(tacTable[i].arg1, "%d", res);
            strcpy(tacTable[i].op, "=");
            tacTable[i].arg2[0] = '\0';
        }
    }
}

void strengthReduction(){
    for (int i=0; i<tacCount; i++){
        char* op = tacTable[i].op;
        char* arg2 = tacTable[i].arg2;

        if ((strcmp(op,"*") == 0 || strcmp(op,"/") == 0) && isNumeric(arg2)){
            int shift = 0;
            int val = atoi(arg2);
            if (val > 0 && (val & (val-1)) == 0){
                while (val > 1){
                    val >>= 1;
                    shift++;
                }

                if (strcmp(op,"*") == 0) strcpy(tacTable[i].op, "<<");
                else strcpy(tacTable[i].op, ">>");
                sprintf(tacTable[i].arg2, "%d", shift);
            }            
        }
    }
}

void algebraicSimplification(){
    for (int i=0; i<tacCount; i++){
        char* op = tacTable[i].op;
        char* arg1 = tacTable[i].arg1;
        char* arg2 = tacTable[i].arg2;

        // x + 0 = x
        if ((strcmp(op,"+") == 0 || strcmp(op,"-") == 0) && strcmp(arg2,"0") == 0){
            strcpy(tacTable[i].op, "=");
            tacTable[i].arg2[0] = '\0';
        }
        // 0 + x = x
        else if (strcmp(op,"+") == 0 && strcmp(arg1,"0") == 0){
            strcpy(tacTable[i].op, "=");
            strcpy(tacTable[i].arg1, tacTable[i].arg2);
            tacTable[i].arg2[0] = '\0';
        }
        // x * 1 = x
        else if ((strcmp(op,"*") == 0 || strcmp(op,"/") == 0) && strcmp(arg2,"1") == 0){
            strcpy(tacTable[i].op, "=");
            tacTable[i].arg2[0] = '\0';
        }
        // 1 * x = x
        else if (strcmp(op,"*") == 0 && strcmp(arg1,"1") == 0){
            strcpy(tacTable[i].op, "=");
            strcpy(tacTable[i].arg1, tacTable[i].arg2);
            tacTable[i].arg2[0] = '\0';
        }
        // x * 0 = 0
        else if (strcmp(op,"*") == 0 && (strcmp(arg1,"0") == 0 || strcmp(arg2,"0") == 0)){
            strcpy(tacTable[i].op, "=");
            strcpy(tacTable[i].arg1, "0");
            tacTable[i].arg2[0] = '\0';
        }
    }
}

void optimizeTAC(){
    constantFolding();
    strengthReduction();
    algebraicSimplification();
}

void printAssembly(){
    for (int i=0; i<tacCount; i++){
        char* op = tacTable[i].op;
        char* arg1 = tacTable[i].arg1;
        char* arg2 = tacTable[i].arg2;
        char* lhs = tacTable[i].lhs;

        if (strcmp(op,"if") == 0){
            printf("CMP %s,0\n", lhs);
            printf("JNZ %s\n", arg2);
        }
        else if (strcmp(op,"goto") == 0){
            printf("JMP %s\n", arg1);
        }
        else if (strcmp(op,"label") == 0){
            printf("\n%s:\n\n", arg1);
        }
        else if (strcmp(op,"=") == 0){
            printf("MOV %s,%s\n", arg1, lhs);
        }
        else{
            printf("MOV %s,R0\n", arg1);

            if (strcmp(op,"+") == 0) printf("ADD %s,R0\n", arg2);
            else if (strcmp(op,"-") == 0) printf("SUB %s,R0\n", arg2);
            else if (strcmp(op,"*") == 0) printf("MUL %s,R0\n", arg2);
            else if (strcmp(op,"/") == 0) printf("DIV %s,R0\n", arg2);
            else if (strcmp(op,"<<") == 0) printf("SHL %s,R0\n", arg2);
            else if (strcmp(op,">>") == 0) printf("SHR %s,R0\n", arg2);
            else if (strcmp(op,"<") == 0) printf("CMP %s,R0\nSETL R0\n", arg2);
            else if (strcmp(op,">") == 0) printf("CMP %s,R0\nSETG R0\n", arg2);
            else if (strcmp(op,"<=") == 0) printf("CMP %s,R0\nSETLE R0\n", arg2);
            else if (strcmp(op,">=") == 0) printf("CMP %s,R0\nSETGE R0\n", arg2);
            else if (strcmp(op,"==") == 0) printf("CMP %s,R0\nSETE R0\n", arg2);
            else if (strcmp(op,"!=") == 0) printf("CMP %s,R0\nSETNE R0\n", arg2);

            printf("MOV R0,%s\n", lhs);            
        }
    }
}

int yylex();
void yyerror(const char* s);
extern FILE* yyin;
%}

%code requires{
    typedef struct{ char* place;} Attr;
}

%union{
    char* sval;
    Attr attr;
}

%token<sval> ID NUM
%token IF GOTO ASSIGN LT GT LE GE EQ NE PLUS MINUS MUL DIV LBRACE RBRACE LPAREN RPAREN SEMI COLON
%type<attr> expr term factor cond

%left PLUS MINUS
%left MUL DIV
%nonassoc LT GT LE GE EQ NE

%%

program : statement_list { 
    printf("\n=======================================\nSyntax Checking\n\n");
    printf("\nSyntax checked successfully!");
};

statement_list : 
| statement_list statement;

statement : ID ASSIGN expr SEMI {
    emitTAC($1, "=", $3.place, "");
    free($1);
    free($3.place);
}
| IF LPAREN cond RPAREN {
    char* l1 = newLabel();
    char* l2 = newLabel();
    tempLabel = l2;
    emitTAC($3.place, "if", "goto", l1);
    emitTAC("", "goto", l2, "");
    emitTAC("", "label", l1, "");
    free($3.place);
} block {
    emitTAC("", "label", tempLabel, "");
    free(tempLabel);
    tempLabel = NULL;
};

block : LBRACE statement_list RBRACE;

expr : expr PLUS term {
    char* t1 = newTemp();
    emitTAC(t1, "+", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
}
| expr MINUS term {
    char* t1 = newTemp();
    emitTAC(t1, "-", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
}
| term {$$ = $1;};

term : term MUL factor {
    char* t1 = newTemp();
    emitTAC(t1, "*", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
}
| term DIV factor {
    char* t1 = newTemp();
    emitTAC(t1, "/", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
}
| factor {$$ = $1;};

factor : NUM {$$.place = strdup($1); free($1);}
| ID {$$.place = strdup($1); free($1);}
| LPAREN expr RPAREN {$$.place = $2.place;};

cond : expr LT expr {
    char* t1 = newTemp();
    emitTAC(t1, "<", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
}
| expr GT expr {
    char* t1 = newTemp();
    emitTAC(t1, ">", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
}
| expr LE expr {
    char* t1 = newTemp();
    emitTAC(t1, "<=", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
}
| expr GE expr {
    char* t1 = newTemp();
    emitTAC(t1, ">=", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
}
| expr EQ expr {
    char* t1 = newTemp();
    emitTAC(t1, "==", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
}
| expr NE expr {
    char* t1 = newTemp();
    emitTAC(t1, "!=", $1.place, $3.place);
    free($1.place);
    free($3.place);
    $$.place = t1;
};

%%

void yyerror(const char* s){
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char** argv){
    FILE* file = fopen(argv[1], "r");
    yyin = file;

    printf("\n=======================================\n");
    printf("COMPILER \n=======================================\n\n");

    printf("Tokenization\n\n");
    yyparse();
    fclose(yyin);

    printf("\n=======================================\nThree Address Code\n\n");
    printTAC();

    printf("\n=======================================\nOptimization\n\n");
    optimizeTAC();
    printTAC();

    printf("\n=======================================\nTarget Code Generation\n\n");
    printAssembly();

    printf("\n\nCompiled Successfully!\n");
    return 0;
}
