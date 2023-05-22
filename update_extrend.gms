*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*           Update some exogenous growth trends applied from 2010 to 2050
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

* EX1: land productivity, land use change, and resource elasticity
    If (ord(t)= 1,
         luc(r) = 0;
         d_shr(r,s) = 1;
         f_adj(r,s,v)$(vnum(v) ) = 1;

         ha_conv(r,s)$p_land0(r,s)=1/p_land0(r,s)*l_shr(r,s);

         esub_nr(r,ff)   = 0;
         pref_nr(r,ff)   = 1 ;
         pref_gen(r,gentype) = 1 ;

    else
         luc(r) =1;
         npp(r,lu)=1;
         npp(r,lu)$luc(r)=lnd_trend(r,lu,t);                                ! update land productivity
         );

* EX2: GHG emissions related updates
* No price on GHG emissions
    f_ghg(r,ghg)= 0;
    f_co2(r)    = 0;
    f_co2luc(r) = 0;
    ctax(r)     = 0;
    ghgcarb(r)  = no;

* Set up co2 emission flag from electricity generation
    f_ele(r)     = 0 ;
    f_co2ele(r)  = 0;
    co2elecap(r) = 0;

* turn on the US clean power plan
*   f_ele("USA")$(co2capt("ele",t)) = 1;
*   f_co2ele("USA")$(co2capt("ele",t))  = 1;
*   co2elecap("USA")$(co2capt("ele",t)) =  co2capt("ele",t);

*EX3: Ag and energy productivity growth
    y0_10_(r,crp,v,t)$y0_10_(r,crp,v,"2010")
        = y0_10_(r,crp,v,"2010");

    y0(r,crp,v)$y0_10_(r,crp,v,t)
        = y0_10_(r,crp,v,t);

    y0_10_(r,i,v,t)$(y0_10_(r,i,v,"2010") and ord(t)>1 and new(v) and y0_trd(r,i,t))
        = y0_10_(r,i,v,"2010")*y0_trd(r,i,t);

    y0(r,i,v)$(y0_10_(r,i,v,t) and new(v) and y0_trd(r,i,t))
        = y0_10_(r,i,v,t);

* define Armington electricity generation mix
    y00(r,i,v)$(y00_10(r,i,v,t) and t.val>2010) = y00_10(r,i,v,t);

*EX4: Energy efficiency
    ed0_10_(r,j,use,i,v,t)$(ord(t)>1 and aeei(r,j,t) and new(v))
        = ed0_10_(r,j,use,i,v,"2010")*aeei(r,j,t);

*  No further efficiency gain for default improvement for transportation sector
*   as its efficiency gain is done in a seperate approach later through old_mpgeT and new_mpgeT
    ed0_10_(r,j,use,trnv,v,t)$(new(v))
         = ed0_10_(r,j,use,trnv,v,"2010");
*  No further efficiency gain for other transportation as well.
    ed0_10_(r,j,use,trn,v,t)$(new(v))
         = ed0_10_(r,j,use,trn,v,"2010");

    ed0_10_(r,j,use,i,v,t)$(extant(v))
         = ed0_10_(r,j,use,i,v,"2010");

    ed0(r,j,use,i,v)$ed0_10_(r,j,use,i,v,"2010")
         = ed0_10_(r,j,use,i,v,t);

* EX5: Adjust intermediate goods use for CHN to align its growth with population

    id0("CHN",agr,i,v)$id0_10_("CHN",agr,i,v,"2010")
          = id0_10_("CHN",agr,i,v,"2010")*idag_trend(t);
    id0("CHN",food,i,v)$id0_10_("CHN",food,i,v,"2010")
          = id0_10_("CHN",food,i,v,"2010")*idag_trend(t);

    id0("CHN","srv",i,v)$id0_10_("CHN","srv",i,v,"2010")
          =  id0_10_("CHN","srv",i,v,"2010")
           + sum(agr, id0_10_("CHN",agr,i,v,"2010") - id0("CHN",agr,i,v))
           + sum(food,id0_10_("CHN",food,i,v,"2010")- id0("CHN",food,i,v))  ;

*EX6: Labor supply

    le0_10_(r,hh,t)$(ord(t)=1 )= (le0_10(r,hh,"2010")+leis0(r,hh)) ;
    le0_10_(r,hh,t)$(ord(t)>1 )= (le0_10(r,hh,"2010")+leis0(r,hh))*(pop_trend(r,t)+lprd_trend(r,t)-1) ;

    le0(r,hh)$(ord(t)>=1 ) = le0_10_(r,hh,t);

