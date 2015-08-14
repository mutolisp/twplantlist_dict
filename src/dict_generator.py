# coding: utf-8
#!/usr/bin/env python                                                                                                              
import sys                                                                                                                         
import re                                                                                                                          
import psycopg2 as pg

DSN = 'dbname=nvdimp user=psilotum'
conn = pg.connect(DSN)
GET_FAM_SQL = 'SELECT distinct family_apg3,family_apg3_zh from namelist order by family_apg3'
with conn:
    with conn.cursor() as curs:
        curs.execute(GET_FAM_SQL)
        fam_list = curs.fetchall()
def fmtname(name):
    n_split = name.split(' ')
    lenf = len(n_split)
    italic_b = '<i>'
    italic_e = '</i>'
    if 'var.' in n_split:
        sub_idx = n_split.index('var.')
        fmt_name = italic_b + " ".join(str(item) for item in n_split[0:2])+ italic_e
        fmt_author = " ".join(str(item) for item in n_split[sub_idx+2:lenf])
        fmt_sub = italic_b + str(n_split[sub_idx+1]) + italic_e + ' '
        fmt_oname = fmt_name + ' var. ' + fmt_sub + fmt_author
    elif 'subsp.' in n_split:
        sub_idx = n_split.index('subsp.')
        fmt_name = italic_b + " ".join(str(item) for item in n_split[0:2])+ italic_e 
        fmt_author = " ".join(str(item) for item in n_split[sub_idx+2:lenf])
        fmt_sub = italic_b + str(n_split[sub_idx+1]) + italic_e + ' '
        fmt_oname = fmt_name + ' subsp. ' + fmt_sub + fmt_author
    elif 'fo.' in n_split:
        sub_idx = n_split.index('fo.')
        fmt_name = italic_b + " ".join(str(item) for item in n_split[0:2])+ italic_e 
        fmt_author = " ".join(str(item) for item in n_split[sub_idx+2:lenf])
        fmt_sub = italic_b + str(n_split[sub_idx+1]) + italic_e + ' '
        fmt_oname = fmt_name + ' fo. ' + fmt_sub + fmt_author
    elif '×' in n_split:
        fmt_name = italic_b + " ".join(str(item) for item in n_split[0:3])+ italic_e 
        fmt_author = " ".join(str(item) for item in n_split[3:lenf])
        fmt_oname = fmt_name + ' ' + fmt_author
    else:
        fmt_name = italic_b + " ".join(str(item) for item in n_split[0:2])+ italic_e 
        fmt_author = " ".join(str(item) for item in n_split[2:lenf])
        fmt_oname = fmt_name + ' ' + fmt_author
    fmt_oname = re.sub(' ex ', ' ' + italic_b + 'ex' + italic_e + ' ', fmt_oname)
    return(fmt_oname)


# In[143]:

