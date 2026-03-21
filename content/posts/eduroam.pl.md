---
title: Eduroam
date: 2026-03-20
description: Jak w końcu zrobić sobie dostęp do uczelnianego wi-fi, ale bez cudowania
---

Łączenie się do wi-fi jeszcze nigdy nie było tak skomplikowane jak eduroam.
Dlaczego? Bo zamiast rotować hasło za każdym razem, gdy ktoś ma mieć odebrany dostęp,
każdy loguje się do tego wi-fi swoim własnym hasłem.
A że jest to skrajnie niebezpieczne, bo ktokolwiek może postawić wi-fi o tej nazwie
i *przechwycić hasło* do uczelnianej poczty,
to trzeba się upewnić, że swoje bezcenne poświadczenia wysyłamy tylko zaufanemu serwerowi.
Sytuację komplikuje mnogość standardów, jakby nie mogli się wszyscy zwyczajnie dogadać.
Na domiar złego każda uczelnia ma kompletnie inne podejście, politykę i wykonanie.

Dalej skupię się na UWr (dobra wiadomość dla PWr: macie podobnie).
Inne uczelnie mogą mieć wszystko kompletnie inaczej, jedyna wspólna część to
dość ustandaryzowane informacje w skrypcie instalacyjnym z [cat.eduroam.org][cat].
Po pobraniu odpowiedniego skryptu możemy zajrzeć do certykifatów, które zawiera:
```
$ awk '/BEGIN CERT/,/END CERT/' < eduroam-linux-UoW.py | openssl asn1parse | grep -i root
  143:d=5  hl=2 l=  55 prim: PRINTABLESTRING   :Hellenic Academic and Research Institutions RootCA 2015
  344:d=5  hl=2 l=  55 prim: PRINTABLESTRING   :Hellenic Academic and Research Institutions RootCA 2015
```
Uwaga: `openssl asn1parse` czyta tylko pierwszy blok.
Przeczytanie pozostałych pozostawione jest jako ćwiczenie dla czytelnika.

# eduroam UWr

Sam certyfikat w formacie PEM wyciągnąłem mniej więcej poleceniem powyżej i można go pobrać [tu o][pem].

Uwaga: NIE UFAJ MI!
Porównaj, czy naprawdę wyciągnąłem ze skryptu do pobrania pod adresem
https://cat.eduroam.org/user/API.php?action=downloadInstaller&profile=1670&device=linux


Okazuje się, że ten certyfikat jest podpisany przez CA, które już z dużą pewnością jest
zaufane w każdym systemie. Mowa o Hellenic Academic and Research Institutions Root CA,
dawniej pod rozwiniętą nazwą, teraz skrócone do HARICA.
(Twoja uczelnia może nie być taka fajna!
Na przykład Politechnika Łódzka ma własny certyfikat TU Lodz Root.)

W takim razie wcale nie trzeba pobierać certyfikatu i nadal mieć bezpiecznie!

## PEAP czy TTLS

Wszystko jedno.
Działają oba, więc jeśli się da, to włączam oba, w razie gdyby jedno miało... przestać działać.

## wpa_supplicant

```
$ cat >> /etc/wpa_supplicant/wpa_supplicant.conf <<EOF
network={
        ssid="eduroam"
        eap=TTLS PEAP
        anonymous_identity="anonymous@uwr.edu.pl"
        identity="123456@uwr.edu.pl"
        password="hunter2"
        phase2="auth=MSCHAPV2"
        ca_cert="/usr/share/ca-certificates/mozilla/Hellenic_Academic_and_Research_Institutions_RootCA_2015.crt"
        ca_cert="/usr/share/ca-certificates/mozilla/HARICA_TLS_RSA_Root_CA_2021.crt"
}
EOF
```

## IWD
zaś iwd można ustawić tak:

```
$ cat > /var/lib/iwd/eduroam.8021x <<EOF
[Security]
EAP-Method=PEAP
EAP-Identity=anonymous@uwr.edu.pl
EAP-PEAP-CACert=/usr/share/ca-certificates/mozilla/HARICA_TLS_RSA_Root_CA_2021.crt
EAP-PEAP-ServerDomainMask=radius.uwr.edu.pl
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=123456@uwr.edu.pl
EAP-PEAP-Phase2-Password=hunter2

[Settings]
AutoConnect=true
EOF
```

## ConnMan

```
$ cat > /var/lib/connman/eduroam.config <<EOF
[service_eduroam]
Type=wifi
Name=eduroam
EAP=peap
CACertFile=/usr/share/ca-certificates/mozilla/HARICA_TLS_RSA_Root_CA_2021.crt
Phase2=MSCHAPV2
Identity=123456@uwr.edu.pl
AnonymousIdentity=anonymous@uwr.edu.pl
Passphrase=hunter2
EOF
```

## NetworkManager

```
nmcli connection add type wifi con-name eduroam         \
        connection.permissions $LOGNAME                 \
        802-11-wireless.ssid eduroam                    \
        802-11-wireless-security.key-mgmt wpa-eap       \
        802-11-wireless-security.group ccmp,tkip        \
        802-11-wireless-security.pairwise ccmp          \
        802-11-wireless-security.proto rsn              \
        802-1x.altsubject-matches DNS:radius.uwr.edu.pl \
        802-1x.anonymous-identity anonymous@uwr.edu.pl  \
        802-1x.eap peap                                 \
        802-1x.identity 123456@uwr.edu.pl               \
        802-1x.password hunter2                         \
        802-1x.phase2-auth mschapv2                     \
        ipv4.method auto                                \
        ipv6.addr-gen-mode stable-privacy               \
        ipv6.method auto
```

[CAT]: https://cat.eduroam.org
[pem]: /eduroam-UoW.pem