*EX7: Energy resources
    re0(r,i,v)         = rd0_10(r,i,v,"2010")*re0_trd(r,i,t)   ;


* CCCCCCCCCCCCCCCCCCCC      Update electricty generation cost, resource endowment by technology  CCCCCCCCCCCCCCCCC
* Activate the advanced electricity generation technology
    f_advgen(r,advee,v) = yes;

* Exgoenous for electricity generation resource endowment and its elasticity
    rnwe0(r,gentype,"new")$(t.val>2010 and (convrnw(gentype) or f_advgen(r,gentype,"new")))
        = rnw0_10(r,gentype,"new","2010")*rnwe0_trd(r,gentype,t) ;

    esub_gen(r,gentype)  = 0 ;
* Assign ROW, bio to be 0.5 so the model solves in 2010
    esub_gen("ROW","bio")= 0.5;
    ele_elas=0.30;

* Update electricity generation cost over time

    elegen_yt00(r,i,v,t)$(convrnw(i) or f_advgen(r,i,v))  =  elegen_yt0(r,i,"new",t) ;

    elegen_edt00(r,e,"fuel",i,v,t)  $(new(v) and (convrnw(i) or f_advgen(r,i,v))) = elegen_edt0(r,e,"fuel",i,v,t) ;
    elegen_idt00(r,i,g,v,t)         $(new(v) and (convrnw(i) or f_advgen(r,i,v))) = elegen_idt0(r,i,g,v,t)        ;
    elegen_ldt00(r,i,v,t)           $(new(v) and (convrnw(i) or f_advgen(r,i,v))) = elegen_ldt0(r,i,v,t)          ;
    elegen_kdt00(r,i,k,v,t)         $(new(v) and (convrnw(i) or f_advgen(r,i,v))) = elegen_kdt0(r,i,k,v,t)        ;
    elegen_rnwdt00(r,i,v,t)         $(new(v) and (convrnw(i) or f_advgen(r,i,v))) = elegen_rnwdt0(r,i,v,t)        ;

* Assume technologies are available during 1985~2050
* Cost is same for year during 1985-2010
    elegen_edt00(r,e,"fuel",i,v,t)$(extant(v)   and (convrnw(i) or f_advgen(r,i,v)))
          =  sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6),ele_btushrV(r,i,"extant",tt,t)*elegen_edt0(r,e,"fuel",i,"extant",tt))
           + ele_btushrV(r,i,"his","2010",t)*elegen_edt0(r,e,"fuel",i,v,"2010") ;

    elegen_idt00(r,i,g,v,t)    $(t.val>2010  and extant(v)   and (convrnw(i) or f_advgen(r,i,v)) )
          =  sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6),ele_btushrV(r,i,"extant",tt,t)*elegen_idt0(r,i,g,"extant",tt))
            + ele_btushrV(r,i,"his","2010",t)* elegen_idt0(r,i,g,v,"2010")        ;

    elegen_ldt00(r,i,v,t)      $(extant(v)   and (convrnw(i) or f_advgen(r,i,v)) )
          =  sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6),ele_btushrV(r,i,"extant",tt,t)*elegen_ldt0(r,i,"extant",tt))
           + ele_btushrV(r,i,"his","2010",t)* elegen_ldt0(r,i,v,"2010")          ;

    elegen_kdt00(r,i,k,v,t)    $(extant(v)   and (convrnw(i) or f_advgen(r,i,v)))
          =   sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6),ele_btushrV(r,i,"extant",tt,t)*elegen_kdt0(r,i,k,"extant",tt))
           +  ele_btushrV(r,i,"his","2010",t)* elegen_kdt0(r,i,k,v,"2010")        ;

    ed0(r,e,use,i,v)$((convrnw(i) or f_advgen(r,i,v))) = elegen_edt00(r,e,use,i,v,t);
    id0(r,g,i,v)    $((convrnw(i) or f_advgen(r,i,v))) = elegen_idt00(r,i,g,v,t)    ;
    ld0(r,i,v)      $((convrnw(i) or f_advgen(r,i,v))) = elegen_ldt00(r,i,v,t)      ;
    kd0(r,k,i,v)    $((convrnw(i) or f_advgen(r,i,v))) = elegen_kdt00(r,i,k,v,t)    ;

