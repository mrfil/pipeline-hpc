.. _FAQs :

****
FAQs
****

How to build with Docker
========================

From a Dockerfile:

.. code-block:: bash

    cd path/to/Dockerfile
    docker build -t organization/image:tag .
    
`More information <https://docs.docker.com/engine/reference/builder/#format>`_

Example Dockerfile:

.. code-block:: bash

    #base image ubuntu 20.04​
    FROM ubuntu:20.04
    # Disable Prompt During Packages Installation
    ARG DEBIAN_FRONTEND=noninteractive
    # Update Ubuntu Software repository & install python3​
    RUN apt-get update
    RUN apt-get install -y vim nano python3 python3-pip
    
    # Install python3 packages with pip3
    RUN pip3 install numpy, pandas, matplotlib, seaborn, scipy
    
    #Environmental variables​
    ENV VAR="FOO"
    
    #copy files​
    COPY directory/in/build/context /opt/destination/in/image
    
    #Working directory​
    WORKDIR /opt/some/directory
    
    #Entrypoint script for docker exec​
    ENTRYPOINT exec /usr/local/bin/python "$@"

From a Docker repository:

.. code-block:: bash
    
    docker pull organization/image:tag

How to build with Singularity
=============================

From a `def recipe file <https://singularity-userdoc.readthedocs.io/en/latest/container_recipes.html>`_ (requires sudo on most systems, some can bypass with --fakeroot):

.. code-block:: bash

    sudo singularity build image.sif image.def

Example def file:

.. code-block:: bash

    Bootstrap: docker
    From: ubuntu:20.04
    
    %files
    /directory/in/build/context
    /directory/in/build/context /opt/destination/in/image
    
    %environment
    export VAR="FOO"
    
    %runscript
    exec /usr/local/bin/python "$@"
    
    %post
    apt-get update
    apt-get install -y vim nano python3 python3-pip
    pip3 install numpy, pandas, matplotlib, seaborn, scipy

From a Docker repository:

.. code-block:: bash
    
    singularity build imagename.sif docker://organization/image:tag

