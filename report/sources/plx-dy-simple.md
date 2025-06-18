# Salue-moi
Un petit programme qui te salue avec ton nom complet.

Assure toi d'avoir la même sortie que ce scénario, en répondant `John` et `Doe` manuellement.
```
> ./main
Quel est ton prénom ? John
Salut John, qu'est est ton nom de famille ? Doe
Passe une belle journée John Doe !
>
```

Démarre avec ce bout de code.
```c
int main(int argc, char *argv[]) {
    // ???
}
```

Vérifie que ton programme ait terminé avec le code de fin 0, en lançant cette commande.
```sh
> echo $?
0
```

<details>
<summary>Solution</summary>

```c
#include <stdio.h>

#define NAME_MAX_SIZE 100
int main(int argc, char *argv[]) {
    char firstname[NAME_MAX_SIZE];
    char lastname[NAME_MAX_SIZE];

    printf("Quel est ton prénom ? ");
    fflush(stdout);
    scanf("%s", firstname);

    printf("Salut %s, qu'est est ton nom de famille ? ", firstname);
    fflush(stdout);
    scanf("%s", lastname);

    printf("Passe une belle journée %s %s !\n", firstname, lastname);
    return 0;
}
```
</details>
