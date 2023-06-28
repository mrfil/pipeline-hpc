# %%
# import packages for reading txt files, editing json files
import os
import json


# %% [markdown]
# This is a Jupyter notebook for changing fieldmap JSON files to include the IntendedFor key-value(s) pair. You will need a list of fieldmap files, func nii.gz files, and dwi nii.gz files as text files for this exact implementation

# %%
# define functions

# get list of all files in SAY_dwi_niftis.txt and return list of strings
def getDWIList(dwi_list: str, subID: str, sesID: str, bids_uri_prefix: str) -> list:
    """
    Returns a list of DWI file names in the format sesID/dwi_file from a text file specified by dwi_list, filtered by the
    subject ID and session ID specified by subID and sesID respectively.

    Args:
    - dwi_list (str): the file path of the text file containing a list of DWI files
    - subID (str): the subject ID to filter by
    - sesID (str): the session ID to filter by
    - bids_uri_prefix (str): prefix of the URI of the BIDS dataset (optional)

    Returns:
    - dwi_list_sub_ses (List[str]): a list of DWI file names filtered by subID and sesID in the format sesID/dwi_file
    """
    with open(dwi_list, 'r') as f:
        dwi_list = f.read().splitlines()
        dwi_list_sub_ses = []
        for dwi_file in dwi_list:
            # get filename without path
            dwi_file = os.path.basename(dwi_file)
            # only add func files to func_list_sub_ses if they contain subID and sesID in the file name
            if subID in dwi_file and sesID in dwi_file:
                if bids_uri_prefix is not None:
                    dwi_list_sub_ses.append(bids_uri_prefix + subID + '/' + sesID + '/dwi/' + dwi_file)
                else:
                    dwi_list_sub_ses.append(sesID + '/dwi/' + dwi_file)
    return dwi_list_sub_ses

# get list of all files in SAY_nback_niftis.txt and return list of strings for each subject and session
def getNBackList(func_list: str, subID: str, sesID: str, bids_uri_prefix: str) -> list:
    """
    Returns a list of functional file names in the format sesID/func_file from a text file specified by func_list, filtered by the
    subject ID and session ID specified by subID and sesID respectively.

    Args:
    - func_list (str): the file path of the text file containing a list of functional files
    - subID (str): the subject ID to filter by
    - sesID (str): the session ID to filter by
    - bids_uri_prefix (str): prefix of the URI of the BIDS dataset (optional)

    Returns:
    - func_list_sub_ses (List[str]): a list of functional file names filtered by subID and sesID in the format sesID/func_file
    """
    with open(func_list, 'r') as f:
        func_list = f.read().splitlines()
        nback_list_sub_ses = []
        for func in func_list:
            # get filename without path
            func = os.path.basename(func)
            # only add func files to func_list_sub_ses if they contain subID and sesID in the file name
            if subID in func and sesID in func:
                if bids_uri_prefix is not None:
                    nback_list_sub_ses.append(bids_uri_prefix + subID + '/' + sesID + '/func/' + func)
                else:
                    nback_list_sub_ses.append(sesID + '/func/' + func)
    return nback_list_sub_ses


# get list of all files in SAY_rest_niftis.txt and return list of strings for each subject and session
def getRestList(func_list: str, subID: str, sesID: str, bids_uri_prefix: str) -> list:
    """
    Returns a list of functional file names in the format sesID/func_file from a text file specified by func_list, filtered by the
    subject ID and session ID specified by subID and sesID respectively.

    Args:
    - func_list (str): the file path of the text file containing a list of functional files
    - subID (str): the subject ID to filter by
    - sesID (str): the session ID to filter by
    - bids_uri_prefix (str): prefix of the URI of the BIDS dataset (optional)

    Returns:
    - func_list_sub_ses (List[str]): a list of functional file names filtered by subID and sesID in the format sesID/func_file
    """
    with open(func_list, 'r') as f:
        func_list = f.read().splitlines()
        rest_list_sub_ses = []
        for func in func_list:
            # get filename without path
            func = os.path.basename(func)
            # only add func files to func_list_sub_ses if they contain subID and sesID in the file name
            if subID in func and sesID in func:
                if bids_uri_prefix is not None:
                    rest_list_sub_ses.append(bids_uri_prefix + subID + '/' + sesID + '/func/' + func)
                else:
                    rest_list_sub_ses.append(sesID + '/func/' + func)
    return rest_list_sub_ses


