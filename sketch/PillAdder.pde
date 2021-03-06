class PillAdder {
    
    int pillPixelX = 0;
    int pillPixelY = 0;
    int pillColorRangeMin = 0;
    int pillColorRangeMax = 0;
    int framesToTake = 100;
    int scannerBoxW = 10;

    int bttnBoxColor = #1d60fe;
    int textBttnColor = color(225);

    boolean informationSeen = false;
    boolean drawColorBoxes = false;

    String xmlPillName = "";

    //Constructor
    PillAdder() {

    }
    
    void start() {
        drawUI();
        pillAdder();    
    }

    void drawUI() {

         //Tegner baggrunden.
        uielement.backgroundForScannerAndPillAdder();   

        //Laver en tilbage knap, der går tilbage til menuen
        uielement.returnBttn();
        uielement.infoHelpBttn("Her kan du tilføje dine piller til systemet, så systemet kan genkende dem, og sende dig relevante notifikationer.\nFor at starte, skal du anbringe dine piller indenfor den røde kasse, og dernæst trykke på den pille du ønsker at gemme. \nHerefter tryk på 'Start', og lad systemet arbejde. ");

        //Kamera-området.
        uielement.drawCameraArea();
        
        //Tegner en boks om den valgte pixel.
        rectMode(RADIUS);
        noFill();
        stroke(0, 255, 0);
        rect(pillPixelX, pillPixelY, scannerBoxW, scannerBoxW);
        rectMode(CORNER);

        stroke(0);
        textAlign(CENTER, CENTER);
        textSize(textSize);
        
        fill(c);
        rect(longbarFieldX, longbarFieldY, longbarFieldW, longbarFieldH);
        fill(0);
        text("Farven på valgte pille", longbarFieldX, longbarFieldY, longbarFieldW, longbarFieldH);

        //Seperator.
        line(camW+seperatorW, 0, camW+seperatorW, height);
        //Liste af piller.
        fill(200);
        rect(listTextX, listTextY, listTextW, listTextH);
        fill(162);
        rect(listTextX, listTextY+listTextH+seperatorW, listTextW, listSplitterW);
        fill(0);
        text("Gemte piller:", listTextX, listTextY, listTextW, listTextY+listTextH-10);

        //Indhenter elementer fra XML-filen, og indskriver det i pillelisten.
        for (int i = 0; i < xmlHandler.children.length-1; ++i) {
            xmlHandler.load(i+1);
            xmlPillName = xmlHandler.outputName;
            xmlPillName = xmlPillName.substring(0,1).toUpperCase() + xmlPillName.substring(1).toLowerCase();

            /*averageColor = (xmlHandler.outputMinRange+xmlHandler.outputMaxRange)/2;
            
            int r=(averageColor>>16)&255;
            int g=(averageColor>>8)&255;
            int b=averageColor&255; 

            println(hex(xmlHandler.outputMinRange, 6) + " " + hex(xmlHandler.outputMaxRange, 6));*/

            fill(188);
            rect(listTextX, listTextY+seperatorW+listSplitterW+(i+1)*(listTextH+seperatorW), listTextW, listTextH);
            fill(0);
            textAlign(LEFT, CENTER);
            text(xmlPillName, listTextX+seperatorW, listTextY+seperatorW+listSplitterW+(i+1)*(listTextH+seperatorW)+textSize/2+6);

            if(drawColorBoxes) {
                fill(r, g, b);
                rect(listColorBoxX, listTextY+seperatorW+listSplitterW+(i+1)*(listTextH+seperatorW), listColorBoxW, listTextH);
            }

        }

        //Reset.
        rectMode(CENTER);
        noStroke();

    }

    //Kører pill-adder-systemet.
    void pillAdder() {

        //Hvis boolean til hjælpe-boksen er true, så vises en besked.
        if (!informationSeen) {
            uielement.informationDialog("Hjælp", "Velkommen til Pill-Adder.\n\nHer kan du tilføje dine piller til systemet, så systemet kan genkende dem, og sende dig relevante notifikationer.\nFor at starte, skal du anbringe dine piller indenfor den røde kasse, og dernæst trykke på den pille du ønsker at gemme. \nHerefter tryk på 'Start', og lad systemet arbejde. ", "information");
            informationSeen = true;
        }

        //Åbner hjælp-boksen via en boolean.
        if (uielement.button(bttnRightX, bttnRightX+bttnWidth, bttnRightY, bttnRightY+bttnHeight, bttnBoxColor, textBttnColor, textSize, "Hjælp")) {
            informationSeen = false;
        }

        //Start-knap, til at starte analysering af pixel.
        if (uielement.button(bttnLeftX, bttnLeftX+bttnWidth, bttnLeftY, bttnLeftY+bttnHeight, bttnBoxColor, textBttnColor, textSize, "Start") && pillPixelX != 0 && pillPixelY != 0) { //Efter en pixel / pille (farve) er blevet valgt, begynd at læse farven. Kan kun blive trykket på, hvis der er blevet valgt en pille / pixel at analysere.
            
            //Sørger for at alle variablerne er reset til standard, så at værdier fra en tidligere analyse, ikke bærer over til en ny.
            String pillName = null;
            String pillColor = null;

            //Opdateres pillColorRanges' således at værdierne kan sammenlignes, og sættes ind i variablerne.
            loadPixels(); 
            pillColorRangeMin = pixels[pillPixelY*width+pillPixelX];
            pillColorRangeMax = pixels[pillPixelY*width+pillPixelX];

            //Viser en informations-boks om scanningen.
            uielement.informationDialog("Når scanneren kører, undlad at placere noget foran kameraet, og lad systemet arbejde.\nSystemet vil fortælle dig, når scanningen er fuldført.\n\nTryk på OK, for at fortsætte.\n");

            //Vi tager x-antal billeder af den angivne pixel, og checker dens farve. 
            for (int i = 0; i < framesToTake; ++i) {
                
                delay(100);
                cam.read();
                image(cam, camW - 639, 240); //Den nye frame bliver tegnet.
                loadPixels(); //Pixels'array'en opdateres, således at pixels'ne kan blive læst.
                
                //If-statement der spørger om den nuværende værdi i pillColorRangeMin er mindre end den læste på skærmen.
                if (pixels[pillPixelY*width+pillPixelX] < pillColorRangeMin) {
                    pillColorRangeMin = pixels[pillPixelY*width+pillPixelX];
                }                    

                //If-statement der spørger om den nuværende værdi i pillColorRangeMax er større end den læste på skærmen.
                if (pixels[pillPixelY*width+pillPixelX] > pillColorRangeMax) {
                    pillColorRangeMax = pixels[pillPixelY*width+pillPixelX];
                }

                loadPixels();
                println(i + ": current color: " + pixels[pillPixelY*width+pillPixelX]);
            
            }

            println("min range: " + pillColorRangeMin);
            println("max range: " + pillColorRangeMax);

            //Nu hvor pillen er blevet registreret, og givet en farverækkevidde, spørger vi brugeren om at given pillen et navn.
            String nameInput = showInputDialog("Færdig! Giv Pillen et navn:\n\nHøjeste Værdi: " + pillColorRangeMax + "\nLaveste Værdi: " + pillColorRangeMin + "\n\nTryk OK for at fortsætte, tryk Cancel for at afbryde");
            
            //Checker om brugeren har givet pillen et navn, eller afbrudt processen. Hvis nameInput ikke fik et navn / blev afbrudt vil nameInput være lig med null.
            if (nameInput == null || nameInput.equals("")) { //Ikke noget input eller afbrudt.
                
                uielement.informationDialog("Afbrudt, pillen blev ikke gemt.");
            
            } else { //Brugeren har intastet et navn.
                
                pillName = nameInput; //Navnet bliver angivet i en variabel.
                String colorInput = showInputDialog("Angiv pillen's farve:"); //Spørger efter farven på pillen.
                
                //Hvis ingen farve er opgivet, får den bare en "ukendt"-label.
                if (colorInput.equals(null) || colorInput.equals("")) {
                    //Brugeren har ikke angivet en farve.
                    pillColor = "ukendt";

                } else { //Pillens farve bliver puttet ind i en variabel.
                    //Brugeren har angivet en farve.
                    pillColor = colorInput;
                
                }
                
                xmlHandler.save(pillName, pillColor, pillColorRangeMin, pillColorRangeMax);
                pillPixelX = 0;
                pillPixelY = 0;
            
            }

        }

        //Vælg-pixel-boks.
        if (uielement.button(scanAreaX, scanAreaX+scanAreaW, scanAreaY, scanAreaY+scanAreaH)) { //Tryk på en pille, så systemet ved hvilken pixel der skal identificeres.
        
            pillPixelX = mouseX;
            pillPixelY = mouseY;

            loadPixels();
            c = pixels[mouseY*width+mouseX];

            println(hex(c, 6));

        }

    }


}