$title  ADAGE Model - Model Structure

    advswtch(r,advbio,"new") = yes;
    advswtch(r,"msce","new") = no;
    advswtch(r,"albd","new") = no;
    f_advgen(r,advee,v) =yes;

$ONTEXT
$model:adage

$sectors:
    y(r,s,v)$y0(r,s,v)                                              ! Production by industries and agriculture (by vintage)
    ffprod(r,ff,v)$y0(r,ff,v)                                       ! Fossil fuel production (by vintage)
    gen(r,i,v)$(y0(r,i,v) and (convi(i) or rnw(i)))                 ! Electricity generation (by vintage)
    advgen(r,i,v)$(y0(r,i,v) and f_advgen(r,i,v)  )                 ! Advanced electricity generation (by vintage)
    agen(r,i)$(y0(r,i,"new") and sameas(i,"ele"))                   ! Armington good for electricity

    biofuel(r,bio,v)$y0(r,bio,v)                                    ! Biofuels production
    advbiofuel(r,i,v)$(advswtch(r,i,v) and not sameas(i,"advb"))    ! Advanced biofuels production
    livfeed(r,s,v)$feed0(r,s,v)                                     ! Livestock feed

    x(r,i)$(sum(vnum,y0(r,i,vnum) ) and cru(i))                     ! Export goods transformation
    m(r,i)$(m0(r,i,"ftrd")   and not cru(i))                        ! Interregional trade
    a(r,i)$a0(r,i)                                                  ! Armington good
    yt                                                              ! Trade transport services
    inv(r,k)$inv0(r,k)                                              ! Investment
    gov(r)                                                          ! Government goods
    w(r,hh)                                                         ! Welfare - consumption of goods and leisure time of households
    c(r,hh)                                                         ! Household consumption
    house(r,hh,v)$house0(r,hh,v)                                    ! Housing (by vintage)

    oev_bio(r,e,i,v)$( ((ed0(r,e,"fuel","auto",v) and bioe(e)) or (f_bio(r,"ceth") and cobd(e) and new(v))) and (auto(i) or (f_hdvbio(r,i) and new(v))) )   ! First generation biofuel use in conventional onroad transportation
    oev_ff(r,e,i,v)$(ed0(r,e,"fuel",i,v) and oil(e) and (auto(i) or f_hdvbio(r,i)))              ! Fossil fuel use in conventional onroad transportation
    oev_adv(r,e,i,v)$(advbio(e) and advswtch(r,e,v) and not advb(e) and (auto(i) or f_hdvbio(r,i)) and new(v))   ! Advanced biofuel use in conventional onroad transportation
    oev_fuel(r,i,v)$(oev_valu0(r,i,v) and (auto(i) or f_hdvbio(r,i)))        ! Total fuel use in conventional onroad transportation
    afvtrn(r,afv,v)$(f_afv(r,afv,v) and new(v) )                             ! Alternative fuel vehicle technology for new vehicle
    afvtrn(r,afv,v)$(f_afv(r,afv,v) and extant(v) and sum(k,xk0(r,k,afv)))   ! Alternative fuel vehicle technology for used vehicle

    emkt(r,e,use,i)$((ertl0(r,e,use,i) and not gentype(i)) or (ertl0(r,e,use,i) and fuel(use) and (convrnw(i) or f_advgen(r,i,"new"))) or (hdvbio_ertl0(r,e,use,i) and f_hdvbio(r,i)))        ! Energy markets

    land(r)$(not luc(r))                                          ! Land transformation
    lnd_tran(r,lu,lu_,v)$(f_luc(r,lu,lu_) and luc(r) and new(v))  ! Land use transformation from one type to another
    lrent(r,lu,v)$(luc(r) and new(v) )                            ! Land transformation from rents to ha

    GHGemis(r,ghg)$(GHGtot0(r,ghg) and f_ghg(r,ghg))              ! Greenhouse gas emissions
    ghg2carb(r)$(ghgcarb(r) and f_co2(r) )                        ! Convert GHG to CO2eq to equilibrate prices in carbon tax scenarios

    nkt(r)                                                        ! production of new capital


$commodities:
    py(r,i)$((sum(v,y0(r,i,v)) and not gentype(i)) or (sum(v,y0(r,i,v)) and (convrnw(i) or f_advgen(r,i,"new"))) or (byprod(i) and sum(v,y0(r,i,v)) or (chg_bio(r,"ceth",i,"new")$(f_bio(r,"ceth") and cobd(i)) ) )  )       ! Price of output
    ped(r,e,use,i)$((ertl0(r,e,use,i) and not gentype(i)) or  (ertl0(r,e,use,i) and fuel(use) and (convrnw(i) or f_advgen(r,i,"new")))   or (advswtch(r,e,"new") and not advb(e)  and auto(i) and fuel(use)) )     ! Price of delivered energy goods)
    pcru                                          ! Price of homogeneous crude oil
    pl(r)                                         ! Price of labor
    rk(r,k)$(sum((new(v),i),kd0(r,k,i,v)  ))      ! Price of capital rental
    rkt(r)                                        ! Price of putty rental capital for rk
    rkx(r,k,i)$((xk0(r,k,i) and not gentype(i)) or (xk0(r,k,i) and (convrnw(i) or f_advgen(r,i,"extant"))))            ! Price of extant capital rental

    phk(r)$(sum((v,s), hkd0(r,s,v)  ))            ! Price of human capital
    plnd(r,i)$(sum(v,lnd0(r,i,v)  ))              ! Price of land returns
    pland(r)$(not luc(r))                         ! Price of land endowment
    pr(r,i)$(sum(v,rd0(r,i,v)  ))                 ! Price of natural resources
    prnw(r,i)$((rnw0(r,i,"new") and not gentype(i)) or (rnw0(r,i,"new") and (convrnw(i) or f_advgen(r,i,"new"))))                   ! Price of electricity resource

    pfeed(r,s)$(sum(v,feed0(r,s,v)  ))            ! Price of livestock feed
    pm(r,i)$(m0(r,i,"ftrd")   and not cru(i))     ! Price of import goods
    pt                                            ! Price of transport services
    pa(r,i)$a0(r,i)                               ! Price of Armington goods
    pg(r)$gov0(r)                                 ! Price of government good
    pinv(r,k)$inv0(r,k)                           ! Price of investment goods
    pcl(r,hh)                                     ! Price of welfare - consumption plus leisure time
    pc(r,hh)                                      ! Price of consumption
    phous(r,hh)$(sum(v,house0(r,hh,v)  ))         ! Price of housing

    pco2(r)$(f_co2(r) or f_ele(r))                ! Price of carbon emissions
    pghg(r,ghg)$f_ghg(r,ghg)                      ! price of GHG
    Pghgendow(r)$sum(ghg,f_ghg(r,ghg))            ! price of GHG

    plrent(r,lu)$luc(r)                           ! Land rents
    plnuse(r,nat)$rentv(r,nat)$luc(r)             ! Land rents on welfare function
    plff(r,lu)$luc(r)                             ! Price of fixed factor to reflect land supply elasticity

    Pedm(r,e)$((ob(e) and ed0(r,e,"fuel","auto","new")) or (advbio(e) and advswtch(r,e,"new") and not advb(e)) or (f_bio(r,"ceth") and cobd(e)))    ! Price of fuel in onroad transportation
    pedh(r,e,i)$(f_hdvbio(r,i) and oil(e) and ed0(r,e,"fuel",i,"New") )           ! Price of fuel in HDV transportation
    poev(r,i)$(oev_valu0(r,i,"new") and (auto(i) or f_hdvbio(r,i)))               ! Price of fuel in onroad transportation

    pafvff(r,i)$(f_afv(r,i,"new") and afv_ff0(r,i,"new"))                         ! fixed factor price for afv
    ptrnff(r,i)$(trnv(i) and f_trn(r,i,"new") )                                   ! fixed factor price for afv
    pmpge(r,i)$(targt_mpge(r,i))

$consumers:
    rh(r,hh)                                         ! Representative household

$auxiliary:
    ghgscale(r)$(ctax(r) and sum(ghg,f_ghg(r,ghg)))  ! Adjustment on GHG prices
    carbtax(r)$(ctax(r) and f_co2(r))                ! Carbon tax
    pcrupath(r)$f_cru(r)                             ! Exogenous crude oil price path
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*



*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*** --   INDUSTRIAL & AGRICULTURAL PRODUCTION   -- ***
*        Agricultural production (new / flexible):
$prod:y(r,s,v)$(y0(r,s,v)   and new(v) and agr(s) and not liv(s))     s:0
+         nCO2(s):CO2_elas(r,s)    CO2.tl(nCO2):0
+         nCH4(s):CH4_elas(r,s)    CH4.tl(nCH4):0
+         nN2O(nCH4):N2O_elas(r,s) N2O.tl(nN2O):0
+         all(nN2O):erva_elas(s)   er(all):er_elas(r,s)    va(all):1
+         ae(er):ae_elas(s)        mat(ae):0               mat.tl(mat):0
+         enoe(ae):enoe_elas(s)    ele.tl(enoe):0          en(enoe):en_elas(s)     cgo.tl(en):0

    o:py(r,s)                               q:y0(r,s,v)                                                     a:rh(r,"hh")   t:ty(r,s)
    i:pghg(r,ghg)$(f_ghg(r,ghg))            q:(0.001*ghg0(r,ghg,s,v))       ghg.tl:
    i:ped(r,e,use,s)                        q:ed0(r,e,use,s,v)              e.tl:
    i:pa(r,g)                               q:id0(r,g,s,v)                  g.tl:   p:pid0(r,g,s)           a:rh(r,"hh")   t:ti(r,g,s)
    i:pl(r)                                 q:ld0(r,s,v)                    va:     p:pld0(r,s)             a:rh(r,"hh")   t:tl(r,s)
    i:rk(r,k)                               q:kd0(r,k,s,v)                  va:     p:pkd0(r,k,s)           a:rh(r,"hh")   t:tk(r,k,s)
    i:phk(r)                                q:hkd0(r,s,v)                   va:     p:phkd0(r,s)            a:rh(r,"hh")   t:thk(r,s)
    i:plnd(r,s)$(not crp(s))                q:lnd0(r,s,v)                   er:     p:plnd0(r,s)            a:rh(r,"hh")   t:tn(r,s)
    i:plnd(r,"crop")$crp(s)                 q:crp_lnd0(r,s,v)               er:     p:plnd0(r,s)            a:rh(r,"hh")   t:tn(r,s)
    i:pr(r,s)                               q:rd0(r,s,v)                    va:     p:prd0(r,s)             a:rh(r,"hh")   t:tr(r,s)

*        Industrial Production (non-ag and non-onroad transportation) (new / flexible):
$prod:y(r,s,v)$(y0(r,s,v)   and new(v) and not agr(s) and not trnv(s))
+         t:0     s:0
+         nCO2(s):CO2_elas(r,s)    CO2.tl(nCO2):0
+         nCH4(s):CH4_elas(r,s)    CH4.tl(nCH4):0
+         nN2O(nCH4):N2O_elas(r,s) N2O.tl(nN2O):0
+         nHFC(nN2O):HFC_elas(r,s) HFC.tl(nHFC):0
+         nPFC(nHFC):PFC_elas(r,s) PFC.tl(nPFC):0
+         nSF6(nPFC):SF6_elas(r,s) SF6.tl(nSF6):0
*+        all(nsf6):0              mat.tl(all):1      fdst(all):1             eva(all):eva_elas(s)      va(eva):1
+         all(nsf6):0              mat.tl(all):0      fdst(all):1             eva(all):eva_elas(s)      va(eva):1
+         enoe(eva):enoe_elas(s)   ele.tl(enoe):0     en(enoe):en_elas(s)     cgo.tl(en):0   et.tl(en):0 bd.tl(en):0 ad.tl(en):0

    o:py(r,"omel")$vol(s)                   q:y0(r,"omel",v)
    o:py(r,s)                               q:y0(r,s,v)                                                       a:rh(r,"hh")   t:ty(r,s)
    i:pghg(r,ghg)$f_ghg(r,ghg)              q:(0.001*ghg0(r,ghg,s,v))                ghg.tl:
    i:ped(r,e,use,s)$(not fdst(use) and f_hdvbio(r,s)=0)   q:(ed0(r,e,use,s,v))      e.tl:
    i:ped(r,e,use,s)$(fdst(use) and f_hdvbio(r,s)=0)       q:(ed0(r,e,use,s,v))      fdst:
    i:poev(r,s)$(f_aggtrn=1 and f_hdvbio(r,s))             q:(sum(e$ob(e),ed0(r,e,"fuel",s,v)))           en:
    i:ped(r,e,use,s)$(f_aggtrn=1 and f_hdvbio(r,s) and not ob(e))  q:(ed0(r,e,use,s,v))                   en:

    i:pa(r,g)                               q:id0(r,g,s,v)                           g.tl:   p:pid0(r,g,s)     a:rh(r,"hh")   t:ti(r,g,s)
    i:pl(r)                                 q:ld0(r,s,v)                             va:     p:pld0(r,s)       a:rh(r,"hh")   t:tl(r,s)
    i:rk(r,k)                               q:kd0(r,k,s,v)                           va:     p:pkd0(r,k,s)     a:rh(r,"hh")   t:tk(r,k,s)
    i:phk(r)                                q:hkd0(r,s,v)                            va:     p:phkd0(r,s)      a:rh(r,"hh")   t:thk(r,s)

