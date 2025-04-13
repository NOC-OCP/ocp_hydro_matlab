%combine _raw.nc underway RVDAS streams in order to subsequently edit using
%more recent code (which expects more streams to be in each file)

opt1 = 'uway_proc'; opt2 = 'combine'; get_cropt

%first get times
[d1,h] = mload(infiles{1},'/');
time = round(d1.time); %s
for no = 2:length(infiles)
    [d1,h1] = mload(infiles{no},'/');
    time = union(time,round(d1.time)); %extend if relevant
end
clear d
d.time = time;
%now load and paste in data
for no = 1:length(infiles)
    [d1,h1] = mload(infiles{no},'/');
    d1.time = round(d1.time);
    [~,ia,ib] = intersect(d.time,d1.time);
    vars = setdiff(h1.fldnam,'time');
    for vno = 1:length(vars)
        d.(vars{vno}) = NaN+d.time;
        d.(vars{vno})(ia) = d1.(vars{vno})(ib);
        h.fldnam = [h.fldnam vars{vno}]; h.fldunt = [h.fldunt h1.fldunt{strcmp(vars{vno},h1.fldnam)}];
    end
    h.comment = [h.comment sprintf('\n data appended from %s by uway_combine',infiles{no})];
end
h0 = h; clear h
[~,ia,ib] = intersect(fieldnames(d),h0.fldnam);
h.fldnam = h0.fldnam(ib); h.fldunt = h0.fldunt(ib);
h.comment = h0.comment;

mfsave(outfile,d,h)