*  Make sure to turn off the production block if old facility phases out
    y0(r,i,v)$(t.val>2010  and (convrnw(i) or f_advgen(r,i,v)) and ld0(r,i,v)>0 and extant(v)) = y0(r,i,"new");
    y0(r,i,v)$(t.val>2010  and (convrnw(i) or f_advgen(r,i,v)) and ld0(r,i,v)=0 and extant(v)) = 0;

*EX8: Land and capital endowment (reset initial endowment)
    lnde0(r,lu,v)$(ord(t)=1) = lnd0(r,lu,v)  ;
    rentv(r,nat)$(ord(t)=1)  = rentv0(r,nat);
    fffor(r,lu,v)$(vnum(v) and ord(t)=1)=fffor0(r,lu,v);

*EX9: Initial assignment for capital and government spending
    xk0(r,k,i)$(ord(t)=1 and not conv(i))    = xk0_10_(r,k,i);
    nk0(r,k)$(ord(t)=1)      = sum(i$(not conv(i)),nk0_10_(r,k,i));
    gove0(r)$(ord(t)=1)      = gov0(r)       ;

*EX10: Energy Elasticities or price
    eva_elas(i)     = eva_elast(i,t);

*  No price path for crude oil
    f_cru(r)        = 0;

*EX11: Update ceth and sybd conversion data after 2010 in USA (data provided by EPA)
    f_bio(r,e)      = 0;
    f_bio("USA","ceth")$(ord(t)>1) = 1;
    f_bio("USA","sybd")$(ord(t)>1) = 1;

    chg_bio(r,bio,"y0","new")$f_bio(r,bio)= chg_biot(r,bio,t,"y0");
    chg_bio(r,bio,i,"new")$f_bio(r,bio)   = chg_biot(r,bio,t,i)   ;
    chg_bio(r,bio,e,"new")$f_bio(r,bio)   = chg_biot(r,bio,t,e)   ;
    chg_bio(r,bio,k,"new")$f_bio(r,bio)   = chg_biot(r,bio,t,k)   ;
    chg_bio(r,bio,"ld","new")$f_bio(r,bio)= chg_biot(r,bio,t,"ld");
    chg_bio(r,bio,"hk","new")$f_bio(r,bio)= chg_biot(r,bio,t,"hk");

*EX12:  Activate advanced biofuel production in all regions
    advswtch(r,i,v) = no;
    advswtch(r,advbio,"new") = yes;
    advswtch(r,"Albd","new") = no;
    advswtch(r,"msce","new") = no;
    advswtch(r,"advb","new")$sum(advbio$advswtch(r,advbio,"new"),1) = yes;

    advbiolnd0("USA",advl)$advswtch("USA",advl,"new")      = advblndshr(advl,t) ;
    advbiokd0("USA","va",advl)$advswtch("USA",advl,"new")  = advbkdshr(advl,"2010");
    advbiomkup(r,advbio)$advbiomkupt(advbio,t)  = advbiomkupt(advbio,t);

*EX13: Assign biofuel volume target in USA: use the baseyear volume as default
    target_fuel('usa',e,t)= bau_btu('usa',e,t);
    target_gal('usa',e,t) = bau_gal('usa',e,t);

*   Assign the initial factor to adjust energy share in LDV
    phi(r,e,v)       = 1;
    phi_(r,e,v,t)    = phi(r,e,v);
    phi_(r,advbio,v,t) = phi(r,"weth",v);

* Assign the initial factor for DDGS
    alfa(r,i) = 1;

*EX14:  Activate AFV in the model and assign its markup, cost input, fixed factor endowment
    f_afv(r,afv,v)      = 0;
    f_afv(r,afv,"new")$afv_t0(r,afv,"new",t)      = 1;
