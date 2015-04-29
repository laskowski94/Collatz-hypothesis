program collatz;								//Krzysztof Laskowski 

const numer_zera=48;								//ord(0)
      reszta_dziel_sys_dzi=10;

type lista = ^elemlisty;							//lista, ktorej elementami sa pojedyncze cyfry
     elemlisty = record								//uzywam do wczytania liczby w systemie dziesietnym
	    w : Byte;
	 nast : lista;
	  end;

     lista_Napiera = ^elemlistyNapiera;						//lista w ktorej zapisywane sa liczby w systemie Napiera
     elemlistyNapiera = record
	    w : Longint;
	 nast : lista_Napiera;
	  end;

     stack = ^elemstack;							//stos, ktorego elementami sa listy z liczbami w systemie Napiera
     elemstack = record
	liczba : lista_Napiera;
	  nast : stack;
	  end;

var s : stack;									
  n : Char;									//zmienna potrzeban do wczytywania danych
  
function empty(const s : stack) : Boolean;					//funkcja sprawdzajaca czy stos s jest pusty
begin
  empty:= s=nil;
end;
  
procedure init(var s : stack);							//procedura tworzaca pusty stos s
begin
  s:=nil;
end;

procedure push(var s : stack; x : lista_Napiera);				//wloz na stos s liczbe x
var pom : stack;
begin
  new(pom);
  pom^.nast:=s;
  pom^.liczba:=x;
  s:=pom;
end;

procedure pop(var s : stack; var x : lista_Napiera);				//zdejmij liczbe ze stosu s i przypisz ja x 
var pom : stack;
begin
  pom:=s;
  x:=s^.liczba;
  s:=s^.nast;
  dispose(pom);
end;

procedure usun_liste_Napiera(var do_usuniecia : lista_Napiera);			//procedura, ktora dealokuje wszystkie elementy listy do_usuniecia
var pom2 : lista_Napiera;							//zmienna pomocnicza, ktora zapamietuje obszar ktory trzeba usunac
begin
pom2:=do_usuniecia;
  while do_usuniecia<>nil do 							//dopoki lista nie jest pusta, usuwamy jej wszystkie elementy
  begin
    do_usuniecia:=pom2^.nast;
    dispose(pom2);
    pom2:=do_usuniecia;
  end;
end;

procedure usun_liste(var do_usuniecia : lista);					//to samo co poprzednia, tylko na listach innego typu
var pom2 : lista;
begin
pom2:=do_usuniecia;
  while pom2<>nil do 
  begin
    pom2:=do_usuniecia^.nast;
    dispose(do_usuniecia);
    do_usuniecia:=pom2;
  end;
end;

procedure clear(var s : stack);							//procedura,ktora usuwa stos oraz listy, ktore sa jego elementami
var pom : stack;
   pom2 : lista_Napiera;
begin
  while not empty(s) do
  begin
    pom2:=s^.liczba;
    pom:=s;
    s:=s^.nast;
    dispose(pom);
    usun_liste_Napiera(pom2);
  end;
end;

procedure dziesi_na_stack(var s : stack);	//procedura, ktora wczytuje liczbe w systemie dziesietnym, a nastepnie wklada na stos te liczbe w systemie Napiera
var zapis_dziesietny : lista;			//lista z liczba w systemie dziesietnym
	listaNapiera : lista_Napiera;		//lista z liczba w systemie Napiera

procedure wczytaj_dziesietny(var zapis_dziesietny : lista);	//zapis_dziesietny<>NIL|procedura wczytania liczby w systemie dziesietnym na liste zapis_dziesietny
var n : Char;							//zmienna potrzebna do wczytywania Charow
  pom1,pom2 : lista;						//zmienne pomocnicze, potrzebne w tworzeniu nowej listy
  i : Byte;							//potrzebne do zamianny Char na Byte
begin
  pom1:=zapis_dziesietny;
  while not eoln do
  begin
    read(n);
    i:=(ord(n)-numer_zera);					//kod Char - kod 0 = wczytana cyfra
    new(pom2);
    pom2^.w:=i;
    pom1^.nast:=pom2;
    pom1:=pom2;
  end;
  pom1^.nast:=nil;
  pom2:=zapis_dziesietny;
  zapis_dziesietny:=zapis_dziesietny^.nast;			//zapis_dziesietny jest lista z wczytana liczba dziesietna
  dispose(pom2);
end;

