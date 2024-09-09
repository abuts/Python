""" MAPS reduction script to use precalculated vanadium integral for absolute units conversion 
    Absolute units integral is calculated  by neigboring MAPSReduction_mono.py script.
"""
# Two rows necessary to run script outside of the mantid. You need also set up 
# appropriate python path-es
import os
import numpy as np
#
from mantid import *
from Direct.ReductionWrapper import *
# Define all runs used by the program
runs = list(range(11014,11061))+list(range(11063,11202))
# Define list of angles runs used by the program
phi  = list(np.arange(0,-23.5,-0.5))+list(np.arange(-23.5,-27.5,-0.5))+list(np.arange(-27.5,-34,-0.5))+list(np.arange(-34.,-93,-0.5))
# Map angles to run numbers
phi_on_run = {runs[i]: phi[i] for i in range(len(phi))}
class MAPSReduction(ReductionWrapper):
#------------------------------------------------------------------------------------#
   @MainProperties
   def def_main_properties(self):
       """ Define main properties used in reduction. These are the property 
           a user usually wants to change
       """ 
       prop = {}
       # if energy is specified as a list (even with single value e.g. ei=[81])
       # The numbers are treated as a fraction of ei [from ,step, to ]. If energy is 
       # a number, energy binning assumed to be absolute (e_min, e_step,e_max)
       #
       prop['incident_energy'] = 785
       prop['energy_bins'] =[-100,4,780]

       # the range of files to reduce. This range ignored when deployed from autoreduction,
       # unless you going to sum these files. 
       # The range of numbers or run number is used when you run reduction from PC.
       #ws = mtd['w1']
       prop['sample_run'] = 11014 #runs #
       prop['wb_run']     = 10962
       #
       prop['sum_runs'] = False # set to true to sum everything provided to sample_run
       #                        # list
       # Absolute units reduction properties. Set prop['monovan_run']=None to do relative units
       prop['monovan_run'] = 11270 #21803  #  vanadium run in the same configuration as your sample 
       prop['sample_mass'] = 166
       prop['sample_rmm']  = 53.94
       return prop
#------------------------------------------------------------------------------------#
   @AdvancedProperties
   def def_advanced_properties(self):
      """  Set up advanced properties, describing reduction.
           These are the properties, usually provided by an instrument 
           scientist
            
           separation between simple and advanced properties depends
           on scientist, experiment and user.   All are necessary for reduction 
           to work properly
      """
      prop = {}
      prop['map_file'] = "4to1_065.map"
      prop['monovan_mapfile'] = "mid-tubes_065.map"
      prop['hardmaskOnly']="4to1_065.msk" #maskfile # disable diag, use only hard mask
      prop['hard_mask_file'] = ""
      prop['bkgd_range'] = [15000,19000]
      prop['fix_ei'] = False
      prop['normalise_method'] = 'current'
      prop['wb_for_monovan_run'] = 11276

      prop['monovan_lo_frac'] = -0.5 # default is -0.6
      #prop['monovan_hi_frac'] = 0.7 # default is 0.7, no need to change
      #prop['abs_units_van_range']=[-40,40] # specify energy range directly, to
                                     #override relative default energy range
      prop['diag_remove_zero'] = False
      prop['wb_integr_range'] = [20,100] 
      
      #prop['det_cal_file'] = "11060" what about calibration?
      prop['save_format'] = 'nxspe' # nxs or spe
      prop['data_file_ext']='.raw' # if two input files with the same name and
                                    #different extension found, what to prefer.
      #prop['run_diagnostics'] = False
      #prop['norm-mon1-spec'] = 578
      #prop['norm-mon2-spec'] = 579
      #prop['ei-mon1-spec'] = 578
      #prop['ei-mon2-spec'] = 579
      
      return prop
      #