def main():
    expf = open('twplantlist.xml', 'w')
    # Dictionary XML header
    HEADER = '''<?xml version="1.0" encoding="UTF-8"?>
    <!--
        This is the plant list of Taiwan
        Lin, Cheng-Tao mutolisp _AT_ gmail _DOT_ COM (2010--2015)
    -->
    <d:dictionary xmlns="http://www.w3.org/1999/xhtml" xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">'''
    expf.write(HEADER + '\n')
    for f in range(len(fam_list)):
        print(fam_list[f][0])
        ### GENUS
        GET_GENUS_SQL = '''
            SELECT 
                distinct genus_apg3,genus_apg3_zh
            FROM 
                nomenclature.namelist
            WHERE 
                family_apg3 = '%s'
            ORDER BY genus_apg3;
        ''' % fam_list[f][0]
        FAMID = fam_list[f][0]
        FAM_ZH = fam_list[f][1]
        FAM_NAME = fam_list[f][0] + '(%s)' % fam_list[f][1]
        FAM_ENTRY_FRONT = '''<d:entry id="%s" d:title="%s">
        <d:index d:value="%s"/>
        <d:index d:value="%s"/>
        <h2>%s</h2>''' % ( FAMID, FAMID, FAMID, FAM_ZH, FAM_NAME)
        expf.write(FAM_ENTRY_FRONT + '\n')
        with conn:
            with conn.cursor() as curs:
                curs.execute(GET_GENUS_SQL)
                genus_list = curs.fetchall()
        for gsp in range(len(genus_list)):        
            ### SPECIES
            GET_SP_SQL = '''
                SELECT 
                    name,fullname,zh_name 
                FROM 
                    nomenclature.namelist
                WHERE 
                    genus_apg3 = '%s'
                ORDER BY name;
                ''' % genus_list[gsp][0]
            with conn:
                with conn.cursor() as curs:
                    curs.execute(GET_SP_SQL)
                    sp_list = curs.fetchall()            
            expf.write('<i>%s</i> %s\n' % (genus_list[gsp][0], genus_list[gsp][1]))
            expf.write('<ol>\n')
            for sp_in_fam in range(len(sp_list)):
                if sp_in_fam == 0:
                    GENUS_SP_LIST = '  <li>' + fmtname(sp_list[sp_in_fam][0])                                     + ' ' + sp_list[sp_in_fam][2][0] + '</li>\n'
                else:
                    GENUS_SP_LIST = GENUS_SP_LIST + '  <li>' + fmtname(sp_list[sp_in_fam][0])                                     + ' ' + sp_list[sp_in_fam][2][0] + '</li>\n'
            expf.write(GENUS_SP_LIST)
            expf.write('</ol>\n')
        FAM_ENTRY_BACK = '''</d:entry>'''
        expf.write(FAM_ENTRY_BACK + '\n')
        # each species
        GET_SPALL_SQL = '''
                SELECT 
                    name,fullname,zh_name 
                FROM 
                    nomenclature.namelist
                WHERE 
                    family_apg3 = '%s'
                ORDER BY name;
                ''' % fam_list[f][0]
        with conn:
            with conn.cursor() as curs:
                curs.execute(GET_SPALL_SQL)
                sp_list_all = curs.fetchall()
        # species entries
        for s in range(len(sp_list_all)):
            SPID = re.sub(' ', '_', sp_list_all[s][0])
            SPNAME_NO_AUTHOR = sp_list_all[s][0]
            # value of chinese names
            if len(sp_list_all[s][2]) > 1:
                for z in range(len(sp_list_all[s][2])):
                    if sp_list_all[s][2][z] is not None:
                        if z == 0:
                            SP_ZHNAME_VAL = '''<d:index d:value="%s"/>''' % sp_list_all[s][2][z]
                        else:
                            SP_ZHNAME_VAL = SP_ZHNAME_VAL + '\n' + '''    <d:index d:value="%s"/>''' % sp_list_all[s][2][z]
            else:
                SP_ZHNAME_VAL = '''    <d:index d:value="%s"/>''' % sp_list_all[s][2][0]
            # chinese names
            for z in range(len(sp_list_all[s][2])):
                if sp_list_all[s][2][z] is not None:
                    if z == 0:
                        SP_ZHNAME = sp_list_all[s][2][z]
                    else:
                        SP_ZHNAME = SP_ZHNAME + ' ' + sp_list_all[s][2][z]
            SP_FAM = fam_list[f][1] + ' ' + fam_list[f][0]
            # format names
            SPNAME_W_AUTHOR = fmtname(sp_list_all[s][1])
            SPNAME_W_AUTHOR = re.sub('&', '&amp;', SPNAME_W_AUTHOR)
            SP_ENTRY = '''<d:entry id="%s" d:title="%s">
        <d:index d:value="%s"/>
        %s
        <h2>%s</h2>
        科名：%s<br/>
        中名：%s<br/>
    </d:entry>''' % ( SPID, SPNAME_NO_AUTHOR, SPNAME_NO_AUTHOR, \
            SP_ZHNAME_VAL, SPNAME_W_AUTHOR, SP_FAM, SP_ZHNAME)
            expf.write(SP_ENTRY + '\n')
    FRONT_BACK_MATTER='''<d:entry id="front_back_matter" d:title="Front/Back Matter">
        <h1><b>Plant list of Taiwan</b></h1>
        <h2>Front/Back Matter</h2>
        <div>
            This is Plant List of Taiwan.<br/><br/>
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
    </d:entry>'''
    expf.write(FRONT_BACK_MATTER + '\n')
    expf.write('</d:dictionary>')
    expf.close()
if __name__=='__main__':
    main()
