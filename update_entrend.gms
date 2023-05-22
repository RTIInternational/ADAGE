*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                Update endogenous growth trends applied from 2010 to 2050
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

*EN1: update price and elasticity of energy and renewable electricity resources
    shr_nr(r,ff,t) = (pr.l(r,ff) * rd0(r,ff,"new")) / (py.l(r,ff) * y0(r,ff,"new"));
    e_nr(r,ff,t)   = eta_nr(r,ff) * ( shr_nr(r,ff,t) / (1-shr_nr(r,ff,t)) );

    p_nr(r,ff,t)$rd0(r,ff,"new")
             =   (   pr.l(r,ff)* rd0(r,ff,"new")
                     / (    sum(g, pa.l(r,g)*id0(r,g,ff,"new")*pid0(r,g,ff))
                         +  pl.l(r)*ld0(r,ff,"new")*pld0(r,ff)
                         +  sum(k, rk.l(r,k)*kd0(r,k,ff,"new")*pkd0(r,k,ff))
                         +  sum((e,use), ped.l(r,e,use,ff)*ed0(r,e,use,ff,"new")) ) )
                / (  rd0(r,ff,"new")
                     / (   sum(g,id0(r,g,ff,"new")*pid0(r,g,ff))
                         + ld0(r,ff,"new")*pld0(r,ff))
                         + sum(k,kd0(r,k,ff,"new")*pkd0(r,k,ff))
                         + sum((e,use),ed0(r,e,use,ff,"new")) );


    shr_rnw(r,rnw,t)$y0(r,rnw,"new")
          = (prnw.l(r,rnw) * rnw0(r,rnw,"new")) / (py.l(r,"ele") * y0(r,rnw,"new"));
    e_rnw(r,rnw,t)   = eta_rnw(r,rnw) * ( shr_rnw(r,rnw,t) / (1-shr_rnw(r,rnw,t)) );

    p_rnw(r,rnw,t)$rnw0(r,rnw,"new")
            =  (  prnw.l(r,rnw) * rnw0(r,rnw,"new")
                 /(   sum(g,pa.l(r,g)* id0(r,g,rnw,"new")*pid0(r,g,rnw))
                    + pl.l(r)* ld0(r,rnw,"new")*pld0(r,rnw)
                    + sum(k,rk.l(r,k)* kd0(r,k,rnw,"new")*pkd0(r,k,rnw)) ) )
              /(    rnw0(r,rnw,"new")
                  /(  sum(g,id0(r,g,rnw,"new")*pid0(r,g,rnw))
                     + ld0(r,rnw,"new")*pld0(r,rnw)
                     + sum(k,kd0(r,k,rnw,"new")*pkd0(r,k,rnw)) ) );

    pref_nr(r,ff)   = (1 + 0.01)**(5*(ord(t)-1)) ;
    pref_nr('bra','col')   = (1 + 0.00)**(5*(ord(t)-1)) ;
    pref_nr('usa','cru')   = (1 + 0.00)**(5*(ord(t)-1)) ;

    pref_gen(r,rnw) = (1 + 0.01)**(5*(ord(t)-1))  ;

    esub_nr(r,ff)   = 0.6;
    dm_elas("Rodf")    = 0.3;

*EN2: Update malleable new capital and extant capital
* Capital code
    xket(r,k,i,t)$(ord(t)=1 and not conv(i))  = xk0_10_(r,k,i);
    nket(r,k,t)$(ord(t)=1)      = sum(i,nk0_10_(r,k,i));
    totcap(r,k,i,t)$(ord(t)=1)  = nk0_10_(r,k,i);

    xk0(r,k,i)$(ord(t)>1 and xk0_10_(r,k,i))      = (kd0_.l(r,k,i,'extant') + kd0_.l(r,k,i,'new')*theta(r))*(1-depr)**5;
    newcap(r,k,i,t)$(ord(t)>1 and clay(r,i))      =  kd0_.l(r,k,i,'new')*(1-theta(r)) ;
    newcap(r,k,i,t)$(ord(t)>1 and not clay(r,i))  =  kd0_.l(r,k,i,'new') ;

