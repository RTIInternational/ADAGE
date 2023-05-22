$title ADAGE Model - Set Definition

set   year          Annual time period  /2010*2050/

set   t(year)       Time periods to use from 2010 to 2050
      /2010, 2015, 2020, 2025, 2030, 2035, 2040, 2045, 2050 /;

alias   (t,tt,ttt) ;

set  reg              Eight regions included in the model
       /USA             "United States"
        BRA             "Brazil"
        CHN             "China"
        EUR             "Europe Union 27"
        XLM             "Rest of South America (no Mexico)"
        XAS             "Rest of Asia"
        AFR             "Africa"
        ROW             "Rest of World (has Mexico)"
        Total           "Global Total"
       /

     r(reg)          Eight regions
       /USA             "United States"
        BRA             "Brazil"
        CHN             "China"
        EUR             "Europe Union 27"
        XLM             "Rest of South America"
        XAS             "Rest of Asia"
        AFR             "Africa"
        ROW             "Rest of World"
       /

     deppr(reg)      Six developing regions
       / BRA             "Brazil"
         CHN             "China"
         XLM             "Rest of South America"
         XAS             "Rest of Asia"
         AFR             "Africa"
         ROW             "Rest of World"
        /

     depdr(reg)      Two developed regions
       /USA             "United States"
        EUR             "Europe Union 27"
       /

     num(r)          Numeraire region / USA /
     chn(r)          China            / CHN /;


**--- All Sectors ---**
set  i               All sectors
       /
**---  Energy Industries ---**
        Col             "Coal"
        Cru             "Crude oil"
        Ele             "Electricity"
        Gas             "Natural gas"
        Oil             "Refined petroleum"

**---  Electricity Generation ---**
        Conv            "Conventional fossil electricity"
          Conv_Col      "Conventional coal generation"
          Conv_Gas      "Conventional natural gas generation"
          Conv_Oil      "Conventional refined oil generation"
        Nuc             "Nuclear electricity"
        Hyd             "Hydro and geothermal electricity"
        Geo             "Geothermal electricity"
        Bio             "Biomass electricity"
        Wnd             "Wind electricity"
        Sol             "Solar electricity"
        Bat             "Electricity storage such as battery"

**---  Advanced technology for electricity generation
        CCS_Col         "Coal carbon capture and storage"
        CC_Gas          "Natural gas combined cycle"
        CCCCS_Gas       "Natural gas combined cycle with carbon capture and storage"
        Wnd_Gas         "Wind generation backed by natural gas"
        Sol_Gas         "Solar genration backed by natural gas"

**--- Biofuels ---**
        Ethl            "Ethanol aggregate"
        Ceth            "Corn ethanol"
        Weth            "Wheat ethanol"
        Scet            "Sugarcane ethanol"
        Sbet            "Sugarbeet ethanol"

        Biod            "Biodiesel aggregate"
        Sybd            "Soybean biodiesel"
        Rpbd            "Rape-mustard biodiesel"
        Plbd            "Palm-Kernel biodiesel"
        Cobd            "Corn-oil biodiesel (introduced after 2010)"

**--- Advanced Biofuels ---**
        Advb            "Advanced biofuel aggregate"
        Swge            "Advanced cellulosic ethanol from switchgrass"
        Albd            "Advanced biodiesel from algae"
        Msce            "Advanced cellulosic ethanol from miscanthus"
        ArsE            "Ethanol from ag residue (cost based on corn stover)"
        FrsE            "Ethanol from forest residue (cost based on hardwood residue)"
        FrwE            "Ethanol from forest pulpwood (cost based on hardwood pulp)"

**--- Coproducts ---**
        Ddgs            "Distillers grains with solubles (DDGs) - coproduct from corn ethanol production"
        Omel            "Vegetable oil meal - coproduct from vegetable oil production"

**--- General Sectors ---**
        Crop            "Crop aggregate"
**--- cereals
        Wht             "Wheat"
        Corn            "Corn"
        Gron            "Rest of cereal grains including rice, oats, barley, sorghum"