procedure podziel_dziesietna(var zapis_dziesietny : lista; var listaNapiera : lista_Napiera);	//listanapiera=nil|procedura zmieniajaca system dziesietny na Napiera
var reszta,pamiec : Byte;			//reszta-zapamietuje reszte z dzielenia|pamiec-zapamietuje liczbe, ktora sprawdzamy czy jest podzielna przez 2
  znajdz,usun : lista;				//znajdz-jest pierwsza cyfra rozna od zera|usun-zapamietuje liste do usuniecia 
  atrapa,pom : lista_Napiera;
  licznik : Longint;				//zlicza kolejne potegi 2
begin
  licznik:=-1;
  usun:=zapis_dziesietny;
  new(atrapa);
  atrapa^.nast:=listaNapiera;
  listaNapiera:=atrapa;
  znajdz:=zapis_dziesietny;
  while znajdz<>nil do				//dopoki liczba ktora dzielimy nie bedzie rowna 0
  begin
    if znajdz^.w=0 then znajdz:=znajdz^.nast;	//szukanie pierwszej cyfry roznej od 0
    reszta:=0;
    zapis_dziesietny:=znajdz;			//liczba ktora bedziemy dzielic przez 2
    if znajdz<>nil then inc(licznik);		//jesli to nie koniec, zwiekszamy potege 2
    while zapis_dziesietny<>nil do		
    begin
      pamiec:=zapis_dziesietny^.w;
      zapis_dziesietny^.w:=(zapis_dziesietny^.w+reszta) div 2;	//jesli w wczesniejszego dzielenia zostala reszta to do danej cyfry dodajemy 10 i dzielimy przez 2
      if (pamiec mod 2)<>0 then reszta:=reszta_dziel_sys_dzi else reszta:=0;	//sprawdzenie reszty
      zapis_dziesietny:=zapis_dziesietny^.nast;	
    end;
    if reszta<>0 then			//jesli reszta z dzielenia liczby przez 2 byla rowna 1 to zapisujemy potege 2
    begin 
      new(pom);
      pom^.w:=licznik;
      listaNapiera^.nast:=pom;
      listaNapiera:=pom;
    end;
  end;
  listaNapiera^.nast:=nil;
  listaNapiera:=atrapa^.nast;		//liczba reprezentowana w systemie Napiera
  dispose(atrapa);
  usun_liste(usun);
end;

begin
  new(zapis_dziesietny);			//lista z liczba dziesietna<>nil
  wczytaj_dziesietny(zapis_dziesietny);
  listaNapiera:=nil;
  podziel_dziesietna(zapis_dziesietny,listaNapiera); 
  push(s,listaNapiera);					//wlozenie liczby w systemie Napiera na stos
end;

procedure Napier_na_stack(var s : stack);		//procedura ktora wczytuje liczbe w systemie Napiera i wklada ja na  stos
var i : Longint;					//wczytywane liczby
  atrapa,pom,lista : lista_Napiera; 
begin
  lista:=nil;
  new(atrapa);
  atrapa^.nast:=lista;
  lista:=atrapa;
  while not eoln do
  begin
    read(i);						//wczytanie liczby i wpisanie jej do listy
    new(pom);
    pom^.w:=i;
    lista^.nast:=pom;
    lista:=pom;
  end;
  lista^.nast:=nil;
  lista:=atrapa^.nast;
  dispose(atrapa);
  push(s,lista);
end;

procedure wypisz_liste(lista : lista_Napiera);		//procedura wypisujaca wartosci ^.w z listy lista
begin
  while lista<>nil do
  begin
    if lista^.nast<>nil then write(lista^.w,' ')
    else write(lista^.w);
    lista:=lista^.nast;
  end;
end;

procedure kopiuj(var s : stack);			//procedura ktora kopiuje liste z czubka stosu i wklada ja na stos
var atrapa,lista1,lista2,pom : lista_Napiera;
begin
  lista1:=s^.liczba;					//przypisanie listy ze stosu do zmiennej lista1
  lista2:=nil;
  new(atrapa);
  atrapa^.nast:=lista2;
  lista2:=atrapa;
  while lista1<>nil do					//kopiowanie listy
  begin
    new(pom);
    pom^.w:=lista1^.w;
    lista2^.nast:=pom;
    lista2:=pom;
    lista1:=lista1^.nast;
  end;
  lista2^.nast:=nil;
  lista2:=atrapa^.nast;
  dispose(atrapa);
  push(s,lista2);					//wlozenie listy na stos
