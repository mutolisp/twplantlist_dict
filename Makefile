DICT=src/flora_taiwan.dict  src/flora_taiwan.idx  src/flora_taiwan.ifo 

all: dict

dict:
		cp $(DICT) Flora_Taiwan ; tar -jcvf Flora_Taiwan.tar.bz2 Flora_Taiwan; \
		./sdconv/convert Flora_Taiwan.tar.bz2 ; mv Flora_Taiwan.tar.bz2 bin
