*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                                   Readme
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
* This is to do runs during 2010~2050 for analysis
* one sample command to run the model is:
*     mkdir  .\lst\DA   .\output\DA
*     gams data.gms    s=.\lst\DA\a1
*     gams model.gms   r=.\lst\DA\a1 s=.\lst\DA\a2
*     gams loop.gms    --scn=ref --nt=9  r=.\lst\DA\a2   s=.\lst\DA\ref50   gdx=.\output\DA\DA_REF
*  Where:  scn: scenario to run
*          nt:  number of time periods to run (1-9; 2010-2050)
*               In case only one period is run in debugging procedure, then use runbyyear.gams as the reference file

$Title    ADAGE Model - Loop


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                            Environmental variables
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
* If running more than one time period, activate below; If not, turn it off and use runbyyear.gms as a reference command
$setglobal moreT

* Specify the approach for fixed factor endowment assumption for onroad AFVs. Only one needs to be activated.
* FFown: fixed factor endowment is equal to the level in previous period. It is default case
* FFaeo: fixed factor endowment is equal to the level in AEO2019 projections
* FF0:   no fixed factor endowment is assumed, so the penetration of AFVs depends on its pure cost and competition among others
$setglobal FFown


* Default flags
    f_afv(r,afv,"new")   = 0 ;
    f_hdvbio(r,hdv)      = 0 ;
    f_afvbio(r,afv)      = 0 ;
    advswtch(r,i,v)      = no;


**CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                                 Loop Runs
**CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
$ifthen setglobal moreT
   loop(t$(ord(t)<=%nt%),
$else
   loop(t$(ord(t)=%nt%),
$endif

**CCCCCCCCCCCCCCCCCCCCCC    Default setting     CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

$include update_extrend.gms                   ! Update exogenous growth trend

*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC --Beginning of SHOCK setup-- CCCCCCCCCCCCCCCCCC
$ifthen  setglobal  shock
    advswtch(r,i,v) = no;
    advswtch("USA",advbio,"new")$biotarget_btu("%shockscn%",advbio,t)  = yes;
    advswtch("USA","advb","new")$(biotarget_btu("%shockscn%","advb",t))= yes;
    advswtch("USA","albd","new") = no ;

* Assign biofuel target volume by scenario
    target_fuel('usa',e,t) = biotarget_btu("%shockscn%",e,t);
    target_gal('usa',e,t)  = biotarget_gal("%shockscn%",e,t);

    phi0("%shockscn%",r,advbio,t)       = 1;
    phi(r,e,v)$phi0("%shockscn%",r,e,t) = phi0("%shockscn%",r,e,t);
    phi_(r,e,v,t)                         = phi(r,e,v);

    alfa(r,cornddg)$num(r) = alfa0("%shockscn%",r,cornddg,t);

* Set the limit for biofuel volume
    f_biocapt(bioe,t)$biotarget_btu("%shockscn%",bioe,"2010") = biotarget_btu("%shockscn%",bioe,t)/biotarget_btu("%shockscn%",bioe,"2010");
    f_biocap0(bioe)$biotarget_btu("%shockscn%",bioe,"2010")   = biotarget_btu("%shockscn%",bioe,t)/biotarget_btu("%shockscn%",bioe,"2010");
    f_biocap0(advbio)$advswtch("usa",advbio,"new") = 1;

    a.fx("USA",bioe)$(biotarget_btu("%shockscn%",bioe,"2010") and not sameas(bioe,"plbd")) = f_biocap0(bioe);
    advbiofuel.fx("USA",advbio,"new")$advswtch("usa",advbio,"new") = f_biocap0(advbio);

$endif
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC --End of SHOCK setup-- CCCCCCCCCCCCCCCCCCCCCCCCCCC

*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC --Beginning of OIL PRICE setup-- CCCCCCCCCCCCCCCCC
$ifthen setglobal pcru

    pcrutrd(r)$f_cru(r)         = pcru_trd_scn("%scn%",t);
    pcru.fx$(sum(r,f_cru(r))=0) = pcru_trd_scn("%scn%",t);

* Flag for no afv is allowed in transportation
*   f_afv(r,afv,"new") = no;

* Relax the constraint on biofuels
    advswtch(r,advbio,"new") = yes;
    advswtch(r,"albd","new") = no;
    advswtch(r,"msce","new") = no;
    advswtch(r,"advb","new") = yes;

    a.lo(r,bioe)   = 0 ;
    a.up(r,bioe)   = inf;

    advbiofuel.lo(r,advbio,"new") = 0 ;
    advbiofuel.up(r,advbio,"new") = inf;

    phi(r,e,v)  = 1;
    phi_(r,e,v,t) = phi(r,e,v);
$endif
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC --End of OIL PRICE setup-- CCCCCCCCCCCCCCCCCCCCCCCC



$include findings.gms           ! Reporting
$include report.gms
$include update_entrend.gms     ! Update endogenous factor
$include adage.gen
*$include adage_%run%.gen
solve adage using mcp;


* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*                                                 Start iteration loop runs
* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    loop(lp,

$include report.gms
         chk_gal0(e,t,lp,'target')$(not oil(e)) = target_gal('usa',e,t);
         chk_gal0(e,t,lp,'adage')$(not oil(e))  = sum(i,oev_gal('usa',e,i,t)) ;
         chk_gal0(e,t,lp,'diff')$(not oil(e))   = sum(i,oev_gal('usa',e,i,t))- target_gal('usa',e,t) ;

         chk_gal(e,t,'target')$(not oil(e)) = target_gal('usa',e,t);
         chk_gal(e,t,'adage')$(not oil(e))  = sum(i,oev_gal('usa',e,i,t)) ;
         chk_gal(e,t,'diff')$(not oil(e))   = sum(i,oev_gal('usa',e,i,t))- target_gal('usa',e,t) ;

         chk0_enprod(r,e,lp,"ADAGE",t)   = enprod_btu(r,e,t);
         chk0_enprod(r,e,lp,"IEO2017",t) = IEO2017_prod(r,e,t);

         chk0_encons(r,e,lp,"ADAGE",t)   = en_btu(r,e,"All",t);
         chk0_encons(r,e,lp,"IEO2017",t) = IEO2017_constot(r,e,t);

         chk0_elegen(r,i,lp,"ADAGE",t)   = elesource(r,i,t);
         chk0_elegen(r,i,lp,"IEO2017",t) = IEO2017_gen(r,i,t);

         chk0_elegen(r,"Total",lp,"ADAGE",t)   = elesource(r,"Total",t);
         chk0_elegen(r,"Total",lp,"IEO2017",t) = IEO2017_gen(r,"Total",t);

         chk_gdp(r,t,'aeo')  = round( gdp_trend(r,t),3);
         chk_gdp(r,t,'adage')= round( gdp_(r,t)/gdp_(r,"2010"),3) ;
         chk_gdp(r,t,'diff') = chk_gdp(r,t,'adage')- chk_gdp(r,t,'aeo');

* Code to calibrate GDP internally in REF case in case exogenous GDP data source is updated.
* Keep in mind this should be turned off in the counterfactual cases.
*        c_le0(r,t) = c_le0(r,t) * chk_gdp(r,t,'aeo')/chk_gdp(r,t,'adage') ;
*        le0_10_(r,hh,t)$(chk_gdp(r,t,'aeo')/chk_gdp(r,t,'adage')>1.005 or chk_gdp(r,t,'aeo')/chk_gdp(r,t,'adage')<0.995)
*             = le0_10_(r,hh,t)* chk_gdp(r,t,'aeo')/chk_gdp(r,t,'adage');
*        le0(r,hh)$(ord(t)>=2 ) =le0_10_(r,hh,t);

         chk_eds(r,e,use,i,v,t,"ed0") = ed0_.l(r,e,use,i,v);
         chk_eds(r,e,use,i,v,t,"eds") = eds(r,e,use,i,v,t);
         chk_eds(r,e,use,i,v,t,"diff")= ed0_.l(r,e,use,i,v)-eds(r,e,use,i,v,t);
option  chk_eds:3:5:2
display chk_eds;
display tran_valu,tran_vmt,tran_vmtV,ed0_.l,obmixv_shr,obmix_shr,en_btu,eds, ed,oev_btu,oev_valu,tran_enbtu,tran_enbtuv,tran_mpge, tran_mpgev,chk_gal0,chk_gal;

* Ensure ddgs is produced proportionally
         idt_val(r,"ddgs",t) = sum(v,feed0_ddgs.L(r,"ddgs","liv",v));
         idt_val(r,"corn",t) = sum(v,feed0_a.L(r,"corn","liv",v));
         idt_ton(r,cornddg,t)$(ag_pric0(r,cornddg))= idt_val(r,cornddg,t)/ag_pric0(r,cornddg);

         alfa0(r,"ddgs",t)$id0_10_(r,"ddgs","liv","new","2010")
                           = idt_val(r,"ddgs",t)/id0_10_(r,"ddgs","liv","new","2010");

         alfa0(r,"corn",t) = 1 -   ( alfa0(r,"ddgs",t)-1)
                                 * ddgs4corn
                                 * (id0_10_(r,"ddgs","liv","new","2010")/ag_pric0(r,"ddgs"))
                                 / (id0_10_(r,"corn","liv","new","2010")/ag_pric0(r,"corn"));

         alfa(r,cornddg) = alfa0(r,cornddg,t);


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC --Beginning of SHOCK LOOP-- CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
$ifthen setglobal shock
* Biofuel matches exogenous constraint
         f_biocapt(bioe,t)$(f_biocapt(bioe,t) and  chk_gal0(bioe,t,lp,'adage') and target_fuel('usa',bioe,t) and not cobd(bioe))
                = f_biocapt(bioe,t)*chk_gal0(bioe,t,lp,'target')/chk_gal0(bioe,t,lp,'adage');
         f_biocap0(bioe) = f_biocapt(bioe,t);
         a.fx("USA",bioe)$biotarget_btu("%shockscn%",bioe,t) = f_biocap0(bioe);

         f_biocap0(advbio)$(advswtch("USA",advbio,"new")and sum(oev,oev_btu('usa',advbio,oev,t))) = f_biocap0(advbio)*biotarget_btu("%shockscn%",advbio,t)/sum(oev,oev_btu('usa',advbio,oev,t));
         advbiofuel.fx("USA",advbio,"new")= f_biocap0(advbio);

$endif
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC --End of SHOCK LOOP-- CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC


* if f_ele is turned on, set up co2 emissions cap on electricity generation
         co2t_ff(r,e,use,i,t)$(not fdst(use) and co200(r,e,use,i) )  = co2_btu(r,e) * sum(v,ed0_.l(r,e,use,i,v)) * BTU_conv(r,e,use,i)*co20(r,e,use,i,"new")/co200(r,e,use,i)  ;
         co2ele(r)   = sum(e,co2t_ff(r,e,"fuel","conv",t));

         f_co2eleT("USA",t)$(f_ele("usa") and co2capt("ele",t)) = co2capt("ele",t)/co2ele("USA");
         f_co2ele("USA")$f_ele("usa")  = f_co2ele("USA")* f_co2eleT("USA",t);
         co2elecap("USA")$f_ele("usa") = f_co2ele("USA")* co2capt("ele",t);

         phi(r,e,v)        = 1 ;
         phi_(r,e,v,t)     = phi(r,e,v);
         beta_(r,s,e,v,t)  = beta(r,s,e,v);

display "first",xket,nket,xk0,nk0;

$include adage.gen
Option Solveopt=clear;
solve adage using mcp;

if (adage.modelstat ne 1,  adage.optfile = 2;
$include adage.gen
option solprint = off;
Option Solveopt=clear;
solve adage using mcp;
      );

      modelstats(t,lp)=adage.Modelstat;
      solvestats(t,lp)=adage.solvestat;

);

* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*                                                 End iteration loop runs
* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

$include report.gms

display "second",xket,nket,xk0,nk0;

* Do further check on biofuel volume target
    chk_gal(e,t,'target')$(not oil(e)) = target_gal('usa',e,t);
    chk_gal(e,t,'adage')$(not oil(e))  = sum(i,oev_gal('usa',e,i,t)) ;
    chk_gal(e,t,'diff')$(not oil(e))   = sum(i,oev_gal('usa',e,i,t))- target_gal('usa',e,t) ;

* Check crude oil price path
$ifthen setglobal pcru
    chk_pcru(t,"adage")  = y0_10_("USA","Cru","new","2010")/prod0("USA","cru")*mmbtu_barel*pcru.L;
    chk_pcru(t,"target") = pcru_scn("%scn%",t);
    chk_pcru(t,"pct")    = chk_pcru(t,"adage") /chk_pcru(t,"target")-1;
$endif

* Check GDP growth path
    chk_gdp(r,t,'aeo')  = round( gdp_trend(r,t),3);
    chk_gdp(r,t,'adage')= round( gdp_(r,t)/gdp_(r,"2010"),3) ;
    chk_gdp(r,t,'diff') = chk_gdp(r,t,'adage')- chk_gdp(r,t,'aeo');

    chk_py(r,i,t)  = prices_pc(r,i,"py",t);
    chk_pc(r,t)    = pc.l(r,'hh');
    chk_ped(r,e,t) = auto_pric_pc(r,e,t);

    chk_area(r,'total',t)$(ord(t)>1) = land_area(r,'total',t) - land_area(r,'total',t-1);
    chk_shrt(r,v,s,t) = chk_shr(r,v,s,"total",t);

    chk_plnd(r,lu,t)$(luc(r)=0)= plnd.l(r,lu);
    chk_plnd(r,lu,t)$(luc(r)=1)= plrent.l(r,lu);

    chk_pl(r,t)  = pl.l(r)/pc.l(r,"hh");
    chk_phk(r,t) = phk.l(r)/pc.l(r,"hh");
    chk_pk(r,k,t)= rk.l(r,k)/pc.l(r,"hh");
    chk_prk(r,k,i,t)$kd0(r,k,i,"extant")  = rkx.l(r,k,i)/pc.l(r,"hh");

    chk_autoOil(r,t)= auto_gal(r,"oil",t) ;

    chk_srv(r,"price",t)  = py.l(r,"srv");
    chk_srv(r,"output",t) = sum(v,y0_.l(r,"srv",v)) ;
    chk_srv(r,"revenu",t) = sum(v, py.l(r,"srv")*y0_.l(r,"srv",v)*(1-ty(r,"srv"))) ;
    chk_srv(r,"cost",t)   =   sum((g,v),    id0_.l(r,g,"srv",v)*pa.l(r,g)*pid0(r,g,"srv"))
                            + sum((e,use,v),ed0_.l(r,e,use,"srv",v)*ped.l(r,e,use,"srv") );

    chk_srv(r,"gdp",t)   =  chk_srv(r,"revenu",t)-  chk_srv(r,"cost",t);

    yield(r,crp,t)$ag_lndh(r,crp,t)              = ag_tonn(r,crp,t)/land_area(r,crp,t);
    yield_growth(r,crp,t)$yield(r,crp,"2010")    = yield(r,crp,t)/yield(r,crp,"2010");
    ag_tonn_growth(r,crp,t)$ag_tonn(r,crp,"2010")= ag_tonn(r,crp,t)/ag_tonn(r,crp,"2010");
    output_growth(r,indm,t)$output(r,indm,"2010")= output(r,indm,t)/ output(r,indm,"2010");
    output_growth(r,trn,t)$output(r,trn,"2010")  = output(r,trn,t) / output(r,trn,"2010");
    vmt_growth(r,t)$tran_vmt(r,"auto","2010")    = tran_vmt(r,"auto",t)/tran_vmt(r,"auto","2010");

* More check for transportation cost in below
$include check.gms

option  chk_gdp:3:2:1, auto_gal:4:2:1, land_area:4:2:1;
display chk_gdp,chk_gal;
);
*End of time loop

