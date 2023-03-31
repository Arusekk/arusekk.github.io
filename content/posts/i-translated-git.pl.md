---
title: Przetłumaczyłem Gita!
date: 2020-12-27
description: Dygresje lingwistyczne o tym, jak trudno się tłumaczy rzeczy
---

Odkryłem, że Git nie ma polskiego tłumaczenia!
Okropne uczucie, prawda?

Więc już ma.
Spędziłem na tłumaczeniu wszystkie wieczory przez ostatni miesiąc przed Bożym Narodzeniem.

Więc oto parę rzeczy, które zauważyłem:

1. Programiści (czy ktokolwiek, kto robi to, co mam na myśli) są chorobliwie anglocentryczni.
Właściwie totalnie ich nie obchodzą inne języki, nawet takie podobne,
nie wspominając już o [egzotycznych][wine-icu] (fragment z *designed well*).
Tak jak hebrajskie liczebniki wspomniane w tym artykule,
po polsku mówimy „dwie”, ale „dwóch” i „dwa”.
Więc tłumaczenie napisu (msgid) typu `"Only two %s found."` jest na 100% źle pomyślane.

[wine-icu]: https://www.winehq.org/interview/16

To samo dotyczy wielu `%s` w msgid.
Hej, GNU printf wspiera `"%1$s not found because of %2$s"`,
wszystkie języki nie-C też mają swój sposób na numerowanie procent-esów.
I wtedy można to oczywiście przetłumaczyć na `"%2$s powoduje, że nie znaleziono %1$s"`
jeśli brzmi to bardziej naturalnie w docelowym języku.

2. Tworzenie słów po angielsku jest endemiczne.
Przykładem jest tworzenie urzeczownikowienie przymiotników.
Wiele rzeczowników tworzonych z przymiotników musi być tłumaczonych jako całe wyrażenie.
Mówią „laptopowy” na „komputer laptopowy” (*laptop (computer)*),
„zdalny” na pilot (*remote (control)*, dosł. „zdalne (sterowanie)”)
(w gicie *remote* == zdalne repozytorium, *upstream* == gałąź nadrzędna),
„Angielski” na Anglika („English”),
„telewizyjny” na telewizor (*television (set)*, dosł „(zestaw) telewizyjny”),
„kiszony” na korniszon (*pickle*, *pickled (cucumber)*, dosł. „kiszony (ogórek)”),
„szklany” na szklankę („glass (cup)”, dosł. „szklany (kubek)”),
„płaskie” na mieszkanie (*flat (apartment)*, dosł. „płaskie (mieszkanie)”),
„przeglądowy” na recenzję (*review (document)*, dosł. „(dokument) przeglądowy”),
„plastyczny” na plastik (*plastic (material)*, dosł. „(materiał) plastyczny”),
„złożony” na kompozyt (*composite (material)*, dosł. „(materiał) złożony”),
„do noszenia” na osprzęt („wearable (equipment)”, dosł. „(sprzęt) do noszenia”, ponoć niektórzy to nazywają werablami).

Po polsku nazywamy niektóre z nich (jak widać) z angielskiego,
ale wolimy mówić „sterowanie” na „zdalne sterowanie”,
„materiał” na „materiał złożony”, „sprzęt” na „sprzęt do noszenia”,
„ogórek” na „kiszony ogórek”,
a na resztę rzeczy mamy coś istotnie różnego od swoich słów bazowych
(rozpaczliwa próba tłumaczenia morficznego, **nie ma** takich słów:
*livement*, *Englisher*, *televisor*, *glassie*, *reviewment*).

Po polsku każdy rzeczownik ma swój niezmienny rodzaj,
a każdy przymiotnik przybiera wszystkie rodzaje, i z założenia nie mogą być takie same.
Można łatwo tworzyć przymiotniki z rzeczowników,
tak jak po angielsku *-y*, *-ing* lub *-ish*.

Jak *blaze* -> *blazy*, *blazing* czy *blazish* mamy
„płomień” -> „płomienny”, „płomienisty”, „płomieniowy” i „płomiennawy”.

I co teraz?  W drugą stroną się nie da tak łatwo.  Albo się da,
ale wychodzi zupełnie co innego.

Weźmy ten pilot (nie: tego pilota).
Dosłowne tłumaczenie algielskiego *remote* byłoby „zdalny”.
Możemy z niego oczywiście zrobić rzeczownik „zdalność” (ale to po angielsku *remoteness*),
„zdalniak”/„zdalnek”/„zdalka”
(nie ma takich słów, ale brzmią równie infantylnie co *remotey* po angielsku).

3. Wymyślanie nowych słów.
Podstawowym słowem gita jest *commit*.
Tym razem jest to i rzeczownik i czasownik.
Wybrałem „zapis” na *a commit* (jak *a record*/*a save*)
i „złożyć” na *to commit* (jak *put together* = poskładać, czy *hand in* = złożyć jakieś np. pismo).
Stwierdziłem, że „złożenie”, jak *a putting together* czy *a handing in*
nie trafia w znaczenie i brzmi gorzej.

Odkryłem też wiele sekretnych możliwości Gita, jak
`git diff --color-words / --color-moved`, `git pull --autostash`
i wszystkie interaktywne procedury (`git add -p`).

Taa, no więc najlepszą częścią tłumaczenia jest satysfakcja
z wyczekiwanego ukończenia go.