end;

procedure usun(var s : stack);				//procedura, ktora zdejmuje ze stosu czubek i usuwa liste ktora jest jego zawartoscia
var pom : stack;
begin
  pom:=s;
  s:=s^.nast;
  usun_liste_Napiera(pom^.liczba);
  dispose(pom);
end;

procedure przenies(var s : stack);			//procedura, ktora przenosi na czubek element, ktory znajduje sie na podanej glebokosci
var glebokosc,i : Integer;
  pom1,pom2,na_szczyt : stack;
begin
  read(glebokosc);					//wczytanie glepokosci elementu
  pom1:=s;
  if glebokosc>1 then for i:=0 to (glebokosc-2) do pom1:=pom1^.nast;//jesli glebokosc wieksza od 1 schodzimy do elementu na glebokosci mniejszej o 1 od podanej
  if glebokosc>0 then			//jesli glebokosc 0 to nic nie robimy, wpp przenosimy element pom1 na szczyt
  begin
    na_szczyt:=pom1^.nast;
    pom2:=na_szczyt^.nast;
    na_szczyt^.nast:=s;
    pom1^.nast:=pom2;
    s:=na_szczyt;
  end;
end;

procedure wypisz(s : stack);			//procedura wypisujaca zawartosc stosu zaczynajac on najglebszych elem
var licznik : Shortint;
  
procedure rekurencja(s : stack);		
begin
  if s<>nil then
  begin
    inc(licznik);				//przy kazdym zejsciu zwiekszamy licznik
    rekurencja(s^.nast);			//rekurencyjnie schodzimy na sam dol stosu
    write(licznik mod reszta_dziel_sys_dzi,': ^');	//wypisujemy glebokosc stosu
    dec(licznik);					//zmniejszamy licznik
    wypisz_liste(s^.liczba);				//wypisujemy liste  danej glebokosci
    writeln();
  end;
end;

begin
  licznik:=-1;
  writeln('[');
  rekurencja(s);
  writeln(']');
end;

procedure dodawanie(var s : stack);				//procedura, ktora zdejmuje 2 liczby ze stosu, dodaje je, a nastepnie wklada je na stos
var usun,lista1,lista2,poczatek,posortowana : lista_Napiera;	//usun-zapamietuje element do dealokacji|lista1,lista2-listy zdjete ze stosu
								//poczatek- zapamietuje poczatek listy|posortowana-posrtowana lista po dodaniu liczb
function rozne(var posortowana,lista : lista_Napiera):boolean;	//funkcja sprawdzajaca czy ostatnia wartosc z posortowanej listy jest taka sama 
begin								//jak wartosc z 1 elemntu nowej listy
  rozne:=true;							
  if posortowana^.w=lista^.w then				//jesli wartosci te same to element sprawdzany element z nowej listyjest usuwany, a
  begin								// lista:=lista^.nast
    usun:=lista;
    lista:=lista^.nast;
    dispose(usun);
    posortowana^.w:=(posortowana^.w+1);
    rozne:=false;						//jesli takie same to rozne:=false
  end;
end;

procedure uporzadkuj(var posortowana,lista : lista_Napiera);	//funkcja, ktora porzadkuje lista jesli jedna z dodawanych jest nilem
var koniec : boolean;
  usun : lista_Napiera;
begin
  koniec:=false;
  while (posortowana^.w=lista^.w) and not koniec do		//jesli ostatni element posortowanej listy jest rowny pierwszemu z listy ktora nie jest nilem
  begin								// to zwiekszamy wartosc listy posortowanej i szukamy elementu w 2 liscie, ktory jest inny
    if lista^.nast=nil then 					
    begin
      posortowana^.w:=(posortowana^.w+1);
      usun:=lista;
      koniec:=true;						//koniec gdy wszystkie takie same i 2 lista=nil,dzieki temu brak leniwego wyliczania
    end
    else begin
      posortowana^.w:=(posortowana^.w+1);
      usun:=lista;
      lista:=lista^.nast;
      dispose(usun);
    end;
  end;
  if koniec then						//jesli 2 lista na nilu to ustawiamy posortowana na nil
  begin
    posortowana^.nast:=nil;
    dispose(usun);
  end
  else posortowana^.nast:=lista;
end;