# read in json file and add new key-values pair with array of strings for "IntendedFor": ["ses-<sesID>/sub-<subID>_ses-<sesID>_task-<taskID_1>_bold.nii.gz", "ses-<sesID>/sub-<subID>_ses-<sesID>_task-<taskID_2>_bold.nii.gz", ...] for each task present in the func_list for that subject and session
def addIntendedFor(json_file: str, func_list_sub_ses: list) -> None:
    """
    Reads in a JSON file specified by json_file and adds a new key-value pair with an array of strings for "IntendedFor":
    ["<sesID>/<subID>_<sesID>_task-<taskID_1>_bold.nii.gz", "<sesID>/<subID>_<sesID>_task-<taskID_2>_bold.nii.gz", ...],
    where <sesID>, <subID>, and <taskID> are extracted from the file names in func_list_sub_ses. Each element in the "IntendedFor" array
    corresponds to a functional file in the func_list_sub_ses for the same subject and session.

    Args:
    - json_file (str): the file path of the JSON file to be updated
    - func_list_sub_ses (List[str]): a list of functional file names in the format sesID/func_file for the same subject and session

    Returns:
    - None
    """

    with open(json_file, 'r') as f:
        json_dict = json.load(f)
    json_dict['IntendedFor'] = [func for func in func_list_sub_ses]
    with open(json_file, 'w') as f:
        json.dump(json_dict, f, indent=4)

# Paths and list files
source_path = 'testing/SAY/bids/sourcedata'
# specify list files
dwi_list_file = 'SAY_dwi_niftis.txt'
rest_list_file = 'SAY_rest_niftis.txt'
nback_list_file = 'SAY_nback_niftis.txt'

# perform for all subjects and sessions
# get list of all subjects
sub_list = os.listdir(source_path)
for sub in sub_list:
    # get list of all sessions for each subject
    ses_list = os.listdir(source_path + '/' + sub)
    for ses in ses_list:
        # get list of all func files for each subject and session
        rest_list_sub_ses = getRestList(rest_list_file, sub, ses, None)
        # get list of all fmap files for each subject and session
        fmap_files_dir = source_path + '/' + sub + '/' + ses + '/fmap'
        # if fieldmap files exist, add "IntendedFor" key-value pair to each fmap json file
        if os.path.exists(fmap_files_dir + '/' + sub + '_' + ses + '_acq-fMRIrest_dir-AP_run-1_epi.json') and os.path.exists(fmap_files_dir + '/' + sub + '_' + ses + '_acq-fMRIrest_dir-PA_run-2_epi.json'):
            addIntendedFor(fmap_files_dir + '/' + sub + '_' + ses + '_acq-fMRIrest_dir-AP_run-1_epi.json', rest_list_sub_ses)
            addIntendedFor(fmap_files_dir + '/' + sub + '_' + ses + '_acq-fMRIrest_dir-PA_run-2_epi.json', rest_list_sub_ses)
        # get list of all func files for each subject and session
        nback_list_sub_ses = getRestList(nback_list_file, sub, ses, None)
        # get list of all fmap files for each subject and session
        fmap_files_dir = source_path + '/' + sub + '/' + ses + '/fmap'
        # if fieldmap files exist, add "IntendedFor" key-value pair to each fmap json file
        if os.path.exists(fmap_files_dir + '/' + sub + '_' + ses + '_acq-fMRInback_dir-AP_run-3_epi.json') and os.path.exists(fmap_files_dir + '/' + sub + '_' + ses + '_acq-fMRInback_dir-PA_run-4_epi.json'):
            addIntendedFor(fmap_files_dir + '/' + sub + '_' + ses + '_acq-fMRInback_dir-AP_run-3_epi.json', nback_list_sub_ses)
            addIntendedFor(fmap_files_dir + '/' + sub + '_' + ses + '_acq-fMRInback_dir-PA_run-4_epi.json', nback_list_sub_ses)
        # get list of all dwi files for each subject and session
        dwi_list_sub_ses = getDWIList(dwi_list_file, sub, ses, None)
        # if fieldmap files exist, add "IntendedFor" key-value pair to each dwi json file
        if os.path.exists(fmap_files_dir + '/' + sub + '_' + ses + '_acq-dwi_dir-AP_run-5_epi.json') and os.path.exists(fmap_files_dir + '/' + sub + '_' + ses + '_acq-dwi_dir-PA_run-6_epi.json'):
            addIntendedFor(fmap_files_dir + '/' + sub + '_' + ses + '_acq-dwi_dir-AP_run-5_epi.json', dwi_list_sub_ses)
            addIntendedFor(fmap_files_dir + '/' + sub + '_' + ses + '_acq-dwi_dir-PA_run-6_epi.json', dwi_list_sub_ses)