*    f_afv(r,afv,"extant")$(afv_t0(r,afv,"extant",t) and y0_.l(r,afv,"new")) = 1;
    f_afv(r,afv,"extant")$(afv_t0(r,afv,"extant",t) ) = 1;

    tran_vmtshrV(r,afv,"extant",tt,t)$(ord(t)=1 and tt.val<=t.val-1 and tt.val>=t.val-6) = 0 ;

    afv_ld0(r,afv,v)$new(v)     = afv_ldt0(r,afv,v,t);
    afv_id0(r,afv,g,v)$new(v)   = afv_idt0(r,afv,g,v,t);
    afv_kd0(r,afv,k,v)$new(v)   = afv_kdt0(r,afv,k,v,t);
    afv_hkd0(r,afv,v)$new(v)    = afv_hkdt0(r,afv,v,t);

    afv_ldt00(r,afv,v,t)$(extant(v)   and ord(t)=1 and f_afv(r,afv,v)) = afv_ldt0(r,afv,"new",t)  ;
    afv_idt00(r,afv,g,v,t)$(extant(v) and ord(t)=1 and f_afv(r,afv,v)) = afv_idt0(r,afv,g,"new",t);
    afv_kdt00(r,afv,k,v,t)$(extant(v) and ord(t)=1 and f_afv(r,afv,v)) = afv_kdt0(r,afv,k,"new",t);
    afv_hkdt00(r,afv,v,t)$(extant(v)  and ord(t)=1 and f_afv(r,afv,v)) = afv_hkdt0(r,afv,"new",t) ;

    afv_ldt00(r,afv,v,t)$(extant(v)   and ord(t)>1 and f_afv(r,afv,v)) = sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6),tran_vmtshrV(r,afv,"extant",tt,t)*afv_ldt0(r,afv,"new",tt))   ;
    afv_idt00(r,afv,g,v,t)$(extant(v) and ord(t)>1 and f_afv(r,afv,v)) = sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6),tran_vmtshrV(r,afv,"extant",tt,t)*afv_idt0(r,afv,g,"new",tt)) ;
    afv_kdt00(r,afv,k,v,t)$(extant(v) and ord(t)>1 and f_afv(r,afv,v)) = sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6),tran_vmtshrV(r,afv,"extant",tt,t)*afv_kdt0(r,afv,k,"new",tt)) ;
    afv_hkdt00(r,afv,v,t)$(extant(v)  and ord(t)>1 and f_afv(r,afv,v)) = sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6),tran_vmtshrV(r,afv,"extant",tt,t)*afv_hkdt0(r,afv,"new",tt))  ;

    afv_edtrdt00(r,afv,v,t)$(extant(v) and ord(t)>1 and f_afv(r,afv,v))
     = sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6 and tran_mpgev(r,afv,"new",tt)),
                   tran_vmtshrV(r,afv,"extant",tt,t)*afv_mpgeT0(r,afv,"2010")/tran_mpgev(r,afv,"new",tt)) ;

    afv_ld0(r,afv,v)$extant(v)     = afv_ldt00(r,afv,v,t);
    afv_id0(r,afv,g,v)$extant(v)   = afv_idt00(r,afv,g,v,t);
    afv_kd0(r,afv,k,v)$extant(v)   = afv_kdt00(r,afv,k,v,t);
    afv_hkd0(r,afv,v)$extant(v)    = afv_hkdt00(r,afv,v,t);

    afv_id0(r,afv,"srv",v)         = sum(trn,afv_id0(r,afv,trn,v))+  afv_id0(r,afv,"srv",v);
    afv_id0(r,afv,trn,v)           = 0;

* Separate fuel efficiency improvement out into two parts: afv_edt(r,afv,e,"2010") and afv_edtrd0(r,afv,v)
    afv_ed0(r,afv,e,v)             = afv_edt0(r,afv,e,"extant","2010");

* Factor to calibrate new vehicle fuel economy to the exogenous growth trend
    c_afv(r,afv,v)$(ord(t)=1) = 1;
    c_afv(r,afv,v)$(c_afvT0(r,afv,v)) = c_afvT0(r,afv,v);

* Allow fuel efficiency adjusted by additional calibration
    afv_edtrd0(r,afv,v)               = 1;
    afv_edtrd0(r,afv,v)$new(v)        = afv_edtrdt0(r,afv,v,t) *c_afv(R,AFV,v);
    afv_edtrd0(r,afv,v)$extant(v)     = afv_edtrdt00(r,afv,v,t)*c_afv(R,AFV,v);

    afv_edt0(r,afv,e,v,t)$(new(v) and btu_conv(r,e,"fuel",afv))
        = afv_edt0(r,afv,e,"extant","2010")*afv_edtrd0(r,afv,v);
    afv_edt00(r,afv,e,v,t)$(extant(v) and btu_conv(r,e,"fuel",afv))
        = afv_edt0(r,afv,e,"extant","2010")*afv_edtrd0(r,afv,v);

* afv_yenT0 and afv_vmtT0 is annual
    afv_vmtT0(r,afv,v,t)$new(v) = afv_yenT0(r,afv,v,t)/afv_loadf0(r,afv)
                                 /afv_pricT0(r,afv,v,t)    ;