begin	
  pop(s,lista1);			//zdejmuje liste ze stosu i przypisuje jej wartosc lista1
  pop(s,lista2);
  if lista1=nil then poczatek:=lista2		//jesli jedna z list jest nilem to wynikiem jest druga lista
  else if lista2=nil then poczatek:=lista1
  else begin
    if lista1^.w<lista2^.w then
    begin
      posortowana:=lista1;
      lista1:=lista1^.nast;
    end
    else begin
      posortowana:=lista2;
      lista2:=lista2^.nast;
    end;
    poczatek:=posortowana;		//ustawiamy poczatek listy na mniejszym elemencie
    while (lista1<>nil) and (lista2<>nil) do	//dopoki ktoras z list nie jest pusta, tworzymy liste w ktorej ukladamy posortowane elementy
    begin
      if lista1^.w=lista2^.w then		//jesli elemnty sa rowne to jeden z nich likwidujemy, a do drugiego dodajemy jedynke
      begin
	posortowana^.nast:=lista1;
	posortowana:=lista1;
	posortowana^.w:=posortowana^.w+1;
	lista1:=lista1^.nast;
	usun:=lista2;
	lista2:=lista2^.nast;
	dispose(usun);
      end
      else if lista1^.w<lista2^.w then		//jesli ktorys z elementow jest mniejszy, to sprawdzamy czy ten mniejszy elemnt jest inny niz element z listy posort
      begin
	if rozne(posortowana,lista1) then
	begin
	  posortowana^.nast:=lista1;
	  posortowana:=lista1;
	  lista1:=lista1^.nast;
	end;
      end
      else if lista1^.w>lista2^.w then
      begin
	if rozne(posortowana,lista2) then
	begin
	  posortowana^.nast:=lista2;
	  posortowana:=lista2;
	  lista2:=lista2^.nast;
	end;
      end;
    end;
    if (lista1=nil) and (lista2=nil) then posortowana^.nast:=lista1
    else if lista1=nil then uporzadkuj(posortowana,lista2)
    else uporzadkuj(posortowana,lista1);
  end;
  push(s,poczatek);				//liste z liczba w reprezentacji Napiera wkladamy na stos
end;

procedure mnozenie(var s : stack);			//procedura wykonujaca mnozenie
var lista1,lista2,usun : lista_Napiera;
    dodaj : Longint;

procedure wrzuc_liczbe(dodaj : Longint; lista : lista_Napiera; var s : stack);
var atrapa,nowa,pom : lista_Napiera;
begin						//procedura ktora wklada na stos liste lista do ktorej dodany jest element dodaj
  new(atrapa);
  nowa:=nil;
  atrapa^.nast:=nowa;
  nowa:=atrapa;
  while lista<>nil do				//kopiowanie listy
  begin
    new(pom);
    pom^.w:=lista^.w;
    nowa^.nast:=pom;
    nowa:=pom;
    lista:=lista^.nast;
  end;
  nowa^.nast:=nil;
  nowa:=atrapa^.nast;
  while nowa<>nil do				//do nowej listy dodawana jest liczba dodaj
  begin
    nowa^.w:=(nowa^.w+dodaj);
    nowa:=nowa^.nast;
  end;
  nowa:=atrapa^.nast;
  dispose(atrapa);
  push(s,nowa);					//wkladamy liste na stos
end;

begin
  pop(s,lista1);
  pop(s,lista2);
  if lista1=nil then				//jesli ktoras lista jest pusta to wynikiem jest lista pusta
  begin
    push(s,lista1);
    usun_liste_Napiera(lista2);
  end
  else if lista2=nil then
  begin
    push(s,lista2);
    usun_liste_Napiera(lista1);
  end
  else begin			
    dodaj:=lista1^.w;
    wrzuc_liczbe(dodaj,lista2,s);	//wlozenie listy 1 na stos
    usun:=lista1;
    lista1:=lista1^.nast;
    dispose(usun);
    while lista1<>nil do		//petla w ktorej brany jest element z listy1 wykonywanie jest dodawanie tego elemntu do calej listy 2, nastepnie
    begin				//lista 2 jest wkladana na stos i dodawana do listy ktora jest pod nia
      dodaj:=lista1^.w;
      wrzuc_liczbe(dodaj,lista2,s);
      dodawanie(s);
      usun:=lista1;
      lista1:=lista1^.nast;
      dispose(usun);
    end;
    usun_liste_Napiera(lista2);
  end;
end;

