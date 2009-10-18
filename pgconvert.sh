#!/usr/bin/env bash

DICTNAME=FloraTaiwan2

#backup first
#cp ${DICTNAME}.xml ${DICTNAME}.xml.bak

if [ -d /tmp/f ] ; then
    echo "/tmp/f exists"
else
    mkdir /tmp/f ; chmod 777 /tmp/f
fi

if [ -d /tmp/g ] ; then
    echo "/tmp/g exists"
else
    mkdir /tmp/g ; chmod 777 /tmp/g
fi

#backup dictionary entry before empty it 
cp dict_entry dict_entry.bak
#clear dict_entry, gen, fam entries
:> dict_entry
:> dict_gen_entry
:> dict_fam_entry

for (( i = 1 ; i <=4605  ; i++)); 
do
 for j in sc_name family simple_sc zh_name zh_name2 zh_name3 collection description synonyms
    do
     # extract data from pgsql database
     if [ ${j} = simple_sc ]; then
        psql -d flora_taiwan -q -c "COPY (SELECT ${j} from namelist where sn=${i}) TO '/tmp/${j}' WITH NULL AS 'nodata';"
        simple_sc=`cat /tmp/${j}`
        itemid=`sed -e 's/\ /_/g' /tmp/${j}`
     elif [ ${j} = sc_name ]; then
        psql -d flora_taiwan -q -c "COPY (SELECT ${j} from namelist where sn=${i}) TO '/tmp/${j}' WITH NULL AS 'nodata';"
        sc_name=`cat /tmp/${j}`
     elif [ ${j} = description ]; then
        psql -d flora_taiwan -q -c "COPY (SELECT ${j} from namelist where sn=${i}) TO '/tmp/${j}' WITH NULL AS 'nodata';"
        description=`cat /tmp/${j}`
     elif [ ${j} = collection ]; then
        psql -d flora_taiwan -q -c "COPY (SELECT ${j} from namelist where sn=${i}) TO '/tmp/${j}' WITH NULL AS 'nodata';"
        collection=`cat /tmp/${j}`
     elif [ ${j} = synonyms ]; then
        psql -d flora_taiwan -q -c "COPY (SELECT ${j} from namelist where sn=${i}) TO '/tmp/${j}' WITH NULL AS 'nodata';"
        synonyms=`cat /tmp/${j}`
     else
        psql -d flora_taiwan -q -c "COPY (SELECT ${j} from namelist where sn=${i}) TO '/tmp/${j}' WITH NULL AS 'nodata';"
        export `echo ${j}`=`cat /tmp/${j}`
     fi

     # check file size, only add non-empty chinese words   
     size_1=`ls -alh /tmp/ | grep zh_name  | awk -F' ' '{ print $5}'`
     size_2=`ls -alh /tmp/ | grep zh_name2 | awk -F' ' '{ print $5}'`
     size_3=`ls -alh /tmp/ | grep zh_name3 | awk -F' ' '{ print $5}'`
     if [ ${size_2} != '2B' -a ${size_3} != '2B' ]; then
         all_zhname=`cat /tmp/zh_name /tmp/zh_name2 /tmp/zh_name3 | sed -e :x -e '$!N;s/\n/ /;tx'`
         zh_name_ne=`cat /tmp/zh_name`
         zh_name2_ne=`cat /tmp/zh_name2`
         zh_name3_ne=`cat /tmp/zh_name3`
         zh_name_value="<d:index d:value=\"${zh_name_ne}\"/>\n
             <d:index d:value=\"${zh_name2_ne}\"/>\n
             <d:index d:value=\"${zh_name3_ne}\"/>"
      elif [ ${size_3} = '2B' -a ${size_2} != '2B' ]; then
         all_zhname=`cat /tmp/zh_name /tmp/zh_name2 | sed -e :x -e '$!N;s/\n/ /;tx'`
         zh_name_ne=`cat /tmp/zh_name`
         zh_name2_ne=`cat /tmp/zh_name2`
         zh_name_value="<d:index d:value=\"${zh_name_ne}\"/>\n
             <d:index d:value=\"${zh_name2_ne}\"/>"
      else
         all_zhname=`cat /tmp/zh_name`
         zh_name_value="<d:index d:value=\"${all_zhname}\"/>"
     fi
     
     # check description, collection and synonyms
     

    done
     

