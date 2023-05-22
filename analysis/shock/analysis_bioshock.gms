$title Biofuel Shock Analysis


*************************************************************************************
*                          Scenario Analysis
*************************************************************************************
set  shockscn   /    Bau       Assumptions in the model
                     REF       AEO REF case
                     Ceth5B    5 billion gallon corn ethanol shock above baseline (flat between 2020-2050)
                     Sybd2B    2 billion gallon soybean disiel shock above baseline (flat between 2020-2050)
                     ArsE5B    5 billion gallon ethanol from Ag residue shock above baseline (flat between 2020-2050)

                     NoRFS     NO RFS case
                     HiSoy     High soybean biodiesel case
                     HiCorn    High corn ethanol case
                 /


parameter shock_gal(t,*,*)   shock volume for ethanol and diesel over the time by scenarios(bg)
;
$onecho >gdxxrw.rsp
par=shock_gal    rng=gams!a4:w13    rdim=1 cdim=2
$offecho

$call 'gdxxrw i=.\analysis\shock\"2018.07.05 Combined volumes for ADAGE.xlsx" o=.\analysis\shock\2018_Combined_volumes.gdx @gdxxrw.rsp'
$gdxin '.\analysis\shock\2018_Combined_volumes.gdx'
$load  shock_gal
$call 'del gdxxrw.rsp'

display shock_gal, bau_gal;

parameter  biotarget_gal(shockscn,*,t)   quantity of biofuel target (billion gallon)
           biotarget_btu(shockscn,*,t)   btu of biofuel target (quad btu)
           biotarget_ha(shockscn,*,t)    area used for biofuel target (million ha);


       biotarget_gal(shockscn,e,t)$(sameas(shockscn,"Bau"))                    = bau_gal("USA",e,t);
       biotarget_gal(shockscn,e,t)$(not sameas(shockscn,"Bau") and t.val=2010) = bau_gal("USA",e,t);

       biotarget_gal(shockscn,e,t)$(not sameas(shockscn,"Bau") and t.val>2010) = shock_gal(t,shockscn,e);

       biotarget_gal("bau",advbio,t) = 0.0000001;
       biotarget_gal(shockscn,advbio,"2010")$(biotarget_gal(shockscn,advbio,"2015")>0)=0;

       biotarget_gal(shockscn,"advb",t) = sum(advbio,  biotarget_gal(shockscn,advbio,t));

       biotarget_btu(shockscn,e,t)       = btu_gal(e)* biotarget_gal(shockscn,e,t);
       biotarget_btu(shockscn,"advb",t)  = sum(advbio,  biotarget_btu(shockscn,advbio,t));


       biotarget_btu(shockscn,"oil",t)   = BTU_conv("USA","oil","fuel","auto") * ed0_10("usa","oil","fuel","auto","new","2010");

       biotarget_ha(shockscn,bio,t)$bio_yield0("usa",bio) = biotarget_gal(shockscn,bio,t)/bio_yield0("usa",bio)*1000/lnd_trend("usa","crop",t);
       biotarget_ha(shockscn,advbio,t)$bio_yield0("usa",advbio) = biotarget_gal(shockscn,"advb",t)/bio_yield0("usa",advbio)*1000/lnd_trend("usa","crop",t);

option  biotarget_gal:2:2:1;
display biotarget_gal, biotarget_btu,biotarget_ha;


       phi0(shockscn,r,e,t)=1;
       phi0(shockscn,"usa",ethl,t)
              =    (biotarget_btu(shockscn,ethl,t) / sum(e, biotarget_btu(shockscn,e,t)))
                  * fuel0_10("usa","new","2010") / ed0_10("usa",ethl,"fuel","auto","new","2010");
       phi0(shockscn,"usa",biod,t)$ed0_10("usa",biod,"fuel","auto","new","2010")
              =    (biotarget_btu(shockscn,biod,t) / sum(e, biotarget_btu(shockscn,e,t)))
                 * fuel0_10("usa","new","2010") / ed0_10("usa",biod,"fuel","auto","new","2010");

       phi0(shockscn,"usa",advbio,t)
              =  ( biotarget_btu(shockscn,advbio,t) /  sum(e, biotarget_btu(shockscn,e,t)))
                 * fuel0_10("usa","new","2010");


       phi0(shockscn,"usa","oil",t)
         =     (   fuel0_10("usa","new","2010")
                 - sum(ethl, phi0(shockscn,"usa",ethl,t) * ed0_10("usa",ethl,"fuel","auto","new","2010"))
                 - sum(biod, phi0(shockscn,"usa",biod,t) * ed0_10("usa",biod,"fuel","auto","new","2010"))
                 - sum(advbio,phi0(shockscn,"usa",advbio,t) * advbiomkup("usa",advbio))      )
              / ed0_10("usa","oil","fuel","auto","new","2010");


display  phi0,phi;

parameter     ddgsprod_ton(shockscn,r,t)    DDGS production under the biofuel shock scenarios (million tonne)
              ddgsprod_val(shockscn,r,t)    DDGS production under the biofuel shock scenarios ($billion);

       ddgsprod_ton(shockscn,r,t)$num(r) =  biotarget_gal(shockscn,"ceth",t)* corncoprod_yield0(t,"ddgs") /2204.62262*1000;
       ddgsprod_val(shockscn,r,t)$num(r) =  ag_pric0(r,"ddgs")* ddgsprod_ton(shockscn,r,t);



