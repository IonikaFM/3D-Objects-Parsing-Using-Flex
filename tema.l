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
    bool image_firstLine;
    bool texture_firstLine;

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
<INITIAL>Object {
    /*  cand intalnesc pentru prima oara cuvantul "Object" initializez numarul
    de taburi cu 0 si intru in starea OBJECT */

    nr_tabs = 0;
    BEGIN(OBJECT);
}

<OBJECT>vertexes { 
    /* din starea OBJECT daca gasesc un string de forma "vertexes" inseamna ca
    urmeaza lista de vertexi. Asadar afisez un string corespunzator, initializez
    variabilele ajutatoare si trec in starea VERTEXES*/

    printf("varfuri: ");
    nr_vertexes = 0;
    texture_exists = false;
    nr_faces = 0;
    image_firstLine = false;
    texture_firstLine = false;
    BEGIN(VERTEXES);
}

<OBJECT>faces {
    /* din starea OBJECT daca gasesc un string de forma "faces" inseamna ca 
    urmeaza lista de fete. Asadar afisez un string corespunzator, initializez
    variabilele ajutatoare si trec in starea FACES*/

    nr_vertexes = 0;
    texture_exists = false;
    nr_faces = 0;
    image_firstLine = false;
    texture_firstLine = false;
    printf("fete: ");
    BEGIN(FACES);
}

<OBJECT>texture {
    /* din starea OBJECT daca gasesc un string de forma "textire" inseamna ca 
    urmeaza lista de indici pentru texturi. Asadar afisez un string corespunzator, 
    initializez variabilele ajutatoare si trec in starea TEXTURE*/

    nr_vertexes = 0;
    nr_faces = 0;
    texture_exists = true;
    image_firstLine = false;
    texture_firstLine = true;
    BEGIN(TEXTURE);
}

<OBJECT>img {
    /* din starea OBJECT daca gasesc un string de forma "img" inseamna ca 
    urmeaza numele imaginii de textura. Asadar afisez un string corespunzator, 
    initializez variabilele ajutatoare si trec in starea IMAGE*/

    nr_vertexes = 0;
    texture_exists = true;
    nr_faces = 0;
    image_firstLine = true;
    texture_firstLine = false;
    BEGIN(IMAGE);
}

<OBJECT>{text} {
    /*  din starea OBJECT daca gasesc un alt string decat cele de mai sus ce se 
    potriveste cu regexul {text} inseamna ca am gasit numele obiectului, 
    caz in care afisez numarul de taburi calculate pana in prezent, urmat de 
    numele obiectului */

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
    printf("%d", nr_vertexes);
    BEGIN(TEXTURE);
}

<VERTEXES>faces {
    /* din starea VERTEXES daca gasesc textul "faces" inseamna ca urmeaza lista
    de fete. Asadar afisez numarul de vertexi si un string corespunzator pentru 
    ce urmeaza sa numar si trec in starea FACES*/

    printf("%d", nr_vertexes);
    printf(", fete: ");
    BEGIN(FACES);
}

<VERTEXES>img {
    /* din starea VERTEXES daca gasesc textul "img" inseamna ca urmeaza numele
    imaginii de textura. Asadar afisez numarul de vertexi si trec in starea IMAGE*/

    printf("%d", nr_vertexes);
    BEGIN(IMAGE);
}

<VERTEXES>Object {
    /* din starea VERTEXES daca gasesc textul "Object" inseamna ca obiectul curent
    contine un obiect in interiorul sau. Asadar afisez numarul de vertexi, verific
    daca exista sau nu textura (daca nu exista afisez acest lucru), incrementez 
    numarul de taburi si trec in starea OBJECT*/

    nr_tabs++;
    printf("%d", nr_vertexes);
    if(texture_exists == false) {
        printf(", fara textura\n");
    } else printf("\n");
    BEGIN(OBJECT);
}

<VERTEXES>{end_object} {
    /* din starea VERTEXES daca gasesc caracterul "}" inseamna ca descrierea 
    obiectului curent a luat sfarsit. Asadar afisez numarul de vertexi, verific
    daca exista sau nu textura (daca nu exista afisez acest lucru) si trec in 
    starea END*/

    printf("%d", nr_vertexes);
    if(texture_exists == false) {
        printf(", fara textura\n");
    } else printf("\n");
    BEGIN(END);
}

<TEXTURE>faces {
    /* din starea TEXTURE cand intalnesc textul "faces" afisez string-ul
    corespunzator si trec in starea FACES */

    printf(", fete: ");
    BEGIN(FACES);
}

<TEXTURE>vertexes { 
    /* din starea TEXTURE cand intalnesc textul "vertexes" afisez string-ul
    corespunzator si trec in starea VERTEXES */

    printf(", varfuri: ");
    BEGIN(VERTEXES);
}

