import os
import shutil
import pydicom

r = []
for root,dirs,files in os.walk("/datain"):
    for name in files:
        r.append(os.path.join(root, name))
        fn = os.path.join(root, name)
        data = pydicom.dcmread(os.path.join(root, name))
        if 't2_swi_tra_1mm' in data.ProtocolName:
            os.system('cp ' + fn + ' ' + fn + '_swi.dcm')
exit()