#------------------------------------------------------------------------------------#
   @iliad
   def reduce(self,input_file=None,output_directory=None):
      """ Method executes reduction over single file

          Overload only if custom reduction is needed or 
          special features are requested
      """
      #
      results = ReductionWrapper.reduce(self,input_file,output_directory)
      #SaveNexus(ws,Filename = 'MARNewReduction.nxs')
      return results
   #
   #
   def set_custom_output_filename(self):
      """define custom name of output files if standard one is not satisfactory
        
          In addition to that, example of accessing complex reduction properties
          Simple reduction properties can be accessed as e.g.: value= prop_man.sum_runs
      """
      def custom_name(prop_man):
            """Sample function which builds filename from
              incident energy and run number and adds some auxiliary information
              to it.
            """
            map_file = prop_man.map_file
            if 'rings' in map_file:
                ftype = '_powder'
            else:
                ftype = ''

            # Note -- properties have the same names as the list of advanced and
            # main properties
            ei = PropertyManager.incident_energy.get_current()
            # sample run is more then just list of runs, so we use
            # the formalization below to access its methods
            run_num = PropertyManager.sample_run.run_number()
            name = "map{0}_ei{1:_<3.0f}meV{2}".format(run_num ,ei,ftype)
            return name
       
      # Uncomment this to use custom filename function
      # Note: the properties are stored in prop_man class accessed as
        # below.
      return lambda : custom_name(self.reducer.prop_man)
      # Uncomment this to use standard file name generating function
      #return None
   #
   #
   
   def do_preprocessing(self,reducer,ws):
        """ Custom function, applied to each run or every workspace, the run is divided to
            in multirep mode
            Applied after diagnostics but before any further reduction is invoked.
                Inputs:
                self    -- initialized instance of the instrument reduction class
                reducer -- initialized instance of the reducer
                           (DirectEnergyConversion class initialized for specific reduction)
                ws         the workspace, describing the run or partial run in multirep mode
                           to preprocess

            By default, does nothing.
            Add code to do custom preprocessing.
            Must return pointer to the preprocessed workspace

        """
        anf_TGP = 54.51
        print('*************************************************')
        print('*** SETTING UP EXTERNAL MONO-CORRECTION FACTOR: *')
        print('*** ',anf_TGP)
        print('*************************************************')
        PropertyManager.mono_correction_factor.set_val_to_cash(reducer.prop_man, anf_TGP)
        run_num = PropertyManager.sample_run.run_number();
        self.reducer.prop_man.psi = phi_on_run[run_num]
        print('*** Run: ',run_num,' psi: ',self.reducer.prop_man.psi)
        return ws
   
   def __init__(self,web_var=None):
       """ sets properties defaults for the instrument with Name"""
       ReductionWrapper.__init__(self,'MAP',web_var)
       ##### Overload do_preprocessing function on reducer
       Mt = MethodType(self.do_preprocessing, self.reducer)
       DirectEnergyConversion.__setattr__(self.reducer,'do_preprocessing',Mt)
       ##### Overload do_postprocessing function on reducer
       #Mt = MethodType(self.do_postprocessing, self.reducer)
       #DirectEnergyConversion.__setattr__(self.reducer,'do_postprocessing',Mt)

#---------------------------------------------------------------------------------------------------------------------------
#


if __name__ == "__main__" or __name__ == "mantidqt.widgets.codeeditor.execution":
#------------------------------------------------------------------------------------#
# SECTION USED TO RUN REDUCTION FROM MANTID SCRIPT WINDOW #
#------------------------------------------------------------------------------------#
##### Here one sets up folders where to find input data and where to save results ####
    # It can be done here or from Mantid GUI:
    #      File->Manage user directory ->Browse to directory
    # Folder where map and mask files are located:
    map_mask_dir = 'e:/SHARE/Fe/Data/sources/InstumentFiles/maps'
    # folder where input data can be found
    data_dir = 'e:/SHARE/Fe/Data/sources/Spe_ei787_cycle_06_05'
    # auxiliary folder with results
    #ref_data_dir = '/isisdatar55/ndxmaps/Instrument/data/cycle_09_05' 
    # Set input search path to values, specified above
    #config.setDataSearchDirs('{0};{1}'.format(data_dir,map_mask_dir))
    # use appendDataSearch directory to add more locations to existing Mantid 
    # data search path
    config.appendDataSearchDir('{0};{1}'.format(data_dir,map_mask_dir))
    # folder to save resulting spe/nxspe files.
    #config['defaultsave.directory'] = '/home/maps/maps_users/Hutchings/March2015/SPE' #data_dir 

###### Initialize reduction class above and set up reduction properties.        ######
######  Note no web_var in constructor.(will be irrelevant if factory is implemented)
    rd = MAPSReduction()
    # set up advanced and main properties
    rd.def_advanced_properties()
    rd.def_main_properties()

#### uncomment rows below to generate web variables and save then to transfer to   ###
    ## web services.
    run_dir = os.path.dirname(os.path.realpath(__file__))
    file = os.path.join(run_dir,'reduce_vars.py')
    rd.save_web_variables(file)

#### Set up time interval (sec) for reducer to check for input data file.         ####
    #  If this file is not present and this value is 0,reduction fails
    #  if this value >0 the reduction waits until file appears on the data
    #  search path checking after time specified below.
    rd.wait_for_file = 0  # waiting time interval in seconds
      

### Define a run number to validate reduction against future changes    #############
    # After reduction works well and all settings are done and verified, 
    # take a run number with good reduced results and build validation
    # for this result. 
    # Then place the validation run together with this reduction script.
    # Next time, the script will run reduction and compare the reduction results against
    # the results obtained earlier.
    #rd.validate_run_number = 21968  # Enabling this property disables normal reduction
    # and forces reduction to reduce run specified here and compares results against
    # validation file, processed earlier or calculate this file if run for the first time.
    #This would ensure that reduction script have not changed,
    #allow to identify the reason for changes if it was changed 
    # and would allow to recover the script,used to produce initial reduction
    #if changes are unacceptable.

####get reduction parameters from properties above, override what you want locally ###
   # and run reduction. Overriding would have form:
   # rd.reducer.prop_man.property_name (from the dictionary above) = new value e.g. 
   # rd.reducer.prop_man.energy_bins = [-40,2,40]
   # or 
   ## rd.reducer.prop_man.sum_runs = False
   # 
    
    rd.run_reduction()

