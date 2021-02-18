function my_tests()
% calcul des descripteurs de Fourier de la base de données
img_db_path = './db/';
img_db_list = glob([img_db_path, '*.gif']);
img_db = cell(1);
label_db = cell(1);
fd_db = cell(1);
for im = 1:numel(img_db_list);
    img_db{im} = logical(imread(img_db_list{im}));
    label_db{im} = get_label(img_db_list{im});
    disp(label_db{im}); 
    [fd_db{im},~,~,~] = compute_fd(img_db{im});
end

% importation des images de requête dans une liste
img_path = './dbq/';
img_list = glob([img_path, '*.gif']);
t=tic()

% pour chaque image de la liste...
for im = 1:numel(img_list)
   
    % calcul du descripteur de Fourier de l'image
    img = logical(imread(img_list{im}));
    [fd,r,m,poly] = compute_fd(img);
       
    % calcul et tri des scores de distance aux descripteurs de la base
    for i = 1:length(fd_db)
        scores(i) = norm(fd-fd_db{i});
    end
    [scores, I] = sort(scores);
       
    % affichage des résultats    
    close all;
    figure(1);
    top = 5; % taille du top-rank affiché
    subplot(2,top,1);
    imshow(img); hold on;
    plot(m(1),m(2),'+b'); % affichage du barycentre
    plot(poly(:,1),poly(:,2),'v-g','MarkerSize',1,'LineWidth',1); % affichage du contour calculé
    subplot(2,top,2:top);
    plot(r); % affichage du profil de forme
    for i = 1:top
        subplot(2,top,top+i);
        imshow(img_db{I(i)}); % affichage des top plus proches images
    end
    drawnow();
    waitforbuttonpress();
end
end

function [fd,r,m,poly] = compute_fd(img)
N = 500;
M = 500; 

h = size(img,1);
w = size(img,2);

% Récupération de tout les pixels blanc
[col,row] = find(img>0);  

% Calcul du barycentre
xbarycentre = mean(col);
ybarycentre = mean(row); 

m = [ybarycentre, xbarycentre];

t = linspace(0,2*pi,N );

% Calcul de la distance max
maxdist = min(max(col),max(row));

% On part d'un cercle de rayon maxdist/20 
R=ones(1,length(t))*maxdist/20;

% On ce donne une marge d'erreur de maxdist/20 (pour passer à travers les
% petites tâches noires) 
erreur = maxdist/5;

% On garde la couleur du point de début de l'algo
spawn = img(max(1,min(h,floor(xbarycentre))), max(1,min(w,floor(ybarycentre))));  

poly = [];

for i = 1:length(t)  
    rayon = R(i);

    % On regarde si le pixel courant est de la couleur du point de départ
    % (barycentre), si ce n'est pas le cas, on regarde si le pixel à une
    % distance d'erreur est aussi différent de la couleur du barycentre. Si
    % un des deux pixels est de la même couleur que le point de début,
    % alors on continue la boucle en augmentant le rayon
    while (floor((xbarycentre+(R(i)*sin(t(i)))))<h && floor((xbarycentre+(R(i)*sin(t(i)))))>0 &&  floor((ybarycentre+R(i)*-cos(t(i))))<w && floor((ybarycentre+R(i)*-cos(t(i))))>0 &&img( floor((xbarycentre+(R(i)*sin(t(i))))), floor((ybarycentre+R(i)*-cos(t(i))))) ==spawn) ||  (floor((xbarycentre+((R(i)+erreur)*sin(t(i)))))<h && floor((xbarycentre+((R(i)+erreur)*sin(t(i)))))>0 &&  floor((ybarycentre+(R(i)+erreur)*-cos(t(i))))<w && floor((ybarycentre+(R(i)+erreur)*-cos(t(i))))>0 &&img( floor((xbarycentre+((R(i)+erreur)*sin(t(i))))), floor((ybarycentre+(R(i)+erreur)*-cos(t(i))))) ==spawn)
        
            R(i)=1+R(i);  
            rayon = (R(i)+1);
            
    end
    
end  

poly = ones(length(R),2);

for i = 1:length(R-1) 
    
%Tracage de la ligne
poly(i,:) = [(ybarycentre+R(i)*-cos(t(i))),(xbarycentre+(R(i)*sin(t(i)))) ];  
end 

r = R;

%Calcul de la TF
rf_r0 = abs(R)/abs(R(1));

fd = fft(rf_r0(1:M)); 
end
