#!/usr/bin/env bash

DICTNAME=FloraTaiwan2

#backup first
#cp ${DICTNAME}.xml ${DICTNAME}.xml.bak
#clear dict_entry
:> dict_entry2

for (( i = 1 ; i <= 4605 ; i++)); 
do
 for j in sc_name family simple_sc zh_name zh_name2 zh_name3
    do
     if [ ${j} = simple_sc ]; then
        psql -d flora_taiwan -q -c "COPY (SELECT ${j} from namelist where sn=${i}) TO '/tmp/${j}' NULL AS 'null';"
        simple_sc=`cat /tmp/${j}`
        itemid=`sed -e 's/\ /_/g' /tmp/${j}`
     elif [ ${j} = sc_name ]; then
        psql -d flora_taiwan -q -c "COPY (SELECT ${j} from namelist where sn=${i}) TO '/tmp/${j}' NULL AS 'null';"
        sc_name=`cat /tmp/${j}`
     else
        psql -d flora_taiwan -q -c "COPY (SELECT ${j} from namelist where sn=${i}) TO '/tmp/${j}' NULL AS 'null';"
        export `echo ${j}`=`cat /tmp/${j}`
     fi
     size_1=`ls -alh /tmp/ | grep zh_name  | awk -F' ' '{ print $5}'`
     size_2=`ls -alh /tmp/ | grep zh_name2 | awk -F' ' '{ print $5}'`
     size_3=`ls -alh /tmp/ | grep zh_name3 | awk -F' ' '{ print $5}'`
        
        if [ ${size_2} != '2B' -a ${size_3} != '2B' ]; then
            all_zhname=`cat /tmp/zh_name /tmp/zh_name2 /tmp/zh_name3 | sed -e :x -e '$!N;s/\n/ /;tx'`
            zh_name_ne=`cat /tmp/zh_name`
            zh_name2_ne=`cat /tmp/zh_name2`
            zh_name3_ne=`cat /tmp/zh_name3`
            zh_name_value="<d:index d:value=\"${zh_name_ne}\">\n"    "<d:index d:value=\"${zh_name2_ne}\">\n"   "<d:index d:value=\"${zh_name3_ne}\">"
         elif [ ${size_3} = '2B' -a ${size_2} != '2B' ]; then
            all_zhname=`cat /tmp/zh_name /tmp/zh_name2 | sed -e :x -e '$!N;s/\n/ /;tx'`
            zh_name_ne=`cat /tmp/zh_name`
            zh_name2_ne=`cat /tmp/zh_name2`
            zh_name_value="<d:index d:value=\"${zh_name_ne}\">\n    <d:index d:value=\"${zh_name2_ne}\">"
        else
            all_zhname=`cat /tmp/zh_name`
            zh_name_value="<d:index d:value=\"${all_zhname}\">"
     fi
    done

echo "${i} - [${family}] (${simple_sc}, ${zh_name})"
cat >> dict_entry2 << _EOF
<d:entry id="${itemid}" d:title="${simple_sc}">
    <d:index d:value="${simple_sc}"/>
    `echo -e ${zh_name_value}`
    <h1><i>${sc_name}</i> </h1>
        科名：${family}<br/>
        漢名：${all_zhname}<br/>
        <p> 
        <b>Description</b> <br/>
        </p>
        <p> 
        <b>Specimen collections</b> <br/>
        </p>
</d:entry>
_EOF

done

# cat > xmlschema << _EOF
# <?xml version="1.0" encoding="UTF-8"?>
# <!--
#     This is the name list and Flora of Taiwan 2
#     Lin, Cheng-Tao mutolisp _AT_ gmail _DOT_ COM
# -->
# <d:dictionary xmlns="http://www.w3.org/1999/xhtml" xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">
# _EOF
# 
# cat > fb_matter << _EOF
# <d:entry id="front_back_matter" d:title="Front/Back Matter">
#     <h1><b>Flora of Taiwan 2</b></h1>
#     <h2>Front/Back Matter</h2>
#     <div>
#         This is Flora of Taiwan 2 dictionary.<br/><br/>
#     </div>
#     <div>
#         <b>To see</b> this page,
#         <ol>
#             <li>Open "Go" menu.</li>
#             <li>Choose "Front/Back Matter" menu item.
#             If it has sub-menu items, choose one of them.</li>
#         </ol>
#     </div>
#     <div>
#         <b>To prepare</b> the menu item, do the followings.
#         <ol>
#             <li>Prepare this page source as an entry.</li>
#             <li>Add "DCSDictionaryFrontMatterReferenceID" key and its value to the plist of the dictionary.
#             The value should be the string of this page entry id. </li>
#         </ol>
#     </div>
#     <br/>
# </d:entry>
# </d:dictionary>
# _EOF
# 
# cat xmlschema dict_entry fb_matter > ${DICTNAME}.xml