echo "${i} - [${family}] (${simple_sc}, ${zh_name})"
cat >> dict_entry << _EOF
<d:entry id="${itemid}" d:title="${simple_sc}">
    <d:index d:value="${simple_sc}"/>
    `echo -e ${zh_name_value}`
    <h1><i>${sc_name}</i> </h1>
        科名：${family}<br/>
        漢名：${all_zhname}<br/>
        <br/>
        <div>
        <u>Synonyms</u><br/>
        </div>
        <p> 
        <u>Description</u> <br/>
        <br/>
        `echo -e ${description}`
        </p>
        <p> 
        <u>Specimen collections</u> <br/>
        <br />
        `echo -e ${collection}`
        </p>
</d:entry>
_EOF

done
######################
# find family
#####################
for fam in `cat family`
do
  
 # select all of the species
  psql -d flora_taiwan -q -c "COPY (SELECT simple_sc,zh_name from namelist where family='${fam}') TO '/tmp/f/${fam}' DELIMITER AS ',';"
  family_species=`cat /tmp/f/${fam}`
  echo "Processing ${fam}..."

cat >> dict_fam_entry << _EOF
<d:entry id="${fam}" d:title="${fam}">
     <d:index d:value="${fam}"/>
     <h1>${fam}</h1>
         <p>
         ${family_species}
         </p>
</d:entry>
_EOF

done

######
# find genus
######

#psql -d flora_taiwan -q -c "COPY (SELECT genus from namelist GROUP BY genus) TO '/tmp/genus';"

for gen in `cat genus` 
    do 
        psql -d flora_taiwan -c -q "COPY (SELECT simple_sc,zh_name FROM namelist WHERE genus='${gen}') TO '/tmp/g/${gen}';";
        gen_species=`cat /tmp/g/${gen}`
        echo "Processing ${gen}..."

cat >> dict_gen_entry << _EOF
<d:entry id="${gen}" d:title="${gen}">
    <d:index d:value="${gen}"/>
    <d:index d:value="${gen}屬"/>    <h1>${gen}</h1>
        <p>
        ${gen_species}
        </p>
</d:entry>
_EOF

done


# combine xml header and dictionary entries (each species, family, genus)

cat > xmlschema << _EOF
<?xml version="1.0" encoding="UTF-8"?>
<!--
    This is the name list and Flora of Taiwan 2
    Lin, Cheng-Tao mutolisp _AT_ gmail _DOT_ COM
-->
<d:dictionary xmlns="http://www.w3.org/1999/xhtml" xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">
_EOF

cat > fb_matter << _EOF
<d:entry id="front_back_matter" d:title="Front/Back Matter">
    <h1><b>Flora of Taiwan 2</b></h1>
    <h2>Front/Back Matter</h2>
    <div>
        This is Flora of Taiwan 2 dictionary.<br/><br/>
    </div>
    <div>
        <b>To see</b> this page,
        <ol>
            <li>Open "Go" menu.</li>
            <li>Choose "Front/Back Matter" menu item.
            If it has sub-menu items, choose one of them.</li>
        </ol>
    </div>
    <div>
        <b>To prepare</b> the menu item, do the followings.
        <ol>
            <li>Prepare this page source as an entry.</li>
            <li>Add "DCSDictionaryFrontMatterReferenceID" key and its value to the plist of the dictionary.
            The value should be the string of this page entry id. </li>
        </ol>
    </div>
    <br/>
</d:entry>
</d:dictionary>
_EOF

sed -i "" 's/&/&amp;/g' dict_entry

echo "Preprocess done! Compile ${DICTNAME} dictionary"
cat xmlschema dict_entry dict_fam_entry dict_gen_entry fb_matter > ${DICTNAME}.xml
make; make install
