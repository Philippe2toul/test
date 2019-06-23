
macro "projetX2 Action Tool - C037T0b11PT7b092" { //def du nom, de sa postion dans la barre commandes et du dessin de l'icone
// orig = repertoire général de départ
// dest = repertoire général d'arrivée
// dir = repertoire en cours
// dirdest = repertoire en cours destination
// diralign = repertoire alignées
// dirnb = repertoire alignées AEC et nb
orig = getDirectory("repertoire initial"); //récupère le nom du répertoire de départ
dest = getDirectory("repertoire des résultats"); //récupère le nom du répertoire d'arrivée
subFolderList = getFileList(orig); // récupère la liste des dossiers du répertoire de départ

for(r=0; r<subFolderList.length;r++){ // parcours tous les sous-répertoirs du répertoir de départ
	dir = orig+subFolderList[r]; //dir = repertoire de travail = repertoire de départ + sous répertoire actuel
    fileList = getFileList(dir); // liste des fichiers du répertoire de travail
    dirdest = dest + subFolderList[r]; // definit le nom du repertoire de destination ... on va le créer après
    diralign= dest + subFolderList[r] + "alignees"; // definit le nom du sous repertoire de destination "alignées"... on va le créer après
    dirnb= dest + subFolderList[r] + "AEC"; // definit le nom du sous repertoire de destination "AEC"... on va le créer après
    dirnx= dest + subFolderList[r] + "noyaux"; // definit le nom du sous repertoire de destination "noyaux"... on va le créer après
    diraligneesrognees= dest + subFolderList[r] + "alignées et rognées"; // definit le nom du sous repertoire de destination "alignées et rognées"... on va le créer après
    listeimages = getFileList(dir);
    File.makeDirectory(dirdest);  // créé : dirdest = repertoire en cours destination
    File.makeDirectory(diralign); // créé : diralign = repertoire alignées
    File.makeDirectory(dirnb);    // créé : dirnb = repertoire alignées AEC et nb
    File.makeDirectory(dirnx);    // créé : dirnx = repertoire alignées noyaux et nb
    File.makeDirectory(diraligneesrognees); // créé : diraligneesrognees = repertoire alignéesrognées
    setBatchMode(true); // fait le travail en mode batch = sans afficher d'image ou de fenetre
    // aligne tout le répertoire de travail "dir"
    run("Register Virtual Stack Slices", "source=[" + dir + "] output=[" + diralign + "] feature=Affine registration=[Moving least squares -- maximal warping                     ] advanced shrinkage initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=8 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=5 inlier_ratio=0.05 feature_extraction_model=Affine registration_model=[Moving least squares -- maximal warping                     ] interpolate shear=0.95 scale=0.95 isotropy=0.95");
	listealignees = getFileList(diralign); // récupère la liste des images du répertoire "alignées"
    open(diralign+"/"+listealignees[0]); // ouvre la première image "alignée"
    largeur = getWidth();  // récupère la largeur de la première image "alignée"
    hauteur = getHeight(); // récupère la hauteur de la première image "alignée"
    close(); // ferme image 1
       for(i=0; i<listealignees.length;i++){ // parcours le répertoire "alignées" et leur donne la bonne taille
	   open(diralign + "/"+listealignees[i]);
	   run("Scale...", "x=- y=- width=" + largeur + "height=" + hauteur +" interpolation=Bilinear average create");
	   save(diraligneesrognees + "/"+listealignees[i]);
	   close();
       }
 
       for(j=0; j<listealignees.length;j++){ // parcours le répertoire "alignées" et les crop de 400 points  sur les 4 cotés
       open(diraligneesrognees + "/"+listealignees[j]);
       makeRectangle(300, 300, largeur-600 , hauteur-600);
       run("Crop");
       save(diraligneesrognees + "/"+listealignees[j]); // sauve les images alignées et cropées dans le répertoire "alignées cropées"
       }
    listealigneesrognees = getFileList(diraligneesrognees); // récupère la liste des images alignées rognées
       for (f=0; f<listealigneesrognees.length; f++) { // parcours le répertoire "alignées rognées"
       path = diraligneesrognees +"/"+listealigneesrognees[f];                                             
       open(path); // ouvre l'image "alignée rognée" en cours [f] 
       nom_image=getTitle();   // récupère le nom de l'image ouverte    
       run("Colour Deconvolution", "vectors=[H AEC]"); // déconvolution avec le "vecteur AEC" => trois images : 1 = noyaux , 2 = AEC, 3= vert = sans interet
       selectWindow(nom_image + "-(Colour_1)"); // selectionne l'image 1 (noyaux)
       run("16-bit"); // converti "noyaux" en gris 16 bits
       run("Invert"); // l'inverse 
       saveAs("Tiff", dirnx + "/" + nom_image + "_nb.tif"); // la sauvegarde dans dirnx et ajoute "_nb.tif" à la fin du nom
       close();  // ferme l'image 
       selectWindow(nom_image + "-(Colour_3)"); // selectionne l'image 3
       close(); // ferme l'image 3 qui ne sert à rien
       selectWindow(nom_image + "-(Colour_2)");// selectionne l'image 2 (AEC)
       run("16-bit"); // converti "AEC" en gris 16 bits
       run("Invert"); // l'inverse
       saveAs("Tiff", dirnb + "/" + nom_image + "_nb.tif"); // la sauvegarde dans dirnb et ajoute "_nb.tif" à la fin du nom
       run("Close"); // ferme l'image                      
       }                                
    }
print( "c'est fini ... bravo fifi, tu es le meilleur"); // dir la vérité 
} // c'est fini :-)
