import os
from mantid.simpleapi import *
wk_folder = os.path.dirname(os.path.realpath(__file__))
data_file = os.path.join(wk_folder,'mccode.h5')
instr_file = os.path.join(wk_folder,'MUSHROOM_Definition.xml')

Load(Filename=data_file, OutputWorkspace='mccode', OutputOnlySummedEventWorkspace=False)
Rebin(InputWorkspace='EventData_mccode', OutputWorkspace='EventData_mccode', Params='54500,10,60100', IgnoreBinErrors=True)
LoadInstrument(Workspace='EventData_mccode', Filename=instr_file, MonitorList='1', InstrumentName='MUSHROOM', RewriteSpectraMap='True')
ConvertUnits(InputWorkspace='EventData_mccode', OutputWorkspace='EventData_mccodeE', Target='DeltaE', EMode='Indirect', AlignBins=True, ConvertFromPointData=False)
