
$Title ADAGE Model - Output Report Writing

**-----------------------------report output variables ------------------------
obmixv(r,use,i,v,t)                = OEV_VALUS0_.L(r,use,i,v);
obmixv(r,use,i,v,t)$trnv(i)        = sum(maptrn(i,j),obmixv(r,use,j,v,t));
obmixv_shr(r,use,j,i,v,t)          = sum(maptrn(i,j)$obmixv(r,use,i,v,t),obmixv(r,use,j,v,t)/obmixv(r,use,i,v,t));
obmixv_shr(r,use,i,i,v,t)$trnv(i)  = sum(maptrn(i,j),obmixv_shr(r,use,j,i,v,t));

obmix(r,use,i,t)                   = sum(v,OEV_VALUS0_.L(r,use,i,v));
obmix(r,use,i,t)$trnv(i)           = sum(maptrn(i,j),obmix(r,use,j,t));
obmix_shr(r,use,j,i,t)             = sum(maptrn(i,j)$obmix(r,use,i,t),obmix(r,use,j,t)/obmix(r,use,i,t));
obmix_shr(r,use,i,i,t)$trnv(i)     = sum(maptrn(i,j),obmix_shr(r,use,j,i,t));
obmix_shr1(r,use,j,i,v,t)$trnv(i)  = sum(maptrn(i,j)$obmix(r,use,i,t),obmixv(r,use,j,v,t)/obmix(r,use,i,t));
obmix_shr1(r,use,i,i,v,t)$trnv(i)  = sum(maptrn(i,j),obmix_shr1(r,use,j,i,v,t));

* Land is total over 5 year time period so need to divide by 5 to convert to annual value
eds(r,e,use,i,v,t)                 = ed0_.l(r,e,use,i,v);
eds(r,e,use,"lu",v,t)$luc(r)       = sum((lu,lu_,g),lnd_ed0_.L(r,e,use,g,lu,lu_,v))/5;
eds(r,e,use,oev,v,t)               = sum(mapoev(oev,j)$(f_hdvbio(r,j)=0 and not auto(j)),eds(r,e,use,j,v,t));
eds(r,e,use,oev,v,t)$(not ob(e))   = sum(mapoev(oev,j),eds(r,e,use,j,v,t));

* Oil-biofuel blending by new and extant are no longer exclusively used in new or used vehicles, but mixed.
* In other words, new or used vehicles do not differentiate how fuel is blended
eds(r,e,use,i,v,t)$(ob(e) and sum(maptrn(j,i)$(f_hdvbio(r,j) or auto(j)), 1))
           = sum(maptrn(j,i)$(f_hdvbio(r,j) or auto(j)),  sum(vv,ed0_.l(r,e,use,j,vv))*obmix_shr1(r,use,i,j,v,t));

eds(r,e,use,i,v,t)$trnv(i)         = sum(maptrn(i,j),eds(r,e,use,j,v,t));
ed(r,e,use,i,t)                    = sum(v,eds(r,e,use,i,v,t));

**re1: Report GDP and macro ($billion)

macro(r,"GDP",t)$(luc(r)=0)
     = ( sum((i,v),             pl.l(r) * ld0_.l(r,i,v) * pld0(r,i))
        + sum((k,i),            rk.l(r,k) * kd0_.l(r,k,i,"new") * pkd0(r,k,i))
        + sum((k,i),            rkx.l(r,k,i) * kd0_.l(r,k,i,"extant") * pkd0(r,k,i))
        + sum((i,v),            phk.l(r) * hkd0_.l(r,i,v) * phkd0(r,i))
        + sum((i,v),            plnd.l(r,i) * lnd0_.l(r,i,v))
        + sum((i,v),            pr.l(r,i) * rd0_.l(r,i,v))
        + sum((i,v),            prnw.l(r,i) * rnw0_.l(r,i,v))
        + sum((i,v),            ty(r,i) * (y0_.l(r,i,v)+y00_.l(r,i,v)))
        + sum((e,use,i,v),      te(r,e,use,i) * eds(r,e,use,i,v,t))
* add natural land value (fixed value)
        + sum(nat,              rentv0(r,nat))
        ) / pc.l(r,"hh")
          /deflator_R(r) ;

macro(r,"GDP",t)$luc(r)
     = ( sum((i,v),             pl.l(r) * ld0_.l(r,i,v) * pld0(r,i))
        + sum((k,i),            rk.l(r,k) * kd0_.l(r,k,i,"new") * pkd0(r,k,i))
        + sum((k,i),            rkx.l(r,k,i) * kd0_.l(r,k,i,"extant") * pkd0(r,k,i))
        + sum((i,v),            phk.l(r) * hkd0_.l(r,i,v) * phkd0(r,i))
        + sum((i,v),            plnd.l(r,i) * lnd0_.l(r,i,v))
        + sum((i,v),            pr.l(r,i) * rd0_.l(r,i,v))
        + sum((i,v),            prnw.l(r,i) * rnw0_.l(r,i,v))
        + sum((i,v),            ty(r,i) * (y0_.l(r,i,v)+y00_.l(r,i,v)))
        + sum((e,use,i,v),      te(r,e,use,i) * eds(r,e,use,i,v,t))
* Add natural land value
        + sum(nat,              plrent.l(r,nat)*rentv(r,nat))
        + sum((nat,v),          plff.l(r,nat)*fffor(r,nat,v))
        ) / pc.l(r,"hh")
          /deflator_R(r) ;

gdp_(r,t)= macro(r,"GDP",t);

**Report GDP by resources
gdp_comp(r,"labor",t)$(luc(r)=0)  = sum((i,v),      pl.l(r) * ld0_.l(r,i,v) * pld0(r,i))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"cap_new",t)$(luc(r)=0)= sum((k,i),      rk.l(r,k) * kd0_.l(r,k,i,"new") * pkd0(r,k,i))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"cap_ex",t)$(luc(r)=0) = sum((k,i),      rkx.l(r,k,i) * kd0_.l(r,k,i,"extant") * pkd0(r,k,i))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"cap_hk",t)$(luc(r)=0) = sum((i,v),      phk.l(r) * hkd0_.l(r,i,v) * phkd0(r,i))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"land",t)$(luc(r)=0)   = sum((i,v),      plnd.l(r,i) * lnd0_.l(r,i,v))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"ff_res",t)$(luc(r)=0) = sum((i,v),      pr.l(r,i) * rd0_.l(r,i,v))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"rnw",t)$(luc(r)=0)    = sum((i,v),      prnw.l(r,i) * rnw0_.l(r,i,v))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"tax_y",t)$(luc(r)=0)  = sum((i,v),      ty(r,i) * (y0_.l(r,i,v)+y00_.l(r,i,v)))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"tax_en",t)$(luc(r)=0) = sum((e,use,i,v),te(r,e,use,i) * eds(r,e,use,i,v,t))/pc.l(r,"hh")/deflator_R(r);

* Add natural land value (fixed value)
gdp_comp(r,"natlnd",t)$(luc(r)=0) = sum(nat,        rentv0(r,nat))/pc.l(r,"hh")/deflator_R(r);

gdp_comp(r,"labor",t)$luc(r)  = sum((i,v),       pl.l(r) * ld0_.l(r,i,v) * pld0(r,i))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"cap_new",t)$luc(r)= sum((k,i),       rk.l(r,k) * kd0_.l(r,k,i,"new") * pkd0(r,k,i))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"cap_ex",t)$luc(r) = sum((k,i),       rkx.l(r,k,i) * kd0_.l(r,k,i,"extant") * pkd0(r,k,i))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"cap_hk",t)$luc(r )= sum((i,v),       phk.l(r) * hkd0_.l(r,i,v) * phkd0(r,i))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"land",t)$luc(r)   = sum((i,v),       plnd.l(r,i) * lnd0_.l(r,i,v))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"ff_res",t)$luc(r) = sum((i,v),       pr.l(r,i) * rd0_.l(r,i,v))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"rnw",t)$luc(r)    = sum((i,v),       prnw.l(r,i) * rnw0_.l(r,i,v))/pc.l(r,"hh")/deflator_R(r);
gdp_comp(r,"tax_y",t)$luc(r)  = sum((i,v),       ty(r,i) * (y0_.l(r,i,v)+y00_.l(r,i,v)))/pc.l(r,"hh")/deflator_R(r);

gdp_comp(r,"tax_en",t)$luc(r) = sum((e,use,i,v), te(r,e,use,i) * eds(r,e,use,i,v,t))/pc.l(r,"hh")/deflator_R(r);

* Add natural land value (fixed value)
gdp_comp(r,"natlnd",t)$luc(r) = (  sum(nat,      plrent.l(r,nat)*rentv(r,nat))
                                 + sum((nat,v),  plff.l(r,nat)*fffor(r,nat,v)))/pc.l(r,"hh")/deflator_R(r);

gdp_comp(r,"gdp",t) =  gdp_(r,t);

gdp_shr(r,"labor",t)  =   gdp_comp(r,"labor",t)  /gdp_(r,t);
gdp_shr(r,"cap_new",t)=   gdp_comp(r,"cap_new",t)/gdp_(r,t);
gdp_shr(r,"cap_ex",t) =   gdp_comp(r,"cap_ex",t) /gdp_(r,t);
gdp_shr(r,"cap_hk",t) =   gdp_comp(r,"cap_hk",t) /gdp_(r,t);
gdp_shr(r,"land",t)   =   gdp_comp(r,"land",t)   /gdp_(r,t);
gdp_shr(r,"ff_res",t) =   gdp_comp(r,"ff_res",t) /gdp_(r,t);
gdp_shr(r,"rnw",t)    =   gdp_comp(r,"rnw",t)    /gdp_(r,t);
gdp_shr(r,"tax_y",t)  =   gdp_comp(r,"tax_y",t)  /gdp_(r,t);
gdp_shr(r,"tax_en",t) =   gdp_comp(r,"tax_en",t) /gdp_(r,t);
gdp_shr(r,"natlnd",t) =   gdp_comp(r,"natlnd",t) /gdp_(r,t);


**Report macro variables such as consumption, investment, government expenditure, import and export ($billion)
macro(r,"CONS",t)          = sum(hh, pc.l(r,hh) * c0_.l(r,hh)) / pc.l(r,"hh")/deflator_R(r) ;
macro(r,"INVEST",t)        = sum(k, pinv.l(r,k) * inv.l(r,k) * inv0(r,k)) / pc.l(r,"hh")/deflator_R(r);
macro(r,"GOVT",t)          = pg.l(r) * gov.l(r) * gov0(r) / pc.l(r,"hh")/deflator_R(r);
macro(r,"EXPORTS",t)       = sum(i, py.l(r,i) * sum(rr,n0_.l(rr,r,i)) ) / pc.l(r,"hh")/deflator_R(r);
macro(r,"IMPORTS",t)       = sum(i, pm.l(r,i) * m0_.l(r,i) ) / pc.l(r,"hh")/deflator_R(r);

**Check balance of sectoral production, consumption, import and export ($billion)
chk_macro(r,g,"y0",t)       =  sum(v,(y0_.l(r,g,v)+y00_.l(r,g,v)))*py.l(r,g)/deflator_R(r);
chk_macro(r,g,"a0",t)       =  a0_.l(r,g)*pa.l(r,g)/deflator_R(r);
chk_macro(r,g,"x0",t)       =  sum(rr,n0_.l(rr,r,g))*py.l(r,g)/deflator_R(r);
chk_macro(r,g,"m0",t)       =  m0_.l(r,g)*pm.l(r,g)/deflator_R(r);

chk_macro(r,g,"bal",t)
    =   chk_macro(r,g,"y0",t)  + chk_macro(r,g,"m0",t)
     - (chk_macro(r,g,"a0",t)  + chk_macro(r,g,"x0",t) ) ;

chk_macro(r,g,"bal",t) = round(chk_macro(r,g,"bal",t), 5);

* Expenditure approach to calculate GDP
gdp_sec(r,i,t)$(not liv(i) and not hh(i))
              =  sum(v,        (y0_.l(r,i,v)+y00_.l(r,i,v)))*py.l(r,i)*(1-ty(r,i))
               - sum((v,g),    id0_.l(r,g,i,v)*pa.l(r,g)*pid0(r,g,i))
               - sum((v,e,use),eds(r,e,use,i,v,t)*ped.l(r,e,use,i));

gdp_sec(r,"liv",t)
              =   sum(v,    y0_.l(r,"liv",v))*py.l(r,"liv")*(1-ty(r,"liv"))
                - sum((v,g)$(not (feed(g) or ofd(g))), id0_.l(r,g,"liv",v)*pa.l(r,g)*pid0(r,g,"liv"))
                - sum(v,    pfeed.l(r,"liv")*feed0_y.l(r,"liv",v))
                - sum((v,e,use), eds(r,e,use,"Liv",v,t)*ped.l(r,e,use,"liv"));

