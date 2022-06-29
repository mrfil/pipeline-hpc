.. _Troubleshooting :

---------------
Troubleshooting
---------------


---------------
Troubleshooting
---------------

Container building
==================

Singularity cache and tmp
-------------------------
Cache directory Error: "FATAL:   While performing build: conveyor failed to get: Error writing blob: write /tmp/bundle-temp-<bundlenumber>/oci-put-blob<blobnumber>>: no space left on device"

Solution: Declare the variables SINGULARITY_CACHEDIR and SINGULARITY_TMPDIR before your singularity build command as follows:

.. code-block:: bash

    mkdir /path/to/singularity_images/SINGCACHE && mkdir /path/to/singularity_images/TMPSING
    SINGULARITY_CACHEDIR=/path/to/singularity_images/SINGCACHE SINGULARITY_TMPDIR=/path/to/singularity_images/SINGTMP singularity build yourimage.sif docker://organization/image:tag

SquashFS-tools
--------------

SquashFS-tools Error: FATAL:   Unable to create build: while searching for mksquashfs: exec: "mksquashfs": executable file not found in $PATH

Solution: Compile squashfs-tools locally from GitHub - https://github.com/plougher/squashfs-tools and add to PATH temporarily as follows

.. code-block:: bash
    
    cd /path/to/singularity_images/
    git clone https://github.com/plougher/squashfs-tools.git
    cd squashfs-tools/squashfs-tools
    make
    export PATH=$PATH:/path/to/singularity_images/squashfs-tools/squashfs-tools


Container running
=================

TemplateFlow
------------

BIDS-Apps failing due to failed attempt to retrieve TemplateFlow images from the web:

.. code-block:: bash

    .....
    urllib3.exceptions.MaxRetryError: HTTPSConnectionPool(host='templateflow.s3.amazonaws.com', port=443): Max retries exceeded with url: /tpl-OASIS30ANTs/tpl-OASIS30ANTs_res-01_T1w.nii.gz (Caused by NewConnectionError('<urllib3.connection.HTTPSConnection object at 0x2aaab5a2c700>: Failed to establish a new connection: [Errno 110] Connection timed out'))
    
    During handling of the above exception, another exception occurred:
    
    Traceback (most recent call last):
    File "/opt/conda/lib/python3.8/multiprocessing/process.py", line 315, in _bootstrap
      self.run()
    File "/opt/conda/lib/python3.8/multiprocessing/process.py", line 108, in run
      self._target(*self._args, **self._kwargs)
    File "/opt/conda/lib/python3.8/site-packages/smriprep/cli/run.py", line 581, in build_workflow
      retval["workflow"] = init_smriprep_wf(
    File "/opt/conda/lib/python3.8/site-packages/smriprep/workflows/base.py", line 166, in init_smriprep_wf
      single_subject_wf = init_single_subject_wf(
    File "/opt/conda/lib/python3.8/site-packages/smriprep/workflows/base.py", line 400, in init_single_subject_wf
      anat_preproc_wf = init_anat_preproc_wf(
    File "/opt/conda/lib/python3.8/site-packages/smriprep/workflows/anatomical.py", line 376, in init_anat_preproc_wf
      brain_extraction_wf = init_brain_extraction_wf(
    File "/opt/conda/lib/python3.8/site-packages/niworkflows/anat/ants.py", line 198, in init_brain_extraction_wf
      tpl_target_path, common_spec = get_template_specs(
    File "/opt/conda/lib/python3.8/site-packages/niworkflows/utils/misc.py", line 78, in get_template_specs
      tpl_target_path = get_template(in_template, **template_spec)
    File "/opt/conda/lib/python3.8/site-packages/templateflow/conf/__init__.py", line 31, in wrapper
      return func(*args, **kwargs)
    File "/opt/conda/lib/python3.8/site-packages/templateflow/api.py", line 79, in get
      _s3_get(filepath)
    File "/opt/conda/lib/python3.8/site-packages/templateflow/api.py", line 222, in _s3_get
      r = requests.get(url, stream=True)
    File "/opt/conda/lib/python3.8/site-packages/requests/api.py", line 75, in get
      return request('get', url, params=params, **kwargs)
    File "/opt/conda/lib/python3.8/site-packages/requests/api.py", line 61, in request
      return session.request(method=method, url=url, **kwargs)
    File "/opt/conda/lib/python3.8/site-packages/requests/sessions.py", line 542, in request
      resp = self.send(prep, **send_kwargs)
    File "/opt/conda/lib/python3.8/site-packages/requests/sessions.py", line 655, in send
      r = adapter.send(request, **kwargs)
    File "/opt/conda/lib/python3.8/site-packages/requests/adapters.py", line 516, in send
      raise ConnectionError(e, request=request)
    requests.exceptions.ConnectionError: HTTPSConnectionPool(host='templateflow.s3.amazonaws.com', port=443): Max retries exceeded with url: /tpl-OASIS30ANTs/tpl-OASIS30ANTs_res-01_T1w.nii.gz (Caused by NewConnectionError('<urllib3.connection.HTTPSConnection object at 0x2aaab5a2c700>: Failed to establish a new connection: [Errno 110] Connection timed out'))
 

Fix use your own pre-downloaded templateflow directory:

.. code-block:: bash

    ls /path/to/singularity_images/templateflow
      tpl-Fischer344  tpl-MNI152NLin2009cAsym  tpl-MNIInfant         tpl-PNC
      tpl-fsaverage   tpl-MNI152NLin2009cSym   tpl-MNIPediatricAsym  tpl-RESILIENT
      tpl-fsLR        tpl-MNI152NLin6Asym      tpl-NKI               tpl-UNCInfant
      tpl-MNI152Lin   tpl-MNI152NLin6Sym       tpl-OASIS30ANTs       tpl-WHS
    
    export TEMPLATEFLOW_HOST_HOME=/path/to/singularity_images/templateflow
    SINGULARITY_ENVTEMPLATEFLOW_HOME=/opt/templateflow
    SINGULARITY_ENVTEMPLATEFLOW_HOME=/opt/templateflow singularity run --nv -B ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITY_ENVTEMPLATEFLOW_HOME},./bids:/data,./bids/derivatives/smriprep:/out,/path/to/singularity_images/license.txt:/opt/freesurfer/license.txt /path/to/singularity_images/smriprep-fastsurfer_dev.sif /data/ /out/ --fs-license-file /opt/freesurfer/license.txt participant --participant-label sub-<participantIDhere>
