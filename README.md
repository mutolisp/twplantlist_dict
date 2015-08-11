#臺灣維管束植物名錄字典檔

平台：MacOS X (10.10, 但應該都可以用)

## 安裝
1. 懶人法：下載並解壓縮[檔案](https://raw.github.com/mutolisp/twplantlist_dict/master/pkg/Plant%20List%20of%20Taiwan.dictionary.zip)後，
把 .dictionary 檔案複製或移動到 ~/Library/Dictionaries 目錄中即可

2. 從源碼 compile (需下載 auxiliary tools，至[](https://developer.apple.com/downloads)下載)
    (1) 開啟 Terminal.app
    (2) 安裝 postgresql 並匯入資料表(待做)
    (3) 輸入 make; make install 即可


## 使用及展示

這個字典檔使用親緣關係分類系統，被子植物採用 Angiosperm Phylogenetic Group III (APG III)

可以使用中文名查學名或學名查中名

![查詢特定物種](https://raw.github.com/mutolisp/twplantlist_dict/master/docs/dict_species.png)

也可以使用科中名/科的學名來查詢該科底下的物種清單
![查詢科底下的物種](https://raw.github.com/mutolisp/twplantlist_dict/master/docs/dict_family_splist.png)