**--- oilseeds ---**
        Soyb            "Soybean"
        Osdn            "Rest of Oilseeds"
**--- Sugar crops ---**
        Srcn            "Sugarcane"
        Srbt            "Sugarbeet"

        Ocr             "Crops not elsewhere classified"

        Liv             "Livestock or pasture land"
        Frs             "Forestry or managed forestland"
*--- processed food products ---**
        Mea             "Meat"
        Vol             "Vegetable oils"
        Ofd             "Other food products"

*--- Industrial sectors ---**
        Eim             "Energy-intensive manufacturing"
        Man             "Other manufacturing"
        Srv             "Services"

*--- Transportation sectors ---**
        AirP            "Airline transportation (passenger)"
        WtrT            "Marine transportation (freight and passenger)"
        RalF            "Rail freight"
        RodF            "Road freight (medium and large truck)"
        RalP            "Rail passenger"
        RodP            "Road passenger (bus)"
        Auto            "LDV passenger (car and light truck)"
        Otrn            "Other transportation (off-road & pipeline)"

**--- Vehicle Types in Auto sector ---**
        Auto_OEV        "LDV passenger - traditional gasoline-ethanol vehicle"
        Auto_GasV       "LDV passenger - advanced compressed gas vehicle"
        Auto_BEV        "LDV passenger - advanced electric battery vehicle"
        Auto_HEV        "LDV passenger - advanced hybrid vehicle"
        Auto_FCEV       "LDV passenger - advanced hydrogen vehicle"

**--- Vehicle Types in RodF sector ---**
        RodF_OEV        "Road freight - traditional gasoline-ethanol vehicle"
        RodF_GasV       "Road freight - advanced compressed gas vehicle"
        RodF_BEV        "Road freight - advanced electric battery vehicle"
        RodF_HEV        "Road freight - advanced hybrid vehicle"
        RodF_FCEV       "Road freight - advanced hydrogen vehicle"

**--- Vehicle Types in RodP sector ---**
        RodP_OEV        "Road passenger - traditional gasoline-ethanol vehicle"
        RodP_GasV       "Road passenger - advanced compressed gas vehicle"
        RodP_BEV        "Road passenger - advanced electric battery vehicle"
        RodP_HEV        "Road passenger - advanced hybrid vehicle"
        RodP_FCEV       "Road passenger - advanced hydrogen vehicle"

**--- Aggregate of transportation sectors other than Auto, RodF, RodP ---**
        Otrn_OEV        "aggregated transportation sectors"

**--- Households ---**
        HH              "All households"

**--- Miscellaneous  ---**
        Current         "Current type of personal vehicles"
        House           "Housing"

        New             "New (flexible) production"
        Extant          "Extant (existing) production"

**--- land type ---**
*       crop           "cropland"
*       liv            "Pasture land"
*       For            "Managed forestry land "
        Nfrs           'Natural forest land'
        Ngrs           'Natural grassland'
*       Othr           'Other type of land'
      /;

alias   (i,j) ;
alias   (iii,*);

**--- industrial/agricultural sectors *---
set  s(i)           Agricultural and Industrial Sectors
       /
        wht             "Wheat"
        corn            "Corn"
        gron            "Rest of cereal grains nec"
        soyb            "Soybean"
        osdn            "Rest of oilseeds"
        srcn            "Sugarcane"
        srbt            "Sugarbeet"
        ocr             "Crops nec"

        LIV             "Livestock"
        FRS             "Forestry"

        MEA             "Meat"
        VOL             "Vegetable oils"
        OFD             "Other foods products"

        EIM             "Energy-intensive manufacturing"
        MAN             "Other Manufacturing"
        SRV             "Services"

        AirP            "Airline transportation (passenger)"
        WtrT            "Marine transportation (freight)"
        RalF            "Rail freight"
        RodF            "Road freight (medium and large truck)"
        RalP            "Rail passenger"
        RodP            "Road passenger (bus)"
        Auto            "LDV passenger (car and light truck)"
        Otrn            "Other transportation (off-road & pipeline)"
       /;