gdp_sec(r,"ele",t)
              =   (sum((v,gentype), y0_.l(r,gentype,v))+ sum(v,y00_.l(r,"ele",v)))*py.l(r,"ele")
                - sum((v,g,gentype), id0_.l(r,g,gentype,v)*pa.l(r,g)*pid0(r,g,gentype))
                - sum((v,e,use,gentype), eds(r,e,use,gentype,v,t)*ped.l(r,e,use,gentype));
gdp_sec(r,gentype,t) = 0;

gdp_sec(r,ad,t)
             =    sum((i,v), eds(r,ad,"fuel",i,v,t)*ped.l(r,ad,"fuel",i))
                - sum((v,g),id0_.l(r,g,ad,v)*pa.l(r,g) )
                - sum((v,e,use), eds(r,e,use,ad,v,t)*ped.l(r,e,use,ad));

* Calculate sectoral GDP from AFV and OEV
gdp_sec(r,afv,t)$sum(v,f_afv(r,afv,v))
            =  sum((maptrn(i,afv),v), y0_.l(r,afv,v)*py.l(r,i)*(1-ty(r,i)) )
                     - sum((v,g),    id0_.l(r,g,afv,v)*pa.l(r,g)*pid0(r,g,afv))
                     - sum((v,e,use),eds(r,e,use,afv,v,t)*ped.l(r,e,use,afv));
gdp_sec(r,oev,t) = sum(mapoev(oev,i), gdp_sec(r,i,t));

gdp_sec(r,nat,t)= sum(v,dfl.l(r,nat,v)*plrent.l(r,nat)) ;

gdp_sec(r,"house",t)
            =   sum(v, house0_.l(r,"hh",v)*phous.l(r,"hh"))
              - sum((e,hous,v),eds(r,e,hous,"hh",v,t)*ped.l(r,e,hous,"hh"));

gdp_sec(r,"total",t)    = sum(i, gdp_sec(r,i,t));
gdp_sec(r,j,t)$trnv(j)  = sum(maptrn(j,i), gdp_sec(r,i,t));
gdp_sec(r,"advb",t)     = sum(ad,gdp_sec(r,ad,t));
gdp_sec(r,"ethl",t)     = sum(ethl,gdp_sec(r,ethl,t));
gdp_sec(r,"biod",t)     = sum(biod,gdp_sec(r,biod,t));
gdp_sec(r,"crop",t)     = sum(crp,gdp_sec(r,crp,t));
gdp_sec(r,"agri",t)     = gdp_sec(r,"crop",t) + gdp_sec(r,"liv",t)  + gdp_sec(r,"frs",t);
gdp_sec(r,"biofuel",t)  = gdp_sec(r,"advb",t) + gdp_sec(r,"ethl",t) + gdp_sec(r,"biod",t);

* Income approach to calculate sectoral GDP
gdp_sec2(r,i,t)
 = ( sum(v,             pl.l(r) * ld0_.l(r,i,v) * pld0(r,i))
    + sum(k,            rk.l(r,k) * kd0_.l(r,k,i,"new") * pkd0(r,k,i))
    + sum(k,            rkx.l(r,k,i) * kd0_.l(r,k,i,"extant") * pkd0(r,k,i))
    + sum(v,            phk.l(r) * hkd0_.l(r,i,v) * phkd0(r,i))
    + sum(v,            plnd.l(r,i) * lnd0_.l(r,i,v))
    + sum(v,            pr.l(r,i) * rd0_.l(r,i,v))
    + sum(v,            prnw.l(r,i) * rnw0_.l(r,i,v))
    + sum(v,            ty(r,i) * (y0_.l(r,i,v)+y00_.l(r,i,v)))
    + sum((e,use,v),    te(r,e,use,i) * eds(r,e,use,i,v,t))
    ) / pc.l(r,"hh")
      /deflator_R(r) ;

gdp_sec2(r,oev,t) = sum(mapoev(oev,i), gdp_sec2(r,i,t));
gdp_sec2(r,afv,t)$sum(v,f_afv(r,afv,v))
 = ( sum(v,             pl.l(r) * ld0_.l(r,afv,v) * pld0(r,afv))
    + sum((k,v),        rk.l(r,k) * kd0_.l(r,k,afv,v) * pkd0(r,k,afv))
    + sum(v,            phk.l(r) * hkd0_.l(r,afv,v) * phkd0(r,afv))
    + sum(v,            ty(r,afv) * y0_.l(r,afv,v))
    + sum((e,use,v),    te(r,e,use,afv) * eds(r,e,use,afv,v,t))
    ) / pc.l(r,"hh")
      /deflator_R(r) ;

gdp_sec2(r,nat,t)
    =(             plrent.l(r,nat)*rentv(r,nat)
      + sum(v,     plff.l(r,nat)*fffor(r,nat,v))
     ) / pc.l(r,"hh")
      /deflator_R(r) ;

gdp_sec2(r,"total",t)   = sum(i,  gdp_sec2(r,i,t));
gdp_sec2(r,j,t)$trnv(j) = sum(maptrn(j,i), gdp_sec2(r,i,t));
gdp_sec2(r,"ele",t)     = sum(gentype,gdp_sec2(r,gentype,t));
gdp_sec2(r,"house",t)   = gdp_sec2(r,"hh",t);
gdp_sec2(r,"hh",t)      = 0;

**re2: Report sectoral output for ag, bio, energy and transportation ($billion)
output(r,i,t)              = sum(v,(y0_.l(r,i,v)+y00_.l(r,i,v)));
output(r,agrbio,t)         = sum(v, (y0_.l(r,agrbio,v)+y00_.l(r,agrbio,v)));
output(r,e,t)              = sum(v, y0_.l(r,e,v));
output(r,'ele',t)          = sum((v,gentype), y0_.l(r,gentype,v))+sum(v,y00_.l(r,"ele",v));
output(r,'ethl',t)         = sum((v,ethl), y0_.l(r,ethl,v));
output(r,'biod',t)         = sum((v,biod), y0_.l(r,biod,v));
output(r,ad,t)             = sum((i,v), eds(r,ad,"fuel",i,v,t));
output(r,'advb',t)         = sum(ad, output(r,ad,t));
output(r,afv,t)$sum(v,f_afv(r,afv,v))
                           = sum(v,y0_.l(r,afv,v));
output(r,'house',t)        = sum(v,house0_.l(r,"hh",v));

output(r,OEV,t)            = sum(mapoev(oev,i),output(r,i,t));
output(r,j,t)$trnv(j)      = sum(maptrn(j,i),output(r,i,t));

**re3: Report sectoral price index
prices(r,i,"py",t)$output(r,i,t)   = py.l(r,i);
prices(r,e,"py",t)$advbio(e)       = ped.l(r,e,"fuel","auto") ;
prices(r,"house","py",t)= phous.l(r,"hh");

prices(r,i,"pa",t)      = pa.l(r,i);
prices(r,"cru","pa",t)  = PCRU.L;
prices(r,"house","pa",t)= phous.l(r,"hh");
prices(r,i,"pa",t)$sameas(i,"cobd")  = py.l(r,i);

prices(r,g,"px",t)=py.l(r,g);
prices(r,e,"px",t)=py.l(r,e);
prices(r,g,"pm",t)=pm.l(r,g);
prices(r,e,"pm",t)=pm.l(r,e);
prices(r,"cru","px",t)=PCRU.L;
prices(r,"cru","pm",t)=PCRU.L;


prices(r,e,"ped",t)$sum((use,i,v)$(not fdst(use)), eds(r,e,use,i,v,t))
        = sum((use,i,v)$(not fdst(use) and eds(r,e,use,i,v,t)), (ped.l(r,e,use,i)+pa.l(r,e)$(ped.l(r,e,use,i)=0)) * eds(r,e,use,i,v,t))
        / sum((use,i,v)$(not fdst(use) and eds(r,e,use,i,v,t)), eds(r,e,use,i,v,t));

prices(r,e,"ped",t)$(bioe(e) or ad(e))
        = ped.l(r,e,"fuel","auto") ;

prices(r,i,"ped",t)$sameas(i,"cobd") = py.l(r,i);


prices(r,"avg","pl",t)$sum((i,v), ld0_.l(r,i,v))          =  pl.l(r) ;
prices(r,k,"rk",t)$sum((i,v)$new(v), kd0_.l(r,k,i,v))     =  rk.l(r,k);
prices(r,k,"rkx",t)$sum((i,v)$extant(v), kd0_.l(r,k,i,v)) = sum((i,v)$extant(v), rkx.l(r,k,i)* kd0_.l(r,k,i,v)) / sum((i,v)$extant(v), kd0_.l(r,k,i,v));

prices(r,"avg","phk",t)$sum((i,v), hkd0_.l(r,i,v))    = phk.l(r)  ;
prices(r,agr,"plnd",t)$sum(v, lnd0_.l(r,agr,v))       = plnd.l(r,agr) ;
prices(r,"crop","plnd",t) = plnd.l(r,"crop");
prices(r,lu,"plnd",t)$luc(r) = plrent.l(r,lu);
prices(r,"pco2","avg",t)    = pco2.l(r) ;
prices(r,"pghg","avg",t)    = pghg.l(r,"n2O") ;

prices_kt(r,k,"avg",v,t)$(new(v) )    = rk.l(r,k) ;
prices_kt(r,k,"avg",v,t)$(extant(v) and sum(i, kd0_.l(r,k,i,v))) = sum(i, rkx.l(r,k,i)* kd0_.l(r,k,i,v)) / sum(i, kd0_.l(r,k,i,v));
prices_kt(r,k,i,v,t)$(extant(v) and kd0_.l(r,k,i,v)) = rkx.l(r,k,i) ;
prices_kt(r,k,i,v,t)$OEV(i)  = sum(mapoev(i,j), prices_kt(r,k,j,v,t));
prices_kt(r,k,i,v,t)$(prices_kt(r,k,i,v,t) and trnv(i)) = 0;

prices_kt_pc(r,k,i,v,t)     = prices_kt(r,k,i,v,t)/pc.l(r,"hh");
prices_kt_pc(r,k,"avg",v,t) = prices_kt(r,k,"avg",v,t)/pc.l(r,"hh");

* retail fuel price
prices_fuel(r,e,i,t)$(trnv(i) and btu_conv(r,e,"fuel",i))=  1/btu_conv(r,e,"fuel",i)*ped.l(r,e,"fuel",i);
prices_fuel(r,e,i,t)$(trnv(i) and btu_conv(r,e,"fuel",i) and prices_fuel(r,e,i,t)=0)=  1/btu_conv(r,e,"fuel",i)*pedm.l(r,e);
prices_fuel(r,e,i,t)$(trnv(i) and btu_conv(r,e,"fuel",i) and prices_fuel(r,e,i,t)=0)=  1/btu_conv(r,e,"fuel",i)*pa.l(r,e);
prices_en(r,e,use,i,t)$btu_conv(r,e,use,i) = 1/btu_conv(r,e,use,i)*ped.l(r,e,use,i);
prices_en(r,e,"fuel",i,t)$prices_fuel(r,e,i,t) = prices_fuel(r,e,i,t);

prices_fuel_pc(r,e,i,t) = prices_fuel(r,e,i,t)/pc.l(r,"hh");

*prices adjusted by consumption price index
prices_pc(r,i,"py",t)      = prices(r,i,"py",t) / pc.l(r,"hh");
prices_pc(r,i,"pa",t)      = prices(r,i,"pa",t) / pc.l(r,"hh");
prices_pc(r,i,"px",t)      = prices(r,i,"px",t) / pc.l(r,"hh");
prices_pc(r,i,"pm",t)      = prices(r,i,"pm",t) / pc.l(r,"hh");
prices_pc(r,i,"ped",t)     = prices(r,i,"ped",t)/ pc.l(r,"hh");
prices_pc(r,"avg","pl",t)  = prices(r,"avg","pl",t)/ pc.l(r,"hh");
prices_pc(r,k,"rk",t)      = prices(r,k,"rk",t)/ pc.l(r,"hh");
prices_pc(r,k,"rkx",t)     = prices(r,k,"rk",t)/ pc.l(r,"hh");
prices_pc(r,"avg","phk",t) = prices(r,"avg","phk",t)  / pc.l(r,"hh") ;
prices_pc(r,agr,"plnd",t)  = prices(r,agr,"plnd",t)/ pc.l(r,"hh") ;
prices_pc(r,"crop","plnd",t) = prices(r,"crop","plnd",t) / pc.l(r,"hh");
prices_pc(r,lu,"plnd",t)     = prices_pc(r,lu,"plnd",t)/ pc.l(r,"hh");
prices_pc(r,"pco2","avg",t)  = prices(r,"pco2","avg",t) / pc.l(r,"hh") ;
prices_pc(r,"pghg","avg",t)  = prices(r,"pghg","avg",t) / pc.l(r,"hh");