* Final capital with the addition of a productivity factor needed to estimate the GDP targets
    xk0(r,k,i)$(ord(t)>1 and sum(v,f_afv(r,i,v)))  = tran_ketbyage(r,k,i,"extant","tot",t);
    xk0(r,k,i)$(ord(t)>1 and trnv(i))              = tran_ketbyage(r,k,i,"extant","tot",t);
    xk0(r,k,i)$(ord(t)>1 and (convrnw(i) or f_advgen(r,i,"extant")))  = ele_ketbyage(r,k,i,"extant","tot",t);

    xk0(r,"ldv",i)$(ord(t)>1 and round(xk0(r,"ldv",i),6)=0 and (auto(i) or autoafv(i))) =  xket(r,"ldv",i,t-1);
    xk0(r,"va",i)$(ord(t)>1  and round(xk0(r,"va",i),6)=0  and (hdv(i) or hdvafv(i)))   =  xket(r,"va",i,t-1);

    xk0(r,k,afv)$(ord(t)>1 and round(xk0(r,k,afv),6)=0  )               =  0;
    xk0(r,k,afv)$(ord(t)>1 and afv_kd0(r,afv,k,"extant")=0  )           =  0;

    xket(r,k,i,t)$(ord(t)>1)   = xk0(r,k,i);
    totcap(r,k,i,t)$(ord(t)>1) = (totcap(r,k,i,"2010") +  xket(r,k,i,"2010")) * gdp_trend(r,t)
                                 - xket(r,k,i,t);
    kprd_trend(r,k,t)        =     sum(i,totcap(r,k,i,t) - newcap(r,k,i,t)*(1-depr)**5)
                                 / (ror*5*inv0(r,k)*inv.l(r,k));
    kprd_trend(r,k,t)$(kprd_trend(r,k,t)<0) = kprd_trend(r,k,t-1);

    nk0(r,k)$(ord(t)>1)       = sum(i,newcap(r,k,i,t))*(1-depr)**5 +  kprd_trend(r,k,t)*  (ror*5*inv0(r,k)*inv.l(r,k));
    nket(r,k,t)$(ord(t)>1)    = nk0(r,k);

    hket(r,t)$(ord(t)>1) = hke0_10_(r)*gdp_trend(r,t);
    hke0(r)$(ord(t)>1)   = hket(r,t);

*EN3: update government expenditure, investment, balance of payment: grow proportionally with gdp endogenously
    gove0(r)              = gov0(r)* gdp_(r,t)/gdp_(r,"2010");
    inve0(r,k)$(ord(t)>1) = c_inve0(r,k,t)*inv0(r,k)*gdp_(r,t)/gdp_(r,"2010");
    bopdef0(r,hh)         = bopdeft0(r,hh,"2010")*gdp_(r,t)/gdp_(r,"2010");

*EN4: update land endowment for agricultural and natural land
    lnde0(r,agri,v)$(luc(r) and l_shr(r,agri) and ord(t)>1 )
       = dfl.l(r,agri,v)/l_shr(r,agri)/lnd_trend(r,agri,t-1)*lnd_trend(r,agri,t);

    rentv(r,nat)$(luc(r) and ord(t)>1) = sum(v,dfl.l(r,nat,v))/lnd_trend(r,nat,t-1)*lnd_trend(r,nat,t);