procedure trzy(var s : stack);		//wklada na stos liczbe 3 w reprezentacji napiera
var pom,trojka : lista_Napiera;
begin
  new(trojka);
  trojka^.nast:=nil;
  trojka^.w:=1;
  new(pom);
  pom^.w:=0;
  pom^.nast:=trojka;
  trojka:=pom;
  push(s,trojka);
end;

procedure jeden(var s : stack);		//wklada na stos liczbe 1 w reprezentacji Napiera
var jedynka : lista_Napiera;
begin
  new(jedynka);
  jedynka^.nast:=nil;
  jedynka^.w:=0;
  push(s,jedynka);
end;

procedure parzysta(var lista : lista_Napiera);	//dzieli parzyste liczby przez 2
var start : lista_Napiera;
begin
  if lista<>nil then
  begin
    start:=lista;
    while lista<>nil do
    begin
      lista^.w:=(lista^.w-1);			//zmniejszenie wszystkich poteg 2 o jeden
      lista:=lista^.nast;
    end;
    lista:=start;
  end;
end;

procedure pusta(var s : stack);	//zastepuje wartosc na czubku stosu wynikiem zaaplikowania funkcji T do jej podlogi i wypisuje ten wynik na wyjscie
var lista : lista_Napiera;

procedure zaokraglij(var lista : lista_Napiera); // procedura ktora szuka pierwszej nieujemnej potegi 2
var usun : lista_Napiera;
begin
  if lista<>nil then
  begin
    while lista^.w<0 do
    begin
      usun:=lista;
      lista:=lista^.nast;
      dispose(usun);
    end;
  end;
end;

begin
  pop(s,lista);
  zaokraglij(lista);
  push(s,lista);
  if lista^.w=0 then		//jesli nieparzysta
  begin
    trzy(s);
    mnozenie(s);		//mnozenie przez 3
    jeden(s);
    dodawanie(s);		//dodanie 1
  end;
  parzysta(s^.liczba);		//podzielenie przez 2
  write('^');
  wypisz_liste(s^.liczba);	//wypisanie liczby
  writeln();
end;

function kopiuj_liste(lista : lista_Napiera) : lista_Napiera;//funkcja ktorej wynikiem jest skopiowana lista : lista_Napiera
var pom,nowa,atrapa : lista_Napiera;
begin
  new(atrapa);
  nowa:=nil;
  atrapa^.nast:=nowa;
  nowa:=atrapa;
  while lista<>nil do		//kopiowanie elemntow listy lista
  begin
    new(pom);
    pom^.w:=lista^.w;
    lista:=lista^.nast;
    nowa^.nast:=pom;
    nowa:=pom;
  end;
  nowa^.nast:=nil;
  nowa:=atrapa^.nast;
  dispose(atrapa);
  kopiuj_liste:=nowa;
end;

procedure poszukiwania(s : stack);		//procedura poszukiwania opisana algorytmem z zadania
var dzialania : stack;
  a,b,c,d,e,x,y,i,j,kopia : lista_Napiera;
  dosc : Boolean;

procedure przypisz(s : stack; var lista : lista_Napiera);	//procedura,ktora kopiuje liste z czubka stosu i przypisuje ja liscie lista 
var atrapa,pom,lista2 : lista_Napiera;
begin
  lista:=nil;
  new(atrapa);
  atrapa^.nast:=lista;
  lista:=atrapa;
  lista2:=s^.liczba;		//lista, ktorej wartosci beda kopiowane
  while lista2<>nil do
  begin
    new(pom);
    pom^.w:=lista2^.w;
    lista^.nast:=pom;
    lista:=pom;
    lista2:=lista2^.nast;
  end;
  lista^.nast:=nil;
  lista:=atrapa^.nast;
  dispose(atrapa);
end;
 
function podloga(x : lista_Napiera): lista_Napiera;	//funkcja, ktorej wynikiem jest lista z liczba calkowita
var atrapa,nowa,pom : lista_Napiera;
  koniec : Boolean;
begin
  koniec:=false;
  while (x<>nil) and (not koniec) do					//x moze byc nilem
  begin
    if x^.w<0 then x:=x^.nast						//szuka pierwszej wartosci >=0
    else koniec:=true;
  end;
  new(atrapa);
  nowa:=nil;
  atrapa^.nast:=nowa;
  nowa:=atrapa;
  while x<>nil do				//tworzenie nowej listy i kopiowanie liczby calkowitej
  begin
    new(pom);
    pom^.w:=x^.w;
    nowa^.nast:=pom;
    nowa:=pom;
    x:=x^.nast;
  end;
  nowa^.nast:=nil;
  podloga:=atrapa^.nast;
  dispose(atrapa);
