//--------------------------------------------------------------------------------------------------
//Batch processing code for working with single-z .tif files
//Nowakowski lab, 6/29/21

//Function of this code is to apply standard settings to a set of .tif files contained within a single folder
//Images should be flattened to a single z slice before running
//All .tif files in the input folder will be processed with the same settings
//Major functions:
	//set pseudocolors to desired standards
	//set min and max intensity for each channel (should be manually determined for a given experiment before running)
	//save individual channel images as .tif, flattened .jpg, or both
//Output files will be put into new subfolders ('jpg_output' and 'tif_output') within the original folder

//--------------------------------------------------------------------------------------------------
//Optional: these defaults can be changed here to pre-populate the dialog box for later processing
C1_name = "DAPI";
C1_pseudo = "Grays";
C1min = 0;
C1max = 255;
C1despeck = "no";
C2_name = "";
C2_pseudo = "Green";
C2min = 0;
C2max = 255;
C2despeck = "no";
C3_name = "";
C3_pseudo = "Red";
C3min = 0;
C3max = 255;
C3despeck = "no";
C4_name = "";
C4_pseudo = "Cyan";
C4min = 0;
C4max = 255;
C4despeck = "no";

//--------------------------------------------------------------------------------------------------
//Open a window to select the folder containing the .tif files
dir = getDirectory("");

//--------------------------------------------------------------------------------------------------
//Determine whether or not to save tiffs and jpegs
	//tiffs should almost always be saved unless there is already a copy
	//jpegs should be saved for easy viewing or insertion into a presentation
yesno = newArray("no", "yes");
Dialog.create("Save settings"); //Start a dialog box to select whether or not to save tiffs and jpegs
Dialog.addChoice("Save tiffs?", yesno, "yes");
Dialog.addChoice("Save jpegs?", yesno, "yes");
Dialog.show();

save_tifs=Dialog.getChoice();
save_jpgs=Dialog.getChoice();

if (save_tifs=="yes") {
        tif_savepath= dir + "/tif_output"; //set savepath for tifs
		if(File.exists(tif_savepath)) { //check to see if there is a pre-existing tif folder
			Dialog.create("Warning!");
			Dialog.addMessage("Tiff folder already exists! Proceeding may overwrite the current folder.");
			Dialog.addMessage(tif_savepath);
			Dialog.addMessage("");
			Dialog.addChoice("Proceed anyway?", yesno, "no"); //give the user the option to overwrite or cancel
			Dialog.show();
			proceed_yn = Dialog.getChoice();

			if(proceed_yn=="no") exit("Delete or rename the existing folder before restarting\n" + tif_savepath);
		}
		
		File.makeDirectory(tif_savepath); //create the new folder for tifs
    }

if (save_jpgs=="yes") {
        jpg_savepath= dir + "/jpg_output"; //set savepath for jpgs
		if(File.exists(jpg_savepath)) { //check to see if there is a pre-existing jpg folder
			Dialog.create("Warning!");
			Dialog.addMessage("Jpeg folder already exists! Proceeding may overwrite the current folder.");
			Dialog.addMessage(jpg_savepath);
			Dialog.addMessage("");
			Dialog.addChoice("Proceed anyway?", yesno, "no"); //give the user the option to overwrite or cancel
			Dialog.show();
			proceed_yn = Dialog.getChoice();

			if(proceed_yn=="no") exit("Delete or rename the existing folder before restarting\n" + jpg_savepath);
		}
		
		File.makeDirectory(jpg_savepath); //create the new folder for jpgs
    }

//--------------------------------------------------------------------------------------------------
//User can enter all of their desired settings for each channel
//If the defaults at the top of this code were changed, those will pre-populate the dialog box
Dialog.create("Image settings");

LUT_options=getList("LUTs");
Dialog.addString("Channel 1 name:", C1_name);
//Set the channel name
Dialog.addChoice("Pseudocolor:", LUT_options, C1_pseudo);
//Set the pseudocolor
Dialog.addNumber("Minimum:", C1min);
//Set the minimum intensity
Dialog.addNumber("Maximum:", C1max);
//Set the maximum intensity
Dialog.addChoice("Despeckle?", yesno, C1despeck);
//Despeckle or not
Dialog.addMessage("");
Dialog.addString("Channel 2 name:", C2_name);
Dialog.addChoice("Pseudocolor:", LUT_options, C2_pseudo);
Dialog.addNumber("Minimum:", C2min);
Dialog.addNumber("Maximum:", C2max);
Dialog.addChoice("Despeckle?", yesno, C2despeck);
Dialog.addMessage("");
Dialog.addString("Channel 3 name:", C3_name);
Dialog.addChoice("Pseudocolor:", LUT_options, C3_pseudo);
Dialog.addNumber("Minimum:", C3min);
Dialog.addNumber("Maximum:", C3max);
Dialog.addChoice("Despeckle?", yesno, C3despeck);
Dialog.addMessage("");
Dialog.addString("Channel 4 name:", C4_name);
Dialog.addChoice("Pseudocolor:", LUT_options, C4_pseudo);
Dialog.addNumber("Minimum:", C4min);
Dialog.addNumber("Maximum:", C4max);
Dialog.addChoice("Despeckle?", yesno, C4despeck);