set  agr(i)        Agricultural goods
      / wht             "Wheat"
        corn            "Corn"
        gron            "Rest of cereal grains nec"
        soyb            "Soybean"
        osdn            "Rest of Oilseeds"
        srcn            "Sugarcane"
        srbt            "Sugarbeet"
        ocr             "Crops nec"
        liv             "Livestock"
        frs             "Forestry"
      /

     crop(i)        Crop or cropland               / crop/
     liv(i)         Livestock or pastureland       / liv /
     frs(i)         Forestry or managed forestland / frs /

     crp(i)         Crops
      / wht           "Wheat"
        corn          "Corn"
        gron          "Rest of cereal grains nec"
        soyb          "Soybean"
        osdn          "Rest of oilseeds"
        srcn          "Sugarcane"
        srbt          "Sugarbeet"
        ocr           "Crops nec"
       /

     vol(i)        "Vegetable oil"         / vol /
     ofd(i)        "Other food products"   / ofd /
     chm(i)        "Chemicals"             / eim /

     feed(i)       "Feedstock for livestock"
       /wht           "Wheat"
        corn          "Corn"
        gron          "Rest of cereal grains nec"
        soyb          "Soybean"
        osdn          "Rest of oilseeds"
        srcn          "Sugarcane"
        srbt          "Sugarbeet"
        ocr           "Crops nec"
        ddgs          "Distillers grains with solubles (DDGs)-coproduct of corn ethanol production"
        omel          "Vegetable oil meal - coproduct of vegetable oil production"
       /

* excludes vol as it is used as feedstock in sybd, rpbd, plbd production
     biog(i)       Inputs other than feedstock used in biofuels    / mea,ofd,eim,man,srv /

     food(i)       Processed food sectors  / mea, vol, ofd /
     ind(i)        Industrial sectors      / eim, man, srv, AirP, WtrT, RalF, RodF, RalP, RodP, Otrn /
     indm(i)       Manufacturing sectors   / eim, man /

     byprod(i)     Byproducts              / ddgs,omel /
     srv(s)        Service goods           / srv /  ;

set  scons(i)  Sectors for which household consumption is dynamic or adjusted by population or income growth;
     scons(agr)   = yes;
     scons(food)  = yes;
     scons("Auto")= yes;
     scons("RodP")= yes;