*        Industrial and Agricultural Production (extant / existing):
$prod:y(r,s,v)$(y0(r,s,v)   and extant(v) and not trnv(s))      t:0         s:0
+         nCO2(s):CO2_elas(r,s)    CO2.tl(nCO2):0
+         nCH4(s):CH4_elas(r,s)    CH4.tl(nCH4):0
+         nN2O(nCH4):N2O_elas(r,s) N2O.tl(nN2O):0
+         nHFC(nN2O):HFC_elas(r,s) HFC.tl(nHFC):0
+         nPFC(nHFC):PFC_elas(r,s) PFC.tl(nPFC):0
+         nSF6(nPFC):SF6_elas(r,s) SF6.tl(nSF6):0
+         all(nSF6):0

    o:py(r,"omel")$vol(s)                   q:y0(r,"omel",v)
    o:py(r,s)                               q:y0(r,s,v)                                                     a:rh(r,"hh")   t:ty(r,s)
    i:pghg(r,ghg)$f_ghg(r,ghg)              q:(0.001*ghg0(r,ghg,s,v))               ghg.tl:
    i:ped(r,e,use,s)$(not fdst(use) and f_hdvbio(r,s)=0)   q:(ed0(r,e,use,s,v))     all:
    i:ped(r,e,use,s)$(fdst(use) and f_hdvbio(r,s)=0)       q:(ed0(r,e,use,s,v))     all:
*    i:poev(r,s)$(f_hdvbio(r,s))                           q:(oev_valu0(r,s,v))     all:
    i:poev(r,s)$(f_hdvbio(r,s))                            q:(sum(e,ed0(r,e,"fuel",s,v)))     all:

    i:pa(r,g)                               q:id0(r,g,s,v)                          all:    p:pid0(r,g,s)           a:rh(r,"hh")   t:ti(r,g,s)
    i:pl(r)                                 q:ld0(r,s,v)                            all:    p:pld0(r,s)             a:rh(r,"hh")   t:tl(r,s)
    i:rkx(r,k,s)                            q:kd0(r,k,s,v)                          all:    p:pkd0(r,k,s)           a:rh(r,"hh")   t:tk(r,k,s)
    i:phk(r)                                q:hkd0(r,s,v)                           all:    p:phkd0(r,s)            a:rh(r,"hh")   t:thk(r,s)
    i:plnd(r,s)$(not crp(s))                q:lnd0(r,s,v)                           all:    p:plnd0(r,s)            a:rh(r,"hh")   t:tn(r,s)
    i:plnd(r,"crop")$crp(s)                 q:crp_lnd0(r,s,v)                       all:    p:plnd0(r,s)            a:rh(r,"hh")   t:tn(r,s)
    i:pr(r,s)                               q:rd0(r,s,v)                            all:    p:prd0(r,s)             a:rh(r,"hh")   t:tr(r,s)
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*




*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*** --   LIVESTOCK & FEED PRODUCTION   -- ***
*        Livestock production (new / flexible):
$prod:y(r,s,v)$(y0(r,s,v)   and new(v) and liv(s))    s:0
+         nCO2(s):CO2_elas(r,s)    CO2.tl(nCO2):0
+         nCH4(s):CH4_elas(r,s)    CH4.tl(nCH4):0
+         nN2O(nCH4):N2O_elas(r,s) N2O.tl(nN2O):0
+         all(nN2O):erva_elas(s)   er(all):er_elas(r,s)    va(all):1
+         ae(er):ae_elas(s)        mat(ae):0               mat.tl(mat):0
+         enoe(ae):enoe_elas(s)    ele.tl(enoe):0          en(enoe):en_elas(s)     cgo.tl(en):0

    o:py(r,s)                               q:y0(r,s,v)                                                     a:rh(r,"hh")   t:ty(r,s)
    i:pghg(r,ghg)$f_ghg(r,ghg)              q:(0.001*ghg0(r,ghg,s,v))               ghg.tl:
    i:pfeed(r,s)                            q:feed0(r,s,v)
    i:ped(r,e,use,s)                        q:ed0(r,e,use,s,v)              e.tl:
    i:pa(r,g)$(not (feed(g) or ofd(g)))     q:id0(r,g,s,v)                  g.tl:   p:pid0(r,g,s)           a:rh(r,"hh")   t:ti(r,g,s)
    i:pl(r)                                 q:ld0(r,s,v)                    va:     p:pld0(r,s)             a:rh(r,"hh")   t:tl(r,s)
    i:rk(r,k)                               q:kd0(r,k,s,v)                  va:     p:pkd0(r,k,s)           a:rh(r,"hh")   t:tk(r,k,s)
    i:phk(r)                                q:hkd0(r,s,v)                   va:     p:phkd0(r,s)            a:rh(r,"hh")   t:thk(r,s)
    i:plnd(r,s)                             q:lnd0(r,s,v)                   er:     p:plnd0(r,s)            a:rh(r,"hh")   t:tn(r,s)
    i:pr(r,s)                               q:rd0(r,s,v)                    va:     p:prd0(r,s)             a:rh(r,"hh")   t:tr(r,s)

*        Feed and byproducts in livestock:
$prod:livfeed(r,s,v)$feed0(r,s,v)             s:10
+         corn(s):10      crp.tl(corn):0    ddgs(corn):0
+         voil(s):10      vol.tl(voil):0    omel(voil):0
+         ofd.tl(s):0
    o:pfeed(r,s)                            q:feed0(r,s,v)
    i:pa(r,g)$(feed(g) or ofd(g))           q:id0(r,g,s,v)                  g.tl:   p:pid0(r,g,s)           a:rh(r,"hh")   t:ti(r,g,s)
    i:pa(r,"ddgs")                          q:id0(r,"ddgs",s,v)             ddgs:
    i:pa(r,"omel")                          q:id0(r,"omel",s,v)             omel:
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*



*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*** --   BIOFUELS PRODUCTION   -- ***
*        Biofuels production:
* Natural gas is not used in ceth and sybd in USA in 2010 but added in later years
$prod:biofuel(r,bio,v)$y0(r,bio,v)
+         t:0      s:0.3     e.tl(s):0       agr.tl(s):0  vol.tl(s):0   nagr(s):0       va(nagr):1
+         biog.tl(nagr):0

    o:py(r,bio)                                              q:(y0(r,bio,v)   + chg_bio(r,bio,"y0",v)$f_bio(r,bio))
    o:py(r,"ddgs")$ceth(bio)                                 q:(y0(r,"ddgs",v)+ chg_bio(r,bio,"ddgs",v)$f_bio(r,bio))
    o:py(r,"cobd")$(f_bio(r,bio) and ceth(bio))              q:(chg_bio(r,bio,"cobd",v))
    o:py(r,"omel")$(f_bio(r,bio) and sybd(bio))              q:chg_bio(r,bio,"omel",v)

    i:ped(r,e,use,bio)$(ed0(r,e,use,bio,v) and fuel(use))    q:(ed0(r,e,use,bio,v) + chg_bio(r,bio,e,v)$f_bio(r,bio))    e.tl:
    i:pa(r,e)$(ed0(r,e,"fuel",bio,v)=0 and ff(e) and chg_bio(r,bio,e,v)$f_bio(r,bio))     q:(chg_bio(r,bio,e,v))         e.tl:
    i:pa(r,g)                                                q:(id0(r,g,bio,v)+ chg_bio(r,bio,g,v)$f_bio(r,bio))         g.tl:   p:pid0(r,g,bio)   a:rh(r,"hh")   t:ti(r,g,bio)
    i:pl(r)                                                  q:(ld0(r,bio,v)  + chg_bio(r,bio,"ld",v)$f_bio(r,bio))      va:
    i:rk(r,k)                                                q:(kd0(r,k,bio,v)+ chg_bio(r,bio,k,v)$f_bio(r,bio))         va:

*        Advanced biofuels production:
$prod:advbiofuel(r,advbio,v)$(advswtch(r,advbio,v))   t:0     s:0

    o:ped(r,advbio,"fuel","auto")           q:1
    o:py(r,"ele")$swge(advbio)              q:advbiocoy0(r,advbio)

    i:plnd(r,"crop")$(not frwe(advbio))     q:(advbiolnd0(r,advbio))                            p:plnd0(r,advbio)       a:rh(r,"hh")   t:tn(r,advbio)
    i:plnd(r,"frs")$(frwe(advbio))          q:(advbiolnd0(r,advbio))                            p:plnd0(r,advbio)       a:rh(r,"hh")   t:tn(r,advbio)
    i:pl(r)                                 q:(advbiold0(r,advbio)*advbiomkup(r,advbio))        p:pld0(r,advbio)        a:rh(r,"hh")   t:tl(r,advbio)
    i:rk(r,"va")                            q:(advbiokd0(r,"va",advbio)*advbiomkup(r,advbio))   p:pkd0(r,"va",advbio)   a:rh(r,"hh")   t:tk(r,"va",advbio)
    i:pa(r,g)                               q:(advbioid0(r,g,advbio)*advbiomkup(r,advbio))
    i:pa(r,e)                               q:(advbioed0(r,e,advbio)*advbiomkup(r,advbio))
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*



*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*** --      LAND USE & TRANSFORMATION  -- ***
*** --                      -- ***
*        Land transformation:
$prod:land(r)$(not luc(r) )            t:0.2   crp.tl(t):20    liv.tl(t):0     frs.tl(t):0
    o:plnd(r,s)                             q:(sum(vnum,lnd0(r,s,vnum)))          s.tl:
    o:plnd(r,"crop")                        q:(sum(vnum,lnd0(r,"crop",vnum)))
    i:pland(r)                              q:land0(r)

*        Land transformation:
$prod:lrent(r,agri,v)$(luc(r) and new(v))
    o:plnd(r,agri)                        q:lnd0(r,agri,v)
    i:plrent(r,agri)                      q:lnd0(r,agri,v)

*        Value of natural land per ha
$prod:lrent(r,nat,v)$rentv(r,nat)$(luc(r) and new(v) )
    o:plnuse(r,nat)$ngrs(nat)             q:rentv0(r,nat)
    i:plrent(r,nat)$ngrs(nat)             q:rentv0(r,nat)
    o:plnuse(r,nat)$nfrs(nat)             q:(rentv0(r,nat)-(lnd0(r,"frs",v)*(1-l_shr(r,"frs"))*nat_tran(r,"inp")))
    i:plrent(r,nat)$nfrs(nat)             q:(rentv0(r,nat)-(lnd0(r,"frs",v)*(1-l_shr(r,"frs"))*nat_tran(r,"inp")))

*        Land use transformation among agricultural sectors:
$prod:lnd_tran(r,agri,agrii,v)$(f_luc(r,agri,agrii)$luc(r) and new(v) )  s:0
+         aa:esub_flnd(agri)            all(aa):erva_elas(agri) er(all):er_elas(r,agri)    va(all):1
+         ae(er):ae_elas(agri)          mat(ae):0               mat.tl(mat):0
+         enoe(ae):enoe_elas(agri)      ele.tl(enoe):0          en(enoe):en_elas(agri)     cgo.tl(en):0

    o:plrent(r,agri)                      q:(npp(r,agri)*v_land0(r,agri))

    i:plrent(r,agrii)                     q:(npp(r,agrii)*v_land0(r,agrii))
    i:ped(r,e,use,g)                      q:(npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shre(r,agrii,e,use,g,v))      e.tl:
    i:pa(r,g)                             q:(npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agrii,g,v))      g.tl:
    i:pl(r)                               q:(npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agrii,'L',v))    va:
    i:rk(r,k)                             q:(npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agrii,K,v))      va:
    i:phk(r)                              q:(npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agrii,'hk',v))   va:
    i:pr(r,agrii)                         q:(npp(r,agrii)*mk_luc(r,agri,agrii)*rent_r0(r,agri,agrii)*ag_shr(r,agrii,'r',v))    va:
    i:plff(r,agrii)                       q:(npp(r,agrii)*mk_luc(r,agri,agrii)*fffor(r,agrii,v))                               aa:

