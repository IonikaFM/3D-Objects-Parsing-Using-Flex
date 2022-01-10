/*Grosu Ioana Alexandra 335CC*/
%{
    #include <stdio.h>
    #include <vector>
    #include <string.h>
    #undef yywrap

    /*variabile ajutatoare*/
    int nr_vertexes;
    bool texture_exists;
    int nr_faces;
    int nr_tabs;

    /*variabile necesare pentru citirea fisierelor multiple*/
    char **ListaFisiere;
    unsigned int FisierCurent = 0;
    unsigned int NumarFisiere;    
%}

%x OBJECT
%x VERTEXES
%x TEXTURE
%x FACES
%x IMAGE
%x END

number [0-9]+
float_number {number}\.{number}
text [A-Za-z][A-Za-z0-9\._]*
start_object [{]
end_object [}]
start_list [(]
end_list [)]
end_faces [\;]
trailing_spaces [ \t\n]*
float_list {start_list}[0-9 \t\n.]*{end_list}
int_list [0-9 \t\n]*{end_faces}

%%
<INITIAL>Object{trailing_spaces} {
    /*  cand intalnesc pentru prima oara cuvantul "Object" initializez numarul
    de taburi cu 0 si intru in starea OBJECT */

    nr_tabs = 0;
    BEGIN(OBJECT);
}

<OBJECT>{start_object}{trailing_spaces}vertexes { 
    /* din starea OBJECT daca gasesc un string de forma "{\n vertexes" inseamna
    ca urmeaza lista de vertexi. Asadar afisez un string corespunzator, initializez
    variabilele ajutatoare si trec in starea VERTEXES*/

    printf("varfuri: ");
    nr_vertexes = 0;
    texture_exists = false;
    nr_faces = 0;
    BEGIN(VERTEXES);
}

<OBJECT>{text} {
    /*  din starea OBJECT daca gasesc un string ce se potriveste cu regexul
    {text} inseamna ca am gasit numele obiectului, caz in care afisez numarul
    de taburi calculate pana in prezent, urmat de numele obiectului */

    for(int i = 0; i < nr_tabs; i ++){
        printf("\t");
    }
    printf("Object %s: ", yytext);
}

<VERTEXES>{float_list} {
    /* din starea VERTEXES daca gasesc un element de tip float_list (adica un
    string de forma "(float_number float_number ... float_number)" ) incrementez
    contorul ce tine evidenta numarului de vertexi din obiectul curent */

    nr_vertexes ++;
}

<VERTEXES>texture {
    /* din starea VERTEXES daca gasesc textul "texture" inseamna ca obiectul 
    curent are textura (asadar boolean-ul texture_exists indica acest lucru) 
    deci afisez numarul de vertexi si trec in starea TEXTURE */

    texture_exists = true;
    printf("%d, ", nr_vertexes);
    BEGIN(TEXTURE);
}

<VERTEXES>faces {
    /* din starea VERTEXES daca gasesc textul "faces" inseamna ca urmeaza lista
    de fete, deci obiectul nu are textura (dar boolean-ul este deja setat pe 
    false). Asadar afisez numarul de vertexi si un string corespunzator pentru 
    ce urmeaza sa numar si trec in starea FACES*/

    printf("%d, ", nr_vertexes);
    printf("fete: ");
    BEGIN(FACES);
}

<TEXTURE>faces {
    /* din starea TEXTURE cand intalnesc textul "faces" afisez string-ul
    corespunzator si trec in starea FACES */

    printf("fete: ");
    BEGIN(FACES);
}

<FACES>{int_list} {
    /* din starea FACES daca gasesc un element de tip {int_list} (adica un string
    de forma "int_number int_number ... int_number;" ) incrementez contorul ce 
    tine evidenta numarului de fete din obiectul curent */

    nr_faces ++;
}

<FACES>img {
    /* din starea FACES daca gasesc textul "img" inseamna ca urmeaza sa intalnesc
    numele texturii existente, asadar afisez numarul de fete si trec in starea 
    IMAGE */

    printf("%d, ", nr_faces);
    BEGIN(IMAGE);
}

<FACES>Object {
    /* din starea FACES daca gasesc textul "Object" inseamna ca obiectul curent
    contine un alt obiect in interiorul sau. Din acest motiv incrementez numarul
    de taburi pe care trebuie sa le afisez in fata numelui sau, afisez numarul
    de fete, si specific ca nu exista textura si reintru in starea OBJECT pentru
    a repeta procesul de pana acum */

    nr_tabs++;
    printf("%d, ", nr_faces);
    printf("fara textura\n");
    BEGIN(OBJECT);
}

<FACES>{end_object} {
    /* din starea faces daca intalnesc un element de tipul {end_object} (adica 
    string-ul "}") inseamna ca specificatia obiectului curent s-a incheiat deci
    afisez numarul de fete, indic faptul ca nu exista textura si trec in starea
    END */

    printf("%d, ", nr_faces);
    printf("fara textura\n");
    BEGIN(END);
}

<IMAGE>Object {
    /* din starea IMAGE daca gasesc textul "Object" inseamna ca obiectul curent
    contine un alt obiect in interiorul sau. Din acest motiv incrementez numarul
    de taburi pe care trebuie sa le afisez in fata numelui sau si reintru in 
    starea OBJECT pentru a repeta procesul de pana acum */

    nr_tabs++;
    BEGIN(OBJECT);
}

<IMAGE>{end_object} {
    /* din starea IMAGE daca intalnesc un element de tipul {end_object} (adica 
    string-ul "}") inseamna ca specificatia obiectului curent s-a incheiat deci
    trec in starea END */

    BEGIN(END);
}

<IMAGE>{text} {
    /* din starea IMAGE daca intalnesc un string ce se potriveste cu regexul
    {text} inseamna ca am gasit numele texturii, iar acesta trebuie afisat */

    printf("imagine textura %s\n", yytext);
}

<END>{end_object} {
    /* din starea END daca intalnesc un element de tipul {end_object} (adica 
    string-ul "}") inseamna ca specificatia obiectului curent s-a incheiat,
    asadar decrementez numarul de taburi ce trebuiesc afisate inaintea numelui
    urmatorului obiect */

    if(nr_tabs){
        nr_tabs --;
    }
}

<END>{trailing_spaces}Object {
    /* din starea END daca intalnesc cuvantul "Object" inseamna ca incepe 
    specificatia urmatorului obiect, asadar trec in starea OBJECT */

    BEGIN(OBJECT);
}

<INITIAL>.|\n ;
<OBJECT>.|\n ;
<VERTEXES>.|\n ;
<TEXTURE>.|\n ;
<FACES>.|\n ;
<IMAGE>.|\n ;
<END>.|\n ;


%%
main(int argc, char **argv){
    FILE *fisier; 
    ListaFisiere = argv + 1;
    NumarFisiere = argc - 2;
    if (argc > 1) {
        FisierCurent = 0;
        fisier = fopen(ListaFisiere[FisierCurent], "r");
        if (!fisier){ 
            printf("!!!eroare!!!");
            exit(1);
        }
        yyin = fisier;
        yylex();
    }
}

/* suprascriere functie yywrap preluata din curs */
int yywrap(){
    FILE *fisier = NULL;
    fclose(yyin);

    FisierCurent++;
    
    if (FisierCurent > NumarFisiere) return 1;
    fisier = fopen(ListaFisiere[FisierCurent], "r");
    if (!fisier){
        printf("!!! eroare!!!");
        exit(1);
    }
    yyin = fisier;
    return(fisier ? 0:1);
}