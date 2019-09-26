import os
from mantid.simpleapi import *
wk_folder = os.path.dirname(os.path.realpath(__file__))
data_file = os.path.join(wk_folder,'mccode.h5')
instr_file = os.path.join(wk_folder,'MUSHROOM_Definition.xml')
config['instrument.view.geometry'] = 'Neutronic'


Load(Filename=data_file, OutputWorkspace='mccode', OutputOnlySummedEventWorkspace=False,ErrorBarsSetTo1=True)
Rebin(InputWorkspace='EventData_mccode', OutputWorkspace='EventData_mccode', Params='35500,10,60100', IgnoreBinErrors=True)

    
LoadInstrument(Workspace='EventData_mccode', Filename=instr_file, MonitorList='1', InstrumentName='MUSHROOM', RewriteSpectraMap='True')
instrument_view1 = getInstrumentView('EventData_mccode')
instrument_view1.show()
config['instrument.view.geometry'] = 'physical'
instrument_view2 = getInstrumentView('EventData_mccode')
instrument_view2.show()

ConvertUnits(InputWorkspace='EventData_mccode', OutputWorkspace='EventData_mccodeE', Target='DeltaE', EMode='Indirect', AlignBins=True, ConvertFromPointData=False)
Rebin(InputWorkspace='EventData_mccodeE', OutputWorkspace='EventData_mccodeE', Params='-0.2,0.01,3', IgnoreBinErrors=True)
SaveNXSPE('EventData_mccodeE','oneD_test.nxspe')

