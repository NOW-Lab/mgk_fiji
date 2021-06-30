# mgk_fiji
ImageJ Macro script repository

Overview: scripts for quickly batch processing images with Fiji. The goal is to extract individual images from inside of a .lif project, apply consistent intensity scaling to images of the same stain, and save individual and merged channels for each experiment. 

## General workflow:
  ### Convert lif to tifs
  1. Take images with Leica image format (.lif file). Saving images with clear names within the project will be helpful for downstream processing (keeping variable information such as stain group, treatment, position, etc. at the start of the name will keep things organized and make regex processing with CellProfiler easier).
  2. Within Fiji, run Plugins>Macros>Edit... and navigate to wherever "*export_lif_as_individuals.ijm*" is and open it.
  3. Press "Run" in the bottom left of the window.
  4. Recommended to use the following settings:
  
    Batch process: no
    File extension: .lif
    Save merge as RGB: no
    z-stack: yes (if applicable)
    Output format: tif
    Generate numbers: no
    Output in subfolder: yes
    
  5. Navigate to the .lif file of interest and run. Individual tifs will be generated in a folder with the same name as the source lif file.
  
  ### Prepare to batch process tifs
  6. Before proceeding with processing, images that should be processed in the same way should be grouped together within subfolders (ex. if you imaged three different stains within one .lif file, separate the newly extracted tifs into three subfolders). The macro should only be run on images with a single z-plane, either through only imaging one plane or already applying a z projection before batch processing.
  7. Manually load a representative image in Fiji for a given stain and note the minimum and maximum intensities for each channel and whether or not any channels need despeckling.
  8. Within Fiji, run Plugins>Macros>Edit... and navigate to wherever "*BatchChannel_SplitEditSave_preprocessed.ijm*" is and open it.
  9. Press "Run" in the bottom left of the window.
  
  ### Batch process tifs
  10. Navigate to the folder containing the tif images ready to be processed. Again, all images will get the same intensity processing, so ensure that the folder contains only a single stain.
  11. In the first dialog box, select if you want to save tifs, jpegs, or both. Tifs are the expected output, and jpegs are worth saving if you plan on using these images in a presentation later on. A warning dialog box will pop up if the tif and jpeg subfolders already exist.
  12. In the second dialog box, set the names, channels, intensities, and despeckling for each channel. (*For advanced use, you can pre-populate the dialog boxes by changing the values at the top of the code. This can be useful if you prefer different pseudocolors (ex. setting channel 1 default to Blue instead of Grays) or if you are going to be processing several different stains where only one or two channels are changing, and you want to set the constant channel defaults to decrease time spent repetitively changing the dialog boxes.*)
  13. At the bottom, decide whether or not you want to process custom merges as well. By default, the program will save all individual channels and a four-channel merge, so only do custom merges if you want to save two- or three-channel combination. It's better to indicate more than fewer, as there's no way to add more merges later without restarting the script.
  14. If you did proceed with custom merges, set up the merges in the checkboxes. Each row is a separate merge (ex. row 1: Ch2, Ch3; row 2: Ch1, C3, Ch4; etc.). Any row that has 0, 1, or 4 selected channels will be skipped.
  15. The script will run through, with some statements printed out to the "Log" window to track progress.
  
