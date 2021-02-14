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
N = 512; % à modifier !!!
M = 512; % à modifier !!!
h = size(img,1);
w = size(img,2);

[col,row] = find(img>0);  
xbarycentre = mean(col);
ybarycentre = mean(row); 
m = [ybarycentre, xbarycentre];

t = linspace(0,2*pi,50);

R=ones(1,length(t));

spawn = img(max(1,min(h,floor(xbarycentre))), max(1,min(w,floor(ybarycentre))));  

poly = [];

for i = 1:length(t)  
    %if label==".\db\car"
    %    disp([ h ,floor(m(1)+(R(i)+1)*cos(t(i))) ,  w , floor(m(2)+((R(i)+1)*sin(t(i))))  ,img( floor(m(1)+R(i)*cos(t(i))), floor(m(2)+R(i)*sin(t(i))))])
    %end 
    
    rayon = R(i);
     
    
    while floor(ybarycentre+(R(i)*sin(t(i))))<h && floor(ybarycentre+(R(i)*sin(t(i))))>0 &&  floor(h-(xbarycentre+R(i)*-cos(t(i))))<w && floor(h-(xbarycentre+R(i)*-cos(t(i))))>0 &&img( floor(ybarycentre+(R(i)*sin(t(i)))), floor(h-(xbarycentre+R(i)*-cos(t(i))))) ==spawn 
      
        
    %if label==".\db\car"
    %    disp([ h ,floor(m(1)+(R(i)+1)*cos(t(i))) ,  w , floor(m(2)+((R(i)+1)*sin(t(i))))  ,img( floor(m(1)+R(i)*cos(t(i))), floor(m(2)+R(i)*sin(t(i))))])
    %end 
            R(i)=1+R(i);  
            rayon = (R(i)+1);
    end
    
end  

poly = ones(length(R),2);

for i = 1:length(R-1) 
poly(i,:) = [h-(xbarycentre+R(i)*-cos(t(i))),ybarycentre+(R(i)*sin(t(i))) ]; % à modifier !!!
end 

r = R ;

fd = rand(1,M); % à modifier !!!
end