Dialog.addMessage("");
Dialog.addChoice("Save specific channel merges?", yesno, "no");
Dialog.addNumber("Number of custom merges:", 0);
Dialog.show();	

//Save all the settings in variables for the future processing
C1_name=Dialog.getString();
C1_pseudo = Dialog.getChoice();
C1min = Dialog.getNumber();
C1max = Dialog.getNumber();
C1despeck = Dialog.getChoice();

C2_name=Dialog.getString();
C2_pseudo = Dialog.getChoice();
C2min = Dialog.getNumber();
C2max = Dialog.getNumber();
C2despeck = Dialog.getChoice();

C3_name=Dialog.getString();
C3_pseudo = Dialog.getChoice();
C3min = Dialog.getNumber();
C3max = Dialog.getNumber();
C3despeck = Dialog.getChoice();

C4_name=Dialog.getString();
C4_pseudo = Dialog.getChoice();
C4min = Dialog.getNumber();
C4max = Dialog.getNumber();
C4despeck = Dialog.getChoice();

custom_merge_yn = Dialog.getChoice();
n_merges = Dialog.getNumber();

//--------------------------------------------------------------------------------------------------
//Final dialog box to set up custom merges, if desired

//Create an array of checkboxes corresponding to the number of merges indicated and four channels
if (custom_merge_yn=="yes"){
	rows = n_merges;
	columns = 4;
	n = rows*columns;
	labels = newArray(n);
	defaults = newArray(n);
	for (i=0; i<n; i+=4) { //set the checkboxes to the channel names
	  labels[i] = C1_name;
	  labels[i+1] = C2_name;
	  labels[i+2] = C3_name;
	  labels[i+3] = C4_name;
	}

	//Create the dialog box -- each row is a unique merge that will be processed
	Dialog.create("Channel merge setup");
	Dialog.addMessage("Specify the desired channels; each row is a unique merge");
	Dialog.addCheckboxGroup(rows,columns,labels,defaults);
	Dialog.show();

	//Extract the inputs into an array for each individual channel
	C1_checks = newArray(n_merges);
	C2_checks = newArray(n_merges);
	C3_checks = newArray(n_merges);
	C4_checks = newArray(n_merges);
	
	c=0;
	m=0;
	for (i=0; i<n; i++) {
		val = Dialog.getCheckbox();
		if (c==0) {
			C1_checks[m]=val;
		}
		if (c==1) {
			C2_checks[m]=val;
		}
		if (c==2) {
			C3_checks[m]=val;
		}
		if (c==3) {
			C4_checks[m]=val;
			c=-1;
			m=m+1;
		}
		c=c+1;
	}
}

//--------------------------------------------------------------------------------------------------
//Perform the actual processing on the images using the input settings

fileList = getFileList(dir);
//Pull out all of the files within the directory 

setBatchMode(true);