*        Land use transformation from agricultural sectors to natural land:
$prod:lnd_tran(r,nat,agri,v)$(f_luc(r,nat,agri) and luc(r)  and new(v) ) s:0
+         aa:esub_flnd(nat)         all(aa):erva_elas(nat)  er(all):er_elas(r,nat)    va(all):1
+         ae(er):ae_elas(nat)       mat(ae):0               mat.tl(mat):0
+         enoe(ae):enoe_elas(nat)   ele.tl(enoe):0          en(enoe):en_elas(nat)     cgo.tl(en):0

    o:plrent(r,nat)                       q:(npp(r,nat)*v_land0(r,nat))
    i:plrent(r,agri)                      q:(npp(r,agri)*v_land0(r,agri))
    i:ped(r,e,use,g)                      q:(npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shre(r,agri,e,use,g,v))  e.tl:
    i:pa(r,g)                             q:(npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,g,v))      g.tl:
    i:pl(r)                               q:(npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,'L',v))    va:
    i:rk(r,k)                             q:(npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,k,v))      va:
    i:phk(r)                              q:(npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,'hk',v))   va:
    i:pr(r,agri)                          q:(npp(r,agri)*mk_luc(r,nat,agri)*rent_r0(r,nat,agri)*ag_shr(r,agri,'r',v))    va:
    i:plff(r,agri)                        q:(npp(r,agri)*mk_luc(r,nat,agri)*fffor(r,agri,v))                             aa:

*        Land use transformation from natural grassland to agricultural sectors :
$prod:lnd_tran(r,agri,ngrs,v)$(rentv(r,ngrs) and f_luc(r,agri,ngrs) and luc(r)  and new(v) )   s:0 t:0
+         aa:l_fx_el(r,ngrs,v)       all(aa):erva_elas(agri)   er(all):er_elas(r,agri)    va(all):1
+         ae(er):ae_elas(agri)       mat(ae):0                 mat.tl(mat):0
+         enoe(ae):enoe_elas(agri)   ele.tl(enoe):0            en(enoe):en_elas(agri)     cgo.tl(en):0

    o:plrent(r,agri)                      q:(npp(r,agri)*v_land0(r,agri))
    o:py(r,agri)                          q:(npp(r,ngrs)*lndout(r,ngrs,v))      a:rh(r,"hh")   t:ty(r,agri)
    i:plrent(r,ngrs)                      q:(npp(r,ngrs)*v_land0(r,ngrs))
    i:ped(r,e,use,g)                      q:(npp(r,ngrs)*mk_luc(r,agri,ngrs)*otinp(r,ngrs,v)*ag_shre(r,agri,e,use,g,v))  e.tl:
    i:pa(r,g)                             q:(npp(r,ngrs)*mk_luc(r,agri,ngrs)*otinp(r,ngrs,v)*ag_shr(r,agri,g,v))         g.tl:
    i:pl(r)                               q:(npp(r,ngrs)*mk_luc(r,agri,ngrs)*otinp(r,ngrs,v)*ag_shr(r,agri,'L',v))       va:
    i:rk(r,k)                             q:(npp(r,ngrs)*mk_luc(r,agri,ngrs)*otinp(r,ngrs,v)*ag_shr(r,agri,k,v))         va:
    i:phk(r)                              q:(npp(r,ngrs)*mk_luc(r,agri,ngrs)*otinp(r,ngrs,v)*ag_shr(r,agri,'hk',v))      va:
    i:pr(r,agri)                          q:(npp(r,ngrs)*mk_luc(r,agri,ngrs)*otinp(r,ngrs,v)*ag_shr(r,agri,'r',v))       va:
    i:plff(r,ngrs)                        q:(npp(r,ngrs)*mk_luc(r,agri,ngrs)*fffor(r,ngrs,v))                            aa:

*        Land use transformation from natural forestland to agricultural sectors :
$prod:lnd_tran(r,agri,nfrs,v)$(rentv(r,nfrs) and f_luc(r,agri,nfrs) and luc(r)  and new(v) )   s:0 t:0
*Coproduct timber is produced when natural forest is converted to ag land
+         aa:l_fx_el(r,nfrs,v)       all(aa):erva_elas(agri)  er(all):er_elas(r,agri)    va(all):1
+         ae(er):ae_elas(agri)       mat(ae):0                mat.tl(mat):0
+         enoe(ae):enoe_elas(agri)   ele.tl(enoe):0           en(enoe):en_elas(agri)     cgo.tl(en):0

    o:plrent(r,agri)                      q:(npp(r,agri)*v_land0(r,agri))
    o:py(r,agri)                          q:(npp(r,nfrs)*lndout(r,nfrs,v))      a:rh(r,"hh")   t:ty(r,agri)
    i:plrent(r,nfrs)                      q:(npp(r,nfrs)*v_land0(r,nfrs))
    i:ped(r,e,use,g)                      q:(npp(r,nfrs)*mk_luc(r,agri,nfrs)*otinp(r,nfrs,v)*ag_shre(r,agri,e,use,g,v))  e.tl:
    i:pa(r,g)                             q:(npp(r,nfrs)*mk_luc(r,agri,nfrs)*otinp(r,nfrs,v)*ag_shr(r,agri,g,v))      g.tl:
    i:pl(r)                               q:(npp(r,nfrs)*mk_luc(r,agri,nfrs)*otinp(r,nfrs,v)*ag_shr(r,agri,'L',v))    va:
    i:rk(r,k)                             q:(npp(r,nfrs)*mk_luc(r,agri,nfrs)*otinp(r,nfrs,v)*ag_shr(r,agri,k,v))      va:
    i:phk(r)                              q:(npp(r,nfrs)*mk_luc(r,agri,nfrs)*otinp(r,nfrs,v)*ag_shr(r,agri,'hk',v))   va:
    i:pr(r,agri)                          q:(npp(r,nfrs)*mk_luc(r,agri,nfrs)*otinp(r,nfrs,v)*ag_shr(r,agri,'r',v))    va:
    i:plff(r,nfrs)                        q:(npp(r,nfrs)*mk_luc(r,agri,nfrs)*fffor(r,nfrs,v))                         aa:
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*




*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*** --   VEHICLE MILES TRAVELED -- ***
*        Conventional HDV transportation production (new / flexible)::
$prod:y(r,s,v)$(y0(r,s,v)   and new(v) and hdv(s))
+         t:0        s:0
+         nCO2(s):CO2_elas(r,s)    CO2.tl(nCO2):0
+         nCH4(s):CH4_elas(r,s)    CH4.tl(nCH4):0
+         nN2O(nCH4):N2O_elas(r,s) N2O.tl(nN2O):0
+         nHFC(nN2O):HFC_elas(r,s) HFC.tl(nHFC):0
+         nPFC(nHFC):PFC_elas(r,s) PFC.tl(nPFC):0
+         nSF6(nPFC):SF6_elas(r,s) SF6.tl(nSF6):0
+         all(nsf6):afv_elas(s)     mat.tl(all):0           eva(all):eva_elas(s)  va(eva):1
+         enoe(eva):enoe_elas(s)   ele.tl(enoe):0          en(enoe):en_elas(s)   cgo.tl(en):0          et.tl(en):0  bd.tl(en):0  ad.tl(en):0

    o:py(r,"omel")$vol(s)                   q:y0(r,"omel",v)
    o:py(r,s)                               q:y0(r,s,v)                                            a:rh(r,"hh")   t:ty(r,s)
    i:pghg(r,ghg)$f_ghg(r,ghg)              q:(0.001*ghg0(r,ghg,s,v))                              ghg.tl:
    i:ped(r,e,use,s)$(not fdst(use) and f_hdvbio(r,s)=0)   q:(ed0(r,e,use,s,v)*mk(r,s,"ed0",v))    e.tl:
    i:poev(r,s)$(f_hdvbio(r,s))                            q:(ed0(r,"oil","fuel",s,v)*mk(r,s,"ed0",v))            en:
    i:ped(r,e,"fuel",s)$(f_hdvbio(r,s) and not oil(e))     q:(ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v))                e.tl:

    i:pa(r,g)                               q:(id0(r,g,s,v)*mk(r,s,"id0",v))                       g.tl:    p:pid0(r,g,s)   a:rh(r,"hh")   t:ti(r,g,s)
    i:pl(r)                                 q:(ld0(r,s,v)*mk(r,s,"ld0",v))                         va:      p:pld0(r,s)     a:rh(r,"hh")   t:tl(r,s)
    i:rk(r,k)$(f_trn(r,s,"new") and kd0(r,k,s,v))    q:((kd0(r,k,s,v)-0.001*y0(r,s,v))*mk(r,s,"kd0",v))     va:      p:pkd0(r,k,s)   a:rh(r,"hh")   t:tk(r,k,s)
    i:rk(r,k)$(f_trn(r,s,"new")=0 and kd0(r,k,s,v))  q:(kd0(r,k,s,v)*mk(r,s,"kd0",v))                       va:      p:pkd0(r,k,s)   a:rh(r,"hh")   t:tk(r,k,s)
    i:phk(r)                                         q:(hkd0(r,s,v)*mk(r,s,"hkd0",v))                       va:      p:phkd0(r,s)    a:rh(r,"hh")   t:thk(r,s)

    o:pmpge(r,s)$(f_aggtrn=0 and targt_mpge(r,s) and rodf(s))          q:(tran_vmt0(r,s)*(pmt("rodf")/targt_mpge(r,s)))
    i:pmpge(r,s)$(f_aggtrn=0 and targt_mpge(r,s) and rodf(s))          q:(pmt("rodf")*sum(e,ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v)*btu_conv(r,e,"fuel",s)/btu_gal("oil")))  en:

    o:pmpge(r,s)$(f_aggtrn=0 and targt_mpge(r,s) and rodp(s))          q:(tran_vmt0(r,s)*(pmt("rodp")/targt_mpge(r,s)))
    i:pmpge(r,s)$(f_aggtrn=0 and targt_mpge(r,s) and rodp(s))          q:(pmt("rodp")*sum(e,ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v)*btu_conv(r,e,"fuel",s)/btu_gal("oil")))  en:

    i:ptrnff(r,s)$(f_trn(r,s,"new") )                   q:(0.001*y0(r,s,v))                        all:

*        Conventional HDV transportation production:
$prod:y(r,s,v)$(y0(r,s,v)   and extant(v) and hdv(s))
+         t:0     s:0
+         nCO2(s):CO2_elas(r,s)    CO2.tl(nCO2):0
+         nCH4(s):CH4_elas(r,s)    CH4.tl(nCH4):0
+         nN2O(nCH4):N2O_elas(r,s) N2O.tl(nN2O):0
+         nHFC(nN2O):HFC_elas(r,s) HFC.tl(nHFC):0
+         nPFC(nHFC):PFC_elas(r,s) PFC.tl(nPFC):0
+         nSF6(nPFC):SF6_elas(r,s) SF6.tl(nSF6):0
+         all(nSF6):0
    o:py(r,"omel")$vol(s)                   q:y0(r,"omel",v)
    o:py(r,s)                               q:y0(r,s,v)                                                      a:rh(r,"hh")   t:ty(r,s)
    i:pghg(r,ghg)$f_ghg(r,ghg)              q:(0.001*ghg0(r,ghg,s,v))                ghg.tl:
    i:ped(r,e,use,s)$(not fdst(use) and f_hdvbio(r,s)=0)     q:(ed0(r,e,use,s,v)*mk(r,s,"ed0",v))
    i:poev(r,s)$(f_hdvbio(r,s))                              q:(ed0(r,"oil","fuel",s,v)*mk(r,s,"ed0",v))
    i:ped(r,e,"fuel",s)$(f_hdvbio(r,s) and not oil(e))       q:(ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v))

    i:pa(r,g)                               q:(id0(r,g,s,v)*mk(r,s,"id0",v))         p:pid0(r,g,s)           a:rh(r,"hh")   t:ti(r,g,s)
    i:pl(r)                                 q:(ld0(r,s,v)  *mk(r,s,"ld0",v))         p:pld0(r,s)             a:rh(r,"hh")   t:tl(r,s)
    i:rkx(r,k,s)                            q:(kd0(r,k,s,v)*mk(r,s,"kd0",v))         p:pkd0(r,k,s)           a:rh(r,"hh")   t:tk(r,k,s)
    i:phk(r)                                q:(hkd0(r,s,v) *mk(r,s,"hkd0",v))        p:phkd0(r,s)            a:rh(r,"hh")   t:thk(r,s)
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*




