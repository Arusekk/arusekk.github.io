---
slug: zgin-przepadnij-ipv4-po-prostu-sie-skoncz
title: Zgiń, przepadnij, IPv4, po prostu się skończ!!!1!
date: 2022-01-10
description: IPv4 jest przestarzałe i nie ma przyszłości.  Po prostu to zrozum.  IPv6 jest jedynym rozwiązaniem.
---

IPv4 zostało wymyślone w latach [osiemdziesiątych][rfc791].
IPv6 pojawiło się zaraz w latach [dziewiędziesiątych][rfc1883],
dokładnie po czternastu latach praktycznego stosowania IPv4.

Minęło prawie 30 lat od tamtego czasu,
i nadal tkwimy w bajorze IPv4.

# Utknęliśmy?

Głównym problemem z IPv4 jest jego 32-bitowe adresowanie.
Ogranicza internet do 4 miliardów prawdziwych uczestników.
(w praktyce jeszcze mniej,
z powodu zarezerwowanych zakresów adresowych,
adresów rozgłoszeniowych, masek i tak dalej):
mniej niż połowa populacji świata!
Wszystkie jego ograniczenia wynikają z tego jednego problemu.

[rfc791]: https://datatracker.ietf.org/doc/html/rfc791
[rfc1883]: https://datatracker.ietf.org/doc/html/rfc1883

# Ale IPv4 jest prostsze!

## Krótkie adresy

Noż użyj nareszcie DNS/rDNS!

Oczywiście, że łatwiej zapamiętać `1.1.1.1` niż `2606:4700:4700::1111`.
Ale można też zapamiętać [one.one.one.one][1111].

Czy jest łatwiej zapamiętać `198.41.0.4` niż `2001:503:ba3e::2:30`?
Możliwe.  Ale czy nie jest jeszcze łatwiej zapamiętać `a.root-servers.net`?

Czy łatwiej zapamiętać `77.254.234.1` niż `2a02:a317:e13d:a780:21f:3bff:fe8c:49c3`?
Oczywiście, ale po prostu trzeba zapomnieć oba i nadać im nazwy.
Co powiesz na `arusekk.pl`, nieco bardziej chwytliwe, co nie?

Dłuższe adresy są nieuniknione jeśli chcemy numerycznie zaadresować
każdy komputer na świecie.

[1111]: https://one.one.one.one

## NAT (*Network address translation*, tłumaczenie adresów sieciowych)

Najoczywistszym sposobem poradzenia się z kurczącą się pulą adresów IPv4 było
jak się okazuje wynalezienie poplątanej warstwy tłumaczenia,
która bruździ we wszystkich istniejących znanych protokołach wyższych warstw,
gdzie ruter kłamie całej maszynie w podsieci, że dostaje globalnie jednoznaczny adres
(dając jej adres 'prywatny'),
i wtedy przechwytuje cały ruch wychodzący i przeprowadza ciągły atak MITM (*man-in-the-middle*)
przeciwko całej podsieci,
kłamie całej sieci WAN (*wide area network*),
że jest jedyną stroną wykonującą te wszystkie żądania i otrzymującą odpowiedzi,
w efekcie łamiąc zasadę ['Po prostu dostarcz te bity, głupcze!'][stupidnet].

[stupidnet]: https://isen.com/stupid.html

Więc nadal twierdzisz, że IPv4 jest prostsze?  To co powiesz na ALG (*application-level gateways*)?

Otóż zaimplementowanie „przezroczystego” NATu poprawnie wymaga nie tylko przepisania adresów IP.
Nie tylko przepisania identyfikatorów pakietów i portów TCP/UDP.
Wymaga również (w niektórych przypadkach) przechwycenia całego strumienia TCP,
i podmieniania tekstowych wystąpień „wewnętrznego” adresu IP na „zewnętrzny”;
SIP, IRC i FTP są dobrymi przykładami protokołów, które wysyłają niektóre adresy
i porty w treści połączenia.
(Tymczasem w IPv6 każdy adres jest po prostu globalnie trasowalny:
nie potrzeba żadnych dziwacznych rozgraniczeń.)