// Loop over all files in selected directory
for (i = 0; i < fileList.length; i++) {
    samp_name = fileList[i];
    // Skip files that don't have "tif" in the name
    if (samp_name.indexOf(".tif") < 0) {
        continue;
    }

    print(samp_name);

    open(samp_name);

    // Remove file extension
    samp_name = samp_name.replace(".tif", "");
    

    run(C1_pseudo);
    setMinAndMax(C1min, C1max);
    run("Next Slice [>]");
    run(C2_pseudo);
    setMinAndMax(C2min, C2max);
    run("Next Slice [>]");
    run(C3_pseudo);
    setMinAndMax(C3min, C3max);
    run("Next Slice [>]");
    run(C4_pseudo);
    setMinAndMax(C4min, C4max);
    saveAs("Tiff", tif_savepath+"/"+samp_name+".tif");
//save the merged image to revisit later
    saveAs("Jpeg", jpg_savepath+"/"+samp_name+".jpg");
//save the merged image as a jpeg

    run("Split Channels");

	
    c1_samp_name = "C1-"+samp_name+".tif";
    selectWindow(c1_samp_name);
    C1_fullname = samp_name+"_"+C1_name;
    if (C1despeck=="yes"){
        run("Despeckle");
    }
    if (save_tifs=="yes") {
        saveAs("Tiff", tif_savepath+"/"+C1_fullname+".tif");
    }
    if (save_jpgs=="yes") {
        run("Flatten");
        saveAs("Jpeg", jpg_savepath+"/"+C1_fullname+".jpg");
    }

    c2_samp_name = "C2-"+samp_name+".tif";
    selectWindow(c2_samp_name);
    C2_fullname = samp_name+"_"+C2_name;
    if (C2despeck=="yes"){
        run("Despeckle");
    }
    if (save_tifs=="yes") {
        saveAs("Tiff", tif_savepath+"/"+C2_fullname+".tif");
    }
    if (save_jpgs=="yes") {
        run("Flatten");
        saveAs("Jpeg", jpg_savepath+"/"+C2_fullname+".jpg");
    }

    c3_samp_name = "C3-"+samp_name+".tif";
    selectWindow(c3_samp_name);
    C3_fullname = samp_name+"_"+C3_name;
    if (C3despeck=="yes"){
        run("Despeckle");
    }
    if (save_tifs=="yes") {
        saveAs("Tiff", tif_savepath+"/"+C3_fullname+".tif");
    }
    if (save_jpgs=="yes") {
        run("Flatten");
        saveAs("Jpeg", jpg_savepath+"/"+C3_fullname+".jpg");
    }

    c4_samp_name = "C4-"+samp_name+".tif";
    selectWindow(c4_samp_name);
    C4_fullname = samp_name+"_"+C4_name;
    if (C4despeck=="yes"){
        run("Despeckle");
    }
    if (save_tifs=="yes") {
        saveAs("Tiff", tif_savepath+"/"+C4_fullname+".tif");
    }
    if (save_jpgs=="yes") {
        run("Flatten");
        saveAs("Jpeg", jpg_savepath+"/"+C4_fullname+".jpg");
    }

    //run the custom merge processing
    if (custom_merge_yn=="yes") {
    	chan_name_list=newArray(C1_name, C2_name, C3_name, C4_name);
		image_name_list=newArray(C1_fullname+".tif", C2_fullname+".tif", C3_fullname+".tif", C4_fullname+".tif");
		
		for (j = 0; j < n_merges; j++) {
			n_chans_in_merge = C1_checks[j]+C2_checks[j]+C3_checks[j]+C4_checks[j];
			//skip any rows wjth 0, 1, or 4 channels selected
			if (n_chans_in_merge==0) {
				print("Custom merge "+j+" skipped; " + "No channels selected");
				continue;
			}
			if (n_chans_in_merge==1) {
				print("Custom merge "+j+" skipped; " + "Individual channels already saved");
				continue;
			}
			if (n_chans_in_merge==4) {
				print("Custom merge "+j+" skipped; " + "Four-channel merge already saved");
				continue;
			}
			
			merge_chan_list = Array.copy(chan_name_list);
			merge_name_list = Array.copy(image_name_list);
			//delete the channels that are not selected (going backwards to preserve indexing)
			if (C4_checks[j]==0) {
				merge_chan_list=Array.deleteIndex(merge_chan_list,3);
				merge_name_list=Array.deleteIndex(merge_name_list,3);
			}
			if (C3_checks[j]==0) {
				merge_chan_list=Array.deleteIndex(merge_chan_list,2);
				merge_name_list=Array.deleteIndex(merge_name_list,2);
			}
			if (C2_checks[j]==0) {
				merge_chan_list=Array.deleteIndex(merge_chan_list,1);
				merge_name_list=Array.deleteIndex(merge_name_list,1);
			}
			if (C1_checks[j]==0) {
				merge_chan_list=Array.deleteIndex(merge_chan_list,0);
				merge_name_list=Array.deleteIndex(merge_name_list,0);
			}
			
			//merge the selected channels if two were selected
			if (n_chans_in_merge==2) {
				run("Merge Channels...", "c1="+merge_name_list[0]+ " c2="+merge_name_list[1]+ " create keep");
				merge_fullname=samp_name+"_"+merge_chan_list[0]+"-"+merge_chan_list[1];
				if (save_tifs=="yes") {
		        	saveAs("Tiff", tif_savepath+"/"+merge_fullname+".tif");
		    	}
		    	if (save_jpgs=="yes") {
		        	run("Flatten");
		        	saveAs("Jpeg", jpg_savepath+"/"+merge_fullname+".jpg");
		    	}
			}
			
			//merge the selected channels if three were selected
		    if (n_chans_in_merge==3) {
				run("Merge Channels...", "c1="+merge_name_list[0]+ " c2="+merge_name_list[1]+ " c3="+merge_name_list[2]+" create keep");
				merge_fullname=samp_name+"_"+merge_chan_list[0]+"-"+merge_chan_list[1]+"-"+merge_chan_list[2];
				if (save_tifs=="yes") {
		        	saveAs("Tiff", tif_savepath+"/"+merge_fullname+".tif");
		    	}
		    	if (save_jpgs=="yes") {
		        	run("Flatten");
		        	saveAs("Jpeg", jpg_savepath+"/"+merge_fullname+".jpg");
		    	}
			}
		}
    }

    run("Close All");
}

setBatchMode(false);

print("");
print("Finished!");