Set  trn(s)        Transportation          /AirP, WtrT, RalF, RodF, RalP, RodP, Auto , Otrn/
     trni(i)       Transportation          /AirP, WtrT, RalF, RodF, RalP, RodP, Auto , Otrn/
     tranp(i)      Passenger transportation         /AirP, Auto, RalP, RodP/
     tranO(i)      Non-passenger (not strict)       /WtrT, RalF, RodF, Otrn/
     trnv(i)       Onroad transportation sector     /Auto, RodF, RodP/
     hdv(i)        Heavy-duty transportation        /RodF, RodP/
     rodp(i)       Bus transportation               /RodP/
     RodF(i)       Freight truck transportation     /RodF/
     Auto(i)       Auto transportation              /Auto/
     Otrn(i)       Other transportation             /Otrn/

     Autoi(i)      Sectors in auto industry
        /Auto_OEV      Traditional gasoline or gasoline-ethanol vehicle
         Auto_gasV     Advanced natural gas vehicle
         Auto_BEV      Advanced electric battery vehicle
         Auto_HEV      Advanced hybrid vehicle
         Auto_FCEV     Advanced hydrogen vehicle
        /
     AutoAfv(i)    Advanced alternative vehicle in auto industry
        /Auto_gasV     Advanced natural gas vehicle
         Auto_BEV      Advanced electric battery vehicle
         Auto_HEV      Advanced hybrid vehicle
         Auto_FCEV     Advanced hydrogen vehicle
        /

     HDVi(i)       Heavy-duty onroad transportation
       /RodF_OEV       Traditional gasoline or gasoline-ethanol road freight vehicle
        RodF_GasV      Advanced natural gas road freight vehicle
        RodF_BEV       Advanced electric battery road freight vehicle
        RodF_HEV       Advanced hybrid road freight vehicle
        RodF_FCEV      Advanced hydrogen road freight vehicle
        RodP_OEV       Traditional gasoline or gasoline-ethanol road passenger vehicle
        RodP_GasV      Advanced natural gas road passenger vehicle
        RodP_BEV       Advanced electric battery road passenger vehicle
        RodP_HEV       Advanced hybrid road passenger vehicle
        RodP_FCEV      Advanced hydrogen road passenger vehicle
        /
     RodFi(i)      Road freight
       /RodF_OEV
        RodF_GasV
        RodF_BEV
        RodF_HEV
        RodF_FCEV
       /
     RodFAFV(i)    Road freight - advanced alternative vehicle
        /RodF_GasV
         RodF_BEV
         RodF_HEV
         RodF_FCEV
        /

     RodPi(i)      Road passenger
        /RodP_OEV
         RodP_GasV
         RodP_BEV
         RodP_HEV
         RodP_FCEV
        /
     RodPAFV(i)    Road passenger  - advanced alternative vehicle
        /RodP_GasV
         RodP_BEV
         RodP_HEV
         RodP_FCEV
        /

     AFV(i)        Alternative fuel vehicles
        /Auto_GasV ,  RodF_GasV ,  RodP_GasV
         Auto_BEV  ,  RodF_BEV  ,  RodP_BEV
         Auto_HEV  ,  RodF_HEV  ,  RodP_HEV
         Auto_FCEV ,  RodF_FCEV ,  RodP_FCEV
        /

     HDVAFV(i)     HDV - Alternative fuel vehicles
        /RodF_GasV ,  RodP_GasV
         RodF_BEV  ,  RodP_BEV
         RodF_HEV  ,  RodP_HEV
         RodF_FCEV ,  RodP_FCEV
        /

     OEV(i)        Traditional onroad gasoline or gasoline-ethanol vehicle
        /Auto_OEV,  RodF_OEV,  RodP_OEV, Otrn_OEV /
     HEV(i)       Advanced hybrid vehicle
        /Auto_HEV, RodF_HEV, RodP_HEV/
     BEV(i)       Advanced battery vehicle
        /Auto_BEV, RodF_BEV, RodP_BEV/
     FCEV(i)       Advanced hydrogen vehicle
        /Auto_FCEV, RodF_FCEV, RodP_FCEV/
     GASV(i)       Advanced natural gas vehicle
        /Auto_GasV, RodF_GasV, RodP_GasV/
     BioAFV(i)     Advanced vehicle refined oil is used so biofuel can be used to replace refined oil
        /Auto_GasV, Auto_HEV, RodF_HEV, RodP_HEV/
     NoBioAFV(i)     Advanced vehicle where refined oil is not used so no biofuel substitution
        /Auto_BEV, RodF_BEV, RodP_BEV, Auto_FceV, RodF_FceV, RodP_FceV, RodF_GasV, RodP_GasV/
     BioAutoAFV(i)    /Auto_HEV, Auto_GasV/
     AutoOEV(i)       /Auto_OEV/
     BioRodFAFV(i)    /RodF_HEV/
     rodFOEV(i)       /RodF_OEV/
     BioRodPAFV(i)    /RodP_HEV/
     RodPOEV(i)       /RodP_OEV /

     trnrod(i)     Onroad transportation where data sources are available 
        /RodF, RodP, auto_OEV, auto_GasV, auto_BEV, auto_HEV, auto_FCEV  /

set  maptrn(i,j)  map onroad transportation sector and its afv sectors
          /Auto . (Auto_OEV, Auto_GasV,  Auto_BEV, Auto_HEV, Auto_FCEV)
           RodF . (RodF_OEV, RodF_GasV,  RodF_BEV, RodF_HEV, RodF_FCEV)
           RodP . (RodP_OEV, RodP_GasV,  RodP_BEV, RodP_HEV, RodP_FCEV)
          /
     mapoev(i,j) map oev to its general sectors (used in report writing)
          /Auto_OEV .Auto
           RodF_OEV .RodF
           RodP_OEV .RodP
