run_dir = os.path.dirname(os.path.realpath(__file__))
Load(Filename=run_dir + r'/MER047405monitors.nxs', OutputWorkspace='MER047405monitors')
#GetEi(InputWorkspace='SR_MER047405_normalized_monitors', Monitor1Spec='69636', Monitor2Spec='69639', EnergyEstimate='10', FixEi='1', IncidentEnergy='10', FirstMonitorPeak='7372.0571995032715', FirstMonitorIndex='3')
GetEi(InputWorkspace='MER047405monitors', Monitor1Spec='69636', Monitor2Spec='69638', EnergyEstimate='10')