$ifthen  setglobal  ffaeo
*case1:ffaeo
    afv_ff0(r,afv,v)$(new(v) and afv_yenT0(r,afv,v,t))  = 0.001;
    afv_ffen0(r,afv,v)$(new(v) and afv_yenT0(r,afv,v,t))= 0.001*afv_yenT0(r,afv,v,t);
$endif

$ifthen  setglobal  ff0
*case2:ff0
     afv_ff0(r,afv,v)$(new(v) and afv_yenT0(r,afv,v,t))  = 0;
     afv_ffen0(r,afv,v)$(new(v) and afv_yenT0(r,afv,v,t))= 0;
$endif

$ifthen  setglobal  ffown
*case3:ffown: default case
    afv_ff0(r,afv,v)$(new(v) and afv_yenT0(r,afv,v,t))  = 0.001;
    afv_ffen0(r,afv,v)$(new(v) and afv_yenT0(r,afv,v,t))         = 0.001*afv_yenT0(r,afv,v,t);
    afv_ffen0(r,afv,v)$(new(v) and afv_yenT0(r,afv,v,t) and ord(t)>1 and round(tran_valuv(r,afv,v,t-1),4)>0)= 0.001*tran_valuv(r,afv,v,t-1);
    afv_ffen0(r,afv,v)$(new(v) and afv_yenT0(r,afv,v,t) and ord(t)>2 and round(tran_valuv(r,afv,v,t-1),4)=0 and round(tran_valuv(r,afv,v,t-2),4)>0)= 0.001*tran_valuv(r,afv,v,t-2);
$endif

* Allow fixed factor endowment enter the conventional transportation technology
    f_trn(r,i,"new")$auto(i) = yes;
    trn_ffen0(r,i,v)$(new(v) and trnv(i) and f_trn(r,i,"new") and ord(t)=1) = 0.001*y0(r,i,v);
    trn_ffen0(r,i,v)$(new(v) and trnv(i) and f_trn(r,i,"new") and ord(t)>1)
       = sum(mapoev(oev,i),0.001*tran_valuv(r,oev,v,t-1));
    trn_ffent0(r,i,t)= trn_ffen0(r,i,"new");

    f_trn(r,i,"new")$(f_trn(r,i,"new") and trn_ffen0(r,i,"new")=0) = no;

*EX15: Apply the lower bound constraint to consider vehicle stock turnover
    y.lo(r,s,v)$(extant(v) and ord(t)>1 and trn(s) and not trnv(s))  = 0.5* y.l(r,s,v);
    y.up(r,s,v)$(new(v)    and ord(t)>1 and trnv(s) and y0_.l(r,s,v)=0) = 0;
    afvtrn.lo(r,afv,v)$(new(v) and ord(t)>1 and f_afv(r,afv,v) and y0_.l(r,afv,v)>=0.01)  = 0.1 *y0_.l(r,afv,v);
    afvtrn.lo(r,afv,v)$(new(v) and ord(t)>1 and f_afv(r,afv,v) and y0_.l(r,afv,v)<0.01)   = 0 ;

* For DN version, turn it off
$ifthen setglobal DN
* Turn off AFV
     f_afv(r,afv,v)     = 0;
* Turn off the fixed factor approach in conventional vechicle
     f_trn(r,i,"new")$auto(i) = no;
$endif

*EX16: Biofuel usage in OEV, AFV or not
*  In the disaggregated version, allow biofuel usage in conventional HDV sector to substitute refined oil
    if(f_aggtrn=0,
         f_hdvbio(r,hdv)$(t.val=2010)  = 1;
         f_hdvbio(r,hdv)$(t.val>2010)  = 1;
*only biofuel and oil are assigned to beta0
         beta0(r,s,e,v)$(ob(e) and trnv(s))                              = betat0(r,s,e,v,t);
         beta(r,s,e,v)$(f_hdvbio(r,s)$rodf(s) or auto(s))                = betat0(r,s,e,v,t);
         beta(r,s,e,v)$(rodp(s) )                                        = betat0(r,s,e,v,"2010");
       );