price(r,i,"py_pc",t) = prices_pc(r,i,"py",t);
price(r,i,"pa_pc",t) = prices_pc(r,i,"pa",t);
price(r,i,"ped_pc",t)= prices_pc(r,i,"ped",t);
price(r,i,"px_pc",t) = prices_pc(r,i,"px",t);
price(r,i,"pm_pc",t) = prices_pc(r,i,"pm",t);

*Household consumption and price
cons(r,i,t)=cd0_.l(r,"hh",i);
cons_p(r,i,t)$cons(r,i,t)=pa.l(r,i)*(1+tc(r,i))/pc.l(r,"hh");

cons_all(r,i,t)$a0(r,i) = a0_.l(r,i);
cons_allp(r,i,t)$a0(r,i)= pa.l(r,i)/pc.l(r,"hh");

cons_alls(r,g,i,t) = sum(v,id0_.l(r,g,i,v));
cons_alls(r,g,i,t)$feed0_y.l(r,i,"new") = sum(v,feed0_a.l(r,g,i,v));
cons_alls(r,"ddgs",i,t)$feed0_y.l(r,i,"new") = sum(v,feed0_ddgs.l(r,"ddgs",i,v));
cons_alls(r,"omel",i,t)$feed0_y.l(r,i,"new") = sum(v,feed0_omel.l(r,"omel",i,v));

**re4: Report energy sectoral demand and production and ghg emission
*  energy demand ($billion)
en_valus(r,e,use,i,t)           = sum(v, eds(r,e,use,i,v,t));
en_valus(r,e,use,"lu",t)$luc(r) = sum(v, eds(r,e,use,"lu",v,t));
en_valus(r,e,use,"all",t)       = sum((v,i)$(not trnv(i)), eds(r,e,use,i,v,t))+ en_valus(r,e,use,"lu",t)$luc(r);
en_valus(r,e,use,"House",t)     = en_valus(r,e,use,"HH",t);
en_valus(r,e,use,"HH",t)        = 0;

en_valu(r,e,i,t)                = sum(use, en_valus(r,e,use,i,t)) ;
en_valu(r,e,"lu",t)$(luc(r))    = sum(use, en_valus(r,e,use,"lu",t));
en_valu(r,e,"all",t)            = sum(use, en_valus(r,e,use,"all",t));

*Energy demand (quad btu)
en_btusv(r,e,use,i,v,t)            = eds(r,e,use,i,v,t) * BTU_conv(r,e,use,i);
en_btusv(r,e,use,i,v,t)$afv(i)     = eds(r,e,use,i,v,t) * BTU_conv(r,e,use,i);
en_btusv(r,e,use,i,v,t)$advbio(e)  = en_btusv(r,e,use,i,v,t)/advbiomkup(r,e);
en_btusv(r,e,use,"lu",v,t)$luc(r)  = sum((g,lu,lu_),lnd_ed0_.l(r,e,use,g,lu,lu_,v)* BTU_conv(r,e,use,g));
en_btusv(r,e,use,"House",v,t)      = en_btusv(r,e,use,"HH",v,t);
en_btusv(r,e,use,"HH",v,t)         = 0;
en_btusv(r,e,use,"all",v,t)        = sum(i$(not trnv(i)),en_btusv(r,e,use,i,v,t)) + en_btusv(r,e,use,"lu",v,t)$luc(r);
en_btusv(r,e,use,i,v,t)$trnv(i)    = sum(maptrn(i,j),en_btusv(r,e,use,j,v,t));


en_btus(r,e,use,i,t)            = ed(r,e,use,i,t) * BTU_conv(r,e,use,i);
en_btus(r,e,use,i,t)$afv(i)     = ed(r,e,use,i,t) * BTU_conv(r,e,use,i);
en_btus(r,e,use,i,t)$advbio(e)  = en_btus(r,e,use,i,t)/advbiomkup(r,e);
en_btus(r,e,use,"lu",t)$luc(r)  = sum((g,lu,lu_,v),lnd_ed0_.l(r,e,use,g,lu,lu_,v)* BTU_conv(r,e,use,g));
en_btus(r,e,use,"House",t)      = en_btus(r,e,use,"HH",t);
en_btus(r,e,use,"HH",t)         = 0;
en_btus(r,e,use,"all",t)        = sum(i$(not trnv(i)),en_btus(r,e,use,i,t)) + en_btus(r,e,use,"lu",t)$luc(r);
en_btus(r,e,use,i,t)$trnv(i)    = sum(maptrn(i,j),en_btus(r,e,use,j,t));

en_btu(r,e,i,t)                  = sum((use,v),en_btusv(r,e,use,i,v,t));
en_btu(r,e,"lu",t)               = sum((use,v),en_btusv(r,e,use,"lu",v,t));
en_btu(r,e,"all",t)              = sum((use,v),en_btusv(r,e,use,"all",v,t));

*Co2 emissions from fossil fuel usage (mmt co2eq)
co2t_ff(r,e,use,i,t)  $(not fdst(use) )               = co2_btu(r,e) * sum(v,eds(r,e,use,i,v,t) * BTU_conv(r,e,use,i)) ;
co2t_ff(r,e,use,i,t)  $(not fdst(use) and advbio(e))  = co2_btu(r,e) * sum(v,eds(r,e,use,i,v,t) * BTU_conv(r,e,use,i)/advbiomkup(r,e)) ;
co2t_ff(r,e,use,i,t)$(not fdst(use) and afv(i) )      = co2_btu(r,e) * sum(v,eds(r,e,use,i,v,t) * BTU_conv(r,e,use,i))  ;
co2t_ff(r,e,use,"lu",t)$(luc(r) )                     = co2_btu(r,e) *sum((g,lu,lu_,v),lnd_ed0_.l(r,e,use,g,lu,lu_,v) * BTU_conv(r,e,use,g))  ;
co2t_ff(r,e,use,"house",t)  = co2t_ff(r,e,use,"hh",t);
co2t_ff(r,e,use,"hh",t)     = 0;

* For Auto, Rodf, and RodP, they are accounted by their OEV and AFVs
co2tot_ff(r,e,t)            = sum((use,i)$(not trnv(i)), co2t_ff(r,e,use,i,t))+ sum(use,co2t_ff(r,e,use,"lu",t))$luc(r);
co2tott_ff(r,t)             = sum(e, co2tot_ff(r,e,t) );
co2elet(r,t)                = sum((e,gentype),co2t_ff(r,e,"fuel",gentype,t));

* Total electricity consumption from Armington block
*  This will be qual to sum of total electricity consumption from all users
ele_cons_all(r,"ele",t)   =  cons_all(r,"ele",t) * btua_conv(r,"ele") ;

**Electricity generation by type ($billion)
ele_valuV(r,gentype,v,t)  = y0_.l(r,gentype,v);
ele_valuV(r,"swge",v,t)   = y00_.l(r,"ele",v) ;

ele_valu(r,gentype,t)     = sum(v, y0_.l(r,gentype,v));
ele_valu(r,"swge",t)      = sum(v, y00_.l(r,"ele",v));
ele_valu(r,"total",t)     = sum(gentype,ele_valu(r,gentype,t)) + ele_valu(r,"swge",t);

**Electricity generation by type (quadbtu)
ele_btuV(r,gentype,v,t)   =  y0_.l(r,gentype,v)*btuprod_conv(r,gentype);
ele_btuV(r,"swge",v,t)    =  y00_.l(r,"ele",v)*btuprod_conv(r,"ele")   ;
ele_btuV(r,"total",v,t)     = sum(gentype,ele_btuV(r,gentype,v,t)) + ele_btuV(r,"swge",v,t);

ele_btu(r,gentype,t)      = sum(v, y0_.l(r,gentype,v))*btuprod_conv(r,gentype);
ele_btu(r,"swge",t)       = sum(v, y00_.l(r,"ele",v))*btuprod_conv(r,"ele") ;
ele_btu(r,"total",t)      = sum(gentype,ele_btu(r,gentype,t)) + ele_btu(r,"swge",t);

* Due to Armington assumption on electricity and their technology, the physical quantity needs to be scaled to maintain supply-demand balance
ele_btu(r,i,t)            =  ele_btu(r,i,t)    * ele_cons_all(r,"ele",t) /ele_btu(r,"total",t) ;
ele_btu(r,"total",t)      = sum(i,ele_btu(r,i,t)) ;

ele_btuV(r,i,v,t)$ele_btuV(r,i,v,t)   = ele_btuV(r,i,v,t) *ele_cons_all(r,"ele",t) /sum(vv,ele_btuV(r,"total",vv,t));
ele_btuV(r,"total",v,t)               = sum(i,ele_btuV(r,i,v,t));

**Electricity generation by fuel (quadbtu)
elesource(r,e,t)        = sum(elefuelmap(e,gentype),ele_btu(r,gentype,t));
elesource(r,rnw,t)      = ele_btu(r,rnw,t);
elesource(r,"swge",t)   = ele_btu(r,"swge",t);
elesource(r,"total",t)  = sum(i,elesource(r,i,t)) ;

ele_btubyage(r,i,"new",t,t)         = ele_btuV(r,i,"new",t);
ele_btubyage(r,i,"extant",t,t)      = ele_btuV(r,i,"extant",t);

ele_btubyage(r,i,"extant",t,t+1)    = ele_btuV(r,i,"new",t);
ele_btubyage(r,i,"extant",t,t+2)    = ele_btuV(r,i,"new",t);
ele_btubyage(r,i,"extant",t,t+3)    = ele_btuV(r,i,"new",t);
ele_btubyage(r,i,"extant",t,t+4)    = ele_btuV(r,i,"new",t);
ele_btubyage(r,i,"extant",t,t+5)    = ele_btuV(r,i,"new",t);

ele_btubyage(r,i,"extant",t,t)$(t.val=2010) = ele_btuV(r,i,"extant",t)*5/5;
ele_btubyage(r,i,"his",t,t+1)$(t.val=2010)  = ele_btuV(r,i,"extant",t)*4/5;
ele_btubyage(r,i,"his",t,t+2)$(t.val=2010)  = ele_btuV(r,i,"extant",t)*3/5;
ele_btubyage(r,i,"his",t,t+3)$(t.val=2010)  = ele_btuV(r,i,"extant",t)*2/5;
ele_btubyage(r,i,"his",t,t+4)$(t.val=2010)  = ele_btuV(r,i,"extant",t)*1/5;


* VMT in t+1 period
ele_btubyage(r,i,"extant","tot",t+1)=   sum(tt,ele_btubyage(r,i,"extant",tt,t+1))
                                      + ele_btubyage(r,i,"his","2010",t+1);

*Share of Transportation VMT traveled by vintage for the next period
ele_btushrV(r,i,"extant",tt,t+1)$ele_btubyage(r,i,"extant","tot",t+1)   = ele_btubyage(r,i,"extant",tt,t+1)/ele_btubyage(r,i,"extant","tot",t+1);
ele_btushrV(r,i,"his","2010",t+1)$ele_btubyage(r,i,"extant","tot",t+1)  = ele_btubyage(r,i,"his","2010",t+1)/ele_btubyage(r,i,"extant","tot",t+1);

ele_btushrV(r,i,"extant",tt,t+1)$(ele_btubyage(r,i,"extant","tot",t+1)=0 and tt.val<=t.val and tt.val>=t.val-5)
                            = 0;

ket(r,k,i,v,t)                                   = kd0_.l(r,k,i,v)    ;
ele_ketbyage(r,k,i,v,t,t)$(gentype(i) )          = ket(r,k,i,v,t)     ;
ele_ketbyage(r,k,i,"extant",t,t+1)$(gentype(i))  = ket(r,k,i,"new",t) ;
ele_ketbyage(r,k,i,"extant",t,t+2)$(gentype(i))  = ket(r,k,i,"new",t) ;
ele_ketbyage(r,k,i,"extant",t,t+3)$(gentype(i))  = ket(r,k,i,"new",t) ;
ele_ketbyage(r,k,i,"extant",t,t+4)$(gentype(i))  = ket(r,k,i,"new",t) ;
ele_ketbyage(r,k,i,"extant",t,t+5)$(gentype(i))  = ket(r,k,i,"new",t) ;

