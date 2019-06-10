from mantid.simpleapi import *

Load(Filename=r'D:\Data\MantidDevArea\Tickets\rob_bewley\mccode.h5', OutputWorkspace='mccode', OutputOnlySummedEventWorkspace=False)
Rebin(InputWorkspace='EventData_mccode', OutputWorkspace='EventData_mccode', Params='54500,10,60100', IgnoreBinErrors=True)
LoadInstrument(Workspace='EventData_mccode', Filename='D:/Data/MantidDevArea/Tickets/rob_bewley/MUSHROOM_Definition.xml', MonitorList='1', InstrumentName='MUSHROOM', RewriteSpectraMap='True')
LoadInstrument(Workspace='EventData_mccode', Filename='D:/Data/MantidDevArea/Tickets/rob_bewley/MUSHROOM_Definition.xml', MonitorList='1', InstrumentName='MUSHROOM', RewriteSpectraMap='True')
ConvertUnits(InputWorkspace='EventData_mccode', OutputWorkspace='EventData_mccodeE', Target='DeltaE', EMode='Indirect', AlignBins=True, ConvertFromPointData=False)