*EN5: Update natural land transformation function
*EN5a: Scale the fixed factor proportionately with the change in land area

    fffor(r,lu,v)$(ord(t)>1 and land_area(r,lu,'2010') and luc(r))
          = fffor0(r,lu,v)*land_area(r,lu,t) /land_area(r,lu,'2010')  ;

    fffor(r,"crop",v)$(ord(t)>1 and land_area(r,"crop",'2010') and luc(r))
          = fffor0(r,"crop",v)*(land_area(r,'total',t)-sum(lu$(not sameas(lu,"crop")),land_area(r,lu,t))) /land_area(r,'crop','2010')  ;

    fffor(r,lu,v)$(ord(t)>1 and fffor(r,lu,v)<0.00000001)   = 0;
    f_luc(r,lu,nat)$(ord(t)>1 and sum(v,fffor(r,nat,v))=0 ) = 0;
    f_luc(r,lu,lu_)$(ord(t)>1 and sum(v,fffor(r,lu_,v))=0 ) = 0;

    ffforT(r,lu,t)= sum(v, fffor(r,lu,v));

*EN5b: Update alpha_l based on benchmark cost share of fixed factor
    alpha_l(r,t,"nfrs",v)$(luc(r) and ord(t)>1 and vnum(v))  = fffor(r,"nfrs",v)/((lnd0(r,"frs",v)*(1-l_shr(r,"frs"))+(y0(r,"frs",v)*nat_tran(r,"nf_f")))/q_land0(r,"frs"));
    alpha_l(r,t,"ngrs",v)$(luc(r) and ord(t)>1 and vnum(v))  = fffor("ngrs",r,v)/v_land0(r,"liv");

    alpha_l(r,t,nat,v)$(luc(r) and ord(t)>1 and alpha_l(r,t,nat,v)<0.0000001 and vnum(v)) = alpha_l(r,t-1,nat,v);
    alpha_l(r,t,nat,v)$(luc(r) and ord(t)>1 and vnum(v) and alpha_l(r,t,nat,v)>alpha_l(r,t-1,nat,v) ) = alpha_l(r,t-1,nat,v);
    l_fx_el(r,nat,v)$(luc(r) and ord(t)>1 and vnum(v)) = nat_tran(r,"s_el")/(1-alpha_l(r,t,nat,v));
    l_fx_el(r,nat,v)$(luc(r) and ord(t)>1 and vnum(v))=l_fx_el(r,nat,v);
    l_fx_el(r,nat,v)$(luc(r) and ord(t)>1 and l_fx_el(r,nat,v)<0.02 and vnum(v)) = 0.02;

    l_fx_el("usa","ngrs",v)$vnum(v)   = 10*l_fx_el("Usa","ngrs",v);
    l_fx_el("chn","ngrs",v)$vnum(v)   = 10*l_fx_el("chn","ngrs",v);
    l_fx_el("eur","ngrs",v)$vnum(v)   = 10*l_fx_el("eur","ngrs",v);

    l_fx_el("XLM",lu,v)               = l_fx_el("BRA",lu,v);
    l_fx_elt(r,lu,t) = l_fx_el(r,lu,"new");

**EN6: update the consumption of goods as income goes up
    c_cd0(r,"auto",t) =  pop(r,t)/pop(r,"2010")
                       /(gdp(r,t)/gdp(r,"2010"))
                       *(VehOwnship(r,t)/VehOwnship(r,"2010"));
    c_cd0(r,"RodP",t) =  pop(r,t)/pop(r,"2010")
                       /(gdp(r,t)/gdp(r,"2010"))
                       *(VehOwnship(r,t)/VehOwnship(r,"2010"));
    c_cd0("USA","auto","2015") = 1.00;
    c_cd0("USA","auto","2020") = 0.95;

    cdt0(r,"hh",i,t)$(ord(t)>1 )    = c_cd0(r,i,t)*cd0_10_(r,"hh",i,"2010");
    cdt0(r,"hh","srv",t)$(ord(t)>1) = c0(r,"hh")-sum(i$(not sameas(i,"srv")),cdt0(r,"hh",i,t));

    c_cd0(r,i,t)$cd0_10_(r,"hh",i,"2010") = cdt0(r,"hh",i,t)/ cd0_10_(r,"hh",i,"2010");
    cd0(r,"hh",i)$(ord(t)>1)              = cdt0(r,"hh",i,t)$cd0(r,"hh",i);