ele_ketbyage(r,k,i,"his",t,t)$(gentype(i) and t.val=2010  )    = ket(r,k,i,"extant",t)*5/5;
ele_ketbyage(r,k,i,"his",t,t+1)$(gentype(i) and t.val=2010  )  = ket(r,k,i,"extant",t)*4/5;
ele_ketbyage(r,k,i,"his",t,t+2)$(gentype(i) and t.val=2010  )  = ket(r,k,i,"extant",t)*3/5;
ele_ketbyage(r,k,i,"his",t,t+3)$(gentype(i) and t.val=2010  )  = ket(r,k,i,"extant",t)*2/5;
ele_ketbyage(r,k,i,"his",t,t+4)$(gentype(i) and t.val=2010  )  = ket(r,k,i,"extant",t)*1/5;

ele_ketbyage(r,k,i,"extant","tot",t+1)$(gentype(i))  =   sum(tt$(tt.val<(t.val+5)),ele_ketbyage(r,k,i,"extant",tt,t+1))
                                                       + ele_ketbyage(r,k,i,"his","2010",t+1);
display ele_btu, elesource;
** Report domestic energy production
* unit: $billion
enprod_valu(r,e,t)        = output(r,e,t);

*unit: quad btu
enprod_btu(r,e,t)          = output(r,e,t)*btuprod_conv(r,e);
enprod_btu(r,e,t)$advbio(e)= output(r,e,t)*btuprod_conv(r,e)/advbiomkup(r,e);
enprod_btu(r,e,t)$ele(e)   = ele_cons_all(r,e,t);

** Report trade for energy ($billion)
entrd_valu(r,e,"import",t) = m0_.l(r,e);
entrd_valu(r,e,"export",t) = sum(rr,n0_.l(rr,r,e));

entrd_valu(r,"cru","import",t)$(en_valu(r,"cru","all",t)>= enprod_valu(r,"cru",t)) = en_valu(r,"cru","all",t)-enprod_valu(r,"cru",t);
entrd_valu(r,"cru","export",t)$(en_valu(r,"cru","all",t)>= enprod_valu(r,"cru",t)) = 0;
entrd_valu(r,"cru","import",t)$(en_valu(r,"cru","all",t)< enprod_valu(r,"cru",t))  = 0;
entrd_valu(r,"cru","export",t)$(en_valu(r,"cru","all",t)< enprod_valu(r,"cru",t))  = enprod_valu(r,"cru",t)- en_valu(r,"cru","all",t);
entrd_valu(r,e,"nettrd",t) =  entrd_valu(r,e,"export",t)- entrd_valu(r,e,"import",t);

** Report trade for energy (quad btu)
entrd_btu(r,e,"import",t)  = m0_.l(r,e)*btuim_conv(r,e);
entrd_btu(r,e,"export",t)  = sum(rr,n0_.l(rr,r,e))*btuex_conv(r,e);

entrd_btu(r,"cru","import",t)$(en_btu(r,"cru","all",t)>= enprod_btu(r,"cru",t)) = en_btu(r,"cru","all",t)-enprod_btu(r,"cru",t);
entrd_btu(r,"cru","export",t)$(en_btu(r,"cru","all",t)>= enprod_btu(r,"cru",t)) = 0;
entrd_btu(r,"cru","import",t)$(en_btu(r,"cru","all",t)< enprod_btu(r,"cru",t))  = 0;
entrd_btu(r,"cru","export",t)$(en_btu(r,"cru","all",t)< enprod_btu(r,"cru",t))  = enprod_btu(r,"cru",t)- en_btu(r,"cru","all",t);

entrd_btu(r,e,"nettrd",t) =  entrd_btu(r,e,"export",t) - entrd_btu(r,e,"import",t);

* Check energy supply/demand balance and if not balanced, re-balance it
chk_enbalt(r,e,"Production",t) = enprod_btu(r,e,t);
chk_enbalt(r,e,"Consumption",t)= en_btu(r,e,"all",t);
chk_enbalt(r,e,"Import",t)     = entrd_btu(r,e,"import",t);
chk_enbalt(r,e,"Export",t)     = entrd_btu(r,e,"export",t);
chk_enbalt(r,e,"balance",t)    = round((    chk_enbalt(r,e,"Production",t)
                                          + chk_enbalt(r,e,"Import",t)
                                          - chk_enbalt(r,e,"Consumption",t)
                                          - chk_enbalt(r,e,"Export",t) ),6) ;

entrd_btu(r,e,"import",t)$(chk_enbalt(r,e,"balance",t)>=0 and chk_enbalt(r,e,"Import",t)>=chk_enbalt(r,e,"balance",t))
       = chk_enbalt(r,e,"Import",t)-chk_enbalt(r,e,"balance",t);
entrd_btu(r,e,"export",t)$(chk_enbalt(r,e,"balance",t)>=0 and chk_enbalt(r,e,"Import",t)<chk_enbalt(r,e,"balance",t) and chk_enbalt(r,e,"Export",t)>0)
       = chk_enbalt(r,e,"Export",t)+chk_enbalt(r,e,"balance",t);
enprod_btu(r,e,t)$(chk_enbalt(r,e,"balance",t)>=0 and chk_enbalt(r,e,"Import",t)<chk_enbalt(r,e,"balance",t) and chk_enbalt(r,e,"Export",t)=0)
       = chk_enbalt(r,e,"Production",t) - chk_enbalt(r,e,"balance",t);

entrd_btu(r,e,"import",t)$(chk_enbalt(r,e,"balance",t)<0 and chk_enbalt(r,e,"Import",t)>0)
       = chk_enbalt(r,e,"Import",t)- chk_enbalt(r,e,"balance",t);
entrd_btu(r,e,"export",t)$(chk_enbalt(r,e,"balance",t)<0 and chk_enbalt(r,e,"Import",t)=0 and (chk_enbalt(r,e,"Export",t)+chk_enbalt(r,e,"balance",t))>=0)
       = chk_enbalt(r,e,"Export",t)+chk_enbalt(r,e,"balance",t);
enprod_btu(r,e,t)$(chk_enbalt(r,e,"balance",t)<0 and chk_enbalt(r,e,"Import",t)=0 and (chk_enbalt(r,e,"Export",t)+chk_enbalt(r,e,"balance",t))<0)
       = chk_enbalt(r,e,"Production",t) - chk_enbalt(r,e,"balance",t);

display "cai", chk_enbalt;

chk_enbalt("world",e,balvar,t)=0;
chk_enbalt(r,e,"Production",t) = enprod_btu(r,e,t);
chk_enbalt(r,e,"Consumption",t)= en_btu(r,e,"all",t);
chk_enbalt(r,e,"Import",t)     = entrd_btu(r,e,"import",t);
chk_enbalt(r,e,"Export",t)     = entrd_btu(r,e,"export",t);
chk_enbalt(r,e,"balance",t)    = round((    chk_enbalt(r,e,"Production",t)
                                          + chk_enbalt(r,e,"Import",t)
                                          - chk_enbalt(r,e,"Consumption",t)
                                          - chk_enbalt(r,e,"Export",t) ),6) ;
chk_enbalt("world",e,balvar,t)=sum(r, chk_enbalt(r,e,balvar,t));


**re5: Report trade for ag and bio and energy sectors ($billion)
trade(r,i,"import",t) = sum(rr,n0_.l(r,rr,i));
trade(rr,i,"export",t)= sum(r, n0_.l(r,rr,i));
trade(r,i,"nettrd",t) = trade(r,i,"export",t) - trade(r,i,"import",t);

** Report bilateral trade ($billion)
bi_trade(r,rr,i,t)         = n0_.l(r,rr,i);

** Report trade for auto energy sectors (billion gal)
entrd_gal(r,e,"import",t)       = gal_conv(r,e,"fuel","auto") * sum(rr,n0_.l(r,rr,e));
entrd_gal(rr,e,"export",t)      = gal_conv(rr,e,"fuel","auto") * sum(r, n0_.l(r,rr,e));
entrd_gal(r,e,"nettrd",t)       = entrd_gal(r,e,"export",t) - entrd_gal(r,e,"import",t) ;
entrd_gal(r,e,"export",t)       = gal_conv(r,e,"fuel","auto") * sum(rr,n0_.l(rr,r,e));

entrd_gal(r,e,"import",t)$advbio(e)   = gal_conv(r,e,"fuel","auto") * sum(rr,n0_.l(r,rr,e))/advbiomkup(r,e);
entrd_gal(rr,e,"export",t)$advbio(e)  = gal_conv(rr,e,"fuel","auto")* sum(r, n0_.l(r,rr,e))/advbiomkup(rr,e);
entrd_gal(r,e,"nettrd",t)$advbio(e)   = entrd_gal(r,e,"export",t) - entrd_gal(r,e,"import",t);
entrd_gal(r,e,"export",t)$advbio(e)   = gal_conv(r,e,"fuel","auto") * sum(rr,n0_.l(rr,r,e))/advbiomkup(r,e);


**re6: Report land value and area by type
*    Land value in $billion
*    Aggregate land into crp, liv, for and advanced cellulosic biofuel land

land_valu(r,i,t)                   = sum(v, lnd0_.l(r,i,v));
land_valu(r,lu,t)                  = sum(v, dfl.l(r,lu,v));
land_valu(r,"advb",t)              = sum((ad,v), lnd0_.l(r,ad,v));

**Report land area in million ha
* Method 1:
land_area0(r,lu,t)$(not luc(r))    = sum(v, dfl.l(r,lu,v))*ha_conv(r,lu)/npp(r,lu);
land_area0(r,nat,t)$(not luc(r))   = q_land0(r,nat);

land_area0(r,lu,t)$(luc(r) and p_land0(r,lu)*npp(r,lu) )
       = sum(v, dfl.l(r,lu,v)) /(p_land0(r,lu)*npp(r,lu));

* Consider the biofuel yield improvement
land_area0(r,crp,t)$(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v)))
       = land_area0(r,'crop',t)*sum(v,lnd0_.l(r,crp,v))
        /(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v)/bio_yldtrd(r,"swge",t)));

land_area0(r,ad,t)$(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v)/bio_yldtrd(r,"swge",t)))
       = land_area0(r,'crop',t)*sum(v,lnd0_.l(r,ad,v)/bio_yldtrd(r,"swge",t))
        /(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v)/bio_yldtrd(r,"swge",t)));

land_area0(r,"crop",t)      = sum(crp,land_area0(r,crp,t));
land_area0(r,"advb",t)      = sum(ad, land_area0(r,ad,t));
land_area0(r,'total',t)     = sum(lu, land_area0(r,lu,t))+ land_area0(r,"advb",t);
land_area0("total","advb",t)= sum((r,ad), land_area0(r,ad,t));
land_area0("total",lu,t)    = sum(r,  land_area0(r,lu,t));

*Method 2: provides same results as in method 1
land_area1(r,lu,t)$(not luc(r))    = sum(v, dfl.l(r,lu,v))*ha_conv(r,lu)/npp(r,lu);
land_area1(r,nat,t)$(not luc(r))   = q_land0(r,nat);

land_area1(r,lu,t)$(luc(r) and p_land0(r,lu)*npp(r,lu) )
       =  sum(v, dfl.l(r,lu,v)) /(p_land0(r,lu)*npp(r,lu));

land_area1(r,'crop',t) =   sum(lu,  q_land0(r,lu))
                        - sum(nat,land_area1(r,nat,t))
                        - land_area1(r,'liv',t)
                        - land_area1(r,'frs',t);

land_area1(r,crp,t)$(crp_lnd0(r,crp,"new") and npp(r,"crop"))
       = sum(v,lnd0_.l(r,crp,v))/crp_lnd0(r,crp,"new")*q_land0(r,crp)/npp(r,"crop");

land_area1(r,crp,t)$sum(crp0,land_area1(r,crp0,t))
       =land_area1(r,crp,t)*land_area0(r,"crop",t)/sum(crp0,land_area1(r,crp0,t));

land_area1(r,ad,t)$(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v)))
       = land_area1(r,'crop',t)*sum(v,lnd0_.l(r,ad,v))
        /(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v)));

land_area1(r,"crop",t)      = sum(crp,land_area1(r,crp,t));
land_area1(r,"advb",t)      = sum(ad, land_area1(r,ad,t));
land_area1(r,'total',t)     = sum(lu, land_area1(r,lu,t))+ land_area1(r,"advb",t);
land_area1("total","advb",t)= sum((r,ad), land_area1(r,ad,t));
land_area1("total",lu,t)    = sum(r,  land_area1(r,lu,t));