### CGNAT (*carrier-grade NAT*)

No... ten bydlak to ogromny przedłużacz agonii.  I nie podoba mi się.
Wyobraź sobie, że jesteś wielkim ISP (dostawcą internetu) i masz do wykorzystania 512 addresów.
Używasz 256 dla swoich 256 komputerów
a pozostałe 256 traktujesz jako zasób zamortyzowany.
Teraz każde połączenie twojego klienta może dostać totalnie inne IP,
bo ciesz się.
Jeśli twoim klientom nie przeszkadza bycie za NATem,
albo masz w głębokim poważaniu tych, którym to jednak przeszkadza,
no to hulaj dusza.

### STUN / TURN

NAT blokuje innowacje.  Oto dlaczego nowe protokoły warstwy czwartej
i ulepszenia protokołów takie jak MPTCP (*multipath TCP*) właściwie stoją w miejscu;
*status quo* NATów wymusza na nas używania wyłącznie istniejących rozwiązań technicznych
i budowanie frankensteinów takich jak *websockets*:
warstwa transportowa w warstwie aplikacji,
dla upewnienia się, że nic jej nie poturbuje.

STUN (różne rozwinięcia, T jak *traversal*, N jak NAT)
jest metodą na „przebijanie NATu”
(co nie istnieje w świecie IPv6, nie ma żadnej potrzeby przebijania czegokolwiek,
po prostu poznajesz adres, na który mają dotrzeć twoje pakiety,
i wtedy po prostu wysyłasz pakiet na parszywy adres!):
jeśli dwa komputery za NATami chcą się porozumieć,
muszą odstawić jakieś wybijanie dziur w firewallu (*firewall hole punching*)
(koncepcja nieistniejąca w pięknym świecie IPv6)
aby nawiązać połączenie.

Czasem ten chocholi taniec uniemożliwia
jakiś gorliwy NAT oszczędzający zasoby
(zwany symetrycznym NATem: najwzniońlejszym wytworzem ludzkiej niekompetencji),
więc jedyną pozostałą opcją jest przepychanie wszystkiego
przez jakiś serwer strony trzeciej.
I to się nazywa TURN
(znowy różne rozwinięcia, R na *relay*, N for NAT),
i jest wybitnym marnotrawstwem zasobów.

# Ale IPv4 jest bezpieczniejsze!

## Wykrywalność

Wysłanie po pakiecie do każdego osiągalnego adresu IPv4 zajmuje jedynie
parę godzin, jeśli nadawca ma jakieś przyzwoite łącze.
Jeśli serwujesz cokolwiek pod swoim adresem IPv4 (np. serwer SSH),
będzie nieustannie sondowany przez losowe botnety i crawlery (pełzacze?),
i to jest pewne.

Zakres prywatny też jest malutki.
Dokładnie dlatego [ataki *DNS rebinding*][rebinding] jest tak łatwo przeprowadzić
i dlatego wiele ruterów domowych tak usilnie próbuje im zapobiec
(kolejny raz łamiąc przestrzeganie standardów).

Iterowanie się po samej tylko jednej **podsieci** /64 w IPv6 zajęłoby 500000+ lat.
Nie ma najmniejszej opcji, żeby ktoś zgadnął twój adres, jeśli jego końcówka jest losowa.
Trzeba go znać: koniec z przypadkowymi sondami, zostają tylko wycelowane.
Jeśli ktoś celuje w „kogokolwiek”,
masz dużo mniejszą szansę zostać przypadkiem tym kimś kolwiek.

[rebinding]: https://en.wikipedia.org/wiki/DNS_rebinding

## Anonimowość

Chowanie się za jednym IP (v4) serwera VPN w niczym nie przewyższa
używania losowego adresu z jednej sieci /64 serwera VPN.
Po prostu zmieniaj sieć i adres, albo używaj paru adresów na raz
(niewybaczalne marnotrawstwo w przestarzałym IPv4) i nadal bądź globalnie trasowalny.