* In the aggregated version, update the transportation set mapping and set the flag to allow biofuel usage in OTRN or not
    if(f_aggtrn=1,
         maptrn(jj,i)$sum(maptrn(j,i),Map_aggtrn(jj,j))=yes;
         maptrn(jj,i)$deltrn(jj) = no;
         maptrn("Otrn","Otrn_OEV")=yes;
         mapoev("Otrn_OEV","Otrn") =yes;
         mapoev(jj,i)$hdv(i) = no;

* No afv is allowed
         f_afv(r,afv,v)     = 0;

* No biofuels are allowed in otrn
*         f_hdvbio(r,s)$(t.val>=2010 and otrn(s) )  = 0;

* Biofuels are allowed in otrn
         f_hdvbio(r,s)$(t.val>=2010 and otrn(s))  = 1;

         beta(r,s,e,v)= betat0(r,s,e,v,t);
         beta(r,s,e,v)$(f_hdvbio(r,s))= betat0(r,s,e,v,t);

* Turn off the fixed factor approach in conventional vechicle
         f_trn(r,i,"new")$auto(i) = no;
       );


* Allow biofuel to be used in AFVs to substitute refined oil in LDV and HDV
*  Technologies where refined oil is used (Auto_GasV, Auto_HEV,  RodF_HEV and RodP_HEV) are allowed to use biofuels
    f_afvbio(r,afv)$(f_afv(r,afv,"new") and BioAFV(afv) )   = 1;

*  Technologies in LDV where refined oil is used (Auto_GasV, Auto_HEV only) are allowed to use biofuels
*   f_afvbio(r,afv)$(f_afv(r,afv,"new") and BioAFV(afv) and bioautoafv(afv))   = 1;

*  Technologies in HDV where refined oil is used (RodF_HEV and RodP_HEV only) are allowed to use biofuels
*   f_afvbio(r,afv)$(f_afv(r,afv,"new") and BioAFV(afv) and not bioautoafv(afv))   = 1;

*  Other technologies where refined oil is not used won't have the ability to substitute its energy to biofuels
    f_afvbio(r,afv)$(sum(maptrn(i,afv),f_hdvbio(r,i))=0 and hdvafv(afv)) = 0;


*EX17: Activate fuel economy target in USA in the baseline or not
    targt_mpge(r,trnv) = 0 ;
    targt_mpge(r,trnv) = targt_mpgeT(r,trnv,t);

* Price for fuel economy permit
    pmt_mpge("rodf","2010") = 1.5;
    pmt_mpge("rodf","2015") = 3.0;
    pmt_mpge("rodp","2015") = 9.0;
    pmt_mpge("auto",t) = 0.7 ;

    pmt(trnv)= pmt_mpge(trnv,t);


*EX18: Enable fuel economy efficiency improvement
* Set up higher mpge efficiency improvement for new OEV vehicles in Auto, RodF, PodP
*  only energy input is adjusted based on fuel economy assumption
    mk(r,s,label,v) = 1 ;

*  Dynamic fuel efficiency improvement for used vehicles
   tran_vmtshrv(r,oev,"his","2010",t)$(ord(t)=1) =0;

   old_mpgeT(r,trn,t)$(trnv(trn) and ord(t)>1)
       =  sum(mapoev(oev,trn), sum(tt$(ord(tt)<=ord(t)-1 and ord(tt)>=ord(t)-6), tran_vmtshrv(r,oev,"extant",tt,t)*tran_mpgeV(r,oev,"new",tt) ) )
        + sum(mapoev(oev,trn), tran_vmtshrv(r,oev,"his","2010",t)*tran_mpgeV(r,oev,"extant","2010")) ;

*  Further improvement on vehicle vintage structure is planned: all input including energy is updated periodically based on previous years results

    mkt(r,trn,"ed0",v,t)$(extant(v) and old_mpgeT(r,trn,t)) = tran_mpge0(r,trn)/old_mpgeT(r,trn,t);
    mkt(r,trn,"ed0",v,t)$(new(v)    and new_mpgeT(r,trn,t)) = tran_mpge0(r,trn)/new_mpgeT(r,trn,t);
    mkt(r,trn,"ed0",v,t)$(extant(v) and new_mpgeT(r,trn,t) and ord(t)=1 and rodp(trn) and num(r)) = mkt(r,trn,"ed0","new",t) ;

    mk(r,trnv,"ed0",v)$new(v)  =  mkt(r,trnv,"ed0",v,t);
    mk(r,trnv,"ed0",v)$(extant(v) and auto(trnv))= mkt(r,trnv,"ed0",v,t);
    mk(r,trnv,"ed0",v)$(extant(v) and hdv(trnv)) = mkt(r,trnv,"ed0",v,t);