* Method 3: consider the markup cost in advanced biofuels
land_area(r,lu,t)$(not luc(r))    = sum(v, dfl.l(r,lu,v))*ha_conv(r,lu)/npp(r,lu);
land_area(r,nat,t)$(not luc(r))   = q_land0(r,nat);

land_area(r,lu,t)$(luc(r) and p_land0(r,lu)*npp(r,lu) )
       = sum(v, dfl.l(r,lu,v)) /(p_land0(r,lu)*npp(r,lu));

land_area(r,'crop',t) =   sum(lu,  q_land0(r,lu))
                         - sum(nat,land_area(r,nat,t))
                         - land_area(r,'liv',t)
                         - land_area(r,'frs',t);

land_area(r,crp,t)$(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v)) - sum((frwe,v),lnd0_.l(r,frwe,v)) )
       = land_area(r,'crop',t)*sum(v,lnd0_.l(r,crp,v))
        /(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v)) - sum((frwe,v),lnd0_.l(r,frwe,v)) );

land_area(r,ad,t)$(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v)) - sum((frwe,v),lnd0_.l(r,frwe,v)) and not frwe(ad))
       = land_area(r,'crop',t)*sum(v,lnd0_.l(r,ad,v))
        /(sum((v,crp0), lnd0_.l(r,crp0,v))+ sum((ad0,v),lnd0_.l(r,ad0,v))- sum((frwe,v),lnd0_.l(r,frwe,v)) );

land_area(r,"frwe",t)$(sum(v, lnd0_.l(r,"frs",v)) + sum(v,lnd0_.l(r,"frwe",v)) )
       = land_area(r,"frs",t)* sum(v,lnd0_.l(r,"frwe",v))
        /(sum(v, lnd0_.l(r,"frs",v)) + sum(v,lnd0_.l(r,"frwe",v)) );

land_area(r,"frs",t)$(sum(v, lnd0_.l(r,"frs",v)) + sum(v,lnd0_.l(r,"frwe",v)) )
       = land_area(r,"frs",t)* sum(v, lnd0_.l(r,"frs",v))
        /(sum(v, lnd0_.l(r,"frs",v)) + sum(v,lnd0_.l(r,"frwe",v)) );

land_area(r,"crop",t)      = sum(crp,land_area(r,crp,t));
land_area(r,"advb",t)      = sum(ad, land_area(r,ad,t));
land_area(r,'total',t)     = sum(lu, land_area(r,lu,t))+ land_area(r,"advb",t);
land_area("total","advb",t)= sum((r,ad), land_area(r,ad,t));
land_area("total",lu,t)    = sum(r,  land_area(r,lu,t));

land_rent(r,'crop',t)$(not luc(r)) = plnd.l(r,'crop')/pc.l(r,"hh");
land_rent(r,'liv',t)$(not luc(r))  = plnd.l(r,'liv')/pc.l(r,"hh");
land_rent(r,'frs',t)$(not luc(r))  = plnd.l(r,'frs')/pc.l(r,"hh");
land_rent(r,nat,t)$(not luc(r))    = 1;
land_rent(r,lu,t)$luc(r)           = plrent.l(r,lu)/pc.l(r,"hh");

**Report land conversion in million ha
land_tran(r,lu,lu_,t)$(luc(r) and f_luc(r,lu,lu_) and p_land0(r,lu)*npp(r,lu) )
    = sum(v,lnd_out.l(r,lu,lu_,v))/(p_land0(r,lu)*npp(r,lu))/5;

**Report land emission or sequestration (follow land_em3 and land _seq3 formula in EPPA5+)
land_em(r,lu,lu_,t)$(luc(r) and f_luc(r,lu,lu_) )
     = land_tran(r,lu,lu_,t)* debtcarb(r,lu,lu_);
land_seq(r,lu,lu_,t)$(luc(r) and f_luc(r,lu,lu_))
     = land_tran(r,lu,lu_,t)* credcarb(r,lu,lu_);

chk_lndem(r,lu,lu_,"area",t) =land_tran(r,lu,lu_,t);
chk_lndem(r,lu,lu_,"emis",t) =land_em(r,lu,lu_,t);
chk_lndem(r,lu,lu_,"seq",t)  =land_seq(r,lu,lu_,t);

**Summarize land use change reports
emis_rep(r,t,"tot",lu_,"tran")$luc(r)    = sum(lu, land_tran(r,lu,lu_,t));
emis_rep(r,t,"tot",lu_,"emiss")$luc(r)   = sum(lu, land_em(r,lu,lu_,t));
emis_rep(r,t,"tot",lu_,"sequ")$luc(r)    = sum(lu, land_seq(r,lu,lu_,t));
emis_rep(r,t,"tot",lu_,"L_em")$luc(r)    = emis_rep(r,t,"tot",lu_,"emiss") - emis_rep(r,t,"tot",lu_,"sequ");

emis_rep(r,t,"tot","tot","tran")$luc(r)  = sum(lu_, emis_rep(r,t,"tot",lu_,"tran"));
emis_rep(r,t,"tot","tot","emiss")$luc(r) = sum(lu_, emis_rep(r,t,"tot",lu_,"emiss"));
emis_rep(r,t,"tot","tot","sequ")$luc(r)  = sum(lu_, emis_rep(r,t,"tot",lu_,"sequ"));
emis_rep(r,t,"tot","tot","L_em")$luc(r)  = emis_rep(r,t,"tot","tot","emiss") - emis_rep(r,t,"tot","tot","sequ");

emis_rep("tot",t,"tot","tot","tran")  = sum(r, emis_rep(r,t,"tot","tot","tran"));
emis_rep("tot",t,"tot","tot","emiss") = sum(r, emis_rep(r,t,"tot","tot","emiss"));
emis_rep("tot",t,"tot","tot","sequ")  = sum(r, emis_rep(r,t,"tot","tot","sequ"));
emis_rep("tot",t,"tot","tot","L_em")  = sum(r, emis_rep(r,t,"tot","tot","L_em"));

**re7: Report GHG and air pollutant emissions
ghgt(r,i,ghg,"2010")= ghgt0(r,ghg,i,"new","2010");
ghgt(r,i,ghg,t)$(t.val>2010    and f_ghg(r,ghg)=0) = sum(v$y0(r,i,v), y0_.l(r,i,v)/y0(r,i,v)*ghgt0(r,ghg,i,v,"2010")*ghg_trend(r,ghg,i,v,t));
ghgt(r,"hh",ghg,t)$(t.val>2010 and f_ghg(r,ghg)=0) = sum(hh, c.l(r,hh)*ghgt0(r,ghg,hh,"new","2010")*ghg_trend(r,ghg,hh,"new",t));
ghgt(r,i,ghg,t)$(t.val>2010    and f_ghg(r,ghg))   = sum(v, ghg0_.l(r,i,ghg,v))*1000;
ghgt(r,"hh",ghg,t)$(t.val>2010 and f_ghg(r,ghg))   = ghgc0_.l(r,"hh",ghg)*1000;

ghgt(r,"ele",ghg,t)$(t.val>2010 and f_ghg(r,ghg)=0)= sum(conv,ghgt(r,conv,ghg,t));
ghgt(r,conv,ghg,t) = 0;

ghgtot(r,ghg,t)$(t.val=2010)    = ghgtot0(r,ghg);
ghgtot(r,ghg,t)$(t.val>2010)    = sum(i, ghgt(r,i,ghg,t));
ghgtott(r,t)                    = sum(ghg, ghgtot(r,ghg,t));

ghgt("Total",i,ghg,t) = sum(r, ghgt(r,i,ghg,t));
ghgtot("Total",ghg,t) = sum(r, ghgtot(r,ghg,t));
ghgtott("total",t)    = sum(r, ghgtott(r,t));

apt(r,ap,s,t)         = sum(v,ap0(r,ap,s)*y.l(r,s,v));
apt(r,ap,"ele",t)     = sum(v, ap0(r,ap,"ele")*gen.l(r,"conv",v));
apt(r,ap,ff,t)        = sum(v, ap0(r,ap,ff)*ffprod.l(r,ff,v));
apt(r,ap,"hh",t)      = sum(v, ap0(r,ap,"hh")* c.l(r,"hh"));

aptot(r,ap,t)         = sum(i,apt(r,ap,i,t));

*display ghgt, ghgtot, ghgtott, ghgendow, co2endow, co2t_ff,co2tot_ff, co2tott_ff;

*Annual co2 emissions include fossil fuel and land (mmt co2)
carbemis(r,"ff",t)                   = co2tott_ff(r,t);
carbemis(r,"land",t)$(t.val=2010)    = ghg_lulc0(r);
carbemis(r,"land",t)$(t.val>2010)    = emis_rep(r,t,"tot","tot","L_em");
carbemis(r,"ghg",t)                  = ghgtott(r,t);
carbemis(r,"ff+ghg",t)               = carbemis(r,"ff",t)+ carbemis(r,"ghg",t);
carbemis(r,"ff+land+ghg",t)          = carbemis(r,"ff",t)+ carbemis(r,"land",t)+carbemis(r,"ghg",t);

carbemis("total","ff",t)                  = sum(r,co2tott_ff(r,t));
carbemis("Total","land",t)$(t.val=2010)   = sum(r,ghg_lulc0(r));
carbemis("total","land",t)$(t.val>2010)   = emis_rep("tot",t,"tot","tot","L_em");
carbemis("total","ghg",t)                 = sum(r, carbemis(r,"ghg",t));
carbemis("total","ff+land+ghg",t)         = carbemis("total","ff",t)+ carbemis("total","land",t)+ carbemis("total","ghg",t);

*Accumulated ghg emission (mmt co2eq): positive for emission and negative for sequestration
* Emissions for four years between two periods will take the average of emissions (linear interpolation between years)

carbemist(r,"ff",t)$(ord(t)=1)      = carbemis(r,"ff",t) ;
carbemist(r,"land",t)$(ord(t)=1)    = carbemis(r,"land",t) ;
carbemist(r,"ghg",t)$(ord(t)=1)     = carbemis(r,"ghg",t) ;
carbemist(r,"ff+land+ghg",t)$(ord(t)=1) = carbemis(r,"ff+land+ghg",t);

carbemist(r,"ff",t)$(ord(t)>1)          = carbemist(r,"ff",t-1)      + 2*carbemis(r,"ff",t-1)      + 3*carbemis(r,"ff",t);
carbemist(r,"land",t)$(ord(t)>1)        = carbemist(r,"land",t-1)    + 2*carbemis(r,"land",t-1)    + 3*carbemis(r,"land",t);
carbemist(r,"ghg",t)$(ord(t)>1)         = carbemist(r,"ghg",t-1)     + 2*carbemis(r,"ghg",t-1)     + 3*carbemis(r,"ghg",t);
carbemist(r,"ff+land+ghg",t)$(ord(t)>1) = carbemist(r,"ff+land+ghg",t-1) + 2*carbemis(r,"ff+land+ghg",t-1) + 3*carbemis(r,"ff+land+ghg",t);

carbemist("total","ff",t)           = sum(r,carbemist(r,"ff",t));
carbemist("total","land",t)         = sum(r,carbemist(r,"land",t));
carbemist("total","ghg",t)          = sum(r,carbemist(r,"ghg",t));
carbemist("total","ff+land+ghg",t)  = carbemist("total","ff",t)+ carbemist("total","land",t)+ carbemist("total","ghg",t);

* GHG reported in another set of categories each year
carbemis2(r,"land","CO2",t)   = carbemis(r,"land",t);
carbemis2(r,iii,ghg,t)$(not sameas(iii,"land"))
        =   ghgt(r,iii,ghg,t)  + sum((e,use),co2t_ff(r,e,use,iii,t))$sameas(ghg,"CO2");

**re8: Report transportation production ($billion)
tran_valu(r,trn,t)         = sum(v,y0_.l(r,trn,v)) ;
tran_valu(r,afv,t)$sum(v,f_afv(r,afv,v)) = sum(v,y0_.l(r,afv,v));
tran_valu(r,OEV,t)         = sum(mapoev(oev,i),tran_valu(r,i,t));
tran_valu(r,j,t)$trnv(j)   = sum(maptrn(j,i),tran_valu(r,i,t));
tran_valu(r,"Total",t)     = sum(trn,tran_valu(r,trn,t));

tran_valuV(r,trn,v,t)         = y0_.l(r,trn,v) ;
tran_valuV(r,afv,v,t)$f_afv(r,afv,v) =y0_.l(r,afv,v);
tran_valuV(r,OEV,v,t)         = sum(mapoev(oev,i),tran_valuV(r,i,v,t));
tran_valuV(r,j,v,t)$trnv(j)   = sum(maptrn(j,i),tran_valuV(r,i,v,t));
tran_valuV(r,"Total",v,t)     = sum(trn,tran_valuV(r,trn,v,t));

