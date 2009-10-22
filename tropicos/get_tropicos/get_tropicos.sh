#!/usr/bin/env bash 
#namelist=namelist.csv
namelist=4k
i=3001
exec_wget() {
    wget --user-agent="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_1; en-us)" "http://www.tropicos.org/NameSearch.aspx?name=${s2}" -O ${i}.html
    echo "Converting ${i}.html to ${i}.txt"
    html2text  -ascii -width 200 -nobs -style pretty ${i}.html > ${i}.txt
    # eliminate strange ^H
   # sed -i "" 's/_//g' ${i}.txt
   # sed -i "" 's///g' ${i}.txt
   # sed -i "" 's/FFaammiillyy/Family/g' ${i}.txt
   # sed -i "" 's/SScciieennttiiffiicc NNaammee/Scientific Name/g' ${i}.txt
   # sed -i "" 's/AAuutthhoorr/Author/g' ${i}.txt
   # sed -i "" 's/RReeffeerreennccee/Reference/g' ${i}.txt
   # sed -i "" 's///g' ${i}.txt
}

for s in `cat ${namelist} | awk -F',' '{ print $3}'`
    do 
    # sleep random seconds to catch data 
    #random=$((RANDOM%300)) 
    #echo "sleep ${random} seconds to avoid high loading of the server" ; sleep ${random} &&
    #if [ `echo ${s} | grep \"+var.+\" | wc -l` -eq 1 -a `echo ${s} | grep \"+subsp.+\" | wc -l` -lt 1 -a `echo ${s} | grep \"+f.+\" | wc` -lt 1 ]; then
    if [ `echo ${s} | grep "+var." | wc -l ` -eq 1 ] && [`echo ${s} | grep \"+subsp.+\" | wc -l` != 1 ]; then
        if [ `echo ${s} | grep \"+f.+\" | wc -l` -eq 1 ]; then 
            echo "${s}, manually search this item!" 
        fi
        s2=`echo ${s} | sed 's/+var.//g'`
        echo ${s}, ${s2}
        exec_wget
    elif [ `echo ${s} | grep "+subsp.+" | wc -l` -eq 1 ] && [ `echo ${s} | grep "+var.+" | wc -l` != 1 ]; then
       s2=`echo ${s} | sed 's/+subsp.//g'`
       echo ${s}, ${s2}
       exec_wget
    else
        s2=${s}
        exec_wget
    fi
    let i+=1
done
