function y = parzen(x,a,nr,width)
%Funktion til udregning af Parzen-vindues funktion
h = width/sqrt(nr);
n = normal((x - a)/h); % x=centrum af viduet, a=feature v�rdien(x-aksen)
%m = sum(n);
k = sum(n);
%k = m/(width/sqrt(nr));
%y = m/nr;
y = k/nr; % Her divideres der ikke med V da vi lader n g� mod uendeligt, se slide 12 fra PR kursusgang 3.
p=0;

%Der hvor der st�r m = sum(n) burde der st� k = sum(n)
%Der hvor der st�r k = .. skal bare slettes
%Der skal �ndres i ligningen for y, der ikke indg� m men i stedet k.

% Det er y vi vil regne, som svarer til pn(x), som er densitets estimat.