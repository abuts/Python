# import mantid algorithms, numpy and matplotlib
from mantid.simpleapi import *
import matplotlib.pyplot as plt
import numpy as np


if not mtd.doesExist('MAP41449') :
    Load(Filename='/archive/NDXMAPS/Instrument/data/cycle_21_1/MAP41449.nxs', OutputWorkspace='MAP41449', LoadMonitors=True)
    
(ei, firstMonitorPeak, FirstMonitorIndex, tzero)=GetEi(InputWorkspace='MAP41449_monitors', Monitor1Spec=41475, Monitor2Spec=41476, EnergyEstimate=70)
print(' Ei = {0} firstMon = {1} '.format(ei,firstMonitorPeak))
GetEi(InputWorkspace='MAP41449_monitors', Monitor1Spec=41475, Monitor2Spec=41476, EnergyEstimate=70,Version=1)