*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*        Primary, Secondary, Retail Energy           *
$prod:ffprod(r,ff,v)$y0(r,ff,v)  s:0
+         nCO2(s):CO2_elas(r,ff)      CO2.tl(nCO2):0
+         nCH4(s):CH4_elas(r,ff)      CH4.tl(nCH4):0
+         nN2O(nCH4):N2O_elas(r,ff)   N2O.tl(nN2O):0
+         nres(nN2O):esub_nr(r,ff)    mat(nres):0      mat.tl(mat):0   va(mat):1       e.tl(mat):0

    o:py(r,ff)                              q:y0(r,ff,v)                    a:rh(r,"hh")   t:ty(r,ff)
    i:pghg(r,ghg)$f_ghg(r,ghg)              q:(0.001*ghg0(r,ghg,ff,v))      ghg.tl:
    i:ped(r,e,use,ff)                       q:ed0(r,e,use,ff,v)             e.tl:
    i:pa(r,g)                               q:id0(r,g,ff,v)                 g.tl:   p:pid0(r,g,ff)          a:rh(r,"hh")   t:ti(r,g,ff)
    i:pl(r)                                 q:ld0(r,ff,v)                   va:     p:pld0(r,ff)            a:rh(r,"hh")   t:tl(r,ff)
    i:rk(r,k)                               q:kd0(r,k,ff,v)                 va:     p:pkd0(r,k,ff)          a:rh(r,"hh")   t:tk(r,k,ff)
    i:pr(r,ff)                              q:rd0(r,ff,v)                   nres:   p:pref_nr(r,ff)         a:rh(r,"hh")   t:tr(r,ff)

*        Electricity generation - conventional fossil fuels (new / flexible):
$prod:gen(r,convi,v)$(y0(r,convi,v) and new(v))          s:0
+         nCH4(s):CH4_elas(r,"ele")     CH4.tl(nCH4):0
+         nN2O(nCH4):N2O_elas(r,"ele")  N2O.tl(nN2O):0
+         nSF6(nN2O):SF6_elas(r,"ele")  SF6.tl(nSF6):0
+         all(nSF6):esub_gen(r,convi)   mat.tl(all):0
+         eva(all):0                    va(eva):1

    o:py(r,convi)                           q:y0(r,convi,v)                                                       a:rh(r,"hh")   t:ty(r,convi)
    i:pghg(r,ghg)$f_ghg(r,ghg)              q:(0.001*ghg0(r,ghg,"ele",v))        ghg.tl:
    i:ped(r,e,use,convi)$(fuel(use))        q:ed0(r,e,use,convi,v)               eva:
    i:pa(r,g)                               q:id0(r,g,convi,v)                   g.tl:   p:pid0(r,g,convi)        a:rh(r,"hh")   t:ti(r,g,convi)
    i:pl(r)                                 q:ld0(r,convi,v)                     va:     p:pld0(r,convi)          a:rh(r,"hh")   t:tl(r,convi)
    i:rk(r,k)                               q:kd0(r,k,convi,v)                   va:     p:pkd0(r,k,convi)        a:rh(r,"hh")   t:tk(r,k,convi)
    i:prnw(r,convi)                         q:rnw0(r,convi,v)                    all:


*        Electricity generation - conventional fossil fuels (extant / existing):
$prod:gen(r,convi,v)$(y0(r,convi,v)   and extant(v))       s:0

    o:py(r,convi)                           q:y0(r,convi,v)                                                  a:rh(r,"hh")   t:ty(r,convi)
    i:pghg(r,ghg)$f_ghg(r,ghg)              q:(0.001*ghg0(r,ghg,"ele",v))
    i:ped(r,e,use,convi)$(fuel(use))        q:ed0(r,e,use,convi,v)
    i:pa(r,g)                               q:id0(r,g,convi,v)                       p:pid0(r,g,convi)        a:rh(r,"hh")   t:ti(r,g,convi)
    i:pl(r)                                 q:ld0(r,convi,v)                         p:pld0(r,convi)          a:rh(r,"hh")   t:tl(r,convi)
    i:rkx(r,k,convi)                        q:kd0(r,k,convi,v)                       p:pkd0(r,k,convi)        a:rh(r,"hh")   t:tk(r,k,convi)

*        Electricity generation - nuclear and renewables:
$prod:gen(r,rnw,v)$(y0(r,rnw,v)   and new(v))    t:0     s:0
+         res(s):esub_gen(r,rnw)      mat(res):0      mat.tl(mat):0   va(mat):1

    o:py(r,rnw)                             q:y0(r,rnw,v)                                                   a:rh(r,"hh")   t:ty(r,rnw)
    i:pa(r,g)                               q:id0(r,g,rnw,v)                g.tl:   p:pid0(r,g,rnw)         a:rh(r,"hh")   t:ti(r,g,rnw)
    i:pl(r)                                 q:ld0(r,rnw,v)                  va:     p:pld0(r,rnw)           a:rh(r,"hh")   t:tl(r,rnw)
    i:rk(r,k)                               q:kd0(r,k,rnw,v)                va:     p:pkd0(r,k,rnw)         a:rh(r,"hh")   t:tk(r,k,rnw)
    i:prnw(r,rnw)                           q:rnw0(r,rnw,v)                 res:    p:pref_gen(r,rnw)

$prod:gen(r,rnw,v)$(y0(r,rnw,v)   and extant(v))    t:0     s:0
    o:py(r,rnw)                             q:y0(r,rnw,v)                                             a:rh(r,"hh")   t:ty(r,rnw)
    i:pa(r,g)                               q:id0(r,g,rnw,v)                  p:pid0(r,g,rnw)         a:rh(r,"hh")   t:ti(r,g,rnw)
    i:pl(r)                                 q:ld0(r,rnw,v)                    p:pld0(r,rnw)           a:rh(r,"hh")   t:tl(r,rnw)
    i:rkx(r,k,rnw)                          q:kd0(r,k,rnw,v)                  p:pkd0(r,k,rnw)         a:rh(r,"hh")   t:tk(r,k,rnw)


*       Electricity generation - Advanced technology :
$prod:advgen(r,advee,v)$(y0(r,advee,v) and f_advgen(r,advee,v) and new(v))    t:0     s:0
+         ff(s):esub_gen(r,advee)      mat(ff):0   eva(ff):0   mat.tl(mat):0   va(eva):1

    o:py(r,advee)                           q:y0(r,advee,v)                                                     a:rh(r,"hh")   t:ty(r,advee)
    i:ped(r,e,use,advee)$(fuel(use))        q:ed0(r,e,use,advee,v)            eva:
    i:pa(r,g)                               q:id0(r,g,advee,v)                g.tl:   p:pid0(r,g,advee)         a:rh(r,"hh")   t:ti(r,g,advee)
    i:pl(r)                                 q:ld0(r,advee,v)                  va:     p:pld0(r,advee)           a:rh(r,"hh")   t:tl(r,advee)
    i:rk(r,k)                               q:kd0(r,k,advee,v)                va:     p:pkd0(r,k,advee)         a:rh(r,"hh")   t:tk(r,k,advee)
    i:prnw(r,advee)                         q:rnw0(r,advee,v)                 ff:     p:pref_gen(r,advee)

$prod:advgen(r,advee,v)$(y0(r,advee,v) and f_advgen(r,advee,v) and extant(v))    t:0     s:0

    o:py(r,advee)                           q:y0(r,advee,v)
    i:ped(r,e,use,advee)$(fuel(use))        q:ed0(r,e,use,advee,v)
    i:pa(r,g)                               q:id0(r,g,advee,v)                 p:pid0(r,g,advee)         a:rh(r,"hh")   t:ti(r,g,advee)
    i:pl(r)                                 q:ld0(r,advee,v)                   p:pld0(r,advee)           a:rh(r,"hh")   t:tl(r,advee)
    i:rkx(r,k,advee)                        q:kd0(r,k,advee,v)                 p:pkd0(r,k,advee)         a:rh(r,"hh")   t:tk(r,k,advee)


*        Electricity armington goods:
$prod:agen(r,i)$(sum(v,y0(r,i,v)) and sameas(i,"ele"))    t:0  s:ele_elas
    o:py(r,i)                               q:y00(r,i,"new")
    i:py(r,convi)                           q:y00(r,convi,"new")
    i:py(r,rnw)                             q:y00(r,rnw,"new")
    i:py(r,advee)$f_advgen(r,advee,"new")   q:y00(r,advee,"New")


*        Energy markets (retail = wholesale + margins):
$prod:emkt(r,e,use,i)$((ertl0(r,e,use,i) and not gentype(i)) or (ertl0(r,e,use,i) and fuel(use) and (convrnw(i) or f_advgen(r,i,"new"))))       s:0

    o:ped(r,e,use,i)                        q:ertl0(r,e,use,i)              a:rh(r,"hh")   t:te(r,e,use,i)
    i:pa(r,"srv")                           q:emrg0(r,e,use,i)
    i:pa(r,e)$cegoe(e)                      q:ewhl0(r,e,use,i)
    i:pcru$cru(e)                           q:ewhl0(r,e,use,i)
    i:pco2(r)$f_co2(r)                      q:(0.001*co200(r,e,use,i))      p:1e-6
    i:pco2(r)$(f_ele(r)$convi(i))           q:(0.001*co200(r,e,use,i))      p:1e-6

*        Bring first generation biofuel market in hdv:
$prod:emkt(r,e,use,i)$(hdvbio_ertl0(r,e,use,i) and f_hdvbio(r,i))       s:0
    o:ped(r,e,use,"auto")                   q:hdvbio_ertl0(r,e,use,i)       a:rh(r,"hh")   t:te(r,e,use,i)
    i:pa(r,"srv")                           q:hdvbio_emrg0(r,e,use,i)
    i:pa(r,e)$cegoe(e)                      q:hdvbio_ewhl0(r,e,use,i)

*        Homogenous Crude oil:
$prod:x(r,i)$(sum(vnum,y0(r,i,vnum))   and cru(i))
    o:pcru                                  q:(sum(vnum,y0(r,i,vnum)  ))
    i:py(r,i)                               q:(sum(vnum,y0(r,i,vnum)  ))
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*        Armington Goods (imports and domestic goods):
$prod:a(r,i)$a0(r,i)      s:dm_elas(i)
    o:pa(r,i)                               q:a0(r,i)
    i:py(r,i)                               q:d0(r,i)
    i:pm(r,i)                               q:m0(r,i,"ftrd")

*        International imports:
$prod:m(r,i)$(m0(r,i,"ftrd")   and not cru(i))        t:0     s:mm_elas(i)            rr.tl:0
    o:pm(r,i)                               q:m0(r,i,"ftrd")
    i:py(rr,i)                              q:n0(r,rr,i)                       rr.tl:   p:pmx0(r,rr,i)    a:rh(rr,"hh")   t:tx(r,rr,i) a:rh(r,"hh")   t:(tm(r,rr,i)*(1+tx(r,rr,i)))
    i:pt#(rr)                               q:trs0(r,rr,i)                     rr.tl:   p:pmt0(r,rr,i)    a:rh(r,"hh")    t:tm(r,rr,i)

*        Trade transportation services:
$prod:yt                     s:1
    o:pt                             q:(sum((r,i),tpt0(r,i)  ))
    i:py(r,i)                           q:tpt0(r,i)

*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*        C + I + G, Emissions                        *
$prod:inv(r,k)$inv0(r,k)                     s:0
    o:pinv(r,k)                             q:inv0(r,k)
    i:pa(r,g)                               q:i0(r,k,g)

*        Government Goods:
$prod:gov(r)                                 s:0
    o:pg(r)                                 q:gov0(r)
    i:pa(r,g)                               q:g0(r,g)

$prod:nkt(r)     t:5
    o:rk(r,k)   q:nk0(r,k)
    i:rkt(r)    q:(sum(k, nk0(r,k)))


*        Consumption by households:
$prod:c(r,hh)                                s:0
+        nCO2(s):CO2_elas(r,"hh")     CO2.tl(nCO2):0
+        nCH4(s):CH4_elas(r,"hh")     CH4.tl(nCH4):0
+        nN2O(nCH4):N2O_elas(r,"hh")  N2O.tl(nN2O):0
*        ct(nN2O):1                   tran(ct):0     trnp(tran):0.5 tranp.tl(trnp):0 trno(tran):0  trano.tl(trnO):0  ch(ct):1
+        ct(nN2O):0.5                 tran(ct):0     trnp(tran):0.5 tranp.tl(trnp):0 trno(tran):0  trano.tl(trnO):0  ch(ct):1
+        cons(ch):0.5                 s_trn.tl:0     hous(ch):1

    o:pc(r,hh)                         q:c0(r,hh)
    i:pghg(r,ghg)$f_ghg(r,ghg)         q:(0.001*ghg0(r,ghg,"hh","new"))  ghg.tl:
    i:pa(r,g)$(not trn(g))             q:cd0(r,hh,g)                     g.tl:    p:pcd0(r,g)  a:rh(r,"hh")   t:tc(r,g)
    i:pa(r,trn)$(tranp(trn))           q:cd0(r,hh,trn)                   trn.tl:
    i:pa(r,trn)$(trano(trn))           q:cd0(r,hh,trn)                   trn.tl:
    i:phous(r,hh)                      q:cd0(r,hh,"house")               hous:

*        Greenhouse gas emissions:
$prod:GHGemis(r,ghg)$(GHGtot0(r,ghg)  and f_ghg(r,ghg))
    o:pghg(r,ghg)                      q:(0.001*GHGtot0(r,ghg))
    i:pghgendow(r)                     q:(0.001*GHGtot0(r,ghg))

