;Getting Data
~/CLOUDSAT/processing_code/CloudSat_ftp.plx or any of the *.plx scripts. To get the latest ftp.plx script go to http://www.cloudsat.cira.colostate.edu/resources/software-tools

;Processing Data
- See /processing_code/ directory in ~/CLOUDSAT/ look at any of the process_*.pro for examples. 
- Make a “go” file to execute the processing code. See golatest for an example. These are run at IDL command line by typing @golatest (at least I think that’s how I ran them). These files unzip the CloudSat hdf files, run the process code, then remove the unzipped file.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Some guidelines for using CloudSat code

Will need Masterlist_2013.sav to get EO attributes. The .sav file and others are located on vis1 cd ../../bmapes/ERILEY/cloud_lists/

Will also need cloudsat_jdays.sav, EO_seasons.sav, and tropical_cloudtypes.sav (though, tropical_cloudtypes.sav could be remade from scratch using define_tropical_EOtypes.pro in ~/Standard_CloudSat_code). These can be found on vis1 cd ../../bmapes/ERILEY/cloud_lists/ or (at least for now) in my dropbox folder

ForEO_seasons.sav, contains the variables Seasons and calendar_days
Seasons has the following values:
JJA = 0
SON = 1
DJF = 2
MAM = 3

calendar_days is the jday of the cloud for an individual year, so 1-365, for leap years there should be two February 28ths.

For cloudsat_jdays.sav, the variable jdays is the julian day since 1 Jan 2006, so ranges from 166 to 2574


Will also need access to pixel files. These can be found on vis1 cd ../../bmapes/ERILEY/EO_pixels/ or external drive SilverBullet

;;;;;;;;;
get_CLDSAT_julday.pro
- Finds the julian day for each EO
- Required files:
	Masterlist_2013.sav
	cloudsat_jdays_since2006_end2013.sav

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Plotting Stamps:

plot_stamp_pages.pro
	- will plot pages of EO stamps.  
	- Elevation optionally plotted underneath each EO. With elevation uses etopo2.nc, which I'll placee on vis1.
	- INPUT = subset of filenames

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Plotting Mosaics:
Use random_stamp_generator.pro or all_stamp_generator.pro, which calls plot_stamps_bylongitude.pro, or plot_stamps_by_latitude

random_stamp_generator.pro
	- Will randomly select EOs out of defined subset to plot
	- INPUT = attribute criteria (i.e. filenames, bbwidths, tops, etc.)
	- Calls plot_stamps_bylongitude.pro
	- Uses - tropical_cloudtypes.sav, which was generator with define_tropical_EOtypes.pro.  If don't want to use tropical cloud types, will need to redefine cloud types within the code, (see all_stamp_generator.pro for example)
	- OPTIONS - if DO_DBZCOLOR = 'true' then will plot EOs in dbz color scale, if DO_DBZCOLOR = 'false' will plot wDP EOs grey to red and all other EOs grey to blue
		  - if DO_ELEVATION = 'true' will plot zground under each profile (zground info is in pixel files), if set equal to 'false' will not plot elevation
		  - ORIENTATION = 'lat' will use plot_stamps_bylatitude.pro, if ORIENTATION = 'lon' will use plot_stamps_by_longitude.pro 

all_stamp_generator.pro
	- Plots ALL EOs of a defined subset
	- INPUT = attribute criteria 
	- Calls plot_stamps_bylongitude.pro
	- Cloudtypes are defined within the code, could delete and replace with restore, tropical_cloudtypes.sav


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Making bar plots, like fig. 10 of Riley et al. (2011, JAS) [these should be presentation, maybe even publication quality]:
Use make_barplots.pro, which calls get_barplot_info.pro and plot_barplot_info.pro and optionally mean_barplot_subsets.pro

Will need to make a directory ~/bar_plot_info where all the .sav files will be stored

get_barplot_info.pro
	- Catorgorizes EOs into arrays by [longitude bin, time of day, and EO type] to be used in another code, plot_barplot_info.pro, to produce bar plots of EOs by type and longitude bin
	- INPUT = days may be either jays from start of cloudsat (in that case input jays from cloudsat_jdays.sav (jays 166-1793)) OR jays for each year to get seasonal bar plot info, (in that case input calendar_jdays from EO_seasons.save (calendar_jdays 1 - 365, for leap years there will be two feb 28ths.)

plot_barplot_info.pro
	- Will need to replace bar_plot.pro in idl/lib with modified bar_plot.pro, where I allowed ycharsize to be a keyword
	- option to plot mean cloud cover line over the bars as in Fig. 10 of Riley et al. (2011, JAS), by setting do_lineplot = 'yes', otherwise set do_lineplot = 'no' or something else. Haven't figured out a way to automate this, so will just have to fuss with the specifics. do_lineplot = 'yes' can only be used after creating a mean line plot over all the bins using mean_barplot_subsets.pro.  

mean_barplot_subsets.pro
	- INPUT - Filenames = an array of the subset names that you want to combine to compute the mean for each longitude bin.  For example, for ENSO the inputs would be something like Filenames = ['ENSO_cool_phase', 'ENSO_warm_phase'] or for the MJO it could be Filenames = ['1', '2', '3', etc.] for each phase. Obviously the filenames has to correspond to what was created in bar_plot_info/ from get_barplot_info.pro.  Other input variables should be the same as used in get_barplot_info.pro, well, you'll want to use a new unique subset_name, like ENSO0_0608 for ENSO, or MJO_all_phases for the average of all the MJO phases.  The subset_name+'mean_coverage.sav' is then saved in bar_plot_info/ directory and is then ready to be used as an input to plot_barplot_info.pro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
To make 2D histograms:

Still using good'ol plot_standard_joint_hists.pro, haven't updated this since my masters, but I'm sure refinements could be made.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
To plot CFADs:

plot_cfads_trops.pro (or other latitude belt) will work, but these need updated! And I'd like to automate the type and quality of CFADs I made for Riley et al. (2011, JAS) Fig. 7.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ECMWF Auxiliary Data

cloud_soundings.pro
- Finds mean temperature, specific & relative humidity, pressure, thetae, theta, and dt_dz for the supplied EO filenames
- Called AS:
	cloud_soundings, FILENAMES=filenames, SAMPLE_NAME=sample_name, TOPS = tops, BOTTOMS = bottoms, PATH = path