end;

function logarytm(y : lista_Napiera): lista_Napiera;	//funkcja, ktorej wynikiem jest lista z podloga z logarytmu przy podstawie 2 z y
var poczatek : lista_Napiera;
  najwieksza : Longint;
	jest : Boolean;

function dziesietna(i : Longint) : lista_Napiera;	//funkcja zamieniajaca liczbe typu longint z systemu dziesietnego na liczbe zapisana
var atrapa,lista,pom : lista_Napiera;			//w liscie w  systemie Napiera
  licznik : Longint;
begin
  licznik:=0;
  lista:=nil;
  new(atrapa);
  atrapa^.nast:=lista;
  lista:=atrapa;
  while i<>0 do
  begin
    if (i mod 2)=1 then					//jesli reszta z dzielenia jeden to wpisujemy potege dwojki do listy napiera
    begin
      new(pom);
      pom^.w:=licznik;
      lista^.nast:=pom;
      lista:=pom;
    end;
    i:=(i div 2);
    inc(licznik);
  end;
  lista^.nast:=nil;
  lista:=atrapa^.nast;
  dispose(atrapa);
  dziesietna:=lista;
end;
 
begin
  najwieksza:=0;
  poczatek:=y;
  jest:=false;
  if y=nil then logarytm:=nil
  else begin
    while y^.nast<>nil do y:=y^.nast;
    if y^.w=0 then
    begin
      if poczatek=y then logarytm:=nil
      else begin 
	najwieksza:=y^.w;
	jest:=true;				//sprawdzanie czy liczba jest wieksza od 1
      end;
    end						//logarytm z liczb <=1 jest rowny zero
    else if y^.w>0 then
    begin
      najwieksza:=y^.w;
      jest:=true;
    end;
  end;
  if jest then logarytm:=dziesietna(najwieksza);	//jesli tak to zamieniamy liczbe na reprezentacje Napiera
end;

function porownaj(lista1,lista2 : lista_Napiera): Boolean; //jesli true to lista1>lista2|funkcja porownujaca 2 liczby w systemie Napiera
var wieksza : Boolean;
  poczatek1,poczatek2,rowna : lista_Napiera;

begin
  wieksza:=false;					//badam dlugosc obydwu list, jesli jedna z list jest dluzsza to obcinam jej poczatek tak, aby
  poczatek1:=lista1;					//obydwie listy byly tej samej dlugosci
  poczatek2:=lista2;
  while (lista1<>nil) and (lista2<>nil) do
  begin
    lista1:=lista1^.nast;
    lista2:=lista2^.nast;
  end;						
  if lista2=nil then					//jesli lista2 jest krotsza, ustawiam poczatek na poczatku listy1, a nastepnie przechodzac dalszym
  begin							//zwiekszam wskaznik dalszy oraz wskaznik na poczatku, do momentu gdy wskaznik na koncu nie 
    if lista1<>nil then wieksza:=true;			//bedzie pokazywal na nil, wtedy wskaznik wczesniejszy bedzie pokazywal poczatek listy, ktora
    rowna:=poczatek1;					//bedzie miala dlugosc listy2
    while lista1<>nil do
    begin
      lista1:=lista1^.nast;
      rowna:=rowna^.nast;
    end;
    lista1:=rowna;
    lista2:=poczatek2;
  end
  else if lista1=nil then
  begin
    rowna:=poczatek2;
    while lista2<>nil do
    begin
      lista2:=lista2^.nast;
      rowna:=rowna^.nast;
    end;
    lista2:=rowna;
    lista1:=poczatek1;
  end;
  while lista1<>nil do					//w momencie gdy obie listy sa rowne, porownuje ich kolejne elemnty, jezeli ktorys jest wiekszy
  begin							//to przypisuje tej liscie wartosc wiekszej liczby, jesli sa takie same to nic nie robie
    if lista1^.w>lista2^.w then wieksza:=true		//na koncu ta lista jesli zmienna wieksza jest true, to znaczy ze lista1 jest wieksza
    else if lista1^.w<lista2^.w then wieksza:=false;
    lista1:=lista1^.nast;
    lista2:=lista2^.nast;
  end;
  porownaj:=wieksza;
end;