$ifthen  setglobal  aggtrn
           Otrn_OEV .Otrn      !in case aggtrn is activated
$endif
          /

    maptrn2(i,j)  map onroad transportation sector and its afv sectors
          /Auto . (Auto, Auto_OEV, Auto_GasV,  Auto_BEV, Auto_HEV, Auto_FCEV)
           RodF . (RodF, RodF_OEV, RodF_GasV,  RodF_BEV, RodF_HEV, RodF_FCEV)
           RodP . (RodP, RodP_OEV, RodP_GasV,  RodP_BEV, RodP_HEV, RodP_FCEV)
          /

    maptrn3(i,j)  map onroad transportation sector and its afv sectors
          /Auto_OEV . (Auto_OEV,  Auto_GasV,  Auto_BEV, Auto_HEV, Auto_FCEV)
           RodF_OEV . (RodF_OEV,  RodF_GasV,  RodF_BEV, RodF_HEV, RodF_FCEV)
           RodP_OEV . (RodP_OEV,  RodP_GasV,  RodP_BEV, RodP_HEV, RodP_FCEV)
          /;

set  ddgs(i)    /ddgs/
     omel(i)    /omel/
     corn(i)    /corn/;

set  agrbio(i)     Ag & byproducts & biofuel & processed food
       /ceth    "Corn ethanol"
        weth    "Wheat ethanol"
        scet    "Sugarcane ethanol"
        sbet    "Sugarbeet ethanol"

        sybd    "Soybean biodiesel"
        rpbd    "Rape-Mustard biodiesel"
        plbd    "Palm-Kernel biodiesel"
        Cobd    "Corn-oil biodiesel (introduced after 2010)"

        ddgs    "Distillers grains with solubles (DDGs) - byproduct from corn ethanol production"
        omel    "Vegetable oil meal - byproduct from vegetable oil production"

        wht     "Wheat"
        corn    "Corn"
        gron    "Rest of cereal grains not elsewhere classified"
        soyb    "Soybean"
        osdn    "Rest of oilseeds"
        srcn    "Sugarcane"
        srbt    "Sugarbeet"
        ocr     "Crops not elsewhere classified"

        LIV     "Livestock"
        FRS     "Forestry"

        MEA     "Meat"
        VOL     "Vegetable oils"
        OFD     "Other food products"
      /;

set  mat(i)        "Material inputs"
     man(s)        "Manufacturing goods"
     s_trn(s)      "Sectors excluding transport"
     trnall(i)     "All transportation sectors"     ;

    mat(s) = s(s);
    man(s) = s(s) - srv(s) - trn(s) - agr(s);
    s_trn(s) = s(s) - trn(s);

    trnall(trn) = yes;
    trnall(oev) = yes;
    trnall(afv) = yes;

display s_trn,man,trnall;

**--- energy  ---**
set  cego(i)       Coal & electricity & natural gas & refined oil  / col,ele,gas,oil /
     ceg(i)        Coal & electricity & natural gas                / col,ele,gas /
     cgo(i)        Coal & natural gas & refined oil                / col,gas,oil /
     ego(i)        Electricity & natural gas & refined oil         / ele,gas,oil /
     eg(i)         Electricity & natural gas                       / ele,gas /
     col(i)        Coal          / col /
     cru(i)        Crude oil     / cru /
     ele(i)        Electricity   / ele /
     gas(i)        Natural gas   / gas /
     oil(i)        Refined oil   / oil /

     ff(i)         Fossil fuels
       /col, cru, gas, oil/  ;