*        Convert GHG to CO2eq to equilibrate prices in carbon tax scenarios:
$prod:ghg2carb(r)$(ghgcarb(r) and f_co2(r) )
    o:pco2(r)                          q:1
    i:pghgendow(r)                     q:1
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*




*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*        Vehicle passenger-miles-traveled by conventional auto transportation (new/flexible):
$prod:y(r,s,v)$(y0(r,s,v) and auto(s)   and new(v))  t:0
* allow fuel-capital substitution only and mpg permits enter leontief with fuel
+       t:0  s:afv_elas(s)  srv.tl(so):0  kf(s):0.1     mpg(kf):0    fso(mpg):0

    o:py(r,s)                          q:y0(r,s,v)
    i:pa(r,g)                          q:(id0(r,g,s,v)*mk(r,s,"id0",v))                                       p:pid0(r,g,s) a:rh(r,"hh")   t:ti(r,g,s)
    i:rk(r,k)$(f_trn(r,s,"new") and kd0(r,k,s,v))      q:((kd0(r,k,s,v)-0.001*y0(r,s,v))*mk(r,s,"kd0",v))     kf:           p:pkd0(r,k,s)  a:rh(r,"hh")   t:tk(r,k,s)
    i:rk(r,k)$(f_trn(r,s,"new")=0 and kd0(r,k,s,v))    q:(kd0(r,k,s,v)*mk(r,s,"kd0",v))                       kf:           p:pkd0(r,k,s)  a:rh(r,"hh")   t:tk(r,k,s)

    i:poev(r,s)                        q:(sum(e$ob(e),ed0(r,e,"fuel",s,v))*mk(r,s,"ed0",v))     fso:
    i:ped(r,e,"fuel",s)$(not ob(e))    q:(ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v))                  fso:

    o:pmpge(r,s)$(targt_mpge(r,s))     q:(tran_vmt0(r,s)*(pmt("auto")/targt_mpge(r,s)))
    i:pmpge(r,s)$(targt_mpge(r,s))     q:(pmt("auto")*sum(e,ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v)*btu_conv(r,e,"fuel",s)/btu_gal("oil")))  mpg:

    i:ptrnff(r,s)$(f_trn(r,s,"new"))   q:(0.001*y0(r,s,v))

*        Vehicle passenger-miles-traveled by conventional auto transportation (extant/existing):
$prod:y(r,s,v)$(y0(r,s,v) and auto(s)  and extant(v))    t:0     s:0
    o:py(r,s)                           q:y0(r,s,v)
    i:pa(r,g)                           q:(id0(r,g,s,v)*mk(r,s,"id0",v))                      p:pid0(r,g,s)          a:rh(r,"hh")   t:ti(r,g,s)
    i:rkx(r,k,s)                        q:(kd0(r,k,s,v)*mk(r,s,"kd0",v))                      p:pkd0(r,k,s)          a:rh(r,"hh")   t:tk(r,k,s)
    i:poev(r,s)                         q:(sum(e$ob(e),ed0(r,e,"fuel",s,v))*mk(r,s,"ed0",v))
    i:ped(r,e,"fuel",s)$(not ob(e))     q:(ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v))
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*




*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*   Fuels                                            *
*        Advanced biofuel use in conventional onroad transportation
$prod:oev_adv(r,e,s,v)$(advbio(e) and advswtch(r,e,v) and not advb(e) and (auto(s) or f_hdvbio(r,s)) and new(v))
    o:pedm(r,e)                            q:  1
    i:ped(r,e,"fuel","auto")               q:  1

*        First generation biofuel use in conventional auto transportation
$prod:oev_bio(r,e,s,v)$(auto(s) and ((bioe(e) and ed0(r,e,"fuel","auto",v)) or (f_bio(r,"ceth") and cobd(e) and new(v))  ) )
    o:pedm(r,e)$(bioe(e) and ed0(r,e,"fuel","auto",v))                   q: (ed0(r,e,"fuel","auto",v))
    o:pedm(r,e)$(f_bio(r,"ceth") and cobd(e) and new(v))                 q: (phi(r,e,v)*chg_bio(r,"ceth",e,v))
    i:ped(r,e,"fuel","auto")$(bioe(e) and ed0(r,e,"fuel","auto",v))      q: (ed0(r,e,"fuel","auto",v))
    i:py(r,e)$(f_bio(r,"ceth") and cobd(e) and new(v))                   q: (phi(r,e,v)*chg_bio(r,"ceth",e,v))

*        Fossil fuel use in conventional auto transportation
$prod:oev_ff(r,e,s,v)$(auto(s) and not bioe(e) and ed0(r,e,"fuel","auto",v) and oil(e))
    o:pedm(r,e)                            q: (ed0(r,e,"fuel","auto",v))
    i:ped(r,e,"fuel","auto")               q: (ed0(r,e,"fuel","auto",v))

*        Total fuel use in conventional auto transportation
$prod:oev_fuel(r,s,v)$(new(v) and auto(s))       s:ldv_elas  ethl.tl(s):ldv_elas    biod.tl(s):ldv_elas  cobd(biod):ldv_elas  advbio.tl(s):ldv_elas
    o:poev(r,s)                                           q:oev_valu0(r,s,v)
    i:pedm(r,ethl)                                        q:(phi(r,ethl,v)*beta(r,s,ethl,v)   )          ethl.tl:
    i:pedm(r,biod)$(not cobd(biod))                       q:(phi(r,biod,v)*beta(r,s,biod,v) )            biod.tl:
    i:pedm(r,e)$(chg_bio(r,"ceth",e,v)$(f_bio(r,"ceth") and cobd(e)))   q:(phi(r,e,v)*beta(r,s,e,v))     cobd:
    i:pedm(r,advbio)$(advswtch(r,advbio,v))               q:(phi(r,advbio,v)*beta(r,s,advbio,v))         advbio.tl:
    i:pedm(r,"oil")                                       q:(phi(r,"oil",v)*beta(r,s,"oil",v)  )

$prod:oev_fuel(r,s,v)$(extant(v) and auto(s))    s:0
    o:poev(r,s)                                           q:oev_valu0(r,s,v)
    i:pedm(r,ethl)                                        q:(phi(r,ethl,v)*beta(r,s,ethl,v))
    i:pedm(r,biod)$(not cobd(biod))                       q:(phi(r,biod,v)*beta(r,s,biod,v))
    i:pedm(r,e)$(chg_bio(r,"ceth",e,v)$(f_bio(r,"ceth") and cobd(e)))   q:(phi(r,e,v)*beta(r,s,e,v))
    i:pedm(r,advbio)$(advswtch(r,advbio,v))               q:(phi(r,advbio,v)*beta(r,s,advbio,v))
    i:pedm(r,"oil")                                       q:(phi(r,"oil",v)*beta(r,s,"oil",v))

*        First generation biofuel use in conventional HDV transportation
$prod:oev_bio(r,e,s,v)$(f_aggtrn=0 and hdv(s)  and f_hdvbio(r,s) and new(v) and ((bioe(e) and ed0(r,e,"fuel","auto",v)) or (f_bio(r,"ceth") and cobd(e) and new(v))  ) )
* cobd is included here in hdv
    o:pedm(r,e)$(bioe(e) and ed0(r,e,"fuel","auto",v))                 q:  1
    o:pedm(r,e)$(f_bio(r,"ceth") and cobd(e))                          q:  1
    i:ped(r,e,"fuel","auto")$(bioe(e) and ed0(r,e,"fuel","auto",v))    q:  1
    i:py(r,e)$(f_bio(r,"ceth") and cobd(e))                            q:  1

*        Fossil fuel use in conventional HDV transportation
$prod:oev_ff(r,e,s,v)$(f_aggtrn=0 and ed0(r,e,"fuel",s,v) and f_hdvbio(r,s)  and ed0(r,e,"fuel",s,v) and oil(e) )  s:0
    o:pedh(r,e,s)                              q:(ed0(r,e,"fuel",s,v))
    i:ped(r,e,"fuel",s)                        q:(ed0(r,e,"fuel",s,v))

*        Total fuel use in conventional road freight transportation
$prod:oev_fuel(r,s,v)$(new(v) and f_aggtrn=0 and hdv(s) and f_hdvbio(r,s))  s:hdv_elas  e.tl(s):hdv_elas  ethl.tl(s):hdv_elas  biod.tl(s):hdv_elas cobd(biod):hdv_elas  advbio.tl(s):hdv_elas
    o:poev(r,s)                                                               q:ed0(r,"oil","fuel",s,v)
    i:pedm(r,ethl)$(f_hdvbio(r,s)  and beta(r,s,ethl,v))                      q:beta(r,s,ethl,v)         ethl.tl:
    i:pedm(r,biod)$(f_hdvbio(r,s)  and beta(r,s,biod,v))                      q:beta(r,s,biod,v)         biod.tl:
    i:pedm(r,biod)$(f_hdvbio(r,s)  and f_bio(r,"ceth") and cobd(biod) )       q:beta(r,s,biod,v)         cobd:
    i:pedm(r,advbio)$(f_hdvbio(r,s) and advswtch(r,advbio,v))                 q:beta(r,s,advbio,v)       advbio.tl:
    i:pedh(r,e,s)$(oil(e) and ed0(r,e,"fuel",s,v) )                           q:beta(r,s,e,v)            e.tl:

$prod:oev_fuel(r,s,v)$(extant(v) and f_aggtrn=0 and hdv(s) and f_hdvbio(r,s))  s:0
    o:poev(r,s)                                                               q:ed0(r,"oil","fuel",s,v)
    i:pedm(r,ethl)$(f_hdvbio(r,s)  and beta(r,s,ethl,v))                      q:beta(r,s,ethl,v)
    i:pedm(r,biod)$(f_hdvbio(r,s)  and beta(r,s,biod,v))                      q:beta(r,s,biod,v)
    i:pedm(r,biod)$(f_hdvbio(r,s)  and f_bio(r,"ceth") and cobd(biod) )       q:beta(r,s,biod,v)
    i:pedm(r,advbio)$(f_hdvbio(r,s) and advswtch(r,advbio,v))                 q:beta(r,s,advbio,v)
    i:pedh(r,e,s)$(oil(e) and beta(r,s,e,v))                                  q:beta(r,s,e,v)

* For aggregated version with biofuel allowed to be used in Otrn
$prod:oev_bio(r,e,s,v)$(f_aggtrn=1 and aggtrn(s)  and f_hdvbio(r,s) and new(v) and ((bioe(e) and ed0(r,e,"fuel","auto",v)) or (f_bio(r,"ceth") and cobd(e) and new(v))  ) )
* cobd is included here in hdv
    o:pedm(r,e)$(bioe(e) and ed0(r,e,"fuel","auto",v))                 q:  1
    o:pedm(r,e)$(f_bio(r,"ceth") and cobd(e))                          q:  1
    i:ped(r,e,"fuel","auto")$(bioe(e) and ed0(r,e,"fuel","auto",v))    q:  1
    i:py(r,e)$(f_bio(r,"ceth") and cobd(e))                            q:  1

*        Fossil fuel use in conventional HDV transportation
$prod:oev_ff(r,e,s,v)$(f_aggtrn=1 and aggtrn(s) and ed0(r,e,"fuel",s,v) and f_hdvbio(r,s)  and ed0(r,e,"fuel",s,v) and oil(e) )  s:0
    o:pedh(r,e,s)                              q:(ed0(r,e,"fuel",s,v))
    i:ped(r,e,"fuel",s)                        q:(ed0(r,e,"fuel",s,v))

*        Total fuel use in conventional road freight transportation
$prod:oev_fuel(r,s,v)$(new(v) and f_aggtrn=1 and aggtrn(s) and f_hdvbio(r,s))  s:hdv_elas  e.tl(s):hdv_elas  ethl.tl(s):hdv_elas  biod.tl(s):hdv_elas cobd(biod):hdv_elas  advbio.tl(s):hdv_elas
    o:poev(r,s)                                                               q:ed0(r,"oil","fuel",s,v)
    i:pedm(r,ethl)$(f_hdvbio(r,s)  and beta(r,s,ethl,v))                      q:beta(r,s,ethl,v)         ethl.tl:
    i:pedm(r,biod)$(f_hdvbio(r,s)  and beta(r,s,biod,v))                      q:beta(r,s,biod,v)         biod.tl:
    i:pedm(r,biod)$(f_hdvbio(r,s)  and f_bio(r,"ceth") and cobd(biod) )       q:beta(r,s,biod,v)         cobd:
    i:pedm(r,advbio)$(f_hdvbio(r,s) and advswtch(r,advbio,v))                 q:beta(r,s,advbio,v)       advbio.tl:
    i:pedh(r,e,s)$(oil(e) and ed0(r,e,"fuel",s,v) )                           q:beta(r,s,e,v)            e.tl:

$prod:oev_fuel(r,s,v)$(extant(v) and f_aggtrn=1 and aggtrn(s) and f_hdvbio(r,s))  s:0
    o:poev(r,s)                                                               q:ed0(r,"oil","fuel",s,v)
    i:pedm(r,ethl)$(f_hdvbio(r,s)  and beta(r,s,ethl,v))                      q:beta(r,s,ethl,v)
    i:pedm(r,biod)$(f_hdvbio(r,s)  and beta(r,s,biod,v))                      q:beta(r,s,biod,v)
    i:pedm(r,biod)$(f_hdvbio(r,s)  and f_bio(r,"ceth") and cobd(biod) )       q:beta(r,s,biod,v)
    i:pedm(r,advbio)$(f_hdvbio(r,s) and advswtch(r,advbio,v))                 q:beta(r,s,advbio,v)
    i:pedh(r,e,s)$(oil(e) and beta(r,s,e,v))                                  q:beta(r,s,e,v)



*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*



*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
* Disaggregated transportation sector

*        Alternative fuel vehicle (new /flexibile):
$prod:afvtrn(r,afv,v)$(f_aggtrn=0 and f_afv(r,afv,v) and new(v) )
+        s:afv_elas(afv)   afv(s):0  kf(afv):0.01 k(kf):0 mpg(kf):0 fso(mpg):0      fue(fso):0  ele(fso):0

    o:py(r,"auto")$(autoafv(afv))            q:1                                        a:rh(r,"hh")   t:ty(r,afv)
    o:py(r,"rodF")$(RodFafv(afv))            q:1                                        a:rh(r,"hh")   t:ty(r,afv)
    o:py(r,"rodP")$(rodPafv(afv))            q:1                                        a:rh(r,"hh")   t:ty(r,afv)

    i:pafvff(r,afv)$(afv_ff0(r,afv,v))       q:(afv_ff0(r,afv,v))

    i:pl(r)                                  q:(afv_ld0(r,afv,v))       p:pld0(r,afv)     a:rh(r,"hh")   t:tl(r,afv)     afv:
    i:pa(r,g)                                q:(afv_id0(r,afv,g,v))     p:pid0(r,g,afv)   a:rh(r,"hh")   t:ti(r,g,afv)   afv:
    i:rk(r,k)                                q:(afv_kd0(r,afv,k,v))     p:pkd0(r,k,afv)   a:rh(r,"hh")   t:tk(r,k,afv)   k:
    i:phk(r)                                 q:(afv_hkd0(r,afv,v))      p:phkd0(r,afv)    a:rh(r,"hh")   t:thk(r,afv)    k:

    i:pa(r,e)$(cego(e) and f_afvbio(r,afv)=0 and not ele(e))     q:(afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v))       fue:
    i:pa(r,e)$(ceg(e)  and f_afvbio(r,afv)>0 and not ele(e))     q:(afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v))       fue:

    i:pa(r,e)$(cego(e) and f_afvbio(r,afv)=0 and ele(e))        q:(afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v))       fue:
    i:pa(r,e)$(ceg(e)  and f_afvbio(r,afv)>0 and ele(e))        q:(afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v))       fue:

    i:poev(r,"auto")$(f_aggtrn=0 and f_afvbio(r,afv)>0 and BioautoAFV(afv))     q:(afv_ed0(r,afv,"oil",v)*afv_edtrd0(r,afv,v))   fue:
    i:poev(r,"RodF")$(f_aggtrn=0 and f_afvbio(r,afv)>0 and BioRodFAFV(afv))     q:(afv_ed0(r,afv,"oil",v)*afv_edtrd0(r,afv,v))   fue:
    i:poev(r,"RodP")$(f_aggtrn=0 and f_afvbio(r,afv)>0 and BiorodPAFV(afv))     q:(afv_ed0(r,afv,"oil",v)*afv_edtrd0(r,afv,v))   fue:

    o:pmpge(r,"auto")$(f_aggtrn=0 and autoafv(afv) and targt_mpge(r,"auto"))  q:(tran_vmt0(r,"auto")*(pmt("auto")/targt_mpge(r,"auto"))/y0(r,"auto",v))
    i:pmpge(r,"auto")$(f_aggtrn=0 and autoafv(afv) and targt_mpge(r,"auto"))  q:(pmt("auto")*sum(e,afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v)*btu_conv(r,e,"fuel","auto")/btu_gal("oil")))   mpg:

    o:pmpge(r,"rodf")$(f_aggtrn=0 and rodfafv(afv) and targt_mpge(r,"rodf"))  q:(tran_vmt0(r,"rodf")*(pmt("rodf")/targt_mpge(r,"rodf"))/y0(r,"rodf",v))
    i:pmpge(r,"rodf")$(f_aggtrn=0 and rodfafv(afv) and targt_mpge(r,"rodf"))  q:(pmt("rodf")*sum(e,afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v)*btu_conv(r,e,"fuel","rodf")/btu_gal("oil")))   mpg:

    o:pmpge(r,"rodp")$(f_aggtrn=0 and rodpafv(afv) and targt_mpge(r,"rodp"))  q:(tran_vmt0(r,"rodp")*(pmt("rodp")/targt_mpge(r,"rodp"))/y0(r,"rodp",v))
    i:pmpge(r,"rodp")$(f_aggtrn=0 and rodpafv(afv) and targt_mpge(r,"rodp"))  q:(pmt("rodp")*sum(e,afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v)*btu_conv(r,e,"fuel","rodp")/btu_gal("oil")))   mpg:



*        Alternative fuel vehicle (extant/existing):
$prod:afvtrn(r,afv,v)$(f_aggtrn=0 and f_afv(r,afv,v) and extant(v) and sum(k,xk0(r,k,afv)) )      s:0
    o:py(r,"auto")$(autoafv(afv) )           q:1                                         a:rh(r,"hh")   t:ty(r,afv)
    o:py(r,"rodF")$(RodFafv(afv) )           q:1                                         a:rh(r,"hh")   t:ty(r,afv)
    o:py(r,"rodP")$(rodPafv(afv) )           q:1                                         a:rh(r,"hh")   t:ty(r,afv)

    i:pl(r)                                  q:(afv_ld0(r,afv,v))     p:pld0(r,afv)     a:rh(r,"hh")   t:tl(r,afv)
    i:rkx(r,k,afv)                           q:(afv_kd0(r,afv,k,v))   p:pkd0(r,k,afv)   a:rh(r,"hh")   t:tk(r,k,afv)
    i:phk(r)                                 q:(afv_hkd0(r,afv,v))    p:phkd0(r,afv)    a:rh(r,"hh")   t:thk(r,afv)
    i:pa(r,g)                                q:(afv_id0(r,afv,g,v))   p:pid0(r,g,afv)   a:rh(r,"hh")   t:ti(r,g,afv)
* Allow biofuel-oil mix to replace the pure oil in HEV and GASV
    i:pa(r,e)$(cego(e) and f_afvbio(r,afv)=0)                  q:(afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v))
    i:pa(r,e)$(ceg(e)  and f_afvbio(r,afv)>0)                  q:(afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v))
    i:poev(r,"auto")$(f_afvbio(r,afv)>0 and BioautoAFV(afv))   q:(afv_ed0(r,afv,"oil",v)*afv_edtrd0(r,afv,v))
    i:poev(r,"RodF")$(f_afvbio(r,afv)>0 and BioRodFAFV(afv))   q:(afv_ed0(r,afv,"oil",v)*afv_edtrd0(r,afv,v))
    i:poev(r,"RodP")$(f_afvbio(r,afv)>0 and BiorodPAFV(afv))   q:(afv_ed0(r,afv,"oil",v)*afv_edtrd0(r,afv,v))

*    i:pafvff(r,afv)$(afv_ff0(r,afv,v))                        q:(afv_ff0(r,afv,v))

*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*



*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*   Housing & welfare
*       Housing Services (house + energy - from new/flexible):
$prod:house(r,hh,v)$(house0(r,hh,v)   and new(v))     t:0     s:1     eh(s):0.5       cego.tl(eh):0
    o:phous(r,hh)                           q:house0(r,hh,v)
    i:rk(r,k)                               q:kd0(r,k,hh,v)          p:pkd0(r,k,hh)  a:rh(r,"hh")   t:tk(r,k,hh)
    i:ped(r,e,use,"hh")$hous(use)           q:ed0(r,e,use,hh,v)      e.tl:

*       Housing Services (house + energy - from extant/existing):
$prod:house(r,hh,v)$(house0(r,hh,v)   and extant(v))  s:0
    o:phous(r,hh)                           q:house0(r,hh,v)
    i:rkx(r,k,hh)                           q:kd0(r,k,hh,v)          p:pkd0(r,k,hh)  a:rh(r,"hh")   t:tk(r,k,hh)
    i:ped(r,e,use,"hh")$hous(use)           q:ed0(r,e,use,hh,v)

*       Welfare - consumption plus Leisure Time:
$prod:w(r,hh)        s:0.5               b:sigma_cl(r,hh)
    o:pcl(r,hh)$(not luc(r))                q:cl0(r,hh)
    o:pcl(r,hh)$luc(r)                      q:(cl0(r,hh)-sum(v,lnd0(r,"frs",v))*(1-l_shr(r,"frs"))*nat_tran(r,"inp"))
    i:pc(r,hh)                              q:c0(r,hh)         b:
    i:pl(r)                                 q:leis0(r,hh)      b:
    i:plnuse(r,nat)$(ngrs(nat) and rentv(r,nat) and luc(r))    q:rentv0(r,nat)
    i:plnuse(r,nat)$(nfrs(nat) and rentv(r,nat) and luc(r))    q:(rentv0(r,nat) - (sum(v,lnd0(r,"frs",v))*(1-l_shr(r,"frs"))*nat_tran(r,"inp")))
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC*
*   Model agents
*       Representative Households:
$demand:rh(r,hh)
    d:pcl(r,hh)$(not luc(r))                     q:(cl0(r,hh))
    d:pcl(r,hh)$luc(r)                           q:(cl0(r,hh)-sum(v,lnd0(r,"frs",v))*(1-l_shr(r,"frs"))*nat_tran(r,"inp"))
    e:pl(r)                                      q:le0(r,hh)
    e:phk(r)                                     q: hke0(r)
    e:pland(r)$(not luc(r))                      q:land0(r)
    e:plrent(r,agri)$luc(r)                      q:(sum(vnum,lnde0(r,agri,vnum))*l_shr(r,agri))
    e:plrent(r,nat)$rentv(r,nat)$luc(r)          q:rentv(r,nat)
    e:plff(r,lu)$(luc(r) )                       q:(sum(vnum,fffor(r,lu,vnum)))
    e:pr(r,i)$(cru(i) and f_cru(r))              q:(sum(vnum,re0(r,i,vnum)))              r:pcrupath(r)
    e:pr(r,i)$(cru(i) and f_cru(r)=0)            q:(sum(vnum,re0(r,i,vnum)))
    e:pr(r,i)$(not cru(i))                       q:(sum(vnum,re0(r,i,vnum)))
    e:prnw(r,gentype)$(rnw0(r,gentype,"new") and (convrnw(gentype) or f_advgen(r,gentype,"new")))                   q:rnwe0(r,gentype,"new")
    e:rkx(r,k,i)$((xk0(r,k,i) and not gentype(i)) or (xk0(r,k,i) and (convrnw(i) or f_advgen(r,i,"extant"))))       q: xk0(r,k,i)
    e:rkt(r)                                     q:(sum(k$nk0(r,k),nk0(r,k)))
    e:pinv(r,k)                                  q:(-inve0(r,k))
    e:pg(r)                                      q:(-gove0(r))
    e:pcl(num,hh)                                q:bopdef0(r,hh)
    e:pghgendow(r)#(r)$sum(ghg,f_ghg(r,ghg))                q:(0.001*GHGendow(r))
    e:pghgendow(r)#(r)$(ctax(r) and sum(ghg,f_ghg(r,ghg)))  q:(-0.001*GHGendow(r))         r:ghgscale(r)$(ctax(r) and sum(ghg,f_ghg(r,ghg)))
    e:pco2(r)#(r)$(f_co2(r) )                               q:(0.001*co2endow(r))
    e:pco2(r)#(r)$(ctax(r) and f_co2(r))                    q:(-0.001*co2endow(r))         r:carbtax(r)$ctax(r)
    e:pco2(r)#(r)$(f_ele(r))                                q:(0.001*co2elecap(r))
    e:pafvff(r,afv)$(f_afv(r,afv,"new") and afv_ff0(r,afv,"new")) q:afv_ffen0(r,afv,"new")
    e:ptrnff(r,i)$(trnv(i) and f_trn(r,i,"new"))            q:trn_ffen0(r,i,"new")


