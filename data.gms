$title  ADAGE Model - Input Data

$eolcom !

$ONEMPTY

**CCCCCCCCCCCCCCCCCCC     Environmental variable for model versions CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
* DA: Model with eight transportation sectors and 5 types of technologies in on-road transportation
* DN: Model with eight transportation sectors and only 1 type of conventional technology in on-road transportation
* AN: Model with two transportation sectors (auto and otrn) and only 1 type of conventional technology in on-road transportation
* Only one of the following three can be activated at a time

$ifthen setglobal AN $setglobal aggtrn
$endif
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC


*CCCCCCCCCCCCCCCCCCC Set up policy analysis CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*$setglobal shock              ! Biofuel volume requirement analysis
$setglobal pcru               ! Crude oil price analysis used for Energy Economics (2023) paper
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

* include set definition file
$include set.gms

*CCCCCCCCCCCCCCCCCCC Set up flags for special control  CCCCCCCCCCCCCCCCCCCCCCCCC
parameter   f_ghg(r,ghg)      Flag to price ghg emissions other than CO2 emissions from fossil fuel combustion or not (CO2 emissions from industrial processes are included here)
            f_co2(r)          Flag to price co2 emissions from fossil fuel combustion or not
            f_co2luc(r)       Flag to price co2 emissions from land use change or not
            f_co2eq(r)        Flag to price both f_ghg and f_co2 and f_co2luc emission or not

            ctax(r)           Flag to specify which regions have ghg tax applied to them
            ctaxt(r,t)        GHG tax growth path over time
            ghgcarb           Convert GHG emissions to co2eq to equilibrate prices in carbon tax scenarios

            f_co2eq_target    Flag to activate co2eq emission reduction target or not

            f_hdvbio(r,i)     Flag to expand biofuel usage in HDV transportation for conventional and afv
            f_afvbio(r,i)     Flag to expand biofuel usage in LDV and HDV for AFV

            f_trn(r,i,v)      Flag to use fixed factor endowment for conventional OEV

            f_case            Flag to initiate which difcarb to use

            f_cru(r)          Flag to set up an exogenous crude oil price
            pcrutrd(r)        Exogenous crude oil price path if f_cru is activated

            f_advgen(r,i,v)   Flag to activate advanced electricity generation technology

            f_ele(r)          Flag to activate the electricity generation emission cap
            co2elecap(r)      CO2 emission cap on electricity generation (mmt co2e)

            f_afv(r,i,v)      Flag to activate afv technology for on-road transportation
 ;

    f_ghg(r,ghg)   = 0;
    f_co2(r)       = 0;
    f_co2luc(r)    = 0;
    f_co2eq(r)     = 0;

    ctax(r)        = 0;
    ctaxt(r,t)     = 0;
    ghgcarb(r)     = no;

    f_co2eq_target = 0;

* The following settings are for sensitivity analysis. The default is f_case=2
*   f_case=1: original difcarb to use
*   f_case=2: emission factor is reduced by 30% for non-cropland in order to calculate difcarb
*   f_case=3; emission factor is reduced by 30% for non-cropland type and some regions are further adjusted to calculate difcarb
*   f_case=4: regional emisisons are further adjusted to ensure simulated emission in 2015 close to the luc emission in 2010 in ghg_lulc0 from World resource institue

    f_case         = 2;

    f_cru(r)       = 0;
    pcrutrd(r)     = 1;

    f_advgen(r,i,v)= 0;
    f_ele(r)       = 0;
    co2elecap(r)   = 0;

    f_afv(r,i,v)   = 0;
    f_hdvbio(r,i)  = 0;
    f_afvbio(r,i)  = 0;
    f_trn(r,i,v)   = 0;


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*              Keep the following and don't delete
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
$ontext
* In the loop file, we can choose the follow options to activate them to allow biofuel expansion to all technologies in LDV and HDV
    f_afv(r,afv,"new")   = 1;
    f_hdvbio(r,hdv)      = 1;
* All technologies
*    f_afvbio("USA",afv)$(f_afv("USA",afv,"new") and BioAFV(afv) )   = 1;
* Auto_gas and auto_hev only
*   f_afvbio("USA",afv)$(f_afv("USA",afv,"new") and BioAFV(afv) and bioautoafv(afv))   = 1;
* HDV only
    f_afvbio("USA",afv)$(f_afv("USA",afv,"new") and BioAFV(afv) and not bioautoafv(afv))   = 1;
    f_afvbio(r,afv)$(sum(maptrn(i,afv),f_hdvbio(r,i))=0 and hdvafv(afv)) = 0;
display  f_afvbio;
$offtext


**CCCCCCCCCCCCCCCCCCC    Set up sectoral mapping if aggregated version is used CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
scalar f_aggtrn          Flag to activate aggregated transportation sector
set    aggtrn(i)         Aggregated transportation sector
       deltrn(i)         Transportation sectors that need to be removed in the aggregated version
       map_aggtrn(j,i)   Mapping between transportation aggregation
       mapsector(j,i)    Mapping individual sector to aggregated transportation sector
       mapGSector(j,i)   Mapping individual sector to aggregated transportation sector  ;

$ifthen setglobal aggtrn
    f_aggtrn = 1;
    aggtrn(i)$(Auto(i) or otrn(i))=yes;
    deltrn(i)$(trni(i) and not aggtrn(i)) =yes;
    Map_aggtrn(i,i)$Auto(i)=yes;
    Map_aggtrn(j,i)$(otrn(j) and trni(i) and not auto(i))=yes;
$else
    f_aggtrn = 0;
    aggtrn(i)$trni(i)=yes;
    deltrn(i)$(trni(i) and not aggtrn(i)) =yes;
    Map_aggtrn(i,i)$trni(i)=yes;
$endif

    mapsector(i,i)$(not trni(i))=yes;
    mapSector(j,i)$(aggtrn(j)) = Map_aggtrn(j,i);
    mapGsector(j,i)= mapsector(j,i);

display aggtrn,deltrn,map_aggtrn,mapsector,maptrn;

*if(f_aggtrn=0, f_hdvbio("USA",s)$hdv(s)   = 1; );
*if(f_aggtrn=1, f_hdvbio("USA",s)$(otrn(s))= 1; );


*CCCCCCCCCCCCCCCCCCCCCCCC Main base-year data in 2010 with disaggregated transportation sectors   CCCCCCCCCCCCCCCCCCCC
parameter
        y0_10(r,i,v,t)             Aggregate sectoral output ($2010 billion)
        ed0_10(r,j,use,i,v,t)      Energy Demand by sector ($2010 billion)
        id0_10(r,j,i,v,t)          Intermediate demand ($2010 billion)
        ld0_10(r,i,v,t)            Labor demand ($2010 billion)
        kd0_10(r,k,i,v,t)          Capital demand ($2010 billion)
        hkd0_10(r,i,v,t)           Human capital demand ($2010 billion)
        lnd0_10(r,i,v,t)           Land inputs to agriculture ($2010 billion)
        rd0_10(r,i,v,t)            Natural resource inputs to energy ($2010 billion)
        rnw0_10(r,i,v,t)           Resource input for electricity generation ($2010 billion)

        cd0_10(r,hh,i,t)           Consumption demand for goods ($2010 billion)
        fuel0_10(r,v,t)            Fuel use in personal vehicles (combined with oil & gas and biofuel or other fuels) ($2010 billion)
        house0_10(r,i,v,t)         Housing services ($2010 billion)
        le0_10(r,hh,t)             Labor endowment of households ($2010 billion)
        ke0_10(r,hh,t)             Capital endowment of households ($2010 billion)

        i0_10(r,k,i,t)             Investment demand for goods ($2010 billion)
        inv0_10(r,k,t)             Total investment ($2010 billion)
        g0_10(r,i,t)               Government demand for goods ($2010 billion)
        gov0_10(r,t)               Total government ($2010 billion)
        tax0_10(r,t)               Total tax revenues ($2010 billion)
        lstax_10(r,hh,t)           Lump-sum transfers ($2010 billion)
        land0_10(r,t)              Total land endowment ($2010 billion)

        x0_10(r,i,trd,t)           Exports ($2010 billion)
        m0_10(r,i,trd,t)           Imports ($2010 billion)
        n0_10(r,rr,i,t)            Interregional trade ($2010 billion)
        tpt0_10(r,i,t)             Transport services for trade goods ($2010 billion)
        trs0_10(r,rr,i,t)          Transport services by export goods ($2010 billion)

        ty_10(r,i)                 Output tax rate (%)
        te_10(r,j,use,i,t)         Energy tax rate (%)
        ti_10(r,j,i)               Intermediate inputs tax (%)
        tl_10(r,i)                 Labor tax rate (%)
        tk_10(r,k,i)               Capital tax rate (%)
        thk_10(r,i)                Human capital tax rate (%)
        tn_10(r,i)                 Land tax rate (%)
        tr_10(r,i)                 Resource tax rate (%)
        tc_10(r,i)                 Consumption tax (%)
        tinv_10(r,k,i)             Investment tax (%)
        tg_10(r,i)                 Government purchases tax (%)
        tx_10(r,rr,i)              Export tax (%)
        tm_10(r,rr,i)              Import tax (%)

        a0_10(r,i,t)               Armington goods ($2010 billion)
        d0_10(r,i,t)               Domestic goods ($2010 billion)
        c0_10(r,hh,t)              Total consumption of goods ($2010 billion)

        pld0_10(r,i)               Reference labor price (=1+tax rate)
        pkd0_10(r,k,i)             Reference capital price (=1+tax rate)
        phkd0_10(r,i)              Reference human capital price (=1+tax rate)
        pid0_10(r,j,i)             Reference intermediate inputs price (=1+tax rate)
        plnd0_10(r,i)              Reference land price (=1+tax rate)
        prd0_10(r,i)               Reference resource price (=1+tax rate)
        pcd0_10(r,i)               Reference consumption goods price (=1+tax rate)
        pmt0_10(r,rr,i)            Reference imports price (=1+tax rate)
        pmx0_10(r,rr,i)            Reference exports price (=1+tax rate)

        ertl0_10(r,j,use,i,t)      Energy Retail Demand by sector ($2010 billion)
        ewhl0_10(r,j,use,i,t)      Energy Wholesale Demand by sector ($2010 billion)
        emrg0_10(r,j,use,i,t)      Energy Margins ($2010 billion)
        etax0_10(r,j,use,i,t)      Energy Taxes ($2010 billion)

        btu0_10(r,j,use,i,t)       Energy consumption by sector (quad Btu)
        prod0_10(r,i,t)            Energy production (quad Btu)
        elegen0_10(r,i)            Electricity generation by type (quad Btu)
        em0_btu_10(r,i,t)          Energy imports (quad Btu)
        ex0_btu_10(r,i,t)          Energy exports (quad Btu)
        en0_btu_10(r,rr,i,t)       Energy bilateral trade (quad btu)

        prc0_10(r,j,use,i)         Delivered retail energy prices ($2010 per MMBtu)
        whlprc0_10(r,i)            Wholesale energy prices ($2010 per MMBtu)

        hectares0_10(r,i)          Land used in agricultural crops (hectares)
        tons_10(r,i)               Agricultural crop production (metric tons)
;

* Baseyear data from various sources: GTAP, IEO, EIA, FAO, GCAM
* Data includes renewable electricity generation and disaggregated transportation sector
$gdxin '.\data\data1_main.gdx'
$load y0_10=y0       id0_10=id0   ld0_10=ld0    hkd0_10=hkd0  kd0_10=kd0   rd0_10=rd0      rnw0_10=rnw0    lnd0_10=lnd0    cd0_10=cd0
$load fuel0_10=fuel0 i0_10=i0     g0_10=g0      x0_10=x0      m0_10=m0     n0_10=n0        tpt0_10=tpt0    trs0_10=trs0
$load ty_10=ty       ti_10=ti     tl_10=tl      tk_10=tk      thk_10=thk   tn_10=tn        tr_10=tr        tc_10=tc        tinv_10=tinv   tg_10=tg  tx_10=tx   tm_10=tm  te_10=te
$load ed0_10=ed0     emrg0_10=emrg0             etax0_10=etax0             ewhl0_10=ewhl0  ertl0_10=ertl0  btu0_10=btu0    prod0_10=prod0
$load prc0_10=prc0   whlprc0_10=whlprc0         elegen0_10=elegen          hectares0_10=hectares           tons_10=tons
$load house0_10=house0            tax0_10=tax0  gov0_10=gov0               lstax_10=lstax  a0_10=a0        d0_10=d0        c0_10=c0       inv0_10=inv0
$load land0_10=land0 le0_10=le0   ke0_10=ke0
$load pld0_10=pld0   pkd0_10=pkd0 phkd0_10=phkd0 pid0_10=pid0 plnd0_10=plnd0 prd0_10=prd0 pcd0_10=pcd0  pmt0_10=pmt0 pmx0_10=pmx0
$load em0_btu_10=em0_btu  ex0_btu_10=ex0_btu en0_btu_10=en0_btu

* Rename the capital type in auto from va to ldv so it is consistent with model structure
    kd0_10(r,"ldv","auto",v,t)= kd0_10(r,"va","auto",v,t) ;
    kd0_10(r,"va","auto",v,t) = 0;
* Household energy consumption is accounted in ed0(r,e,use,hh) so remove it from the final consumption
    cd0_10(r,hh,i,t)$e(i)     = 0;


parameter  oev_valu0_10(r,i,v,t)   Oil and biofuel fuel use in on-road transportation in 2010 ($2010 billion)
           oev_btu0_10(r,e,i,t)    Oil and biofuel fuel use in on-road transportation in 2010 (quad)  ;

    oev_valu0_10(r,i,v,t)$trnv(i)= sum(e$ob(e),ed0_10(r,e,"fuel",i,v,"2010"));
    oev_btu0_10(r,e,i,t)$(trnv(i) and ob(e)) = btu0_10(r,e,"fuel",i,"2010");



**CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                            Electricity Sector Disaggregation and Updates
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
* Goal: 1) Split fossil fuel electricity generation into coal, gas and oil
*          Split solar from wind
*          split geothermol from hydro power
*       2) Introduce advanced technologies such as CC_gas, CCCCS_gas
*       3) Update the generation cost using ATB2020 data: https://atb.nrel.gov/electricity/2020/about.php
*

set  elei      Input used in elctricity generation for all regions in ADAGE
     / Col,  Gas,  Oil,   Eim,   Man,    Srv,    Ld0,    Kd0,    Id0,   ed0, rnw0, Y0, LCOE/;

* Introduce IEO2017 data to split renewables
parameter  IEO2017_gentech     Electricity generation from IEO2017 (solar wind hyr geo are included) (quad)
* The file is generated from D:\Model\ADAGE\CGE_Data_2011_tran\International\Energy_Data\EIA_2018\read_IEO2017.gms
*             copied from D:\Model\ADAGE\CGE_Data_2011_tran\International\Energy_Data\EIA_2018\output\IEO2017_gen.gdx
*             renamed to data11_en_eia_gen.gdx in ADAGE model
$gdxin data\data11_en_eia_gen.gdx
$load  IEO2017_gentech=gen
;
    IEO2017_gentech(r,"sol",t) = IEO2017_gentech(r,"slr",t);
    IEO2017_gentech(r,"slr",t) = 0;

* Fill in missing value with a tiny value
    IEO2017_gentech("bra","sol",t)$(t.val<2020) =  IEO2017_gentech("bra","sol","2020");
    IEO2017_gentech("chn","geo",t)$(t.val=2015) =  IEO2017_gentech("chn","geo","2010");
    IEO2017_gentech("xlm","sol",t)$(t.val<2025) =  IEO2017_gentech("xlm","sol","2025");

Table EIA_heateff(*,*)    Heat efficiency in electricity generation (%)
*https://www.eia.gov/electricity/annual/html/epa_08_01.html
*Table 8.1. Average Operating Heat Rate for Selected Energy Sources, 2006 through 2016 (Btu per kilowatt hour)
*Btu per kilowatt hour is then converted to Btu generated/btu used, so it becomes percentage to measure energy use efficiency
*Heat rate is the average by energy source from the existing technologies, so gas would be the average from conv_gas
*  and cc_gas as CC_gas already accounts for large share of gas generation

            Col              oil            Gas           Nuc
2006        0.32963        0.31566        0.40279        0.32698
2007        0.32887        0.31610        0.40605        0.32529
2008        0.32877        0.30976        0.41084        0.32644
2009        0.32764        0.31237        0.41814        0.32623
2010        0.32760        0.31063        0.41686        0.32644
2011        0.32669        0.31508        0.41855        0.32607
2012        0.32501        0.31044        0.42443        0.32560
2013        0.32623        0.31849        0.42929        0.32654
2014        0.32720        0.31552        0.43152        0.32623
2015        0.32511        0.31927        0.43310        0.32626
2016        0.32517        0.31560        0.43355        0.32623
;


* Update exisiting electricity technology and introduce new electricity generation technology
parameters ATB20_elecost(r,i,t,*)     Production cost for electricity generation ($2010 per mmbtu)
           ATB20_heateff(i)           Electricity energy conversion efficiency by ADAGE sectors (%)
           ATB20_WndSolCost           Wind and solar cost and potential generations by detailed technology ($ per mmbtu and quad for gen);

set        ATB20_mapall               Mapping between ATB technology and ADAGE electricity generation technology ;

* Source: ATB2020 data from https://atb.nrel.gov/electricity/2020/about.php
* Process: D:\Model\ADAGE\CGE_Data_2011_tran\International\Eletech_data
* Output: D:\Model\ADAGE\CGE_Data_2011_tran\International\Eletech_data\output\Data_ATB2020.gdx
$gdxin data\data11_ATB2020.gdx
$load  ATB20_elecost    ATB20_heateff=heateff ATB20_WndSolCost=ATB20_WndSolCost  ATB20_mapall=mapall

    ATB20_heateff("conv_oil") = EIA_heateff("2010","oil") ;
* As natural gas related generation has upward trend in energy cost after 2020, so change it to be flat at 2020 value
    ATB20_elecost(r,"conv_gas" ,t,"ed0")$(t.val>2020) = ATB20_elecost(r,"conv_gas" ,"2020","ed0") ;
    ATB20_elecost(r,"cc_gas"   ,t,"ed0")$(t.val>2020) = ATB20_elecost(r,"cc_gas" ,"2020","ed0") ;
    ATB20_elecost(r,"ccccs_gas",t,"ed0")$(t.val>2020) = ATB20_elecost(r,"ccccs_gas","2020","ed0") ;
    ATB20_elecost(r,i ,t,"LCOE") =sum(elei$(not sameas(elei,"LCOE")), ATB20_elecost(r,i ,t,elei));

*CCCCCC Goal 1: Split CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
parameter  chk0_elegen_btu    Check electricity generation from fossil fuels in 2010 (quad)
           heateff(r,i)       Final heat rate (%)

           eleshr2split_btu   Electricity share to split in in terms to btu
           eleshr2split_val   Electricity share to split in in terms to $

           chk0_eleprod       Check electricity generation input share in 2010 ($ per mmbtu)
           chk0_elecost       Check Electricity generation cost by source in 2010 ($ per mmbtu)
;

* Rename conventional electricity to new name
    elegen0_10(r,"conv") = sum(elefuelmap(e,convi), elegen0_10(r,e));
    elegen0_10(r,convi)  = sum(elefuelmap(e,convi), elegen0_10(r,e));
    elegen0_10(r,cgo)    = 0;

    btu0_10(r,cgo,use,"conv",t)= btu0_10(r,cgo,use,"ele",t);
    btu0_10(r,e,use,convi,t)   = sum(elefuelmap(e,convi), btu0_10(r,e,use,"ele",t));
    btu0_10(r,cgo,use,"ele",t) = 0;

* Compare electricity generation by different heat efficiency assumption
    chk0_elegen_btu(r,"conv")        = elegen0_10(r,"conv");
    chk0_elegen_btu(r,"conv1")       = sum(convi, elegen0_10(r,convi));
    chk0_elegen_btu(r,"conv2")       = sum(elefuelmap(e,convi), btu0_10(r,e,"fuel",convi,"2010")*ATB20_heateff(convi));
    chk0_elegen_btu(r,"conv3")       = sum(elefuelmap(e,convi), btu0_10(r,e,"fuel",convi,"2010")*EIA_heateff("2010",e));
    chk0_elegen_btu(r,"Total")       =  elegen0_10(r,"conv")+ sum(rnw,elegen0_10(r,rnw))
                                      - prod0_10(r,"ele","2010");

* We use heat rate from GTAP for conventional fossil fuel technology, and ATB2020 for other tecthnologies.
    heateff(r,convi)             = sum(elefuelmap(e,convi),elegen0_10(r,convi)/btu0_10(r,e,"fuel",convi,"2010"));
    heateff(r,i)$(not convi(i))  = ATB20_heateff(i);

    chk0_elegen_btu(r,"conv4")       = sum(elefuelmap(e,convi), btu0_10(r,e,"fuel",convi,"2010")*heateff(r,convi));

display elegen0_10,prod0_10,chk0_elegen_btu;

* Split coal, gas and oil generation from GTAP data, defining in terms of btu
* Split geo from hyd, sol from wnd  - split from i to j using IEO2018 data
    eleshr2split_btu(r,convi,"conv")= elegen0_10(r,convi)/elegen0_10(r,"conv");
    eleshr2split_btu(r,"sol","wnd") = IEO2017_gentech(r,"sol","2010")/sum(wndsol,IEO2017_gentech(r,wndsol,"2010"));
    eleshr2split_btu(r,"wnd","wnd") = IEO2017_gentech(r,"wnd","2010")/sum(wndsol,IEO2017_gentech(r,wndsol,"2010"));
    eleshr2split_btu(r,"geo","hyd") = IEO2017_gentech(r,"geo","2010")/sum(hydgeo,IEO2017_gentech(r,hydgeo,"2010"));
    eleshr2split_btu(r,"hyd","hyd") = IEO2017_gentech(r,"hyd","2010")/sum(hydgeo,IEO2017_gentech(r,hydgeo,"2010"));

    elegen0_10(r,rnw)$sum(elesplitmap(j,rnw),1) = sum(elesplitmap(j,rnw),eleshr2split_btu(r,rnw,j)*elegen0_10(r,j));

* Split coal, gas and oil generation from GTAP data in terms of $
* Split geo from hyd, sol from wnd - same as split based on btu

    ed0_10(r,e,"fuel",convi,"new",t)  = sum(elefuelmap(e,convi),ed0_10(r,e,"fuel","conv","new",t));

    eleshr2split_val(r,convi,"conv")  = sum(elefuelmap(e,convi),ed0_10(r,e,"fuel",convi,"new","2010"))
                                       /sum(elefuelmap(ee,j),ed0_10(r,ee,"fuel",j,"new","2010"));

    eleshr2split_val(r,rnw,j)$eleshr2split_btu(r,rnw,j) = eleshr2split_btu(r,rnw,j);

    y0_10(r,ii,v,t)$sum(elesplitmap(i,ii),1)    = sum(elesplitmap(i,ii), y0_10(r,i,v,t)    * eleshr2split_val(r,ii,i));
    kd0_10(r,k,ii,v,t)$sum(elesplitmap(i,ii),1) = sum(elesplitmap(i,ii), kd0_10(r,k,i,v,t) * eleshr2split_val(r,ii,i));
    hkd0_10(r,ii,v,t)$sum(elesplitmap(i,ii),1)  = sum(elesplitmap(i,ii), hkd0_10(r,i,v,t)  * eleshr2split_val(r,ii,i));
    id0_10(r,g,ii,v,t)$sum(elesplitmap(i,ii),1) = sum(elesplitmap(i,ii), id0_10(r,g,i,v,t) * eleshr2split_val(r,ii,i));
    ld0_10(r,ii,v,t)$sum(elesplitmap(i,ii),1)   = sum(elesplitmap(i,ii), ld0_10(r,i,v,t)   * eleshr2split_val(r,ii,i));
    rnw0_10(r,ii,v,t)$sum(elesplitmap(i,ii),1)  = sum(elesplitmap(i,ii), rnw0_10(r,i,v,t)  * eleshr2split_val(r,ii,i));

* Assign same tax rate across each of the split sectors
    ty_10(r,ii)$sum(elesplitmap(i,ii),1)        = sum(elesplitmap(i,ii), ty_10(r,i));
    te_10(r,e,use,ii,t)$sum(elesplitmap(i,ii),1)= sum((elesplitmap(i,ii),elefuelmap(e,ii)), te_10(r,e,use,i,t));
    ti_10(r,j,ii)$sum(elesplitmap(i,ii),1)      = sum(elesplitmap(i,ii), ti_10(r,j,i));
    tl_10(r,ii)$sum(elesplitmap(i,ii),1)        = sum(elesplitmap(i,ii), tl_10(r,i));
    tk_10(r,k,ii)$sum(elesplitmap(i,ii),1)      = sum(elesplitmap(i,ii), tk_10(r,k,i));
    thk_10(r,ii)$sum(elesplitmap(i,ii),1)       = sum(elesplitmap(i,ii), thk_10(r,i));

    pid0_10(r,j,ii)$sum(elesplitmap(i,ii),1)    = 1 + ti_10(r,j,ii) ;
    pld0_10(r,ii)$sum(elesplitmap(i,ii),1)      = 1 + tl_10(r,ii)   ;
    pkd0_10(r,k,ii)$sum(elesplitmap(i,ii),1)    = 1 + tk_10(r,k,ii) ;
    phkd0_10(r,ii)$sum(elesplitmap(i,ii),1)     = 1 + thk_10(r,ii)  ;

parameter eleshr2splitgas_btu(i)   CC_gas in total gas generation in USA in terms to quad btu in 2010
* Assign 81.4% of natural gas generation to ADAGE backstop generation CC_gas based on EIA data
*  https://www.eia.gov/electricity/monthly/epm_table_grapher.php?t=table_1_07_c
   /CC_gas    0.814
    Conv_gas  0.186 /;

    elegen0_10(r,ii)$eleshr2splitgas_btu(ii)    = eleshr2splitgas_btu(ii)*elegen0_10(r,"Conv_gas");

    IEO2017_gentech(r,"conv_col",t)= IEO2017_gentech(r,"col",t);
    IEO2017_gentech(r,"conv_oil",t)= IEO2017_gentech(r,"oil",t);
    IEO2017_gentech(r,i,t)$eleshr2splitgas_btu(i) = IEO2017_gentech(r,"gas",t)*eleshr2splitgas_btu(i);

    IEO2017_gentech(r,"col",t) = 0;
    IEO2017_gentech(r,"oil",t) = 0;
    IEO2017_gentech(r,"gas",t) = 0;

parameter eleshr2splitgas_val(r,i)   CC_gas in total gas generation in USA in terms of $ in 2010;

    eleshr2splitgas_val(r,i)$eleshr2splitgas_btu(i)
           = eleshr2splitgas_btu(i)*ATB20_elecost(r,i,"2010","LCOE")
            /sum(ii$eleshr2splitgas_btu(ii),eleshr2splitgas_btu(ii)*ATB20_elecost(r,ii,"2010","LCOE"));

    ed0_10(r,e,"fuel",ii,v,t)$eleshr2splitgas_val(r,ii)= ed0_10(r,e,"fuel","conv_gas",v,t)*eleshr2splitgas_val(r,ii)   ;
    btu0_10(r,e,"fuel",ii,t)$eleshr2splitgas_val(r,ii) = btu0_10(r,e,"fuel","conv_gas",t)*eleshr2splitgas_val(r,ii)    ;
    prod0_10(r,i,"2010")$elegen0_10(r,i)  =  elegen0_10(r,i) ;

    heateff(r,gentype)$sum(elefuelmap(e,gentype),btu0_10(r,e,"fuel",gentype,"2010"))
                     = elegen0_10(r,gentype)/sum(elefuelmap(e,gentype),btu0_10(r,e,"fuel",gentype,"2010"));

    y0_10(r,ii,v,t)$eleshr2splitgas_val(r,ii)          = y0_10(r,"conv_gas",v,t)    *eleshr2splitgas_val(r,ii) ;
    kd0_10(r,k,ii,v,t)$eleshr2splitgas_val(r,ii)       = kd0_10(r,k,"conv_gas",v,t) *eleshr2splitgas_val(r,ii) ;
    hkd0_10(r,ii,v,t)$eleshr2splitgas_val(r,ii)        = hkd0_10(r,"conv_gas",v,t)  *eleshr2splitgas_val(r,ii) ;
    id0_10(r,g,ii,v,t)$eleshr2splitgas_val(r,ii)       = id0_10(r,g,"conv_gas",v,t) *eleshr2splitgas_val(r,ii) ;
    ld0_10(r,ii,v,t)$eleshr2splitgas_val(r,ii)         = ld0_10(r,"conv_gas",v,t)   *eleshr2splitgas_val(r,ii) ;
    rnw0_10(r,ii,v,t)$eleshr2splitgas_val(r,ii)        = rnw0_10(r,"conv_gas",v,t)  *eleshr2splitgas_val(r,ii) ;

* Assign same tax rate to backstop sector as corresponding conventional sector
    ty_10(r,ii)$sum(eleemismap(i,ii),1)        = sum(eleemismap(i,ii), ty_10(r,i));
    te_10(r,e,use,ii,t)$sum(eleemismap(i,ii),1)= sum((eleemismap(i,ii),elefuelmap(e,ii)), te_10(r,e,use,i,t));
    ti_10(r,j,ii)$sum(eleemismap(i,ii),1)      = sum(eleemismap(i,ii), ti_10(r,j,i));
    tl_10(r,ii)$sum(eleemismap(i,ii),1)        = sum(eleemismap(i,ii), tl_10(r,i));
    tk_10(r,k,ii)$sum(eleemismap(i,ii),1)      = sum(eleemismap(i,ii), tk_10(r,k,i));
    thk_10(r,ii)$sum(eleemismap(i,ii),1)       = sum(eleemismap(i,ii), thk_10(r,i));

    pid0_10(r,j,ii)$sum(eleemismap(i,ii),1)    = 1 + ti_10(r,j,ii) ;
    pld0_10(r,ii)$sum(eleemismap(i,ii),1)      = 1 + tl_10(r,ii)   ;
    pkd0_10(r,k,ii)$sum(eleemismap(i,ii),1)    = 1 + tk_10(r,k,ii) ;
    phkd0_10(r,ii)$sum(eleemismap(i,ii),1)     = 1 + thk_10(r,ii)  ;

* Check if electricity generation is in balance
    chk0_eleprod(r,gentype,"y0")$(elegen0_10(r,gentype))  = y0_10(r,gentype,"new","2010")*(1-ty_10(r,gentype))/elegen0_10(r,gentype);
    chk0_eleprod(r,gentype,g)$(elegen0_10(r,gentype))     = id0_10(r,g,gentype,"new","2010")*(1+ti_10(r,g,gentype))/elegen0_10(r,gentype);

    chk0_eleprod(r,gentype,"id0")$(elegen0_10(r,gentype)) = sum(g,id0_10(r,g,gentype,"new","2010")*(1+ti_10(r,g,gentype)))/elegen0_10(r,gentype);
    chk0_eleprod(r,gentype,"kd0")$(elegen0_10(r,gentype)) = kd0_10(r,"va",gentype,"new","2010")*(1+tk_10(r,"va",gentype))/elegen0_10(r,gentype);
    chk0_eleprod(r,gentype,"ld0")$(elegen0_10(r,gentype)) = ld0_10(r,gentype,"new","2010")*(1+tl_10(r,gentype))/elegen0_10(r,gentype);
    chk0_eleprod(r,gentype,e)$(elegen0_10(r,gentype))     = ed0_10(r,e,"fuel",gentype,"new","2010")/elegen0_10(r,gentype);
    chk0_eleprod(r,gentype,"rnw0")$(elegen0_10(r,gentype))= rnw0_10(r,gentype,"new","2010")/elegen0_10(r,gentype);

    chk0_eleprod(r,gentype,"bal")= round((  chk0_eleprod(r,gentype,"y0")
                                          - chk0_eleprod(r,gentype,"id0")
                                          - chk0_eleprod(r,gentype,"kd0")
                                          - chk0_eleprod(r,gentype,"ld0")
                                          - sum(e,chk0_eleprod(r,gentype,e))
                                          - chk0_eleprod(r,gentype,"rnw0") ),7);

* Assign resource allocation
    rnw0_10(r,gentype,"new",t)     = 0.01* y0_10(r,gentype,"new","2010");
    kd0_10(r,"va",gentype,"new",t) =  (        y0_10(r,gentype,"new","2010")*(1-ty_10(r,gentype))
                                             - sum(g,id0_10(r,g,gentype,"new","2010")*(1+ti_10(r,g,gentype)))
                                             - ld0_10(r,gentype,"new","2010")*(1+tl_10(r,gentype))
                                             - sum(e,ed0_10(r,e,"fuel",gentype,"new","2010"))
                                             - rnw0_10(r,gentype,"new","2010"))
                                           /(1+tk_10(r,"va",gentype));

* Split energy market
    ertl0_10(r,j,use,ii,t)$sum(elesplitmap(i,ii),1) = sum((elesplitmap(i,ii),elefuelmap(j,ii)),ertl0_10(r,j,use,i,t));
    ewhl0_10(r,j,use,ii,t)$sum(elesplitmap(i,ii),1) = sum((elesplitmap(i,ii),elefuelmap(j,ii)),ewhl0_10(r,j,use,i,t));
    emrg0_10(r,j,use,ii,t)$sum(elesplitmap(i,ii),1) = sum((elesplitmap(i,ii),elefuelmap(j,ii)),emrg0_10(r,j,use,i,t));
    etax0_10(r,j,use,ii,t)$sum(elesplitmap(i,ii),1) = sum((elesplitmap(i,ii),elefuelmap(j,ii)),etax0_10(r,j,use,i,t));

    ertl0_10(r,j,use,ii,t)$eleshr2splitgas_val(r,ii) = ertl0_10(r,j,use,"conv_gas",t)*eleshr2splitgas_val(r,ii);
    ewhl0_10(r,j,use,ii,t)$eleshr2splitgas_val(r,ii) = ewhl0_10(r,j,use,"conv_gas",t)*eleshr2splitgas_val(r,ii);
    emrg0_10(r,j,use,ii,t)$eleshr2splitgas_val(r,ii) = emrg0_10(r,j,use,"conv_gas",t)*eleshr2splitgas_val(r,ii);
    etax0_10(r,j,use,ii,t)$eleshr2splitgas_val(r,ii) = etax0_10(r,j,use,"conv_gas",t)*eleshr2splitgas_val(r,ii);

display  chk0_eleprod;

*CCCCCC Goal 1: End of Code Splitting Electricity Generation into Greater Disaggregation CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC


*CCCCCC Goal 2: Update existing technology and introduce new advanced technology CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*  In ATB20_elecost:     conv_oil is not available; bat (Electricity storage such as battery) has capital but no LCOE cost
*  In ATB20_elecost:     wind and solar generation cost is calculated as the potential generation-weighted average cost across all subtechnologies
*  In ATB20_wndsolcost:  wind and solar cost is provided by subtechnology, with no average value provided.
*                                               Optimistic       Representive
*                        wind:  LandbasedWind,  LTRG1             LTRG4
*                        solar: UtilityPV,      Daggett           Kansascity
* Representive technology for wind and solar
    ATB20_elecost(r,"wnd",t,elei) = ATB20_WndSolCost(r,"wnd","LandbasedWind","LTRG4",t,elei);
    ATB20_elecost(r,"sol",t,elei) = ATB20_WndSolCost(r,"sol","UtilityPV","Kansascity",t,elei);
* Optimistic cost for wind and solar. Could be used for sensitivity analysis
*   ATB20_elecost(r,"wnd",t,elei) = ATB20_WndSolCost(r,"wnd","LandbasedWind","LTRG1",t,elei);
*   ATB20_elecost(r,"sol",t,elei) = ATB20_WndSolCost(r,"sol","UtilityPV","Daggett",t,elei);

* Combine ed0 in bioele and nuclear into kd0
    ATB20_elecost(r,i,t,"Kd0")$(bioelec(i) or nuc(i))
       = ATB20_elecost(r,i,t,"ed0")+ATB20_elecost(r,i,t,"Kd0");
    ATB20_elecost(r,i,t,"ed0")$(bioelec(i) or nuc(i)) = 0;

* Fuel cost needs to be replaced with fuel cost in ADAGE using ADAGE fuel price
    ATB20_elecost(r,i,t,"ed0")$(heateff(r,i) and sum(elefuelmap(e,i),ed0_10(r,e,"fuel",i,"new","2010")) and not bioelec(i) and not nuc(i))
       =sum(elefuelmap(e,i),    1 / heateff(r, i)
                              *  ed0_10(r,e,"fuel",i,"new","2010")/btu0_10(r,e,"fuel",i,"2010") );

    ATB20_elecost(r,i,t,e)$(ATB20_heateff(i) and not bioelec(i) and not nuc(i))
       =sum(elefuelmap(e,i),   ATB20_elecost(r,i,t,"ed0"));

    ATB20_elecost(r,i,t,"LCOE")=  ATB20_elecost(r,i,t,"ed0")
                                + ATB20_elecost(r,i,t,"kd0")
                                + ATB20_elecost(r,i,t,"Ld0")
                                + sum(g,ATB20_elecost(r,i,t,g))
                                + ATB20_elecost(r,i,t,"rnw0");

* Assign rnw0 to be 1% of total cost and assign the difference to kd0. 1% share is also used in all backstop tocknology for fixed factor
    ATB20_elecost(r,i,t,"rnw0")= 0.01*ATB20_elecost(r,i,t,"LCOE");
* Temparialy reassign rnw0 to be 0
    ATB20_elecost(r,i,t,"rnw0")= 0;

    ATB20_elecost(r,i,t,"Kd0") =  ATB20_elecost(r,i,t,"LCOE")
                                - ATB20_elecost(r,i,t,"ed0")
                                - ATB20_elecost(r,i,t,"Ld0")
                                - sum(g,ATB20_elecost(r,i,t,g))
                                - ATB20_elecost(r,i,t,"rnw0");

display ATB20_elecost,btu0_10;

* Prepare the production function for fossil fuel and renewable electricity generation
 parameter   elegen_yt0(r,i,v,t)          Electricity production by technology for new capital ($billion)
             elegen_edt0(r,e,use,i,v,t)   Electricity energy consumption by technology for new capital ($billion)
             elegen_idt0(r,i,g,v,t)       Electricity material usage by technology for new capital ($billion)
             elegen_kdt0(r,i,k,v,t)       Electricity capital usage by technology for new capital($billion)
             elegen_ldt0(r,i,v,t)         Electricity labor usage by technology for new capital($billion)
             elegen_rnwdt0(r,i,v,t)       Electricity resource (fixed factor) usage by technology for new capital($billion)

             elegen_yt00(r,i,v,t)         Electricity production by technology for new and extant capital ($billion)
             elegen_edt00(r,e,use,i,v,t)  Electricity energy consumption by technology for new and extant capital ($billion)
             elegen_idt00(r,i,g,v,t)      Electricity material usage by technology for new and extant capital ($billion)
             elegen_kdt00(r,i,k,v,t)      Electricity capital usage by technology for new and extant capital ($billion)
             elegen_ldt00(r,i,v,t)        Electricity labor usage by technology for new and extant capital ($billion)
             elegen_rnwdt00(r,i,v,t)      Electricity resource (fixed factor) usage by technology for new and extant capital ($billion)
 ;

    elegen_yt0(r,i,v,t)$(elegen0_10(r,i) and not conv(i)) = y0_10(r,i,"new",t);

    elegen_idt0(r,i,g,v,t)        = ATB20_elecost(r,i,t,g)     *elegen0_10(r,i)/(1+ti_10(r,g,i));
    elegen_kdt0(r,i,"va",v,t)     = ATB20_elecost(r,i,t,"kd0") *elegen0_10(r,i)/(1+tk_10(r,"va",i));
    elegen_ldt0(r,i,v,t)          = ATB20_elecost(r,i,t,"Ld0") *elegen0_10(r,i)/(1+tl_10(r,i)) ;
    elegen_edt0(r,e,"fuel",i,v,t) = sum(elefuelmap(e,i), ATB20_elecost(r,i,t,"ed0") *elegen0_10(r,i));

* Fill conv_oil with the data in ADAGE
    elegen_yt0(r,i,v,t)$conv_oil(i)            = y0_10(r,i,"new",t)        ;
    elegen_edt0(r,e,"fuel",i,v,t)$conv_oil(i)  = ed0_10(r,e,"fuel",i,"new",t) ;
    elegen_idt0(r,i,g,v,t)$conv_oil(i)         = id0_10(r,g,i,"new",t)     ;
    elegen_ldt0(r,i,v,t)$conv_oil(i)           = ld0_10(r,i,"new",t)       ;
    elegen_kdt0(r,i,"va",v,t)$conv_oil(i)      = kd0_10(r,"va",i,"new",t)  ;

* Ensure the sum of capital and rnw are equal in vintage
    elegen_rnwdt0(r,i,"new",t)    = 0.01* elegen_yt0(r,i,"new",t);
    elegen_kdt0(r,i,"va","new",t)$elegen_kdt0(r,i,"va","extant",t) = elegen_kdt0(r,i,"va","extant",t) - elegen_rnwdt0(r,i,"new",t)/(1+tk_10(r,"va",i)) ;
    elegen_rnwdt0(r,i,"extant",t) = 0;

* Assign the advanced generation technology production input
    y0_10(r,i,v,t)$(advee(i) and not cc_gas(i))          = elegen_yt0(r,i,v,t)           ;
    ed0_10(r,e,"fuel",i,v,t)$(advee(i) and not cc_gas(i))= elegen_edt0(r,e,"fuel",i,v,t) ;
    id0_10(r,g,i,v,t)$(advee(i) and not cc_gas(i))       = elegen_idt0(r,i,g,v,t)        ;
    ld0_10(r,i,v,t)$(advee(i) and not cc_gas(i))         = elegen_ldt0(r,i,v,t)          ;
    kd0_10(r,k,i,v,t)$(advee(i) and not cc_gas(i))       = elegen_kdt0(r,i,k,v,t)        ;
    rnw0_10(r,i,v,t)$(advee(i) and not cc_gas(i))        = elegen_rnwdt0(r,i,v,t)        ;

display  ed0_10,elegen_edt0,advee,elegen_kdt0,elegen_rnwdt0;

* Calculate energy market margins and tax and make sure energy market for advee is available
parameter  chk0_emkt(r,e,use,i,*)              Check energy market ($ billion)
           chk0_prod                           Check production input-output balance ($ billion)
           chk0_eleprod_ATB                    Check ATB input output production data ($ billion) ;

    chk0_emkt(r,e,"fuel",i,"retail")$gentype(i) =  ertl0_10(r,e,"fuel",i,"2010")*(1-te_10(r,e,"fuel",i,"2010") );
    chk0_emkt(r,e,"fuel",i,"marg")$gentype(i)   =  emrg0_10(r,e,"fuel",i,"2010");
    chk0_emkt(r,e,"fuel",i,"whole")$gentype(i)  =  ewhl0_10(r,e,"fuel",i,"2010") ;
    chk0_emkt(r,e,"fuel",i,"diff")$gentype(i)
        =  chk0_emkt(r,e,"fuel",i,"retail")
         - chk0_emkt(r,e,"fuel",i,"marg")
         - chk0_emkt(r,e,"fuel",i,"whole");

    chk0_emkt(r,e,"fuel",i,"%")$chk0_emkt(r,e,"fuel",i,"whole")
        =    chk0_emkt(r,e,"fuel",i,"marg")
           / chk0_emkt(r,e,"fuel",i,"whole");

    chk0_emkt(r,e,"fuel",i,"%_retail")$chk0_emkt(r,e,"fuel",i,"whole")
        =    chk0_emkt(r,e,"fuel",i,"marg")
           / chk0_emkt(r,e,"fuel",i,"retail");

* Check if electricity generation is in balance
    chk0_eleprod_ATB(r,gentype,v,"y0")$(elegen0_10(r,gentype))  = elegen_yt0(r,gentype,v,"2010")*(1-ty_10(r,gentype));
    chk0_eleprod_ATB(r,gentype,v,g)$(elegen0_10(r,gentype))     = elegen_idt0(r,gentype,g,v,"2010")*(1+ti_10(r,g,gentype));

    chk0_eleprod_ATB(r,gentype,v,"id0")$(elegen0_10(r,gentype)) = sum(g,elegen_idt0(r,gentype,g,v,"2010")*(1+ti_10(r,g,gentype)));
    chk0_eleprod_ATB(r,gentype,v,"kd0")$(elegen0_10(r,gentype)) = elegen_kdt0(r,gentype,"va",v,"2010")*(1+tk_10(r,"va",gentype));
    chk0_eleprod_ATB(r,gentype,v,"ld0")$(elegen0_10(r,gentype)) = elegen_ldt0(r,gentype,v,"2010")*(1+tl_10(r,gentype));
    chk0_eleprod_ATB(r,gentype,v,e)$(elegen0_10(r,gentype))     = elegen_edt0(r,e,"fuel",gentype,v,"2010");
    chk0_eleprod_ATB(r,gentype,v,"rnw0")$(elegen0_10(r,gentype))= elegen_rnwdt0(r,gentype,v,"2010");

    chk0_eleprod_ATB(r,gentype,v,"in")=     chk0_eleprod_ATB(r,gentype,v,"id0")
                                          + chk0_eleprod_ATB(r,gentype,v,"kd0")
                                          + chk0_eleprod_ATB(r,gentype,v,"ld0")
                                          + sum(e,chk0_eleprod_ATB(r,gentype,v,e))
                                          + chk0_eleprod_ATB(r,gentype,v,"rnw0") ;

    chk0_eleprod_ATB(r,gentype,v,"bal")= round((  chk0_eleprod_ATB(r,gentype,v,"y0")
                                                - chk0_eleprod_ATB(r,gentype,v,"id0")
                                                - chk0_eleprod_ATB(r,gentype,v,"kd0")
                                                - chk0_eleprod_ATB(r,gentype,v,"ld0")
                                                - sum(e,chk0_eleprod_ATB(r,gentype,v,e))
                                                - chk0_eleprod_ATB(r,gentype,v,"rnw0") ),7);


option chk0_emkt:3:4:1, chk0_eleprod_ATB:3:3:1;
display chk0_emkt,elegen0_10,chk0_eleprod_ATB;

    ertl0_10(r,e,use,i,"2010")$advee(i) =   ed0_10(r,e,use,i,"new","2010");
    ewhl0_10(r,e,use,i,"2010")$advee(i) =   ertl0_10(r,e,use,i,"2010")*(1-te_10(r,e,use,i,"2010"))
                                          * sum(eleemismap(ii,i),(1-chk0_emkt(r,e,use,ii,"%_retail")));
    emrg0_10(r,e,use,i,"2010")$advee(i) =   ertl0_10(r,e,use,i,"2010")*(1-te_10(r,e,use,i,"2010"))
                                          * sum(eleemismap(ii,i),chk0_emkt(r,e,use,ii,"%_retail"));

* advee will not be in balance as its production cost is lower than conv even in 2010
    chk0_prod(r,i,v,'in')$(y0_10(r,i,v,"2010")   and gentype(i) )
        =   sum((e,use),ed0_10(r,e,use,i,v,"2010"))
          + sum(g,id0_10(r,g,i,v,"2010")*(1+ti_10(r,g,i)))
          + ld0_10(r,i,v,"2010")*(1+tl_10(r,i))
          + sum(k,kd0_10(r,k,i,v,"2010")*(1+tk_10(r,k,i)))
          + hkd0_10(r,i,v,"2010")*(1+thk_10(r,i))
          + rnw0_10(r,i,v,"2010")  ;

    chk0_prod(r,i,v,'out')$(y0_10(r,i,v,"2010")   and gentype(i) )
         = y0_10(r,i,v,"2010")*(1-ty_10(r,i));
    chk0_prod(r,i,v,'bal') =round((chk0_prod(r,i,v,'out')-chk0_prod(r,i,v,'in')),5);
display chk0_prod,rnw0_10;

* Compare electricity generation cost from different sources and how it changes over time
set       datasource /GTAP, ATBraw,ATBfin/
          item2      /y0,id0,kd0,ld0,ed0,rnw0,in,bal/;

parameter chk_gencost    Electricity generation cost from different soures ($ per mmbtu);

    chk_gencost(r,gentype,v,t,"GTAP","y0")$elegen0_10(r,gentype)    =  chk0_eleprod(r,gentype,"y0") ;
    chk_gencost(r,gentype,v,t,"GTAP","id0")$elegen0_10(r,gentype)   =  chk0_eleprod(r,gentype,"id0");
    chk_gencost(r,gentype,v,t,"GTAP","kd0")$elegen0_10(r,gentype)   =  chk0_eleprod(r,gentype,"kd0");
    chk_gencost(r,gentype,v,t,"GTAP","ld0")$elegen0_10(r,gentype)   =  chk0_eleprod(r,gentype,"ld0");
    chk_gencost(r,gentype,v,t,"GTAP","ed0")$elegen0_10(r,gentype)   =  sum(e,chk0_eleprod(r,gentype,e));
    chk_gencost(r,gentype,v,t,"GTAP","rnw0")$elegen0_10(r,gentype)  =  chk0_eleprod(r,gentype,"rnw0");

    chk_gencost(r,gentype,v,t,"ATBraw","y0")$(elegen0_10(r,gentype) and not conv(gentype))  =  elegen_yt0(r,gentype,v,t)*(1-ty_10(r,gentype))/elegen0_10(r,gentype);
    chk_gencost(r,gentype,v,t,"ATBraw","id0")$(elegen0_10(r,gentype) and not conv(gentype)) =  sum(g,elegen_idt0(r,gentype,g,v,t)*(1+ti_10(r,g,gentype)))/elegen0_10(r,gentype);
    chk_gencost(r,gentype,v,t,"ATBraw","kd0")$(elegen0_10(r,gentype) and not conv(gentype)) =  elegen_kdt0(r,gentype,"va",v,t)*(1+tk_10(r,"va",gentype))/elegen0_10(r,gentype);
    chk_gencost(r,gentype,v,t,"ATBraw","ld0")$(elegen0_10(r,gentype) and not conv(gentype)) =  elegen_ldt0(r,gentype,v,t)*(1+tl_10(r,gentype))/elegen0_10(r,gentype);
    chk_gencost(r,gentype,v,t,"ATBraw","ed0")$(elegen0_10(r,gentype) and not conv(gentype)) =  sum(e,elegen_edt0(r,e,"fuel",gentype,v,t))/elegen0_10(r,gentype) ;
    chk_gencost(r,gentype,v,t,"ATBraw","rnw0")$(elegen0_10(r,gentype) and not conv(gentype))=  elegen_rnwdt0(r,gentype,v,t)/elegen0_10(r,gentype) ;

    chk_gencost(r,gentype,v,t,datasource,"in")=   chk_gencost(r,gentype,v,t,datasource,"id0")
                                                + chk_gencost(r,gentype,v,t,datasource,"kd0")
                                                + chk_gencost(r,gentype,v,t,datasource,"ld0")
                                                + chk_gencost(r,gentype,v,t,datasource,"ed0")
                                                + chk_gencost(r,gentype,v,t,datasource,"rnw0") ;

    chk_gencost(r,gentype,v,t,datasource,"bal") = round((  chk_gencost(r,gentype,v,t,datasource,"y0")
                                                         - chk_gencost(r,gentype,v,t,datasource,"in")),7);



* The following is used to adjust the Armington block in electricity generation mix in the model agen
parameter y0_IEO2017(r,i,t)    IEO2017 electricity generation by technology from 2010 to 2050 ($billion)
          y00_10(r,i,v,t)      Electricity generation by technology if using IEO2017 generation mix from 2010 to 2050 ($billion)
          y00(r,i,v)           Electricity generation by technology if using IEO2017 generation mix in 2010 ($billion)       ;

    y0_IEO2017(r,i,t)$prod0_10(r,i,"2010")=IEO2017_gentech(r,i,t)/prod0_10(r,i,"2010")*y0_10(r,i,"new","2010");
    y0_IEO2017(r,"ele",t)=sum(i, y0_IEO2017(r,i,t));

    y00_10(r,i,"new",t)= y0_10(r,"ele","new","2010")*y0_IEO2017(r,i,t)/y0_IEO2017(r,"ele",t);

    y00(r,i,"new")$y00_10(r,i,"new","2010") = y00_10(r,i,"new","2010") ;
display y0_IEO2017,y00_10,y00;

*execute_unload  '.\chk\ATB_chk.gdx',ATB20_elecost;
*execute 'gdxxrw.exe .\chk\ATB_chk.gdx o=.\chk\ATB_chk.xlsx  par=ATB20_elecost       rng=ATB20_elecost!a2  cdim=0'


*CCCCCCCCCCCCCCCCCCCCCCCC Process the base year data in case model is set for aggregated transportation runs   CCCCCCCCCCCCCCCCCCCC
parameter
        y0_10_(r,i,v,t)             Aggregate sectoral output ($2010 billion)
        ed0_10_(r,j,use,i,v,t)      Energy Demand by sector ($2010 billion)
        id0_10_(r,j,i,v,t)          Intermediate demand ($2010 billion)
        ld0_10_(r,i,v,t)            Labor demand ($2010 billion)
        kd0_10_(r,k,i,v,t)          Capital demand ($2010 billion)
        hkd0_10_(r,i,v,t)           Human capital demand ($2010 billion)
        lnd0_10_(r,i,v,t)           Land inputs to agriculture ($2010 billion)
        rd0_10_(r,i,v,t)            Natural resource inputs to energy ($2010 billion)
        rnw0_10_(r,i,v,t)           Renewable electricity resource ($2010 billion)

        cd0_10_(r,hh,i,t)           Consumption demand for goods ($2010 billion)
        fuel0_10_(r,v,t)            Fuel use in personal vehicles ($2010 billion)
        house0_10_(r,i,v,t)         Housing services ($2010 billion)
        le0_10_(r,hh,t)             Labor endowment of households ($2010 billion)
        ke0_10_(r,hh,t)             Capital endowment of households ($2010 billion)

        i0_10_(r,k,i,t)             Investment demand for goods ($2010 billion)
        inv0_10_(r,k,t)             Total investment ($2010 billion)
        g0_10_(r,i,t)               Government demand for goods ($2010 billion)
        gov0_10_(r,t)               Total government ($2010 billion)
        tax0_10_(r,t)               Total tax revenues ($2010 billion)
        lstax_10_(r,hh,t)           Lump-sum transfers ($2010 billion)
        land0_10_(r,t)              Total land endowment ($2010 billion)

        x0_10_(r,i,trd,t)           Exports ($2010 billion)
        m0_10_(r,i,trd,t)           Imports ($2010 billion)
        n0_10_(r,rr,i,t)            Interregional trade ($2010 billion)
        tpt0_10_(r,i,t)             Transport services for trade goods ($2010 billion)
        trs0_10_(r,rr,i,t)          Transport services by export good ($2010 billion)

        ty_10_(r,i)                 Output tax rate (%)
        te_10_(r,j,use,i,t)         Energy tax rate (%)
        ti_10_(r,j,i)               Intermediate inputs tax (%)
        tl_10_(r,i)                 Labor tax rate (%)
        tk_10_(r,k,i)               Capital tax rate (%)
        thk_10_(r,i)                Human capital tax rate (%)
        tn_10_(r,i)                 Land tax rate (%)
        tr_10_(r,i)                 Resource tax rate (%)
        tc_10_(r,i)                 Consumption tax (%)
        tinv_10_(r,k,i)             Investment tax (%)
        tg_10_(r,i)                 Government purchases tax (%)
        tx_10_(r,rr,i)              Export tax (%)
        tm_10_(r,rr,i)              Import tax (%)

        a0_10_(r,i,t)               Armington goods ($2010 billion)
        d0_10_(r,i,t)               Domestic goods ($2010 billion)
        c0_10_(r,hh,t)              Total consumption of goods ($2010 billion)

        pld0_10_(r,i)               Reference labor price (=1+tax rate)
        pkd0_10_(r,k,i)             Reference capital price (=1+tax rate)
        phkd0_10_(r,i)              Reference human capital price (=1+tax rate)
        pid0_10_(r,j,i)             Reference intermediate inputs price (=1+tax rate)
        plnd0_10_(r,i)              Reference land price (=1+tax rate)
        pinv0_10_(r,k,i)            Reference investment price (=1+tax rate)
        prd0_10_(r,i)               Reference resource price (=1+tax rate)
        pcd0_10_(r,i)               Reference consumption goods price (=1+tax rate)
        pg0_10_(r,i)                Reference government consumption price (=1+tax rate)
        pmt0_10_(r,rr,i)            Reference imports price (=1+tax rate)
        pmx0_10_(r,rr,i)            Reference exports price (=1+tax rate)

        ertl0_10_(r,j,use,i,t)      Energy retail Demand by sector ($2010 billion)
        ewhl0_10_(r,j,use,i,t)      Energy wholesale Demand by sector ($2010 billion)
        emrg0_10_(r,j,use,i,t)      Energy margins ($2010 billion)
        etax0_10_(r,j,use,i,t)      Energy taxes ($2010 billion)

        btu0_10_(r,j,use,i,t)       Energy consumption by sector (quad btu)
        prod0_10_(r,i,t)            Energy production (quad Btu)
        elegen0_10_(r,i,t)          Electricity generation by type (quad btu)
        em0_btu_10_(r,i,t)          Energy imports (quad btu)
        ex0_btu_10_(r,i,t)          Energy exports (quad btu)
        en0_btu_10_(r,rr,i,t)       Energy bilateral trade (quad btu)

        prc0_10_(r,j,use,i)         Delivered retail energy prices ($2010 per MMBtu)
        whlprc0_10_(r,i)            Wholesale energy prices ($2010 per MMBtu)

        hectares0_10_(r,i)          Land used in agricultural crops (hectares) (data are old and updated with another parameter q_land0)
        tons0_10_(r,i)              Agricultural crop production (metric tons) (data are old and updated with another parameter ag_ton0)

        oev_valu0_10_(r,i,v,t)      Fuel use in on-road transportation in 2010 ($2010 billion)
        oev_btu0_10_(r,e,i,t)       Fuel use in on-road transportation in 2010 (quad btu)  ;

    y0_10_(r,ii,v,t)         = sum(mapsector(ii,i),y0_10(r,i,v,t));
    ed0_10_(r,jj,use,ii,v,t) = sum(mapsector(ii,i),sum(mapGsector(jj,j),ed0_10(r,j,use,i,v,t)));
    id0_10_(r,jj,ii,v,t)     = sum(mapsector(ii,i),sum(mapGsector(jj,j),id0_10(r,j,i,v,t)));
    ld0_10_(r,ii,v,t)        = sum(mapsector(ii,i),ld0_10(r,i,v,t));
    kd0_10_(r,k,ii,v,t)      = sum(mapsector(ii,i),kd0_10(r,k,i,v,t));
    hkd0_10_(r,ii,v,t)       = sum(mapsector(ii,i),hkd0_10(r,i,v,t));
    lnd0_10_(r,ii,v,t)       = sum(mapsector(ii,i),lnd0_10(r,i,v,t));
    rd0_10_(r,ii,v,t)        = sum(mapsector(ii,i),rd0_10(r,i,v,t));
    rnw0_10_(r,ii,v,t)       = sum(mapsector(ii,i),rnw0_10(r,i,v,t));

    cd0_10_(r,hh,ii,t)       = sum(mapsector(ii,i),cd0_10(r,hh,i,t));
    fuel0_10_(r,v,t)         = fuel0_10(r,v,t);
    house0_10_(r,ii,v,t)     = sum(mapsector(ii,i), house0_10(r,i,v,t));
    le0_10_(r,hh,t)          = le0_10(r,hh,t);
    ke0_10_(r,hh,t)          = ke0_10(r,hh,t);

    i0_10_(r,k,ii,t)         = sum(mapsector(ii,i),i0_10(r,k,i,t));
    inv0_10_(r,k,t)          = inv0_10(r,k,t);
    g0_10_(r,ii,t)           = sum(mapsector(ii,i),g0_10(r,i,t));
    gov0_10_(r,t)            = gov0_10(r,t);
    tax0_10_(r,t)            = tax0_10(r,t);
    lstax_10_(r,hh,t)        = lstax_10(r,hh,t);
    land0_10_(r,t)           = land0_10(r,t);

    x0_10_(r,ii,trd,t)       = sum(mapsector(ii,i),x0_10(r,i,trd,t));
    m0_10_(r,ii,trd,t)       = sum(mapsector(ii,i),m0_10(r,i,trd,t));
    n0_10_(r,rr,ii,t)        = sum(mapsector(ii,i),n0_10(r,rr,i,t));
    tpt0_10_(r,ii,t)         = sum(mapsector(ii,i),tpt0_10(r,i,t));
    trs0_10_(r,rr,ii,t)      = sum(mapsector(ii,i),trs0_10(r,rr,i,t));

    a0_10_(r,ii,t)           = sum(mapsector(ii,i),a0_10(r,i,t));
    d0_10_(r,ii,t)           = sum(mapsector(ii,i),d0_10(r,i,t));
    c0_10_(r,hh,t)           = c0_10(r,hh,t);

    ertl0_10_(r,jj,use,ii,t) = sum(mapsector(ii,i),sum(mapGsector(jj,j),ertl0_10(r,j,use,i,t)));
    ewhl0_10_(r,jj,use,ii,t) = sum(mapsector(ii,i),sum(mapGsector(jj,j),ewhl0_10(r,j,use,i,t)));
    emrg0_10_(r,jj,use,ii,t) = sum(mapsector(ii,i),sum(mapGsector(jj,j),emrg0_10(r,j,use,i,t)));
    etax0_10_(r,jj,use,ii,t) = sum(mapsector(ii,i),sum(mapGsector(jj,j),etax0_10(r,j,use,i,t)));

    btu0_10_(r,jj,use,ii,t)  = sum(mapsector(ii,i),sum(mapGsector(jj,j),btu0_10(r,j,use,i,t)));
    prod0_10_(r,ii,t)        = sum(mapsector(ii,i),prod0_10(r,i,t));
    elegen0_10_(r,ii,t)      = sum(mapsector(ii,i), elegen0_10(r,i));
    em0_btu_10_(r,e,t)       = em0_btu_10(r,e,t);
    ex0_btu_10_(r,e,t)       = ex0_btu_10(r,e,t);
    en0_btu_10_(r,rr,e,t)    = en0_btu_10(r,rr,e,t);

    prc0_10_(r,jj,use,ii)$sum((mapSector(ii,i),mapGSector(jj,j)), btu0_10(r,j,use,i,"2010"))
          =  sum((mapSector(ii,i),mapGSector(jj,j)), prc0_10(r,j,use,i)*btu0_10(r,j,use,i,"2010"))
           / sum((mapSector(ii,i),mapGSector(jj,j)), btu0_10(r,j,use,i,"2010"));

    whlprc0_10_(r,ii)$sum(mapSector(ii,i),prod0_10(r,i,"2010")  )
          =  sum(mapSector(ii,i), whlprc0_10(r,i)* prod0_10(r,i,"2010"))
           / sum(mapSector(ii,i), prod0_10(r,i,"2010"))  ;

    ty_10_(r,ii)$sum(mapSector(ii,i), y0_10(r,i,"new","2010"))
          = sum(mapSector(ii,i),  ty_10(r,i)* y0_10(r,i,"new","2010"))
          / sum(mapSector(ii,i), y0_10(r,i,"new","2010"));

    te_10_(r,jj,use,ii,t)$ertl0_10(r,jj,use,ii,t)
        = etax0_10(r,jj,use,ii,t) /ertl0_10(r,jj,use,ii,t);

    ti_10_(r,jj,ii)$sum((mapSector(ii,i),mapGSector(jj,j)),  id0_10(r,j,i,"new","2010"))
          =  sum((mapSector(ii,i),mapGSector(jj,j)),  ti_10(r,j,i)* id0_10(r,j,i,"new","2010"))
           / sum((mapSector(ii,i),mapGSector(jj,j)),  id0_10(r,j,i,"new","2010"));

    tl_10_(r,ii)$sum(mapSector(ii,i), ld0_10(r,i,"new","2010") )
          = sum(mapSector(ii,i),  tl_10(r,i)* ld0_10(r,i,"new","2010") )
           /sum(mapSector(ii,i),  ld0_10(r,i,"new","2010") ) ;

    tk_10_(r,k,ii)$sum(mapSector(ii,i),kd0_10(r,k,i,"new","2010"))
          =  sum(mapSector(ii,i),  tk_10(r,k,i)* kd0_10(r,k,i,"new","2010"))
           / sum(mapSector(ii,i),  kd0_10(r,k,i,"new","2010"));

    thk_10_(r,ii)$sum(mapSector(ii,i), hkd0_10(r,i,"new","2010") )
          = sum(mapSector(ii,i),  thk_10(r,i)*hkd0_10(r,i,"new","2010") )
           /sum(mapSector(ii,i),  hkd0_10(r,i,"new","2010") );

    tn_10_(r,ii)$sum(mapSector(ii,i),  lnd0_10(r,i,"new","2010") )
          =  sum(mapSector(ii,i),  tn_10(r,i)*lnd0_10(r,i,"new","2010")   )
           / sum(mapSector(ii,i),  lnd0_10(r,i,"new","2010") );

    tr_10_(r,ii)$sum(mapSector(ii,i),  rd0_10(r,i,"new","2010"))
          =  sum(mapSector(ii,i),  tr_10(r,i)*rd0_10(r,i,"new","2010")  )
           / sum(mapSector(ii,i),  rd0_10(r,i,"new","2010")  );

    tc_10_(r,ii)$sum(mapSector(ii,i), cd0_10(r,"hh",i,"2010"))
          = sum(mapSector(ii,i),  tc_10(r,i)*cd0_10(r,"hh",i,"2010") )
           /sum(mapSector(ii,i),  cd0_10(r,"hh",i,"2010"));

    tinv_10_(r,k,ii)$sum(mapSector(ii,i), i0_10(r,k,i,"2010") )
          = sum(mapSector(ii,i),  tinv_10(r,k,i)* i0_10(r,k,i,"2010") )
           /sum(mapSector(ii,i),  i0_10(r,k,i,"2010") );

    tg_10_(r,ii)$sum(mapSector(ii,i), g0_10(r,i,"2010"))
          =  sum(mapSector(ii,i),  tg_10(r,i)*g0_10(r,i,"2010"))
           / sum(mapSector(ii,i),  g0_10(r,i,"2010"));

    tx_10_(r,rr,ii)$sum(mapSector(ii,i), n0_10(r,rr,i,"2010") )
          = sum(mapSector(ii,i),  tx_10(r,rr,i)*n0_10(r,rr,i,"2010") )
           /sum(mapSector(ii,i),  n0_10(r,rr,i,"2010") );

    tm_10_(r,rr,ii)$sum(mapSector(ii,i),  tm_10(r,rr,i)*(trs0_10(r,rr,i,"2010")+(1+tx_10(r,rr,i))*n0_10(r,rr,i,"2010")) )
          =  sum(mapSector(ii,i),  tm_10(r,rr,i)*(trs0_10(r,rr,i,"2010")+(1+tx_10(r,rr,i))*n0_10(r,rr,i,"2010")) )
           / sum(mapSector(ii,i),  (trs0_10(r,rr,i,"2010")+(1+tx_10(r,rr,i))*n0_10(r,rr,i,"2010")) );

    pld0_10_(r,ii)           = 1 + tl_10_(r,ii);
    pkd0_10_(r,k,ii)         = 1 + tk_10_(r,k,ii);
    phkd0_10_(r,ii)          = 1 + thk_10_(r,ii);
    pid0_10_(r,jj,ii)        = 1 + ti_10_(r,jj,ii);
    plnd0_10_(r,ii)          = 1 + tn_10_(r,ii);
    pinv0_10_(r,k,ii)        = 1 + tinv_10_(r,k,ii);
    prd0_10_(r,ii)           = 1 + tr_10_(r,ii);
    pcd0_10_(r,ii)           = 1 + tc_10_(r,ii);
    pg0_10_(r,ii)            = 1 + tg_10_(r,ii);
    pmt0_10_(r,rr,ii)        = 1 + tm_10_(r,rr,ii);
    pmx0_10_(r,rr,ii)        = (1 + tx_10_(r,rr,ii)) * (1 + tm_10_(r,rr,ii));

    hectares0_10_(r,ii)      = sum(mapsector(ii,i),hectares0_10(r,i));
    tons0_10_(r,ii)          = sum(mapsector(ii,i),tons_10(r,i));

    oev_valu0_10_(r,"auto",v,t)= oev_valu0_10(r,"auto",v,t);
    oev_btu0_10_(r,e,"auto",t) = oev_btu0_10(r,e,"Auto",t);

$ifthen setglobal aggtrn
    oev_valu0_10_(r,"Otrn",v,t)= sum(hdv,oev_valu0_10(r,hdv,v,t));
    oev_btu0_10_(r,e,"Otrn",t) = sum(hdv,oev_btu0_10(r,e,hdv,t));
$else
    oev_valu0_10_(r,hdv,v,t)   = oev_valu0_10(r,hdv,v,t);
    oev_btu0_10_(r,e,hdv,t)    = oev_btu0_10(r,e,hdv,t);
$endif

* Remove the time dimension in the base year data set so it can be directly used in model.gms
parameter
        y0(r,i,v)               Aggregate sectoral output ($2010 billion)
        ed0(r,j,use,i,v)        Energy Demand by sector ($2010 billion)
        id0(r,j,i,v)            Intermediate demand ($2010 billion)
        ld0(r,i,v)              Labor demand ($2010 billion)
        kd0(r,k,i,v)            Capital demand ($2010 billion)
        hkd0(r,i,v)             Human capital demand ($2010 billion)
        lnd0(r,i,v)             Land inputs to agriculture ($2010 billion)
        rd0(r,i,v)              Natural resource inputs to energy ($2010 billion)
        rnw0(r,i,v)             Renewable electricity resource ($2010 billion)

        cd0(r,hh,i)             Consumption demand for goods ($2010 billion)
        fuel0(r,v)              Fuel use in personal vehicles ($2010 billion)
        house0(r,i,v)           Housing services ($2010 billion)
        le0(r,hh)               Labor endowment of households ($2010 billion)
        ke0(r,hh)               Capital endowment of households ($2010 billion)

*add endowment for land & energy resource and renewable resource
        lnde0(r,i,v)            Land endowment ($2010 billion)
        re0(r,i,v)              Energy resource endowment ($2010 billion)
        rnwe0(r,i,v)            Electricity resource endowment ($2010 billion)
        gove0(r)                Total government endowment ($2010 billion)

        i0(r,k,i)               Investment demand for goods ($2010 billion)
        inv0(r,k)               Total investment ($2010 billion)
        g0(r,i)                 Government demand for goods ($2010 billion)
        gov0(r)                 Total government expenditure ($2010 billion)
        tax0(r)                 Total tax revenues ($2010 billion)
        lstax(r,hh)             Lump-sum transfers ($2010 billion)
        land0(r)                Total land endowment ($2010 billion)

        x0(r,i,trd)             Exports ($2010 billion)
        m0(r,i,trd)             Imports ($2010 billion)
        n0(r,rr,i)              Interregional trade ($2010 billion)
        tpt0(r,i)               Transport services for trade goods ($2010 billion)
        trs0(r,rr,i)            Transport services by export good ($2010 billion)

        ty(r,i)                 Output tax rate (%)
        te(r,j,use,i)           Energy tax rate (%)
        ti(r,j,i)               Intermediate inputs tax (%)
        tl(r,i)                 Labor tax rate (%)
        tk(r,k,i)               Capital tax rate (%)
        thk(r,i)                Human capital tax rate (%)
        tn(r,i)                 Land tax rate (%)
        tr(r,i)                 Resource tax rate (%)
        tc(r,i)                 Consumption tax (%)
        tinv(r,k,i)             Investment tax (%)
        tg(r,i)                 Government purchases tax (%)
        tx(r,rr,i)              Export tax (%)
        tm(r,rr,i)              Import tax (%)

        hectares0(r,i)          Land used in agricultural crops (hectares) (data are old and updated with another parameter q_land0)
        tons0(r,i)              Agricultural crop production (metric tons) (data are old and updated with another parameter ag_ton0)

        a0(r,i)                 Armington goods ($2010 billion)
        d0(r,i)                 Domestic goods ($2010 billion)
        c0(r,hh)                Total consumption of goods ($2010 billion)

        pld0(r,i)               Reference labor price (=1+tax rate)
        pkd0(r,k,i)             Reference capital price (=1+tax rate)
        phkd0(r,i)              Reference human capital price (=1+tax rate)
        pinv0(r,k,i)            Reference price of investment
        pid0(r,j,i)             Reference intermediate inputs price (=1+tax rate)
        plnd0(r,i)              Reference land price (=1+tax rate)
        prd0(r,i)               Reference resource price (=1+tax rate)
        pcd0(r,i)               Reference consumption goods price (=1+tax rate)
        pg0(r,i)                Reference price of the government good
        pmt0(r,rr,i)            Reference imports price (=1+tax rate)
        pmx0(r,rr,i)            Reference exports price (=1+tax rate)

        ertl0(r,j,use,i)        Energy Retail Demand by sector ($2010 billion)
        ewhl0(r,j,use,i)        Energy Wholesale Demand by sector ($2010 billion)
        emrg0(r,j,use,i)        Energy Margins ($2010 billion)
        etax0(r,j,use,i)        Energy Taxes ($2010 billion)

        btu0(r,j,use,i)         Energy consumption by sector i (quad btu)
        prod0(r,i)              Energy production (quad Btu)
        elegen0(r,i)            Electricity generation by fuel (quad btu)
        em0_btu(r,i)            Energy imports (quad Btu)
        ex0_btu(r,i)            Energy exports (quad Btu)
        en0_btu(r,rr,i)         Energy bilateral trade (quad btu)

        prc0(r,j,use,i)         Delivered energy prices ($2010 per MMBtu)
        whlprc0(r,i)            Wholesale energy prices ($2010 per MMBtu)
        price0(r,e)             Weighted retail energy price in 2010 ($ per mmbtu)

        oev_valu0(r,i,v)        fuel use in on-road transportation in 2010 ($2010 billion) (otrn is assigned)
        oev_btu0(r,i,i)         fuel use in on-road transportation in 2010 (quad) (otrn is assigned) ;

    y0(r,ii,v)         = y0_10_(r,ii,v,"2010");
    ed0(r,jj,use,ii,v) = ed0_10_(r,jj,use,ii,v,"2010");
    id0(r,jj,ii,v)     = id0_10_(r,jj,ii,v,"2010");
    ld0(r,ii,v)        = ld0_10_(r,ii,v,"2010");
    kd0(r,k,ii,v)      = kd0_10_(r,k,ii,v,"2010");
    hkd0(r,ii,v)       = hkd0_10_(r,ii,v,"2010");
    lnd0(r,ii,v)       = lnd0_10_(r,ii,v,"2010");
    rd0(r,ii,v)        = rd0_10_(r,ii,v,"2010");
    rnw0(r,ii,v)       = rnw0_10_(r,ii,v,"2010");

    cd0(r,hh,ii)       = cd0_10_(r,hh,ii,"2010");
    fuel0(r,v)         = fuel0_10_(r,v,"2010");
    house0(r,ii,v)     = house0_10_(r,ii,v,"2010");
    le0(r,hh)          = le0_10_(r,hh, "2010");
    ke0(r,hh)          = ke0_10_(r,hh,"2010");

    i0(r,k,ii)         = i0_10_(r,k,ii,"2010");
    inv0(r,k)          = inv0_10_(r,k,"2010");
    g0(r,ii)           = g0_10_(r,ii,"2010");
    gov0(r)            = gov0_10_(r,"2010");
    tax0(r)            = tax0_10_(r,"2010");
    lstax(r,hh)        = lstax_10_(r,hh,"2010");
    land0(r)           = land0_10_(r,"2010");

    x0(r,ii,trd)       = x0_10_(r,ii,trd,"2010");
    m0(r,ii,trd)       = m0_10_(r,ii,trd,"2010");
    n0(r,rr,ii)        = n0_10_(r,rr,ii,"2010");
    tpt0(r,ii)         = tpt0_10_(r,ii,"2010");
    trs0(r,rr,ii)      = trs0_10_(r,rr,ii,"2010");

    a0(r,ii)           = a0_10_(r,ii,"2010");
    d0(r,ii)           = d0_10_(r,ii,"2010");
    c0(r,hh)           = c0_10_(r,hh,"2010");

    ertl0(r,jj,use,ii) = ertl0_10_(r,jj,use,ii,"2010");
    ewhl0(r,jj,use,ii) = ewhl0_10_(r,jj,use,ii,"2010");
    emrg0(r,jj,use,ii) = emrg0_10_(r,jj,use,ii,"2010");
    etax0(r,jj,use,ii) = etax0_10_(r,jj,use,ii,"2010");

    btu0(r,jj,use,ii)  = btu0_10_(r,jj,use,ii,"2010");
    prod0(r,ii)        = prod0_10_(r,ii,"2010");
    elegen0(r,ii)      = elegen0_10_(r,ii,"2010");
    em0_btu(r,e)       = em0_btu_10_(r,e,"2010");
    ex0_btu(r,e)       = ex0_btu_10_(r,e,"2010");
    en0_btu(r,rr,e)    = en0_btu_10_(r,rr,e,"2010");

    prc0(r,jj,use,ii)  = prc0_10_(r,jj,use,ii);
    whlprc0(r,ii)      = whlprc0_10_(r,ii) ;

    ty(r,ii)           = ty_10_(r,ii);
    te(r,jj,use,ii)    = te_10_(r,jj,use,ii,"2010");;
    ti(r,jj,ii)        = ti_10_(r,jj,ii);
    tl(r,ii)           = tl_10_(r,ii) ;
    tk(r,k,ii)         = tk_10_(r,k,ii);
    thk(r,ii)          = thk_10_(r,ii);
    tn(r,ii)           = tn_10_(r,ii);
    tr(r,ii)           = tr_10_(r,ii);
    tc(r,ii)           = tc_10_(r,ii);
    tinv(r,k,ii)       = tinv_10_(r,k,ii) ;
    tg(r,ii)           = tg_10_(r,ii);
    tx(r,rr,ii)        = tx_10_(r,rr,ii);
    tm(r,rr,ii)        = tm_10_(r,rr,ii);

    pld0(r,ii)         = 1 + tl(r,ii);
    pkd0(r,k,ii)       = 1 + tk(r,k,ii);
    phkd0(r,ii)        = 1 + thk(r,ii);
    pid0(r,jj,ii)      = 1 + ti(r,jj,ii);
    plnd0(r,ii)        = 1 + tn(r,ii);
    pinv0(r,k,ii)      = 1 + tinv(r,k,ii);
    prd0(r,ii)         = 1 + tr(r,ii);
    pcd0(r,ii)         = 1 + tc(r,ii);
    pg0(r,ii)          = 1 + tg(r,ii);
    pmt0(r,rr,ii)      = 1 + tm(r,rr,ii);
    pmx0(r,rr,ii)      = (1 + tx(r,rr,ii)) * (1 + tm(r,rr,ii));

    hectares0(r,ii)    = hectares0_10_(r,ii);
    tons0(r,ii)        = tons0_10_(r,ii);

    oev_valu0(r,ii,v)  = oev_valu0_10_(r,ii,v,"2010");
    oev_btu0(r,e,ii)   = oev_btu0_10_(r,e,ii,"2010");

    price0(r,e)$sum((use,i,v),ed0(r,e,use,i,v))
     = sum((use,i), ed0(r,e,use,i,"new"))/sum((use,i)$prc0(r,e,use,i),btu0(r,e,use,i))

set   label        Input catergory
            / Ed0         Energy
              Ld0         Labor
              Kd0         Capital
              Hkd0        Human capital
              Id0         Material
              In          Total input
              Out         Totoal output
              Y0          Main output
            /
       balvar      Market balance category    / production, consumption, import, export, balance/
       mrkt        Market clearance items      /y0, m0, x0, id0, ed0, cd0, i0,g0,in, out,bal /
       inout       Input and output items      /in, out/
;

parameter chk0_mrkt(r,i,*)         Check the market balance for all commodities after aggregation;

    chk0_mrkt(r,i,"y0")$(not gentype(i))  = y0(r,i,"new")+ house0(r,"hh","new")$housei(i);
    chk0_mrkt(r,i,"m0")$(not gentype(i))  = m0(r,i,"ftrd");
    chk0_mrkt(r,i,"x0")$(not gentype(i))  = sum(trd, x0(r,i,trd)) ;
    chk0_mrkt(r,i,"id0")$(not gentype(i)) = sum(j, id0(r,i,j,"new"));
    chk0_mrkt(r,i,"ed0")$(not gentype(i) and e(i))
       =    sum((use,j), ertl0(r,i,use,j))
          - sum((use,j), emrg0(r,i,use,j))
          - sum((use,j), etax0(r,i,use,j))    ;

    chk0_mrkt(r,i,"cd0")$(not gentype(i)) = sum(hh, cd0(r,hh,i));
    chk0_mrkt(r,i,"i0")$(not gentype(i))  = sum(k, i0(r,k,i));
    chk0_mrkt(r,i,"g0")$(not gentype(i))  = g0(r,i);

    chk0_mrkt(r,i,"bal")$(not gentype(i))
        = round((    y0(r,i,"new") + house0(r,"hh","new")$housei(i)
                   + sum(trd,m0(r,i,trd))
                   - sum(trd, x0(r,i,trd))
                   - sum(j, id0(r,i,j,"new"))
                   - chk0_mrkt(r,i,"ed0")$e(i)
                   - sum(hh, cd0(r,hh,i))
                   - sum(k,  i0(r,k,i))
                   - g0(r,i)), 5);

    chk0_prod(r,i,v,'out')$(y0(r,i,v)   and new(v) and not byprod(i))
         =  y0(r,i,v)*(1-ty(r,i))
          + y0(r,"omel",v)$vol(i)
          + y0(r,"ddgs",v)$ceth(i) ;

    chk0_prod(r,i,v,'in')$(y0(r,i,v)   and new(v) and not byprod(i) and not liv(i))
        =   sum((e,use),ed0(r,e,use,i,v))
          + sum(g,id0(r,g,i,v)*(1+ti(r,g,i)))
          + ld0(r,i,v)*(1+tl(r,i))
          + sum(k,kd0(r,k,i,v)*(1+tk(r,k,i)))
          + hkd0(r,i,v)*(1+thk(r,i))
          + (lnd0(r,i,v)*(1+tn(r,i)))$crp(i)
          + (lnd0(r,i,v)*(1+tn(r,i)))$(not crp(i))
          + rd0(r,i,v)*(1+tr(r,i))
          + rnw0(r,i,v)  ;

    chk0_prod(r,i,v,'in')$(y0(r,i,v)    and new(v) and  liv(i))
        =   sum((e,use),ed0(r,e,use,i,v))
          + sum(g$(not (feed(g) or ofd(g))),id0(r,g,i,v)*(1+ti(r,g,i)))
          + sum(crp, id0(r,crp,i,v)  *pid0(r,crp,i))
          + sum(byprod, id0(r,byprod,i,v)  )
          + sum(ofd, id0(r,ofd,i,v)  *pid0(r,ofd,i))

          + ld0(r,i,v)*(1+tl(r,i))
          + sum(k,kd0(r,k,i,v)*(1+tk(r,k,i)))
          + hkd0(r,i,v)*(1+thk(r,i))
          + lnd0(r,i,v)*(1+tn(r,i))
          + rd0(r,i,v)*(1+tr(r,i)) ;

    chk0_prod(r,i,v,'out')$ele(i)
         = sum(gentype$(not conv(gentype) and not advee(gentype)), chk0_prod(r,gentype,v,'out'));

    chk0_prod(r,i,v,'in')$ele(i)
         = sum(gentype$(not conv(gentype) and not advee(gentype)), chk0_prod(r,gentype,v,'in'));

    chk0_prod(r,i,v,'bal') =round((chk0_prod(r,i,v,'out')-chk0_prod(r,i,v,'in')),5);

display  chk0_mrkt,chk0_prod;

parameter chk0_enbal       Check energy supply - demand balance in quad btu
          chk0_enconv      Check energy import balance ;
* Goods supply demand balance holds in the equation: y0+m0-x0-a0=0
* Energy has both retail and wholesale market where a0 corresponds to wholesale
    chk0_enbal(r,e,"Production") = prod0(r,e);
    chk0_enbal(r,e,"Consumption")= sum((use,i),btu0(r,e,use,i));
    chk0_enbal(r,e,"Import")     = em0_btu(r,e);
    chk0_enbal(r,e,"Export")     = ex0_btu(r,e);
    chk0_enbal(r,e,"balance")    = round((   chk0_enbal(r,e,"Production")
                                           + chk0_enbal(r,e,"Import")
                                           - chk0_enbal(r,e,"Consumption")
                                           - chk0_enbal(r,e,"Export") ),6) ;

    chk0_enbal("world",e,balvar)=sum(r, chk0_enbal(r,e,balvar));

    chk0_enconv(r,e,"import1") = em0_btu(r,e);
    chk0_enconv(r,e,"import2") = sum(rr,en0_btu(r,rr,e));
    chk0_enconv(r,e,"export1") = ex0_btu(r,e);
    chk0_enconv(r,e,"export2") = sum(rr,en0_btu(rr,r,e));

option  chk0_enbal:3:2:1;
display chk0_enbal,chk0_enconv;


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                           Land use, land cover, land use change data and further processing
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

    tr(r,ff)   =  0.05;
    rd0(r,ff,v)=  rd0(r,ff,v)/(1+tr(r,ff));

* Adjust land endowment
    rd0(r,"frs",v)    =  rd0(r,"frs",v) * prd0(r,"frs");
    lnd0(r,"frs",v)   =  rd0(r,"frs",v);
    tn(r,'frs')       =  tr(r,'frs');
    tn(r,'frs')       =  0;
    plnd0(r,'frs')    =  1+ tn(r,'frs') ;
    rd0(r,"frs",v)    =  0;
    tr(r,'frs')       =  0;
    land0(r)          = land0(r)   + sum(vnum, lnd0(r,"frs",vnum)  );
    lnd0(r,"CROP",v)  = sum(crp, lnd0(r,crp,v)  );

parameter crp_lnd0     Cropland input separated from lnd0;
    crp_lnd0(r,crp,v) = lnd0(r,crp,v)  ;
    lnd0(r,crp,v)     = 0;

Parameter
          luc          Flag to activate land use change by region
          f_luc        Flag to activate transformation in land use from one activity to other
          npp          Flag for land productivity improvement
          npp0         Land productivity growth trend
          mk_luc       Markup in land use transformation to represent costs to open and explore new areas;

* Allow agriculture transitions:
    f_luc(r,agri,agrii) = 1;
    f_luc(r,agri,agri)  = 0;
* Allow agriculture abandonment:
    f_luc(r,nat,agri)   = 1;
* Do not allow conversion from pasture to forests:
    f_luc(r,"frs","liv") = 0;
    f_luc(r,"nfrs","liv")= 0;

* No land conversion is allowed from managed forest to pasture in USA
    f_luc("usa","liv","frs")= 0;

* Natural forest can directly become only managed forest and natural grass only pasture:
    f_luc(r,agri,nat)     = 0;
    f_luc(r,"frs","nfrs") = 1;
    f_luc(r,"liv","ngrs") = 1;

* NPP is assumed to remain constant over time for land uses other than crop production, where productivity is assumed to increase by 1% per year
    luc(r)      = 1;
    npp(r,lu)   = 1;
    npp0(r,lu,t)= 1;
    npp0(r,"crop",t)=(1+0.01)**(5*(ord(t)-1));

    mk_luc(r,lu, lu_) = 1;


* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCC    Land use, land cover, land use change data CCCCCCCCCCCCCCCCCCCCCCCCCC
* Data are from FAO and GTAP and EPPA-TEM
$include 'data\data2_lulc.dat'
*  parameter lulc             Combined land cover for 8 regions in 2010 from different sources (ha) (from EPPA5)/
*  parameter nat_tran         Natural land transformation parameter for ADAGE (from EPPA5)
*  parameter carbcnt(r,lu)    Carbon content for regions (including soil and vegetable carbons) (metric ton c per ha) (from EPPA5)/
*  parameter year_rot(r)      Forest rotation age for ADAGE (from EPPA5)
* nat_tran:
*   out: output from natural forest relative to traditional forestry sector when 1 new ha of natural is harvested
*   inp: ratio natural area rents to harvested area rents
*   nf_f: share of forestry output from natural forests
*   s_el: elasticity of land supply (calculated in the file: Land supply elasticities_corrected.xls at: MIT/Projects/TEM E EPPA/Land use documentation
*   s_el calculations need to be corrected since we rely on historical land use changes from TEM (regional aggregation of EPPA5 is different from EPPA4)

parameter
          d_shr               Share of output coming from managed forestry sector
          l_shr               Share of land used by managed forestry sector
          f_adj               Adjustment to other inputs at forestry sector  ;

    d_shr(r,s) = 1;
    d_shr(r,'frs') = 1 - nat_tran(r,"nf_f");
    d_shr(r,"frs")$(not luc(r)) = 1;

* Calculate the share of land used by managed forestry sector given the share of forest output
* from deforestation and $ output/ha from deforestation relative to managed forest sector
    l_shr(r,s) = 1;
    l_shr(r,'frs') =  ( d_shr(r,'frs')/nat_tran(r,"nf_f")*nat_tran(r,"out"))
                     /((d_shr(r,'frs')/nat_tran(r,"nf_f")*nat_tran(r,"out"))+1);
    l_shr(r,'frs')$(not luc(r))=1;

    f_adj(r,s,v)$vnum(v) = 1;

* Adjustment = (output from trad. forestry sector - land rents from trad. forestry sector) / (output from trad. forestry sector - land rents of nat. and trad. forests)
    f_adj(r,'frs',v)$vnum(v) = ((1-ty(r,'frs'))*(y0(r,'frs',v)*d_shr(r,'frs'))
                              - (lnd0(r,'frs',v)*l_shr(r,'frs')))/((1-ty(r,'frs'))*y0(r,'frs',v)
                              - (lnd0(r,'frs',v)));
    f_adj(r,"frs",v)$(vnum(v) and not luc(r)) = 1;

    d_shr(r,'crop') = 1;
    l_shr(r,'crop') = 1;
    f_adj(r,'crop',v) = 1;
option l_shr:5:1:1

parameter q_lndothr0(reg)   Land area for other in 2010 (SOURCE: EPPA-TEM) (mha)
   /
    AFR        851.015
    BRA        23.575
    CHN        241.136
    EUR        29.562
    ROW        1086.599
    USA        106.421
    XAS        166.799
    XLM        152.138
   /;

table     rice0(reg,*)     Paddy rice information (SOURCE: FAO)
* area: mha; production: mmt; yield:metric ton per ha
               area   production       Yield
    CHN      37.488     195.304       5.210
    XAS     128.243     438.191       3.417
    USA       1.226       9.410       7.677
    BRA       3.527      12.293       3.485
    XLM       3.176      14.825       4.668
    EUR       0.362       2.644       7.304
    AFR       9.759      24.783       2.539
    ROW       1.125       4.927       4.381
;

parameter q_crpchn(*)     Adjustment for China land area (SOURCE: FAO)
* The land area from Lulc for China from EPPA5 looks off so new data from FAO is brought in to fix it
   /Wht          19.258
    Corn         19.341
    Soyb         9.772
    Gron         1.286
    Srcn         1.696
    Srbt         0.219
    Osdn         5.424
    Ocr          142.461
    Total        199.456
    /;

alias(crp,crp0);

parameter q_land0(*,*)        Final land area for the model in 2010 (mha)
          p_land0(r,*)        Final land rent for the model in 2010 ($billion per mha)
          v_land0(r,*)        Value of land in 2010 ($billion per mha)
          rent_r0(r,lu,lu_)   Markup in the land conversion from one type to other ($billion per mha)
          rentv0(r,i)         Natural land value ($ billion)
          rentv(r,i)          Natural land value endowment ($ billion)

          chk0_lnd0           Check land value before and after adjustment
          kd00, ld00          Capital and labor in the adjusted ag production
          chk0_ag             Chk zero profit condition in the adjusted ag production
  ;
* Natural area comes from eppa-tem
* Land rent is the same for all crops
* Land area is quite different between crpfao and crptem, here we adjust to make sure the yield looks reasonable
* Divide by 1e+6: convert ha in lulc to mha in q_land0
    q_land0(r,'crop') = lulc(r,'crptem')/1e+6;
    q_land0(r,'crop')$(sameas(r,"USA")) = lulc(r,'crpfao')/1e+6;
    q_land0(r,'crop')$(sameas(r,"ROW")) = lulc(r,'crpfao')/1e+6;
    q_land0(r,'crop')$(sameas(r,"XLM")) = lulc(r,'crpfao')/1e+6;

    q_land0(r,'liv')  = lulc(r,'livtem')/1e+6;
    q_land0(r,'liv')$(sameas(r,"XLM"))  = lulc(r,'livgtap')/1e+6;

    q_land0(r,'frs')  = lulc(r,'frstem')/1e+6;
    q_land0(r,'nfrs') = lulc(r,'nfrs')/1e+6;
    q_land0(r,'ngrs') = lulc(r,'ngrs')/1e+6;

    p_land0(r,s)$q_land0(r,s)
            = sum(v,lnd0(r,s,v))/q_land0(r,s)  ;

    p_land0(r,'crop')$q_land0(r,'crop')
           = sum((v,crp),crp_lnd0(r,crp,v))/q_land0(r,'crop')   ;

* Assign crop area proportionally with gtap crop area
* Change crp_lnd0 proportionally with gtap crop area
* Put the difference of land value to capital
    q_land0(r,crp)= q_land0(r,'crop')*lulc(r,crp)/sum(crp0,lulc(r,crp0));

* Make adjustment for China to fix the negative lnd0 issue
    q_land0(r,crp)$chn(r)=q_crpchn(crp);

* Make adjustment for XAS to fix the negative lnd0 issue
    q_land0("xas","gron")= q_land0("xas","gron")-13;
    q_land0("xas","wht") = q_land0("xas","wht") + 5;
    q_land0("xas","srcn")= q_land0("xas","srcn")+ 1;
    q_land0("xas","ocr") = q_land0("xas","ocr") + 7;

    lnd0(r,crp,"new")    = q_land0(r,crp)* p_land0(r,'crop');

* Make adjustments to prevent K&L from going negative
PARAMETER lnd_adj   Track lnd0 adjustments and prevent negatives ;

    lnd_adj(r,crp,"PRE")    = lnd0(r,crp,"new") ;
    lnd0(r,crp,"new")$(lnd0(r,crp,"new")-crp_lnd0(r,crp,"new") > 0.9 * (kd0(r,"va",crp,"new")+ld0(r,crp,"new"))) =  0.9 * (kd0(r,"va",crp,"new")+ld0(r,crp,"new")) + crp_lnd0(r,crp,"new");
    q_land0(r,crp)          = lnd0(r,crp,"new") / p_land0(r,'crop') ;

    lnd_adj(r,crp,"PST")                            = lnd0(r,crp,"new")         ;
    lnd_adj(r,crp,"PCT")$lnd_adj(r,crp,"PRE")       = lnd_adj(r,crp,"PST") / lnd_adj(r,crp,"PRE") - 1   ;
    lnd_adj(r,crp,"PRE")$(lnd_adj(r,crp,"PRE")=lnd_adj(r,crp,"PST"))    = 0     ;
    lnd_adj(r,crp,"PST")$(lnd_adj(r,crp,"PRE")=0)    = 0 ;
    lnd_adj(r,crp,"PCT")$(lnd_adj(r,crp,"PRE")=0)    = 0 ;

    kd00(r,"va",crp,"new")$(kd0(r,"va",crp,"new")+ld0(r,crp,"new"))
           = kd0(r,"va",crp,"new")-(lnd0(r,crp,"new")-crp_lnd0(r,crp,"new"))* kd0(r,"va",crp,"new")/(kd0(r,"va",crp,"new")+ld0(r,crp,"new")) ;

    ld00(r,crp,"new")
        =(       y0(r,crp,"new")*(1-ty(r,crp))
               - (  sum((e,use),ed0(r,e,use,crp,"new"))
                  + sum(g,id0(r,g,crp,"new")*(1+ti(r,g,crp)))
                  + sum(k,kd00(r,k,crp,"new")*(1+tk(r,k,crp)))
                  + hkd0(r,crp,"new")*(1+thk(r,crp))
                 + (lnd0(r,crp,"new")*(1+tn(r,crp)))
                  + rd0(r,crp,"new")*(1+tr(r,crp))  ) )
          /(1+tl(r,crp));

    p_land0(r,'ngrs')$q_land0(r,'liv')
           =  p_land0(r,'liv')*nat_tran(r,'inp')  ;

    p_land0(r,'nfrs')$q_land0(r,'frs')
           = p_land0(r,'frs')*nat_tran(r,'inp')  ;

* Fix price for some regions where it is too low or too high
    p_land0('usa','nfrs')
           =  2* p_land0('usa','nfrs')   ;
    p_land0('usa','ngrs')
           =  0.1* p_land0('usa','ngrs')   ;
    p_land0('eur','nfrs')
           =  10* p_land0('eur','nfrs')   ;

    rentv0(r,nat)= p_land0(r,nat)*q_land0(r,nat);
    rentv0(r,'nfrs')$((rentv0(r,'nfrs')- lnd0(r,"frs",'new')*(1-l_shr(r,"frs"))*nat_tran(r,"inp"))<0)
        = 1.1*lnd0(r,"frs",'new')*(1-l_shr(r,"frs"))*nat_tran(r,"inp");

    p_land0(r,nat)=rentv0(r,nat)/q_land0(r,nat);

    v_land0(r,lu)    = p_land0(r,lu);
    rent_r0(r,lu,lu_)= max(0, (v_land0(r,lu)-v_land0(r,lu_)));

* Check land value to ensure it is not negative when we reassign the land value based on the area
    chk0_lnd0(r,crp,"old")=crp_lnd0(r,crp,"new");
    chk0_lnd0(r,"crop","old")=sum(crp,crp_lnd0(r,crp,"new"));
    chk0_lnd0(r,"crop","old1")=lnd0(r,"crop","new");
    chk0_lnd0(r,crp,"new")=lnd0(r,crp,"new");
    chk0_lnd0(r,"crop","new")=sum(crp,lnd0(r,crp,"new"));
    chk0_lnd0(r,s,"diff")=-chk0_lnd0(r,s,"new")+chk0_lnd0(r,s,"old");

    chk0_lnd0(r,crp,"K")=kd0(r,"va",crp,"new");
    chk0_lnd0(r,crp,"L")=ld0(r,crp,"new");
    chk0_lnd0(r,crp,"K+L")= chk0_lnd0(r,crp,"K")+  chk0_lnd0(r,crp,"L");

    chk0_lnd0(r,crp,"K_new")=kd00(r,"va",crp,"new");
    chk0_lnd0(r,crp,"L_new")=ld00(r,crp,"new");
    chk0_lnd0(r,crp,"K+L_new")= chk0_lnd0(r,crp,"K_New")+  chk0_lnd0(r,crp,"L_new");

* Reassign new capital and labor
    crp_lnd0(r,crp,"new") = lnd0(r,crp,"new") ;
    lnd0(r,crp,"new")     = 0;

    ld0_10_(r,crp,"new","2010")= ld00(r,crp,"new");
    ld0(r,crp,"new")           = ld00(r,crp,"new") ;
    le0_10_(r,hh, "2010")      = sum(i, ld0_10_(r,i,"new","2010"));
    le0(r,hh)                  = le0_10_(r,hh, "2010");

    kd0_10_(r,"va",crp,"new","2010")= kd00(r,"va",crp,"new");
    kd0(r,"va",crp,"new")           = kd00(r,"va",crp,"new");
    ke0_10_(r,hh,"2010")            = sum(i, kd0_10_(r,"va",i,"new","2010"));
    ke0(r,hh)                       = ke0_10_(r,hh,"2010");

option lnd0:3:1:2,chk0_lnd0:3:2:1;

parameters
         fffor0            Fixed factor endowment for natural land conversion ($billion)
         fffor             Fixed factor endowment for natural land conversion ($billion)
         ffforT            Fixed factor endowment for natural land conversion over time ($billion)
         l_fx_el           Elasticity of substitution in the fixed factor at natural land transformation function
         l_fx_elt          Elasticity of substitution in the fixed factor at natural land transformation function
         alpha_l           Cost share of fixed factor
         lndout            Value of natural harvested product ($billion per mha)
         otinp             Value of other inputs      ;

    fffor0(r,agri,v)$vnum(v)=0.01*v_land0(r,agri);
    rent_r0(r,lu,lu_)= max(0, (v_land0(r,lu)-v_land0(r,lu_)-fffor0(r,lu_,'new')));

    fffor0(r,'nfrs',v)$vnum(v) = (lnd0(r,"Frs",v)*(1-l_shr(r,"FRS"))-(lnd0(r,"Frs",v)*(1-l_shr(r,"Frs"))*nat_tran(r,"inp")))
                                 / q_land0(r,"frs") ;

    alpha_l(r,t,"nfrs",v)$vnum(v) = fffor0(r,"nfrs",v)/((lnd0(r,"frs",v)*(1-l_shr(r,"frs"))+(y0(r,"frs",v)*nat_tran(r,"nf_f")))/q_land0(r,"frs"));
    l_fx_el(r,"nfrs",v)$vnum(v)   = nat_tran(r,"s_el")/(1-alpha_l(r,"2010","nfrs",v));
    alpha_l(r,t,"ngrs",v)$vnum(v) = alpha_l(r,t,"nfrs",v);
    l_fx_el(r,"ngrs",v)$vnum(v)   = l_fx_el(r,"nfrs",v);

* Allow USA, EUR and China to preserve natural forest as observed historically
    l_fx_el("usa","ngrs",v)$vnum(v)   = 10*l_fx_el("Usa","nfrs",v);
    l_fx_el("chn","ngrs",v)$vnum(v)   = 10*l_fx_el("chn","nfrs",v);
    l_fx_el("eur","ngrs",v)$vnum(v)   = 10*l_fx_el("eur","nfrs",v);
    l_fx_el("XLM",lu,v)               = l_fx_el("BRA",lu,v);

    fffor0(r,'ngrs',v)$vnum(v) = v_land0(r,"liv")*alpha_l(r,"2010",'ngrs','new');

    lndout(r,"nfrs",v)$vnum(v) = nat_tran(r,"out")*y0(r,"frs",v)/q_land0(r,"frs");
    lndout(r,"ngrs",v)$vnum(v) = 0;

    otinp(r,"nfrs",v)$vnum(v) = lndout(r,"nfrs",v)*(1-ty(r,'frs')) + v_land0(r,"frs") - v_land0(r,"nfrs") - fffor0(r,'nfrs',v);
    otinp(r,"ngrs",v)$vnum(v) = lndout(r,"ngrs",v)*(1-ty(r,'liv')) + v_land0(r,"liv") - v_land0(r,"ngrs") - fffor0(r,'ngrs',v);

alias  (j,j0), (lu,lu_);

* Prepare land use change production block using the aggregated ag production function
parameter  ag_prd   Total inputs in the production function of agriculture
           ag_shr   Share of inputs other than energy in the ag production function which will be used in the land conversion function
           ag_shre  Share of energy inputs in the agriculture production function which will be used in the land conversion function   ;

    ag_prd(r,'crop',v)  =   sum((k,crp),kd0(r,k,crp,v))
                          + sum(crp, hkd0(r,crp,v))
                          + sum(crp, ld0(r,crp,v))
                          + sum((g,crp)$(not sameas(crp,'ocr')), id0(r,g,crp,v))
                          + sum((g,crp)$(sameas(crp,'ocr')), id0(r,g,crp,v))
                          + sum((j,use,crp), ed0(r,j,use,crp,v))
                          + sum(crp,rd0(r,crp,v));
    ag_prd(r,i,v)$(frs(i) or liv(i))
                        =   sum(k,kd0(r,k,i,v)) + hkd0(r,i,v)+ ld0(r,i,v)
                          + sum(g, id0(r,g,i,v))
                          + sum((j0,use), ed0(r,j0,use,i,v))
                          + rd0(r,i,v) ;

    ag_shr(r,'crop',k,v)$ag_prd(r,'crop',v)
                      =    sum(crp,kd0(r,k,crp,v))
                         / ag_prd(r,'crop',v);

    ag_shr(r,'crop',"hk",v)$ag_prd(r,'crop',v)
                      =    sum(crp, hkd0(r,crp,v))
                         / ag_prd(r,'crop',v);

    ag_shr(r,'crop',"L",v)$ag_prd(r,'crop',v)
                      =    sum(crp, ld0(r,crp,v))
                         / ag_prd(r,'crop',v);

    ag_shr(r,'crop',i,v)$(ag_prd(r,'crop',v) )
                      =  (   sum(crp$(not sameas(crp,'ocr')), id0(r,i,crp,v))  + id0(r,i,"ocr",v)  )
                        / ag_prd(r,'crop',v);


    ag_shr(r,'crop','r',v)$ag_prd(r,'crop',v)
                      =   sum(crp,rd0(r,crp,v))
                        / ag_prd(r,'crop',v);

    ag_shre(r,'crop',e,use,crp,v)$ag_prd(r,'crop',v)
                      =   ed0(r,e,use,crp,v)
                        / ag_prd(r,'crop',v);


    ag_shr(r,i,k,v)$(( liv(i) or frs(i) ) and  ag_prd(r,i,v))
                      =    kd0(r,k,i,v)
                         / ag_prd(r,i,v);

    ag_shr(r,i,"hk",v)$(( liv(i) or frs(i) ) and ag_prd(r,i,v))
                      =    hkd0(r,i,v)
                         / ag_prd(r,i,v);

    ag_shr(r,i,"L",v)$(( liv(i) or frs(i) ) and  ag_prd(r,i,v))
                      =    ld0(r,i,v)
                         / ag_prd(r,i,v);

    ag_shr(r,i,g,v)$(( liv(i) or frs(i) ) and ag_prd(r,i,v))
                      =    id0(r,g,i,v)
                         / ag_prd(r,i,v);
    ag_shr(r,i,'r',v)$(( liv(i) or frs(i) ) and ag_prd(r,i,v))
                      =    rd0(r,i,v)
                         / ag_prd(r,i,v);

    ag_shre(r,i,e,use,i,v)$(( liv(i) or frs(i) ) and ag_prd(r,i,v))
                      =    ed0(r,e,use,i,v)
                         / ag_prd(r,i,v);

    ag_shr(r,i,'tot',v) = sum(k,ag_shr(r,i,k,v))+ag_shr(r,i,'hk',v)+ ag_shr(r,i,'l',v)+ sum(j,ag_shr(r,i,j,v))+ag_shr(r,i,'r',v)+sum((e,use,j),ag_shre(r,i,e,use,j,v));

option ag_shr:2:2:2,  ag_shre:2:3:2


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                        Data for ag and biofuel physical information in 2010
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
* Data are collected from FAO
$include  '.\data\data3_agbio.dat'

parameter chk0_agv      Check agriculture value
          chk0_biov     Check biofuel value
          ag_yield0     Ag yield in 2010 (metric ton per ha);
** There is a significant difference between GTAP & FAO data especially the livestock sector
    chk0_agv(r,agr,'adage')   = y0(r,agr,'new');
    chk0_agv(r,agr,'gtap')    = ag_valu0(r,agr);
    chk0_agv(r,'frs','adage') = 0;
    chk0_agv(r,agr,'diff')    = round((chk0_agv(r,agr,'adage')- chk0_agv(r,agr,'gtap')),1);

    chk0_biov(r,bio,'adage')  = y0(r,bio,'new');
    chk0_biov(r,bio,'gtap')   = biop_valu0(r,bio);
    chk0_biov(r,bio,'diff')   = chk0_biov(r,bio,'adage')- chk0_biov(r,bio,'gtap') ;
option chk0_biov:1:2:1,chk0_agv:1:2:1;

* Update the ag_valu0 with GTAP data
    ag_valu0(r,i)    = 0;
    ag_valu0(r,crp)  = y0(r,crp,'new');
    ag_tonn0(r,'liv')= 0;
    ag_tonn0(r,'mea')= 0;
    ag_pric0(r,s)$(not sameas(s,"liv"))=0;
    ag_pric0(r,crp)$ag_tonn0(r,crp) = ag_valu0(r,crp)/ag_tonn0(r,crp);

    ag_pric0(r,"mea")= ag_pric0(r,"liv")*y0(r,"mea","new")/id0(r,"liv", "mea","new");
    ag_tonn0(r,'liv')= y0(r,"liv",'new')/ag_pric0(r,"liv");
    ag_tonn0(r,'mea')= y0(r,"mea",'new')/ag_pric0(r,"mea");

* Ag price data for forest product is taken from GLOBIOM on phase II model comparision (thousand $2010/metric ton)
    ag_pric0("AFR","frs")=   0.56897   ;
    ag_pric0("BRA","frs")=   0.55143   ;
    ag_pric0("CHN","frs")=   1.26422   ;
    ag_pric0("EUR","frs")=   0.64026   ;
    ag_pric0("XAS","frs")=   0.67374   ;
    ag_pric0("XLM","frs")=   0.56015   ;
    ag_pric0("ROW","frs")=   0.64336   ;
    ag_pric0("USA","frs")=   0.71233   ;
    ag_pric0("World","frs")= 0.68902   ;

    ag_tonn0(r,'frs')$ag_pric0(r,"frs")  =  y0(r,"frs",'new')/ag_pric0(r,"frs");

* ddgs price is from usda and adjusted to ensure ddgs production yield in USA is 6.011 in 2010
    ag_pric0(r,"ddgs")     = 0.1170;
    ag_pric0("USA","ddgs") = 0.15375;
    ag_pric0("CHN","ddgs") = 0.11179;
    ag_pric0("ROW","ddgs") = 0.37505;
    ag_pric0(r,"omel")     = 0.31359;
    ag_tonn0(r,byprod)$ag_pric0(r,byprod) = y0(r,byprod,'new')/ag_pric0(r,byprod);

Table volby_pric0(r,i)   vegetable oil and byproduct price
* Assume soybean yield in terms to weight: oil (vol) : 19%, meal (omel): 80%; waste: 1%
* The osdn yield in terms to weight:     oil (vol) : 40%*0.97=38.8%, meal (omel): 60%; waste: 1.2%
*     osdn conversion rate is 0.97 above
* https://www.cmegroup.com/trading/agricultural/files/pm374-cbot-soybeans-vs-dce-soybean-meal-and-soybean-oil.pdf
                   Omel           Vol
    USA         0.10060       3.70347
    BRA         0.02239       4.43709
    CHN         0.01392       2.06082
    EUR         0.04824       2.66469
    XLM         0.02026       2.96744
    XAS         0.03595       2.45225
    AFR         0.02641       2.20566
    ROW         0.06816       4.69054
;
    ag_pric0(r,"vol")  = volby_pric0(r,"vol");
    ag_pric0(r,"omel") = volby_pric0(r,"omel");

    ag_tonn0(r,'vol')  = y0(r,"vol",'new')/ag_pric0(r,"vol");
    ag_tonn0(r,'omel') = y0(r,"omel",'new')/ag_pric0(r,"omel");

    ag_yield0(r,i)$q_land0(r,i)          = ag_tonn0(r,i)/q_land0(r,i);

* Yield for feedstock used in advbio in metric ton/ha:
    ag_yield0(r,"swge") =   15;
    ag_yield0(r,"Msce") = 2*15;
    ag_yield0(r,"Frwe") = 22.32;

parameter     chk0_area       Check area    ;
    chk0_area(r,crp,"fao")     = lulc(r,crp)/1e+6;
    chk0_area(r,"crop","fao")  = sum(crp,chk0_area(r,crp,"fao"));
    chk0_area(r,crp,"Adage")   = q_land0(r,crp);
    chk0_area(r,"crop","Adage")= sum(crp,q_land0(r,crp));


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                       GHG emission data and process
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
parameter ghg0_10(r,ghg,i,v)             GHG emission by disaggregated sector and ghg in 2010 (mmt co2eq)
          co20_10(r,j,use,i,v)           CO2 emissions from fossil fuel combustion by type of use in 2010 for disaggregated sectors (mmt co2eq)
          ghgt0_10(r,ghg,i,v,t)          GHG emission by sector and ghg during 2010-2050 for disaggregated sectors (mmt co2eq)
          ghg_lulc0_10(r)                CO2 emission from land use change in 2010 (mmt co2eq)

          ghg0_10_(r,ghg,i,v)            GHG emission by aggregated sector and ghg in 2010 (mmt co2eq)
          co20_10_(r,j,use,i,v)          CO2 emissions from fossil fuel combustion by type of use in 2010 for aggregated sectors (mmt co2eq)
          ghgt0_10_(r,ghg,i,v,t)         GHG emission by sector and ghg during 2010-2050 for aggregated sectors (mmt co2eq)
          ghg_lulc0_10_(r)               CO2 emission from land use change in 2010 (mmt co2eq)

          ghg0(r,ghg,i,v)                GHG emission by sector and ghg in 2010 with transportation sectors aggregated (mmt co2eq)
          co20(r,j,use,i,v)              CO2 emissions from fossil fuel combustion by type of use in 2010 with transportation sectors aggregated (mmt co2eq)
          ghgt0(r,ghg,i,v,t)             GHG emission by sector and ghg during 2010-2050 with transportation sectors aggregated (mmt co2eq)
          ghgtott0(r,*,t)                Total GHG emissions by type in 2010 by region (mmt co2eq)

          ghg_lulc0(r)                   GHG emission from land use change in 2010 (mmt co2eq)
          ghg_lulctot0                   Total land use emission in the world in 2010 (mmt co2eq)

          ghg_target(r,t)                GHG emission target trend based on Copenhagen Agreement
          carbcnt_gcam(r,lu,cvar)        Carbon intensity by land type in 2010 from GCAM (metric ton co2eq per ha & area: million ha)
          emisfac_gcam(r,*,cvar)         CO2 emission factor from land use change from Govinda R. Timilsina, Simon Mevel "biofuels and Climate Change Mitigation: A CGE Analysis Incorporating Land-Use Change" from World Bank Policy research Working paper

          chk_ghg2(r,ghg,i)              Check crop ghg intensity

          co2_btu(r,i)                   CO2 emissions intensity by fossil fuel combustion per quad Btu (mmt co2eq per quad btu)
          co2_btu0(r,cgo,use,i)          CO2 emissions intensity by ff and sector (mmt co2 eq per quad btu)
          co200(r,j,use,i)               CO2 emissions by fossil fuels type by sector (mmt co2eq)
          co2tot0(r,i)                   CO2 emissions by fuel type (mmt co2eq)
          co2endow0(r)                   Endowment of total co2 emissions from fossil fuel (mmt co2eq) in 2010
          co2endow(r)                    Endowment of total co2 emissions from fossil fuel (mmt co2eq)

          ghgtot0(r,ghg)                 Total GHG emissions by type in 2010 (mmt co2eq)
          ghgendow0(r)                   Endowment of GHG emissions (mmt co2eq) in 2010
          ghgendow(r)                    Endowment of GHG emissions (mmt co2eq)
          ghg_btu                        GHG emission factor from fossil fuel production (mmt co2eq per quad btu)
          co2eqendow0(r)                 Endowment of all ghg gases excluding emissions from land use change (mmt co2eq)
          co2eqendow(r)                  Endowment of all ghg gases excluding emissions from land use change (mmt co2eq);
;

* Data were collected from EDGAR, International Energy Statistics, EPA inventory and World resource institue for Land use emissions and other sources
*   edgar: emission database for global atmospheric research: http://edgar.jrc.ec.europa.eu/datasets_list.php?v=42FT2010
*   International Energy Statistics: http://www.eia.gov/cfapps/ipdbproject/IEDIndex3.cfm?tid=90&pid=44&aid=8
*                                    http://www.eia.gov/cfapps/ipdbproject/IEDIndex3.cfm?tid=91&pid=46&aid=31#
*   World resource institute: http://cait2.wri.org/wri/Country GHG Emissions?indicator=Total GHG Emissions Excluding LUCF&indicator=Total GHG Emissions Including LUCF&year=2010
*   Emission factor for land use change: Govinda R. Timilsina, Simon Mevel, "Biofuels and Climate Change Mitigation: A CGE Analysis Incorporating Land-Use Change" Environmental and Resource Economics volume 55, pages119 (2013)
$gdxin '.\data\data4_ghg.gdx'
$load ghg0_10=ghg0 co20_10=co20  ghgt0_10=ghgt ghg_lulc0_10=ghg_lulc ghg_target carbcnt_gcam   emisfac_gcam

* Turn off co2 emissions from agri, liv and fors as it may include emissions from natural fires
    ghgt0_10(r,"co2",agr,"new",t) = 0;
    ghg0_10(r,"co2",agr,v)        = 0;
    ghgt0_10(r,"co2",agr,v,t)     = 0;

* Fix regions and sectors where the emissions are too large to cause negative input if ghg is priced, then 0.5 is used to scale emissions down.
    ghgt0_10(r,ghg,crp,"new",t)   = 0.5*ghgt0_10(r,ghg,crp,"new",t);

* Split emissions for electricity generation by technology
* Electricity related non-CO2 ghg emission is only for SF6, which is linked to transmission
* so the split is based on physical quantity of generation
    ghgt0_10(r,ghg,i,v,t)$(ghgt0_10(r,ghg,"ele",v,t) and gentype(i) and not conv(i))
           = ghgt0_10(r,ghg,"ele",v,t)*elegen0_10(r,i)/sum(ii$(not conv(ii)),elegen0_10(r,ii));
    ghgt0_10(r,ghg,"ele",v,t)          = 0;
    ghg0_10(r,ghg,i,v)                 = ghgt0_10(r,ghg,i,v,"2010");

* Split CO2 emissions from energy usage for electricity generation instead of electricity generated.
* Assume 90% of emissions are captured in CCS generation
    co20_10(r,e,"fuel",i,v)$(    gentype(i)
                             and btu0_10(r,e,"fuel",i,"2010")*eleemisf(e,i)
                             and sum(elefuelmap(e,ii)$(not conv(ii)),btu0_10(r,e,"fuel",ii,"2010")*eleemisf(e,i)))
           = sum(elefuelmap(e,i), co20_10(r,e,"fuel","conv",v))
                                 *btu0_10(r,e,"fuel",i,"2010")*eleemisf(e,i)
                                 /sum(elefuelmap(e,ii)$(not conv(ii)),btu0_10(r,e,"fuel",ii,"2010")*eleemisf(e,i));

    co20_10(r,j,use,"conv",v)          = 0;

* Assign emissions to aggregated sectors
    ghgt0_10_(r,ghg,ii,v,t) = sum(mapSector(ii,i), ghgt0_10(r,ghg,i,v,t));
    ghg0_10_(r,ghg,ii,v)    = sum(mapSector(ii,i), ghg0_10(r,ghg,i,v));
    co20_10_(r,jj,use,ii,v) = sum((mapSector(ii,i),mapGSector(jj,j)),co20_10(r,j,use,i,v));

    ghg0(r,ghg,ii,v)        = ghg0_10_(r,ghg,ii,v)   ;
    co20(r,jj,use,ii,v)     = co20_10_(r,jj,use,ii,v);
    ghgt0(r,ghg,ii,v,t)     = ghgt0_10_(r,ghg,ii,v,t);

    ghgtott0(r,ghg,t)       = sum(ii,ghgt0(r,ghg,ii,"new",t));
    ghgtott0(r,"All",t )    = sum((ghg,ii),ghgt0(r,ghg,ii,"new",t));

    ghg_lulc0_10_(r)        = ghg_lulc0_10(r);
    ghg_lulc0(r)            = ghg_lulc0_10(r) ;
    ghg_lulctot0            = sum(r, ghg_lulc0(r));

    ghg_target(r,"2010")    = 1;

    chk_ghg2(r,ghg,crp)$q_land0(r,crp)=ghgt0(r,ghg,crp,"new","2010")/q_land0(r,crp);

display co20_10,ghg0,co20,ghgt0_10,ghg_lulc0, ghgtott0, chk_ghg2;



    co200(r,cgo,use,i)  $(not fdst(use)) = co20(r,cgo,use,i,"new");
    co2tot0(r,cgo)    = sum((use,i),co20(r,cgo,use,i,"new"));
    co2endow0(r)      = sum((cgo,use,i),co20(r,cgo,use,i,"new"));
    co2endow(r)       = co2endow0(r);

    co2_btu(r,cgo)$sum((use,i)$(not fdst(use) and not conv(i)), btu0(r,cgo,use,i))
        = co2tot0(r,cgo)/ sum((use,i)$(not fdst(use)  and not conv(i)), btu0(r,cgo,use,i)) ;

    co2_btu0(r,cgo,use,i)$(not fdst(use) and btu0(r,cgo,use,i))= co200(r,cgo,use,i)/btu0(r,cgo,use,i);
    co2_btu0(r,cgo,use,i)$(sameas(use,"fuel") and advee(i))    = sum(eleemismap(j,i),co2_btu0(r,cgo,use,j)*eleemisf(cgo,i));

    ghgtot0(r,ghg)= sum(i, ghg0(r,ghg,i,"new"));
    ghgendow0(r)  = sum(ghg,ghgtot0(r,ghg));
    ghgendow(r)   = ghgendow0(r);

    ghg_btu(r,ghg,ff)$prod0_10_(r,ff,"2010") = ghg0(r,ghg,ff,"new")/prod0_10_(r,ff,"2010") ;
    co2eqendow0(r) = ghgendow(r) + co2endow(r);
    co2eqendow(r)  = co2eqendow0(r);

display co2tot0,co2endow, ghg0, co20,ghgendow, co200,ghgtot0,co2_btu, co2_btu0, ghg_btu;

parameter   re_ghg0     Report ghg emission by gas in 2010 (mmt co2eq);
* Emissions from lulc is not included here
   re_ghg0(r,i,ghg)       = ghg0(r,ghg,i,"new");
   re_ghg0(r,i,"co2")     = ghg0(r,"co2",i,"new")+ sum((cgo,use),co200(r,cgo,use,i)) ;
   re_ghg0(r,"ele",ghg)   = re_ghg0(r,"ele",ghg) + re_ghg0(r,"conv",ghg);
   re_ghg0(r,"conv",ghg)  = 0;
   re_ghg0(r,"Total",ghg) = sum(i,re_ghg0(r,i,ghg));
*display re_ghg0;


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                     CO2 emissions from land use change
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
parameter  carbcnt_eppa    Carbon intensity from land in EPPA (metric ton co2eq per ha)
           chk0_carbcnt    Check carbon intensity from EPPA and GCAM (metric ton co2eq per ha);
* Convert from metric ton c per ha to metric ton co2eq per ha)
* 44/12 is to convert from c to co2; 10 is for the unit conversion from GCAM to ADAGE
    carbcnt_eppa(r,lu) = carbcnt(r,lu)*44/12;
    carbcnt_gcam(r,lu,"vegc") = 10*carbcnt_gcam(r,lu,"vegc");
    carbcnt_gcam(r,lu,"soilc")= 10*carbcnt_gcam(r,lu,"soilc");

    chk0_carbcnt(r,lu,"GCAM") = carbcnt_gcam(r,lu,"vegc") + carbcnt_gcam(r,lu,"soilc");
    chk0_carbcnt(r,lu,"EPPA") = carbcnt_eppa(r,lu);

    carbcnt(r,lu) = 0;
    carbcnt(r,lu) =  carbcnt_gcam(r,lu,"vegc")*emisfac_gcam(r,lu,"vegc")
                   + carbcnt_gcam(r,lu,"soilc")*emisfac_gcam(r,lu,"soilc");

display chk0_carbcnt,carbcnt;
option  carbcnt_gcam:1:1:2,emisfac_gcam:2:1:2
display carbcnt_eppa,carbcnt_gcam, emisfac_gcam,carbcnt;

parameter  difcarb(r,lu,lu_)         Difference in co2 between two vegetation types (metric ton of co2eq per ha)
           debtcarb(r,lu,lu_)        Co2 debt (million metric tons of co2eq per million ha)
           credcarb(r,lu,lu_)        Co2 credit (million metric tons of co2eq per million ha)
           debtcarb0(r,lu,lu_)       Co2 debt (million metric tons of co2eq per million ha)
           credcarb0(r,lu,lu_)       Co2 credit (million metric tons of co2eq per million ha) ;

* For land abandonment or reforestation/afforestation, consider carbon is accumulated over 20 years to reach the maximum capacity

* The following settings are for sensitivity anlysis. The default is f_case=2
*   f_case=1: original difcarb to use
*   f_case=2: emission factor is reduced by 30% for non-cropland in order to calculate difcarb
*   f_case=3; emission factor is reduced by 30% for non-cropland type and some regions are further adjusted to calculate difcarb
*   f_case=4: regional emisisons are further adjusted to ensure simulated emission in 2015 close to the luc emission in 2010 in ghg_lulc0 from World resource institue

*Case 1:
if (f_case=1,
    difcarb(r,lu,lu_)$f_luc(r,lu,lu_)   = (carbcnt(r,lu_) - carbcnt(r,lu)); );

*Case 2:
if (f_case=2,
     carbcnt(r,lu)$(not sameas(lu,"crop"))= 0.70* carbcnt(r,lu);
     difcarb(r,lu,lu_)$f_luc(r,lu,lu_)    = (carbcnt(r,lu_) - carbcnt(r,lu));  );

*Case3:
if (f_case=3,
      carbcnt(r,lu)$(not sameas(lu,"crop") and not num(r))= 0.70*carbcnt(r,lu);
      difcarb(r,lu,lu_)$f_luc(r,lu,lu_)   = (carbcnt(r,lu_) - carbcnt(r,lu));
      difcarb(r,lu,lu_)= difcarb(r,lu,lu_)/3;     );

*Case 4:
* Regional emisisons are further adjusted to ensure simulated emission in 2015 close to the luc emission in 2010 in ghg_lulc0 from World resource institue
if (f_case=4,
     carbcnt(r,lu)$(not sameas(lu,"crop"))=0.70* carbcnt(r,lu);
     difcarb(r,lu,lu_)$f_luc(r,lu,lu_)   = (carbcnt(r,lu_) - carbcnt(r,lu));
     difcarb(r,lu,lu_)$(sameas(r,"EUR") or sameas(r,"ROW") or sameas(r,"BRA")  or sameas(r,"XAS"))= difcarb(r,lu,lu_)/12;
     difcarb(r,lu,lu_)$(sameas(r,"XLM") )= difcarb(r,lu,lu_)/15;
     difcarb(r,lu,lu_)$(sameas(r,"USA") or sameas(r,"AFR") or sameas(r,"CHN") )= difcarb(r,lu,lu_)/8;
    );

     debtcarb(r,lu,lu_)$(difcarb(r,lu,lu_) gt 0)   =   difcarb(r,lu,lu_);
     credcarb(r,lu,lu_)$(difcarb(r,lu,lu_) lt 0)   =  -difcarb(r,lu,lu_);

parameter chk0_lucghg(r,lu,lu_,*)     Land conversion block comparison;
   chk0_lucghg(r,lu,lu_,"rent")$f_luc(r,lu,lu_)     =  rent_r0(r,lu,lu_) ;
   chk0_lucghg(r,lu,lu_,"debtcarb")$f_luc(r,lu,lu_) =  debtcarb(r,lu,lu_)/1000;
   chk0_lucghg(r,lu,lu_,"credcarb")$f_luc(r,lu,lu_) =  credcarb(r,lu,lu_)/1000;
option  chk0_lucghg:3:3:1
*display chk0_lucghg;

Table gaselas(*,ghg)        Elasticities of substitution from forward-looking ADAGE
               CO2        CH4         N2O        HFC        PFC         SF6
      RES        0        0.21
      COL        0        0.40
      ELE        0        0.11                              0.16
      GAS        0        0.13
      OIL        0        0.10
      AGR        0        0.05        0.07
      EIM        0        0.11        0.70        0.4       0.12        0.60
      MAN        0        0.11                    0.4       0.14
      SRV        0
;
    gaselas(agr,ghg)  = gaselas("AGR",ghg);
    gaselas("hh",ghg) = gaselas("res",ghg);
    gaselas(i,ghg)    = gaselas(i,ghg) ;

parameter    chk0_elas   Check sectors with ghg emissions  ;
     chk0_elas(i,ghg)$(sum(r,ghg0(r,ghg,i,"new"))) =1;

parameter
        CO2_elas       CO2 elasticity
        CH4_elas       Methane elasticity
        N2O_elas       N2O elasticity
        HFC_elas       HFC elasticity
        PFC_elas       PFC elasticity
        SF6_elas       SF6 elasticity ;

    CO2_elas(r,i)    = gaselas(i,"CO2");
    CH4_elas(r,i)    = gaselas(i,"CH4");
    N2O_elas(r,i)    = gaselas(i,"N2O");
    HFC_elas(r,i)    = gaselas(i,"HFC");
    PFC_elas(r,i)    = gaselas(i,"PFC");
    SF6_elas(r,i)    = gaselas(i,"SF6");
    CO2_elas(r,"hh") = gaselas("RES","CO2");
    CH4_elas(r,"hh") = gaselas("RES","CH4");
    N2O_elas(r,"hh") = gaselas("RES","N2O");

* Prepare air pollutant emission data for the model
parameter    ap0(r,ap,i)          Air pollutant in edgar in 2010 by sector (1000 metric ton)
             aptot0(r,ap)         Total  air pollutant  emissions by type in 2010 (1000 metric ton);

$gdxin  '.\data\data5_pollutant.gdx'
$load  ap0

    aptot0(r,ap)=sum(i,  ap0(r,ap,i));

table       co2capt(*,t)          CO2 emission from electricity generation constraint starting in 2020 (mmt co2e)
* This is the CO2 emission constraint for clean power plan from EPA
        2020       2025        2030        2035        2040        2045        2050
ELE    2136.61  1877.68     1618.75     1618.75     1618.75     1618.75     1618.75
;

parameter   co2ele(r)             Simulated co2 emission from regulation
            f_co2ele(r)           Factor to adjust co2 emission endowment from electricity generation
            f_co2eleT(r,t)        Factor to adjust co2 emission endowment from electricity generation over time    ;

f_co2ele(r)    = 0;
f_co2eleT(r,t) = 0;

*End of ghg emission data for the model
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                               Elasticities
**--- Elasticities and Other Parameters taken from forward-looking ADAGE or EPPA ---**
parameter
        eva_elas(i)             Elasticity between energy and value added (non-electricity)
        enoe_elas(*)            Elasticity between electricity and non-electric energy
        en_elas(*)              Elasticity among types of fossil fuels
        erva_elas(*)            Elasticity between resource-energy-material bundle and value added (agriculture only)
        er_elas(r,*)            Elasticity between resource input and energy-material bundle (agriculture only)
        ae_elas(*)              Elasticity between materials and energy (agriculture only)

        cog_elas(i)             Elasticity between gas and coal-oil in electricity
        co_elas(i)              Elasticity between coal and oil in electricity
        mm_elas(i)              Elasticity among import sources
        dm_elas(i)              Elasticity between domestic goods and imports

        ele_elas                Elasticity between electricity generated from technology
        esub_nr(r,i)            Elasticity between natural resources and other inputs
        pref_nr(r,i)            Reference price for natural resources
        esub_gen(r,i)           Elasticity between resources and other inputs in electricity generation
        pref_gen(r,i)           Reference price for electricity generation resources
        esub_bio(r,i)           Elasticity between biofuel resource and other inputs
        pref_bio(r,i)           Reference price for biofuel resource


        shagp(i,t)              Factor to adjust elasticity of energy_value added bundle
        eva_elast(i,t)          Elasticity between energy and value added (non-electricity)
        esub_flnd               Elasticity of fixed factor of land input in land conversion

        ldv_elas                Elasticity between bioenergy and gasoline in ldv sector
        hdv_elas                Elasticity between bioenergy and gasoline in hdv sector ;

    esub_nr(r,ff)      = 0;
    pref_nr(r,ff)      = 1;

    esub_bio(r,bio)    = 0;
    pref_bio(r,bio)    = 1;

    esub_gen(r,gentype)= 0.1 ;
    pref_gen(r,i)      = 1;

    ele_elas           = 1;

    eva_elas("conv")   = 0.4;
    eva_elas(s)        = 1.0;
    eva_elas(s)$trnv(s)= 0.1;

    ae_elas(s)         = 0.3;
    ae_elas(lu)        = 0.3;

    enoe_elas(s)       = 0.5;
    enoe_elas(lu)      = 0.5;
    enoe_elas(s)$trnv(s)= 0.1;

    en_elas(s)         = 1.0;
    en_elas(lu)        = 1.0;
    en_elas("auto")    = 0.1;
    en_elas(hdv)       = 0.1;

    er_elas(r,lu)      = 0.6;
    er_elas(r,s)       = 0.6;
    er_elas('bra','gron')   = 0.1;
    er_elas("usa","wht")    = 0.2;
    er_elas("usa","corn")   = 0.6;
    er_elas("usa","ocr")    = 0.7;

    erva_elas(s)       = 1.0;
    erva_elas(lu)      = 1.0;

    cog_elas(conv)     = 1;
    co_elas(conv)      = 0.3;

    mm_elas(i)         = 5;
    mm_elas(agr)       = 0.5;
    mm_elas("ele")     = 0.5;

    dm_elas(i)         = 4;
    dm_elas(agr)       = 0.3;
    dm_elas("ele")     = 0.3;

    shagp(i,t)$(not trnv(i))= 0.5* eva_elas(i)/(card(t)-1);
    eva_elast(i,t)$(not trnv(i))= eva_elas(i)+ shagp(i,t)*(ord(t)-1);

    esub_flnd('crop')  = 0.26;
    esub_flnd('liv')   = 0.30;
    esub_flnd('frs')   = 0.15;
    esub_flnd(nat)     = 0.15;

    ldv_elas           = 0.25 ;
    hdv_elas           = 0.25 ;

**--- set resource supply elasticities ---**
parameter
        eta_nr          Supply elasticity for natural resources
        eta_rnw         Supply elasticity for renewable generation
        shr_nr          Share of resource in natural resource production
        shr_rnw         Share of resource in renewable generation
        e_nr            Supply elasticity for natural resources
        e_rnw           Supply elasticity for renewable generation
        p_nr            Price natural resources
        p_rnw           Price elasticity for renewable generation   ;

    eta_nr(r,ff)       = 2;
    eta_rnw(r,rnw)     = 1;


**----- Add Leisure Time and Balance Incomes -----**
parameter
        cl0(r,i)                Total consumption plus leisure time (welfare)
        sigma_cl                Elasticity of substitution between consumption and leisure
        leis0(r,hh)             Leisure time
        lse_comp                Static compensated labor supply elasticity      /0.40/
        lse_uncomp              Static uncompensated labor supply elasticity    /0.15/
        theta_l                 Share of leisure in utility
        bopdef0(r,hh)           Balance of payments deficit in 2010
        bopdeft0(r,hh,t)        Balance of payments deficit in 2010~2050    ;

    theta_l(r,hh)     = lse_comp - lse_uncomp;
    leis0(r,hh)       = c0(r,hh)   * (theta_l(r,hh)/(1-theta_l(r,hh)));
    le0(r,hh)         = le0_10_(r,hh,"2010")   + leis0(r,hh)  ;
    sigma_cl(r,hh)    = ( lse_comp/(1-theta_l(r,hh)) ) * ( (le0(r,hh)   - leis0(r,hh)  ) / leis0(r,hh)  );

    c0(r,"hh") =   sum(g$(not trn(g)),cd0(r,"hh",g)*(1+tc(r,g)))
                 + sum(trn, cd0(r,"hh",trn))
                 + cd0(r,"hh","house");

    cl0(r,hh) = c0(r,hh)   + leis0(r,hh)  ;
display cl0;

**---- Net Crude Oil Trade ----**
* redefine CRU trade in net terms since it is assumed to be homogeneous good (avoid big trade swings)
* (don't have tariffs/transport costs for CRU at moment)
*  turning off trade adjustments for crude
$ontext
    x0(r,"CRU","ftrd")      = 0;
    m0(r,"CRU","ftrd")      = 0;
    x0(r,"CRU","ftrd")      =  max( (y0(r,"CRU","new")   -ed0(r,"CRU","feed","OIL","new")  ), 0);
    m0(r,"CRU","ftrd")      = -min( (y0(r,"CRU","new")   -ed0(r,"CRU","feed","OIL","new")  ), 0);

    ex0_btu(r,"cru") = 0;
    em0_btu(r,"cru") = 0;
    ex0_btu(r,"cru") =  max( (prod0(r,"CRU")   -sum((use,i),btu0(r,"cru",use,i)) ), 0);
    em0_btu(r,"cru") = -min( (prod0(r,"CRU")   -sum((use,i),btu0(r,"cru",use,i))     ), 0);
$offtext

**CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*             ----- Extant / Existing Production -----
parameter
        clay(*,*)               Percentage of capital stock that is fixed;

* Clay portion of putty-clay capital
    clay(r,s)$(y0(r,s,"new") and not agr(s))  = 0.5;
    clay(r,"ele")           = 0;
    clay(r,gentype)         = 5/6;
    clay(r,ff)              = 0;
    clay(r,hh)              = 0.5;
* For transportation, consider the life of vehicle: ldv: 15 years; RodF and RodP: 30 year
    clay(r,"auto")          = 2/3;
    clay(r,autoafv)         = 2/3;
    clay(r,hdv)$(y0(r,hdv,"new"))  = 5/6;
    clay(r,hdvafv)          = 5/6;

    y0(r,i,"extant")$clay(r,i)                    = y0(r,i,"new")  ;
    y0(r,"omel","extant")$clay(r,"vol")           = y0(r,"omel","new")  ;
    y0(r,"ddgs","extant")$sum(ceth,clay(r,ceth))  = y0(r,"ddgs","new")  ;

    ed0(r,e,use,i,"extant")$clay(r,i)             = ed0(r,e,use,i,"new")  ;
    id0(r,j,i,"extant")$clay(r,i)                 = id0(r,j,i,"new")  ;
    ld0(r,i,"extant")$clay(r,i)                   = ld0(r,i,"new")  ;
    kd0(r,k,i,"extant")$clay(r,i)                 = kd0(r,k,i,"new")  ;
    rd0(r,i,"extant")$sum(num,clay(num,i))        = rd0(r,i,"new")  ;
    hkd0(r,i,"extant")$clay(r,i)                  = hkd0(r,i,"new")  ;
    lnd0(r,i,"extant")$clay(r,i)                  = lnd0(r,i,"new")  ;

    ghg0(r,ghg,i,"extant")$clay(r,i)              = ghg0(r,ghg,i,"new");
    co20(r,j,use,i,"extant")$clay(r,i)            = co20(r,j,use,i,"new");
    ghgt0(r,ghg,i,"extant",t)$clay(r,i)           = ghgt0(r,ghg,i,"new",t);
    ghgt0(r,ghg,"ele","extant",t)                 = ghgt0(r,ghg,"ele","new",t);

    house0(r,i,"extant")$clay(r,i)                = house0(r,i,"new")  ;
    fuel0(r,"extant")$clay(r,"auto")              = fuel0(r,"new")  ;
    oev_valu0(r,s,"extant")                       = oev_valu0(r,s,"new");

    y0_10_(r,i,"extant",'2010')$clay(r,i)                    = y0(r,i,"extant")  ;
    y0_10_(r,"omel","extant",'2010')$clay(r,"vol")           = y0(r,"omel","extant")  ;
    y0_10_(r,"ddgs","extant",'2010')$sum(ceth,clay(r,ceth))  = y0(r,"ddgs","extant")  ;
    ed0_10_(r,e,use,i,"extant",'2010')$clay(r,i)             = ed0(r,e,use,i,"extant")  ;
    id0_10_(r,j,i,"extant",'2010')$clay(r,i)                 = id0(r,j,i,"extant")  ;
    ld0_10_(r,i,"extant",'2010')$clay(r,i)                   = ld0(r,i,"extant")  ;
    kd0_10_(r,k,i,"extant",'2010')$clay(r,i)                 = kd0(r,k,i,"extant")  ;
    rd0_10_(r,i,"extant",'2010')$sum(num,clay(num,i))        = rd0(r,i,"extant")  ;
    hkd0_10_(r,i,"extant",'2010')$clay(r,i)                  = hkd0(r,i,"extant")  ;
    lnd0_10_(r,i,"extant",'2010')$clay(r,i)                  = lnd0(r,i,"extant")  ;
    house0_10_(r,i,"extant",'2010')$clay(r,i)                = house0(r,i,"extant")  ;
    fuel0_10_(r,"extant",'2010')                             = fuel0(r,"extant")  ;

display clay,y0,rnw0,kd0_10;

*CCCCCCCCCCCCCCCCCCCCCCCCC Second part for Electricity generation modification  CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
    kd0(r,"va",i,v)$(y0_10(r,i,v,"2010") and extant(v) and (convrnw(i) or advee(i)) )
           = kd0_10(r,"va",i,v,"2010")+ rnw0_10(r,i,"new","2010")/(1+tk(r,"va",i));

    rnw0(r,i,v)$(y0_10(r,i,v,"2010") and new(v) and (convi(i) or rnw(i) or advee(i)))
           = 0.01*y0_10(r,i,v,"2010")    ;

    rnw0(r,i,v)$(y0_10(r,i,v,"2010") and extant(v) and (convi(i) or rnw(i) or advee(i)) )
           = 0    ;

    kd0(r,"va",i,v)$(y0(r,i,v) and  (convi(i) or rnw(i) or advee(i) ))
           =(   y0(r,i,v)* (1-ty(r,i))
             - sum(e, ed0(r,e,"fuel",i,v))
             - sum(g, id0(r,g,i,v)*(1+ti(r,g,i)))
             - ld0(r,i,v)*(1+tl(r,i))
             - rnw0(r,i,v))
            / (1+tk(r,"va",i));

    chk0_prod(r,i,v,'in')$(y0(r,i,v)   and gentype(i) )
        =   sum(e,ed0(r,e,"fuel",i,v))
          + sum(g,id0(r,g,i,v)*(1+ti(r,g,i)))
          + ld0(r,i,v)*(1+tl(r,i))
          + kd0(r,"va",i,v)*(1+tk(r,"va",i))
          + rnw0(r,i,v)  ;

    chk0_prod(r,i,v,'out')$(y0(r,i,v)   and gentype(i) )
         = y0(r,i,v)*(1-ty(r,i));
    chk0_prod(r,i,v,'bal') =round((chk0_prod(r,i,v,'out')-chk0_prod(r,i,v,'in')),5);
display chk0_prod;

parameter afactor(r,*)   Value to make pcl in balance
* this is the marginal value from model runs in pcl
/   USA.HH           33.1254
    BRA.HH           -0.9367
    CHN.HH           -0.5955
    EUR.HH           -0.6720
    XLM.HH           -2.2258
    XAS.HH           -3.8629
    AFR.HH           -4.6590
    ROW.HH          -20.1735
/ ;

* Implied income transfers among regions
    bopdef0(r,hh)
        = cl0(r,hh)
        + sum(k, inv0(r,k)  )
        + lstax(r,hh)
        - le0(r,hh)
        - land0(r)
        - sum(vnum, rd0(r,"frs",vnum)  )
        - sum((s,vnum), hkd0(r,s,vnum)  )
        - sum((e,v), rd0(r,e,v)  )
        - sum((gentype,v), rnw0(r,gentype,v)  )
        - sum((k,i,v)$(not vnum(v)), kd0(r,k,i,v)  *clay(r,i))
        - sum((k,i,vnum), kd0(r,k,i,vnum)  *(1-clay(r,i)))
        + afactor(r,"hh") ;


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
**         Conversion Factors between monetary accounts and physical accounts
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
parameter
        btua_conv       Energy conversion between dollar to btu in Armington (quad btu per billion dollars)
        btuprod_conv    Energy conversion between dollar to btu in production side (quad btu per billion dollars)
        btu_conv        Quad Btu (10**15 btu) per billion dollars in energy retail market
        btuim_conv      Energy conversion between dollar to btu in import side (quad btu per billion dollars)
        btuex_conv      Energy conversion between dollar to btu in export side (quad btu per billion dollars)
        btuen_conv      Energy conversion between dollar to btu in bilateral trade side (quad btu per billion dollars)
  ;

* Conversion factor for production side
    btuprod_conv(r,i)$y0(r,i,"new") = prod0(r,i)/y0(r,i,"new");

* Conversion factor for cobd is adjusted to calibrate exogenous yield to match EPA assumption
    btuprod_conv(r,"cobd")         = btuprod_conv(r,"sybd");

    btuprod_conv(r,advbio)         = btuprod_conv(r,"ceth");
    btuprod_conv(r,advbio)$(btuprod_conv(r,advbio)=0)= btuprod_conv(r,"scet");
    btuprod_conv(r,advbio)$(btuprod_conv(r,advbio)=0)= btuprod_conv(r,"weth");
    btuprod_conv("afr",advbio)$(btuprod_conv("AFR",advbio)=0)= btuprod_conv("USA",advbio);

* Conversion factor for wholesale side: note here a0 is equal to sum of ewhl0
    btua_conv(r,e)$a0_10(r,e,"2010")
       = sum((use,i)$(not conv(i)),btu0_10(r,e,use,i,"2010"))/a0_10(r,e,"2010");
** for cobd, advbio, assume they are equal to producer price
    btua_conv(r,e)$(btua_conv(r,e)=0 and btuprod_conv(r,e))= btuprod_conv(r,e);


* Conversion factor for retail side: disaggregated sectors such as RODF, RODP
    btu_conv(r,e,use,i)$sum(vnum(v), ed0_10(r,e,use,i,v,"2010"))
       = btu0_10(r,e,use,i,"2010") / sum(vnum(v), ed0_10(r,e,use,i,v,"2010"));

* Conversion factor for retail side: aggregated sectors such as OTRN: weighted average from all transportation other than Auto
    btu_conv(r,e,use,i)$sum(vnum(v), ed0(r,e,use,i,v))
       = btu0(r,e,use,i) / sum(vnum(v), ed0(r,e,use,i,v));

    btu_conv(r,e,use,"house") =  btu_conv(r,e,use,"hh") ;

* Conversion factor for retail side: electricity generation
    btu_conv(r,e,use,gentype)$sum(vnum(v), elegen_edt0(r,e,use,gentype,v,"2010"))
       = btu0(r,e,use,gentype) / sum(vnum(v), elegen_edt0(r,e,use,gentype,v,"2010"));
    btu_conv(r,e,use,gentype)$(btu_conv(r,e,use,gentype)=0)
       = sum(elefuelmap(e,gentype),btu_conv(r,e,use,"conv"));

* Conversion factor for retail side: energy used in AFV:
    btu_conv(r,e,"fuel",Autoi)$(oil(e) or bio(e))  = btu_conv(r,e,"fuel","auto");

* Allow conversion factors for AFVs same as their conventional technology instead of OTRN or other sectors
    btu_conv(r,e,"fuel",hdv)$(btu_conv(r,e,"fuel",hdv)=0 and bio(e))= btu_conv(r,e,"fuel","auto");
    btu_conv(r,e,"fuel",rodpi)= btu_conv(r,e,"fuel","RodP");
    btu_conv(r,e,"fuel",rodfi)= btu_conv(r,e,"fuel","RodF");

* Assign Armington energy price to  energy used in transportation which is not available in AFV (note input price is pa(r,e)
    btu_conv(r,e,"fuel",Afv)$(ceg(e) )   = btua_conv(r,e);

* Allow biofuel used in hdvi
    btu_conv(r,e,"fuel",i)$((bioe(e) or ad(e)) and (auto(i) or hdvi(i)))= btu_conv(r,e,"fuel","auto");

* If new energy is added in biofuel production (example: gas in ceth and sybd later shown in corncoprod_cost0 and soybcoprod_cost0)
    btu_conv(r,e,"fuel",bio)$(btu_conv(r,e,"fuel",bio)=0)      = btua_conv(r,e);
    btu_conv(r,e,"fuel",advbio)$(btu_conv(r,e,"fuel",advbio)=0)= btua_conv(r,e);

    btu_conv(r,advbio,use,i)$(oev(i) or bioafv(i) or trnv(i))  = BTU_conv(r,"ceth",use,"auto");
    btu_conv(r,advbio,use,i)$((oev(i) or bioafv(i) or trnv(i)) and btu_conv(r,advbio,use,i)=0) = BTU_conv(r,"scet",use,"auto");
    btu_conv(r,advbio,use,i)$((oev(i) or bioafv(i) or trnv(i)) and btu_conv(r,advbio,use,i)=0) = BTU_conv(r,"weth",use,"auto");
    btu_conv(r,"Albd",use,i)$(oev(i) or bioafv(i) or trnv(i))   = BTU_conv(r,"sybd",use,"auto");
    btu_conv(r,"Albd",use,i)$((oev(i) or bioafv(i) or trnv(i)) and btu_conv(r,"Albd",use,i)=0) = BTU_conv(r,"plbd",use,"auto");
    btu_conv("afr",advbio,"fuel",i)$((oev(i) or bioafv(i) or trnv(i)) and btu_conv("afr",advbio,"fuel",i)=0 ) = BTU_conv("afr","oil","fuel","auto");
    btu_conv("afr",advbio,"fuel",i)$((oev(i) or bioafv(i) or trnv(i)) and btu_conv("afr",advbio,"fuel",i)=0 ) = sum(maptrn(j,i),BTU_conv("afr","oil","fuel",j));

    btu_conv(r,e,"fuel",i)$(bioe(e) and trni(i))= btu_conv(r,e,"fuel","auto");
    btu_conv(r,advbio,"fuel",i)$(trni(i))= btu_conv(r,advbio,"fuel","auto");

    btu_conv(r,"cobd","fuel",trni) = btua_conv(r,"cobd");
    btu_conv(r,"cobd","fuel",i)$(oev(i) or bioafv(i))  = btua_conv(r,"cobd");

    btuim_conv(r,e)$m0(r,e,"ftrd") = em0_btu(r,e)/m0(r,e,"ftrd");
    btuex_conv(r,e)$x0(r,e,"ftrd") = ex0_btu(r,e)/x0(r,e,"ftrd");
    btuen_conv(r,rr,e)$n0(r,rr,e)  = en0_btu(r,rr,e)/n0(r,rr,e);

option  btu_conv:3:3:1
display btua_conv,btu_conv,btua_conv,btuprod_conv;


* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
parameter frs_shr    Forest production input share;
    frs_shr(r,"Y0") = y0(r,"frs","new");
    frs_shr(r,"K0")$y0(r,"frs","new") = (sum(k,kd0(r,k,"frs","new"))+hkd0(r,"frs","new"))/ y0(r,"frs","new");
    frs_shr(r,"L0")$y0(r,"frs","new") = ld0(r,"frs","new")/y0(r,"frs","new");
    frs_shr(r,"id_notrn0")$y0(r,"frs","new") = sum(g$(not trn(g)), id0(r,g,"frs","new"))/ y0(r,"frs","new");
    frs_shr(r,"id_trn0")$y0(r,"frs","new")   =  sum(g$(trn(g)), id0(r,g,"frs","new"))/ y0(r,"frs","new");
    frs_shr(r,"ed0")$y0(r,"frs","new")       = sum((e,use), ed0(r,e,use,"frs","new"))/ y0(r,"frs","new");
    frs_shr(r,"lnd0")$y0(r,"frs","new")      = lnd0(r,"frs","new")/ y0(r,"frs","new");


parameter lnd_trend(r,*,t)      Trend of land productivity from GTAP;
    lnd_trend(r,lu,t)   = npp_trend(r,lu,t);

* assume cropland productivity increase by 1% annually instead of 0.5%
    lnd_trend(r,"crop",t)$(ord(t)<=1)=1;

loop(t$(ord(t)>=1),lnd_trend(r,"crop",t+1)$(ord(t)>=1)=lnd_trend(r,"crop",t)*(1+0.01)**5;);

display lnd_trend;

parameter bio_convert(r,*)     Biofuel converter (gallon per dry tonne) ;
$ontext
** Based on information provided by EPA OTAQ, the conversion factors are as follows:
Corn/Grain/Other Ethanol:   =  2.71 gallons per bushel
                            = 20.66 lbs per gallon

Soy Oil Biodiesel:          = 131.58 gallons per thousand lbs of soy oil
                            = 7.6 lbs of soybean oil per gallon of biodiesel

Sugarcane Ethanol:          = 153.57 gallons per dry metric tonne of sugar
                            = 14.36 lbs of sugar (dry) per gallon

Switchgrass Ethanol:        = 81.2 gallons per dry tonne of switchgrass
                            = 24.63 lbs (dry) per gallon

** Here is the conversion from bushel to tonne for variety of ag products
*Source: http://www.grains.org/index.php/buying-selling/conversion-factors
 Conversion Factors
BARLEY (48 pound per bushel)
Bushels Metric equivalent
1 bushel = .024 short ton
1 bushel = .021772 metric ton
1 bushel = .021429 long ton

Metric equivalent bushels
1 short ton = 41.667 bushels
1 metric ton = 45.9296 bushels
1 long ton = 46.667 bushels

CORN & SORGHUM (56 pound bushel)
Bushels Metric equivalent
1 bushel = .028 short ton
1 bushel = .0254 metric ton
1 bushel = .025 long ton

Metric equivalent bushels
1 short ton = 35.714 bushels
1 metric ton = 39.368 bushels
1 long ton = 40.0 bushels

WHEAT & SOYBEANS (60 pound bushel)
Bushels Metric equivalent
1 bushel = .03 short ton
1 bushel = .0272155 metric ton
1 bushel = .0267857 long ton

Metric equivalent bushels
1 short ton = 33.333 bushels
1 metric ton = 36.7437 bushels
1 long ton = 37.333 bushels
$offtext
* assume : soybean contains around 19% soy oil by weight
*          sugarcane contains 12%~22% (assume 20%) of sugar by weight
* In Brazil, One hectare of sugar cane yields 4,000 litres of ethanol (1 litre=0.264172 gallon)
** The following are either from FASOM or consistent with FASOM
    bio_convert(r,"ceth") = 2.71 /.0254;
    bio_convert(r,"weth") = 2.56 /.0272155;
    bio_convert(r,"sybd") = 131.58/(1000/2204.62)*0.19;
    bio_convert(r,"scet") = 30.81;
    bio_convert(r,"sbet") = 30.81;
    bio_convert(r, advbio)= 81.2;

table  swge_new(t,*)      Switchgrass feedstock yield and conversion cost to biofuel over the time
* provided by Michael Shell from EPA during May 2017
       fdskyield         convyield            fdskcost      convcost
*      "dryton fdsk/ha"  "gal/dryton fdsk"    "$/gal swge"  "$/gal swge"
2010   15.00             70.90
2015   15.00             70.90
2020   15.46             70.90                1.0972        0.88
2025   16.24             70.90                1.0972        0.88
2030   17.07             73.78                1.0972        0.83
2035   17.94             76.78                1.0972        0.79
2040   18.86             79.90                1.0972        0.75
2045   19.82             83.15                1.0972        0.72
2050   20.83             86.53                1.0972        0.68
;

Table swge_newnew(*,t)    SWGE feedstock yield over time (dry tons per ha)
* Data is provided by Michael Shell from EPA on 2017-08-02. This is the national average switchgrass yield from BTS2016
* Origional file is saved here: F:\Model\ADAGE\ADAGE_8r_agfrsres_tran_Link_20170727_CI_swgesybd\data\BTS2016 National Avg Switchgrass Yields_for ADAGE.xlsx
               2015            2020            2025            2030            2035            2040            2045            2050
fdskyield    12.347          12.977          13.639          14.335          15.066          15.835          16.643          17.491
;

    swge_newnew("fdskyield","2010") = swge_newnew("fdskyield","2015");
    swge_new(t,"fdskyield")         = swge_newnew("fdskyield",t);

    ag_yield0(r,"swge")      = swge_new("2010","fdskyield");
    bio_convert(r, advbio)   = swge_new("2010","convyield");
*$/gal swge
    swge_new(t,"cost")       = swge_new(t,"fdskcost")+ swge_new(t,"convcost");
*gal/ha
    swge_new(t,"yield")      = swge_new(t,"fdskyield")*swge_new(t,"convyield");

Parameter
          bio_yield0(r,*)    Biofuel yield (gallons per ha)
          bio_area0(r,*)     Biofuel area in 2010 (mha)
          crp_area0(r,*)     Crop area excluding area used for biofuels in 2010;

    ag_yield0(r,crp)$q_land0(r,crp)=ag_tonn0(r,crp)/q_land0(r,crp);

*                         tonne/ha            gal/tonne
    bio_yield0(r,"ceth")= ag_yield0(r,"corn")*bio_convert(r,"ceth");
    bio_yield0(r,"weth")= ag_yield0(r,"wht") *bio_convert(r,"weth");
    bio_yield0(r,"sybd")= ag_yield0(r,"Soyb")*bio_convert(r,"sybd");

* Rapeseed yield:
* http://www.esru.strath.ac.uk/EandE/Web_sites/02-03/biofuels/quant_biodiesel.htm
*                       tonne/ha  oil content   conversion rate   density(gal/tonne)
    bio_yield0(r,"Rpbd") = 3         *0.4         *0.97             *300.1953;

* http://en.wikipedia.org/wiki/Biodiesel
*                         gal/acre   acre/ha
    bio_yield0(r,"plbd") = 508       *2.47105;

*                         litres/hectare  gallon/litres
    bio_yield0(r,"scet")= 4000            *0.264172 ;
    bio_yield0(r,"sbet")= 4000            *0.264172 ;
**                         gal/ton                  ton/ha
    bio_yield0(r,"Swge")=  bio_convert(r, "swge") * ag_yield0(r,"swge") ;
    bio_yield0(r,"msce")=  bio_convert(r, "msce") * ag_yield0(r,"msce") ;
    bio_yield0(r,"frwe")=  bio_convert(r, "frwe") * ag_yield0(r,"frwe") ;

parameter bio_yldtrd(r,i,t)   Cellulosic energy biofuel yield growth rate by year (1 in 2010);
    bio_yldtrd(r,advbio,t) =swge_new(t,"yield")/swge_new("2010","yield");

parameter
        ha_conv         Million hectares per billion dollars of land
        ton_conv        Million metric tons of crop per billion dollars of agricultural output
        gal_conv        Gallons per dollar of fuel at retail market
        gal_btu         Convert gallon to btu
        btu_gal         Million btu and gallon conversion (quad btu per billion gallon = million btu per gal)
        chk0_gal        Check biofuels used in auto industry (billion gallons);

    ha_conv(r,crp)$p_land0(r,crp)  = 1/p_land0(r,crp);
    ha_conv(r,lu)=1/p_land0(r,lu);

* Some units conv: HHV is used
*  1 barrel = 42 US gallons
*  Gasoline = 5.253 MBtu/Barrel
*  Ethanol  = 3.539 MBtu/Barrel
*  biodiesel= 5.376 MBtu/Barrel
* These lead to Ethanol   =  84,262  btu/ga
*               Biodiesel = 128,000  btu/ga

    gal_conv(r,oil,"fuel",i) = (42 / 5.253) * btu_conv(r,oil,"fuel",i);
    gal_conv(r,ethl,"fuel",i)= (42 / 3.539) * btu_conv(r,ethl,"fuel",i) ;
    gal_conv(r,biod,"fuel",i)= (42 / 5.376) * btu_conv(r,biod,"fuel",i) ;

* Some units conv: LHV is used
*  1 barrel = 42 US gallons
*  Gasoline = 5.10 MBtu/Barrel
*  Ethanol  = 3.192 MBtu/Barrel
*  biosiesel= 4.956 MBtu/Barrel
* These lead to Ethanol   =  76,000 btu/ga
*               Biodiesel = 118,000  btu/ga

    gal_conv(r,oil,"fuel",i) = (42 / 5.100) * btu_conv(r,oil,"fuel",i);
    gal_conv(r,ethl,"fuel",i)= (42 / 3.192) * btu_conv(r,ethl,"fuel",i) ;
    gal_conv(r,biod,"fuel",i)= (42 / 4.956) * btu_conv(r,biod,"fuel",i) ;

    gal_conv(r,advbio,use,i) = sum(ceth, gal_conv(r,ceth,use,i));
    gal_conv(r,advbio,use,i)$(gal_conv(r,advbio,use,i)=0) = gal_conv(r,"scet",use,i);
    gal_conv(r,advbio,use,i)$(gal_conv(r,advbio,use,i)=0) = gal_conv(r,"scet",use,i);
    gal_conv("afr",advbio,use,i) = gal_conv("CHN",advbio,use,i);

*                           gallons /dollar              ha/gal
    ha_conv(r,advl) = gal_conv(r,"ceth","fuel","auto") /bio_yield0(r,advl)*1000;

    ha_conv(r,"Albd")    = ha_conv(r,"msce");
    ha_conv('BRA',advbio)= ha_conv('CHN',advbio);
    ha_conv('XAS',advbio)= ha_conv('CHN',advbio);
    ha_conv('AFR',advbio)= ha_conv('CHN',advbio);
    ha_conv('XLM',advbio)= ha_conv('CHN',advbio);
    ha_conv('EUR',advbio)= ha_conv('USA',advbio);

    btu_gal(e)$gal_conv('usa',e,"fuel","auto")=   BTU_conv("usa",e,"fuel","auto")/gal_conv('usa',e,"fuel","auto") ;
    btu_gal("rpbd") =  btu_gal("sybd") ;
    btu_gal("Msce") =  btu_gal("ceth") ;
    btu_gal("advb") =  btu_gal("ceth") ;

    gal_btu(r,e,use,i)$gal_conv(r,e,use,i)=  btu_conv(r,e,use,i)/ gal_conv(r,e,use,i);

    chk0_gal(r,ethl) = gal_conv(r,ethl,"fuel","auto") * sum(vnum(v), ed0(r,ethl,"fuel","auto",v)  );
    chk0_gal(r,biod) = gal_conv(r,biod,"fuel","auto") * sum(vnum(v), ed0(r,biod,"fuel","auto",v)  );

option gal_conv:3:3:1,btu_gal:5:0:1
display ha_conv, btu_gal,GAL_conv,chk0_gal,gal_btu;

Table  corncoprod_yield0(t,*)    Corn ethanol co-product yield over time in USA from EPA
* Data is updated by EPA on 7-11-2022 for ceth
*     "gal ceth/dryton corn"  "lb ddgs/gal ceth"      "kg cornoil/GJ ceth"       "lbs cornoil/gal cobd"
              ceth                   ddgs                     coil                        cobd
    2010                                                      1.13                        7.9
    2015      108.26                 5.98                     1.13                        7.9
    2020      109.44                 5.89                     1.17                        7.8
    2025      110.23                 5.82                     1.21                        7.7
    2030      112.30                 5.67                     1.21                        7.7
    2035      114.41                 5.53                     1.21                        7.6
    2040      116.56                 5.39                     1.20                        7.6
    2045      118.75                 5.25                     1.20                        7.6
    2050      120.51                 5.14                     1.20                        7.5
;

     corncoprod_yield0("2010","ceth") =   prod0("USA","ceth")/btu_gal("ceth")
                                        /(id0_10_("USA", "corn","ceth","new","2010")/ag_pric0("USA","corn") )
                                        *1000;

*lbs ddgs/gal ceth               = lb/kg  * million tonne              /billion gal
    corncoprod_yield0("2010","ddgs") =2.20462 * ag_tonn0("usa","ddgs")  /(prod0("usa","ceth")/btu_gal("ceth") );

* convert the unit as below:
*   lb cornoil/gal ceth             kg/GJ ceth                 * lb/kg  /   mmbtu/gj  * mmbtu/gal ceth
    corncoprod_yield0(t,"coil")   = corncoprod_yield0(t,"coil")*2.20462 /  0.947086   * 0.07600;
*  gal cobd/gal ceth                 lb cornoil/gal ceth           gal cobd/lb cornoil
    corncoprod_yield0(t,"cobd")   = corncoprod_yield0(t,"coil")/corncoprod_yield0(t,"cobd");
*    gal of cobd/dryton of corn   =   gal cobd/gal ceth       * gal ceth/dryton of corn
    corncoprod_yield0(t,"cobd2")  = corncoprod_yield0(t,"cobd")*corncoprod_yield0(t,"ceth");

* quad btu cobd/quad btu ceth
    corncoprod_yield0(t,"cobd3")  = corncoprod_yield0(t,"cobd")*btu_gal("cobd")/btu_gal("ceth");

* ton of ddgs/gal ceth; ton of corn oil /gal ceth
    corncoprod_yield0(t,"Ddgs")   = corncoprod_yield0(t,"ddgs")/2204.62 ;
    corncoprod_yield0(t,"coil")   = corncoprod_yield0(t,"coil")/2204.62 ;

* ton of ddgs/dry ton of corn; ton of corn oil/dry ton of corn
    corncoprod_yield0(t,"Ddgs2")   = corncoprod_yield0(t,"ddgs")*corncoprod_yield0(t,"ceth") ;
    corncoprod_yield0(t,"Coil2")   = corncoprod_yield0(t,"coil")*corncoprod_yield0(t,"ceth") ;

* Final unit:
*          ceth               ddgs                           ddgs2                     coil                     coil2
*  "gal/dryton corn"       "ton of ddgs/gal ceth"         "ton of ddgs/dryton corn"   "ton of coil/gal ceth"   "ton of coil/dryton corn"

*         cobd                cobd2                          cobd3
*  "gal cobd/gal ceth"    "gal of cobd/dryton of corn"     "quad cobd/quad ceth"

table soybcoprod_yield0(t,*)   soybean & soybean oil and soybean meal and soybean biodiesel yield over time in USA (from EPA)
* Data is updated by EPA on 7-11-2022 for vol2sybd and sybd
*    "tons soybeanoil/tons soybean" "tons soybeanmeal/tons soybean"  "gal sybd/ton soyboil"              "gal sybd/ton soybean"
            vol                            omel                          vol2sybd                               sybd
2010        0.19                           0.80
2015        0.19                           0.80                           286.31                                54.40
2020        0.19                           0.80                           290.08                                55.12
2025        0.19                           0.80                           293.95                                55.85
2030        0.19                           0.80                           295.30                                56.11
2035        0.19                           0.80                           296.66                                56.37
2040        0.19                           0.80                           298.04                                56.63
2045        0.19                           0.80                           299.43                                56.89
2050        0.19                           0.80                           300.83                                57.16
;
* The implied biofuel convertion rate from underlying GTAP data in 2010 is not consistent with new assumption from EPA.
* For policy analysis, we let biofuel yield adjustment starts in 2015 so we can avoid huge effort to change the baseyear data but still get consistant results after 2010.
    soybcoprod_yield0("2010","sybd")     =    prod0("USA","sybd")/btu_gal("sybd")
                                           /(  id0_10_("USA", "soyb","sybd","new","2010")/ag_pric0("USA","soyb")
                                             + id0_10_("USA", "vol","sybd","new","2010")/ag_pric0("USA","vol")/soybcoprod_yield0("2010","vol") )
                                           *1000;

    soybcoprod_yield0(t,"vol2sybd")      = soybcoprod_yield0(t,"sybd")/soybcoprod_yield0(t,"vol");

parameter bio_convert_trd(r,*,t)    Trend for biofuel conversion rate over time;
      bio_convert_trd(r,bio,t)$bio_convert(r,bio) = 1;
      bio_convert_trd(r,bio,t)$corncoprod_yield0(t,bio) = corncoprod_yield0(t,bio)/corncoprod_yield0("2010",bio);
      bio_convert_trd(r,bio,t)$soybcoprod_yield0(t,bio) = soybcoprod_yield0(t,bio)/soybcoprod_yield0("2010",bio);
      bio_convert_trd(r,advbio,t)                       = swge_new(t,"convyield")/swge_new("2010","convyield");

option  corncoprod_yield0:6:1:1
display bio_convert,bio_convert_trd, bio_yield0,corncoprod_yield0,soybcoprod_yield0;

set  cs(i)     Goods involved in corn ethanol and soybean biodiesel updates
        /corn, soyb, ceth, vol, omel, ddgs/
     csbio(i) /ceth, sybd/;

parameter id_ton(r,i,j)  Intermediate goods demand in metric ton;
    id_ton(r,cs,j)$ag_pric0(r,cs) = id0(r,cs,j,"new") / ag_pric0(r,cs);

parameter yldconv(r,*,*,i)          Check yield and conversion rate for corn and soybean and their products
          yldconv1(r,*,*,i)         Check yield and conversion rate for corn and soybean and their products ;

    yldconv(r,"prod","mt",cs)       = ag_tonn0(r,cs);
    yldconv(r,"prod","bg",csbio)    = prod0(r,csbio)/btu_gal(csbio) ;
    yldconv(r,"Price","$1000/t",cs) = ag_pric0(r,cs);
    yldconv(r,"Price","$/gal",csbio)$gal_conv(r,csbio,"fuel","auto") = 1/gal_conv(r,csbio,"fuel","auto");

    yldconv(r,"Yield","ton/ha",cs)  = ag_yield0(r,cs);
    yldconv(r,"Yield","ton/ton corn","ddgs")$id_ton(r,"corn","ceth")  = ag_tonn0(r,"ddgs")/id_ton(r,"corn","ceth");
    yldconv(r,"Yield","gal/ton corn","ceth")$id_ton(r,"corn","ceth")  = 1000*yldconv(r,"prod","bg","ceth") /id_ton(r,"corn","ceth");


    yldconv(r,"Yield","ton/ton soyb","vol")$(id_ton(r,"soyb","vol")+id_ton(r,"osdn","vol"))
         = ag_tonn0(r,"vol")/(id_ton(r,"soyb","vol")+id_ton(r,"osdn","vol"));
    yldconv(r,"Yield","ton/ton soyb","omel")$(id_ton(r,"soyb","vol")+id_ton(r,"osdn","vol"))
         = ag_tonn0(r,"omel")/(id_ton(r,"soyb","vol")+id_ton(r,"osdn","vol"));
    yldconv(r,"Yield","gal/ton soyb","sybd")$(id_ton(r,"soyb","sybd")+id_ton(r,"vol","sybd")/yldconv(r,"Yield","ton/ton soyb","vol"))
         = 1000*yldconv(r,"prod","bg","sybd") /(id_ton(r,"soyb","sybd")+id_ton(r,"vol","sybd")/yldconv(r,"Yield","ton/ton soyb","vol"));

    yldconv1(r,"Yield","gal/ton corn","ceth")=yldconv(r,"Yield","gal/ton corn","ceth");
    yldconv1(r,"Yield","gal/ton soyb","sybd") =yldconv(r,"Yield","gal/ton soyb","sybd");
option yldconv:2:3:1
display  yldconv;


parameter  bau_gal       Initial biofuel consumption target in the bau case (same as in 2010) (billion gallons)
           bau_btu       Initial biofuel consumption target in the bau case (same as in 2010) (quad btu) ;
* In the bau case, biofuels keep the level in 2010
    bau_gal(r,e,t)= gal_conv(r,e,"fuel","auto") * sum(vnum(v), ed0(r,e,"fuel","auto",v)  );
    bau_btu(r,e,t)= BTU_conv(r,e,"fuel","auto") * sum(vnum(v), ed0(r,e,"fuel","auto",v)  );

display  bau_gal;

set     biof(i)      Biofuels
        fdsk(i)      feedstock for sybd  /vol/
        fdskmap(i,j)  /ceth.corn,sybd.soyb,sybd.vol, vol.soyb/;

    biof("ceth")=yes;
    biof("sybd")=yes;

parameter chk0_bioproc      Check biofuel production cost ($ per gallon)
          chk0_biofdsk;
*$/gal
    chk0_bioproc(r,bio,"biofuel")$(biof(bio) and prod0(r,bio))
       = y0(r,bio,"new")*(1-ty(r,bio))
        /prod0(r,bio)*btu_gal(bio);

    chk0_bioproc(r,bio,"byprod")$(ceth(bio) and y0(r,bio,"new")*(1-ty(r,bio)))
       =  y0(r,"ddgs","new")*(1-ty(r,"ddgs"))
        /( y0(r,bio,"new")*(1-ty(r,bio)));
    chk0_bioproc(r,bio,g)$(fdskmap(bio,g) and y0(r,bio,"new")*(1-ty(r,bio)))
       = id0(r,g,bio,"new")*(1+ti(r,g,bio))
        / (y0(r,bio,"new")*(1-ty(r,bio)));

    chk0_bioproc(r,bio,g)$(biof(bio) and y0(r,bio,"new")*(1-ty(r,bio)))
       = id0(r,g,bio,"new")*(1+ti(r,g,bio)) / (y0(r,bio,"new")*(1-ty(r,bio)))    ;

    chk0_bioproc(r,bio,e)$(biof(bio) and y0(r,bio,"new")*(1-ty(r,bio)))
       = sum(use,ed0(r,e,use,bio,"new"))
        /( y0(r,bio,"new")*(1-ty(r,bio)));

    chk0_bioproc(r,bio,"labor")$(biof(bio) and y0(r,bio,"new")*(1-ty(r,bio)))
       = ld0(r,bio,"new")*(1+tl(r,bio))
        /( y0(r,bio,"new")*(1-ty(r,bio)));

    chk0_bioproc(r,bio,"capital")$(biof(bio) and y0(r,bio,"new")*(1-ty(r,bio)))
       =  sum(k,kd0(r,k,bio,"new")*(1+tk(r,k,bio)))
        /( y0(r,bio,"new")*(1-ty(r,bio)));

*  $1000/ton
    chk0_biofdsk(r,s,"output")$fdsk(s) = y0(r,s,"new")*(1-ty(r,s))/ag_tonn0(r,s);

    chk0_biofdsk(r,s,"byprod")$(vol(s) and y0(r,s,"new")*(1-ty(r,s)))
       =  y0(r,"omel","new")*(1-ty(r,"omel"))
        / (y0(r,s,"new")*(1-ty(r,s)));
    chk0_biofdsk(r,s,g)$(fdskmap(s,g) and y0(r,s,"new")*(1-ty(r,s)))
       = id0(r,g,s,"new")*(1+ti(r,g,s))
        / (y0(r,s,"new")*(1-ty(r,s)));

    chk0_biofdsk(r,s,g)$(fdsk(s) and y0(r,s,"new")*(1-ty(r,s)))
       =  id0(r,g,s,"new")*(1+ti(r,g,s)) / (y0(r,s,"new")*(1-ty(r,s)));
    chk0_biofdsk(r,s,g)=round(chk0_biofdsk(r,s,g),5);

    chk0_biofdsk(r,s,e)$(fdsk(s) and y0(r,s,"new")*(1-ty(r,s)))
       =  sum(use,ed0(r,e,use,s,"new"))
        / (y0(r,s,"new")*(1-ty(r,s)));
    chk0_biofdsk(r,s,"labor")$(fdsk(s) and y0(r,s,"new")*(1-ty(r,s)))
       = ld0(r,s,"new")*(1+tl(r,s))
        / (y0(r,s,"new")*(1-ty(r,s)));
    chk0_biofdsk(r,s,"capital")$(fdsk(s) and y0(r,s,"new")*(1-ty(r,s)))
       = sum(k,kd0(r,k,s,"new")*(1+tk(r,k,s)))
        /( y0(r,s,"new")*(1-ty(r,s)));

    chk0_biofdsk(r,s,"capital")$(chk0_biofdsk(r,s,"capital")<0)
       = - chk0_biofdsk(r,s,"capital") ;

    chk0_biofdsk(r,s,"humancap")$(fdsk(s) and y0(r,s,"new")*(1-ty(r,s)))
       = hkd0(r,s,"new")*(1+thk(r,s))
        /( y0(r,s,"new")*(1-ty(r,s)));
    chk0_biofdsk(r,s,"land")$(fdsk(s) and y0(r,s,"new")*(1-ty(r,s)))
       = crp_lnd0(r,s,"new")*(1+tn(r,s))
        /( y0(r,s,"new")*(1-ty(r,s)));

display chk0_bioproc,chk0_biofdsk;

parameter     bio_shr0          Biofuel production input cost share in 2010 ($ per gal biofuel)
              vol_shr0          Vegetable oil and oil meal input cost share in 2010 ($ per ton of vol)
              bio_shr00         Biofuel share in 2010 (percentage) and used in report;

    bio_shr0(r,bio,"2010","y0")$(biof(bio) and prod0(r,bio))     =  y0(r,bio,"new")   / prod0(r,bio)*btu_gal(bio);
    bio_shr0(r,bio,"2010","ddgs")$(ceth(bio) and prod0(r,bio))   =  y0(r,"ddgs","new")/ prod0(r,bio)*btu_gal(bio);
    bio_shr0(r,bio,"2010",e)$(biof(bio) and prod0(r,bio))        =  sum(use,ed0(r,e,use,bio,"new"))/ prod0(r,bio)*btu_gal(bio);
    bio_shr0(r,bio,"2010",g)$(biof(bio) and prod0(r,bio))        =  id0(r,g,bio,"new")/ prod0(r,bio)*btu_gal(bio);
    bio_shr0(r,bio,"2010","ld")$(biof(bio) and prod0(r,bio))     =  ld0(r,bio,"new")  / prod0(r,bio)*btu_gal(bio);
    bio_shr0(r,bio,"2010",k)$(biof(bio) and prod0(r,bio))        =  kd0(r,k,bio,"new")/ prod0(r,bio)*btu_gal(bio);
    bio_shr0(r,bio,"2010","hk")$(biof(bio) and prod0(r,bio))     =  hkd0(r,bio,"new") / prod0(r,bio)*btu_gal(bio);

    vol_shr0(r,s,"2010","y0")$(vol(s) )                      =  y0(r,s,"new")/ ag_tonn0(r,s);
    vol_shr0(r,s,"2010","omel")$(vol(s) and ag_tonn0(r,s))   =  y0(r,"omel","new")/ag_tonn0(r,s);
    vol_shr0(r,s,"2010",e)$(vol(s) and ag_tonn0(r,s))        =  sum(use,ed0(r,e,use,s,"new"))/ag_tonn0(r,s);
    vol_shr0(r,s,"2010",g)$(vol(s) and ag_tonn0(r,s))        =  id0(r,g,s,"new")/ ag_tonn0(r,s);
    vol_shr0(r,s,"2010","ld")$(vol(s) and ag_tonn0(r,s))     =  ld0(r,s,"new")  / ag_tonn0(r,s);
    vol_shr0(r,s,"2010",k)$(vol(s) and ag_tonn0(r,s))        =  kd0(r,k,s,"new")/ ag_tonn0(r,s);
    vol_shr0(r,s,"2010","hk")$(vol(s) and ag_tonn0(r,s))     =  hkd0(r,s,"new")/ ag_tonn0(r,s);

    bio_shr00(r,bio,i)$y0(r,bio,"new")   = bio_shr0(r,bio,"2010",i);
    bio_shr00(r,bio,"y0")$y0(r,bio,"new")= bio_shr0(r,bio,"2010","y0") ;
    bio_shr00(r,bio,"ld")$y0(r,bio,"new")= bio_shr0(r,bio,"2010","ld") ;
    bio_shr00(r,bio,k)$y0(r,bio,"new")   = bio_shr0(r,bio,"2010",k) ;
    bio_shr00(r,bio,"hk")$y0(r,bio,"new")= bio_shr0(r,bio,"2010","hk") ;


display bio_shr0,bio_shr00, vol_shr0;

*execute_unload  '.\data\bio_costshare.gdx', chk_bioproc,chk_biofdsk;
*execute 'gdxxrw.exe .\data\bio_costshare.gdx o=.\data\bio_costshare.xlsx  par=chk_bioproc        rng=bioproc!a7         cdim=1'
*execute 'gdxxrw.exe .\data\bio_costshare.gdx o=.\data\bio_costshare.xlsx  par=chk_biofdsk        rng=biofdsk!a7         cdim=1'

table soybcoprod_cost0(t,*)    New soybean biodiesel production energy use and other non-energy non-feedstock cost over time in USA from EPA
* Energy use includes energy used for refining and oilseed crushing
*     "quad gas/quad sybd in refine"  "quad ele/quad sybd in refine" "quad gas/quad sybd in crush"  "quad ele/quad sybd in crush"         "$2010/gal sybd"      "$2010/gal sybd"
                        gas_ref                      ele_ref                   gas_cru                          ele_cru                         "id+ld"                    va
    2010
    2015                 0.058                        0.008                      0.123                           0.024                           0.530                     0.120
    2020                 0.058                        0.008                      0.123                           0.024                           0.500                     0.120
    2025                 0.058                        0.008                      0.123                           0.024                           0.480                     0.120
    2030                 0.058                        0.008                      0.123                           0.024                           0.474                     0.120
    2035                 0.058                        0.008                      0.123                           0.024                           0.468                     0.120
    2040                 0.058                        0.008                      0.123                           0.024                           0.462                     0.120
    2045                 0.058                        0.008                      0.123                           0.024                           0.457                     0.120
    2050                 0.058                        0.008                      0.123                           0.024                           0.451                     0.120
;

    soybcoprod_cost0(t,"gas")=   soybcoprod_cost0(t,"gas_ref")+ soybcoprod_cost0(t,"gas_cru");
    soybcoprod_cost0(t,"ele")=   soybcoprod_cost0(t,"ele_ref")+ soybcoprod_cost0(t,"ele_cru");

    soybcoprod_cost0(t,e)$btu_conv("usa",e,"fuel","sybd")
*    $/gal                 = "quad ff/quad sybd"   /"quad ff/$billion"              *"quad sybd/billion gal"
                           =  soybcoprod_cost0(t,e)/btu_conv("usa",e,"fuel","sybd") * btu_gal("sybd") ;

    soybcoprod_cost0(t,e)$(btu_conv("usa",e,"fuel","sybd")=0 and soybcoprod_cost0(t,e))
*    $/gal                 = "quad ff/quad sybd"   /"quad ff/$billion"              *"quad sybd/billion gal"
                           =  soybcoprod_cost0(t,e)/btua_conv("usa",e) * btu_gal("sybd") ;

    bio_shr0("usa","sybd",t,e)$(t.val>2010)  = soybcoprod_cost0(t,e);
    bio_shr0("usa","sybd",t,s)$(t.val>2010 and (not sameas(s,"soyb") and not sameas(s,"vol") and  not sameas(s,"vol")))
     = soybcoprod_cost0(t,"id+ld")
      *bio_shr0("usa","sybd","2010",s)
      /(sum(g$(not sameas(g,"soyb") and not sameas(g,"vol") and not sameas(g,"omel")),bio_shr0("usa","sybd","2010",g))+bio_shr0("usa","sybd","2010","ld"));

    bio_shr0("usa","sybd",t,"ld")$(t.val>2010)
         = soybcoprod_cost0(t,"id+ld")
          *bio_shr0("usa","sybd","2010","ld")
          /(sum(g$(not sameas(g,"soyb") and not sameas(g,"vol") and not sameas(g,"omel")),bio_shr0("usa","sybd","2010",g))+bio_shr0("usa","sybd","2010","ld"));

    bio_shr0("usa","sybd",t,"va")$(t.val>2010)
         = soybcoprod_cost0(t,"va") ;

    bio_shr0("usa","sybd",t,s)$(t.val>2010 and (sameas(s,"soyb") or sameas(s,"vol")) )
         = bio_shr0("usa","sybd","2010",s)*soybcoprod_yield0("2010","sybd")/soybcoprod_yield0(t,"sybd");

    bio_shr0("usa","sybd",t,"y0")$(t.val>2010)
         = bio_shr0("usa","sybd","2010","y0");

    bio_shr0("usa","sybd",t,"omel")$(t.val>2010)
         =  bio_shr0("usa","sybd",t,"soyb")/ag_pric0("usa","soyb")
           *soybcoprod_yield0(t,"omel")*ag_pric0("usa","omel")    ;

    bio_shr0("usa","sybd",t,"output_total")
         = bio_shr0("usa","sybd",t,"y0")+bio_shr0("usa","sybd",t,"omel");

    bio_shr0("usa","sybd",t,"input_total")
         =  sum(i$(not sameas(i,"omel")),bio_shr0("usa","sybd",t,i))
          + bio_shr0("usa","sybd",t,"va")
          + bio_shr0("usa","sybd",t,"ld")   ;

parameter chk0_sybd           Check sybd cost;
    chk0_sybd(t) =1000/(   bio_shr0("usa","sybd",t,"soyb")/ag_pric0("usa","soyb")
                         + bio_shr0("usa","sybd",t,"vol")/ag_pric0("usa","vol")/0.19 );
*display chk0_sybd;

Table corncoprod_cost0(t,*)    New corn ethanol production energy use and other non-energy non-feedstock cost over the time in USA from EPA
* Cost includes refining production cost for corn ethanol and corn oil, but not cost from corn oil to corn oil biodiesel
*     "quad gas/quad ceth" "quad ele/quad ceth"    "$2010/gal ceth"      "$2010/gal ceth"
              gas              ele                  "id+ld"                 va
2010
2015         0.318            0.026                 0.340                  0.250
2020         0.318            0.026                 0.330                  0.250
2025         0.318            0.026                 0.310                  0.250
2030         0.318            0.026                 0.306                  0.250
2035         0.318            0.026                 0.302                  0.250
2040         0.318            0.026                 0.299                  0.250
2045         0.318            0.026                 0.295                  0.250
2050         0.318            0.026                 0.291                  0.250
;
* Energy cost is converted to $/gal of ceth
    corncoprod_cost0(t,e)$btu_conv("usa",e,"fuel","ceth")
*    $/gal                 = "quad ff/quad ceth"  /"quad ff/$billion"              *"quad ceth/billion gal"
                           = corncoprod_cost0(t,e)/btu_conv("usa",e,"fuel","ceth") * btu_gal("ceth") ;

    corncoprod_cost0(t,e)$(btu_conv("usa",e,"fuel","ceth")=0 and corncoprod_cost0(t,e))
*    $/gal                 = "quad ff/quad ceth"  /"quad ff/$billion" *"quad ceth/billion gal"
                           = corncoprod_cost0(t,e)/btua_conv("usa",e) * btu_gal("ceth") ;

    bio_shr0("usa","ceth",t,e)$(t.val>2010)= corncoprod_cost0(t,e);
    bio_shr0("usa","ceth",t,s)$(t.val>2010 and (not sameas(s,"corn") and not sameas(s,"ddgs")))
         = corncoprod_cost0(t,"id+ld")
          *bio_shr0("usa","ceth","2010",s)
          /(sum(g$(not sameas(g,"corn") and not sameas(g,"ddgs")),bio_shr0("usa","ceth","2010",g))+bio_shr0("usa","ceth","2010","ld"));

    bio_shr0("usa","ceth",t,"ld")$(t.val>2010)
         = corncoprod_cost0(t,"id+ld")
          *bio_shr0("usa","ceth","2010","ld")
          /(sum(g$(not sameas(g,"corn") and not sameas(g,"ddgs")),bio_shr0("usa","ceth","2010",g))+bio_shr0("usa","ceth","2010","ld"));

    bio_shr0("usa","ceth",t,"va")$(t.val>2010)
     = corncoprod_cost0(t,"va") ;

    bio_shr0("usa","ceth",t,"corn")$(t.val>2010)
         = bio_shr0("usa","ceth","2010","corn")* corncoprod_yield0("2010","ceth")/corncoprod_yield0(t,"ceth");

    bio_shr0("usa","ceth",t,"ddgs")$(t.val>2010)
         = bio_shr0("usa","ceth","2010","ddgs")* corncoprod_yield0(t,"ddgs")/corncoprod_yield0("2010","ddgs");

    bio_shr0("usa","ceth",t,"y0")$(t.val>2010)
         = bio_shr0("usa","ceth","2010","y0");

* Assume cobd cost structure is same as sybd  and should be added to each of the input items above.
    bio_shr0("usa","ceth",t,"cobd")$(t.val>2010)
         =    bio_shr0("USA","sybd","2010","y0")*corncoprod_yield0(t,"cobd");

    bio_shr0("usa","ceth",t,e)$(t.val>2010)
         =  bio_shr0("usa","ceth",t,e)
           +bio_shr0("USA","sybd",t,e)*corncoprod_yield0(t,"cobd");

    bio_shr0("usa","ceth",t,s)$(t.val>2010 and (not sameas(s,"corn") and not sameas(s,"vol") and not sameas(s,"soyb")))
         =  bio_shr0("usa","ceth",t,s)
           +bio_shr0("USA","sybd",t,s)*corncoprod_yield0(t,"cobd");

    bio_shr0("usa","ceth",t,"ld")$(t.val>2010)
         =  bio_shr0("usa","ceth",t,"ld")
           +bio_shr0("USA","sybd",t,"ld")*corncoprod_yield0(t,"cobd");

    bio_shr0("usa","ceth",t,"va")$(t.val>2010)
         =  bio_shr0("usa","ceth",t,"va")
           +bio_shr0("USA","sybd",t,"va")*corncoprod_yield0(t,"cobd");

    bio_shr0("usa","ceth",t,"output_total")
         = bio_shr0("usa","ceth",t,"y0")+bio_shr0("usa","ceth",t,"ddgs")+bio_shr0("usa","ceth",t,"cobd");

    bio_shr0("usa","ceth",t,"input_total")
         =  sum(i$(not sameas(i,"ddgs") and not sameas(i,"cobd")),bio_shr0("usa","ceth",t,i))
          + bio_shr0("usa","ceth",t,"va")
          + bio_shr0("usa","ceth",t,"ld")   ;

display corncoprod_cost0,bio_shr0;


parameter f_bio         Flag to activate the change of input and output cost data in USA for ceth & sybd & swge
          chg_bio       Difference of input and output in ceth and sybd in USA
          chg_biot      Difference of input and output in ceth and sybd in USA over time;
    f_bio(r,bio)         = 0;
    chg_bio(r,bio,i,v)   = 0;
    chg_bio(r,bio,k,v)   = 0;
    chg_bio(r,bio,"ld",v)= 0;
    chg_bio(r,bio,"hk",v)= 0;
    chg_bio(r,bio,"y0",v)= 0;

    chg_biot(r,bio,t,"y0")$csbio(bio)=  prod0(r,bio)/btu_gal(bio)*( bio_shr0(r,bio,t,"y0")- bio_shr0(r,bio,"2010","y0"));
    chg_biot(r,bio,t,i)$csbio(bio)   =  prod0(r,bio)/btu_gal(bio)*( bio_shr0(r,bio,t,i)   - bio_shr0(r,bio,"2010",i));
    chg_biot(r,bio,t,e)$csbio(bio)   =  prod0(r,bio)/btu_gal(bio)*( bio_shr0(r,bio,t,e)   - bio_shr0(r,bio,"2010",e)) ;

    chg_biot(r,bio,t,k)$csbio(bio)   =  prod0(r,bio)/btu_gal(bio)*( bio_shr0(r,bio,t,k)   - bio_shr0(r,bio,"2010",k));
    chg_biot(r,bio,t,"ld")$csbio(bio)=  prod0(r,bio)/btu_gal(bio)*( bio_shr0(r,bio,t,"ld")- bio_shr0(r,bio,"2010","ld"));
    chg_biot(r,bio,t,"hk")$csbio(bio)=  prod0(r,bio)/btu_gal(bio)*( bio_shr0(r,bio,t,"hk")- bio_shr0(r,bio,"2010","hk"));

display prod0,btu_gal,y0,chg_biot;

set             cornddg(i)       /corn, ddgs/;

parameter       ddgs4corn        Lbs of corn displaced by one lb of DDGS for livestock feed  /1.125/ ;
parameter       alfa0(r,i,t)     Factor used to reflect yield growth rate especially DDGS (used in the loop)
                alfa(r,i)        Factor used to reflect yield growth rate especially DDGS (used in the loop)
                idt_val(r,*,t)   Corn and DDGS demand in feedstock of livestock sector ($billion) (used in the loop)
                idt_ton(r,*,t)   Corn and DDGS demand in feedstock of livestock sector (million tonne) (used in the loop);

parameter
        feed0
        advswtch                Switch on advanced biofuels
        advbiomkup              Cost markup on advanced biofuels
        advbiocoy0              Coproduct in advanced biofuels
        advbiolnd0              Land inputs to advanced biofuels
        advbiold0               Labor inputs to advanced biofuels
        advbiokd0               Capital inputs to advanced biofuels
        advbioid0               Intermediate inputs to advanced biofuels
        advbioed0               Energy inputs to advanced biofuels
        advbio_t                Total inputs
;

    feed0(r,liv,v)
       =  sum(crp, id0(r,crp,liv,v)  *pid0(r,crp,liv))
        + sum(byprod, id0(r,byprod,liv,v)  )
        + sum(ofd, id0(r,ofd,liv,v)  *pid0(r,ofd,liv));

    advswtch(r,i,v)                 = no;
    advbiomkup(r,i)                 = 1;

* Miscathus: adapted from Purdue paper
    advbiolnd0(r,"msce")            = 0.045;
    advbiold0(r,"msce")             = 0.143;
    advbiokd0(r,"va","msce")        = 0.532;
    advbioid0(r,"eim","msce")       = 0.078;
    advbioid0(r,"rodf","msce")      = 0.073;
    advbioid0(r,"srv","msce")       = 0.061;
    advbioed0(r,"ele","msce")       = 0.034;
    advbioed0(r,"gas","msce")       = 0.034;

* Algae advanced biodiesel
*  Updated in 1-21-2016
*  Source: http://www.biofuelsdigest.com/bdigest/2014/10/13/where-are-we-with-algae-biofuels/
    advbiolnd0(r,"Albd")            = 0.057;
    advbiold0(r,"Albd")             = 0.080;
    advbiokd0(r,"va","Albd")        = 0.655;
    advbioid0(r,"eim","Albd")       = 0.129;
    advbioid0(r,"rodf","Albd")      = 0.031;
    advbioid0(r,"srv","Albd")       = 0.002;
    advbioed0(r,"ele","Albd")       = 0.001;
    advbioed0(r,"gas","Albd")       = 0.045;

$ontext
* Cassava ethanol in Thailand and China:
  Cost of cassava production per ha
                                                     Unit        Thailand      China
Yield                                                ton/ha       23.4         20
Price                                                $/ton        17.73        26.03
Revenue                                              $/ha        414.882      520.6
labor cost                                           $/ha        167.18       167.4
other production cost:
fertilizer, chemical, cutting, transportation        $/ha        198.73       260.22
capital cost                                         $/ha         48.89        94.94
Total cost                                           $/ha         414.8       522.56

Aggregated production cost from cassava production and ethanol production ($/ha)
               Thailand       China
Land               187        125
Labor              215        182
Capital            301        185
ele                 92        18
gas                 92        18
service             54        40
Transportation     100        95
Chemical           255        608
Total Cost        1296        1271

* Cost of cassava ethanol: $1.703/gal
    advbiolnd0(r,"cave")            = 0.0983;
    advbiold0(r,"cave")             = 0.1428;
    advbiokd0(r,"va","cave")        = 0.1458;
    advbioid0(r,"eim","cave")       = 0.4783;
    advbioid0(r,"rodf","cave")      = 0.0747;
    advbioid0(r,"srv","cave")       = 0.0311;
    advbioed0(r,"ele","cave")       = 0.0144;
    advbioed0(r,"gas","cave")       = 0.0144;

* Cost of sweet sorghum ethanol: $1.896/gal
    advbiolnd0(r,"sghe")            = 0.0278;
    advbiold0(r,"sghe")             = 0.1633;
    advbiokd0(r,"va","sghe")        = 0.4671;
    advbioid0(r,"eim","sghe")       = 0.2194;
    advbioid0(r,"rodf","sghe")     = 0.0305;
    advbioid0(r,"srv","sghe")       = 0.0435;
    advbioed0(r,"ele","sghe")       = 0.0310;
    advbioed0(r,"oil","sghe")       = 0.0174;
$offtext

* Corn stover
*  Cost: $0.73/gal from  http://www.nrel.gov/docs/fy02osti/32438.pdf
*  Cost: $3.51/gal from FASOM and subsidies around $0.15/gal varying by state
*  Cost is averaged from these two sources:(0.73+3.51)/2 = $2.12/gal
    advbiold0(r,"ArsE")             = 0.0802;
    advbiokd0(r,"va","ArsE")        = 0.4048;
    advbioid0(r,"eim","ArsE")       = 0.3330-0.0311;
    advbioid0(r,"rodf","ArsE")      = 0.1549;
    advbioid0(r,"srv","ArsE")       = 0.0311;
    advbioed0(r,"ele","ArsE")       = 0.0271/2;
    advbioed0(r,"gas","ArsE")       = 0.0271/2;

*Forest residue
* Cost: $5.38/gal oil equivalent from FASOM
    advbiold0(r,"FrsE")             = 0.0882;
    advbiokd0(r,"va","FrsE")        = 0.4450;
    advbioid0(r,"eim","FrsE")       = 0.3660-0.0435;
    advbioid0(r,"rodf","FrsE")      = 0.0711;
    advbioid0(r,"srv","FrsE")       = 0.0435;
    advbioed0(r,"ele","FrsE")       = 0.0297/2;
    advbioed0(r,"oil","FrsE")       = 0.0297/2;

* Forest pulpwood
*  Cost: $5.48/gal oil equivalent from FASOM
*  Assumption to calculate the land as below:
*  Pulpwood yield:  http://www.sfrc.ufl.edu/Extension/FFSnl/ffsnl34e.htm
*                  harvested at age 20-25, yield  30 cords per acre
*  Pulpwood volume-weight conversion: table 1 in http://msucares.com/pubs/publications/p2244.pdf
*                  pulpwood: 2.6 tons/cord
*  Unit conversion from wet ton to dry ton:
*                  average wood: 0.5
*  Pulpwood ethanol yield in FASOM: 79.1 gal ethnaol / dry ton
*  Unit conversion from acre to hecter: 0.404686 ha/acre ;
*                  from 1 gal ethanol to gallon of oil equivalent: 76000/115400 =0.65858
*  Thus the ethanol yield from pulpwood = 30*2.6*0.5*79.1 gal ethnaol/acre = 3084.9 ethanol gal /acre
*                                      = 30*2.6*0.5*79.1 *0.65858 /0.404686 gal oil eqvi /ha = 5020.32 gal oil eqvi /ha
*  Land cost: land value per ha / ethanol yield in USA: = 0.024*1000/5020.32 $/gal = 0.00478 $/gal
*  Land cost share in USA:  0.00478*25 years /5.48 = 25*0.00087

    advbiolnd0(r,"FrwE")            = 1000*p_land0("USA","frs")/5020.32/5.48*25;
    advbiold0(r,"FrwE")             = 0.0865;
    advbiokd0(r,"va","FrwE")        = 0.4363-advbiolnd0(r,"FrwE");
    advbioid0(r,"eim","FrwE")       = 0.3589-0.0435;
    advbioid0(r,"rodf","FrwE")      = 0.0891;
    advbioid0(r,"srv","FrwE")       = 0.0435;
    advbioed0(r,"ele","FrwE")       = 0.0292/2;
    advbioed0(r,"oil","FrwE")       = 0.0292/2;

    tn(r,advbio)            = tn(r,"ocr");
    tl(r,advbio)            = tl(r,"ocr");
    tk(r,"va",advbio)       = tk(r,"va","ocr");

    plnd0(r,advbio)         = 1 + tn(r,advbio);
    pld0(r,advbio)          = 1 + tl(r,advbio);
    pkd0(r,"va",advbio)     = 1 + tk(r,"va",advbio);

* Check input share = 1
    advbio_t(r,advbio)=   advbiolnd0(r,advbio)+advbiold0(r,advbio)+advbiokd0(r,"va",advbio)
                        + advbioid0(r,'eim',advbio)+ advbioid0(r,'rodf',advbio)+ advbioid0(r,'srv',advbio)
                        + sum(e,advbioed0(r,e,advbio));
option    advbio_t:6:1:1
display  "before", advbiolnd0,  advbiold0,advbiokd0,advbioid0,advbioed0,advbio_t;


set   advb_initem     Input items in advb /land, va, ld, eim, rodf,otrn,  srv, ele, gas, oil /;

Table shr_feedstock   Proportion of input cost in feedstock production in terms to the overall input cost in 2010
* the 1- shr_feedstock will be the proportion for biofuel production cost share
* the data is come from "cassava%sweet soyghum & agfors residue ethanol production.xlsx"
             Swge          MscE          ArsE          FrsE          FrwE
land       1.0000        1.0000        0.0000        0.0000        1.0000
va         0.3929        0.3929        0.5149        0.5149        0.5149
ld         0.6855        0.6855        0.3878        0.3878        0.3878
eim        0.8645        0.8645        0.1584        0.1584        0.1584
RodF       0.8826        0.8826        1.0000        1.0000        1.0000
Srv        0.5979        0.5979        0.3746        0.3746        0.3746
ele        0.0357        0.0255        0.0000        0.0000        0.0000
gas        0.0357        0.0255        0.0000        0.0000        0.0000
Oil        0.0000        0.0000        0.0000        0.0000        0.0000
;

* The following data for swge is updated by Michael Shell from EPA
Table shr_feedstock_sw  Proportion of input cost in swtichgrass feedstock production in terms to the overall input cost in 2010
           Swge
land      1.0000
va        0.5686
ld        0.7589
eim       0.1519
RodF      1.0000
Srv       0.0792
ele       0.0000
;

    shr_feedstock(advb_initem,"swge") = shr_feedstock_sw(advb_initem,"swge");
* swge: production of switch grass feedstock cost:$1.097/gal ;
*       conversion cost from feedstock to biofuel: $0.878/gal
*       electricity credit from biofuel production: $0.112/gal
*       total combined biofuel cost: 1.10+0.88-0.11 = $1.863/gal;
* here biofuel production cost is normalized to 1, so electricity coproduct credit share = 0.112/1.863 =0.06005

    advbiocoY0(r,"swge")            = 0.06005 ;
    advbiolnd0(r,"swge")            = 0.18256 ;
    advbiold0(r,"swge")             = 0.17848 ;
    advbiokd0(r,"va","swge")        = 0.30036 ;
    advbioid0(r,"eim","swge")       = 0.27134 ;
    advbioid0(r,"rodf","swge")      = 0.05300 ;
    advbioid0(r,"srv","swge")       = 0.07432 ;

$ifthen setglobal aggtrn
    shr_feedstock("otrn", advbio)    = shr_feedstock("rodf", advbio);
    shr_feedstock_sw("otrn", advbio) = shr_feedstock_sw("rodf", advbio);

    shr_feedstock(advb_initem,"swge") = shr_feedstock_sw(advb_initem,"swge");
    shr_feedstock("rodf", advbio)    = 0;
    shr_feedstock_sw("rodf", advbio) = 0;

    advbioid0(r,"otrn",advbio)= advbioid0(r,"rodf",advbio);
    advbioid0(r,"rodf",advbio)= 0;
$endif

parameter
        fdsklnd0              Land inputs to advanced biofuel feedstock production
        fdskld0               Labor inputs to advanced biofuel feedstock production
        fdskkd0               Capital inputs to advanced biofuel feedstock production
        fdskid0               Intermediate inputs to advanced biofuel feedstock production
        fdsked0               Energy inputs to advanced biofuel feedstock production  ;

    fdsklnd0(r,advbio)  = advbiolnd0(r,advbio)  *shr_feedstock("land",advbio);
    fdskld0(r,advbio)   = advbiold0(r,advbio)   *shr_feedstock("ld",advbio);
    fdskkd0(r,k,advbio) = advbiokd0(r,k,advbio) *shr_feedstock(k,advbio);
    fdskid0(r,s,advbio) = advbioid0(r,s,advbio) *shr_feedstock(s,advbio);
    fdsked0(r,e,advbio) = advbioed0(r,e,advbio) *shr_feedstock(e,advbio);
display fdsklnd0,fdskld0,fdskkd0,fdskid0,fdsked0;

Table advfdCost(*,*)        Advanced biomass feedstock cost in 2015 in advanced biofuel production (cost is in $ per gal oil equivalent)
          cost     share
* Swge    1.159    0.29231
 Swge     1.097    0.58890
 Msce     1.009    0.34906
 ArsE     0.744    0.15493
 FrsE     0.427    0.07109
 FrwE     0.562    0.08914
 Albd     7.230    0.68143
;

* Only new swge cost is in $/gal of ethanol so it is converted to $/gal oil equivalent)
    advfdCost("swge","cost") = advfdCost("swge","cost")*(5.253/3.192);


table advbioCost          Advanced biofuel cost over time ($ per gal oil equivalent)
* The data is taken from Winchester, Reilly, 2015, "The Feasibility, Costs, and Environmental Implications of Large-scale Biomass Energy",
*  MIT Joint Program report, Figure 4.
*  The original data is from cost estimates to 2015 based on a production cost survey by Bloomberg New Energy Finance (2013).
*  Due to the lead time between technology availability and plant operations, cost estimates in this survey are lagged by two years.
*  ethanol costs fall by 81% between 2010 and 2015 due to assumed decreases in enzyme costs and learning effects.
*  From 2015 to 2040, reflecting the scope for development of new technologies, we assume that ethanol costs fall an additional 2.5% per year. and flatten out after 2040
* Oil price in 2010 = $2.747/gal
*  Albd source is from:http://www.biofuelsdigest.com/bdigest/2014/10/13/where-are-we-with-algae-biofuels/
*  For future research, the cost trend should be updated.
             2010        2015        2020        2025        2030        2035        2040        2045        2050
Albd        18.22       10.61       4.785       3.078       2.927       2.783       2.647        2.647      2.647
ArsE         8.20        4.80        4.23        3.73        3.28        2.89        2.55        2.55       2.55
FrsE        10.40        6.00        5.29        4.66        4.10        3.62        3.19        2.819      2.819
*FrWE       10.40        6.00        5.29        4.66        4.10        3.62        3.19        3.19        3.19
;

    advbioCost("FrWe" ,t)=1.05*advbioCost("Frse",t);

* Yield of ethanol : msce:  2960 gal/ha; swge: 1480 gal/ha; frwe: 1812.384 gal/ha
* Yield of equivalent of gasoline: msce  2960/(5.253/3.192)=1798.65 gal/ha; swge: 1480/(5.253/3.192)=899.33 gal/ha; frwe: 1812.384/(5.253/3.192)=1101.3 gal/ha
    advbioCost("Msce" ,"2015")=p_land0("USA","crop")*1000/(bio_yield0("USA","msce")/(5.253/3.192)) /advbiolnd0("USA","msce");
    advbioCost("Msce" ,"2010")=advbioCost("msce","2015")/0.6;
    advbioCost("Msce" ,t)$(t.val>2015)= advbioCost("msce" ,"2015")*(1-0.01)**(t.val-2015);
    advbioCost("Msce" ,t)$(t.val>2015 and advbioCost("Msce" ,t)<2.747)= 2.747;

    advbioCost("Swge" ,t)$(t.val>2015)= swge_new(t,"cost")*5.253/3.192;
    advbioCost("swge" ,"2010")= advbioCost("swge" ,"2020")*1.30;
    advbioCost("swge" ,"2015")= advbioCost("swge" ,"2020")*1.15 ;

    advbioCost("Albd" ,t)=advbioCost("Arse",t);
* Make cost flatter after 2030 except swge.
    advbioCost(advbio,t)$(t.val>2030 and not swge(advbio))= advbioCost(advbio ,"2030");


parameter   advbiomkupt          Cost markup on advanced biofuels over time ;
    advbiomkupt(i,t)$advbioCost(i,t) =advbioCost(i,t)/2.747;
display advbiomkupt,advbioCost,advbiolnd0;

parameter  advblndshr(i,t)       New land share cost in the cellulosic biofuel production
           advbkdshr(i,t)        New capital share cost in the cellulosic biofuel production;

    advblndshr("frwe","2010") = p_land0("USA","frs")*1000/(bio_yield0("usa","frwe")/(5.253/3.192))/advbioCost("frwe" ,"2010");
    advblndshr("swge","2010") = p_land0("USA","crop")*1000/(bio_yield0("usa","swge")/(5.253/3.192))/advbioCost("swge" ,"2010");
    advblndshr("msce","2010") = p_land0("USA","crop")*1000/(bio_yield0("usa","msce")/(5.253/3.192))/advbioCost("msce" ,"2010");

* This share is to calibrate to its ethanol yield assumption as below (gallon of ethanol per ha):
*                   2015        2020        2025        2030        2035        2040        2045        2050
*Swge5B.Swge    1483.323    1520.065    1557.786    1596.522    1636.315    1677.175    1719.114    1762.186
*Msce5B.Msce    2947.907    3020.968    3096.017    3173.044    3252.135    3333.331    3416.669    3502.252
*FrwE5B.FrwE    1812.420    1812.420    1812.420    1812.420    1812.420    1812.420    1812.420    1812.420
* advblndshr("swge","2010") = 0.0373 is used to reach swge yield in 2010 as 1483.323 gal/ha
* advblndshr("swge","2010") = 0.0373 *2.180621 is to reach yield 15 ton/ha and feedstock and 70.9 gal/ton = 1063.6 gal/ha
* advblndshr("swge","2010") = 0.0373 *1.8127029 is to match yield 12.347 ton/ha and feedstock and 70.9 gal/ton = 875.402 gal/ha

    advblndshr("swge","2010") = 0.0373 *1.8127029 ;
    advblndshr("msce","2010") = 0.02574 ;
    advblndshr("frwe","2010") = 0.001744 ;

    advblndshr(advl,t)$(ord(t)>1) = advblndshr(advl,"2010")/advbioCost(advl,t)*advbioCost(advl,"2010");
    advbkdshr(advl,"2010")        = advbiokd0("USA","va",advl)+ advbiolnd0("USA",advl)- advblndshr(advl,"2010") ;

    advblndshr(advl,t)$(ord(t)>1) = advblndshr(advl,"2010")/bio_yldtrd("usa",advl,t)*lnd_trend("usa","crop",t)
                                   /advbioCost(advl,t)*advbioCost(advl,"2010");

    advbio_t(r,advbio)=   advbiolnd0(r,advbio)+advbiold0(r,advbio)+advbiokd0(r,"va",advbio)
                        + advbioid0(r,'eim',advbio)+ advbioid0(r,'rodf',advbio)+ advbioid0(r,'srv',advbio)
                        + sum(e,advbioed0(r,e,advbio));

display  "after", advbiolnd0,  advbiold0,advbiokd0,advbioid0,advbioed0,advbio_t;

parameter advbioshr    Advanced biofuel input share;
    advbioshr("Land",advbio) = advbiolnd0("USA",advbio);
    advbioshr("va",advbio)   = advbiokd0("USA","va",advbio);
    advbioshr("ld",advbio)   = advbiold0("USA",advbio);

    advbioshr(i,advbio)$advbioid0("USA",i,advbio)      = advbioid0("USA",i,advbio);
    advbioshr(e,advbio)$advbioed0("USA",e,advbio)      = advbioed0("USA",e,advbio);
    advbioshr("total",advbio) =  advbioshr("Land",advbio)+ advbioshr("va",advbio)
                             + advbioshr("ld",advbio)+ sum(i,advbioshr(i,advbio));
option advbioshr:5:1:1;
display advbioshr;

* Account for tax/credit
    advbiolnd0(r,advbio)      = advbiolnd0(r,advbio)  / plnd0(r,advbio);
    advbiold0(r,advbio)       = advbiold0(r,advbio)   / pld0(r,advbio);
    advbiokd0(r,"va",advbio)  = advbiokd0(r,"va",advbio)   / pkd0(r,"va",advbio);


Table resfactor(*,*)      Residue related parameters
* source: Gregg, J.S. and S.J. Smith, 2010: Global and regional potential for bioenergy from agricultural and forestry residues. Mitigation and Adaptation Strategies for Global Change, 15(3):241-262.
*   Qmax: Maximum Residue Biomass Energy Available per ha = ( Residue Ratio *Yield - Residue Retention ) * Residue Energy Content
*   drywetRatio: Residue ratio (dry residue mass/wet crop mass)
*   Retenrate:   Residue retention (metric ton/ha)
*   Engcont:     Residue Energy Content (mmbtu/metric ton)
*   b       :    Curve exponent b
*   Midprice:    Middle price to supply 50% of residue available ($2010/mmbtu)
*   Maxprice:    Maximum price to supply 100% of residue available ($2010/mmbtu)
*   ag_yield0:   ton/ha

         drywetRatio   Retenrate    Engcont     b     Midprice    Maxprice
Wht         1.49        2.81        15.36    10.83     2.43        4.09
Rice        0.99        0.94        12.83    10.83     2.43        4.09
Corn        0.74        2.20        15.97    10.83     2.43        4.09
Gron        1.02        1.09        14.40    10.83     2.43        4.09
Osdn        1.28        1.26        12.56    10.83     2.43        4.09
Srcn        0.28        1.24        14.41    10.83     2.43        4.09
Ocr         0.38        0.38         7.74    10.83     2.43        4.09
*timber     0.33        20.00       17.93     7.02     2.90        5.84
frs         0.33        0.00        17.93     7.02     2.90        5.84
Mill        0.30        0.00        18.94     1.46     1.71        6.43
Soyb        1.28        1.26        12.56    10.83     2.43        4.09
Srbt        0.28        1.24        14.41    10.83     2.43        4.09
;

parameter residueE0_btu(r,*,t)   AG and forest residue endowment (quad btu)
          residueE0_val(r,*,t)   Ag and forest residue endowment ($billion) ;

     q_land0(r,"ocr") = q_land0(r,"ocr")- rice0(r,"area");
     residueE0_btu(r,i,"2010") =   (resfactor(i,"drywetRatio")*ag_yield0(r,i)- resfactor(i,"Retenrate") )
                               * resfactor(i,"Engcont")
                               * q_land0(r,i)
                               / 1000;

     residueE0_btu(r,"rice","2010") =  (resfactor("rice","drywetRatio")*rice0(r,"yield")- resfactor("rice","Retenrate") )
                                    * resfactor("rice","Engcont")
                                    * rice0(r,"area")
                                   /  1000;

     residueE0_btu(r,"mill","2010") = (resfactor("mill","drywetRatio")*ag_yield0(r,"frs")- resfactor("mill","Retenrate") )
                                     * resfactor("mill","Engcont")
                                     * q_land0(r,"frs")
                                     / 1000;

     residueE0_btu(r,i,"2010")$(residueE0_btu(r,i,"2010")<0)=0;
     residueE0_btu(r,"rice","2010")$(residueE0_btu(r,"rice","2010")<0)=0;

     residueE0_btu(r,"arsE","2010") =  sum(crp, residueE0_btu(r,crp,"2010"))+ residueE0_btu(r,"rice","2010");
     residueE0_val(r,"arsE","2010") =  sum(crp, residueE0_btu(r,crp,"2010")*resfactor(crp,"Midprice"))  + residueE0_btu(r,"rice","2010")*resfactor("rice","Midprice") ;

     residueE0_btu(r,"frsE","2010") = residueE0_btu(r,"frs","2010")+residueE0_btu(r,"mill","2010") ;
     residueE0_val(r,"frsE","2010") = residueE0_btu(r,"frsE","2010")*resfactor("frs","Midprice")+residueE0_btu(r,"mill","2010")*resfactor("mill","Midprice");

     residueE0_btu(r,crp,"2010")   = 0;
     residueE0_btu(r,"rice","2010")= 0;
     residueE0_btu(r,"frs","2010") = 0;
     residueE0_btu(r,"mill","2010")= 0;
display  residueE0_btu,residueE0_val,q_land0;


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*            Introduce Physical data in transportation sector
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
* Data is from GCAM and AEO2015
parameter
* Data are from GCAM
       tran_pricT0_10      Price (2010$ per ton-mile for freight and 2010$ per passenger-mile for passenger) from 2010 to 2050
       tran_loadf0_10      Average load factor in transportation sector (persons per vehicle for passenger and ton per vehicle for freight) from 2010 to 2050
       tran_pvmtT0_10      Price of miles traveled by transportation sector by vehicle ($ per vmt for passenger or $ per ton for freight) from 2010 to 2050
       tran_vmt0_10        Vehicle miles traveled by transportation sectors (billion miles) in 2010
       tran_mpge0_10       Miles per gallon of gasoline equivalent in 2010

       auto_pricT0         Price (2010$ per pass-mile for passenger) from 2010 to 2050
       auto_loadf0         Average load factor (which differs by type then assumed to be same as gasoline car later)
       auto_loadfT0        Load factor over the time (which differs by type and time then assumed to be same as gasoline car later)
       auto_mpgeT0         Auto mpge from 2010 to 2050 (mile traveled per gallon of gasoline equivalent) (For USA GCAM data is replaced by AEO2015 data where LDV is EPA-rated fuel efficiency)
       auto_enpricT0       Auto energy price ($ per mmbtu) from 2010 to 2050
       auto_vmtT0          Vehicle miles traveled by auto sectors (billion miles) from 2010 to 2050

* Data are from AEO2015
       USA_auto_price0     New car sales price in USA from AEO2015 ($ thousand)
       USA_auto_enmix0     Enegy mix share in AFV in USA from AEO2015
       USA_auto_stock0     USA auto stock from 2010 to 2050 from AEO2015 (million) (includes both new and used vehicles)
       USA_auto_vmtV0      USA average auto vehicle mile traveled per vehicle (thousand miles per vehicle)

       afv_markupt0          Alternative fuel vehicle markup relative to conventional gasoline vehicle
;

$gdxin  '.\data\data6_tran.gdx'
$load  tran_pricT0_10=tran_pricT0  tran_loadf0_10=tran_loadf0 tran_pvmtT0_10=tran_pvmtT0 tran_vmt0_10=tran_vmt0   tran_mpge0_10=tran_mpge0
$load  auto_pricT0=auto_pricT0  auto_loadfT0=auto_loadfT0 auto_loadf0=auto_loadf0 auto_mpgeT0=auto_mpgeT0  auto_enpricT0=auto_enpricT0  auto_vmtT0=auto_vmtT0
$load USA_auto_price0=USA_auto_price0  USA_auto_enmix0=USA_auto_enmix0 USA_auto_stock0=USA_auto_stock0

* Heavy duty and light-duty bus transportation in tran_vmt0 for XAS and CHN are not accounted, now we need to add it back using GCAM data
parameter Fvmt_RodP_10(r,i) factor used to adjust vmt in the bus transportation ;
    Fvmt_rodP_10(r,trnall) = 1;
    Fvmt_rodP_10("CHN","rodP")     = 64.96935324;
    Fvmt_rodP_10("XAS","rodP")     = 1.036754452;
    Fvmt_rodP_10("CHN","rodP_OEV") = Fvmt_rodP_10("CHN","rodP");
    Fvmt_rodP_10("XAS","rodP_OEV") = Fvmt_rodP_10("XAS","rodP");

* In case transportation sectors are aggregated
parameter  tran_vmt0_10_(r,i)          Vehicle miles traveled by transportation sectors (billion miles) in 2010
           tran_mpge0_10_(r,i)         Miles per gallon of gasoline equivalent in 2010
           tran_pricT0_10_(r,i,t)      Price (2010$ per ton-mile for freight and 2010$ per pass-mile for passenger) from 2010 to 2050
           tran_loadf0_10_(r,i)        Average load factor in transportation sector (persons per vehicle for passenger and ton per vehicle for freight) from 2010 to 2050
           tran_pvmtT0_10_(r,i,t)      Price of miles traveled by transportation sector by vehicle ($ per vmt for passenger or $ per ton for freight) from 2010 to 2050
           Fvmt_RodP_10_(r,i)          Weighted factor to adjust the vmt due to adjustment in bus transportation

           tran_vmt0(r,i)              Vehicle miles traveled by transportation sectors (billion miles) in 2010
           tran_mpge0(r,i)             Miles per gallon of gasoline equivalent in 2010
           tran_pricT0(r,i,t)          Price (2010$ per ton-mile for freight and 2010$ per pass-mile for passenger) from 2010 to 2050
           tran_loadf0(r,i)            Average load factor in transportation sector (persons per vehicle for passenger and ton per vehicle for freight) from 2010 to 2050
           tran_pvmtT0(r,i,t)          Price of miles traveled by transportation sector by vehicle ($ per vmt for passenger or $ per ton for freight) from 2010 to 2050
           Fvmt_RodP0(r,i)             Weighted factor to adjust the vmt due to adjustment in bus transportation;

    tran_vmt0_10_(r,ii)  = sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i));

    tran_mpge0_10_(r,ii)$sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i))
       = sum(mapsector(ii,i)$trni(i),tran_mpge0_10(r,i)*tran_vmt0_10(r,i))
        /sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i));

    tran_pricT0_10_(r,ii,t)$sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i))
       =  sum(mapsector(ii,i)$trni(i),tran_pricT0_10(r,i,t)*tran_vmt0_10(r,i)*tran_loadf0_10(r,i))
         /sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i)*tran_loadf0_10(r,i));

    tran_loadf0_10_(r,ii)$sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i))
      =  sum(mapsector(ii,i)$trni(i),tran_loadf0_10(r,i)*tran_vmt0_10(r,i))
        /sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i));

    tran_pvmtT0_10_(r,ii,t)$sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i))
      =  sum(mapsector(ii,i)$trni(i),tran_pvmtT0_10(r,i,t)*tran_vmt0_10(r,i))
        /sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i));

    Fvmt_RodP_10_(r,ii)$sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i))
      = sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i)*Fvmt_RodP_10(r,i))
       /sum(mapsector(ii,i)$trni(i),tran_vmt0_10(r,i));


    tran_vmt0(r,ii)       = tran_vmt0_10_(r,ii)    ;
    tran_mpge0(r,ii)      = tran_mpge0_10_(r,ii)   ;
    tran_pricT0(r,ii,t)   = tran_pricT0_10_(r,ii,t);
    tran_loadf0(r,ii)     = tran_loadf0_10_(r,ii)  ;
    tran_pvmtT0(r,ii,t)   = tran_pvmtT0_10_(r,ii,t);
    Fvmt_RodP0(r,ii)      = Fvmt_RodP_10_(r,ii);

scalar onroadeff      Onroad efficiency rate (ratio respect to EPA-rated fuel efficiecy)  /0.8/;

Table   USA_auto_mpge(*,t)    New vehicle mpge in USA in auto_OEV over time in AEO2019 (actual fuel efficiency)
* This is copied from auto_FEdata_20190531.xlsx
* Data is from AEO2015 for 2010 and 2015 and AEO2019 from 2020~2050
                  2010          2015          2020          2025          2030          2035          2040          2045        2050
Auto_OEV        24.828        25.474        28.132        35.341        35.537        35.451        35.192        34.950        34.546
Auto_BEV        76.523        78.513        86.706        94.119        94.274        94.997        95.302        95.262        94.976
Auto_GasV       23.605        24.134        26.937        34.504        34.810        34.924        34.788        34.656        34.322
Auto_HEV        41.013        42.240        46.548        56.167        56.240        55.970        55.553        54.960        54.205
Auto_FCEV       36.120        36.120        39.502        42.984        42.887        43.145        43.390        43.653        43.706
;

$include .\data\data7a_US_aeo2019_data.dat
* It is renamed from US_aeo2019_data.dat generated from read_auto_aeo2019.gms in tran_data
* parameter usa_mpget0          AEO2019: new AFV vehicles mpge in USA for auto_AFV and RodF_AFV(Auto_AFV is EPA_Rated but RodF_AFV is actual) (mile per gallon of oile)
*           usa_vmtt0           AEO2019: new AFV vehicles mile-traveled (billion vmt traveled)
* RodP_AFV is not available in AEO2019

* Convert  usa_mpget0 in aeo2019 to actual fuel economy
   usa_mpget0("auto_OEV",t) = USA_auto_mpge("auto_OEV",t);
   usa_mpget0(autoafv,t)    = USA_auto_mpge(autoafv,t);

* For USA, mpge in USA in Auto_OEV is actual fuel economy from GCAM
* For all other regions, mpge for all technology is already the onroad fuel efficiency
* Auto_FCEV in USA in AEO is small so it is replaced with GCAM projections
    auto_mpgeT0("USA","auto_OEV",t)     = USA_auto_mpge("Auto_OEV",t) ;
    auto_mpgeT0("USA",autoafv,t)$(not sameas(autoafv,"auto_FCEV"))  = USA_auto_mpge(autoafv,t);
display  usa_mpget0,usa_vmtt0 ,tran_vmt0,tran_loadf0, auto_mpgeT0;

* Fill up missing value in 2010 and 2015 for modeling purpose
    auto_mpgeT0(r,Autoafv,"2005") = 0 ;
    auto_mpgeT0(r,Autoafv,"2015")$(auto_mpgeT0(r,Autoafv,"2015")=0)
       = auto_mpgeT0(r,Autoafv,"2020")*auto_mpgeT0(r,Autoafv,"2020")/auto_mpgeT0(r,Autoafv,"2025");
    auto_mpgeT0(r,Autoafv,"2010")$(auto_mpgeT0(r,Autoafv,"2010")=0)
       = auto_mpgeT0(r,Autoafv,"2015")*auto_mpgeT0(r,Autoafv,"2015")/auto_mpgeT0(r,Autoafv,"2020");

display  auto_mpgeT0;

* Afr and xas in auto_gasV and auto_HEV: mpge is much smaller in 2010 and much larger in 2015 than in later years, so 2010 and 2015 are linearly interpolated using later years data.
    auto_mpgeT0(r,"Auto_gasv","2015")$(sameas(r,"afr") or sameas (r,"xas"))   = auto_mpgeT0(r,"Auto_gasv","2020")*auto_mpgeT0(r,"Auto_gasv","2020")/auto_mpgeT0(r,"Auto_gasv","2025");
    auto_mpgeT0(r,"Auto_gasv" ,"2010")$(sameas(r,"afr") or sameas (r,"xas"))  = auto_mpgeT0(r,"Auto_gasv" ,"2015")*auto_mpgeT0(r,"Auto_gasv" ,"2015")/auto_mpgeT0(r,"Auto_gasv" ,"2020");
    auto_mpgeT0(r,"Auto_HEV","2015")$sameas(r,"afr")   = auto_mpgeT0(r,"Auto_HEV","2020")*auto_mpgeT0(r,"Auto_HEV","2020")/auto_mpgeT0(r,"Auto_HEV","2025");
    auto_mpgeT0(r,"Auto_HEV" ,"2010")$sameas(r,"afr")  = auto_mpgeT0(r,"Auto_HEV" ,"2015")*auto_mpgeT0(r,"Auto_HEV" ,"2015")/auto_mpgeT0(r,"Auto_HEV" ,"2020");

* Load factor in GCAM is weighted average from class size and different over time
    auto_loadfT0(r,autoafv,"2015")$(auto_loadfT0(r,autoafv,"2015")=0)
       = auto_loadfT0(r,autoafv,"2020")*auto_loadfT0(r,autoafv,"2020")/auto_loadfT0(r,autoafv,"2025");
    auto_loadfT0(r,autoafv,"2010")$(auto_loadfT0(r,autoafv,"2010")=0)
       = auto_loadfT0(r,autoafv,"2015")*auto_loadfT0(r,autoafv,"2015")/auto_loadfT0(r,autoafv,"2020");

* Load factor is assumed to be same as OEV to simplify the problem
    auto_loadfT0(r,autoafv,t)= tran_loadf0(r,"auto");
    auto_loadf0(r,autoafv)   = tran_loadf0(r,"auto");

* Fill in the missing data
    auto_enpricT0(r,Autoafv,"2015")$(auto_enpricT0(r,Autoafv,"2015")=0)
       = auto_enpricT0(r,autoafv,"2020")*auto_enpricT0(r,autoafv,"2020")/auto_enpricT0(r,autoafv,"2025");
    auto_enpricT0(r,autoafv,"2010")$(auto_enpricT0(r,autoafv,"2010")=0)
       = auto_enpricT0(r,autoafv,"2015")*auto_enpricT0(r,autoafv,"2015")/auto_enpricT0(r,autoafv,"2020");

Table AutoTrgt_mpge(*,t)   Auto (LDV) mpge target in USA for new vehicles only (both OEV and AFV) (miles per gallon of gasoline equivalent)
* Include only new auto_OEV and AFVs
* Received from EPA on 2019-04-09: "2019.04.8 LDVR  HDVR Assumptions for ADAGE.xlsx"
         2010     2015     2020      2025      2030      2035     2040    2045      2050
Auto   21.948   27.931   33.913    42.434    42.434    42.434   42.434  42.434    42.434
;

AutoTrgt_mpge("auto","2010")  = auto_mpgeT0("USA","auto_OEV","2010");
AutoTrgt_mpge("auto","2015")  = 0.5* auto_mpgeT0("USA","auto_OEV","2010")+ 0.5*AutoTrgt_mpge("auto","2020");

Table usa_hdv_mpge(*,t)    Fuel economy for conventional new HDV vehicles in USA  (mile per gallon oil)
*Rodf_OEV: 2010 and 2015 values are from the fuel economy target in HDVtargt_mpge, 2020~2050 from AEO2019
*Rodp_OEV: 2010 and 2015 values from FHWA, 2020-2030 assume FE growth similar to Phase II HD vehicle rule; assume 1% growth/year after that
                 2010    2015   2020    2025     2030    2035    2040     2045    2050
Rodf_OEV        8.366   8.993  8.166   9.032   10.061  10.342  10.467   10.595  10.743
RodP_OEV        6.500   6.669  7.469   8.003    8.270   8.691   9.135    9.601  10.090
;

* As 2020~2025 in rodf_OEV is below the value in 2015, so linear interpolation is used for 2020 and 2025
usa_hdv_mpge("rodf_OEV","2020")= 2/3*usa_hdv_mpge("rodf_OEV","2015")+1/3*usa_hdv_mpge("rodf_OEV","2030");
usa_hdv_mpge("rodf_OEV","2025")= 1/3*usa_hdv_mpge("rodf_OEV","2015")+2/3*usa_hdv_mpge("rodf_OEV","2030");

* Make the data set consistent in many places
usa_mpget0("rodf_OEV",t)       = usa_hdv_mpge("rodf_OEV",t);


Table HDVtrgt_mpge(trn,t)  Heavy duty vehicles target for new vehicles only (both OEV and AFV) (mile per gallon of gasoline equivalent)
* Received from EPA in 2019-04-09: "2019.04.8 LDVR  HDVR Assumptions for ADAGE.xlsx"
         2010   2015    2020     2025     2030     2035     2040     2045     2050
RodF    8.366   8.993   9.891   10.791   10.791   10.791   10.791   10.791   10.791
RodP    6.074   6.669   7.788    8.534    8.534    8.534    8.534    8.534    8.534
;

parameter targt_mpgeT(r,*,t)        mpge target for USA for onroad new vehicle
          targt_mpge(r,*)           mpge target for USA for onroad new vehicle ;
    targt_mpgeT("USA",trn,t)      = HDVtrgt_mpge(trn,t);
    targt_mpgeT("USA","auto",t)   = AutoTrgt_mpge("auto",t);
    targt_mpge("USA",trnv)        = targt_mpgeT("USA",trnv,"2010");

parameter pmt_mpge(i,t)            Price of fuel economy permit for new vehicle
          pmt(i)                   Price of fuel economy permit for new vehicle;
* initial permit price is set to compensate the onroad fuel economy, RodP_AFV has higher cost than OEV so permit price is set higher to promote faster penetration of AFV
* so it can meet the fuel economy target
pmt(trnv)=1;
pmt_mpge(trnv,t) =1;
pmt_mpge("rodp",t)$(t.val<2020) = 3;
pmt_mpge("rodp",t)$(t.val=2020) = 9;
pmt_mpge("rodp",t)$(t.val>2020) = 6;

$ifthen setglobal AN
    targt_mpgeT("USA",hdv,t) = 0;
    targt_mpge("USA",hdv)    = 0;
    pmt_mpge(hdv,t)          = 0;
    pmt(hdv)                 = 0;
$endif

display  targt_mpgeT,targt_mpge;

* Data from GCAM and adjusted by EPA assumption on battery cost
$include .\data\data7b_afv_EPA.dat       !updated 03-12-2020
*parameter auto_noencost       nonenergy cost
*               kd0            Total capital cost ($/passenger-mile-traveled or ton-mile-traveled)
*               kd0_purc       Capital cost_vehicle purchasing cost ($/passenger-mile-traveled or ton-mile-traveled)
*               kd0_infr       Capital cost_vehicle infrastructure cost ($/passenger-mile-traveled or ton-mile-traveled)
*               kd0_othr       Capital cost_other capital cost ($/passenger-mile-traveled or ton-mile-traveled)
*               id0            Material input cost($/passenger-mile-traveled or ton-mile-traveled)
*               mant           Material cost_specially assigned to service cost in ADAGE ($/passenger-mile-traveled or ton-mile-traveled)
*               noen           Total non-energy cost (sum of kd0+id0) ($/passenger-mile-traveled or ton-mile-traveled)

*parameter afv_mpge0                    AFV fuel economy
*parameter afv_kc_coef(r,afv,t)         AFV capital cost ratio (no infrastructure cost) relative to refined oil transportation
*          afv_mpge_coef(r,afv,t)       AFV fuel efficiency ratio relative to refined oil transportation
*          afv_mant_coef(r,afv)         AFV maintenance cost ratio relative to refined oil transportation  (similar as service in LDV)
*          afv_mant_coef2(r,afv)        AFV maintenance cost share in the overall "id0" cost in refined oil transportation  (similar as service in LDV)

* fill up missing value in 2010 and 2015 for modeling purpose
    afv_kc_coef(r,hdvi,"2015")= afv_kc_coef(r,hdvi,"2020")*afv_kc_coef(r,hdvi,"2020")/afv_kc_coef(r,hdvi,"2025");
    afv_kc_coef(r,hdvi,"2010")= afv_kc_coef(r,hdvi,"2015")*afv_kc_coef(r,hdvi,"2015")/afv_kc_coef(r,hdvi,"2020");

set  r3   3 regions without capital cost adjustment  /AFR, CHN, XAS/;
parameter afv_kc_coef1 ;
    afv_kc_coef1(r,i,t)$(oev(i) ) = 1 ;
    afv_kc_coef1(r,i,t)$(autoafv(i)) = afv_kc_coef(r,i,t);
    afv_kc_coef1(r,i,t)$(gasv(i) and hdvafv(i)) = afv_kc_coef(r,"auto_GasV",t);
    afv_kc_coef1(r,i,t)$(t.val<=2025 and hev(i) and hdvafv(i)) = afv_kc_coef(r,i,t);
    afv_kc_coef1(r,i,t)$(t.val>2025  and hev(i) and hdvafv(i)) = afv_kc_coef(r,"auto_hev",t-2);
    afv_kc_coef1(r,i,t)$(t.val<=2025 and bev(i) and hdvafv(i)) = afv_kc_coef(r,i,t);
    afv_kc_coef1(r,i,t)$(t.val>2025  and bev(i) and hdvafv(i)) = afv_kc_coef(r,"auto_bev",t-2);
    afv_kc_coef1(r,i,t)$(t.val<=2025 and fcev(i) and hdvafv(i))= afv_kc_coef(r,i,t);
    afv_kc_coef1(r,i,t)$(t.val>2025  and fcev(i) and hdvafv(i))= afv_kc_coef(r,"auto_fcev",t-2);
    afv_kc_coef1(r3,i,t)$(hev(i) or bev(i) or fcev(i))         =  afv_kc_coef(r3,i,t);
display  afv_kc_coef,afv_kc_coef1;

    afv_mpge_coef(r,hdvafv,"2010")$(afv_mpge_coef(r,hdvafv,"2010")=0 and afv_mpge_coef(r,hdvafv,"2015"))
       = afv_mpge_coef(r,hdvafv,"2015");

* Update gasv fuel economy ratio based on EPA assumption. It is same for other AFVs.
    afv_mpge_coef(r,"rodf_gasv",t)= 0.9;
    afv_mpge_coef(r,"rodp_gasv",t)= 0.9;

parameter afv_kc_coef_infras         Infrastructure cost relative to capital cost excluding infrastructure cost in non-gasv ;
* Infrastructure cost is included in Auto_BEV and Auto_FCEV in GCAM and ADAGE, but not in Auto_GASV, now updated auto_noencost includes infrastructure cost for auto_gasv now
* We continue to expand the assumption to HDV_AFV using same ratio from LDV_AFV
    afv_kc_coef_infras(r,gasv,t) =    auto_noencost(r, "auto_GASV","kd0_infr",t)
                                   /( auto_noencost(r, "auto_GASV","kd0_purc",t)+ auto_noencost(r, "auto_GASV","kd0_othr",t));
    afv_kc_coef_infras(r,bev,t)  =    auto_noencost(r, "auto_bev","kd0_infr",t)
                                   /( auto_noencost(r, "auto_bev","kd0_purc",t) + auto_noencost(r, "auto_bev","kd0_othr",t));
    afv_kc_coef_infras(r,fcev,t) =    auto_noencost(r, "auto_fcev","kd0_infr",t)
                                   /( auto_noencost(r, "auto_fcev","kd0_purc",t)+ auto_noencost(r, "auto_fcev","kd0_othr",t));

display afv_kc_coef_infras;

parameter          chk0_kc           compare capital cost markup excluding infrastructure cost
                   chk0_kct          compare capital cost markup including infrastructure cost   ;

    chk0_kc(r,i,"old",t) =  afv_kc_coef(r,i,t) ;
    chk0_kc(r,i,"new",t) =  afv_kc_coef1(r,i,t);

    chk0_kct(r,i,"old",t)$autoi(i) =  afv_kc_coef(r,i,t)*(1+afv_kc_coef_infras(r,i,t)) ;
    chk0_kct(r,i,"old",t)$hdvi(i)  =  afv_kc_coef(r,i,t) ;
    chk0_kct(r,i,"new",t)          =  afv_kc_coef1(r,i,t)*(1+afv_kc_coef_infras(r,i,t));
display chk0_kc, chk0_kct;

set  mapafv(j,i)
           /Auto_OEV  .(  RodF_OEV  ,  RodP_OEV  )
            Auto_gasV .(  RodF_GasV ,  RodP_GasV )
            Auto_BEV  .(  RodF_BEV  ,  RodP_BEV  )
            Auto_HEV  .(  RodF_HEV  ,  RodP_HEV  )
            Auto_FCEV .(  RodF_FCEV ,  RodP_FCEV )
          /


parameter afv_enmix0(i,*)    AFV energy mix ratio
          afv_ensup0(i,*)    FCEV additional input cost (produce & supply FCEV) relative to energy cost
          afv_mpge0(r,i)     AFV mpge (mile per gallon) starting in 2010 for LDV and 2020 for HDV
          afv_mpgeT0(r,i,t)  AFV mpge (mile per gallon) from 2010 to 2050 ;

* Assume energy mix share is the same in AFVs in auto and hdv
    afv_enmix0(afv,e)$autoi(afv)  = USA_auto_enmix0(afv,e)/sum(ee,USA_auto_enmix0(afv,ee));
    afv_enmix0(afv,e)$hdvi(afv)   = sum(mapafv(autoi,afv), afv_enmix0(autoi,e));
    afv_enmix0("RodF_gasV","gas") = 1;
    afv_enmix0("RodF_gasV","oil") = 0;
    afv_enmix0("RodP_gasV","gas") = 1;
    afv_enmix0("RodP_gasV","oil") = 0;

    afv_ensup0(afv,"ld0")$autoi(afv) = USA_auto_enmix0(afv,"ld0")/sum(ee,USA_auto_enmix0(afv,ee));
    afv_ensup0(afv,"kd0")$autoi(afv) = USA_auto_enmix0(afv,"kd0")/sum(ee,USA_auto_enmix0(afv,ee));
    afv_ensup0(afv,"ld0")$hdvi(afv)  = sum(mapafv(autoi,afv), afv_ensup0(autoi,"ld0")) ;
    afv_ensup0(afv,"kd0")$hdvi(afv)  = sum(mapafv(autoi,afv), afv_ensup0(autoi,"kd0"))*0.75 ;
    afv_ensup0(afv,"hkd0")$hdvi(afv) = sum(mapafv(autoi,afv), afv_ensup0(autoi,"kd0"))*0.25 ;

    afv_mpge0(r,autoi)     =  auto_mpgeT0(r,autoi,"2010");
    afv_mpgeT0(r,autoi,t)  =  auto_mpgeT0(r,autoi,t);
    afv_mpge_coef(r,autoi,t)= auto_mpgeT0(r,autoi,t)/auto_mpgeT0(r,"auto_OEV",t);

* Assume mpge in OEV in LDV and HDV grow at same rate
    afv_mpgeT0(r,"RodF_OEV",t)$(not num(r)) = tran_mpge0_10(r,"RodF")* auto_mpgeT0(r,"Auto_OEV",t)/auto_mpgeT0(r,"Auto_OEV","2010");
    afv_mpgeT0(r,"RodP_OEV",t)$(not num(r)) = tran_mpge0_10(r,"RodP")* auto_mpgeT0(r,"Auto_OEV",t)/auto_mpgeT0(r,"Auto_OEV","2010");
    afv_mpgeT0(r,rodfafv,t)$(not num(r))    = afv_mpgeT0(r,"RodF_OEV",t)*afv_mpge_coef(r,rodfafv,t);
    afv_mpgeT0(r,rodpafv,t)$(not num(r))    = afv_mpgeT0(r,"RodP_OEV",t)*afv_mpge_coef(r,rodpafv,t);

    afv_mpgeT0(r,"RodF_OEV",t)$num(r)      = usa_hdv_mpge("RodF_OEV",t);
    afv_mpgeT0(r,"RodP_OEV",t)$num(r)      = usa_hdv_mpge("RodP_OEV",t);
    afv_mpgeT0(r,rodfafv,t)$num(r)          = afv_mpgeT0(r,"RodF_OEV",t)*afv_mpge_coef(r,rodfafv,t)  ;
    afv_mpgeT0(r,rodpafv,t)$num(r)          = afv_mpgeT0(r,"RodP_OEV",t)*afv_mpge_coef(r,rodpafv,t);

    afv_mpge0(r,hdvi)      = afv_mpgeT0(r,hdvi,"2010");
display afv_mpge_coef,afv_kc_coef,afv_mpget0,afv_mpge0;

* GTAP data shows no tax for auto_OEV but + tax for rodF_OEV and RodP_OEV.
* Assuming the tax rate for afvs is same as its conventional technology
* In addition, assume 15% tax subsidies included for AFVs
    ty(r,oev) =  sum(mapoev(oev,i), ty(r,i));
    ty(r,i)$(autoafv(i) or hdvafv(i))  =  -0.15 ;
    tl(r,i)$(autoi(i) or hdvi(i))  =  sum(maptrn(j,i),tl(r,j))  ;
    tk(r,k,i)$(autoi(i) or hdvi(i))=  sum(maptrn(j,i),tk(r,k,j));
    ti(r,g,i)$(autoi(i) or hdvi(i))=  sum(maptrn(j,i),ti(r,g,j));
    thk(r,i)$(autoi(i) or hdvi(i)) =  sum(maptrn(j,i),thk(r,j)) ;

    pld0(r,i)  = 1+ tl(r,i)  ;
    pkd0(r,k,i)= 1+ tk(r,k,i);
    pid0(r,g,i)= 1+ ti(r,g,i);
    phkd0(r,i) = 1+ thk(r,i);

parameter tran_cost0              Input cost in transportation sector in OEV (2010$ per passenger-mile for passenger) in 2010 (including tax)
          afv_costT0(r,i,*,t)     AFV service cost over the time ($2010 per passenger-mile-traveled or ton-mile-traveled) (including tax)

          afv_yt0                 AFV total cost relative to corresponding OEV over the time
          afv_ldt0                AFV labor cost share relative to corresponding OEV over the time
          afv_idt0                AFV intermediate goods cost share relative to corresponding OEV  over the time
          afv_edt0                AFV energy cost share relative to corresponding OEV over the time
          afv_kdt0                AFV capital cost share relative to corresponding OEV over the time
          afv_hkdt0               AFV human capital cost share relative to corresponding OEV over the time
          afv_fft0                AFV fixed factor share relative to corresponding OEV over the time
          afv_edtrdt0             AFV energy efficiency trend (1 in 2010)

          afv_y0                  AFV total cost in 2010
          afv_ld0                 AFV labor cost share in 2010
          afv_id0                 AFV intermediate goods cost share in 2010
          afv_ed0                 AFV energy cost share in 2010
          afv_kd0                 AFV capital cost share in 2010
          afv_hkd0                AFV human capital cost share in 2010
          afv_ff0                 AFV fixed factor ($billion)
          afv_edtrd0              AFV energy efficiency trend (1 in 2010)

          afv_vmtT0(r,afv,v,t)    AFV Vehicle-mile-traveled pathway (billion miles)
          afv_yent0(r,afv,v,t)    AFV service production pathway ($billion)
          afv_ffen0(r,afv,v)      AFV fixed factor endowment pathway (billion $)

          afv_t0(r,afv,v,t)       Year where AFV is available into the market
          afvmarkup(r,afv,v)      Markup for alternative fuel vehicle

          chk0_afvt0              Check AFVs input share
;

    tran_cost0(r,trnv,"y0")  = y0_10(r,trnv,"new","2010")*(1-ty_10(r,trnv))/(tran_vmt0_10(r,trnv)*tran_loadf0_10(r,trnv));
    tran_cost0(r,trnv,"id0") = sum(g,id0_10(r,g,trnv,"new","2010")*(1+ti_10(r,g,trnv)))/(tran_vmt0_10(r,trnv)*tran_loadf0_10(r,trnv));
    tran_cost0(r,trnv,g)     = id0_10(r,g,trnv,"new","2010")*(1+ti_10(r,g,trnv))/(tran_vmt0_10(r,trnv)*tran_loadf0_10(r,trnv));

    tran_cost0(r,trnv,"kd0") = sum(k,kd0_10(r,k,trnv,"new","2010")*(1+tk_10(r,k,trnv)))/(tran_vmt0_10(r,trnv)*tran_loadf0_10(r,trnv));
    tran_cost0(r,trnv,"hkd0")= hkd0_10(r,trnv,"new","2010")*(1+thk_10(r,trnv))/(tran_vmt0_10(r,trnv)*tran_loadf0_10(r,trnv));
    tran_cost0(r,trnv,"ld0") = ld0_10(r,trnv,"new","2010")*(1+tl_10(r,trnv))/(tran_vmt0_10(r,trnv)*tran_loadf0_10(r,trnv));
    tran_cost0(r,trnv,"ed0") = sum(e,ed0_10(r,e,"fuel",trnv,"new","2010"))/(tran_vmt0_10(r,trnv)*tran_loadf0_10(r,trnv));
    tran_cost0(r,trnv,e)     = ed0_10(r,e,"fuel",trnv,"new","2010")/(tran_vmt0_10(r,trnv)*tran_loadf0_10(r,trnv));

    tran_cost0(r,trnv,"bal")= round((  tran_cost0(r,trnv,"y0")
                                     - tran_cost0(r,trnv,"id0")
                                     - tran_cost0(r,trnv,"kd0")
                                     - tran_cost0(r,trnv,"hkd0")
                                     - tran_cost0(r,trnv,"ld0")
                                     - tran_cost0(r,trnv,"ed0")     ),7);

* Energy input cost in AFV
    afv_costT0(r,hdvi,e,t)$(afv_mpgeT0(r,hdvi,t) and afv_enmix0(hdvi,e))
         = 1/afv_mpgeT0(r,hdvi,t)
          *btu_gal("oil")* afv_enmix0(hdvi,e)
          /btu_conv(r,e,"fuel",hdvi)
          /sum(maptrn(hdv,hdvi),tran_loadf0_10(r,hdv)) ;

    afv_costT0(r,autoi,e,t)$(afv_mpgeT0(r,autoi,t) and afv_enmix0(autoi,e))
         = 1/afv_mpgeT0(r,autoi,t)
          *btu_gal("oil")* afv_enmix0(autoi,e)
          /btu_conv(r,e,"fuel",autoi)
          /tran_loadf0_10(r,"auto") ;

display  afv_enmix0,afv_mpgeT0,tran_cost0;

    afv_costT0(r,autoi,e,t)$(not AFV(autoi)) = sum(maptrn(auto,autoi),tran_cost0(r,auto,e))
                                             *afv_mpgeT0(r,autoi,"2010")/afv_mpgeT0(r,autoi,t);
    afv_costT0(r,autoi,"ed0",t)              = sum(e,afv_costT0(r,autoi,e,t));

    afv_costT0(r,hdvi,e,t)$(not AFV(hdvi))  = sum(maptrn(hdv,hdvi),tran_cost0(r,hdv,e))
                                            *afv_mpgeT0(r,hdvi,"2010")/afv_mpgeT0(r,hdvi,t);
    afv_costT0(r,hdvi,"ed0",t)              = sum(e,afv_costT0(r,hdvi,e,t));

    afv_costT0(r,i,e,"2010")$((autoi(i) or hdvi(i)) and afv_costT0(r,i,e,"2010")=0 and  afv_costT0(r,i,e,"2015"))
       = afv_costT0(r,i,e,"2015");

    afv_costT0(r,i,"ed0","2010")$((autoi(i) or hdvi(i)) and afv_costT0(r,i,"ed0","2010")=0 and  afv_costT0(r,i,"ed0","2015"))
       = afv_costT0(r,i,"ed0","2015");


    afv_costT0(r,autoi,"ld0",t)$auto_noencost(r,"auto_oev","ld0","2010")
        =     sum(maptrn(auto,autoi),  tran_cost0(r,auto,"ld0"))
            * auto_noencost(r,autoi,"ld0",t)/auto_noencost(r,"auto_oev","ld0","2010");

    afv_costT0(r,autoi,"ld0",t)=     afv_costT0(r,autoi,"ld0",t)
                                 +  afv_costT0(r,autoi,"ed0",t) *afv_ensup0(autoi,"ld0");

    afv_costT0(r,hdvi,"ld0",t) =  sum(maptrn(hdv,hdvi),tran_cost0(r,hdv,"ld0"))
                                  + afv_costT0(r,hdvi,"ed0",t) *afv_ensup0(hdvi,"ld0");
    afv_costT0(r,i,"ld0","2010")$((autoi(i) or hdvi(i)) and afv_costT0(r,i,"ld0","2010")=0 and  afv_costT0(r,i,"ld0","2015"))
       = afv_costT0(r,i,"ld0","2015");

    afv_costT0(r,autoi,"kd0",t)=     sum(maptrn(auto,autoi),  tran_cost0(r,auto,"kd0"))

* Difference between Auto and HDV is no need to add afv_kc_coef_infras in auto_afv as kd0 already include kd0_infr
                                   * auto_noencost(r,autoi,"kd0",t)/auto_noencost(r,"auto_oev","kd0","2010")
                                  +  afv_costT0(r,autoi,"ed0",t) *afv_ensup0(autoi,"kd0");

    afv_costT0(r,hdvi,"kd0",t) =  sum(maptrn(hdv,hdvi),tran_cost0(r,hdv,"kd0") *afv_kc_coef1(r,hdvi,t)*(1+afv_kc_coef_infras(r,hdvi,t)) )
                                   + afv_costT0(r,hdvi,"ed0",t) *afv_ensup0(hdvi,"kd0");

    afv_costT0(r,i,"kd0","2010")$((autoi(i) or hdvi(i)) and afv_costT0(r,i,"kd0","2010")=0 and  afv_costT0(r,i,"kd0","2015"))
       = afv_costT0(r,i,"kd0","2015");


    afv_costT0(r,autoi,"hkd0",t)=     sum(maptrn(auto,autoi),  tran_cost0(r,auto,"hkd0"))
                                  * auto_noencost(r,autoi,"kd0",t)/auto_noencost(r,"auto_oev","kd0","2010")
                                 +  afv_costT0(r,autoi,"ed0",t) *afv_ensup0(autoi,"hkd0");

    afv_costT0(r,hdvi,"hkd0",t) =   sum(maptrn(hdv,hdvi),tran_cost0(r,hdv,"hkd0")*afv_kc_coef1(r,hdvi,t)*(1+afv_kc_coef_infras(r,hdvi,t)) )
                                   + afv_costT0(r,hdvi,"ed0",t) *afv_ensup0(hdvi,"hkd0");
    afv_costT0(r,i,"hkd0","2010")$((autoi(i) or hdvi(i)) and afv_costT0(r,i,"hkd0","2010")=0 and  afv_costT0(r,i,"hkd0","2015"))
       = afv_costT0(r,i,"hkd0","2015");

    afv_costT0(r,autoi,g,t)     = sum(maptrn(auto,autoi),tran_cost0(r,auto,g));
    afv_costT0(r,autoi,"srv",t) = sum(maptrn(auto,autoi),tran_cost0(r,auto,"srv")
                                                        *(   afv_mant_coef2(r,auto)*afv_mant_coef(r,autoi)
                                                          + (1- afv_mant_coef2(r,auto)) ) );
    afv_costT0(r,hdvi,g,t)     = sum(maptrn(hdv,hdvi),tran_cost0(r,hdv,g));
    afv_costT0(r,hdvi,"srv",t) = sum(maptrn(hdv,hdvi),tran_cost0(r,hdv,"srv")
                                                        *(   afv_mant_coef2(r,hdv)*afv_mant_coef(r,hdvi)
                                                          + (1 - afv_mant_coef2(r,hdv)) ) );

    afv_costT0(r,autoi,"id0",t) = sum(g,afv_costT0(r,autoi,g,t));
    afv_costT0(r,hdvi,"id0",t)  = sum(g,afv_costT0(r,hdvi,g,t));

    afv_costT0(r,i,g,"2010")$((autoi(i) or hdvi(i)) and afv_costT0(r,i,g,"2010")=0 and  afv_costT0(r,i,g,"2015"))
       = afv_costT0(r,i,g,"2015");
    afv_costT0(r,i,"id0","2010")$((autoi(i) or hdvi(i)) and afv_costT0(r,i,"id0","2010")=0 and  afv_costT0(r,i,"id0","2015"))
       = afv_costT0(r,i,"id0","2015");


    afv_costT0(r,afv,"ff0",t)= 0.001* sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));

    afv_costT0(r,i,"y0",t)$(hdvi(i) or autoi(i))
                  =   afv_costT0(r,i,"kd0",t)
                    + afv_costT0(r,i,"hkd0",t)
                    + afv_costT0(r,i,"ld0",t)
                    + afv_costT0(r,i,"ed0",t)
                    + afv_costT0(r,i,"id0",t)
                    + afv_costT0(r,i,"ff0",t) ;

* Input share index relative to corresponding OEV in 2010  (it is excluded from tax)
    afv_ldt0(r,afv,v,t)$new(v)      =   afv_costT0(r,afv,"ld0",t)/(1+tl(r,afv))
                                      / sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));
    afv_idt0(r,afv,g,v,t)$new(v)    =   afv_costT0(r,afv,g,t)/(1+ti(r,g,afv))
                                      / sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));

* Remove some tiny shares that are less than 1e-5 to other sectors
parameter chk_afvidt;
    chk_afvidt(r,afv,g,v,t)$(new(v) and round(afv_idt0(r,afv,g,v,t),5)=0)=afv_idt0(r,afv,g,v,t);
option chk_afvidt:4:4:1;

    afv_idt0(r,afv,"man",v,t)$(new(v)   and not autoafv(afv))
         = ( afv_costT0(r,afv,"man",t)  + sum(g$(not trn(g) and chk_afvidt(r,afv,g,v,t)),afv_costT0(r,afv,g,t)))
          /(1+ti(r,"man",afv))
          /sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));

    afv_idt0(r,afv,"rodf",v,t)$(new(v)  and not autoafv(afv))
         =  ( afv_costT0(r,afv,"rodf",t) + sum(g$(trn(g) and chk_afvidt(r,afv,g,v,t)),afv_costT0(r,afv,g,t)))
           /(1+ti(r,"rodf",afv))
           /sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));

    afv_idt0(r,afv,g,v,t)$(new(v)   and not autoafv(afv) and chk_afvidt(r,afv,g,v,t))  = 0;
    afv_idt0(r,afv,g,v,t)$(new(v)   and not autoafv(afv) and chk_afvidt(r,afv,g,v,t))  = 0;

    afv_edt0(r,afv,e,v,t)$(new(v)     and afv_costT0(r,afv,"y0",t))
        =  afv_costT0(r,afv,e,t) /sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));
    afv_hkdt0(r,afv,v,t)$(new(v)      and afv_costT0(r,afv,"y0",t))
        =  afv_costT0(r,afv,"hkd0",t)/(1+thk(r,afv))
          /sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));

    afv_kdt0(r,afv,"va",v,t)$(new(v)  and hdvi(afv) and afv_costT0(r,afv,"y0",t))
        =   afv_costT0(r,afv,"kd0",t)/(1+tk(r,"va",afv))
          / sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));
    afv_kdt0(r,afv,"ldv",v,t)$(new(v) and autoi(afv) and afv_costT0(r,afv,"y0",t))
       =  afv_costT0(r,afv,"kd0",t)/(1+tk(r,"ldv",afv))
          /sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));

    afv_fft0(r,afv,"ff0",v,t)$new(v)= 0.001;
    afv_kdt0(r,afv,k,v,t)$afv_kdt0(r,afv,k,v,t)  = afv_kdt0(r,afv,k,v,t)- afv_fft0(r,afv,"ff0",v,t);

    afv_yt0(r,afv,v,t)$(new(v)    and afv_costT0(r,afv,"y0",t))
       =  afv_costT0(r,afv,"y0",t)/(1-ty(r,afv))
         /sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));

    afv_markupt0(r,afv,v,t)$(new(v) and afv_costT0(r,afv,"y0",t))
       = afv_costT0(r,afv,"y0",t)/sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010"));
    afv_markupt0(r,i,v,t)$(new(v)   and afv_costT0(r,i,"y0",t) and (autoi(i) or hdvi(i)) )
       = afv_costT0(r,i,"y0",t)/sum(maptrn3(OEV,i),afv_costT0(r,OEV,"y0","2010"));

    chk_afvidt(r,afv,g,v,t)=0;
    chk_afvidt(r,afv,g,v,t)$(new(v) and round(afv_idt0(r,afv,g,v,t),5)=0)
       = afv_idt0(r,afv,g,v,t);

option chk_afvidt:4:4:1;
option afv_idt0:3:4:1;
display chk_afvidt,afv_idt0;

display afv_costT0,afv_markupt0, afv_idt0,afv_edt0,afv_kdt0, afv_hkdt0,afv_ldt0;

* Make adjustment and redo autoafvs cost share
parameter AFV_pricT0      Price (2010$ per pass-mile for passenger)from 2010 to 2050
          AFV_loadf0      Average load factor (which differ by type then assumed to be same as gasoline car later) ;

    auto_pricT0(r,"Auto_OEV",t)    =  tran_cost0(r, "auto","y0")* auto_pricT0(r,"Auto_OEV",t)/auto_pricT0(r,"Auto_OEV","2010");
    auto_pricT0(r,autoafv,t)       =  afv_markupt0(r,autoafv,"new",t)* auto_pricT0(r,"Auto_OEV","2010");

* Assume load factor for alternative fuel vehicles are same as gasoline car
    AFV_loadf0(r,hdvafv)  = sum(maptrn(i,hdvafv),tran_loadf0_10(r,i));
    AFV_loadf0(r,AutoAfv) = auto_loadf0(r,autoafv);
    AFV_loadf0(r,oev)     = sum(mapoev(oev,i),tran_loadf0(r,i));

    AFV_pricT0(r,hdvafv,v,t)$new(v)= sum(maptrn(i,hdvafv),afv_markupt0(r,hdvafv,v,t)*tran_pricT0_10(r,i,"2010"));
    AFV_pricT0(r,autoafv,v,t)$new(v)= auto_pricT0(r,autoafv,t);

option AFV_loadf0:2:0:2
display AFV_loadf0,AFV_pricT0;

display tran_cost0,afv_costT0,auto_pricT0,AFV_pricT0,afv_markupt0;

    chk0_afvt0(r,afv,v,"y0",t)  = afv_yt0(r,afv,v,t)*(1-ty(r,afv))             ;
    chk0_afvt0(r,afv,v,"ld0",t) = afv_ldt0(r,afv,v,t)*(1+tl(r,afv))            ;
    chk0_afvt0(r,afv,v,"id0",t) = sum(g,afv_idt0(r,afv,g,v,t)*(1+ti(r,g,afv))) ;
    chk0_afvt0(r,afv,v,"ed0",t) = sum(e,afv_edt0(r,afv,e,v,t) ) ;
    chk0_afvt0(r,afv,v,"kd0",t) = sum(k,afv_kdt0(r,afv,k,v,t)*(1+tk(r,k,afv))) ;
    chk0_afvt0(r,afv,v,"hkd0",t)= afv_hkdt0(r,afv, v,t)*(1+thk(r,afv))         ;
    chk0_afvt0(r,afv,v,"ff0",t) = afv_fft0(r,afv,"ff0", v,t)                   ;

    chk0_afvt0(r,afv,v,"bal",t) = round((   chk0_afvt0(r,afv,v,"y0",t)
                                          - chk0_afvt0(r,afv,v,"ld0",t)
                                          - chk0_afvt0(r,afv,v,"id0",t)
                                          - chk0_afvt0(r,afv,v,"ed0",t)
                                          - chk0_afvt0(r,afv,v,"kd0",t)
                                          - chk0_afvt0(r,afv,v,"hkd0",t)
                                          - chk0_afvt0(r,afv,v,"ff0",t)), 6) ;


display "before",afv_edt0,afv_ldt0,afv_idt0,afv_kdt0,afv_hkdt0,chk0_afvt0;

$ifthen setglobal aggtrn
    tran_cost0(r,trnv,ii)  = sum(mapSector(ii,i), tran_cost0(r,trnv,i));
    tran_cost0(r,trnv,ii)$deltrn(ii) = 0 ;

    afv_costT0(r,hdvi,ii,t) = sum(mapSector(ii,i), afv_costT0(r,hdvi,i,t));
    afv_costT0(r,hdvi,ii,t)$deltrn(ii) = 0 ;

    afv_idt0(r,afv,ii,v,t) = sum(mapSector(ii,g),afv_idt0(r,afv,g,v,t));
    afv_idt0(r,afv,ii,v,t)$deltrn(ii) = 0 ;

    chk0_afvt0(r,afv,v,"y0",t)  = afv_yt0(r,afv,v,t)*(1-ty(r,afv));
    chk0_afvt0(r,afv,v,"ld0",t) = afv_ldt0(r,afv, v,t)*(1+tl(r,afv))           ;
    chk0_afvt0(r,afv,v,"id0",t) = sum(g,afv_idt0(r,afv,g,v,t)*(1+ti(r,g,afv))) ;
    chk0_afvt0(r,afv,v,"ed0",t) = sum(e,afv_edt0(r,afv,e,v,t) )                ;
    chk0_afvt0(r,afv,v,"kd0",t) = sum(k,afv_kdt0(r,afv,k,v,t)*(1+tk(r,k,afv))) ;
    chk0_afvt0(r,afv,v,"hkd0",t)= afv_hkdt0(r,afv, v,t)*(1+thk(r,afv))         ;
    chk0_afvt0(r,afv,v,"ff0",t) = afv_fft0(r,afv,"ff0", v,t)                   ;

    chk0_afvt0(r,afv,v,"bal",t)= round((    chk0_afvt0(r,afv,v,"y0",t)
                                          - chk0_afvt0(r,afv,v,"ld0",t)
                                          - chk0_afvt0(r,afv,v,"id0",t)
                                          - chk0_afvt0(r,afv,v,"ed0",t)
                                          - chk0_afvt0(r,afv,v,"kd0",t)
                                          - chk0_afvt0(r,afv,v,"hkd0",t)
                                          - chk0_afvt0(r,afv,v,"ff0",t)), 6) ;

display "after",chk0_afvt0, afv_edt0,afv_ldt0,afv_idt0,afv_kdt0,afv_hkdt0,afv_yt0;
$endif

* Auto_EFF: Ethanol-Flex Fuel ICE. Here it is aggregated to auto_OEV catergory.
    USA_auto_vmtV0("Auto_OEV") = tran_vmt0("USA","auto")/(USA_auto_stock0("Auto_OEV","2010")+USA_auto_stock0("Auto_EFF","2010"));

    afv_vmtT0(r,afv,v,t)$(new(v) and autoafv(afv) and sameas(r,"USA"))    = usa_vmtt0(afv,t);
    afv_vmtT0(r,afv,v,t)$(new(v) and autoafv(afv)and not sameas(r,"USA")) = auto_vmtT0(r,afv,t);
* EUR for HEV in 2010 is a little higher than USA.
    afv_vmtT0(r,"Auto_HEV",v,t)$(new(v) and sameas(r,"EUR"))      = afv_vmtT0(r,"Auto_HEV",v,t)/5;
    afv_vmtT0(r,"Auto_HEV",v,"2010")$(new(v) and sameas(r,"XAS")) = afv_vmtT0("USA","Auto_HEV",v,"2010")/2;

* Model has two options for AFV growth: exogenous assumption as shown below or endogenously simulated based on cost over the time
    afv_vmtT0(r,afv,v,t)$(new(v) and rodfafv(afv) and sameas(r,"USA"))      =  usa_vmtt0(afv,t);
    afv_vmtT0(r,afv,v,t)$(new(v) and rodfafv(afv) and not sameas(r,"USA"))
          =  sum(maptrn(i,afv),tran_vmt0_10(r,i)* usa_vmtt0(afv,t)/tran_vmt0_10("USA","rodf")* tran_vmt0_10(r,i));

    afv_vmtT0(r,"rodp_gasv",v,t)$(new(v))  =  tran_vmt0_10(r,"rodp")*usa_vmtt0("rodf_gasv",t)/tran_vmt0_10("USA","rodf");
    afv_vmtT0(r,"rodp_hev ",v,t)$(new(v))  =  tran_vmt0_10(r,"rodp")*usa_vmtt0("rodf_hev ",t)/tran_vmt0_10("USA","rodf");
    afv_vmtT0(r,"rodp_bev ",v,t)$(new(v))  =  tran_vmt0_10(r,"rodp")*usa_vmtt0("rodf_bev ",t)/tran_vmt0_10("USA","rodf");
    afv_vmtT0(r,"rodp_fcev",v,t)$(new(v))  =  tran_vmt0_10(r,"rodp")*usa_vmtt0("rodf_fcev",t)/tran_vmt0_10("USA","rodf");

    afv_vmtT0(r,afv,v,t)$(t.val<2020 and hdvafv(afv)) = 0;

*   Endowment use annual: allow larger expansion in the first 10 years
    afv_yent0(r,afv,v,t)$(new(v))  = afv_vmtT0(r,afv,v,t)*afv_loadf0(r,afv)*afv_pricT0(r,afv,v,t);

    afv_ff0(r,afv,v)$(new(v) and afv_yent0(r,afv,v,"2010"))   = 0.001;
    afv_ffen0(r,afv,v)$(new(v) and afv_yent0(r,afv,v,"2010")) = 0.001*afv_yent0(r,afv,v,"2010");

    afv_edtrdt0(r,afv,v,t)$new(v)   = afv_mpgeT0(r,afv,"2010")/afv_mpgeT0(r,afv,t);

    afv_t0(r,afv,v,t)$(new(v) and autoafv(afv) and afv_vmtT0(r,afv,v,t)) = 1;
    afv_t0(r,afv,v,t)$(new(v) and hdvafv(afv)  and ord(t)>=3)            = 1;

display afv_mpgeT0,afv_vmtT0,afv_yent0;

Set  age          Technology age (30 years lifetime)
* Applies to onroad transportaiton and electricity generation
          / 0   age 0~4
            1   age 5~9
            2   age 10~14
            3   age 15~19
            4   age 20~24
            5   age 24~29
          /
      mapage(age,i)  Technology age age mapping
* Applies to onroad transportaiton and electricity generation
          /  0            . new
            (1,2,3,4,5)   . extant /
 ;

Table vmthis(age,*)    New vehicles's historical average annual sales or pvmt&tvmt data in USA from 1985 to 2010
* Date: 10/11/2019
* Age 0: 2010~2014; age 1: 2005~2009; age 2: 2000~2004; age 3: 1995~1999; age 4: 1990~1995; age 5: 1985~1989
* Auto_sales (thousand sales): Table 3.5 in https://tedb.ornl.gov/wp-content/uploads/2019/03/TEDB_37-2.pdf#page=82
* Auto_pvmt  (million pvmt): Table 3.5 in https://tedb.ornl.gov/wp-content/uploads/2019/03/TEDB_37-2.pdf#page=82
* RodF (thousand sales): Table 3.5 in https://tedb.ornl.gov/wp-content/uploads/2019/03/TEDB_37-2.pdf#page=82
* RodP (thousand sales): table 1-12 in https://www.bts.gov/content/us-sales-or-deliveries-new-aircraft-vehicles-vessels-and-other-conveyances
* Raw data is saved in the tab "final_sales" in the file "Vintage Structure in ADAGE_data and example.xlsx"
     Auto_sale     auto_pvmt      RodF        RodP
0    13925.400     341.113       544.800    390.623
1    14445.600     354.268       527.800    424.310
2    16804.000     412.823       478.200    490.448
3    15356.000     371.699       487.200    393.500
4    13578.200     322.335       306.400    331.730
5    15038.400     351.717       310.400    301.943
;

Table mpgehis(age,*)    New vehicles's historical average fuel economy (pvmt or TVMT per gallon of oil equivalent) in USA from 1985 to 2010
* Date: 10/11/2019
* Age 0: 2010~2014; age 1: 2005~2009; age 2: 2000~2004; age 3: 1995~1999; age 4: 1990~1995; age 5: 1985~1989
* Auto and RodP: pvmt per gallon; RodF: tvmt per gallon. Load factor will be needed if convert to vmt per gallon
* Source: moves model provided by EPA: https://nepis.epa.gov/Exe/ZyPDF.cgi?Dockey=P100NNUQ.pdf#page=24
* Raw file: "fuel economy 1980~2010.xlsx"
           Auto          RodF        RodP
0          35.11        17.20        123.66
1          33.83        18.61        125.19
2          33.18        17.62        123.87
3          34.78        19.43        125.64
4          35.47        20.10        126.11
5          32.45        19.58        124.54
;

parameter vmthis_trd(age,i)    New vehicles's historical VMT  trend (1 in 1985~1989 or age 5)
          mpgehis_trd(age,i)   New vehicles's historical mpge trend (1 in 1985~1989 or age 5);
* Age 0: 2010~2014; age 1: 2005~2009; age 2: 2000~2004; age 3: 1995~1999; age 4: 1990~1995; age 5: 1985~1989
* Use sales data as approximitation
   vmthis_trd(age,i)$vmthis("5",i)  = vmthis(age,i)/vmthis("5",i);
   vmthis_trd(age,"auto")$vmthis("5","auto_pvmt") = vmthis(age,"auto_pvmt")/vmthis("5","auto_pvmt");

   mpgehis_trd(age,i)$mpgehis("5",i)= mpgehis(age,i)/mpgehis("5",i);


* 9-9-2019: VMT Schedule index and vehicle survival rate are obtained from EPA and saved in .\rawdata\VMT schedule and survival rate.xlsx
*           Data comes from MOVES2014a (https://19january2017snapshot.epa.gov/moves/moves2014a-latest-version-motor-vehicle-emission-simulator-moves_.html)
*   and aggregated using aeo sales data in 2010 as the weight. load factor is considered when aggregated from size class.
table vmtschedule(age,i)  Onroad transportation vehicle VMT Schedule index (1 for new vehicle represented by age 0)
                  Auto           RodP          RodF
        0        1.0000        1.0000        1.0000
        1        0.8665        0.9728        0.8103
        2        0.7189        0.9497        0.5626
        3        0.5793        0.9300        0.3495
        4        0.4728        0.9133        0.2409
        5        0.4213        0.8991        0.1443
;

table surrate(age,i)     Onroad transportation vehicle survival rate by age (1 for new vehicle represented by age 0)
                   Auto          RodP          RodF
        0        0.9870        1.0000        1.0000
        1        0.9092        0.9456        0.9456
        2        0.7267        0.7964        0.7964
        3        0.3865        0.6047        0.6047
        4        0.1648        0.4086        0.4086
        5        0.0726        0.2514        0.2514
;

* Now introduce the vintage structure of AFV
parameter vmtbyage           Vehicle weighted average VMT Schedule index when they age (1 for new vehicle) for new vehicles in 2010 and beyond
          vmtbyage_his5yl    Vehicle VMT Schedule index for vehicles in 1985-2009 considering the growth trend five years later
          vmtbyage_histot    Total VehicleVMT Schedule index for vehicles in 1985-2009 considering the growth trend
          vmtbyage_his       Vehicle weighted average VMT Schedule index for vehicles in 1985-2009 considering the growth trend relative to vmt schedule in used vehicles in 2010  ;
* Incorporate VMT schedule and survival rate by vehicle age
    vmtbyage(age,i)                        = vmtschedule(age,i)*surrate(age,i);

    vmtbyage_his5yl("1",age,i)$(age.val>0) = vmthis_trd(age,i)*vmtbyage(age,i);
    vmtbyage_his5yl("2",age,i)$(age.val>1) = vmthis_trd(age-1,i)*vmtbyage(age,i);
    vmtbyage_his5yl("3",age,i)$(age.val>2) = vmthis_trd(age-2,i)*vmtbyage(age,i);
    vmtbyage_his5yl("4",age,i)$(age.val>3) = vmthis_trd(age-3,i)*vmtbyage(age,i);
    vmtbyage_his5yl("5",age,i)$(age.val>4) = vmthis_trd(age-4,i)*vmtbyage(age,i);

    vmtbyage_histot("1",i) = sum(age$(age.val>0), vmthis_trd(age,i)  *vmtbyage(age,i));
    vmtbyage_histot("2",i) = sum(age$(age.val>1), vmthis_trd(age-1,i)*vmtbyage(age,i));
    vmtbyage_histot("3",i) = sum(age$(age.val>2), vmthis_trd(age-2,i)*vmtbyage(age,i));
    vmtbyage_histot("4",i) = sum(age$(age.val>3), vmthis_trd(age-3,i)*vmtbyage(age,i));
    vmtbyage_histot("5",i) = sum(age$(age.val>4), vmthis_trd(age-4,i)*vmtbyage(age,i));

    vmtbyage_his(age,i)$(vmtbyage_histot("1",i)) = vmtbyage_histot(age,i)/vmtbyage_histot("1",i);
    vmtbyage_his(age,j)$(not afv(j))  = sum(maptrn2(i,j),vmtbyage_his(age,i)) ;

    vmtbyage(age,j)                   = sum(maptrn2(i,j),vmtbyage(age,i));

parameter new_mpgeT(r,*,t)      Fuel economy for new conventional vehicles over time
          old_mpgeT(r,*,t)      Fuel economy for used conventional vehicles over time taking into consideration stock turnover

          mk(r,i,label,v)       Markup factor for mpge for conventional vehicles
          mkt(r,i,label,v,t)    Markup factor for mpge for conventional vehicles over time;

    new_mpgeT(r,trnv,t)      = sum( mapoev(oev,trnv),afv_mpgeT0(r,oev,t));
    old_mpgeT(r,trnv,"2010") = tran_mpge0(r,trnv);

* Update mpge for old vehicle in OEV required by EPA. This is the presumed assumption based on presumed stock turnover rate
* Later in loop file, it should be updated using simulated results from previous periods
* Assuming 30 years lifetime for HDV
    old_mpgeT(r,trn,"2010")$trnv(trn) = 6/6*tran_mpge0(r,trn);
    old_mpgeT(r,trn,"2015")$trnv(trn) = 5/6*old_mpgeT(r,trn,"2010")+ 1/6*new_mpgeT(r,trn,"2010");
    old_mpgeT(r,trn,"2020")$trnv(trn) = 4/6*old_mpgeT(r,trn,"2010")+ 1/6*new_mpgeT(r,trn,"2010")+ 1/6*new_mpgeT(r,trn,"2015");
    old_mpgeT(r,trn,"2025")$trnv(trn) = 3/6*old_mpgeT(r,trn,"2010")+ 1/6*new_mpgeT(r,trn,"2010")+ 1/6*new_mpgeT(r,trn,"2015")
                                      +1/6*new_mpgeT(r,trn,"2020") ;
    old_mpgeT(r,trn,"2030")$trnv(trn) = 2/6*old_mpgeT(r,trn,"2010")+ 1/6*new_mpgeT(r,trn,"2010")+ 1/6*new_mpgeT(r,trn,"2015")
                                      + 1/6*new_mpgeT(r,trn,"2020")+ 1/6*new_mpgeT(r,trn,"2025") ;

    old_mpgeT(r,trn,"2035")$trnv(trn) = 1/6*old_mpgeT(r,trn,"2010")+ 1/6*new_mpgeT(r,trn,"2010")+ 1/6*new_mpgeT(r,trn,"2015")
                                      + 1/6*new_mpgeT(r,trn,"2020")+ 1/6*new_mpgeT(r,trn,"2025")+ 1/6*new_mpgeT(r,trn,"2030") ;
    loop(t$(ord(t)>6),
        old_mpgeT(r,trn,t)$trnv(trn)  = 1/6*(  new_mpgeT(r,trn,t-6) + new_mpgeT(r,trn,t-5) + new_mpgeT(r,trn,t-4)
                                             + new_mpgeT(r,trn,t-3) + new_mpgeT(r,trn,t-2) + new_mpgeT(r,trn,t-1)) ;);

    mkt(r,trn,label,v,t) = 1;
    mkt(r,trn,"ed0",v,t)$(new(v) and new_mpgeT(r,trn,t) and num(r))     = tran_mpge0(r,trn)/new_mpgeT(r,trn,t);
    mkt(r,trn,"ed0",v,t)$(extant(v) and old_mpgeT(r,trn,t) and num(r))  = tran_mpge0(r,trn)/old_mpgeT(r,trn,t);

    mkt(r,trn,label,v,t)$(not num(r)) =1;
    mkt(r,trn,"ed0",v,t)$(new(v)    and new_mpgeT(r,trn,t) and not num(r))   = tran_mpge0(r,trn)/new_mpgeT(r,trn,t);
    mkt(r,trn,"ed0",v,t)$(extant(v) and old_mpgeT(r,trn,t) and not num(r))   = tran_mpge0(r,trn)/old_mpgeT(r,trn,t);

    mk(r,trnv,label,v)= 1;
display  old_mpgeT,new_mpgeT,mkt;

* Presumed vehicle turnover based on vehicle age. This could become dynamic for used vehicles in the loop.gms
    afv_yt0(r,afv,"extant",t)$(t.val=2010)       = afv_yt0(r,afv,"new",t)    ;
    afv_ldt0(r,afv,  "extant",t)$(t.val=2010)    = afv_ldt0(r,afv,"new",t)   ;
    afv_idt0(r,afv,g,"extant",t)$(t.val=2010)    = afv_idt0(r,afv,g,"new",t) ;
    afv_edt0(r,afv,e,"extant",t)$(t.val=2010)    = afv_edt0(r,afv,e,"new",t) ;
    afv_kdt0(r,afv,k,"extant",t)$(t.val=2010)    = afv_kdt0(r,afv,k,"new",t) ;
    afv_hkdt0(r,afv,"extant",t)$(t.val=2010 )    = afv_hkdt0(r,afv,"new",t)  ;
    afv_edtrdt0(r,afv,"extant",t)$(t.val=2010 )  = afv_edtrdt0(r,afv,"new",t);
    afv_markupt0(r,afv,"extant",t)$(t.val=2010)  = afv_markupt0(r,afv,"new",t);
    afv_fft0(r,afv,"ff0", "extant",t)            = 0  ;

    afv_yt0(r,afv,   "extant",t)$(t.val=2015)    = afv_yt0(r,afv,"new",t-1)    ;
    afv_ldt0(r,afv,  "extant",t)$(t.val=2015)    = afv_ldt0(r,afv,"new",t-1)   ;
    afv_idt0(r,afv,g,"extant",t)$(t.val=2015)    = afv_idt0(r,afv,g,"new",t-1) ;
    afv_edt0(r,afv,e,"extant",t)$(t.val=2015)    = afv_edt0(r,afv,e,"new",t-1) ;
    afv_kdt0(r,afv,k,"extant",t)$(t.val=2015)    = afv_kdt0(r,afv,k,"new",t-1) ;
    afv_hkdt0(r,afv, "extant",t)$(t.val=2015)    = afv_hkdt0(r,afv,"new",t-1)  ;
    afv_edtrdt0(r,afv,"extant",t)$(t.val=2015 )  = afv_edtrdt0(r,afv,"new",t-1);
    afv_markupt0(r,afv,"extant",t)$(t.val=2015)  = afv_markupt0(r,afv,"new",t-1);

    afv_yt0(r,afv,  "extant",t)$(t.val=2020   )  = 5/6* afv_yt0(r,afv,"new",t-2)     + 1/6* afv_yt0(r,afv,"new",t-1)    ;
    afv_ldt0(r,afv,  "extant",t)$(t.val=2020  )  = 5/6* afv_ldt0(r,afv,"new",t-2)    + 1/6* afv_ldt0(r,afv,"new",t-1)   ;
    afv_idt0(r,afv,g,"extant",t)$(t.val=2020  )  = 5/6* afv_idt0(r,afv,g,"new",t-2)  + 1/6* afv_idt0(r,afv,g,"new",t-1) ;
    afv_edt0(r,afv,e,"extant",t)$(t.val=2020  )  = 5/6* afv_edt0(r,afv,e,"new",t-2)  + 1/6* afv_edt0(r,afv,e,"new",t-1) ;
    afv_kdt0(r,afv,k,"extant",t)$(t.val=2020  )  = 5/6* afv_kdt0(r,afv,k,"new",t-2)  + 1/6* afv_kdt0(r,afv,k,"new",t-1) ;
    afv_hkdt0(r,afv, "extant",t)$(t.val=2020  )  = 5/6* afv_hkdt0(r,afv,"new",t-2)   + 1/6* afv_hkdt0(r,afv,"new",t-1)  ;
    afv_edtrdt0(r,afv,"extant",t)$(t.val=2020 )  = 5/6* afv_edtrdt0(r,afv,"new",t-2) + 1/6* afv_edtrdt0(r,afv,"new",t-1);
    afv_markupt0(r,afv,"extant",t)$(t.val=2020)  = 5/6* afv_markupt0(r,afv,"new",t-2)+ 1/6* afv_markupt0(r,afv,"new",t-1);

    afv_yt0(r,afv,  "extant",t)$(t.val=2025   )  = 4/6* afv_yt0(r,afv,"new",t-3)     + 1/6* afv_yt0(r,afv,"new",t-2)     + 1/6* afv_yt0(r,afv,"new",t-1)    ;
    afv_ldt0(r,afv,  "extant",t)$(t.val=2025  )  = 4/6* afv_ldt0(r,afv,"new",t-3)    + 1/6* afv_ldt0(r,afv,"new",t-2)    + 1/6* afv_ldt0(r,afv,"new",t-1)   ;
    afv_idt0(r,afv,g,"extant",t)$(t.val=2025  )  = 4/6* afv_idt0(r,afv,g,"new",t-3)  + 1/6* afv_idt0(r,afv,g,"new",t-2)  + 1/6* afv_idt0(r,afv,g,"new",t-1) ;
    afv_edt0(r,afv,e,"extant",t)$(t.val=2025  )  = 4/6* afv_edt0(r,afv,e,"new",t-3)  + 1/6* afv_edt0(r,afv,e,"new",t-2)  + 1/6* afv_edt0(r,afv,e,"new",t-1) ;
    afv_kdt0(r,afv,k,"extant",t)$(t.val=2025  )  = 4/6* afv_kdt0(r,afv,k,"new",t-3)  + 1/6* afv_kdt0(r,afv,k,"new",t-2)  + 1/6* afv_kdt0(r,afv,k,"new",t-1) ;
    afv_hkdt0(r,afv, "extant",t)$(t.val=2025  )  = 4/6* afv_hkdt0(r,afv,"new",t-3)   + 1/6* afv_hkdt0(r,afv,"new",t-2)   + 1/6* afv_hkdt0(r,afv,"new",t-1)  ;
    afv_edtrdt0(r,afv,"extant",t)$(t.val=2025 )  = 4/6* afv_edtrdt0(r,afv,"new",t-3) + 1/6* afv_edtrdt0(r,afv,"new",t-2) + 1/6* afv_edtrdt0(r,afv,"new",t-1);
    afv_markupt0(r,afv,"extant",t)$(t.val=2025)  = 4/6* afv_markupt0(r,afv,"new",t-3)+ 1/6* afv_markupt0(r,afv,"new",t-2)+ 1/6* afv_markupt0(r,afv,"new",t-1);

    afv_yt0(r,afv,   "extant",t)$(t.val=2030  )  = 3/6* afv_yt0(r,afv,"new",t-4)     + 1/6* afv_yt0(r,afv,"new",t-3)     + 1/6* afv_yt0(r,afv,"new",t-2)     + 1/6* afv_yt0(r,afv,"new",t-1)    ;
    afv_ldt0(r,afv,  "extant",t)$(t.val=2030  )  = 3/6* afv_ldt0(r,afv,"new",t-4)    + 1/6* afv_ldt0(r,afv,"new",t-3)    + 1/6* afv_ldt0(r,afv,"new",t-2)    + 1/6* afv_ldt0(r,afv,"new",t-1)   ;
    afv_idt0(r,afv,g,"extant",t)$(t.val=2030  )  = 3/6* afv_idt0(r,afv,g,"new",t-4)  + 1/6* afv_idt0(r,afv,g,"new",t-3)  + 1/6* afv_idt0(r,afv,g,"new",t-2)  + 1/6* afv_idt0(r,afv,g,"new",t-1) ;
    afv_edt0(r,afv,e,"extant",t)$(t.val=2030  )  = 3/6* afv_edt0(r,afv,e,"new",t-4)  + 1/6* afv_edt0(r,afv,e,"new",t-3)  + 1/6* afv_edt0(r,afv,e,"new",t-2)  + 1/6* afv_edt0(r,afv,e,"new",t-1) ;
    afv_kdt0(r,afv,k,"extant",t)$(t.val=2030  )  = 3/6* afv_kdt0(r,afv,k,"new",t-4)  + 1/6* afv_kdt0(r,afv,k,"new",t-3)  + 1/6* afv_kdt0(r,afv,k,"new",t-2)  + 1/6* afv_kdt0(r,afv,k,"new",t-1) ;
    afv_hkdt0(r,afv, "extant",t)$(t.val=2030  )  = 3/6* afv_hkdt0(r,afv,"new",t-4)   + 1/6* afv_hkdt0(r,afv,"new",t-3)   + 1/6* afv_hkdt0(r,afv,"new",t-2)   + 1/6* afv_hkdt0(r,afv,"new",t-1)  ;
    afv_edtrdt0(r,afv,"extant",t)$(t.val=2030 )  = 3/6* afv_edtrdt0(r,afv,"new",t-4) + 1/6* afv_edtrdt0(r,afv,"new",t-3) + 1/6* afv_edtrdt0(r,afv,"new",t-2) + 1/6* afv_edtrdt0(r,afv,"new",t-1);
    afv_markupt0(r,afv,"extant",t)$(t.val=2030)  = 3/6* afv_markupt0(r,afv,"new",t-4)+ 1/6* afv_markupt0(r,afv,"new",t-3)+ 1/6* afv_markupt0(r,afv,"new",t-2)+ 1/6* afv_markupt0(r,afv,"new",t-1);

    afv_yt0(r,afv,   "extant",t)$(t.val=2035  )  = 2/6* afv_yt0(r,afv,"new",t-5)     + 1/6* afv_yt0(r,afv,"new",t-4)     + 1/6* afv_yt0(r,afv,"new",t-3)     + 1/6* afv_yt0(r,afv,"new",t-2)     + 1/6* afv_yt0(r,afv,"new",t-1)    ;
    afv_ldt0(r,afv,  "extant",t)$(t.val=2035  )  = 2/6* afv_ldt0(r,afv,"new",t-5)    + 1/6* afv_ldt0(r,afv,"new",t-4)    + 1/6* afv_ldt0(r,afv,"new",t-3)    + 1/6* afv_ldt0(r,afv,"new",t-2)    + 1/6* afv_ldt0(r,afv,"new",t-1)   ;
    afv_idt0(r,afv,g,"extant",t)$(t.val=2035  )  = 2/6* afv_idt0(r,afv,g,"new",t-5)  + 1/6* afv_idt0(r,afv,g,"new",t-4)  + 1/6* afv_idt0(r,afv,g,"new",t-3)  + 1/6* afv_idt0(r,afv,g,"new",t-2)  + 1/6* afv_idt0(r,afv,g,"new",t-1) ;
    afv_edt0(r,afv,e,"extant",t)$(t.val=2035  )  = 2/6* afv_edt0(r,afv,e,"new",t-5)  + 1/6* afv_edt0(r,afv,e,"new",t-4)  + 1/6* afv_edt0(r,afv,e,"new",t-3)  + 1/6* afv_edt0(r,afv,e,"new",t-2)  + 1/6* afv_edt0(r,afv,e,"new",t-1) ;
    afv_kdt0(r,afv,k,"extant",t)$(t.val=2035  )  = 2/6* afv_kdt0(r,afv,k,"new",t-5)  + 1/6* afv_kdt0(r,afv,k,"new",t-4)  + 1/6* afv_kdt0(r,afv,k,"new",t-3)  + 1/6* afv_kdt0(r,afv,k,"new",t-2)  + 1/6* afv_kdt0(r,afv,k,"new",t-1) ;
    afv_hkdt0(r,afv, "extant",t)$(t.val=2035  )  = 2/6* afv_hkdt0(r,afv,"new",t-5)   + 1/6* afv_hkdt0(r,afv,"new",t-4)   + 1/6* afv_hkdt0(r,afv,"new",t-3)   + 1/6* afv_hkdt0(r,afv,"new",t-2)   + 1/6* afv_hkdt0(r,afv,"new",t-1)  ;
    afv_edtrdt0(r,afv,"extant",t)$(t.val=2035 )  = 2/6* afv_edtrdt0(r,afv,"new",t-5) + 1/6* afv_edtrdt0(r,afv,"new",t-4) + 1/6* afv_edtrdt0(r,afv,"new",t-3) + 1/6* afv_edtrdt0(r,afv,"new",t-2) + 1/6* afv_edtrdt0(r,afv,"new",t-1);
    afv_markupt0(r,afv,"extant",t)$(t.val=2035 ) = 2/6* afv_markupt0(r,afv,"new",t-5)+ 1/6* afv_markupt0(r,afv,"new",t-4)+ 1/6* afv_markupt0(r,afv,"new",t-3)+ 1/6* afv_markupt0(r,afv,"new",t-2)+ 1/6* afv_markupt0(r,afv,"new",t-1);

  loop(t$(ord(t)>6),
    afv_yt0(r,afv,   "extant",t)   = 1/6* afv_yt0(r,afv,"new",t-6)     + 1/6* afv_yt0(r,afv,"new",t-5)     + 1/6* afv_yt0(r,afv,"new",t-4)     + 1/6* afv_yt0(r,afv,"new",t-3)     + 1/6* afv_yt0(r,afv,"new",t-2)     + 1/6* afv_yt0(r,afv,"new",t-1)    ;
    afv_ldt0(r,afv,  "extant",t)   = 1/6* afv_ldt0(r,afv,"new",t-6)    + 1/6* afv_ldt0(r,afv,"new",t-5)    + 1/6* afv_ldt0(r,afv,"new",t-4)    + 1/6* afv_ldt0(r,afv,"new",t-3)    + 1/6* afv_ldt0(r,afv,"new",t-2)    + 1/6* afv_ldt0(r,afv,"new",t-1)   ;
    afv_idt0(r,afv,g,"extant",t)   = 1/6* afv_idt0(r,afv,g,"new",t-6)  + 1/6* afv_idt0(r,afv,g,"new",t-5)  + 1/6* afv_idt0(r,afv,g,"new",t-4)  + 1/6* afv_idt0(r,afv,g,"new",t-3)  + 1/6* afv_idt0(r,afv,g,"new",t-2)  + 1/6* afv_idt0(r,afv,g,"new",t-1) ;
    afv_edt0(r,afv,e,"extant",t)   = 1/6* afv_edt0(r,afv,e,"new",t-6)  + 1/6* afv_edt0(r,afv,e,"new",t-5)  + 1/6* afv_edt0(r,afv,e,"new",t-4)  + 1/6* afv_edt0(r,afv,e,"new",t-3)  + 1/6* afv_edt0(r,afv,e,"new",t-2)  + 1/6* afv_edt0(r,afv,e,"new",t-1) ;
    afv_kdt0(r,afv,k,"extant",t)   = 1/6* afv_kdt0(r,afv,k,"new",t-6)  + 1/6* afv_kdt0(r,afv,k,"new",t-5)  + 1/6* afv_kdt0(r,afv,k,"new",t-4)  + 1/6* afv_kdt0(r,afv,k,"new",t-3)  + 1/6* afv_kdt0(r,afv,k,"new",t-2)  + 1/6* afv_kdt0(r,afv,k,"new",t-1) ;
    afv_hkdt0(r,afv, "extant",t)   = 1/6* afv_hkdt0(r,afv,"new",t-6)   + 1/6* afv_hkdt0(r,afv,"new",t-5)   + 1/6* afv_hkdt0(r,afv,"new",t-4)   + 1/6* afv_hkdt0(r,afv,"new",t-3)   + 1/6* afv_hkdt0(r,afv,"new",t-2)   + 1/6* afv_hkdt0(r,afv,"new",t-1)  ;
    afv_edtrdt0(r,afv,"extant",t)  = 1/6* afv_edtrdt0(r,afv,"new",t-6) + 1/6* afv_edtrdt0(r,afv,"new",t-5) + 1/6* afv_edtrdt0(r,afv,"new",t-4) + 1/6* afv_edtrdt0(r,afv,"new",t-3) + 1/6* afv_edtrdt0(r,afv,"new",t-2) + 1/6* afv_edtrdt0(r,afv,"new",t-1);
    afv_markupt0(r,afv,"extant",t) = 1/6* afv_markupt0(r,afv,"new",t-6)+ 1/6* afv_markupt0(r,afv,"new",t-5)+ 1/6* afv_markupt0(r,afv,"new",t-4)+ 1/6* afv_markupt0(r,afv,"new",t-3)+ 1/6* afv_markupt0(r,afv,"new",t-2)+ 1/6* afv_markupt0(r,afv,"new",t-1);
     );

* Add fixed factor endowment in new vehicles to capital in used vehicles
    afv_kdt0(r,afv,k,"extant",t)$ afv_kdt0(r,afv,k,"extant",t) =  afv_kdt0(r,afv,k,"extant",t) + 0.001;

    afv_t0(r,afv,v,t)$(new(v) and autoafv(afv) and afv_vmtT0(r,afv,v,t)) = 1;
    afv_t0(r,afv,v,t)$(new(v) and hdvafv(afv)  and ord(t)>=3)            = 1;

    afv_t0(r,afv,"extant",t)$(autoafv(afv) and afv_vmtT0(r,afv,"new",t-1))= 1;
    afv_t0(r,afv,"extant",t)$(hdvafv(afv)  and ord(t)>=4)                 = 1;

    chk0_afvt0(r,afv,v,"y0",t)   = afv_yt0(r,afv,v,t)*(1-ty(r,afv));
    chk0_afvt0(r,afv,v,"ld0",t)  = afv_ldt0(r,afv,v,t)*(1+tl(r,afv))    ;
    chk0_afvt0(r,afv,v,"id0",t)  = sum(g,afv_idt0(r,afv,g,v,t)*(1+ti(r,g,afv) ) );
    chk0_afvt0(r,afv,v,"ed0",t)  = sum(e,afv_edt0(r,afv,e,v,t) ) ;
    chk0_afvt0(r,afv,v,"kd0",t)  = sum(k,afv_kdt0(r,afv,k,v,t)*(1+tk(r,k,afv) )) ;
    chk0_afvt0(r,afv,v,"hkd0",t) = afv_hkdt0(r,afv, v,t)*(1+ thk(r,afv))  ;
    chk0_afvt0(r,afv,v,"ff0",t)  = afv_fft0(r,afv,"ff0", v,t);

    chk0_afvt0(r,afv,v,"bal",t)  = round((  chk0_afvt0(r,afv,v,"y0",t)
                                          - chk0_afvt0(r,afv,v,"ld0",t)
                                          - chk0_afvt0(r,afv,v,"id0",t)
                                          - chk0_afvt0(r,afv,v,"ed0",t)
                                          - chk0_afvt0(r,afv,v,"kd0",t)
                                          - chk0_afvt0(r,afv,v,"hkd0",t)
                                          - chk0_afvt0(r,afv,v,"ff0",t)), 6) ;

display chk0_afvt0,afv_idt0,afv_kdt0, afv_hkdt0,afv_yt0,afv_edt0;

    afv_ld0(r,afv,v)     = afv_ldt0(r,afv,v,"2010")   ;
    afv_id0(r,afv,g,v)   = afv_idt0(r,afv,g,v,"2010") ;
    afv_ed0(r,afv,e,v)   = afv_edt0(r,afv,e,v,"2010") ;
    afv_kd0(r,afv,k,v)   = afv_kdt0(r,afv,k,v,"2010") ;
    afv_hkd0(r,afv,v)    = afv_hkdt0(r,afv,v,"2010")  ;
    afv_edtrd0(r,afv,v)  = afv_edtrdt0(r,afv,v,"2010");
    afvmarkup(r,afv,v)   = afv_markupt0(r,afv,v,"2010");


display afv_vmtT0,tran_loadf0,auto_loadf0,auto_loadfT0,tran_vmt0,afv_markupt0,afv_pricT0,afv_edtrdt0,afv_mpgeT0,afv_ff0,tran_cost0,afv_kdt0,afv_edt0,chk0_afvt0,afv_t0,afv_yent0,tl,tk;

* Dynamic input cost approach for used AFVs in the loop.gms
parameter  afv_ldt00
           afv_idt00
           afv_kdt00
           afv_hkdt00
           afv_edt00
           afv_edtrdt00  ;

parameter         afv_elas(i)      fixed factor elasticity for AFV
* Based on econometric estimation from Wards auto data
  /
*    Auto_OEV   0.132
     Auto_HEV   0.631
     Auto_GASV  0.492
     Auto_BEV   0.631
     Auto_FCEV  0.631
   /;

* Based on MIT EPPA model
    afv_elas(autoafv) =  0.20 ;
    afv_elas(hdvafv)  =  0.20 ;
    afv_elas(afv)$(gasv(afv)) = 0.10;
    afv_elas(afv)$(fcev(afv)) = 0.10;
    afv_elas(trnv)            = 0.10 ;

parameter trn_ffen0(r,i,v)     Fixed factor endowment in conventional transportation
          trn_ffent0(r,i,t)    Fixed factor endowment in conventional transportation in new;
    trn_ffen0(r,i,v)$(new(v) and trnv(i)) = 0.001*y0(r,i,v);


parameter kdcost(r,trn)        Capital cost in OEV transportation ($ per mile)
          ldcost(r,trn)        Capital cost in OEV transportation ($ per mile)
          edcost(r,trn)        Energy cost in OEV transportation ($ per mile) ;


    kdcost(r,trn)$tran_vmt0(r,trn) = sum(k,kd0(r,k,trn,"new"))/ tran_vmt0(r,trn);
    ldcost(r,trn)$tran_vmt0(r,trn) = ld0(r,trn,"new")/ tran_vmt0(r,trn);
    edcost(r,trn)$tran_vmt0(r,trn) = sum(e,ed0(r,e,"fuel",trn,"new"))/ tran_vmt0(r,trn);

display USA_auto_stock0, USA_auto_vmtV0, kdcost,ldcost,edcost,mapoev;

*End of transportation sector
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC



*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*          Check some production and consumption function and supply-demand balance
*             due to introduction of additional modeling features
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

parameter pctax         Carbon tax ($ per ton of CO2e)       /28/;
* Given a small carbon tax assumption and check the carbon tax input cost relative to other inputs in the production block

parameter chk0_ag       Check balance on agricultural production
          chk0_shr      Check share of armington goods in production
          chk0_agp      Check agriculture price to see if input price=1+tax
          chk0_lnd      Check balance on land conversion
          chk0_lrent    Check the land rent
          chk0_x        Check the balance of export
          chk0_a        Check the balance of intermediate good production
          chk0_exy      Check ag & industry production (extant)
          chk0_l        Check labor balance
          chk0_lndp     Check the reference price of land
          chk0_ff       Check fossil fuel balance
          chk0_trnP     Check transportation production balance
          chk0_trnM     Check transportation market balance
          chk0_auto     Check auto energy supply-demand balance
          chk0_rnweleP  Check production balance in renewable electricity generation
          chk0_en       Check energy supply-demand balance
          chk0_m        Check import balance
          chk0_trd      Check trade balance
          pmxt0         Trade margin including import export tax and transportation cost margin

          chk0_c        Check household consumption
          chk0_w        Check Welfare
          chk0_py       Check production and domestic consumption
          chk0_emkt     Check transportation energy market structure and margin ;


    chk0_en(r,e,use,i,"ed0")   = ed0(r,e,use,i,"new");
    chk0_en(r,e,use,i,"ert0")  = ertl0(r,e,use,i);
    chk0_en(r,e,use,i,"ed0-ert0")=  chk0_en(r,e,use,i,"ed0")
                                  - chk0_en(r,e,use,i,"ert0");

    chk0_auto(r,e,'retail')   =  gal_conv(r,e,"fuel","auto")* ertl0(r,e,"fuel",'auto');
    chk0_auto(r,e,'demand')   =  gal_conv(r,e,"fuel","auto")* sum(vnum(v), ed0(r,e,"fuel","auto",v)  );


    chk0_trnP(r,trn,"y0") =  y0(r,trn,"new")*(1-ty(r,trn));
    chk0_trnP(r,trn,"id0") = sum(g,id0(r,g,trn,"new")*(1+ti(r,g,trn)));
    chk0_trnP(r,trn,"kd0") = sum(k,kd0(r,k,trn,"new")*(1+tk(r,k,trn)));
    chk0_trnP(r,trn,"hkd0")= hkd0(r,trn,"new")*(1+thk(r,trn));
    chk0_trnP(r,trn,"ld0") = ld0(r,trn,"new")*(1+tl(r,trn));
    chk0_trnP(r,trn,"ed0") = sum(e,ed0(r,e,"fuel",trn,"new"));
    chk0_trnP(r,trn,"ed0")$auto(trn)= fuel0(r,"new");
    chk0_trnP(r,trn,"bal")= round((chk0_trnP(r,trn,"y0")
                                 - chk0_trnP(r,trn,"id0")
                                 - chk0_trnP(r,trn,"kd0")
                                 - chk0_trnP(r,trn,"hkd0")
                                 - chk0_trnP(r,trn,"ld0")
                                 - chk0_trnP(r,trn,"ed0") ),5);

    chk0_trnM(r,trn,"y0")  = y0(r,trn,"new");
    chk0_trnM(r,trn,"x0")  = sum(trd, x0(r,trn,trd));
    chk0_trnM(r,trn,"m0")  = sum(trd, m0(r,trn,trd));
    chk0_trnM(r,trn,"id0") = sum(g,id0(r,trn,g,"new"));
    chk0_trnM(r,trn,"cd0") = cd0(r,"hh",trn);
    chk0_trnM(r,trn,"i0") =  sum(k, i0(r,k,trn));
    chk0_trnM(r,trn,"g0") =  g0(r,trn);

    chk0_trnM(r,trn,"bal")=round((   chk0_trnM(r,trn,"y0")
                                    +  chk0_trnM(r,trn,"m0")
                                    -  chk0_trnM(r,trn,"x0")
                                    -  chk0_trnM(r,trn,"id0")
                                    -  chk0_trnM(r,trn,"cd0")
                                    -  chk0_trnM(r,trn,"i0")
                                    -  chk0_trnM(r,trn,"g0")),5);

    chk0_mrkt(r,s,mrkt)  = 0;
    chk0_mrkt(r,s,"y0")  = y0(r,s,"new");
    chk0_mrkt(r,s,"m0")  = sum(trd, m0(r,s,trd));
    chk0_mrkt(r,s,"x0")  = sum(trd, x0(r,s,trd));
    chk0_mrkt(r,s,"id0") = sum(jj,id0(r,s,jj,"new"));
    chk0_mrkt(r,s,"cd0") = cd0(r,"hh",s);
    chk0_mrkt(r,s,"i0") =  sum(k, i0(r,k,s));
    chk0_mrkt(r,s,"g0") =  g0(r,s);

    chk0_mrkt(r,s,"bal")=round((       chk0_mrkt(r,s,"y0")
                                    +  chk0_mrkt(r,s,"m0")
                                    -  chk0_mrkt(r,s,"x0")
                                    -  chk0_mrkt(r,s,"id0")
                                    -  chk0_mrkt(r,s,"cd0")
                                    -  chk0_mrkt(r,s,"i0")
                                    -  chk0_mrkt(r,s,"g0")),5);

option chk0_en:3:4:1;

    chk0_rnweleP(r,rnw,"y0")  =  y0(r,rnw,"new")*(1-ty(r,rnw));
    chk0_rnweleP(r,rnw,"id0") = sum(g,id0(r,g,rnw,"new")*(1+ti(r,g,rnw)));
    chk0_rnweleP(r,rnw,"kd0") = kd0(r,"va",rnw,"new")*(1+tk(r,"va",rnw));
    chk0_rnweleP(r,rnw,"hkd0")= hkd0(r,rnw,"new")*(1+thk(r,rnw));
    chk0_rnweleP(r,rnw,"ld0") = ld0(r,rnw,"new")*(1+tl(r,rnw));
    chk0_rnweleP(r,rnw,"rnw0")= rnw0(r,rnw,"new");
    chk0_rnweleP(r,rnw,"bal") = round((chk0_rnweleP(r,rnw,"y0")
                                 - chk0_rnweleP(r,rnw,"id0")
                                 - chk0_rnweleP(r,rnw,"kd0")
                                 - chk0_rnweleP(r,rnw,"hkd0")
                                 - chk0_rnweleP(r,rnw,"ld0")
                                 - chk0_rnweleP(r,rnw,"rnw0") ),7);

    chk0_m(r,i,"demand")$(not cru(i))= m0(r,i,"ftrd");

    n0(r,rr,i)$(not cru(i))= (   m0(r,i,"ftrd")
                              -  sum(rrr,trs0(r,rrr,i)*(1+tm(r,rrr,i))) )
                             /  sum(rrr, n0(r,rrr,i)*(1+tx(r,rrr,i))*(1+tm(r,rrr,i)))
                             * n0(r,rr,i);

    pmx0(r,rr,i)$(not cru(i)) = (1+tx(r,rr,i))*(1+tm(r,rr,i));
    pmxt0(r,rr,i)$ n0(r,rr,i) = (  trs0(r,rr,i)*(1+tm(r,rr,i))
                                 + n0(r,rr,i)*(1+tx(r,rr,i))*(1+tm(r,rr,i)) )
                               /  n0(r,rr,i)-1;

    chk0_m(r,i,"supply")$(not cru(i))=   sum(rr, n0(r,rr,i)*(1+tx(r,rr,i))*(1+tm(r,rr,i)))
                                       + sum(rr, trs0(r,rr,i)*(1+tm(r,rr,i)));
    chk0_m(r,i,"s-d")$(not cru(i))   = chk0_m(r,i,"supply")-chk0_m(r,i,"demand") ;


    chk0_trd(r,i,"supply")$(not gentype(i) or (not ele(i)) or (not cru(i)))= sum(rr, n0(rr,r,i))+tpt0(r,i);
    chk0_trd(r,i,"supply")$cru(i)=0;
    chk0_trd(r,i,"demand")$(not gentype(i) or (not ele(i)) or (not cru(i)))= x0(r,i,"ftrd");
    chk0_trd(r,i,"demand")$cru(i) = 0;
    chk0_trd(r,i,"s-d")= chk0_trd(r,i,"supply")-chk0_trd(r,i,"demand");

    chk0_trd("World",i,"supply") = sum(r,chk0_trd(r,i,"supply"));
    chk0_trd("World",i,"demand") = sum(r,chk0_trd(r,i,"demand"));
    chk0_trd("World",i,"s-d")    = sum(r,chk0_trd(r,i,"s-d"));

    chk0_lndp(r,s)= plnd0(r,s)-(1+tn(r,s));

    chk0_l(r,'supply')= le0(r,'hh')-leis0(r,'hh');
    chk0_l(r,'demand')= sum((i,vnum), ld0(r,i,vnum));
    chk0_l(r,'s-d')   = chk0_l(r,'supply')- chk0_l(r,'demand');

    chk0_ff(r,ff,v,'out')$(y0(r,ff,v) and new(v) )
        = y0(r,ff,v)*(1-ty(r,ff));
    chk0_ff(r,ff,v,'in')$(y0(r,ff,v) and new(v))
        =   sum((e,use),ed0(r,e,use,ff,v))
          + sum(g,id0(r,g,ff,v)*(1+ti(r,g,ff)))
          + ld0(r,ff,v)*(1+tl(r,ff))
          + sum(k,kd0(r,k,ff,v)*(1+tk(r,k,ff)))
          + rd0(r,ff,v)*(1+tr(r,ff));

    chk0_ff(r,ff,v,'ctax')$(y0(r,ff,v)   and new(v))
         =  sum(ghg,pctax *0.001*ghg0(r,ghg,ff,v)) ;

    chk0_ff(r,ff,v,'ctax_pct')$(y0(r,ff,v)   and new(v))
          = chk0_ff(r,ff,v,'ctax')/ chk0_ff(r,ff,v,'in');

    chk0_ff(r,ff,v,'rd0_pct')$(y0(r,ff,v)   and new(v))
          = rd0(r,ff,v)/ y0(r,ff,v);

option chk0_ff:3:3:1;

    chk0_ag(r,s,v,'out')$(y0(r,s,v)   and new(v) and agr(s) and not liv(s))
        = y0(r,s,v)*(1-ty(r,s));
    chk0_ag(r,s,v,'in')$(y0(r,s,v)   and new(v) and agr(s) and not liv(s))
        =   sum((e,use),ed0(r,e,use,s,v))
          + sum(g,id0(r,g,s,v)*(1+ti(r,g,s)))
          + ld0(r,s,v)*(1+tl(r,s))
          + sum(k,kd0(r,k,s,v)*(1+tk(r,k,s)))
          + hkd0(r,s,v)*(1+thk(r,s))
          + (crp_lnd0(r,s,v)*(1+tn(r,s)))$crp(s)
          + (lnd0(r,s,v)*(1+tn(r,s)))$(not crp(s))
          + rd0(r,s,v)*(1+tr(r,s))   ;

    chk0_ag(r,s,v,'out')$(y0(r,s,v)   and new(v) and  liv(s))
         = y0(r,s,v)*(1-ty(r,s));
    chk0_ag(r,s,v,'in')$(y0(r,s,v)    and new(v) and  liv(s))
        =   sum((e,use),ed0(r,e,use,s,v))
          + sum(g$(not (feed(g) or ofd(g))),id0(r,g,s,v)*(1+ti(r,g,s)))
          + feed0(r,s,v)
          + ld0(r,s,v)*(1+tl(r,s))
          + sum(k,kd0(r,k,s,v)*(1+tk(r,k,s)))
          + hkd0(r,s,v)*(1+thk(r,s))
          + lnd0(r,s,v)*(1+tn(r,s))
          + rd0(r,s,v)*(1+tr(r,s))   ;

    chk0_ag(r,s,v,'ctax')$(y0(r,s,v)   and new(v) and agr(s))
         =  sum(ghg,pctax *0.001*ghg0(r,ghg,s,v));

    chk0_ag(r,s,v,'ctax_share')$(y0(r,s,v)   and new(v) and agr(s))
         = chk0_ag(r,s,v,'ctax')/ chk0_ag(r,s,v,'in');

    chk0_shr(r,i,g,v)$(y0(r,i,v)   and new(v) )
         =  id0(r,g,i,v)*(1+ti(r,g,i))/(y0(r,i,v)*(1-ty(r,i)));

    chk0_shr(r,i,"land",v)$(y0(r,i,v)   and new(v) and agr(i))
        = (crp_lnd0(r,i,v)*(1+tn(r,i)))/(y0(r,i,v)*(1-ty(r,i)));

    chk0_shr(r,i,"labor",v)$(y0(r,i,v)   and new(v) )
        = ld0(r,i,v)*(1+tl(r,i))/(y0(r,i,v)*(1-ty(r,i)));

    chk0_shr(r,i,"kapital",v)$(y0(r,i,v)   and new(v) )
        = ( sum(k,kd0(r,k,i,v)*(1+tk(r,k,i)))+ hkd0(r,i,v)*(1+thk(r,i))) /(y0(r,i,v)*(1-ty(r,i)));

    chk0_shr(r,i,"en",v)$(y0(r,i,v)   and new(v) )
       =  sum((e,use),ed0(r,e,use,i,v)) /(y0(r,i,v)*(1-ty(r,i)));

    chk0_exy(r,s,v,'out')$(y0(r,s,v) and ( (new(v) and not agr(s)) or extant(v)  ))
        = y0(r,s,v)*(1-ty(r,s))
         +y0(r,"omel",v)$vol(s) ;
    chk0_exy(r,s,v,'in')$(y0(r,s,v) and ( (new(v) and not agr(s)) or extant(v)  ))
        =   (sum((e,use),ed0(r,e,use,s,v)))$extant(v)
          + (   sum((e,use)$(not fdst(use)), ed0(r,e,use,s,v))
              + sum((e,use)$fdst(use), ed0(r,e,use,s,v)) )$new(v)
          + sum(g,id0(r,g,s,v)*(1+ti(r,g,s)))
          + ld0(r,s,v)*(1+tl(r,s))
          + sum(k,kd0(r,k,s,v)*(1+tk(r,k,s)))
          + hkd0(r,s,v)*(1+thk(r,s))
          + (crp_lnd0(r,s,v)*(1+tn(r,s)))$crp(s)
          + (lnd0(r,s,v)*(1+tn(r,s)))$(not crp(s))
          + rd0(r,s,v)*(1+tr(r,s));

    chk0_exy(r,s,v,'ed0')$(y0(r,s,v) and ( (new(v) and vol(s)) or extant(v)  ))
        = (   (sum((e,use),ed0(r,e,use,s,v)))$extant(v)
           + (   sum((e,use)$(not fdst(use)), ed0(r,e,use,s,v))
              + sum((e,use)$fdst(use), ed0(r,e,use,s,v)) )$new(v))
           /chk0_exy(r,s,v,'out') ;
    chk0_exy(r,s,v,'id0')$(y0(r,s,v) and ( (new(v) and vol(s)) or extant(v)  ))
          = sum(g,id0(r,g,s,v)*(1+ti(r,g,s)))/chk0_exy(r,s,v,'out') ;

    chk0_exy(r,s,v,'ld0')$(y0(r,s,v) and ( (new(v) and vol(s)) or extant(v)  ))
          =   ld0(r,s,v)*(1+tl(r,s))/chk0_exy(r,s,v,'out');

    chk0_exy(r,s,v,'kd0')$(y0(r,s,v) and ( (new(v) and vol(s)) or extant(v)  ))
          =   sum(k,kd0(r,k,s,v)*(1+tk(r,k,s)))/chk0_exy(r,s,v,'out') ;

    chk0_exy(r,s,v,'hkd0')$(y0(r,s,v) and ( (new(v) and vol(s)) or extant(v)  ))
         =  hkd0(r,s,v)*(1+thk(r,s))/chk0_exy(r,s,v,'out');

    chk0_exy(r,s,v,'lnd0')$(y0(r,s,v) and ( (new(v) and vol(s)) or extant(v)  ))
         =( (crp_lnd0(r,s,v)*(1+tn(r,s)))$crp(s)
          + (lnd0(r,s,v)*(1+tn(r,s)))$(not crp(s))
          + rd0(r,s,v)*(1+tr(r,s)))/chk0_exy(r,s,v,'out');

    chk0_exy(r,s,v,'in-out')=  chk0_exy(r,s,v,'in')-  chk0_exy(r,s,v,'out');

    chk0_agp(r,g,s,'a')$(id0(r,g,s,'new'))= pid0(r,g,s)-(1+ti(r,g,s));
    chk0_agp(r,s,'labor','l')$ld0(r,s,'new')= pld0(r,s)-(1+tl(r,s));
    chk0_agp(r,s,k,'k' )$kd0(r,k,s,'new')= pkd0(r,k,s)-(1+tk(r,k,s));
    chk0_agp(r,s,'hucap','hk')$hkd0(r,s,'new')= phkd0(r,s)-(1+thk(r,s));
    chk0_agp(r,s,'land','lnd')$(lnd0(r,s,'new') or crp_lnd0(r,s,'new'))= plnd0(r,s)-(1+tn(r,s));
    chk0_agp(r,s,'resource','lnd')$rd0(r,s,'new') = prd0(r,s)-(1+tr(r,s));

* agrii -> agri
    chk0_lnd(r,agri,agrii,v,'out')$(f_luc(r,agri,agrii) and luc(r) and new(v) and rent_r0(r,agri,agrii))
         = npp(r,agri)*v_land0(r,agri);
    chk0_lnd(r,agri,agrii,v,'in')$(f_luc(r,agri,agrii) and luc(r) and new(v) and rent_r0(r,agri,agrii))
         =  npp(r,agrii)*v_land0(r,agrii)
          + sum((e,use,g),npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shre(r,agri,e,use,g,v))
          + sum(g,npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agri,g,v))
          + npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agri,'L',v)
          + sum(k,npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agri,k,v))
          + npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agri,'hk',v)
          + npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agri,'r',v)
          + npp(r,agrii)*mk_luc(r,agri,agrii)*fffor0(r,agrii,v)   ;

    chk0_lnd(r,agri,agrii,v,'in_ctax')$(f_luc(r,agri,agrii) and luc(r) and new(v) and rent_r0(r,agri,agrii))
         = pctax*npp(r,agrii)*debtcarb(r,agri,agrii)/1000;

    chk0_lnd(r,agri,agrii,v,'out_ctax')$(f_luc(r,agri,agrii) and luc(r) and new(v) and rent_r0(r,agri,agrii))
         = pctax*npp(r,agri)*credcarb(r,agri,agrii)/1000;

    chk0_lnd(r,agri,agrii,v,'in-out')$(f_luc(r,agri,agrii) and luc(r) and new(v) and rent_r0(r,agri,agrii))
         = round( (chk0_lnd(r,agri,agrii,v,'in')- chk0_lnd(r,agri,agrii,v,'out')),5);

* agri -> nat
    chk0_lnd(r,nat,agri,v,'out')$(f_luc(r,nat,agri) and luc(r) and new(v) and rent_r0(r,nat,agri))
         = npp(r,nat)*v_land0(r,nat);
    chk0_lnd(r,nat,agri,v,'in')$(f_luc(r,nat,agri) and luc(r) and new(v) and rent_r0(r,nat,agri))
         =  npp(r,agri)*v_land0(r,agri)
          + sum((e,use,g),npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shre(r,agri,e,use,g,v))
          + sum(g,npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,g,v))
          + npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,'L',v)
          + sum(k,npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,k,v))
          + npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,'hk',v)
          + npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,'r',v)   ;

    chk0_lnd(r,nat,agri,v,'in_ctax')$(f_luc(r,nat,agri) and luc(r) and new(v) and rent_r0(r,nat,agri))
         = pctax*npp(r,agri)*debtcarb(r,nat,agri)/1000;
    chk0_lnd(r,nat,agri,v,'out_ctax')$(f_luc(r,nat,agri) and luc(r) and new(v) and rent_r0(r,nat,agri))
         = pctax*npp(r,nat)*credcarb(r,nat,agri)/1000;

    chk0_lnd(r,nat,agri,v,'in-out')$(f_luc(r,nat,agri) and luc(r) and new(v) and rent_r0(r,nat,agri))
         = round( (chk0_lnd(r,nat,agri,v,'in')- chk0_lnd(r,nat,agri,v,'out')),5);

* nat -> agri

    chk0_lnd(r,agri,nat,v,'out')$(f_luc(r,agri,nat) and luc(r) and new(v) and rent_r0(r,agri,nat))
         =    npp(r,agri)*v_land0(r,agri)
            + npp(r,nat)*lndout(r,nat,v)*(1-ty(r,agri));
    chk0_lnd(r,agri,nat,v,'in')$(f_luc(r,agri,nat) and luc(r) and new(v) and rent_r0(r,agri,nat))
         =  npp(r,nat)*v_land0(r,nat)
          + sum((e,use,g),npp(r,nat)*mk_luc(r,agri,nat)*otinp(r,nat,v)*ag_shre(r,agri,e,use,g,v))
          + sum(g,npp(r,nat)*mk_luc(r,agri,nat)*otinp(r,nat,v)*ag_shr(r,agri,g,v))
          + npp(r,nat)*mk_luc(r,agri,nat)*otinp(r,nat,v)*ag_shr(r,agri,'L',v)
          + sum(k,npp(r,nat)*mk_luc(r,agri,nat)*otinp(r,nat,v)*ag_shr(r,agri,k,v))
          + npp(r,nat)*mk_luc(r,agri,nat)*otinp(r,nat,v)*ag_shr(r,agri,'hk',v)
          + npp(r,nat)*mk_luc(r,agri,nat)*otinp(r,nat,v)*ag_shr(r,agri,'r',v)
          + npp(r,nat)*mk_luc(r,agri,nat)*fffor0(r,nat,v)   ;

    chk0_lnd(r,agri,nat,v,'in_ctax')$(f_luc(r,agri,nat) and luc(r) and new(v) and rent_r0(r,agri,nat))
         = pctax*npp(r,nat)*debtcarb(r,agri,nat)/1000;
    chk0_lnd(r,agri,nat,v,'out_ctax')$(f_luc(r,agri,nat) and luc(r) and new(v) and rent_r0(r,agri,nat))
         = pctax*npp(r,agri)*credcarb(r,agri,nat)/1000;

    chk0_lnd(r,agri,nat,v,'in-out')$(f_luc(r,agri,nat) and luc(r) and new(v) and rent_r0(r,agri,nat))
         = round( (chk0_lnd(r,agri,nat,v,'in')- chk0_lnd(r,agri,nat,v,'out')),5);

    chk0_lnd(r,agri,nat,v,'diff')$(f_luc(r,agri,nat) and luc(r) and new(v) and rent_r0(r,agri,nat))
         =round( (   npp(r,nat)*v_land0(r,nat)
                   + otinp(r,nat,v)
                   + fffor0(r,nat,v)
                   - chk0_lnd(r,agri,nat,v,'out')),5);

    chk0_lrent(r,nat,v)$(new(v) and nfrs(nat))
        = rentv0(r,nat) - lnd0(r,"frs",v)*(1-l_shr(r,"frs"))*nat_tran(r,"inp") ;

    chk0_x(r,i,'input')$((sum(vnum,y0(r,i,vnum)  ) and not gentype(i)) or ele(i))
        = sum(vnum,y0(r,i,vnum));

    chk0_x(r,i,'output')$((sum(vnum,y0(r,i,vnum)  ) and not gentype(i)) or ele(i) and not cru(i))
        = d0(r,i)+ x0(r,i,"ftrd") ;

    chk0_x(r,i,'output')$((sum(vnum,y0(r,i,vnum)  ) and not gentype(i)) or ele(i) and cru(i))
        = sum(vnum,y0(r,i,vnum)  ) ;

    chk0_x(r,i,"input-output") = chk0_x(r,i,'input')-chk0_x(r,i,'output');
    chk0_a(r,i)$a0(r,i)=a0(r,i)-d0(r,i)-m0(r,i,"ftrd");

    chk0_c(r,"y0") = c0(r,"hh");
    chk0_c(r,g)$(not trn(g))= cd0(r,"hh",g)*(1+tc(r,g));
    chk0_c(r,trn)  = cd0(r,"hh",trn);
    chk0_c(r,"hou")= cd0(r,"hh","house");
    chk0_c(r,"in")=      sum(g$(not trn(g)), chk0_c(r,g))
                       +sum(trn,chk0_c(r,trn))
                       +chk0_c(r,"hou") ;

    chk0_w(r,hh)= cl0(r,hh) - c0(r,hh) - leis0(r,hh) ;
    cl0(r,hh)   = c0(r,hh) +  leis0(r,hh)+ chk0_w(r,hh);

    chk0_py(r,i,"y0") = y0(r,i,"new");
    chk0_py(r,i,"d0") = d0(r,i) +sum(rr,n0(rr,r,i))+tpt0(r,i);
    chk0_py(r,i,"diff") = chk0_py(r,i,"y0")- chk0_py(r,i,"d0");
    d0(r,s)= y0(r,s,"new")- sum(rr,n0(rr,r,s))-tpt0(r,s);
    a0(r,s)= d0(r,s)+ m0(r,s,"ftrd");

    chk0_emkt(r,e,"fuel",trn,"retail") =  ertl0(r,e,"fuel",trn)*(1-te(r,e,"fuel",trn) );
    chk0_emkt(r,e,"fuel",trn,"marg")   =  emrg0(r,e,"fuel",trn);
    chk0_emkt(r,e,"fuel",trn,"whole")  =  ewhl0(r,e,"fuel",trn) ;
    chk0_emkt(r,e,"fuel",trn,"diff")
        =  chk0_emkt(r,e,"fuel",trn,"retail")
         - chk0_emkt(r,e,"fuel",trn,"marg")
         - chk0_emkt(r,e,"fuel",trn,"whole");

    chk0_emkt(r,e,"fuel",trn,"%")$chk0_emkt(r,e,"fuel",trn,"whole")
        =    chk0_emkt(r,e,"fuel",trn,"marg")
           / chk0_emkt(r,e,"fuel",trn,"whole");


parameter   chk0_bioprod      Check biofuel production cost
            chk0_bioprods     Check biofuel production input share
            chk0_ddgstrd(r,*) Check ddgs trade
            chk0_feed         Check livestock feed input

            chk0_trned_val    Report transportation energy consumption ($billion)
            chk0_trned_btu    Report transportation energy consumption (quad btu)  ;

       chk0_bioprod(r,bio,"prod"," ")    =  y0(r,bio,"new");
       chk0_bioprod(r,bio,"use_en",e)    =  sum(use,ed0(r,e,use,bio,"new"));
       chk0_bioprod(r,bio,"use_input",g) =  id0(r,g,bio,"new");
       chk0_bioprod(r,bio,"use_input","labor")   =  ld0(r,bio,"new");
       chk0_bioprod(r,bio,"use_input","capital") =  sum(k,kd0(r,k,bio,"new"));

       chk0_bioprods(r,bio,"prod"," ")    =  y0(r,bio,"new");
       chk0_bioprods(r,bio,"use_en",e)$y0(r,bio,"new")    =  sum(use,ed0(r,e,use,bio,"new"))/y0(r,bio,"new");
       chk0_bioprods(r,bio,"use_input",g)$y0(r,bio,"new") =  id0(r,g,bio,"new")/y0(r,bio,"new");
       chk0_bioprods(r,bio,"use_input","labor")$y0(r,bio,"new")   =  ld0(r,bio,"new")/y0(r,bio,"new");
       chk0_bioprods(r,bio,"use_input","capital")$y0(r,bio,"new") =  sum(k,kd0(r,k,bio,"new"))/y0(r,bio,"new");

       chk0_ddgstrd(r,"import")=m0(r,"ddgs","ftrd");
       chk0_ddgstrd(r,"export")=x0(r,"ddgs","ftrd");

       chk0_feed(r,"output")=feed0(r,"liv","new");
       chk0_feed(r,"ddgs")  =id0(r,"ddgs","liv","new");
       chk0_feed(r,"omel")  =id0(r,"omel","liv","new");
       chk0_feed(r,g)$(crp(g) or ofd(g)) =id0(r,g,"liv","new");
       chk0_feed(r,"Input") =sum(i,chk0_feed(r,i)*(1+ti(r,i,"liv")));

   chk0_ag(r,s,v,'energy')$(y0(r,s,v)   and new(v) and agr(s) and not liv(s) and chk0_ag(r,s,v,'out') and ag_pric0(r,s))
       = 1000*  sum((e,use),ed0(r,e,use,s,v))/(chk0_ag(r,s,v,'out')/ag_pric0(r,s));
   chk0_ag(r,s,v,'material')$(y0(r,s,v)   and new(v) and agr(s) and not liv(s) and chk0_ag(r,s,v,'out') and ag_pric0(r,s))
       =1000*  sum(g,id0(r,g,s,v)*(1+ti(r,g,s)))/(chk0_ag(r,s,v,'out')/ag_pric0(r,s)) ;
   chk0_ag(r,s,v,'labor')$(y0(r,s,v)   and new(v) and agr(s) and not liv(s) and chk0_ag(r,s,v,'out') and ag_pric0(r,s))
      =   1000* ld0(r,s,v)*(1+tl(r,s))/(chk0_ag(r,s,v,'out')/ag_pric0(r,s));

   chk0_ag(r,s,v,'capital')$(y0(r,s,v)   and new(v) and agr(s) and not liv(s) and chk0_ag(r,s,v,'out') and ag_pric0(r,s))
      =  1000* (sum(k,kd0(r,k,s,v)*(1+tk(r,k,s)))+ hkd0(r,s,v)*(1+thk(r,s)))/(chk0_ag(r,s,v,'out')/ag_pric0(r,s));

   chk0_ag(r,s,v,'land')$(y0(r,s,v)   and new(v) and agr(s) and not liv(s) and chk0_ag(r,s,v,'out') and ag_pric0(r,s))
     =  1000* (crp_lnd0(r,s,v)*(1+tn(r,s)))/(chk0_ag(r,s,v,'out')/ag_pric0(r,s))  ;

   chk0_ag(r,s,v,'Price')$(y0(r,s,v)   and new(v) and agr(s) and not liv(s) and chk0_ag(r,s,v,'out') and ag_pric0(r,s))
     =  1000*chk0_ag(r,s,v,'in')/(chk0_ag(r,s,v,'out')/ag_pric0(r,s))  ;



   chk0_ag(r,s,v,'energy_peracre')$(y0(r,s,v)   and new(v) and crp(s) and not liv(s) and q_land0(r,s))
       = 1000*  sum((e,use),ed0(r,e,use,s,v))/ q_land0(r,s);
   chk0_ag(r,s,v,'material_peracre')$(y0(r,s,v)   and new(v) and crp(s) and not liv(s) and q_land0(r,s))
       =1000*  sum(g,id0(r,g,s,v)*(1+ti(r,g,s)))/ q_land0(r,s) ;
   chk0_ag(r,s,v,'labor_peracre')$(y0(r,s,v)   and new(v) and crp(s) and not liv(s) and q_land0(r,s))
      =   1000* ld0(r,s,v)*(1+tl(r,s))/ q_land0(r,s);

   chk0_ag(r,s,v,'capital_peracre')$(y0(r,s,v)   and new(v) and crp(s) and not liv(s) and q_land0(r,s))
      =  1000* (sum(k,kd0(r,k,s,v)*(1+tk(r,k,s)))+ hkd0(r,s,v)*(1+thk(r,s)))/ q_land0(r,s);

   chk0_ag(r,s,v,'land_peracre')$(y0(r,s,v)   and new(v) and crp(s) and not liv(s) and q_land0(r,s))
     =  1000* (crp_lnd0(r,s,v)*(1+tn(r,s)))/q_land0(r,s) ;

   chk0_trned_val(r,e,trn)= ed0(r,e,"fuel",trn,"new");
   chk0_trned_btu(r,e,trn)= btu0(r,e,"fuel",trn);

option  chk0_bioprod:3:2:2, chk0_bioprods:3:2:2
display chk0_bioprod, chk0_bioprods, chk0_ddgstrd;

option  ed0:2:0:5,chk0_trned_val:2:2:1, chk0_trned_btu:2:2:1
display chk0_feed,byprod,pid0,ed0,chk0_trned_val,chk0_trned_btu;

option  chk0_ag:3:3:1;
option  chk0_agp:3:3:1;
option  chk0_lnd:3:3:2;
option  chk0_lrent:3:1:2;
option  chk0_x:3:2:1;
option  chk0_exy:3:3:1,chk0_shr:3:2:2;
display chk0_ag, chk0_agp, chk0_lnd, chk0_lrent, chk0_x, chk0_a, chk0_exy,chk0_shr;


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                            Capital vintaging and other endowments
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
parameter
        nk0_10_(r,k,i)       New capital in 2010
        nk0(r,k)             New capital in the model
        xk0_10_(r,k,i)       Extant capital in 2010
        xk0(r,k,i)           Extant capital in the model
        hke0(r)              Human capital endowment
        hke0_10_(r)          Human capital endowment in 2010
        inve0(r,k)           Investment endowment;

    xk0_10_(r,k,i) =  kd0(r,k,i,"extant") *clay(r,i);
    nk0_10_(r,k,i) =  kd0(r,k,i,'new') *(1-clay(r,i));
    xk0(r,k,i)$(not conv(i))     =  xk0_10_(r,k,i);
    nk0(r,k)                     =  sum(i$(not conv(i)), nk0_10_(r,k,i));
    hke0(r)        =  sum((s,vnum), hkd0(r,s,vnum));
    hke0_10_(r)    =  sum((s,vnum), hkd0(r,s,vnum));
    inve0(r,k)     =  inv0(r,k);

display   hkd0,xk0_10_;

* Assign endowment for land & energy resource and renewable electricity resources
    lnde0(r,i,v) =  lnd0(r,i,v)   ;
    re0(r,i,v)   =  rd0(r,i,v)    ;
    rnwe0(r,i,v) =  rnw0(r,i,v)   ;
    rentv(r,i)   =  rentv0(r,i);
    fffor(r,lu,v)$vnum(v)=fffor0(r,lu,v);
    gove0(r)     =  gov0(r)       ;

scalar
        ror             Capital rate of return    / 0.10 /
        depr            Depreciation rate         / 0.05 /  ;

parameter
        srvshr(r)            Single period survival share for extant capital
        theta(r)             Share of new vintage which is frozen each period
        oldcap(r,k,i,t)      Old capital over the time ($billion)
        newcap(r,k,i,t)      New capital over the time ($billion)
        totcap(r,k,i,t)      Total capital over the time ($billion)
        ket(r,k,i,v,t)       Capital over the time ($billion)
        xket                 Extant capital the time ($billion)
        nket                 New capital the time ($billion)
        scale(r,k,i)         Scale factor
        hket0(r,t)           Human capital over the time ($billion)
        hket(r,t)            Human capital over the time ($billion)
 ;

    srvshr(r)= (1-depr)**5;
    theta(r) = 0.40 ;


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                           GDP and Population updates
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
set    source      Source of GDP data  /AEO2013, AEO2018, IEO2013, IEO2014, IEO2017, EIASTAT, ADAGE/
       gdptype     Type of GDP         /MER, PPP/
       type        Type of data source /Assumption, Simulated/
       th(t)       Historical period   /2010, 2015/;

* GDP data from FAO and IEO2012 where GDP is updated periodically to IEO2013, IEO 2014, IEO2017 later through model development during 2012~present
$include '.\data\data8_trend.dat'
display  gdp_trend,pop;

parameter gdp_ieo2013r(r,t)        GDP projections by adage regions in IEO2013 based on market exchange rate (billion $2010)
          gdp_ieo2013trd(r,t)      GDP trend by adage regions in IEO2013 based on market exchange rate (baseyear=1 in 2010)
          gdp_ieo2013growth(r,t)   GDP annual growth rate by ADAGE regions in IEO2013 based on market exchange rate ;

$gdxin 'data\data9a_gdp_ieo2013.gdx'
$load gdp_ieo2013r=gdp_aeor gdp_ieo2013trd=gdp_aeotrd gdp_ieo2013growth=gdp_aeogrowth

parameter gdp_ieo2014r(r,t)        GDP projections by  ADAGE regions in IEO2014 based on purchasing power parity(billion $2010)
          gdp_ieo2014trd(r,t)      GDP trend by  ADAGE regions in IEO2014 based on purchasing power parity(baseyear=1 in 2010)
          gdp_ieo2014growth(r,t)   GDP annual growth rate by ADAGE regions in IEO2014 based on purchasing power parity;

$gdxin 'data\data9b_gdp_ieo2014.gdx'
$load  gdp_ieo2014r=gdp_aeo2014r  gdp_ieo2014trd=gdp_aeo2014trd  gdp_ieo2014growth=gdp_aeo2014growth
display  gdp_ieo2014trd;


parameter gdp_all         GDP from AEO and IEO in various years (billion in $2010)
          pop_all         Population projections from UN2017 and 2010 (million);
$gdxin .\data\data9c_gdp_all.gdx
$load   gdp_all=gdp_r_all   pop_all=pop_all

    gdp_all(r,"MER","IEO2013",t) = gdp_ieo2013r(r,t);
    gdp_all(r,"PPP","IEO2014",t) = gdp_ieo2014r(r,t);
display  GDP_all, pop_all;

parameter GDP            GDP projection in purchasing power parity ($billion 2010)
          chk_GDPtrd     Compare GDP projection difference before and after
          chk_poptrd     Compare population projection difference between UN2017 and UN2010
          pop_trend      Population growth trend
          lprd_trend     Labor productivity growth trend
          kprd_trend     Capital growth trend;

    chk_GDPtrd(r,"Old",t) = gdp_trend(r,t);
* 2010~2015 are from world bank and 2020~2050 are from IEO2017
* Regions in ADAGE and World Bank are matching, so use World Bank as the base point.
* Regions in ADAGE and IEO are roughly matching so only trend is used relative to its baseline
    gdp_trend(r,t)       = GDP_all(r,"MER","IEO2017",t)/GDP_all(r,"MER","IEO2017","2010");
    gdp_trend(r,t)$th(t) = GDP_all(r,"MER","WB",t)/GDP_all(r,"MER","WB","2010");
    chk_GDPtrd(r,"New",t)= gdp_trend(r,t);
    GDP(r,t)             = GDP_all(r,"MER","WB","2010")*gdp_trend(r,t);

    chk_poptrd(r,"Old",t) = pop_all(r,"UN2010",t)/pop_all(r,"UN2010","2010");
    chk_poptrd(r,"New",t) = pop_all(r,"UN2017",t)/pop_all(r,"UN2017","2010");
    pop(r,t)              = pop_all(r,"UN2017",t);
* Labor trend is shifted at same rate of population growth rate
    labor_trend(r,t)      = labor_trend(r,t)*chk_poptrd(r,"New",t)/chk_poptrd(r,"Old",t);

    pop_trend(r,t)        =  pop(r,t)/pop(r,"2010");
    lprd_trend(r,t)       =  gdp_trend(r,t) - pop_trend(r,t) + 1;

* Allow budget deficit to grow with GDP
    bopdeft0(r,hh,"2010") = bopdef0(r,hh);
    bopdeft0(r,hh,t)      = bopdeft0(r,hh,"2010")*gdp_trend(r,t);

display "IEO2017", gdp_trend, chk_GDPtrd,chk_poptrd,GDP,pop,lprd_trend,labor_trend;


scalar     deflator          Deflator used to convert dollar between $2005 and $2010 /1.10774/;
parameter  deflator_R(reg)   GDP deflator adjustment factor when original data is converted from $2005 to $2010 by region
* This should be considered but it didn't in the raw data processing part where only a uniform deflator 1.10774 from US is used.
* so the actual deflator = deflator_r*1.108 if we need to report output or input in $2005
     / USA   1.000
       BRA   1.619
       CHN   1.445
       EUR   0.920
       XLM   1.280
       XAS   1.002
       AFR   1.202
       ROW   1.451
    /;

parameter aggrowth(r)       Annual percentage reduction of the share of ag value added from GDP from FAO;
* The above is using the historical trend from 1980-2013
$gdxin 'data\data10_aggrowth.gdx'
$load aggrowth=aggrowth_8r

option  aggrowth:4:0:1
display aggrowth;

table co2_trd(r,cgo)   CO2 average annual emission reduction growth rate based on historical eia data from 1980-2011
                       Col              Oil               Gas
     AFR        -0.0005151        0.0003779        -0.0114778
     BRA         0.0006958       -0.0014489        -0.0028978
     CHN        -0.0003945       -0.0027618        -0.0003999
     EUR         0.0013409       -0.0016365        -0.0001995
     ROW         0.0000228       -0.0013220        -0.0058547
     USA         0.0007508       -0.0006650         0.0000356
     XAS         0.0000044       -0.0037272        -0.0091223
     XLM        -0.0001417        0.0006473        -0.0020834
;

    co2_trd(r,cgo)$(co2_trd(r,cgo)>0) = -co2_trd(r,cgo);


parameter   co2_trend(r,cgo,t)       CO2 emission reduction trend from energy combustion for producing same unit of output
            ghg_trend(r,ghg,i,v,t)   GHG emission reduction trend from non-energy combustion;

    co2_trend(r,cgo,t)=(1+ co2_trd(r,cgo))**(5*(ord(t)-1));
    co2_trend(r,cgo,t)=1;

    ghg_trend(r,ghg,i,v,t)$ghgt0(r,ghg,i,v,"2010")
        =ghgt0(r,ghg,i,v,t)/ghgt0(r,ghg,i,v,"2010")/gdp_trend(r,t);

    ghg_trend(r,ghg,agr,v,t)$ghgt0(r,ghg,agr,v,"2010")
        =ghgt0(r,ghg,agr,v,t)/ghgt0(r,ghg,agr,v,"2010")/(gdp_trend(r,t)*(1+aggrowth(r))**(5*(ord(t)-1)));

* Assign an upper and lower bound for the emission reduction efficiency
    ghg_trend(r,ghg,i,v,t)$(ghg_trend(r,ghg,i,v,t)>1) = (1-0.001)**(5*(ord(t)-1));
    ghg_trend(r,ghg,i,v,t)$(ghg_trend(r,ghg,i,v,t) and not sameas(r,"CHN") and ghg_trend(r,ghg,i,v,t)<(1-0.02)**(5*(ord(t)-1)))=(1-0.02)**(5*(ord(t)-1));
    ghg_trend(r,ghg,i,v,t)$(ghg_trend(r,ghg,i,v,t) and     sameas(r,"CHN") and ghg_trend(r,ghg,i,v,t)<(1-0.04)**(5*(ord(t)-1)))=(1-0.04)**(5*(ord(t)-1));
    ghg_trend("BRA","sf6","ele",v,t) = ghg_trend("BRA","sf6","eim",v,t);

* Fix trend outliers
loop(t$(t.val>=2030 and t.val<=2050),
     ghg_trend(r,ghg,i,v,t)$(ghg_trend(r,ghg,i,v,t) and ghg_trend(r,ghg,i,v,t)>ghg_trend(r,ghg,i,v,t-1) and ghg_trend(r,ghg,i,v,"2020"))
                 = ghg_trend(r,ghg,i,v,t-1) * ghg_trend(r,ghg,i,v,"2025")/ghg_trend(r,ghg,i,v,"2020"););
    ghg_trend(r,"N2O",crp,"new","2020")$num(r)  = 0.97;
    ghg_trend(r,"N2O","wht","new","2025")$num(r)= 0.85;
    ghg_trend(r,"N2O",crp,v,t)$(num(r) and not sameas(crp,"gron")) = ghg_trend(r,"N2O","wht",v,t);

option ghg_trend:2:4:1
display ghg_trend,co2_trend;

set     tt0(t)   /2010, 2030, 2050/
parameter ghg_trend_report(i,ghg,t)   Report ghg trend ;
    ghg_trend_report(i,ghg,tt0)=  ghg_trend("USA",ghg,i,"new",tt0);
    ghg_trend_report(i,ghg,tt0)$(ghg_trend_report(i,ghg,tt0)>1)= (1-0.005)**(5*(ord(tt0)-1));
option   ghg_trend_report:3:1:2
display  ghg_trend_report;

    efs_trend('chn',i,t)$(efs_trend('chn',i,'2015')<1)=efs_trend('usa',i,t);
    efs_trend('chn',i,t)$(t.val>2010 and efs_trend('chn',i,t))=1+2*(efs_trend('usa',i,t)-1);
    efs_trend(r,i,t)$(efs_trend(r,i,t)=1 )= efs_trend(r,'trn',t);
    efs_trend("USA","hh",t)= (1+0.03)**(5*(ord(t)-1));

    efs_trend(r,trn,t)=efs_trend(r,'trn',t);
    efs_trend(r,'trn',t)=0;

parameter idag_trend(t)     Agriculture input growth trend in production for China;
    idag_trend("2010")=1;
loop(t$(t.val>2010),
    idag_trend(t)$(t.val>2010 and t.val<2035)=idag_trend(t-1)*(1-0.02)**5;
    idag_trend(t)$(t.val>=2035 )=idag_trend(t-1)*(1-0.015)**5;  );
display idag_trend;

parameter ghg_ton           GHG emissions from agriculture (ton co2eq per ton);
    ghg_ton(r,ghg,i)$ag_tonn0(r,i)= ghg0(r,ghg,i,"new")/ ag_tonn0(r,i);
    ton_conv(r,crp)$ag_valu0(r,crp)= ag_tonn0(r,crp)/ag_valu0(r,crp);
display ghg_ton;

* Exogenous parameters (GDP, energy price and energy consumption) that ADAGE calibrates
$include match.gms

parameter
       target_fuel          Biofuel limit (quadbtu)
       target_gal           Biofuel limit (billion gallons)

       f_biocap0(e)         Factor to set up the trend for biofuel limit in armington block
       f_biocapT(e,t)       Factor to set up the trend for biofuel limit in armington block over the time ;

parameter
       pa0                  Armington energy goods price in 2010 ($billion per quad btu)
       poev0                Average price for mixed oil-biofuel price in 2010 ($billion per quad btu) ;

    pa0(r,i)$(e(i) and (d0(r,i)*btuprod_conv(r,i)+em0_btu(r,i)))
        = a0(r,i)/(d0(r,i)*btuprod_conv(r,i)+em0_btu(r,i));

    poev0(r,trn)$sum(e$ob(e),btu0(r,e,"fuel",trn)) = oev_valu0(r,trn,"extant")/sum(e$ob(e),btu0(r,e,"fuel",trn));


Parameter
       autooev_shr0         Share of fuel in LDV energy use in 2010 in $
       hdvoev_shr0          Share of fuel in HDV energy use in 2010 in $
       hdvoev_shrt0         Share of fuel in HDV in future years if biofuel is expanded to HDV in $
       autooev_shr_btu0     Share of fuel in LDV energy use in 2010 in btu

       beta0                Initial input ratio for biofuels in hdv energy production
       betat0               hdv energy production after introduction of biofuels
       beta                 Updated input ratio for biofuels in the hdv energy production
       beta_                Report final beta

       phi0                 Initial input growth in scn in the auto energy production
       phi                  Updated input growth in scn in the auto energy production
       phi_                 Report final phi;


Set mapbioshr(i,j)   Map biofuel share in LDV to biofuel share in HDV to replace oil if it is allowed
* One-to-one mapping for all regions
  /  oil.  oil
     ceth. ceth
     scet. scet
     weth. weth
     sbet. sbet
     sybd. sybd
     Plbd. Plbd
     cobd. cobd
     rpbd. rpbd
     Swge. Swge, Albd.Albd, Msce.Msce, ArsE.ArsE, FrsE.FrsE, FrwE.FrwE
 / ;


    mapbioshr(advbio,advbio)= yes;
    phi0("Bau",r,e,t)$ad(e) = 1;
    phi(r,e,v)$ob(e)        = 1;

* Note: natural gas is used in conventional LDV/HDV transportation in some regions
*       Here we will only consider biofuel and oil share in LDV
    autooev_shr0(r,e,t)$oil(e)                   = sum(v, ed0(r,e,"fuel","auto",v))  / sum((v,ee)$ob(ee), ed0(r,ee,"fuel","auto",v));
    autooev_shr0(r,e,t)$bioe(e)                  = sum(v, ed0(r,e,"fuel","auto",v))  / sum((v,ee)$ob(ee), ed0(r,ee,"fuel","auto",v));
    autooev_shr0(r,e,t)$(ord(t)>1 and cobd(e))   = chg_biot(r,"ceth",t,e)/ sum((v,ee)$ob(ee), ed0(r,ee,"fuel","auto",v));
    autooev_shr0(r,e,t)$(ord(t)>1 and ad(e)$(not albd(e) and not Msce(e)))
                                                 = phi0("Bau",r,e,t)/ sum((v,ee)$ob(ee), ed0(r,ee,"fuel","auto",v));

* Assume additional cobd and ad are used to substitute oil
    autooev_shr0(r,e,t)$oil(e)   = autooev_shr0(r,e,t)- autooev_shr0(r,"cobd",t)-sum(ad,autooev_shr0(r,ad,t));

    autooev_shr0(r,"ethl",t)    = sum(e$et(e), autooev_shr0(r,e,t));
    autooev_shr0(r,"biod",t)    = sum(e$bd(e), autooev_shr0(r,e,t));
    autooev_shr0(r,"advb",t)    = sum(e$ad(e), autooev_shr0(r,e,t));

parameter autooev_shr_btu0 ;

autooev_shr_btu0(r,e,"ethl",t)$(ethl(e) and sum(ee$ethl(ee),btu0_10(r,ee,"fuel","auto","2010")))
   = btu0_10(r,e,"fuel","auto","2010")/sum(ee$ethl(ee),btu0_10(r,ee,"fuel","auto","2010"));


autooev_shr_btu0(r,e,"biod",t)$(biod(e) and sum(ee$biod(ee),(btu0_10(r,ee,"fuel","auto","2010")+chg_biot(r,"ceth",t,ee)*btu_conv(r,ee,"fuel","auto"))) )
    =    (btu0_10(r,e,"fuel","auto","2010")+ chg_biot(r,"ceth",t,e)*btu_conv(r,e,"fuel","auto"))
       / sum(ee$biod(ee),(btu0_10(r,ee,"fuel","auto","2010")+chg_biot(r,"ceth",t,ee)*btu_conv(r,ee,"fuel","auto")));

autooev_shr_btu0(r,e,"Total",t)$bio(e)
    =    (btu0_10(r,e,"fuel","auto","2010")+ chg_biot(r,"ceth",t,e)*btu_conv(r,e,"fuel","auto"))
       / sum(ee$ob(ee),(btu0_10(r,ee,"fuel","auto","2010")));

* Assume four types of advanced biofuels Swge, ArsE, FrsE, FrwE are activated in the model and sum of them=0.0001
autooev_shr_btu0(r,e,"Total",t)$(advbio(e) and not albd(e) and not msce(e))= 0.0001/4;
autooev_shr_btu0(r,e,"Total",t)$oil(e) = 1- sum(ee,autooev_shr_btu0(r,ee,"Total",t));

option autooev_shr_btu0:5:3:1;

display btu0_10,chg_biot,ed0,chg_bio,btu_conv,autooev_shr0, autooev_shr_btu0;

Table oevshr_btu_EPA(r,j,i,t)     Share of fuel in blended conventional technology in terms of quad btu
* Provided by EPA based on biofuel data, and gasoline and diesel data from STEO and AEO
                        2010           2015
USA . ethl. Auto       0.0675        0.0700
USA . biod. Auto       0.0001        0.0001
USA . advb. Auto       0.0001        0.0001
USA . ethl. RodF       0.0120        0.0123
USA . biod. RodF       0.0320        0.0640
USA . advb. RodF       0.0001        0.0001
USA . ethl. RodP       0.0064        0.0067
USA . biod. RodP       0.0320        0.0640
USA . advb. RodP       0.0001        0.0001
;

oevshr_btu_EPA("USA",j,i,t)$(t.val>2015)      = oevshr_btu_EPA("USA",j,i,"2015");
oevshr_btu_EPA(r,j,i,t)$(hdv(i))              = oevshr_btu_EPA("USA",j,i,t);
* AFR is a special case where there are no first generation biofuels available for all OEV vehicles
oevshr_btu_EPA("afr","ethl",i,t)$(trnv(i))         = 0 ;
oevshr_btu_EPA("afr","biod",i,t)$(trnv(i))         = 0 ;

oevshr_btu_EPA(r,"ethl",i,t)$(auto(i) and not num(r))  = sum(j$ethl(j),autooev_shr_btu0(r,j,"Total",t));
oevshr_btu_EPA(r,"biod",i,t)$(auto(i) and not num(r))  = sum(j$biod(j),autooev_shr_btu0(r,j,"Total",t));
oevshr_btu_EPA(r,"advb",i,t)$(auto(i) and not num(r))  = oevshr_btu_EPA("USA",i,"advb",t);

oevshr_btu_EPA("afr","advb",i,t)$(trnv(i))         = 0.0001 ;

oevshr_btu_EPA(r,"oil",i,t)$trnv(i)  = 1 - oevshr_btu_EPA(r,"ethl",i,t)
                                         - oevshr_btu_EPA(r,"biod",i,t)
                                         - oevshr_btu_EPA(r,"advb",i,t);

oevshr_btu_EPA(r,e,i,t)$(ethl(e))= oevshr_btu_EPA(r,"ethl",i,t)* autooev_shr_btu0(r,e,"ethl",t);
oevshr_btu_EPA(r,e,i,t)$(biod(e))= oevshr_btu_EPA(r,"biod",i,t)* autooev_shr_btu0(r,e,"biod",t);

* Assume four types of advanced biofuels Swge, ArsE, FrsE, FrwE are activated in the model
oevshr_btu_EPA(r,e,i,t)$(advbio(e) and not albd(e) and not msce(e))= oevshr_btu_EPA("USA","advb",i,t)/4;

option  oevshr_btu_EPA:4:3:1;
display oevshr_btu_EPA;


parameter oev_val_EPA(r,j,i,t)  Fuel in blended conventional technology in terms of $billion
          oev_shr0              Share of fuel in blended conventional technology in terms of $;

    oev_val_EPA(r,e,i,t)$(trnv(i) and oevshr_btu_EPA(r,e,i,t) and btu_conv(r,e,"fuel",i))
              =  oevshr_btu_EPA(r,e,i,t)*sum(ee$ob(ee),btu0_10(r,ee,"fuel",i,"2010"))
                /btu_conv(r,e,"fuel",i);

    oev_shr0(r,e,i,v,t)$(trnv(i) and sum(ee$ob(ee),  oev_val_EPA(r,e,i,t)))
        = oev_val_EPA(r,e,i,t)/sum(ee$ob(ee),  oev_val_EPA(r,e,i,t));

option oev_val_EPA:4:3:1;
display oev_val_EPA;

parameter chk0_oevbtu          check to see the sum of OEV share equals to 1
          chk0_oevval          check to see if the sum of OEV value equals to the $;
    chk0_oevbtu(r,i,t)$trnv(i) = sum(e$ob(e),oevshr_btu_EPA(r,e,i,t));
    chk0_oevval(r,i,"EPA",t)$trnv(i)  = sum(e,oev_val_EPA(r,e,i,t));
    chk0_oevval(r,i,"Data",t)$trnv(i) = sum(ee$ob(ee),  sum(vnum(v), ed0_10(r,ee,"fuel",i,v,"2010")));
    chk0_oevval(r,i,"Diff",t) = round((chk0_oevval(r,i,"EPA",t) - chk0_oevval(r,i,"Data",t)),6);

* There is a price difference between fuels so quad btu based share won't match the $ based amount. The difference is small so we map the difference to oil.
    oev_val_EPA(r,"oil",i,t)    = oev_val_EPA(r,"oil",i,t)- chk0_oevval(r,i,"Diff",t);
    oev_shr0(r,e,i,v,t)$(trnv(i) and sum(ee$ob(ee), ed0_10(r,ee,"fuel",i,"new","2010")))
                                = oev_val_EPA(r,e,i,t)/sum(ee$ob(ee), ed0_10(r,ee,"fuel",i,"new","2010"));
display "before",oev_shr0;

parameter hdvbio_ewhl0(r,e,use,i)   Biofuel wholesale share in hdv
          hdvbio_ertl0(r,e,use,i)   Biofuel retail share in hdv
          hdvbio_emrg0(r,e,use,i)   Biofuel margin share in hdv ;

    te(r,bioe,"fuel",hdv) = te(r,bioe,"fuel","auto");
    hdvbio_ewhl0(r,bioe,"fuel",hdv)$(ertl0(r,bioe,"fuel","auto")) = 1;
    hdvbio_emrg0(r,bioe,"fuel",hdv)$(ertl0(r,bioe,"fuel","auto")) = emrg0(r,bioe,"fuel","auto")/ewhl0(r,bioe,"fuel","auto");

    hdvbio_ertl0(r,bioe,"fuel",hdv)$(ertl0(r,bioe,"fuel","auto")) =  (hdvbio_ewhl0(r,bioe,"fuel",hdv)+hdvbio_emrg0(r,bioe,"fuel",hdv))
                                                                    /(1-te(r,bioe,"fuel",hdv));
display hdvbio_ewhl0,hdvbio_emrg0, hdvbio_ertl0;

$ifthen setglobal aggtrn
    oev_val_EPA(r,e,i,t)           = sum(map_aggtrn(i,j), oev_val_EPA(r,e,j,t));
    oev_val_EPA(r,e,i,t)$deltrn(i) = 0;
    oev_shr0(r,e,i,v,t)$deltrn(i)  = 0;

    oev_shr0(r,e,i,v,t)$((ob(e) and not oil(e)) and aggtrn(i))
        = oev_val_EPA(r,e,i,t)/sum(ee$ob(ee), ed0(r,ee,"fuel",i,v));

    oev_shr0(r,e,i,v,t)$(oil(e) and aggtrn(i))
        = 1 - sum(ee$(ob(ee) and not oil(ee)), oev_shr0(r,ee,i,v,t));

    oev_val_EPA(r,e,i,t)$(oil(e) and aggtrn(i))
        =  oev_shr0(r,e,i,"new",t)* sum(ee$ob(ee), ed0(r,ee,"fuel",i,"new"));

    te(r,bioe,"fuel",i)$aggtrn(i) = te(r,bioe,"fuel","auto");
    hdvbio_ewhl0(r,bioe,"fuel",i)$(aggtrn(i) and ertl0(r,bioe,"fuel","auto"))
         = 1;
    hdvbio_emrg0(r,bioe,"fuel",i)$(aggtrn(i) and ertl0(r,bioe,"fuel","auto"))
         = emrg0(r,bioe,"fuel","auto")/ewhl0(r,bioe,"fuel","auto");

    hdvbio_ertl0(r,bioe,"fuel",i)$(aggtrn(i) and ertl0(r,bioe,"fuel","auto"))
         =  (hdvbio_ewhl0(r,bioe,"fuel",i)+hdvbio_emrg0(r,bioe,"fuel",i))
           /(1-te(r,bioe,"fuel",i));

    hdvbio_ewhl0(r,bioe,"fuel",hdv)= 0;
    hdvbio_emrg0(r,bioe,"fuel",hdv)= 0;
    hdvbio_ertl0(r,bioe,"fuel",hdv)= 0;
$endif

display "agg",oev_val_EPA;
display chk0_oevbtu, chk0_oevval,oev_shr0;

*Only biofuel and oil are assigned to beta0
    betat0(r,s,e,v,t)$(ob(e))                 = oev_val_EPA(r,e,s,t);
    betat0(r,s,"all",v,t)                     = sum(e$ob(e),betat0(r,s,e,v,t));

    beta0(r,s,e,v)$(ob(e))                    = betat0(r,s,e,v,"2010");
    beta(r,s,e,v)$(f_hdvbio(r,s) or auto(s))  = beta0(r,s,e,v);
    beta(r,s,e,v)$(f_hdvbio(r,s) or auto(s))  = betat0(r,s,e,v,"2010");

option autooev_shr0:5:2:1, betat0:6:4:1;
display autooev_shr0,betat0,beta0,beta;

* Provide summary for transportation cost
set item3     / Ele, Gas, Oil, Biof,  Eim,  Man, Srv, Tran, Other, Labor, Capital, Sum /
    item4(i)  /Eim,  Man, Srv/;

parameter tran_sumry,tran_sumry2,tran_sumry3;
    tran_sumry(r,afv,"Labor")        = afv_ldt0(r,afv,"new","2010")*(1+tl(r,afv))     ;
    tran_sumry(r,afv,g)              = afv_idt0(r,afv,g,"new","2010")*(1+ti(r,g,afv)) ;
    tran_sumry(r,afv,e)              = afv_edt0(r,afv,e,"new","2010") ;
    tran_sumry(r,afv,"Capital")      = sum(k,afv_kdt0(r,afv,k,"new","2010")*(1+tk(r,k,afv)))+afv_hkdt0(r,afv,"new","2010")*(1+thk(r,afv))  ;

    tran_sumry(r,OEV,"Labor")        = sum(mapoev(oev,i)$tran_cost0(r, i,"y0"),tran_cost0(r,i,"ld0")/tran_cost0(r, i,"y0"));
    tran_sumry(r,OEV,g)              = sum(mapoev(oev,i)$tran_cost0(r, i,"y0"),tran_cost0(r,i,g)/tran_cost0(r, i,"y0"));
    tran_sumry(r,OEV,e)              = sum(mapoev(oev,i)$tran_cost0(r, i,"y0"),tran_cost0(r,i,e)/tran_cost0(r, i,"y0"));
    tran_sumry(r,OEV,"Capital")      = sum(mapoev(oev,i)$tran_cost0(r, i,"y0"),(tran_cost0(r,i,"kd0")+tran_cost0(r,i,"hkd0"))/tran_cost0(r, i,"y0"));

    tran_sumry(r,i,"sum")            =  tran_sumry(r,i,"Labor")
                                      + sum(g, tran_sumry(r,i,g))
                                      + sum(e, tran_sumry(r,i,e))
                                      + tran_sumry(r,i,"Capital") ;

    tran_sumry(r,i,e)$(ob(e) and (autooev(i) or BioAutoAFV(i))) = oev_shr0(r,e,"auto","new","2010")*tran_sumry(r,i,"oil") ;
    tran_sumry(r,i,e)$(ob(e) and (rodfoev(i) or BioRodFAFV(i))) = oev_shr0(r,e,"rodf","new","2010")*tran_sumry(r,i,"oil") ;
    tran_sumry(r,i,e)$(ob(e) and (rodpoev(i) or BioRodPAFV(i))) = oev_shr0(r,e,"rodp","new","2010")*tran_sumry(r,i,"oil") ;

    tran_sumry2(r,afv,t)             = afv_pricT0(r,afv,"new",t);
    tran_sumry2(r,oev,t)             = sum(mapoev(oev,i),tran_cost0(r,i,"y0"));

    tran_sumry3(r,i,item3)   =  tran_sumry(r,i,item3) ;
    tran_sumry3(r,i,"Tran")  =  sum(g$trni(g),tran_sumry(r,i,g));
    tran_sumry3(r,i,"Other") =  sum(g$(not trni(g) and not item4(g)),tran_sumry(r,i,g));
    tran_sumry3(r,i,"Biof")  =  sum(e$(bio(e)),tran_sumry(r,i,e));
    tran_sumry3(r,i,item3)$tran_sumry(r,i,"sum")    = tran_sumry3(r,i,item3)/tran_sumry(r,i,"sum");
display mapoev,tran_sumry,tran_sumry2,afv_costT0;

parameter afv_costT1     AFV's cost in terms to $ per vmt;
         afv_costT1(r,i,t)= afv_costT0(r,i,"y0",t)*AFV_loadf0(r,i) ;
display afv_costT1,AFV_loadf0;

execute_unload 'data\dataout4tran.gdx', tran_sumry,tran_sumry2,tran_sumry3,oev_shr0,tran_cost0,afv_costT0,afv_costT1,afv_mpgeT0,chk0_kc,chk0_kct,chk0_afvt0;
*execute 'gdxxrw.exe data\dataout4tran.gdx    o=data\dataout4tran.xlsx  par=tran_sumry2      rng=cost!a3        cdim=1'
execute 'gdxxrw.exe data\dataout4tran.gdx    o=data\dataout4tran.xlsx  par=tran_sumry3       rng=inshare!a3     cdim=1'
*execute 'gdxxrw.exe data\dataout4tran.gdx    o=data\dataout4tran.xlsx  par=tran_cost0       rng=cost2!a3       cdim=1'
execute 'gdxxrw.exe data\dataout4tran.gdx    o=data\dataout4tran.xlsx  par=afv_costT0        rng=afvcost!a3     cdim=0'
execute 'gdxxrw.exe data\dataout4tran.gdx    o=data\dataout4tran.xlsx  par=afv_costT1        rng=afvcost_vmt!a2 cdim=0'
execute 'gdxxrw.exe data\dataout4tran.gdx    o=data\dataout4tran.xlsx  par=afv_mpgeT0        rng=afvmpgeT!a3    cdim=0'
*execute 'gdxxrw.exe data\dataout4tran.gdx    o=data\dataout4tran.xlsx  par=chk0_kc          rng=chk0_kc!a3     cdim=0'
*execute 'gdxxrw.exe data\dataout4tran.gdx    o=data\dataout4tran.xlsx  par=chk0_kct         rng=chk0_kct!a3    cdim=0'

*CCCC Update the Household Auto transportation consumption
* Reference: table 2 in "Vehicle Ownership and Income Growth Worldwide 1960-2030"
*       Author(s): Joyce Dargay, Dermot Gately and Martin Sommer
*       Source: The Energy Journal , 2007, Vol. 28, No. 4 (2007), pp. 143-170
*       Published by: International Association for Energy Economics
*       URL: https://www.jstor.org/stable/41323125
*       https://www.jstor.org/stable/pdf/41323125.pdf?refreqid=excelsior%3Ae32c60791df61943112882fdfb72b3e8

Scalar    SAII      Speed of adjustment - income increases  /0.095       /
          SAID      Speed of adjustment - income decreases  /0.084       /
          MaxSat    Maximium saturation level (USA)         / 852        /
          Popden    Population density                      / - 0.000388 /
          Urban     Urbanization                            / - 0.007765 /
          Alpha     Alpha                                   / -0.597     /
          GDPdeflat GDP deflator between 1995 and 2010 ;
* https://courses.lumenlearning.com/macroeconomics/chapter/converting-nominal-to-real-gdp/
   GDPdeflat = 110/81.7;

Table  Ecmt(r,*)   Econometric estimation on Beta and MaxSat
* EUR: average from Germany and France
* XLM: average from Argentina and Chile
* XAS: average from Japan, Kerea and India
* AFR: average from Egypt and South Africa
* ROW: average from Canada,Mexico and Austrilia
                              Beta              MaxSat
           USA               -0.20              852
           BRA               -0.17              831
           CHN               -0.14              807
           EUR               -0.165             776
           XLM               -0.15              805
           XAS               -0.21              687
           AFR               -0.18              838
           ROW               -0.17              823
 ;

Table  VehOwn(r,*)    Motor vehicle ownership in 2014  by Region
* TotalVeh: Total number of motor vehicle in million
* Pop: population in million
* VehOwnrate = TotalVeh /POP
* Motor vehicle data is from: http://www.nationmaster.com/country-info/stats/Transport/Road/Motor-vehicles-per-1000-people
* Number of private motor vehicles per 1000 people in 2014 by country. 'Motor vehicle' includes automobiles, SUVs, trucks, vans, buses, commercial vehicles and freight motor road vehicles. This data excludes motorcycles and other two-wheelers.
* GDP and population data is from IMF: world economic outlook database, 2020. accessed in 1-7-2021
* Those files are saved in D:\Model\ADAGE\CGE_Data_2011_tran\International\Tran_data\Motor vehicles per 1000 people by country in 2014.xlsx
                TotalVeh           POP            VehOwnrate
     AFR         39.4205        930.0240          0.04239
     BRA         50.2278        201.7180          0.24900
     CHN        113.5879       1368.5840          0.08300
     EUR        288.1691        536.9840          0.53664
     ROW        279.1284       1078.7730          0.25875
     USA        253.8724        318.5350          0.79700
     XAS        164.3700       1054.9000          0.15582
     XLM         99.7752        701.4180          0.14225
;

Parameter  GDPpercap(r,year)     GDP per capita in $1995 ($thousand)
           VehOwnrate(r,year)    The long-run equilibrium level of vehicle ownership annualy (vehicles per 1000 people)
           VehOwnship(r,t)       The long-run equilibrium level of vehicle ownership every five year (vehicles per 1000 people)
           TotVeh(r,t)           Total motor vehicle ownship (million);

* VehOwnship at t = SAII*MaxSat*e^(alpha*e^(beta*(GDP at t)))+(1-SAII)*VehOwnship at t-1

    GDPpercap(r,t)= gdp(r,t)/pop(r,t)/GDPdeflat;
loop(year$t(year),
    GDPpercap(r,year+1)= 4/5*GDPpercap(r,year)+ 1/5*GDPpercap(r,year+5);
    GDPpercap(r,year+2)= 3/5*GDPpercap(r,year)+ 2/5*GDPpercap(r,year+5);
    GDPpercap(r,year+3)= 2/5*GDPpercap(r,year)+ 3/5*GDPpercap(r,year+5);
    GDPpercap(r,year+4)= 1/5*GDPpercap(r,year)+ 4/5*GDPpercap(r,year+5););

    VehOwnrate(r,"2015") = SAII*ecmt(r,"MaxSat")*exp(Alpha*exp(ecmt(r,"beta")*GDPpercap(r,"2015")))+(1-SAII)* VehOwn(r,"VehOwnrate")*1000;
    VehOwnship(r,"2015") = SAII*ecmt(r,"MaxSat")*exp(Alpha*exp(ecmt(r,"beta")*GDPpercap(r,"2015")))+(1-SAII)* VehOwn(r,"VehOwnrate")*1000;

loop(year$(year.val>2015),
    VehOwnrate(r,year)   = SAII*ecmt(r,"MaxSat")*exp(Alpha*exp(ecmt(r,"beta")*GDPpercap(r,year)))+(1-SAII)* VehOwnrate(r,year-1);  );
    VehOwnrate(r,year)$(not t(year))= 0;
    VehOwnrate(r,"2010") =  VehOwnrate(r,"2015")* VehOwnrate(r,"2015")
                          / VehOwnrate(r,"2020");
loop(t$(t.val>2015),
    VehOwnship(r,t)  = SAII*ecmt(r,"MaxSat")*exp(Alpha*exp(ecmt(r,"beta")*GDPpercap(r,t)))+(1-SAII)* VehOwnship(r,t-1);  );

*    VehOwnship(r,t)     = VehOwnrate(r,t);
    VehOwnship(r,"2010") =  VehOwnship(r,"2015")* VehOwnship(r,"2015")
                          / VehOwnship(r,"2020");

    TotVeh(r,t) = VehOwnship(r,t)*pop(r,t)/1000;
display GDPpercap,VehOwnrate, VehOwnship,TotVeh;



*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                           Specify Scenario Analysis
* Oil Price analysis
$if setglobal pcru  $include .\analysis\pcru\analysis_oilprice.gms
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC




*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                                Report parameters
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
set   lp                    Flag to control number of runs to match the biofuel share
$ifthen  setglobal  shock
      /1*8/ ;
$else
      /1*1/ ;
$endif


parameter
      modelstats            Model status
      solvestats            Sover status       ;


*  In conventional onroad transportation and advanced AFV, if oil usage (gasv, HEV) is expanded to oil-biofuel mix then the following notes are useful to interpret ed0_
*    ed0_.l for auto, rodf and rodP for oil and biofuel are sum of consumption from conventional and AFV
*    ed0_.l for auto, rodf and rodP for ele, gas are reported separately by conventional and AFV (auto, rodf, rodp are actually auto_oev, rodf_oev, rodP_oev)
*     use an example to illustrate as below : ED0_.L
*                                                     LEVEL           Notes
*         ex: USA.Oil .fuel.Auto     .Extant          20.0            auto_oev
*             USA.Oil .fuel.Auto     .New             50.0            auto_oev + auto_gasv + auto_hev
*             USA.Ceth.fuel.Auto     .Extant          8.0             auto_oev
*             USA.Ceth.fuel.Auto     .New             4.0             auto_oev + auto_gasv + auto_hev

*             USA.Gas .fuel.Auto     .New             5.0             auto_oev
*             USA.Gas .fuel.Auto_GasV.New             0.1             auto_GasV
*             USA.Gas .fuel.Auto_BEV .New             0.2             Auto_BEV
*             USA.Gas .fuel.Auto_HEV .New             0.3             Auto_HEV
*             USA.Gas .fuel.Auto_FCEV.New             0.5             Auto_FCEV
* Some parameters are added and reporting need to be modified to account for the expansion as below:

parameter
* Save ed0_.l to ed and distribute total onroad transportation oil-biofuel energy mix in oev, gasv ahd hev to its own technology
        eds(r,j,use,*,v,t)           Energy Demand by sector by vintage ($2010 billion)
        ed(r,j,use,*,t)              Energy Demand by sector ($2010 billion)
        obmixv(r,use,i,v,t)          Total energy (oil-biofuel) in onroad transportation by vintage(OEV & GASV & HEV where oil usage is expanded to oil-biofuel mix) ($2010 billion)
        obmix(r,use,i,t)             Total energy (oil-biofuel) in onroad transportation (OEV & GASV & HEV where oil usage is expanded to oil-biofuel mix) ($2010 billion)
        obmixv_shr(r,use,i,j,v,t)    Share of energy (oil-biofuel) in onroad transportation by technology by vintage(%)
        obmix_shr(r,use,i,j,t)       Share of energy (oil-biofuel) in onroad transportation by technology (%)
        obmix_shr1(r,use,i,j,v,t)    Share of energy (oil-biofuel) in onroad transportation by technology (%) ;

set     macrovar /GDP,CONS,INVEST,GOVT,EXPORTS,IMPORTS/;

parameter
        macro                  Macro outputs including GDP & consumption & investment and others ($billion)
        gdp_comp               GDP component by resource ($billion)
        gdp_shr                GDP share by resource using income approach
        gdp_                   Total GDP ($billion)
        gdp_sec                Sectoral gdp calculated from production side ($billion)
        gdp_sec2               Sectoral gdp calculated from resource side ($billion)

        output                 Sectoral production ($billion)
        cons                   Household consumption ($billion)
        cons_p                 Consumer goods price index
        cons_all               Total consumption (armington goods) ($billion)
        cons_allp              Armington goods price index
        cons_alls              Armington goods consumption by sectors ($billion)
        cons_tonn              AG and food Household consumption (million metric ton)
        cons_all_tonn          AG and food armington goods consumption (million metric ton)
        cons_alls_tonn         Ag and food armington goods consumption by sectors (million metric ton)
        cons_alls_tonn_temp    Temporary calculation for soybean consumption by sectors (million metric ton)

        prices                 Price index of sectoral output
        price                  Price index of sectoral output and intermediate goods
        prices_pc              Price index of sectoral output (adjusted by price of consumption)
        prices_kt              Price of capital by vintage
        prices_kt_pc           Price of capital by vintage (adjusted by price of consumption)
        prices_fuel            Price of fuel in transportation ($ per mmtu)
        prices_fuel_pc         Price of fuel in transportation ($ per mmtu) (adjusted by price of consumption)
        prices_en              prices of energy by sector ($ per mmbtu)

        agbio_macro            Production & consumption & import and export for crop and biofuel ($billion)

        en_valu                Energy demand by sectors ($billion)
        en_valus               Energy demand by sectors and use type ($billion)
        en_btusv               Energy demand by sectors & generation type & vintage (quad btu)
        en_btus                Energy demand by sectors & generation type (quad btu)
        en_btu                 Energy demand by sectors (quad btu)

* Another method to calculate the energy consumption (retail)
        en_valu1               Energy demand by sectors ($billion)
        en_valus1              Energy demand by sectors and use type ($billion)
        en_btu1                Energy demand by sectors (quad btu)

        enprod_valu            Energy production ($billion)
        enprod_btu             Energy production (quad btu)

        entrd_valu             Energy trade ($billion)
        entrd_btu              Energy trade (quad btu)
        entrd_gal              Energy trade (billion gallons)

        ele_cons_all           Total electricity consumption (from armington goods) (quad btu)
        ele_valu               Electricity generation by technology ($billion)
        ele_btu                Electricity generation by technology (quad btu)
        elesource              Electricity generation by energy source (quad btu)
        ele_valuV              Electricity generation by technology and vintage ($billion)
        ele_btuV               Electricity generation by technology and vintage (quad btu)
        ele_btubyAge           Electricity generation by technology and by age (quad btu)
        ele_btuShrV            Share of electricity generation by vintage for the next period
        ele_ketByAge           Electricity generation capital endowment by vintage over the time ($billion)

        auto_valu              Energy demand by household auto ($billion)
        auto_shr               Share of biofuel in total household auto energy demand according to dollar value(%)
        auto_btu               Energy demand by household auto (quad btu)
        auto_gal               Energy demand by household auto (billion gallons)
        auto_pric              Price index of auto energy
        auto_pric_pc           Price index of auto energy (adjusted by price of consumption)
        auto_trdgal            Trade for energy and biofuels in household auto industry (billion gallons)

        OEV_valu               Energy demand by OEV ($billion)
        OEV_shr                Share of biofuels in OEV in terms to dollar value (%)
        OEV_shr_btu            Share of biofuels in OEV in terms to quad btu (%)
        OEV_btu                Energy demand by OEV (quad btu)
        OEV_gal                Energy demand by OEV (billion gallons)
        OEV_pric               Price index of OEV
        OEV_pric_pc            Price index of OEV (adjusted by price of consumption)

        tran_vmt               Transportation VMT traveled (billion vehicle-mile-traveled)
        tran_valu              Transportation production by sector ($billion)
        tran_prod              Transportation production by sector (billion passenger-mile-traveled for passenger transportation and billion-ton-mile traveled for freight)
        tran_enbtu             Transportation energy consumption (quad btu)
        tran_emis              Transportation ghg emission (mmt co2eq)
        tran_mpge              Transportation fuel economy (mile per gallon)
        tran_envalu            Transportation energy consumption ($billion)

        tran_vmtV              Transportation VMT traveled by vintage (billion mile-vehicle-traveled)
        tran_vmtbyage          Transportation VMT traveled by vintage for the next 30 years (billion mile-vehicle-traveled)
        tran_vmtshrV           Share of Transportation VMT traveled by vintage for the next period
        tran_surratio          Transportation VMT ratio between simulated and expected for extant vehicle (<1 means earlier scrappge than MOVEsa and >1 means late scrappage)
        tran_ketbyage          Transportation capital endowment by vintage over the time ($billion)
        tran_valuv             Transportation production by sector by vintage ($billion)
        tran_enbtuV            Transportation energy consumption by vintage(quad btu)
        tran_mpgeV             Transportation fuel economy by vintage (mile per gallon)
        usa_auto_stockV        Stock in USA auto sector by vintage (million)

        trade                  Import and export by sector ($billion)
        bi_trade               Export from one region to another region by sector ($billion)

        land_valu              Land demand by sector ($billion)
        land_area              Land area for different land types such as crop & livestock & forest & cellulosic biofuel (million ha)
        land_area0             Land area for different land types such as crop & livestock & forest & cellulosic biofuel (million ha)
        land_area1             Land area for different land types such as crop & livestock & forest & cellulosic biofuel (million ha)
        land_rent              land rent index
        land_tran              Land transformation from one type to another (million ha)
        land_em                Co2 emission from land use change (million metric ton co2eq)
        land_seq               Co2 sequestration from land use change (mmt CO2eq)
        chk_lndem              Check land use change in area & emission and sequestration
        emis_rep               Land conversion report (area(m ha) & emission and sequestration (mmt co2eq)

        co2t_ff                Co2 emissions by fuels type and by sector (mmt co2eq)
        co2tot_ff              Co2 emissions by fuel type (mmt co2eq)
        co2tott_ff             Total fossil fuel related co2 emissions by each country (mmt co2eq)
        co2elet                co2 emission from electricity generation (mmt CO2eq)

        co2t_lnd               Co2 emissions from land use change (mmt co2eq)
        co2tot_lnd             Co2 emissions from land use change (mmt co2eq)
        co2tott_lnd            Total Co2 emissions from land use change (mmt co2eq)

        ghgt                   GHG emission by sector and ghg excluding CO2 emissions from fossil fuel and land use change (mmt co2eq)
        ghgtot(*,ghg,t)        Total GHG emissions by type excluding CO2 emissions from fossil fuel and land use change (mmt co2eq)
        ghgtott(*,t)           Total GHG emissions excluding CO2 emissions from fossil fuel and land use change (mmt co2eq)

        carbemis               Total GHG emissions by source in each period (mmt co2eq)
        carbemist              Accumulated GHG emissions by source from 2010 to the current period (mmt co2eq)
        carbemis2              Total GHG emissions by anoterh set of source in each period (mmt co2eq)

        pco2t                  Price of co2 emission ($ per metric ton)
        pghgt                  Price of ghg emission ($ per metric ton)

        apt(r,ap,i,t)          Air pollutant emission by sector and pollutant (thousand metric ton)
        aptot(r,ap,t)          Air pollutant emission by pollutant (thousand metric ton)

        ag_tonn                AG production (million ton)
        ag_valu                AG production ($billion)
        ag_pric                AG price ($1000 per metric ton)
        ag_lndh                AG land area (million ha)
        ag_lndv                AG land area ($billion)

        ag_tonn_trad           AG trade (million metric tons)
        ag_tonn_cons           AG armington consumption (mmt)
        ag_pric_cons           Ag consumption price ($thousand  per ton)

        yield                  AG yield (ton per ha)
        yield_growth           AG yield growth trend (1 in 2010)
        ag_tonn_growth         AG production growth trend (1 in 2010)
        output_growth          Sectoral production growth trend (1 in 2010)
        vmt_growth             Auto VMT growth trend (1 in 2010)

        chk_ag_tonn            Check ag supply-demand balance (mmt)

        chk_gdp                Check gdp growth trend to see if it matches the exogenous trend
        chk_macro              Check sectoral balance on production & consumption & import & export ($billion)
        chk_shr                Check sectoral input share balance
        chk_shrt               Check the sum of sectoral input share to see if it's equal to 1
        chk_area               Check land area (mha)

        chk_py                 Check sectoral production price
        chk_pc                 Check consumption price
        chk_ped                Check energy price in sectoral demand
        chk_plnd               Check land price
        chk_pl                 Check labor price
        chk_phk                Check human capital price
        chk_pk                 Check capital price
        chk_prk                Check capital price for vintage
        chk_srv(r,*,*)         Check service sector

        chk_enbalt             Check energy supply & demand balance (quad btu)
        chk_enprod             Check energy production at each period
        chk_encons             Check energy consumption at each period
        chk_elegen             Check electricity generation by source at each period
        chk_gencost            Check electricity generation Cost by source at each period
        chk_enrpric            Check energy retail price at each period
        chk_enwpric            Check energy whole sale price at each iteration

        chk_envalu             Check energy consumption by sector and type ($billion)
        chk_enbtu              Check energy consumption by sector and type (quad btu)
        chk_eds                Check energy consumption by sector and type ($billion)

        chk0_enprod            Check energy production at each iteration (quad btu)
        chk0_encons            Check energy consumption at each iteration (quad btu)
        chk0_elegen            Check electricity generation by source at each iteration (quad btu)
        chk0_enrpric           Check energy retail price at each iteration
        chk0_enwpric           Check energy whole sale price at each iteration

        chk_autoOil            Check auto sector oil consumption (billion gallons)
        chk_autogalshr         Check auto fuel share by fuel type

        chk_gal                Check if biofuels in final runs match the target (billion gallon)
        chk_gal0               Check if biofuel projection approaches the target in each iteration (billion gallon)
        chk_afvt               Check onroad OEV and afv's input and output
        chk_mpg                Check onroad OEV and afv's mpge (mile per gallon of oil equivalent)
        chk_mpge               Check onroad mpge to see if they meet the fuel economy target (mile per gallon of oil equivalent)

        chk_afvtV
        chk_afvtP
        chk_afvtQ
        chk_afvtall            AFV's input cost seperated by price (P) quanty (Q) value (V =P*Q) ($ per vmt)
;


* Assign initial value of tran_vmtV for reporting purposes which will be updated in the model
      ele_valuv(r,gentype,v,"2010") = y0(r,gentype,v) ;

      tran_vmtv(r,oev,"extant","2010") = sum(mapoev(oev,trnv),clay(r,trnv)*tran_vmt0(r,trnv));
      tran_vmtv(r,oev,"new","2010")    = sum(mapoev(oev,trnv),(1-clay(r,trnv))*tran_vmt0(r,trnv));

      tran_valuv(r,afv,v,"2010") =0;

      tran_mpgev(r,oev,"extant","2010") = sum(mapoev(oev,trnv), old_mpgeT(r,trnv,"2010"));
      tran_mpgev(r,oev,"new","2010")    = sum(mapoev(oev,trnv), new_mpgeT(r,trnv,"2010"));

    ele_btushrV(r,advee,"extant",tt,t)$(ord(t)=1 and tt.val<=t.val-1 and tt.val>=t.val-6) = 0 ;
    ele_btushrV(r,i,"his","2010",t)$(t.val<=2010) = 1 ;

Set  item1  /y0,mpge0, ld0,id0,kd0,hkd0,ob0,ff0/;
     item1(e)=yes;

execute_unload '.\data\dataout4merge.gdx' pop, whlprc0,  prc0,price0, bio_convert,bio_convert_trd,bio_yield0, bio_yldtrd,swge_new,    btu_conv,  gal_conv, btu_gal, btuprod_conv, btuim_conv,btuex_conv,btuen_conv
                                          p_land0,  ag_pric0,  tx, tm,  tc, ty ,advbiomkupt ;


execute_unload  '.\lst\ATB_chk.gdx',heateff,elegen0_10,chk0_eleprod,ed0_10,ertl0_10,ewhl0_10,etax0_10,btu0_10,prod0_10,ATB20_elecost,y0_10,elegen_yt0,elegen_edt0,elegen_idt0,elegen_kdt0,elegen_rnwdt0,rnw0_10,rnw0,
                                    btu_conv,btuprod_conv;