set  e(i)          All energy including first and second generation biofuels
       /col , cru , gas , oil , ele
        ceth, weth, scet, sbet
        sybd, rpbd, plbd, cobd
        advb, Swge, Albd, Msce, ArsE, FrsE, FrwE
       /

     et(e)         First generation ethanol     /ceth, weth, scet, sbet/
     bd(e)         First generation biodiesel  /sybd, rpbd, plbd, cobd/
     ad(e)         Advanced biofuel             /Swge, Albd, Msce, ArsE, FrsE, FrwE/
     advb(e)       Advanced biofuel aggregates  /advb/

     bioe(e)       First generation biofuels
       /ceth, weth, scet, sbet
        sybd, rpbd, plbd, cobd   /

     cegoe(i)      Fossil fuel and first generation biofuels
       /col , ele , gas , oil
        ceth, weth, scet, sbet
        sybd, rpbd, plbd, cobd   /

     bio(i)        First generation biofuels
       /ceth, weth, scet, sbet
        sybd, rpbd, plbd, cobd /

     ethl(i)       First generation ethanol     /ceth, weth, scet, sbet/
     biod(i)       First generation biodiesel   /sybd, rpbd, plbd, Cobd/
     advbio(e)     Advanced biofuels            /Swge,Albd,Msce,ArsE,FrsE,FrwE/

     ceth(i)       Corn ethanol                 /ceth/
     sybd(i)       Soybean Biodiesel            /sybd/
     cobd(i)       Corn-oil biodiesel           /cobd/

     Swge(i)         /Swge/
     Msce(i)         /Msce/
     Albd(i)         /Albd/
     ArsE(i)         /ArsE/
     FrsE(i)         /FrsE/
     FrwE(i)         /FrwE/

     advl(advbio)  Advanced biofuels that use land  /swge,msce,frwe/
     ob(i)         Biofuels and refined oil mix used in transportation
        /oil
         ceth, weth, scet, sbet
         sybd, rpbd, plbd, cobd
         Swge, Albd, Msce, ArsE, FrsE, FrwE  /;

set  lu(i)        land use categories
     /  crop         Cropland
        Liv          Pasture land
        Frs          Managed Forestry
        Ngrs         Natural grassland
        Nfrs         Natural forestry land
*       Othr         Other type of land
      /

     agri(lu)      Agricultural land        / Crop, Liv, Frs /
     nat(lu)       Natural land             / Nfrs,  Ngrs /
     nfrs(nat)     Natural forestry land    / Nfrs /
     ngrs(nat)     Natural grassland        / Ngrs / ;


* electricity generation types
set  gentype(i)    Types of electricity generation
      /
**---  Electricity Generation ---**
        Conv            "Conventional fossil electricity"
          Conv_Col      "Conventional coal generation"
          Conv_gas      "Conventional natural gas generation"
          Conv_Oil      "Conventional refined oil generation"
        nuc             "Nuclear electricity"
        hyd             "Hydropower electricity"
        geo             "Geothermal electricity"
        bio             "Biomass electricity"
        wnd             "Wind electricity"
        sol             "Solar electricity"
        bat             "Electricity storage such as battery"

**---  Advanced technology for electricity generation
        CCS_col         "Coal carbon capture and storage (90% capture)"
        CC_gas          "Natural gas combined cycle"
        CCCCS_gas       "Natural gas combined cycle with carbon capture and storage (90% capture)"
        wnd_gas         "Wind generation backed by natural gas"
        sol_gas         "Solar genration backed by natural gas"

*       swge            "Electricity generated from swge production
      /
     convrnw(i)    Conventional and renewable generation / conv_col, conv_gas, conv_oil
                                                           nuc, hyd, bio, geo, wnd, sol/
     conv(i)       Conventional generation      / conv/
     convi(i)      Conventional generation      / conv_col, conv_gas, conv_oil /
     cc_gas(i)     Combined cycle natural gas   /CC_gas/
     rnw(i)        Renewable generation         / nuc, hyd, bio, geo, wnd, sol/
     conv_oil(i)   Conventional generation      / conv_oil /
     wndsol(i)     Wind and Solar               / wnd, sol/
     wnd(i)        Wind generation              / wnd/
     sol(i)        Solar generation             / sol/
     hydgeo(i)     Hydropower and Geothermal    / Hyd, geo /
     bioelec(i)    Bioelectricity generation    / bio/
     geo(i)        Geothermal                   / geo/
     nuc(i)        Nuclear generation           / nuc/


     adve(i)       Advanced technology for electricity generation
      / CCS_col         "Coal carbon capture and storage"
        CC_gas          "Natural gas combined cycle"
        CCCCS_gas       "Natural gas combined cycle with carbon capture and storage"
        wnd_gas         "wind generation backed by natural gas"
        sol_gas         "solar generation backed by natural gas"
      /

    advee(i)      Advanced technology for electricity generation (near-term)
      / CCS_col, CC_gas, CCCCS_gas/
    CCS(i)        Carbon capture and storage
      /CCS_col,  CCCCS_gas/      ;