<TEXTURE>img {
    /* din starea TEXTURE cand intalnesc textul "img" trec in starea IMAGE */

    /* aceste doua boolene ma ajuta la afisarea pe formatul cerut*/
    if(texture_firstLine == true && image_firstLine == false){
        image_firstLine = true;
    }
    BEGIN(IMAGE);
}

<TEXTURE>Object {
    /* din starea TEXTURE daca gasesc textul "Object" inseamna ca obiectul curent
    contine un obiect in interiorul sau. Asadar incrementez numarul de taburi si
    trec in starea OBJECT*/

    nr_tabs++;
    printf("\n");
    BEGIN(OBJECT);
}

<TEXTURE>{end_object} {
    /* din starea TEXTURE daca gasesc caracterul "}" inseamna ca descrierea 
    obiectului curent a luat sfarsit, deci trec direct in starea END*/

    printf("\n");
    BEGIN(END);
}

<FACES>{int_list} {
    /* din starea FACES daca gasesc un element de tip {int_list} (adica un string
    de forma "int_number int_number ... int_number;" ) incrementez contorul ce 
    tine evidenta numarului de fete din obiectul curent */

    nr_faces ++;
}

<FACES>vertexes { 
    /* din starea FACES daca gasesc textul "vertexes" inseamna ca urmeaza lista
    de vertexi. Asadar afisez numarul de fete si un string corespunzator pentru 
    ce urmeaza sa numar si trec in starea VERTEXES*/

    printf("%d", nr_faces);
    printf(", varfuri: ");
    BEGIN(VERTEXES);
}

<FACES>img {
    /* din starea FACES daca gasesc textul "img" inseamna ca urmeaza sa intalnesc
    numele texturii existente, asadar afisez numarul de fete si trec in starea 
    IMAGE */

    printf("%d", nr_faces);
    BEGIN(IMAGE);
}

<FACES>texture {
    /* din starea FACES daca gasesc textul "texture" inseamna ca obiectul 
    curent are textura (asadar boolean-ul texture_exists indica acest lucru) 
    deci afisez numarul de fete si trec in starea TEXTURE */

    texture_exists = true;
    printf("%d", nr_faces);
    BEGIN(TEXTURE);
}

<FACES>Object {
    /* din starea FACES daca gasesc textul "Object" inseamna ca obiectul curent
    contine un obiect in interiorul sau. Asadar afisez numarul de fete, verific
    daca exista sau nu textura (daca nu exista afisez acest lucru), incrementez 
    numarul de taburi si trec in starea OBJECT*/

    nr_tabs++;
    printf("%d", nr_faces);
    if(texture_exists == false) {
        printf(", fara textura\n");
    } else printf("\n");
    BEGIN(OBJECT);
}

<FACES>{end_object} {
    /* din starea FACES daca gasesc caracterul "}" inseamna ca descrierea 
    obiectului curent a luat sfarsit. Asadar afisez numarul de fete, verific
    daca exista sau nu textura (daca nu exista afisez acest lucru) si trec in 
    starea END*/

    printf("%d", nr_faces);
    if(texture_exists == false) {
        printf(", fara textura\n");
    } else printf("\n");
    BEGIN(END);
}

<IMAGE>Object {
    /* din starea IMAGE daca gasesc textul "Object" inseamna ca obiectul curent
    contine un obiect in interiorul sau. Asadar incrementez numarul de taburi 
    si trec in starea OBJECT*/

    nr_tabs++;
    printf("\n");
    BEGIN(OBJECT);
}

<IMAGE>{end_object} {
    /* din starea IMAGE daca gasesc caracterul "}" inseamna ca descrierea 
    obiectului curent a luat sfarsit deci trec in starea END*/

    printf("\n");
    BEGIN(END);
}

<IMAGE>vertexes { 
    /* din starea IMAGE daca gasesc textul "vertexes" inseamna ca urmeaza lista
    de vertexi. Asadar afisez  un string corespunzator pentru ce urmeaza sa numar
    si trec in starea VERTEXES*/

    printf(", varfuri: ");
    BEGIN(VERTEXES);
}

<IMAGE>texture {
    /* din starea IMAGE daca gasesc textul "texture" inseamna ca obiectul 
    curent are textura (asadar boolean-ul texture_exists indica acest lucru) 
    si trec in starea TEXTURE */

    texture_exists = true;
    BEGIN(TEXTURE);
}

<IMAGE>faces {
    /* din starea IMAGE cand intalnesc textul "faces" afisez string-ul
    corespunzator si trec in starea FACES */

    printf(", fete: ");
    BEGIN(FACES);
}

<IMAGE>{text} {
    /* din starea IMAGE daca intalnesc un alt string decat cele de mai sus ce se
    potriveste cu regexul {text} inseamna ca am gasit numele texturii pe care il 
    afisez*/

    if(image_firstLine == false){
        printf(", ");
    }
    printf("imagine textura %s", yytext);
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

<END>Object {
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
    /*citire din fisiere multiple*/
    
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
