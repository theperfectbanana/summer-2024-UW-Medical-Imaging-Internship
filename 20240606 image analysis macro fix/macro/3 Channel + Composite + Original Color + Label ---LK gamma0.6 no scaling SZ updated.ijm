//Sequence extracts original file name (used to be assigned to montage later)
orig_stack = getTitle();
run("Duplicate...", "duplicate");
stack = getTitle();
num_channels = nSlices;
// Get each slice label.
labels = newArray(num_channels);
for (i = 1; i <= num_channels; i++) {
    setSlice(i);
    labels[i-1] = getInfo("slice.label");
}
// Extract channel from label by removing common strings.
channels = newArray(num_channels);
// Find smallest channel length.
min_len = 256;
for (i = 0; i < num_channels; i++) {
    len = lengthOf(labels[i]);
    if (len < min_len)
	min_len = len;
}
// Remove common leading characters.
trim_start_by = 0;
complete = false;
for (p = 0; p < min_len; p++) {
    index = 0;
    for (i = 1; i < num_channels; i++) {
	prev_label = labels[i-1];
	label = labels[i];
	if (charCodeAt(label, p) != charCodeAt(prev_label, p))
	    complete = true;
    }
    if (!complete)
	trim_start_by = p + 1;
}
// Remove common trailing characters. 
trim_end_by = 0;
complete = false;
for (p = 0; p < min_len; p++) {
    index = 0;
    for (i = 1; i < num_channels; i++) {
	prev_label = labels[i-1];
	offset_prev = -1 + lengthOf(prev_label);
	label = labels[i];
	offset = -1 + lengthOf(label);
	if (charCodeAt(label, offset - p) != charCodeAt(prev_label, offset_prev - p))
	    complete = true;
    }
    if (!complete)
	trim_end_by = p + 1;
}
//Sequence Creates images individual channels and composite. (JG/SZ)
    run("Rename...", "title=[placeholder]");
	run("Duplicate...", "title=stack duplicate");
	run("Split Channels");
	selectWindow("C1-stack");
	run("Gamma...", "value = 0.6");
	selectWindow("C2-stack");
	run("Gamma...", "value = 0.6");
	selectWindow("C3-stack");
	run("Gamma...", "value = 0.6");
	run("Merge Channels...", "c1=C1-stack c2=C2-stack c3=C3-stack create keep");
	selectWindow("stack");
	run("Flatten");
	run("Images to Stack", "name=[Stack with composite] title=[] use");
	run("Stack to Images");
//Makes a stack in designated order. (JG)
	run("Concatenate...", "  image1=[stack-1] image2=C1-stack image3=C2-stack image4=C3-stack image5=[-- None --]");;
	run("Make Montage...", "columns=2 rows=2 scale=1");
	
//Sequence closes all windows except currently selected open window
currentImageID=getImageID();           //get image ID for current image
totalOpenImages=nImages;                //get total number of open images
imageIDs=newArray(nImages);          //create array to hold all image IDs
for(i=0;i<nImages;i++){                        //and populate array with
//image IDs
     selectImage(i+1);
     imageIDs[i]=getImageID();
};

for(i=0;i<totalOpenImages;i++){           //run through array of image IDs
     if(imageIDs[i]!=currentImageID){     //and check whether it matches
//current image
         selectImage(imageIDs[i]);             //if it doesn't match,
//select image and close it
         close();
     };
};
//Sequene renames montage with original file name instead of "stack" (JG)  
rename(orig_stack + " " + getTitle());

//Add file name as title over top left corner of composite (JG)
run("Label...", "format=Label starting=0 interval=1 x=3 y=20 font=16 text=[] range=1-1 use_text");