Cóż, jeśli chcesz prawdziwej anonimowości,
i tak lepiej użyj sobie czegoś typu [Tor][tor].

[tor]: https://www.torproject.org/

## Zapora sieciowa (*firewall*)

NAT jest z natury firewallem,
bo ktoś z zewnątrz nie ma żadnego sposobu dowiedzenia się,
z jakim „adresem wewnętrznym” rozmawia.
A nawet gdyby wiedział, nie ma żadnego sposobu wskazania ruterowi, by tam dostarczył pakiet.
[Chyba że jednak ma.][slipstream]
Tak więc NAT nie jest w niczym lepszy niż zachowawcza zapora śledząca połączenia.

I właśnie to mnie najbardziej frustruje.
Po prostu chcę mieć parę serwerów w mojej sieci.
To by także pomogło ogólnemu bezpieczeństwu,
na przykład gdyby adres rutera w sieci był globalnie trasowalny,
mógłby [dostać normalny certyfikat HTTPS][nowebpki].

[slipstream]: https://samy.pl/slipstream/
[nowebpki]: https://emilymstark.com/2021/12/24/when-a-web-pki-certificate-wont-cut-it.html

# Ale IPv4 jest szerzej wspierany!

Już nie.
Parę firm Big Tech przenosi się na [farmy serwerowe używające wyłącznie IPv6][ungleich].

[ungleich]: https://ungleich.ch/en-us/cms/blog/2019/01/09/die-ipv4-die/

# Ale IPv4 jest przetestowane w boju!

Tak, jest, i zostało uznane za gorsze i podrzędne względem IPv6,
które jest równie dobrze przetestowane w boju.

# Ale dostawcy internetu bardziej lubią IPv4!

Nie, nie lubią.
Było dla nich ciągłym wrzodem [nawet 8 lat temu][tmint].

[tmint]: https://www.tecmint.com/ipv4-and-ipv6-comparison/

# Ale mamy nadal mnóstwo czasu zanim IPv4 stanie się bezużyteczne!

Tak i nie.
Wprowadzenie NATów uczyniło IPv4 prawie całkiem bezużytecznym
do dowolnego „zaawansowanego” użycia, to znaczy gdy ktokolwiek
za NATem chciał zrobić cokolwiek poza przeglądaniem stron WWW,
więc i już jest bezużyteczne.

Ale to tylko kwestia czasu, kiedy rynkowa cena dzierżawy adresu IPv4
przekroczy wartość najęcia ziemniaczanego VPSu u typowego dostawcy hostingu.
Klienci hostingów zaczną najmować hosty chmurowe, które same są za NATem,
i przez to tak samo nieosiągalne jak każdy inny niedoszły serwer w sieci konsumenckiej,
co ekonomicznie pchnie ich do użycia IPv6,
tworząc strony dostępne wyłącznie po IPv6.

To zapotrzebowanie na dostęp do IPv6 zacznie pchać tych leniwych
przestarzałych dostawców, by wreszcie przyjęli przyszłość.

Pozwolenie IPv4 i IPv6 współistnieć było jedyną szansą dostawców,
by wprowadzili wsparcie dla IPv6 bez ingerowania w jakikolwiek sposób w IPv4, które już mieli.
Aby pozwolić beznadziejnym, bez końca rozsnącym stosom sztuczek
i oszustw paść wraz z odchodzącym IPv4,
tylko wciąż drożejącym w porównaniu z szybkim, tanim, czystym i oczywistym IPv6.
Zrób staremu dobremu IPv4 przysługę i przyznaj,
że jest już zwyczajnie przestarzałe i nieaktualne;
albo jeszcze lepiej, zapytaj dział sprzedaży swojego dostawcy o IPv6
i że rozważasz rozwiązanie umowy z powodu jego braku.
Razem możemy już teraz tworzyć przyszłość.