set elefuelmap(i,j)    Electricity generation fuel and technology mapping
    /  col.( Conv_Col,    CCS_col)
       gas.( Conv_gas,    CC_gas,  CCCCS_gas)
       oil.( Conv_Oil)
*      nuc. nuc
*      bio. bio
    /

   elesplitmap(i,j)   Electricity generation split mapping from GTAP data
   /  conv. (conv_col, conv_gas, conv_oil)
      wnd.  (wnd, sol)
      hyd.  (hyd, geo)
*     nuc.   nuc
*     bio.   bio
   /

  eleemismap(i,j)    Electricity generation emission mapping
    /  Conv_Col.    CCS_col
       Conv_gas.   (CC_gas,  CCCCS_gas)
    /
parameter eleemisf(j,i)  electricity generation emissions adjustment for CCS;
   eleemisf(e,i)$(elefuelmap(e,i) and not CCS(i))=1;
   eleemisf(e,i)$(elefuelmap(e,i) and CCS(i))=0.1;

set  use           Energy use
     /  fuel           "Energy for fuel"
        feed           "Feedstocks"
        heat           "Residential heating"
        othr           "Other residential energy" /

     fdst(use)     Energy use as feedstock         / feed/
     fuel(use)     Energy use as fuel              / fuel/
     hous(use)     Energy use in housing or other  / heat,othr/;

set  k             Capital types
      / va              "Value-added"
        res             "Residential houses"
        ldv             "Light-duty personal vehicles"   /;

set
     va(k)         "Value-added capital"                  / va  /
     ldv(k)        "Residential house capital"            / ldv /
     res(k)        "Light-duty personal vehicle capital"  / res / ;

* household variables
set
     housei(i)       / house /
     hh(i)           / HH    /;

set  v(i)          Capital vintages                / extant,new /
     extant(i)     Existing (fixed) production     / extant /
     new(i)        New (flexible) production       / new /
     vnum(v)       New (flexible) production       / new / ;

set  trd           Foreign trade type      / ftrd /;

set  ghg           Greenhouse gas types   / co2,ch4,n2o,hfc,pfc,sf6 /
     co2(ghg)      Carbon dioxide         / co2 /
     ch4(ghg)      Methane                / ch4 /
     n2o(ghg)      Nitrous oxide          / n2o /
     hfc(ghg)      Hydrofluorocarbons     / hfc /
     pfc(ghg)      Perfluorocarbons       / pfc /

     sf6(ghg)      Sulphur hexafluoride   / sf6 /

     cvar          Carbon type in land use change /vegc, soilc /

     ap            Air pollutants
       /BC             Black carbon
        CO             Carbon monoxide
        NH3            Ammonia
        NMVOC          Non-methane volatile organic compounds
        NOX            Nitrogen oxides
        OC             Organic carbon
        PM10           Particulate matter 10 micrometers or less in diameter
        PM25           Particulate matter 2.5 micrometers or less in diameter
        SO2            Sulfur dioxide
       / ;


alias   (s,g),    (g,gg),     (r,rr),     (r,rrr);
alias   (e,ee),   (e,f),      (cgo,cgoe), (hh,hhh),   (k,kk),     (v,vv);
alias   (lu,lu_), (agr,agrs), (crp,crp0), (ad,ad0),   (bio,bio0), (agri,agrii);
alias   (i,ii),   (j, jj),    (afv,afv1);