*        Carbon tax
$constraint:carbtax(r)$(ctax(r) and f_co2(r) )
    pco2(r) =e= ctax(r) * pc(r,"hh");

*        Adjustment on GHG prices
$constraint:ghgscale(r)$(ctax(r) and sum(ghg,f_ghg(r,ghg)))
    pghgendow(r) =e= ctax(r)* pc(r,"hh");

*        Exogenous crude oil price path
$constraint:pcrupath(r)$(f_cru(r))
    pcru=e=  pcrutrd(r);


*- Reporting Variables -*
$report:
* Production
    v:y0_(r,i,v)$(y0(r,i,v)   and s(i))                                   o:py(r,i)               prod:y(r,i,v)
    v:y0_(r,i,v)$(y0(r,i,v)   and convrnw(i))                             o:py(r,i)               prod:gen(r,i,v)
    v:y0_(r,i,v)$(y0(r,i,v)   and f_advgen(r,i,v))                        o:py(r,i)               prod:advgen(r,i,v)
    v:y0_(r,i,v)$(y0(r,i,v)   and sameas(i,"ele") and new(v) )            o:py(r,i)               prod:agen(r,i)
    v:y000_(r,j,v)$(y0(r,j,v) and (convrnw(j) or f_advgen(r,j,v)) and new(v))    i:py(r,j)               prod:agen(r,"ele")

    v:y0_(r,i,v)$(y0(r,i,v)   and bio(i) and new(v))                      o:py(r,i)               prod:biofuel(r,i,v)
    v:y0_(r,i,v)$(y0(r,i,v)   and ff(i))                                  o:py(r,i)               prod:ffprod(r,i,v)
    v:y0_(r,i,v)$(advswtch(r,i,v)   and new(v))                           o:ped(r,i,"fuel","auto")  prod:advbiofuel(r,i,v)
* coproduct electricity from switchgrass biofuel production
    v:y00_(r,i,v)$(advswtch(r,"swge",v)   and new(v) and ele(i))          o:py(r,i)               prod:advbiofuel(r,"swge",v)

    v:y0_(r,i,v)$(ddgs(i))                                                o:py(r,i)               prod:biofuel(r,"ceth",v)
    v:y0_(r,i,v)$(cobd(i)$f_bio(r,"ceth"))                                o:py(r,i)               prod:biofuel(r,"ceth",v)
    v:y0_(r,i,v)$(omel(i))                                                o:py(r,i)               prod:y(r,"vol",v)
* coproduct - oil meal in soybean biodiesel production
    v:y00_(r,i,v)$(omel(i)$f_bio(r,"sybd"))                               o:py(r,i)               prod:biofuel(r,"sybd",v)

    v:y0_(r,i,v)$(f_afv(r,i,v) and autoafv(i))                            o:py(r,"auto")          prod:afvtrn(r,i,v)
    v:y0_(r,i,v)$(f_afv(r,i,v) and rodFafv(i))                            o:py(r,"RodF")          prod:afvtrn(r,i,v)
    v:y0_(r,i,v)$(f_afv(r,i,v) and rodPafv(i))                            o:py(r,"rodP")          prod:afvtrn(r,i,v)

* House production
    v:house0_(r,i,v)$(house0(r,i,v)   and hh(i))                          o:phous(r,i)            prod:house(r,i,v)

* Sectoral energy use
    v:ed0_(r,e,use,i,v)$(ed0(r,e,use,i,v)   and s(i) and not auto(i) and f_hdvbio(r,i)=0)           i:ped(r,e,use,i)        prod:y(r,i,v)
    v:ed0_(r,e,use,i,v)$(ed0(r,e,use,i,v)   and s(i) and (auto(i) or f_hdvbio(r,i)) and not ob(e))  i:ped(r,e,use,i)        prod:y(r,i,v)
    v:ed0_(r,e,use,i,v)$(ed0(r,e,use,i,v)   and convrnw(i))               i:ped(r,e,use,i)          prod:gen(r,i,v)
    v:ed0_(r,e,use,i,v)$(ed0(r,e,use,i,v)   and f_advgen(r,i,v))          i:ped(r,e,use,i)          prod:advgen(r,i,v)
    v:ed0_(r,e,use,i,v)$(ed0(r,e,use,i,v)   and bio(i) and new(v))        i:ped(r,e,use,i)          prod:biofuel(r,i,v)
    v:ed0_(r,e,use,i,v)$(ed0(r,e,"fuel",i,v)=0 and bio(i) and fuel(use) and new(v) and ff(e) and chg_bio(r,i,e,v))          i:pa(r,e)        prod:biofuel(r,i,v)
    v:ed0_(r,e,use,i,v)$(ed0(r,e,use,i,v)   and ff(i))                    i:ped(r,e,use,i)          prod:ffprod(r,i,v)
    v:ed0_(r,e,use,i,v)$(advswtch(r,i,v)    and fuel(use))                i:pa(r,e)                 prod:advbiofuel(r,i,v)
    v:ed0_(r,e,use,i,v)$(f_afv(r,i,v)       and fuel(use) and afv(i))     i:pa(r,e)                 prod:afvtrn(r,i,v)
    v:ed0_(r,e,use,i,v)$(ed0(r,e,use,i,v)   and hh(i) and hous(use))      i:ped(r,e,use,"hh")       prod:house(r,i,v)

* Energy mix (name as OE) for refined oil, biofuel (including first generation, second generation and cobd) that are used in
* OEV, gasv and hev for all onroad transportation
    v:edb0_(r,e,use,i,v)$(auto(i) and fuel(use) and ed0(r,e,use,i,v) and bioe(e))                           i:pedm(r,e)        prod:oev_fuel(r,i,v)
    v:edb0_(r,e,use,i,v)$(auto(i) and fuel(use) and ed0(r,e,use,i,v) and oil(e))                            o:pedm(r,e)        prod:oev_ff(r,e,i,v)
    v:edb0_(r,e,use,i,v)$(auto(i) and fuel(use) and advswtch(r,e,v) and advbio(e))                          i:pedm(r,e)        prod:oev_fuel(r,i,v)
    v:edb0_(r,e,use,i,v)$(auto(i) and fuel(use) and (f_bio(r,"ceth") and cobd(e) and new(v)))               o:pedm(r,e)        prod:oev_bio(r,e,i,v)
    v:edb0_(r,e,use,i,v)$(f_hdvbio(r,i) and fuel(use) and ed0(r,e,use,i,v) and oil(e))                      o:pedh(r,e,i)      prod:oev_ff(r,e,i,v)
    v:edb0_(r,e,use,i,v)$(f_hdvbio(r,i) and fuel(use) and ed0(r,e,use,"auto",v) and bioe(e) and new(v))     i:pedm(r,e)        prod:oev_fuel(r,i,v)
    v:edb0_(r,e,use,i,v)$(f_hdvbio(r,i) and fuel(use) and advswtch(r,e,v) and advbio(e) and new(v) )        i:pedm(r,e)        prod:oev_fuel(r,i,v)
    v:edb0_(r,e,use,i,v)$(f_hdvbio(r,i) and fuel(use) and (f_bio(r,"ceth") and cobd(e) and new(v)))         o:pedm(r,e)        prod:oev_bio(r,e,i,v)

    v:ed0_(r,e,use,i,v)$(auto(i) and fuel(use) and ed0(r,e,use,i,v) and bioe(e))                       o:pedm(r,e)        prod:oev_bio(r,e,i,v)
    v:ed0_(r,e,use,i,v)$(auto(i) and fuel(use) and ed0(r,e,use,i,v) and oil(e))                        o:pedm(r,e)        prod:oev_ff(r,e,i,v)
    v:ed0_(r,e,use,i,v)$(f_hdvbio(r,i) and fuel(use) and ed0(r,e,use,"auto",v) and bioe(e) and new(v)) i:pedm(r,e)        prod:oev_fuel(r,i,v)
    v:ed0_(r,e,use,i,v)$(f_hdvbio(r,i) and fuel(use) and ed0(r,e,use,i,v) and oil(e))                  o:pedh(r,e,i)      prod:oev_ff(r,e,i,v)
    v:ed0_(r,e,use,i,v)$((auto(i) or f_hdvbio(r,i)) and fuel(use) and advswtch(r,e,v) and advbio(e))   i:pedm(r,e)        prod:oev_fuel(r,i,v)
    v:ed0_(r,e,use,i,v)$((auto(i) or f_hdvbio(r,i)) and fuel(use) and f_bio(r,"ceth") and cobd(e) and new(v))   i:pedm(r,e)        prod:oev_fuel(r,i,v)


* Total energy mix (OE) consumed on on-road transportation (conventional and GasV and HEV).
* Sum of oev_valuS0_ over i are equal to oev_valu0_.
    v:oev_valu0_(r,i,v)$(oev_valu0(r,i,v) and (auto(i) or f_hdvbio(r,i)))                             o:poev(r,i)             prod:oev_fuel(r,i,v)

* Total energy mix (OE) consumed on on-road transportation (conventional)
    v:oev_valuS0_(r,use,i,v)$(y0(r,"auto",v) and fuel(use) and AutoOEV(i))                            i:poev(r,"auto")        prod:y(r,"auto",v)
    v:oev_valuS0_(r,use,i,v)$(y0(r,"rodF",v) and fuel(use) and rodfOEV(i) and f_hdvbio(r,"rodf"))     i:poev(r,"rodf")        prod:y(r,"rodf",v)
    v:oev_valuS0_(r,use,i,v)$(y0(r,"rodP",v) and fuel(use) and rodPOEV(i) and f_hdvbio(r,"rodP"))     i:poev(r,"rodP")        prod:y(r,"rodP",v)

* Total energy mix (OE) consumed on on-road transportation (GasV and HEV)
    v:oev_valuS0_(r,use,i,v)$(f_afv(r,i,v) and f_afvbio(r,i)>0 and fuel(use) and BioautoAFV(i))      i:poev(r,"auto")      prod:afvtrn(r,i,v)
    v:oev_valuS0_(r,use,i,v)$(f_afv(r,i,v) and f_afvbio(r,i)>0 and fuel(use) and BiorodfAFV(i))      i:poev(r,"rodf")      prod:afvtrn(r,i,v)
    v:oev_valuS0_(r,use,i,v)$(f_afv(r,i,v) and f_afvbio(r,i)>0 and fuel(use) and BiorodpAFV(i))      i:poev(r,"rodp")      prod:afvtrn(r,i,v)

    v:edm0_(r,e,use,i)$(ertl0(r,e,use,i))                                 o:ped(r,e,use,i)        prod:emkt(r,e,use,i)
    v:edm0_(r,e,use,i)$(hdvbio_ertl0(r,e,use,i) and f_hdvbio(r,i) )       o:ped(r,e,use,"auto")   prod:emkt(r,e,use,i)

    v:edwh0_(r,e,use,i)$(cegoe(e) and ertl0(r,e,use,i))                                 o:pa(r,e)       prod:emkt(r,e,use,i)
    v:edwh0_(r,e,use,i)$(cru(e) and ertl0(r,e,use,i))                                   i:pcru          prod:emkt(r,e,use,i)
    v:edwh0_(r,e,use,i)$(cegoe(e) and hdvbio_ertl0(r,e,use,i) and f_hdvbio(r,i) )       o:pa(r,e)       prod:emkt(r,e,use,i)

    v:trnff_(r,i,v)$(f_trn(r,i,v) and new(v))                              i:ptrnff(r,i)           prod:y(r,i,v)
    v:afvff0_(r,i,v)$(f_afv(r,i,v) and afv(i) and new(v))                  i:pafvff(r,i)           prod:afvtrn(r,i,v)

    v:mpgeIn_(r,i,v)$(new(v) and targt_mpge(r,i))                             i: pmpge(r,i)        prod:y(r,i,v)
    v:mpgeOut_(r,i,v)$(new(v) and targt_mpge(r,i))                            o: pmpge(r,i)        prod:y(r,i,v)
    v:mpgeIn_(r,i,v)$(f_afv(r,i,v) and autoafv(i) and new(v) and sum(maptrn(j,i),targt_mpge(r,j)))     i: pmpge(r,"auto")        prod:afvtrn(r,i,v)
    v:mpgeOut_(r,i,v)$(f_afv(r,i,v) and autoafv(i) and new(v) and sum(maptrn(j,i),targt_mpge(r,j)))    o: pmpge(r,"auto")        prod:afvtrn(r,i,v)
    v:mpgeIn_(r,i,v)$(f_afv(r,i,v) and rodfafv(i) and new(v) and sum(maptrn(j,i),targt_mpge(r,j)))     i: pmpge(r,"rodf")        prod:afvtrn(r,i,v)
    v:mpgeOut_(r,i,v)$(f_afv(r,i,v) and rodfafv(i) and new(v) and sum(maptrn(j,i),targt_mpge(r,j)))    o: pmpge(r,"rodf")        prod:afvtrn(r,i,v)
    v:mpgeIn_(r,i,v)$(f_afv(r,i,v) and rodpafv(i) and new(v) and sum(maptrn(j,i),targt_mpge(r,j)))     i: pmpge(r,"rodp")        prod:afvtrn(r,i,v)
    v:mpgeOut_(r,i,v)$(f_afv(r,i,v) and rodpafv(i) and new(v) and sum(maptrn(j,i),targt_mpge(r,j)))    o: pmpge(r,"rodp")        prod:afvtrn(r,i,v)


