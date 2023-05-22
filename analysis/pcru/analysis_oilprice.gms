$Title Oil Price Analysis

set  scn        Scenarios in oil price analysis
       / Ref     Reference oil price
         HOP     High oil price
         LOP     Low oil price    /;


table  pcru_scn(scn,t)      Crude oil brent spot price scenario ($2017 per barrel)
* data during 2015~2050 is provided by EPA and taken from AEO
* data in 2010 is the historical price: 81.31 $2011/barrel from AEO2018
                  2015           2020            2025          2030            2035           2040            2045            2050
    REF          54.3890        69.9609        85.6952        92.8216        99.8657        106.0786        110.0415        113.5585
    HOP          54.3890       122.6483       164.8495       185.5338       199.7384        211.5846        220.3792        229.4992
    LOP          54.3890        31.2787        35.2719        37.5783        41.1244         44.8811         47.9949         51.6367
;

parameter PI_aeo2012(*)     GDP chain-type price index from AEO2012 (1 in 2005)
    / 2009        1.097
      2010        1.110
      2011        1.133
      2015        1.196
      2016        1.217
      2017        1.239
     /;

parameter PI_aeo2018(*)     GDP chain-type price index from AEO2018 (1 in 2009)
    / 2016        1.114
      2017        1.134
     /;


scalar  deflat17to10   deflation factor from $2017 to $2010 /1.1226/
*http://www.in2013dollars.com/2010-dollars-in-2017
        mmbtu_barel    mmbtu per barrel of crude oil        /5.800/;

     deflat17to10= PI_aeo2018("2017")/(PI_aeo2012("2010")/PI_aeo2012("2009"));


parameter   pcru_trd_scn(scn,t)  crude oil price trend (1 in 2010);

     pcru_scn(scn,t)      = pcru_scn(scn,t)/deflat17to10;
     pcru_scn(scn,"2010") = 81.31/(PI_aeo2012("2011")/PI_aeo2012("2010"));
* actual price in ADAGE
*pcru_scn(scn,"2010") = y0("USA","Cru","new")/prod0("USA","cru")*mmbtu_barel;

*pcru_trd_scn(scn,t)  = pcru_scn(scn,t)/pcru_scn(scn,"2010");
pcru_trd_scn(scn,t)   = pcru_scn(scn,t)/(y0("USA","Cru","new")/prod0("USA","cru")*mmbtu_barel);
display pcru_scn,pcru_trd_scn;

parameter  chk_pcru      Check if crude oil price match the target ;




