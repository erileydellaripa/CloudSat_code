# CloudSat_code
IDL code for processing and analyzing CloudSat data

Information on CloudSat Echo Object data base:

- A cloud or what we call an echo object (EO) is a contiguous region of dBZ echo (see Riley and Mapes 2009, GRL or Riley et al. 2011, JAS for more info).

- EO attributes are provided in the EO_masterlistYYYY.nc files, where YYYY corresponds to the different years. I transferred the EO attributes from IDL .save files to netcdf files for sharing. A description of each EO attribute is provide if you do an ncdump -h

- I’ve processed from the start of CloudSat 15 June 2006 till 17 January 2013 for the EO attributes.

- In total, there are 15,181,193 EOs 

- There was a battery failure 17 April 2011. CloudSat resumed collecting data 27 October 2011, but only during the day.

- The days variable is days since the start of each year. For example, day 166 for 2006 is 15 June 2006.

- For EOs through day 181 in 2010 I have a corresponding sounding of pressure, temperature, and specific humidity. Since this data are quite large I only transferred the EOs from 2006 into a netcdf file (i.e., ECMWF_sounding_info_2006.nc. The orbit number and EO number per orbit (i.e., ORBITS and EONUMBERS) corresponds to the similarly named variables in the EO attribute file (i.e., EO_masterlist2006.nc file). This way you can match the EO attributes with the sounding information.

- I had processed ice water content (IWC) and liquid water content (LWC) per EO, but I noticed an error in the way I processed this data and so the values are not correct. I can redo this eventually.

Data:
- Data were downloaded from ftp1.cloudsat.cira.colostate.edu in directory 2B-GEOPROF.R04

Processing:
- Data were processed and analyzed using IDL. See CloudSat_code_README.txt for details

References:
Riley, E. M., B. E. Mapes, and S. N. Tulich, 2011: Clouds Associated with the Madden-Julian Oscillation: A New Perspective from CloudSat. J. Atmos. Sci., 68, 3032-3051, https://doi.org/10.1175/JAS-D-11-030.1.

Riley, E. M., and B. E. Mapes, 2009: Unexpected peak near -15°C in CloudSat echo top climatology. Geophys. Res. Lett., 36, L09819, https://doi.org/10.1029/2009GL037558.