* Intermediate goods use
    v:id0_(r,g,i,v)$(id0(r,g,i,v) and s(i))                               i:pa(r,g)               prod:y(r,i,v)
    v:id0_(r,g,i,v)$(id0(r,g,i,v) and convrnw(i))                         i:pa(r,g)               prod:gen(r,i,v)
    v:id0_(r,g,i,v)$(id0(r,g,i,v) and f_advgen(r,i,v))                    i:pa(r,g)               prod:advgen(r,i,v)
    v:id0_(r,g,i,v)$(id0(r,g,i,v) and bio(i) and new(v))                  i:pa(r,g)               prod:biofuel(r,i,v)
    v:id0_(r,g,i,v)$(id0(r,g,i,v) and ff(i))                              i:pa(r,g)               prod:ffprod(r,i,v)
    v:id0_(r,g,i,v)$(advswtch(r,i,v) and not e(g) and advbioid0(r,g,i))   i:pa(r,g)               prod:advbiofuel(r,i,v)
    v:id0_(r,g,i,v)$(f_afv(r,i,v))                                        i:pa(r,g)               prod:afvtrn(r,i,v)

* Livestock feed input use
    v:feed0_y(r,i,v)$liv(i)                                                    i:pfeed(r,i)       prod:y(r,i,v)
    v:feed0_a(r,g,i,v)$(id0(r,g,i,v) and feed0(r,i,v) and (feed(g) or ofd(g))) i:pa(r,g)          prod:livfeed(r,i,v)
    v:feed0_ddgs(r,feed,i,v)$(ddgs(feed) and liv(i))                           i:pa(r,feed)       prod:livfeed(r,i,v)
    v:feed0_omel(r,omel,i,v)$(liv(i))                                          i:pa(r,omel)       prod:livfeed(r,i,v)

* Sectoral labor use
    v:ld0_(r,i,v)$(ld0(r,i,v) and s(i))                                   i:pl(r)                 prod:y(r,i,v)
    v:ld0_(r,i,v)$(ld0(r,i,v) and convrnw(i))                             i:pl(r)                 prod:gen(r,i,v)
    v:ld0_(r,i,v)$(ld0(r,i,v) and f_advgen(r,i,v))                        i:pl(r)                 prod:advgen(r,i,v)
    v:ld0_(r,i,v)$(ld0(r,i,v) and bio(i) and new(v))                      i:pl(r)                 prod:biofuel(r,i,v)
    v:ld0_(r,i,v)$(ld0(r,i,v) and ff(i))                                  i:pl(r)                 prod:ffprod(r,i,v)
    v:ld0_(r,i,v)$(advswtch(r,i,v))                                       i:pl(r)                 prod:advbiofuel(r,i,v)
    v:ld0_(r,i,v)$(f_afv(r,i,v))                                          i:pl(r)                 prod:afvtrn(r,i,v)

* Sectoral capital use
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v) and s(i) and new(v))                    i:rk(r,k)               prod:y(r,i,v)
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v) and s(i) and extant(v))                 i:rkx(r,k,i)            prod:y(r,i,v)
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v) and convrnw(i) and new(v))              i:rk(r,k)               prod:gen(r,i,v)
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v) and convrnw(i) and extant(v))           i:rkx(r,k,i)            prod:gen(r,i,v)
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v) and f_advgen(r,i,v) and new(v))         i:rk(r,k)               prod:advgen(r,i,v)
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v) and f_advgen(r,i,v) and extant(v))      i:rkx(r,k,i)            prod:advgen(r,i,v)
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v) and bio(i) and new(v))                  i:rk(r,k)               prod:biofuel(r,i,v)
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v) and ff(i))                              i:rk(r,k)               prod:ffprod(r,i,v)
    v:kd0_(r,k,i,v)$(advswtch(r,i,v))                                     i:rk(r,k)               prod:advbiofuel(r,i,v)
    v:kd0_(r,k,i,v)$(f_afv(r,i,v) and new(v))                             i:rk(r,k)               prod:afvtrn(r,i,v)
    v:kd0_(r,k,i,v)$(f_afv(r,i,v) and extant(v))                          i:rkx(r,k,i)            prod:afvtrn(r,i,v)
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v)   and hh(i) and new(v))                 i:rk(r,k)               prod:house(r,i,v)
    v:kd0_(r,k,i,v)$(kd0(r,k,i,v)   and hh(i) and extant(v))              i:rkx(r,k,i)            prod:house(r,i,v)

* Sectoral human capital use
    v:hkd0_(r,i,v)$hkd0(r,i,v)                                            i:phk(r)                prod:y(r,i,v)
    v:hkd0_(r,i,v)$f_afv(r,i,v)                                           i:phk(r)                prod:afvtrn(r,i,v)

* Land use
    v:lnd0_(r,i,v)$(lnd0(r,i,v))                                          i:plnd(r,i)             prod:y(r,i,v)
    v:lnd0_(r,i,v)$crp(i)                                                 i:plnd(r,"crop")        prod:y(r,i,v)
    v:lnd0_(r,i,v)$(advswtch(r,i,v)$(not frwe(i)))                        i:plnd(r,"crop")        prod:advbiofuel(r,i,v)
    v:lnd0_(r,i,v)$(advswtch(r,i,v)$(frwe(i)))                            i:plnd(r,"frs")         prod:advbiofuel(r,i,v)

* Natural resource
    v:rnw0_(r,i,v)$(rnw0(r,i,v) and convrnw(i))                           i:prnw(r,i)             prod:gen(r,i,v)
    v:rnw0_(r,i,v)$(rnw0(r,i,v) and f_advgen(r,i,v))                      i:prnw(r,i)             prod:advgen(r,i,v)

    v:rd0_(r,i,v)$(rd0(r,i,v) and ff(i))                                  i:pr(r,i)               prod:ffprod(r,i,v)
    v:rd0_(r,i,v)$(rd0(r,i,v) and frs(i))                                 i:pr(r,i)               prod:y(r,i,v)

* Armington goods/import/bi-lateral trade
    v:a0_(r,i)$a0(r,i)                                                    o:pa(r,i)               prod:a(r,i)
    v:m0_(r,i)$m0(r,i,"ftrd")                                             o:pm(r,i)               prod:m(r,i)
    v:n0_(r,rr,i)$n0(r,rr,i)                                              i:py(rr,i)              prod:m(r,i)

* GHG emission
    v:ghg0_(r,i,ghg,v)$(f_ghg(r,ghg) and ghg0(r,ghg,i,v) and s(i))                    i:pghg(r,ghg)           prod:y(r,i,v)
    v:ghg0_(r,i,ghg,v)$(f_ghg(r,ghg) and ghg0(r,ghg,"ele",v) and convrnw(i))          i:pghg(r,ghg)           prod:gen(r,i,v)
    v:ghg0_(r,i,ghg,v)$(f_ghg(r,ghg) and ghg0(r,ghg,"ele",v) and f_advgen(r,i,v))     i:pghg(r,ghg)           prod:advgen(r,i,v)
    v:ghg0_(r,i,ghg,v)$(f_ghg(r,ghg) and ghg0(r,ghg,i,v) and ff(i))                   i:pghg(r,ghg)           prod:ffprod(r,i,v)
    v:ghgc0_(r,hh,ghg)$(f_ghg(r,ghg) )                                                i:pghg(r,ghg)           prod:c(r,hh)
    v:co20_(r,e,use,i)$co200(r,e,use,i)                                               i:pco2(r)               prod:emkt(r,e,use,i)
    v:ghgt0_(r,ghg)$(GHGtot0(r,ghg)  and f_ghg(r,ghg))                                i:pghgendow(r)          prod:GHGemis(r,ghg)

* consumption
    v:c0_(r,hh)$c0(r,hh)                                                  o:pc(r,hh)              prod:c(r,hh)
    v:cd0_(r,hh,i)$(cd0(r,hh,i) and g(i))                                 i:pa(r,i)               prod:c(r,hh)
    v:cd0_(r,hh,i)$(cd0(r,hh,i) and housei(i))                            i:phous(r,hh)           prod:c(r,hh)
    v:cl0_(r,hh)$cl0(r,hh)                                                o:pcl(r,hh)             prod:w(r,hh)
    v:leis0_(r,hh)$leis0(r,hh)                                            i:pl(r)                 prod:w(r,hh)

* Land-use change
    v:dfl(r,lu,v)$(new(v) and not luc(r))                                  o:plnd(r,lu)           prod:land(r)
    v:dfl(r,lu,v)$(luc(r) and new(v))                                      i:plrent(r,lu)         prod:lrent(r,lu,v)
    v:dfnt(r,nat)$(rentv0(r,nat) and luc(r))                               i:plnuse(r,nat)        prod:w(r)
    v:lnd_out(r,lu,lu_,v)$(f_luc(r,lu,lu_) and luc(r))                     o:plrent(r,lu)         prod:lnd_tran(r,lu,lu_,v)
    v:lnd_inp(r,lu,lu_,v)$(f_luc(r,lu,lu_) and luc(r))                     i:plrent(r,lu_)        prod:lnd_tran(r,lu,lu_,v)
    v:lnd_fff(r,lu,lu_,v)$(f_luc(r,lu,lu_) and luc(r))                     i:plff(r,lu_)          prod:lnd_tran(r,lu,lu_,v)
    v:lnd_y(r,agri,nat,v)$(rentv0(r,nat) and f_luc(r,agri,nat) and luc(r)) i:py(r,agri)           prod:lnd_tran(r,agri,nat,v)
    v:lnd_a(r,g,lu,lu_,v)$(f_luc(r,lu,lu_) and luc(r) and (ag_shr(r,lu_,g,v) or ag_shr(r,lu,g,v)$agri(lu)))                           i:pa(r,g)             prod:lnd_tran(r,lu,lu_,v)
    v:lnd_ed0_(r,e,use,g,lu,lu_,v)$(f_luc(r,lu,lu_) and luc(r) and (ag_shre(r,lu_,e,use,g,v) or ag_shre(r,lu,e,use,g,v)$agri(lu)))    i:ped(r,e,use,g)      prod:lnd_tran(r,lu,lu_,v)



$offtext
$sysinclude mpsgeset adage


pco2.l(r)                       = 0;
pghg.l(r,ghg)                   = 0;
pghgendow.l(r)                  = 0;
pcl.fx("USA","HH")              = 1;
*pfix.l(r,i)$(advswtch(r,i,"new") and not sameas(i,"advb")) = 0;

y.l(r,s,"new")                  = 1 - clay(r,s);
y.l(r,s,"extant")               = clay(r,s);

ffprod.l(r,ff,"new")            = 1 - clay(r,ff);
ffprod.l(r,ff,"extant")         = clay(r,ff);

gen.l(r,convi,"new")             = 1 - clay(r,convi);
gen.l(r,convi,"extant")          = clay(r,convi);
gen.l(r,rnw,"new")               = 1 - clay(r,rnw);
gen.l(r,rnw,"extant")            = clay(r,rnw);

advgen.l(r,advee,"new")          = 1 - clay(r,advee);
advgen.l(r,advee,"extant")       = clay(r,advee);


house.l(r,hh,"new")             = 1 - clay(r,hh);
house.l(r,hh,"extant")          = clay(r,hh);

afvtrn.l(r,afv,"new")           = 1 - clay(r,afv);
afvtrn.l(r,afv,"extant")        = clay(r,afv);

oev_adv.l(r,e,s,"new")          = 1 ;
oev_bio.l(r,e,s,"new")          = 1 ;
oev_bio.l(r,e,"auto","new")$ed0(r,e,"fuel","auto","new")       = 1-clay(r,"auto") ;
oev_bio.l(r,e,"auto","extant")$ed0(r,e,"fuel","auto","extant") = clay(r,"auto");

oev_ff.l(r,e,s,"new")           = 1 - clay(r,s);
oev_ff.l(r,e,s,"extant")        = clay(r,s);

oev_fuel.l(r,s,"new")           = 1 - clay(r,s);
oev_fuel.l(r,s,"extant")        = clay(r,s);

adage.iterlim = 0;
$include adage.gen
solve adage using mcp;
DISPLAY adage.OBJVAL;


option solprint=on;
adage.iterlim = 1000000;
adage.WORKSPACE = 25;
option mcp=path;
option sysout=on;
*OPTION RESLIM = 500;

$include adage.gen
solve adage using mcp;

*$call 'copy adage.gen adage_%run%.gen'