* Report transportation production (billion vmt)
tran_vmt(r,trn,t)          = sum(v$y0(r,trn,v),y0_.l(r,trn,v)/y0(r,trn,v))*tran_vmt0(r,trn)*Fvmt_RodP0(r,trn);
tran_vmt(r,afv,t)$sum(v,f_afv(r,afv,v))
                           = sum(v,y0_.l(r,afv,v))/sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010")/(1-ty(r,oev)))/afv_loadf0(r,afv);
tran_vmt(r,OEV,t)          = sum(mapoev(oev,i),tran_vmt(r,i,t));
tran_vmt(r,j,t)$trnv(j)    = sum(maptrn(j,i),tran_vmt(r,i,t));

* Report transportation production (billion passenger-mile-traveled or ton-mile-traveled)
tran_prod(r,trn,t)         = tran_vmt(r,trn,t)*tran_loadf0(r,trn);
tran_prod(r,afv,t)         = tran_vmt(r,afv,t)*afv_loadf0(r,afv);
tran_prod(r,OEV,t)         = tran_vmt(r,oev,t)*sum(mapoev(oev,i),tran_loadf0(r,i));

* Report transportation energy consumption (quad btu)
tran_enbtu(r,e,trnall,t)   = en_btu(r,e,trnall,t);
tran_enbtu(r,e,"Total",t)  = sum(trn,tran_enbtu(r,e,trn,t));

* Report transportation fuel economy (mile per gallon of oil equivalent)
tran_mpge(r,i,t)$(Fvmt_RodP0(r,i) and sum(e,tran_enbtu(r,e,i,t)) and trnall(i))
     = tran_vmt(r,i,t)/Fvmt_RodP0(r,i)/sum(e,tran_enbtu(r,e,i,t))*btu_gal("oil");

tran_mpge(r,i,t)$(Fvmt_RodP0(r,i)=0 and sum(e,tran_enbtu(r,e,i,t)) and trnall(i))
     = tran_vmt(r,i,t)/sum(e,tran_enbtu(r,e,i,t))*btu_gal("oil");

tran_mpge(r,OEV,t)$(tran_vmt(r,oev,t) and sum(e,tran_enbtu(r,e,oev,t)))
     =  tran_vmt(r,oev,t)/sum(mapoev(oev,trn),Fvmt_RodP0(r,trn))
      / sum(e,tran_enbtu(r,e,oev,t))*btu_gal("oil");

* Mpge use weighted average for Auto,rodf,rodp
tran_mpge(r,trn,t)$sum(maptrn(trn,j),tran_vmt(r,j,t))
     =  sum(maptrn(trn,j),tran_mpge(r,j,t)*tran_vmt(r,j,t))
       / sum(maptrn(trn,j),tran_vmt(r,j,t));

tran_mpge(r,i,t)$(tran_vmt(r,i,t)=0)=0;

tran_mpge("Total",i,t)$(sum((r,e),tran_enbtu(r,e,i,t)) and not sameas(i,"otrn"))
    = sum(r, tran_vmt(r,i,t))/sum((r,e),tran_enbtu(r,e,i,t))*btu_gal("oil");

tran_vmtV(r,trn,v,t)          = y.l(r,trn,v)*tran_vmt0(r,trn)*Fvmt_RodP0(r,trn);
tran_vmtV(r,afv,v,t)$f_afv(r,afv,v)   = y0_.l(r,afv,v)/sum(maptrn3(OEV,afv),afv_costT0(r,OEV,"y0","2010")/(1-ty(r,oev)))/afv_loadf0(r,afv);

tran_vmtV(r,OEV,v,t)          = sum(mapoev(oev,i),tran_vmtV(r,i,v,t));
*tran_vmtV(r,trn,v,t)         = sum(maptrn(trn,i),tran_vmtV(r,i,v,t));
tran_vmtV(r,j,v,t)$trnv(j)    = sum(maptrn(j,i),tran_vmtV(r,i,v,t));

* Vehicle vmt reduces over time along with the age
tran_vmtbyage(r,i,v,t,t)             = tran_vmtV(r,i,v,t);
*tran_vmtbyage(r,i,"extant","2010","2010") = tran_vmtV(r,i,"extant","2010");
tran_vmtbyage(r,i,"extant",t,t+1)    = tran_vmtV(r,i,"new",t)*vmtbyage("1",i);
tran_vmtbyage(r,i,"extant",t,t+2)    = tran_vmtV(r,i,"new",t)*vmtbyage("2",i);
tran_vmtbyage(r,i,"extant",t,t+3)    = tran_vmtV(r,i,"new",t)*vmtbyage("3",i);
tran_vmtbyage(r,i,"extant",t,t+4)    = tran_vmtV(r,i,"new",t)*vmtbyage("4",i);
tran_vmtbyage(r,i,"extant",t,t+5)    = tran_vmtV(r,i,"new",t)*vmtbyage("5",i);

tran_vmtbyage(r,i,"his",t,t+1)$(t.val=2010)  = tran_vmtV(r,i,"extant",t)*vmtbyage_his("2",i);
tran_vmtbyage(r,i,"his",t,t+2)$(t.val=2010)  = tran_vmtV(r,i,"extant",t)*vmtbyage_his("3",i);
tran_vmtbyage(r,i,"his",t,t+3)$(t.val=2010)  = tran_vmtV(r,i,"extant",t)*vmtbyage_his("4",i);
tran_vmtbyage(r,i,"his",t,t+4)$(t.val=2010)  = tran_vmtV(r,i,"extant",t)*vmtbyage_his("5",i);

* vmt in t+1 period
tran_vmtbyage(r,i,"extant","tot",t+1)=  sum(tt,tran_vmtbyage(r,i,"extant",tt,t+1))
                                      + tran_vmtbyage(r,i,"his","2010",t+1);

tran_surratio(r,i,t)$tran_vmtbyage(r,i,"extant","tot",t)=  tran_vmtv(r,i,"extant",t)/tran_vmtbyage(r,i,"extant","tot",t);

*Share of Transportation VMT traveled by vintage for the next period
tran_vmtshrV(r,i,"extant",tt,t+1)$tran_vmtbyage(r,i,"extant","tot",t+1)   = tran_vmtbyage(r,i,"extant",tt,t+1)/tran_vmtbyage(r,i,"extant","tot",t+1);
tran_vmtshrV(r,i,"his","2010",t+1)$tran_vmtbyage(r,i,"extant","tot",t+1)  = tran_vmtbyage(r,i,"his","2010",t+1)/tran_vmtbyage(r,i,"extant","tot",t+1);

tran_vmtshrV(r,i,"extant",tt,t+1)$(tran_vmtbyage(r,i,"extant","tot",t+1)=0 and tt.val<=t.val and tt.val>=t.val-5)
                            = 0;

ket(r,k,i,v,t)                                           = kd0_.l(r,k,i,v)     ;
tran_ketbyage(r,k,i,v,t,t)$(trnv(i) or afv(i) )          = ket(r,k,i,v,t)      ;
tran_ketbyage(r,k,i,"extant",t,t+1)$(trnv(i) or afv(i))  = ket(r,k,i,"new",t)*vmtbyage("1",i) ;
tran_ketbyage(r,k,i,"extant",t,t+2)$(trnv(i) or afv(i))  = ket(r,k,i,"new",t)*vmtbyage("2",i) ;
tran_ketbyage(r,k,i,"extant",t,t+3)$(trnv(i) or afv(i))  = ket(r,k,i,"new",t)*vmtbyage("3",i) ;
tran_ketbyage(r,k,i,"extant",t,t+4)$(trnv(i) or afv(i))  = ket(r,k,i,"new",t)*vmtbyage("4",i) ;
tran_ketbyage(r,k,i,"extant",t,t+5)$(trnv(i) or afv(i))  = ket(r,k,i,"new",t)*vmtbyage("5",i) ;

tran_ketbyage(r,k,i,"his",t,t+1)$(trnv(i) and t.val=2010  )  = ket(r,k,i,"extant",t)*vmtbyage_his("2",i);
tran_ketbyage(r,k,i,"his",t,t+2)$(trnv(i) and t.val=2010  )  = ket(r,k,i,"extant",t)*vmtbyage_his("3",i);
tran_ketbyage(r,k,i,"his",t,t+3)$(trnv(i) and t.val=2010  )  = ket(r,k,i,"extant",t)*vmtbyage_his("4",i);
tran_ketbyage(r,k,i,"his",t,t+4)$(trnv(i) and t.val=2010  )  = ket(r,k,i,"extant",t)*vmtbyage_his("5",i);

tran_ketbyage(r,k,i,"extant","tot",t+1)$(trnv(i) or afv(i))  =  sum(tt$(tt.val<(t.val+5)),tran_ketbyage(r,k,i,"extant",tt,t+1))
                                                              + tran_ketbyage(r,k,i,"his","2010",t+1);
tran_enbtuV(r,e,trnall,v,t)  = en_btusv(r,e,"fuel",trnall,v,t);
tran_enbtuV(r,e,"Total",v,t) = sum(trn,tran_enbtuV(r,e,trn,v,t));

tran_mpgeV(r,i,v,t)=0;
tran_mpgeV(r,trn,v,t)$(tran_vmtV(r,trn,v,t) and Fvmt_RodP0(r,trn)  and sum(e,tran_enbtuV(r,e,trn,v,t)))
     = tran_vmtV(r,trn,v,t)/Fvmt_RodP0(r,trn)
      /sum(e,tran_enbtuV(r,e,trn,v,t))*btu_gal("oil");

tran_mpgeV(r,afv,v,t)$(tran_vmtV(r,afv,v,t) and sum(e,tran_enbtuV(r,e,afv,v,t)))
     = tran_vmtV(r,afv,v,t)/sum(e,tran_enbtuV(r,e,afv,v,t))*btu_gal("oil");

tran_mpgeV(r,OEV,v,t)$(tran_vmtV(r,oev,v,t) and sum(e,tran_enbtuV(r,e,oev,v,t)))
     =  tran_vmtV(r,oev,v,t)/sum(mapoev(oev,trn),Fvmt_RodP0(r,trn))
      / sum(e,tran_enbtuV(r,e,oev,v,t))*btu_gal("oil");

* Mpgev use weighted average for Auto,rodf,rodp
tran_mpgeV(r,trn,v,t)$(tran_vmtV(r,trn,v,t) and sum(maptrn(trn,j),tran_vmtV(r,j,v,t)))
     =   sum(maptrn(trn,j),tran_mpgeV(r,j,v,t)*tran_vmtV(r,j,v,t))
       / sum(maptrn(trn,j),tran_vmtV(r,j,v,t));

tran_mpgev("Total",i,v,t)$sum((r,e),tran_enbtuv(r,e,i,v,t))
    = sum(r, tran_vmtv(r,i,v,t))/sum((r,e),tran_enbtuv(r,e,i,v,t))*btu_gal("oil");

* Report vehicle stock in USA auto sector by vintage (million)
USA_auto_stockV("Auto_OEV",v,t) = y.l("USA","auto",v)*tran_vmt0("USA","auto")/USA_auto_vmtV0("Auto_OEV");
USA_auto_stockV(autoafv,v,t)    = y0_.l("USA",autoafv,v)/auto_pricT0("USA",autoafv,"2010")/auto_loadf0("USA",autoafv)/USA_auto_vmtV0("Auto_OEV");

USA_auto_stockV("Auto",v,t)
   =  USA_auto_stockV("auto_OEV",v,t)
    + sum(autoafv,USA_auto_stockV(autoafv,v,t));

USA_auto_stockV("auto_OEV","Total",t)= sum(v,USA_auto_stockV("auto_OEV",v,t));
USA_auto_stockV(autoafv,"Total",t)   = sum(v,USA_auto_stockV(autoafv,v,t));
USA_auto_stockV("Auto","Total",t)
    =  USA_auto_stockV("auto_OEV","total",t)
     + sum(autoafv,USA_auto_stockV(autoafv,"Total",t));

* Report transportation ghg emission (mmt co2eq)
tran_emis(r,"co2",i,t)$(trni(i) or autoi(i) or hdvi(i))   = sum(e,co2t_ff(r,e,"fuel",i,t));
tran_emis(r,ghg,i,t)$(trni(i) or autoi(i) or hdvi(i))     = tran_emis(r,ghg,i,t)+ ghgt(r,i,ghg,t);
tran_emis(r,ghg,"total",t)   = sum(trn,tran_emis(r,ghg,trn,t));

