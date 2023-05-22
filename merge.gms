*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                        Combine Results From Different Scenarios
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
$onUNDF
$setglobal doc                 ! for model documentation run
*$setglobal pcru               ! Crude oil price analysis

$ifthen setglobal
$setglobal  base1       Doc_Ref
$setglobal  in1         '.\output\DA\Doc'
$setglobal  out         '.\output\DA\Doc'
$call gdxmerge          %in1%\%base1%.gdx
$endif

$ifthen setglobal pcru
$setglobal base1        DA_REF
$setglobal scn1_1       DA_HOP
$setglobal scn1_2       DA_LOP

$setglobal base2        DN_REF
$setglobal scn2_1       DN_HOP
$setglobal scn2_2       DN_LOP

$setglobal base3        AN_REF
$setglobal scn3_1       AN_HOP
$setglobal scn3_2       AN_LOP

$setglobal  vsn         All
$setglobal  in1         '.\output\DA'
$setglobal  in2         '.\output\DN'
$setglobal  in3         '.\output\AN'
$setglobal  out         .\output\%vsn%

$call gdxmerge        %in1%\%base1%.gdx  %in1%\%scn1_1%.gdx  %in1%\%scn1_2%.gdx   %in2%\%base2%.gdx  %in2%\%scn2_1%.gdx  %in2%\%scn2_2%.gdx  %in3%\%base3%.gdx  %in3%\%scn3_1%.gdx  %in3%\%scn3_2%.gdx
$endif


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                     Default reporting program
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
$include set.gms

set macrovar       macro variable
       /GDP,CONS,INVEST,GOVT,EXPORTS,IMPORTS/
    trdvar         trade related variable
       /EXPORT,IMPORT,Nettrd/

    merged_set_1   names of gdx files ;

alias   (i,j), (s,g), (g,gg), (agr,agrs), (r,rr), (e,f), (hh,hhh), (k,kk), (cgo,cgoe), (lu,lu_), (agri, agrii), (crp,crp0),(ad,ad0);


table    ag_pric0(r,i)      Producer price for ag related goods ($1000 per ton)
             Ddgs        Omel         Wht        Corn        Gron        Soyb        Osdn        Srcn        Srbt         Ocr         Liv         Frs         Mea         Vol
USA         0.112       0.106       0.280       0.147       0.152       0.360       0.433       0.031       0.051       0.865       1.238       0.712       2.667       3.935
BRA                     0.023       0.275       0.215       0.089       0.388       1.967       0.017                   0.293       1.036       0.551       1.927       4.437
CHN         0.112       0.013       0.111       0.062       0.076       0.243       0.072       0.015       0.008       0.234       1.832       1.264       3.119       2.070
EUR                     0.048       0.258       0.237       0.199       0.468       0.516       0.162       0.051       0.973       1.556       0.640       3.143       2.665
XLM                     0.021       0.513       0.482       0.375       0.270       0.561       0.020       0.143       0.649       1.454       0.560       2.524       2.968
XAS                     0.036       0.300       0.204       0.257       0.436       0.169       0.037       0.139       0.397       1.428       0.674       2.590       2.455
AFR                     0.026       0.831       0.299       0.453       0.335       0.148       0.046       0.077       0.287       1.836       0.569       3.405       2.206
ROW         0.112       0.069       0.211       0.300       0.330       0.391       0.344       0.045       0.039       0.573       2.062       0.643       5.020       4.702
;

display ag_pric0;

parameter
        chk_gdp
        modelstats             Model status
        luc                    Flag for land use change
        macro                  Macro outputs including GDP & consumption & investment and others ($billion)
        gdp_comp               GDP component ($billion)
        gdp_                   Total GDP  ($billion)
        gdp_sec                Sectoral gdp calculated from production side ($billion)
        gdp_sec2               Sectoral gdp calculated from resource side ($billion)
        output                 Agriculture & biofuel and energy output ($billion)

        prices                 Price index of sectoral output
        prices_pc              Price index of sectoral output (adjusted by price of consumption)
        price                  Price index of sectoral output
        prices_kt              Price of capital by vintage
        prices_kt_pc           Price of capital by vintage (adjusted by price of consumption)
        prices_fuel            Price of fuel in transportation ($ per per mmtu)
        prices_fuel_pc         Price of fuel in transportation ($ per per mmtu) (adjusted by price of consumption)

        cons                   Household consumption ($billion)
        cons_p                 Consumer goods price index

        cons_all               Armington goods consumption ($billion)
        cons_allp              Armington goods price index
        cons_alls              Armington goods consumption by sectors ($billion)

        agbio_macro            Physical production & consumption & import and export for crop and biofuel

        en_valu                Energy demand by sectors ($billion)
        en_valus               Energy demand by sectors and use type ($billion)
        en_btusv               Energy demand by sectors & generation type & vintage (quad btu)
        en_btus                Energy demand by sectors & generation type & capital (quad btu)
        en_btu                 Energy demand by sectors (quad btu)

