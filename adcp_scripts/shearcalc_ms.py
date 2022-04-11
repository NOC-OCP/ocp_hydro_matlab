#!/usr/bin/env python

"""
Script, based on shearcalc_demo.py, to process a directory full of
LADCP raw files, with a corresponding directory of CTD
time series files

LADCP filenames are expected to have the form whsss_cc.dat
where sss is the three-digit station number and cc is the 
two-digit case number
(however, i think the form is only important for the glob 
and the translation to CTD filename, both coded in this file 
and therefore easily editable)

CTD filenames are expected to have the form ctd.sss.cc.asc
and be formatted as header-less columns (a la ODF flat format)
as currently set, columns are
time_in_seconds, P, [T], [S], lat, lon, [dd] 
as in the LDEO 1Hz files (bracketed columns aren't used here)

No attempt has been made to optimize the editing parameters;
defaults are used.
"""

import os
import glob
import sys

import pycurrents.ladcp.ladcp as ladcp

import numpy as np
import matplotlib.pyplot as plt

from pycurrents.system.pathops import filename_base
from pycurrents.system import safe_makedirs

pathbase = "/local/users/pstar/cruise/"
ctdpath = os.path.join(pathbase, "data/ladcp/ctd")
ladcppath = os.path.join(pathbase, "data/ladcp/raw")
savepath = "/local/users/pstar/cruise/data/ladcp/uhpy/shearcalc"

safe_makedirs(savepath)

def ladcp_files(path):
    flist = glob.glob(os.path.join(path, "wh*.dat"))
    flist.sort()
    return flist

def ctd_from_ladcp(fn):
#construct the ctd file name based on the ladcp filename
    fbase = filename_base(fn)
    sta, cast = fbase[2:].split('_')
    #name = "%03d%02d.ctd" % (int(sta), int(cast))
    name = "ctd.%03d.%02d.asc" % (int(sta), int(cast))
    return name


## Read a Seabird cnv file with a time series ctd record (either the
## original sample rate or processed down to 1 Hz), and return a
## Bunch with dday, pressure, longitude, and latitude.
## eg. 
#ctd_func = ladcp.from_cnv(fname)

# Simple ODF CTD flat file, no header; but on different cruises,
# the number of columns and the column assignments might differ.
ctd_func = ladcp.CTD_flatfile(iseconds=0,
                              ipressure=1,
                              ilongitude=5,
                              ilatitude=4,
                              ncolumns=7,
                              )

for fn in ladcp_files(ladcppath):

    fnbase = filename_base(fn)

#  Example of skipping problematic files:
#    if fnbase.startswith("wh013"):
#        print "skipping 13"   # split WH files
#        continue

    save_base = os.path.join(savepath, fnbase)
    npzfn = save_base + ".npz"

#  Uncomment the following to skip calculation if it has been done already.
#    if os.path.exists(npzfn):
#        continue

    try:
        ctdfn = os.path.join(ctdpath, ctd_from_ladcp(fn))
    except ValueError:
        continue

    print "LADCP file: %s    CTD file: %s" % (fn, ctdfn)

    if not os.path.exists(ctdfn):
        print "No ctd file. Skipping."
        continue

    uv = ladcp.Velocity(fn, ctd_fname=ctdfn, ctd_func=ctd_func,
                         dz=2, ndgrid=3000)

    fig = ladcp.plot_ladcp(uv.profile, fnbase)
    fig.savefig(save_base + ".png")

    try: 
        uv.save_mat(save_base + ".mat")
    except:
        print 'cannot save matfile -- no scipi?'
    
    uv.save_npz(save_base + ".npz")

    plt.close(fig)