** Report OE energy demand
** Oil-biofuel onroad fuel demand ($billion)
OEV_valu(r,e,i,t)$(ob(e) and (autoi(i) or hdvi(i)))     = ed(r,e,"fuel",i,t);

*Report share of biofuel on household onroad energy
OEV_shr(r,i,t)$sum(ob,OEV_valu(r,ob,i,t))
           = sum(ob$(not oil(ob)),OEV_valu(r,ob,i,t)) / sum(ob,OEV_valu(r,ob,i,t));

OEV_shr_btu(r,"ethl",i,t)$sum(e,tran_enbtu(r,e,i,t))=sum(ethl,tran_enbtu(r,ethl,i,t))/sum(e,tran_enbtu(r,e,i,t));
OEV_shr_btu(r,"biod",i,t)$sum(e,tran_enbtu(r,e,i,t))=sum(biod,tran_enbtu(r,biod,i,t))/sum(e,tran_enbtu(r,e,i,t));
OEV_shr_btu(r,"advb",i,t)$sum(e,tran_enbtu(r,e,i,t))=sum(advbio,tran_enbtu(r,advbio,i,t))/sum(e,tran_enbtu(r,e,i,t));

**Report physical output for onroad sectors (billion gal)
** GAL_conv is same for all OE
OEV_gal(r,e,i,t)             = GAL_conv(r,e,"fuel",i) * OEV_valu(r,e,i,t) ;
OEV_gal(r,e,i,t)$advbio(e)   = GAL_conv(r,e,"fuel",i) * OEV_valu(r,e,i,t) /advbiomkup(r,e);
OEV_gal(r,ad,i,t)            = gal_conv(r,ad,"fuel",i)* OEV_valu(r,ad,i,t)/advbiomkup(r,ad);

OEV_gal(r,"ethl",i,t)        = sum(et, OEV_gal(r,et,i,t));
OEV_gal(r,"biod",i,t)        = sum(bd, OEV_gal(r,bd,i,t));
OEV_gal(r,"advb",i,t)        = sum(ad, OEV_gal(r,ad,i,t));
OEV_gal(r,"total_bio",i,t)   = OEV_gal(r,"ethl",i,t) + OEV_gal(r,"biod",i,t) + OEV_gal(r,'advb',i,t);
OEV_gal(r,"total",i,t)       = sum(e, OEV_gal(r,e,i,t));

**Report oil/biofuel energy in btu
OEV_btu(r,e,i,t)             = BTU_conv(r,e,"fuel",i) * OEV_valu(r,e,i,t) ;
OEV_btu(r,e,i,t)$advbio(e)   = OEV_btu(r,e,i,t)/advbiomkup(r,e);
OEV_btu(r,"total",i,t)       = sum(e,OEV_btu(r,e,i,t));

**Report OEV energy price
OEV_pric(r,e,i,t)$OEV_valu(r,e,i,t)
        =  pedm.l(r,e) ;

** Report oev energy price (adjusted by consumption price)
OEV_pric_pc(r,e,i,t)$OEV_valu(r,e,i,t)
        = OEV_pric(r,e,i,t)/pc.l(r,"hh");


** Report household auto energy demand
**Auto fuel demand ($billion)
auto_valu(r,e,t)     = ed(r,e,"fuel","auto",t);

*Report share of biofuel on household auto energy
auto_shr(r,t)$(auto_valu(r,"oil",t) + sum(bio,auto_valu(r,bio,t)))
           = 100 * sum(bio,auto_valu(r,bio,t)) / (auto_valu(r,"oil",t)+sum(bio,auto_valu(r,bio,t)));

**Report physical output for auto sectors (billion gal)
auto_gal(r,e,t)$GAL_conv(r,e,"fuel","auto")  = GAL_conv(r,e,"fuel","auto") * ed(r,e,"fuel","auto",t);
auto_gal(r,e,t)$(GAL_conv(r,e,"fuel","auto") and advbio(e)) = GAL_conv(r,e,"fuel","auto") * ed(r,e,"fuel","auto",t)/advbiomkup(r,e);

auto_gal(r,"total",t)       = sum(e, auto_gal(r,e,T));
auto_gal(r,"ethl",t)        = sum(et, auto_gal(r,et,T));
auto_gal(r,"biod",t)        = sum(bd, auto_gal(r,bd,T));
auto_gal(r,ad,t)            = gal_conv(r,ad,"fuel","auto") * ed(r,ad,"fuel","auto",t)/advbiomkup(r,ad);
auto_gal(r,"advb",t)        = sum(ad, auto_gal(r,ad,T));
auto_gal(r,"total_bio",t)   = auto_gal(r,"ethl",T) + auto_gal(r,"biod",T) + auto_gal(r,'advb',T);


**Report Auto energy in quad btu
auto_btu(r,e,t)  =   BTU_conv(r,e,"fuel","auto") * ed(r,e,"fuel","auto",t) ;
auto_btu(r,e,t)$advbio(e) = auto_btu(r,e,t)/advbiomkup(r,e);

auto_btu(r,"total",t) =sum(e,auto_btu(r,e,t));

**Report auto energy price
auto_pric(r,e,t)$ed(r,e,"fuel","auto",t)
        = ped.l(r,e,"fuel","auto") ;

** Report auto energy price (adjusted by consumption price)
auto_pric_pc(r,e,t)
        = auto_pric(r,e,t)/pc.l(r,"hh");

***re9: Report physical units for crop sectors and biofuel on production, import, export, consumption
** Consumption includes intermediate use, final consumption by households, government consumption
** units for crop: mmt
** units for biofuels: billion gal
agbio_macro(r,crp,"y0",t)$ag_pric0(r,crp)   = sum(v,y0_.l(r,crp,v))* py.l(r,crp) /ag_pric0(r,crp);
agbio_macro(r,crp,"a0",t)$ag_pric0(r,crp)   = a0_.l(r,crp) * pa.l(r,crp) /ag_pric0(r,crp);
agbio_macro(r,crp,"x0",t)$ag_pric0(r,crp)   = sum(rr,n0_.l(rr,r,crp)) * py.l(r,crp) /ag_pric0(r,crp);
agbio_macro(r,crp,"m0",t)$ag_pric0(r,crp)   = m0_.l(r,crp) * pm.l(r,crp) /ag_pric0(r,crp);

agbio_macro(r,bio,"y0",t)$bioc_pric0(r,bio) = sum(v,y0_.l(r,bio,v))* py.l(r,bio) /bioc_pric0(r,bio);
agbio_macro(r,bio,"a0",t)$bioc_pric0(r,bio) = a0_.l(r,bio) * pa.l(r,bio) /bioc_pric0(r,bio);
agbio_macro(r,bio,"x0",t)$bioc_pric0(r,bio) = sum(rr,n0_.l(rr,r,bio)) * py.l(r,bio) /bioc_pric0(r,bio);
agbio_macro(r,bio,"m0",t)$bioc_pric0(r,bio) = m0_.l(r,bio) * pm.l(r,bio) /bioc_pric0(r,bio);

agbio_macro(r,crp,"y0",t)$ag_pric0(r,crp)   = sum(v,y0_.l(r,crp,v))* py.l(r,crp) ;
agbio_macro(r,crp,"a0",t)$ag_pric0(r,crp)   = a0_.l(r,crp) * pa.l(r,crp) ;
agbio_macro(r,crp,"x0",t)$ag_pric0(r,crp)   = sum(rr,n0_.l(rr,r,crp)) * py.l(r,crp) ;
agbio_macro(r,crp,"m0",t)$ag_pric0(r,crp)   = m0_.l(r,crp) * pm.l(r,crp) ;

agbio_macro(r,bio,"y0",t)$bioc_pric0(r,bio) = sum(v,y0_.l(r,bio,v))* py.l(r,bio);
agbio_macro(r,bio,"a0",t)$bioc_pric0(r,bio) = a0_.l(r,bio) * pa.l(r,bio);
agbio_macro(r,bio,"x0",t)$bioc_pric0(r,bio) = sum(rr,n0_.l(rr,r,bio)) * py.l(r,bio);
agbio_macro(r,bio,"m0",t)$bioc_pric0(r,bio) = m0_.l(r,bio) * pm.l(r,bio);

**Notice that gal_conv(r,bio,"fuel","auto") is equal to 1/bioc_pric0(r,bio), to keep it consistent  we use gal_conv

**re: Report crop sectoral production by value, area, price
* Units:  ag_valu: $billion
*         ag_area: million ha
*         ag_tonn: million tonnes
*         ag_pric: $1000/tonne

ag_valu(r,agrbio,t)$(ag_pric0(r,agrbio) ) =  sum(v,(y0_.l(r,agrbio,v)+y00_.l(r,agrbio,v))) ;
ag_tonn(r,agrbio,t)$(ag_pric0(r,agrbio) ) =  sum(v,(y0_.l(r,agrbio,v)+y00_.l(r,agrbio,v))) /ag_pric0(r,agrbio);
ag_pric(r,agrbio,t)$(ag_pric0(r,agrbio) ) =  prices_pc(r,agrbio,"py",t)* ag_pric0(r,agrbio);

ag_lndh(r,crp,t) =  land_area(r,crp,t);
ag_lndv(r,crp,t) =  sum(v, lnd0_.l(r,crp,v));

*display land_area, land_tran, land_em, land_seq;

ag_tonn_trad(r,i,"export",t) =   sum(rr$ag_pric0(r,i),bi_trade(rr,r,i,t)/ag_pric0(r,i));
ag_tonn_trad(r,i,"import",t) =   sum(rr$ag_pric0(rr,i),bi_trade(r,rr,i,t)/ag_pric0(rr,i));
ag_tonn_trad(r,i,"nettrd",t) =   ag_tonn_trad(r,i,"export",t) - ag_tonn_trad(r,i,"import",t);
ag_tonn_trad("total",i,"nettrd",t) = sum(r,ag_tonn_trad(r,i,"nettrd",t));

chk_ag_tonn(r,i,"production",t)$ag_pric0(r,i)= ag_tonn(r,i,t);
chk_ag_tonn(r,i,"import",t)$ag_pric0(r,i)= ag_tonn_trad(r,i,"import",t);
chk_ag_tonn(r,i,"export",t)$ag_pric0(r,i)= ag_tonn_trad(r,i,"export",t);
chk_ag_tonn(r,i,"consumption",t)$ag_pric0(r,i)
      =   chk_ag_tonn(r,i,"production",t)+ag_tonn_trad(r,i,"import",t)
        - chk_ag_tonn(r,i,"export",t) ;

ag_tonn_cons(r,i,t)$ag_pric0(r,i)       = chk_ag_tonn(r,i,"consumption",t);
ag_pric_cons(r,i,t)$ag_tonn_cons(r,i,t) = cons_all(r,i,t)/ag_tonn_cons(r,i,t);

cons_tonn(r,i,t)$ag_pric_cons(r,i,"2010")            = cons(r,i,t)/ag_pric_cons(r,i,"2010");
cons_all_tonn(r,i,t)$ag_pric_cons(r,i,"2010")        = cons_all(r,i,t)/ag_pric_cons(r,i,"2010");
cons_alls_tonn(r,i,j,t)$ag_pric_cons(r,i,"2010")     = cons_alls(r,i,j,t)/ag_pric_cons(r,i,"2010");

cons_tonn("total",i,t)          = sum(r,cons_tonn(r,i,t));
cons_all_tonn("total",i,t)      = sum(r,cons_all_tonn(r,i,t));
cons_alls_tonn("total",i,j,t)   = sum(r,cons_alls_tonn(r,i,j,t));

