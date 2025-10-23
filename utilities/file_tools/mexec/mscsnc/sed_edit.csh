#/bin/csh -f
echo $1 $2
more $1 | sed -f $2 >! sed_out_temp
