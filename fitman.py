import os

if os.name == 'nt':
	os.system('idlrt fitman/fitMAN_Suite.sav')
else:
	os.system('idl -vm=fitman/fitMAN_Suite.sav')