* Check sectoral input shares:
*       Add taxes on land, intermediate goods (non-energy), resources
*       Add output of ddgs for ethanol
chk_shr(r,v,s,"ed0",t)$(y0_.l(r,s,v)$(new(v) and agr(s)))
          =    sum((e,use), ped.l(r,e,use,s) * ed(r,e,use,s,t))
             / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + (py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"ed0",t)$(y0_.l(r,s,v)$(new(v) and not agr(s)))
          =  (   sum((e,use)$(not fdst(use)), ped.l(r,e,use,s) * ed(r,e,use,s,t))
               + sum((e,use)$fdst(use),       ped.l(r,e,use,s) * ed(r,e,use,s,t)) )
              / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + (py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"ed0",t)$(y0_.l(r,s,v)$extant(v))
          =   sum((e,use), ped.l(r,e,use,s) * ed(r,e,use,s,t))
              / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + (py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"id0",t)$y0_.l(r,s,v)
          =   sum(g, pa.l(r,g) * (1+ti(r,g,s)) * id0_.l(r,g,s,v))
             / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + (py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"id0",t)$(y0_.l(r,s,v) and liv(s))
          = (   sum(g$(not (feed(g) or ofd(g))), pa.l(r,g) * (1+ti(r,g,s)) * id0_.l(r,g,s,v))
              + pfeed.l(r,s)*feed0_y.l(r,s,v)  )
             / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + ( py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"ld0",t)$y0_.l(r,s,v)
          =   (pl.l(r) * ld0_.l(r,s,v) * pld0(r,s))
            / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + ( py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"hkd0",t)$y0_.l(r,s,v)
          =    (phk.l(r) * hkd0_.l(r,s,v) * phkd0(r,s))
             / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s))+ ( py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"lnd0",t)$(y0_.l(r,s,v)$crp(s))
           = (plnd.l(r,'crop') * (1+tn(r,s)) * lnd0_.l(r,s,v))
           / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + ( py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s))
            * dfl.l(r,'crop',v)/(sum(crp0, lnd0_.l(r,crp0,v))+ sum(ad,lnd0_.l(r,ad,v)))   ;

chk_shr(r,v,s,"lnd0",t)$(y0_.l(r,s,v)$(liv(s) or frs(s)))
           =    (plnd.l(r,s) * (1+tn(r,s)) * lnd0_.l(r,s,v))
              / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + ( py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));


chk_shr(r,v,s,"rd0",t)$y0_.l(r,s,v)
           =  (pr.l(r,s) * rd0_.l(r,s,v) * prd0(r,s))
            / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + ( py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"kd0",t)$(new(v) and y0_.l(r,s,v))
           =    sum(k, rk.l(r,k) * kd0_.l(r,k,s,v) * pkd0(r,k,s))
             / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + ( py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"kd0",t)$(extant(v) and y0_.l(r,s,v))
           =    sum(k, rkx.l(r,k,s) * kd0_.l(r,k,s,v) * pkd0(r,k,s))
             / (py.l(r,s) * y0_.l(r,s,v) * (1-ty(r,s)) + ( py.l(r,"omel")*y0_.l(r,"omel",v))$vol(s));

chk_shr(r,v,s,"total",t)
        = chk_shr(r,v,s,"ed0",t)
        + chk_shr(r,v,s,"id0",t)
        + chk_shr(r,v,s,"ld0",t)
        + chk_shr(r,v,s,"kd0",t)
        + chk_shr(r,v,s,"hkd0",t)
        + chk_shr(r,v,s,"rd0",t)
        + chk_shr(r,v,s,"lnd0",t);

* Include ddg byproduct for corn ethanol
chk_shr(r,v,"ceth","ed0",t)$y0_.l(r,"ceth",v)
        =  sum((e,use), ped.l(r,e,use,"ceth") * ed(r,e,use,"ceth",t))
         /(py.l(r,"ceth") * y0_.l(r,"ceth",v) * (1-ty(r,"ceth")) + py.l(r,"ddgs") * y0_.l(r,"ddgs",v));

chk_shr(r,v,"ceth","id0",t)$(y0_.l(r,"ceth",v))
        =   sum(g$(not corn(g)), pa.l(r,g) * id0_.l(r,g,"ceth",v))
          /(py.l(r,"ceth") * y0_.l(r,"ceth",v) * (1-ty(r,"ceth")) + py.l(r,"ddgs") * y0_.l(r,"ddgs",v));

chk_shr(r,v,"ceth","corn",t)$(y0_.l(r,"ceth",v))
        =   pa.l(r,"corn") * id0_.l(r,"corn","ceth",v)
          /(py.l(r,"ceth") * y0_.l(r,"ceth",v) * (1-ty(r,"ceth")) + py.l(r,"ddgs") * y0_.l(r,"ddgs",v));

chk_shr(r,v,"ceth","ld0",t)$y0_.l(r,"ceth",v)
         = (pl.l(r) * ld0_.l(r,"ceth",v) * pld0(r,"ceth"))
          /(py.l(r,"ceth") * y0_.l(r,"ceth",v) * (1-ty(r,"ceth")) + py.l(r,"ddgs") * y0_.l(r,"ddgs",v));

chk_shr(r,v,"ceth","hkd0",t)$y0_.l(r,"ceth",v)
         =  (phk.l(r) * hkd0_.l(r,"ceth",v) * phkd0(r,"ceth"))
           /(py.l(r,"ceth") * y0_.l(r,"ceth",v) * (1-ty(r,"ceth")) + py.l(r,"ddgs") * y0_.l(r,"ddgs",v));
chk_shr(r,v,"ceth","lnd0",t)$y0_.l(r,"ceth",v)
         =  (plnd.l(r,"ceth") * lnd0_.l(r,"ceth",v))
           /(py.l(r,"ceth") * y0_.l(r,"ceth",v) * (1-ty(r,"ceth")) + py.l(r,"ddgs") * y0_.l(r,"ddgs",v));

chk_shr(r,v,"ceth","kd0",t)$(new(v) and y0_.l(r,"ceth",v))
         = (rk.l(r,"va") * kd0_.l(r,"va","ceth",v) * pkd0(r,"va","ceth"))
          /(py.l(r,"ceth") * y0_.l(r,"ceth",v) * (1-ty(r,"ceth"))   + py.l(r,"ddgs") * y0_.l(r,"ddgs",v));

chk_shr(r,v,"ceth","kd0",t)$(extant(v) and y0_.l(r,"ceth",v))
         = (rkx.l(r,"va","ceth") * kd0_.l(r,"va","ceth",v) * pkd0(r,"va","ceth"))
          /(py.l(r,"ceth") * y0_.l(r,"ceth",v) * (1-ty(r,"ceth"))   + py.l(r,"ddgs") * y0_.l(r,"ddgs",v));

chk_shr(r,v,"ceth","total",t)
        = chk_shr(r,v,"ceth","ed0",t)
        + chk_shr(r,v,"ceth","id0",t)
        + chk_shr(r,v,"ceth","corn",t)
        + chk_shr(r,v,"ceth","ld0",t)
        + chk_shr(r,v,"ceth","kd0",t)
        + chk_shr(r,v,"ceth","hkd0",t)
        + chk_shr(r,v,"ceth","lnd0",t);


*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
*                            Global report
*XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
macro("Total",macrovar,t)       = sum(r,macro(r,macrovar,t));
gdp_("Total",t)                 = macro("Total","GDP",t);

gdp_sec("Total",i,t)            = sum(r,gdp_sec(r,i,t));
gdp_sec("Total","total",t)      = sum(r,gdp_sec(r,"total",t));
gdp_sec("Total","advb",t)       = sum(r,gdp_sec(r,"advb",t));
gdp_sec("Total","ethl",t)       = sum(r,gdp_sec(r,"ethl",t));
gdp_sec("Total","biod",t)       = sum(r,gdp_sec(r,"biod",t));
gdp_sec("Total","crop",t)       = sum(r,gdp_sec(r,"crop",t));
gdp_sec("Total","agri",t)       = sum(r,gdp_sec(r,"agri",t));
gdp_sec("Total","biofuel",t)    = sum(r,gdp_sec(r,"biofuel",t));

**Report sectoral output for ag, bio and energy ($billion)
output("Total",agrbio,t)        = sum(r, output(r,agrbio,t));
output("Total",e,t)             = sum(r, output(r,e,t));
output("Total",'ele',t)         = sum(r, output(r,'ele',t));
output("Total",'ethl',t)        = sum(r, output(r,'ethl',t));
output("Total",'biod',t)        = sum(r, output(r,'biod',t));
output("Total",ad,t)            = sum(r, output(r,ad,t));
output("Total",'advb',t)        = sum(r, output(r,'advb',t));
output("Total",i,t)             = sum(r, output(r,i,t));

*Household consumption and price
cons("total",i,t)               = sum(r,cons(r,i,t));
cons_p("total",i,t)$sum(r,cons(r,i,t))
                                = sum(r,cons(r,i,t)*cons_p(r,i,t))/sum(r,cons(r,i,t));
cons_all("total",i,t)           = sum(r,cons_all(r,i,t));
cons_allp("total",i,t)$sum(r,cons_all(r,i,t))
                                = sum(r,cons_all(r,i,t)*cons_allp(r,i,t))/sum(r,cons_all(r,i,t));

cons_alls("Total",j,i,t)        = sum(r,cons_alls(r,j,i,t));

**Report price index
price("Total",i,"py_pc",t)$sum(r, output(r,i,t))
                                = sum(r, price(r,i,"py_pc",t)* output(r,i,t))/sum(r, output(r,i,t));
price("Total",g,"pa_pc",t)$sum((r,i,v), id0_.l(r,g,i,v))
                                = sum(r, price(r,g,"pa_pc",t)* sum((i,v), id0_.l(r,g,i,v)))/sum((r,i,v), id0_.l(r,g,i,v));

**Report energy sectoral demand
*  energy demand by $ billion
en_valu("Total",e,i,t)          = sum(r, en_valu(r,e,i,t));
en_valu("Total",e,"all",t)      = sum(r, en_valu(r,e,"all",t));

en_valus("Total",e,use,i,t)     = sum(r, en_valus(r,e,use,i,t));
en_valus("Total",e,use,"all",t) = sum(r, en_valus(r,e,use,"all",t));

en_btu("Total",e,i,t)           = sum(r, en_btu(r,e,i,t));
en_btu("Total",e,"all",t)       = sum(r, en_btu(r,e,"all",t));

enprod_valu("Total",e,t)        = sum(r, enprod_valu(r,e,t));
enprod_btu("Total",e,t)         = sum(r, enprod_btu(r,e,t));

co2tot_ff("Total",e,t)            = sum(r, co2tot_ff(r,e,t));
co2tott_ff("Total",t)             = sum(r, co2tott_ff(r,t));

ele_valu("Total",gentype,t)     = sum(r, ele_valu(r,gentype,t));
ele_btu("Total",gentype,t)      = sum(r, ele_btu(r,gentype,t));

auto_valu("Total",e,t)          = sum(r, auto_valu(r,e,t));

**Report physical output for auto sectors (billion gal)
auto_gal("Total",e,t)           = sum(r, auto_gal(r,e,t));
auto_gal("Total","total",t)     = sum(r, auto_gal(r,"total",t));
auto_gal("Total","ethl",t)      = sum(r, auto_gal(r,"ethl",t));
auto_gal("Total","biod",t)      = sum(r, auto_gal(r,"biod",t));
auto_gal("Total",ad,t)          = sum(r, auto_gal(r,ad,t));
auto_gal("Total","advb",t)      = sum(r, auto_gal(r,"advb",t));
auto_gal("Total","total_bio",t) = sum(r, auto_gal(r,"total_bio",t));

auto_btu("Total",e,t)           = sum(r, auto_btu(r,e,t));
auto_btu("Total","total",t)     = sum(r, auto_btu(r,"total",t));

auto_pric("Total",e,t)$sum(r, auto_valu(r,e,t))
                                = sum(r, auto_pric(r,e,t)*auto_valu(r,e,t))/sum(r, auto_valu(r,e,t));
auto_pric_pc("Total",e,t)$sum(r, auto_valu(r,e,t))
                                = sum(r, auto_pric_pc(r,e,t)*auto_valu(r,e,t))/sum(r, auto_valu(r,e,t));

**re: Report land value and area by type
*    Land value in $billion
*    Aggeregate land into crp, liv, for and advanced cellulosic biofuel land

land_valu("Total",i,t)          = sum(r, land_valu(r,i,t));
land_valu("Total",lu,t)         = sum(r, land_valu(r,lu,t));
land_valu("Total","advb",t)     = sum(r, land_valu(r,"advb",t));

land_area("Total",i,t)          = sum(r, land_area(r,i,t));
land_area("Total","crop",t)     = sum(r, land_area(r,"crop",t));
land_area("Total","advb",t)     = sum(r, land_area(r,"advb",t));
land_area("Total",'total',t)    = sum(r, land_area(r,'total',t));

ag_valu("Total",crp,t)          = sum(r, ag_valu(r,crp,t));
ag_tonn("Total",crp,t)          = sum(r, ag_tonn(r,crp,t));
ag_pric("Total",crp,t)$sum(r, agbio_macro(r,crp,"a0",t))
                                = sum(r, ag_pric(r,crp,t)*agbio_macro(r,crp,"a0",t))/sum(r, agbio_macro(r,crp,"a0",t));
ag_lndh("Total",crp,t)          = sum(r, ag_lndh(r,crp,t));
ag_lndv("Total",crp,t)          = sum(r, ag_lndv(r,crp,t));
