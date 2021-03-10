import os
import shutil
import pydicom

r = []
for root,dirs,files in os.walk("/datain"):
    for name in files:
        r.append(os.path.join(root, name))
        fn = os.path.join(root, name)
        data = pydicom.dcmread(os.path.join(root, name))
        if 'PhysioLog' in data.SeriesDescription and 'SBRef' not in data.SeriesDescription:
            os.system('cp ' + fn + ' ' + fn + '_physio.dcm')