function czy_rowne(lista1,lista2 : lista_Napiera): Boolean;	//funkcja sprawdzajaca czy listy sa rowne
var rowne : boolean;
begin
  rowne:=true;
  while (lista1<>nil) and (lista2<>nil) and (rowne) do
  begin
    if lista1^.w<>lista2^.w then rowne:=false;
    lista1:=lista1^.nast;
    lista2:=lista2^.nast;
  end;
  if (lista1<>nil) or (lista2<>nil) then rowne:=false;
  czy_rowne:=rowne;
end;

function czy_nieparzysta(lista : lista_Napiera): Boolean;//podane liczby beda zawsze calkowite, nie bedzie ujemnych poteg|funkcja sprawdzajaca czy liczba nieprazysta
var nieparzysta1 : boolean;
begin
  nieparzysta1:=false;
  if lista<>nil then
    if lista^.w=0 then nieparzysta1:=true;
  czy_nieparzysta:=nieparzysta1;
end;

begin
  init(dzialania);			//tworze stos, na ktorym bede wykonywal dzialania dodawania i mnozenia
  przypisz(s,e);			//przypisuje lista odpowiedznie wartosci
  s:=s^.nast;
  przypisz(s,d);
  s:=s^.nast;
  przypisz(s,c);
  s:=s^.nast;
  przypisz(s,b);
  s:=s^.nast;
  przypisz(s,a);
  y:=nil;
  i:=nil;
  j:=nil;
  writeln('{');
  x:=d;
  repeat						// start petli repeat
    usun_liste_Napiera(y);				//usuniecie list z poprzedniej petli
    usun_liste_Napiera(i);
    usun_liste_Napiera(j);
    y:=podloga(x);						//podloga dziala
    i:=nil;
    dosc:=false;
    kopia:=kopiuj_liste(b);				//przypisanie wartosci j wyniku mnozenia listy B i logarytmu z y
    push(dzialania,kopia);
    push(dzialania,logarytm(y));
    mnozenie(dzialania);
    pop(dzialania,j);						// j:=B*log(y)
    while not dosc and porownaj(y,a) do				//jesli y>A
      if porownaj(i,j) or czy_rowne(i,j) then dosc:=true	//jesli i>=j
      else begin
	if czy_nieparzysta(y) then
	begin
	  push(dzialania,y);				//wykonanie dzialania (3*i+1) div 2 w reprezentacji Napiera
	  trzy(dzialania);
	  mnozenie(dzialania);
	  jeden(dzialania);
	  dodawanie(dzialania);
	  pop(dzialania,y);
	  parzysta(y);
	end
	else parzysta(y);
	push(dzialania,i);				//wykonanie dzialania inc(i)
	jeden(dzialania);
	dodawanie(dzialania);
	pop(dzialania,i);		
      end;
    if dosc then
    begin
      write('^');
      wypisz_liste(x);					//wypisanine list
      writeln();
    end;
    push(dzialania,x);					//x:=x+C
    kopia:=kopiuj_liste(c);
    push(dzialania,kopia);
    dodawanie(dzialania);
    pop(dzialania,x);
  until porownaj(x,e);					//dopoki x>E
  writeln('}');
  usun_liste_Napiera(a);				//dealokacja list
  usun_liste_Napiera(b);
  usun_liste_Napiera(c);
  usun_liste_Napiera(e);
  usun_liste_Napiera(x);
  usun_liste_Napiera(y);
  usun_liste_Napiera(i);
  usun_liste_Napiera(j);
end;
  
begin							//program glowny
  init(s);						//utworzenie stosu
  repeat
    read(n);						//wczytanie polecenia
    case n of   
      '#' : begin
	      dziesi_na_stack(s);
	      readln();
	    end;
      '^' : begin
	      Napier_na_stack(s);
	      readln();
	    end;
      '+' : begin
	      dodawanie(s);
	      readln();
	    end;
      '*' : begin
	      mnozenie(s);
	      readln();
	    end;
      '=' : begin
	      kopiuj(s);
	      readln();
	    end;
      '\' : begin
	      usun(s);
	      readln();
	    end;
      '@' : begin
	      przenies(s);
	      readln();
	    end;
      '$' : begin
	      wypisz(s);
	      readln();
	    end;
      '?' : begin
	      poszukiwania(s);
	      readln();
	    end;
      else pusta(s);
    end;
  until eof;				//dopoki nie koniec pliku
  clear(s);				//wyczyszczenie stosu
end.