* Another method to calculate energy consumption (retail)
        en_valu1               Energy demand by sectors ($billion)
        en_valus1              Energy demand by sectors and use type ($billion)
        en_btu1                Energy demand by sectors (quad btu)

        enprod_valu            Energy production ($billion)
        enprod_btu             Energy production (quad btu)

        entrd_valu             Enegy trade ($billion)
        entrd_btu              Energy trade (quad btu)
        entrd_gal              EnergyTrade (billion gallons)

        ele_valu               Electricity demand or production by generation ($billion)
        ele_btu                Electricity demand or production by generation (quad btu)
        elesource              Electricity generation by source (quad btu)

        auto_valu              Energy demand by household auto ( $billion)
        auto_shr               Share of biofuel in total household auto energy demand according to dollar value(%)
        auto_btu               Energy demand by household auto (quad btu)
        auto_gal               Energy demand by household auto (billion gallons)
        auto_pric              Price index of auto energy
        auto_pric_pc           Price index of auto energy (adjusted by price of consumption)
        auto_trdgal            Trade for energy and biofuels in household auto industry (billion gallons)

        OEV_valu               Energy demand by OEV ( $billion)
        OEV_shr                Share of biofuel in OEV according to dollar value(%)
        OEV_shr_btu            Share of biofuels in OEV in terms to quad btu (%)
        OEV_btu                Energy demand by OEV (quad btu)
        OEV_gal                Energy demand by OEV (billion gallons)
        OEV_pric               Price index of OEV
        OEV_pric_pc            Price index of OEV (adjusted by price of consumption)

        tran_vmt               Transportation VMT traveled (billion mile-vehicle-traveled)
        tran_valu              Transportation production ($billion)
        tran_prod              Transportation production (billion passenger-mile-traveled for passenger transportation and billion-ton-mile traveled for freight)
        tran_prod_pmt          Transportation production for passenger transportation(billion passenger-mile-traveled for passenger transportation and billion-ton-mile traveled for freight)
        tran_prod_tmt          Transportation production for freight transportation (billion-ton-mile traveled for freight)
        tran_enbtu             Transportation energy consumption (quad btu)
        tran_emis              Transportation ghg emission (mmt co2eq)
        tran_mpge              Transportation fuel economy (miles per gallon of gassoline equivalent)
        tran_envalu            Transportation energy consumption ($)

        tran_vmtV              Transportation VMT traveled by vintage(billion mile-vehicle-traveled)
        tran_enbtuV            Transportation energy consumption by vintage (quad btu)
        tran_mpgeV             Transportation fuel economy by vintage (miles per gallon of gasoline equivalent)
        tran_surratio          Transportation VMT ratio between simulated and expected for extant vehicle (<1 means earlier scrappge than MOVEsa and >1 means late scrappage)
        usa_auto_stockV        Stock in USA auto sector by vintage (million)

        trade                  Agriculture & biofuel import and export ($billion)
        bi_trade               Export from one region to another region ($billion)

        land_valu              Land demand by sector ($billion)
        land_area              Land area for different land types  such as crop & livestock & forest & cellulosic biofuel(million ha)
        Land_areaOthr          Land area for other (mha) in 2010  using TEM data
        land_rent              Land rent index
        land_tran              Land transformation from one type to another (million ha)
        land_em                CO2 emission from land use change (million metric ton co2)
        land_seq               CO2 sequestration from land use change (million metric ton co2)
        emis_rep               Land conversion report (area(m ha) & emission and sequestration (million metric ton co2)

        co2t_ff                Co2 emissions by fuels type and by sector (mmt co2eq)
        co2tot_ff              Carbon emission by fossil fuel (million metric ton co2)
        co2tott_ff             Total Carbon emission from all fossil fuel (million metric ton co2)
        co2elet                CO2 emissions from electricity generation

        ghgt                   GHG emissions by sector and ghg (mmt co2eq)
        ghgtot                 Total GHG emissions by type (mmt co2eq)
        ghgtott                Total GHG emissions from excluding fossil fuel co2 emission (mmt co2eq)

        carbemis               Total GHG emissions in each period (mmt co2eq)
        carbemist              Accumulated GHG emissions from 2010 to the current period (mmt co2eq)
        ctaxt                  Carbon tax ($ per ton of CO2eq)

        apt                    Air pollutant emissions by sector and pollutant (thousand metric ton)
        aptot                  Air pollutant emissions by pollutant (thousand metric ton)

        ag_tonn                Crop production (million tonne)
        ag_valu                Value of Crop production ($billion)
        ag_pric                Crop price ($1000 per tonne)
        ag_lndh                Crop area  (mha)
        ag_lndv                Crop area by value ($billion)

        ag_tonn_trad           Ag trade in million metric tons
        ag_tonn_cons           Ag Armington consumption in million metric tons
        ag_pric_cons           Ag consumption price ($thousand  per ton)
        chk_ag_tonn            Check ag supply-demand balance

        cons_tonn              AG and food Household consumption (million metric ton)
        cons_all_tonn          AG and food Armington goods consumption (million metric ton)
        cons_alls_tonn         Ag and food Armington goods consumption by sectors (million metric ton)

        chk_macro              Check sectoral balance on production & consumption & import & export ($ billion)
        chk_shr                Check sectoral input share balance
        chk_gal                Check gallon of biofuel
        chk_afvt               Check on-road OEV and afv's input and output
        chk_afvtV,chk_afvtP,chk_afvtQ, chk_afvtall
 ;


* Load merged file
$gdxin merged.gdx
$load  merged_set_1
$load  chk_gdp        =   chk_gdp
$load  modelstats     =   modelstats
$load  macro          =   macro
$load  gdp_comp       =   gdp_comp
$load  gdp_           =   gdp_
$load  gdp_sec        =   gdp_sec
$load  gdp_sec2       =   gdp_sec2
$load  output         =   output

$load  prices         =   prices
$load  prices_pc      =   prices_pc
$load  price          =   price
$load  prices_kt      =   prices_kt
$load  prices_kt_pc   =   prices_kt_pc
$load  prices_fuel    =   prices_fuel
$load  prices_fuel_pc =   prices_fuel_pc


$load  cons           =   cons
$load  cons_P         =   cons_p
$load  cons_all       =   cons_all
$load  cons_allP      =   cons_allp
$load  cons_alls      =   cons_alls
$load  cons_tonn      =   cons_tonn
$load  cons_all_tonn  =   cons_all_tonn
$load  cons_alls_tonn =   cons_alls_tonn

$load  agbio_macro    =   agbio_macro

$load  en_valu        =   en_valu
$load  en_valus       =   en_valus
$load  en_btus        =   en_btus
$load  en_btusV       =   en_btusV
$load  en_btu         =   en_btu

$load  enprod_valu    =   enprod_valu
$load  enprod_btu     =   enprod_btu

$load  entrd_valu     =   entrd_valu
$load  entrd_btu      =   entrd_btu
$load  entrd_gal      =   entrd_gal

$load  ele_valu       =   ele_valu
$load  ele_btu        =   ele_btu
$load  elesource      =   elesource
$load  auto_valu      =   auto_valu
$load  auto_shr       =   auto_shr
$load  auto_btu       =   auto_btu
$load  auto_gal       =   auto_gal
$load  auto_pric      =   auto_pric
$load  auto_pric_pc   =   auto_pric_pc

$load  OEV_valu       =   OEV_valu
$load  OEV_shr        =   OEV_shr
$load  OEV_shr_btu    =   OEV_shr_btu
$load  OEV_btu        =   OEV_btu
$load  OEV_gal        =   OEV_gal
$load  OEV_pric       =   OEV_pric
$load  OEV_pric_pc    =   OEV_pric_pc


$load  trade          =   trade
$load  bi_trade       =   bi_trade

$load  land_valu      =   land_valu
$load  land_area      =   land_area
$load  land_areaothr  =   q_lndothr0
$load  land_rent      =   land_rent
$load  land_tran      =   land_tran
$load  land_em        =   land_em
$load  land_seq       =   land_seq
$load  emis_rep       =   emis_rep
$load  co2t_ff        =   co2t_ff
$load  co2tot_ff      =   co2tot_ff
$load  co2tott_ff     =   co2tott_ff
$load  ghgt           =   ghgt
$load  ghgtot         =   ghgtot
$load  ghgtott        =   ghgtott
$load  carbemis       =   carbemis
$load  carbemist      =   carbemist
$load  apt            =   apt
$load  aptot          =   aptot

$load  ag_tonn        =   ag_tonn
$load  ag_valu        =   ag_valu
$load  ag_pric        =   ag_pric
$load  ag_lndh        =   ag_lndh
$load  ag_lndv        =   ag_lndv

$load  chk_macro      =   chk_macro
$load  chk_shr        =   chk_shr
$load  ctaxt          =   ctaxt

$load  tran_vmt       =  tran_vmt
$load  tran_valu      =  tran_valu
$load  tran_prod      =  tran_prod
$load  tran_enbtu     =  tran_enbtu
$load  tran_emis      =  tran_emis
$load  tran_mpge      =  tran_mpge
$load  tran_vmtV      =  tran_vmtV
$load  tran_enbtuV    =  tran_enbtuV
$load  tran_mpgeV     =  tran_mpgeV
$load  tran_surratio  =  tran_surratio
$load  usa_auto_stockV=  usa_auto_stockV

$load  co2elet        =  co2elet
$load  ag_tonn_trad   =  ag_tonn_trad
$load  ag_tonn_cons   =  ag_tonn_cons
$load  ag_pric_cons   =  ag_pric_cons
$load  chk_gal        =  chk_gal
$load  chk_afvt       =  chk_afvt
$load  chk_afvtV      =  chk_afvtV
$load  chk_afvtP      =  chk_afvtP
$load  chk_afvtQ      =  chk_afvtQ
$load  chk_afvtall    =  chk_afvtall
$gdxin
;

land_areaothr(merged_set_1,"Total")=sum(r,land_areaothr(merged_set_1,r));

set     tranPP(i)        "passenger transportation"
           /AirP,       Auto,     RalP,    RodP
            Auto_OEV  , RodP_OEV
            Auto_gasV , RodP_GasV
            Auto_BEV  , RodP_BEV
            Auto_HEV  , RodP_HEV
            Auto_FCEV , RodP_FCEV   /
        tranOP(i)        "non passenger transportation"
           /WtrT,       RalF,    RodF,    Otrn
            RodF_OEV
            RodF_GasV
            RodF_BEV
            RodF_HEV
            RodF_FCEV   /;

    tran_prod_pmt(merged_set_1,r,i,t)$tranPP(i) = tran_prod(merged_set_1,r,i,t)  ;
    tran_prod_tmt(merged_set_1,r,i,t)$tranOP(i) = tran_prod(merged_set_1,r,i,t)  ;
display gdp_,land_areaothr,co2elet,tran_prod_pmt,tran_prod_tmt,prices_kt_pc;

option modelstats:1:1:2;
display merged_set_1,ag_tonn,ag_tonn_cons,ag_pric_cons,modelstats,tran_mpge;

* Normalize the price trend where 2010 is 1.
    price(merged_set_1,r,i,"py_pc",t) $price(merged_set_1,r,i,"py_pc","2010") = price(merged_set_1,r,i,"py_pc",t)  /price(merged_set_1,r,i,"py_pc","2010")  ;
    price(merged_set_1,r,i,"pa_pc",t) $price(merged_set_1,r,i,"pa_pc","2010") = price(merged_set_1,r,i,"pa_pc",t)  /price(merged_set_1,r,i,"pa_pc","2010")  ;
    price(merged_set_1,r,i,"ped_pc",t)$price(merged_set_1,r,i,"ped_pc","2010")= price(merged_set_1,r,i,"ped_pc",t) /price(merged_set_1,r,i,"ped_pc","2010") ;
    cons_p(merged_set_1,r,i,t)        $cons_p(merged_set_1,r,i,"2010")        = cons_p(merged_set_1,r,i,t)         /cons_p(merged_set_1,r,i,"2010")         ;
    cons_allp(merged_set_1,r,i,t)     $cons_allp(merged_set_1,r,i,"2010")     = cons_allp(merged_set_1,r,i,t)      /cons_allp(merged_set_1,r,i,"2010")      ;
    auto_pric(merged_set_1,r,e,t)     $auto_pric(merged_set_1,r,e,"2010")     = auto_pric(merged_set_1,r,e,t)      /auto_pric(merged_set_1,r,e,"2010")      ;
    auto_pric_pc(merged_set_1,r,e,t)  $auto_pric_pc(merged_set_1,r,e,"2010")  = auto_pric_pc(merged_set_1,r,e,t)   /auto_pric_pc(merged_set_1,r,e,"2010")   ;

    auto_pric(merged_set_1,"total",e,t)     $auto_pric(merged_set_1,"total",e,"2010")     = auto_pric(merged_set_1,"total",e,t)      /auto_pric(merged_set_1,"total",e,"2010")      ;
    auto_pric_pc(merged_set_1,"total",e,t)  $auto_pric_pc(merged_set_1,"total",e,"2010")  = auto_pric_pc(merged_set_1,"total",e,t)   /auto_pric_pc(merged_set_1,"total",e,"2010")   ;

parameter
        tran_mpgeAFV           Transportation fuel economy for AFV (mile per gallon of gasoline equivalent)
        USA_auto_stock         Total vehicle stock in USA auto sector (million);

    usa_auto_stock(merged_set_1,trn,t) = usa_auto_stockV(merged_set_1,trn,"Total",t);
    tran_mpgeAFV(merged_set_1,r,afv,t) = tran_mpgev(merged_set_1,r,afv,"new",t);

