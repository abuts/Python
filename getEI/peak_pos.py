# import mantid algorithms, numpy and matplotlib
from mantid.simpleapi import *
import matplotlib.pyplot as plt
import numpy as np


#MAR28050_monitors = ADS.retrieve('MAR28050_monitors')

#fig, axes = plt.subplots(edgecolor='#ffffff', num='MAR28050_monitors-1', subplot_kw={'projection': 'mantid'})
#axes.plot(MAR28050_monitors, color='#1f77b4', label='MAR28050_monitors: spec 3', wkspIndex=2)
#axes.tick_params(axis='x', which='major', **{'gridOn': False, 'tick1On': True, 'tick2On': False, 'label1On': True, 'label2On': False, 'size': 6, 'tickdir': 'out', 'width': 1})
#axes.tick_params(axis='y', which='major', **{'gridOn': False, 'tick1On': True, 'tick2On': False, 'label1On': True, 'label2On': False, 'size': 6, 'tickdir': 'out', 'width': 1})
#axes.set_title('MAR28050_monitors')
#axes.set_xlabel('Time-of-flight ($\\mu s$)')
#axes.set_ylabel('Counts ($\\mu s$)$^{-1}$')
#axes.set_xlim([3446.1, 3843.5])
#axes.set_ylim([-93.788, 1632.3])
#legend = axes.legend(fontsize=8.0).set_draggable(True).legend

#plt.show()
# Scripting Plots in Mantid:
# https://docs.mantidproject.org/tutorials/python_in_mantid/plotting/02_scripting_plots.html

def peak_pos(ws,x_min,x_max,ws_ind):
    ws_work = CropWorkspace(ws,x_min,x_max,ws_ind,ws_ind)
    x = ws_work.readX(0)
    y = ws_work.readY(0)
    dx = (x[1:]-x[0:-1])
    x0 = 0.5*(x[1:]+x[0:-1])

    Norm = np.sum(dx*y)
    fy = y/Norm
    print('Norm(fy) = ',np.sum(fy))
    
    peak_pos = np.sum(x0*fy)
    DeleteWorkspace(ws_work)
    return peak_pos
    
ws = mtd['MAP41449_monitors']
peak1 = peak_pos(ws,2780,2880,2)
peak2 = peak_pos(ws,5000,6000,3)
print('MAP positions : peak1={0}; peak2={1}'.format(peak1,peak2))
    
ws = mtd['MER53574_monitors']
peak1 = peak_pos(ws,2750,2800,3)
peak2 = peak_pos(ws,4000,4710,7)
print('MER positions : peak1={0}; peak2={1}'.format(peak1,peak2))
    