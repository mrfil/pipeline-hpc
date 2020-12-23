import os


def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes


def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where

    allowed template fields - follow python string module:

    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """

    t1w = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_T1w') 
    FLAIR = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_FLAIR') 
    dwi = create_key('sub-{subject}/{session}/dwi/sub-{subject}_{session}_run-{item:01d}_dwi')
    rest = create_key('sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_dir-PA_run-{item:01d}_bold')
    fmap_fmri = create_key('sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-{acq}_dir-{dir}_run-{item:01d}_epi')
    fmap_dwi = create_key('sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-{acq}_dir-{dir}_run-{item:01d}_epi')
    fmap_tfmri = create_key('sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-{acq}_dir-{dir}_run-{item:01d}_epi')
    rest_sbref = create_key('sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_dir-PA_run-1_sbref')
    tfunc = create_key('sub-{subject}/{session}/func/sub-{subject}_{session}_task-{task}_dir-PA__run-{item:01d}_bold')
    swi = create_key('sub-{subject}/{session}/derivatives/swi/sub-{subject}_{session}_acq-{acq}_dir-PA_run-{item:01d}_t2star')
    asl = create_key('sub-{subject}/{session}/derivatives/perf/sub-{subject}_{session}_acq-{acq}_run-{item:01d}_asl')
    t2w = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-{acq}_run-{item:01d}_T2w')
    
    info = {t1w: [], dwi: [], t2w: [], FLAIR: [], rest: [], rest_sbref: [], fmap_fmri: [], fmap_tfmri: [] , fmap_dwi: [], tfunc: [], swi: [], asl: []} 
   
    for s in seqinfo:
        if (('T1w' in s.protocol_name) or ((s.dim3 == 192) and (s.dim4 == 1))) and ('t1' in s.protocol_name):
            info[t1w] = [s.series_id] # assign if a single series meets criteria
        if (('dwi' in s.protocol_name) or ((s.dim1 == 92) and (s.TR == 2.8))) and ('cmrr' in s.protocol_name):
            info[dwi].append({'item': s.series_id}) # append if multiple series meet criteria
        if (('dwi' in s.protocol_name) and ('fmap' in s.protocol_name)) or (('DTIField' in s.protocol_name) and (s.TR == 8.29)):
            if ('AP' in s.protocol_name):
                info[fmap_dwi].append({'item': s.series_id, 'acq': 'dwi', 'dir': 'AP'})
            else:
                info[fmap_dwi].append({'item': s.series_id, 'acq': 'dwi', 'dir': 'PA'})
        if (('T2w' in s.protocol_name) or (s.TR == 6)) and ('flair' in s.protocol_name):
            info[FLAIR] = [s.series_id]
        if ('T2w' in s.protocol_name) and ('highreshippocampus' in s.protocol_name):
            info[t2w].append({'item': s.series_id, 'acq': 'highreshippocampus'})
        if (s.dim4 > 10) and ('rest' or 'REST_PA' in s.protocol_name) and ('cmrr' not in s.protocol_name):
            info[rest].append({'item': s.series_id})
        if (s.dim4 < 4) and ('rest' or 'REST_PA' in s.protocol_name) and ('fmap' not in s.protocol_name) and ('cmrr' not in s.protocol_name):
            info[rest_sbref] = [s.series_id]
        if (s.dim4 > 10) and ('task' in s.protocol_name) and ('rest' not in s.protocol_name):
            pref = '_task-'
            suff = '_'
            taskname = s.protocol_name[s.protocol_name.find(pref)+1 : s.protocol_name(suff)]
            info[tfunc].append({'item': s.series_id, 'task': taskname})
        if (s.dim4 > 10) and ('nback' in s.protocol_name):
            info[tfunc].append({'item': s.series_id, 'task': 'nback'})
        if (('fmap' in s.protocol_name) and ('rest' in s.protocol_name)) or ('fMRIFieldMap' in s.protocol_name):
            if ('AP' in s.protocol_name):
                info[fmap_fmri].append({'item': s.series_id, 'acq': 'fMRIrest', 'dir': 'AP'})
            else:
                info[fmap_fmri].append({'item': s.series_id, 'acq': 'fMRIrest', 'dir': 'PA'})
        if ('fmap' in s.protocol_name) and ('nback' in s.protocol_name):
            if ('AP' in s.protocol_name):
                info[fmap_tfmri].append({'item': s.series_id, 'acq': 'fMRI', 'dir': 'AP'})
            else:
                info[fmap_tfmri].append({'item': s.series_id, 'acq': 'fMRI', 'dir': 'PA'})  
        if ('fmap' in s.protocol_name) and ('task' in s.protocol_name) and ('rest' not in s.protocol_name) and ('nback' not in s.protocol_name):
            pref = '_task-'
            suff = '_'
            taskname = s.protocol_name[s.protocol_name.find(pref)+1 : s.protocol_name(suff)]
            if ('_AP' in s.protocol_name):
                info[fmap_tfmri].append({'item': s.series_id, 'acq': 'fMRI', 'dir': 'AP'})
            else:
                info[fmap_tfmri].append({'item': s.series_id, 'acq': 'fMRI', 'dir': 'PA'})
        if ('perf' in s.protocol_name) and ('asl' in s.protocol_name):
            if ('ti1X800ti1400' in s.protocol_name):
                info[asl].append({'item': s.series_id, 'acq': 'ti1X800ti1400'})
            elif ('ti1X800ti1800' in s.protocol_name):
                info[asl].append({'item': s.series_id, 'acq': 'ti1X800ti1800'})
            elif ('ti1X800ti2200' in s.protocol_name):
                info[asl].append({'item': s.series_id, 'acq': 'ti1X800ti2200'})
            elif ('ti1X800ti2600' in s.protocol_name):
                info[asl].append({'item': s.series_id, 'acq': 'ti1X800ti2600'})
    return info

