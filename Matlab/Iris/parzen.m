function y = parzen(x,a,nr,width)
%Funktion til udregning af Parzen-vindues funktion
h = width/sqrt(nr);
n = normal((x - a)/h);
%m = sum(n);
k = sum(n);
%k = m/(width/sqrt(nr));
%y = m/nr;
y = k/nr;
p=0;

%Der hvor der st�r m = sum(n) burde der st� k = sum(n)
%Der hvor der st�r k = .. skal bare slettes
%Der skal �ndres i ligningen for y, der ikke indg� m men i stedet k.

% Det er y vi vil regne, som svarer til pn(x), som er densitets estimat.