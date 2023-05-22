$title  ADAGE Model - Review and Verify Model Results

* Check how close ADAGE outputs for MPG are to exogenous assumption and/or targets
    chk_mpge(r,i,"data",t)$(Autoi(i) or hdvi(i)) = afv_mpget0(r,i,t);
    chk_mpge(r,i,"ADAGE",t)$(Autoi(i) or hdvi(i) or trnv(i))= tran_mpgev(r,i,"new",t);
    chk_mpge(r,i,"Target",t)= targt_mpgeT(r,i,t);

    chk_mpg(r,s,"out")$targt_mpge(r,s)=tran_vmt0(r,s)*(1/targt_mpge(r,s))/y0(r,s,"new");
    chk_mpg(r,s,"in")$targt_mpge(r,s)= sum(e,ed0(r,e,"fuel",s,"new")*mk(r,s,"ed0","new")*btu_conv(r,e,"fuel",s))/btu_gal("oil")/y0(r,s,"new");
    chk_mpg(r,s,e)$targt_mpge(r,s)   = ed0(r,e,"fuel",s,"new")*mk(r,s,"ed0","new")*btu_conv(r,e,"fuel",s)/btu_gal("oil")/y0(r,s,"new");

* Generate values for MPG comparison for LDVs
    chk_mpg(r,afv,"out")$(autoafv(afv) and targt_mpge(r,"auto"))
       = (tran_vmt0(r,"auto")*(1/targt_mpge(r,"auto"))/y0(r,"auto","new")) ;

    chk_mpg(r,afv,"in")$(autoafv(afv) and targt_mpge(r,"auto"))
        =(sum(e,afv_ed0(r,afv,e,"new")*afv_edtrd0(r,afv,"new")*btu_conv(r,e,"fuel","auto")/btu_gal("oil")));

    chk_mpg(r,afv,e)$(autoafv(afv) and targt_mpge(r,"auto"))
        =afv_ed0(r,afv,e,"new")*afv_edtrd0(r,afv,"new")*btu_conv(r,e,"fuel","auto")/btu_gal("oil");

* Generate values for MPG comparison for Road Freight vehicles
    chk_mpg(r,afv,"out")$(rodfafv(afv) and targt_mpge(r,"rodf"))
        = (tran_vmt0(r,"rodf")*(1/targt_mpge(r,"rodf"))/y0(r,"rodf","new")) ;

    chk_mpg(r,afv,"in")$(rodfafv(afv) and targt_mpge(r,"rodf"))
       = (sum(e,afv_ed0(r,afv,e,"new")*afv_edtrd0(r,afv,"new")*btu_conv(r,e,"fuel","rodf")/btu_gal("oil")))  ;

    chk_mpg(r,afv,e)$(rodfafv(afv) and targt_mpge(r,"rodf"))
       = afv_ed0(r,afv,e,"new")*afv_edtrd0(r,afv,"new")*btu_conv(r,e,"fuel","rodf")/btu_gal("oil")  ;

* Generate values for MPG comparison for Road Passenger vehicles
    chk_mpg(r,afv,"out")$(rodpafv(afv) and targt_mpge(r,"rodp"))
       =(tran_vmt0(r,"rodp")*(1/targt_mpge(r,"rodp"))/y0(r,"rodp","new"));

    chk_mpg(r,afv,"in")$(rodpafv(afv) and targt_mpge(r,"rodp"))
       =(sum(e,afv_ed0(r,afv,e,"new")*afv_edtrd0(r,afv,"new")*btu_conv(r,e,"fuel","rodp")/btu_gal("oil")))   ;

    chk_mpg(r,afv,e)$(rodpafv(afv) and targt_mpge(r,"rodp"))
       =afv_ed0(r,afv,e,"new")*afv_edtrd0(r,afv,"new")*btu_conv(r,e,"fuel","rodp")/btu_gal("oil")   ;

    chk_afvt(r,afv,v,t,"out_y0")   = 1-ty(r,afv);
    chk_afvt(r,afv,v,t,"out_fes")$new(v)  = chk_mpg(r,afv,"out");
    chk_afvt(r,afv,v,t,"out")      = chk_afvt(r,afv,v,t,"out_y0")+chk_afvt(r,afv,v,t,"out_fes")$new(v);

* Check inputs to AFV production
    chk_afvt(r,afv,v,t,"l")     = afv_ld0(r,afv,v)*(1+tl(r,afv));
    chk_afvt(r,afv,v,t,"k")     = sum(k,afv_kd0(r,afv,k,v)*(1+tk(r,k,afv)));
    chk_afvt(r,afv,v,t,"hk")    = afv_hkd0(r,afv,v)*(1+thk(r,afv));
    chk_afvt(r,afv,v,t,"a")     = sum(g,afv_id0(r,afv,g,v)*(1+ti(r,g,afv)));
    chk_afvt(r,afv,v,t,"ed")    = sum(e,afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v));
    chk_afvt(r,afv,v,t,"ed_btu")= sum(e,afv_ed0(r,afv,e,v)*afv_edtrd0(r,afv,v)*btu_conv(r,e,"fuel",afv));

    chk_afvt(r,afv,v,t,"ff")   = afv_ff0(r,afv,v);
    chk_afvt(r,afv,v,t,"in_fes")$new(v)  = chk_mpg(r,afv,"in");
    chk_afvt(r,afv,v,t,"in")   =  chk_afvt(r,afv,v,t,"l")
                               + chk_afvt(r,afv,v,t,"k")
                               + chk_afvt(r,afv,v,t,"hk")
                               + chk_afvt(r,afv,v,t,"a")
                               + chk_afvt(r,afv,v,t,"ed")
                               + chk_afvt(r,afv,v,t,"ff")
                               + chk_afvt(r,afv,v,t,"in_fes")$new(v) ;

* Check inputs to OEV production
    chk_afvt(r,oev,v,t,"out_y0")  = sum(mapoev(oev,s),(1-ty(r,s)));
    chk_afvt(r,oev,v,t,"out_fes")$new(v) = sum(mapoev(oev,s),chk_mpg(r,s,"out")) ;
    chk_afvt(r,oev,v,t,"out")     = chk_afvt(r,oev,v,t,"out_y0")+chk_afvt(r,oev,v,t,"out_fes");

    chk_afvt(r,oev,v,t,"l")    = sum(mapoev(oev,s),(ld0(r,s,v)*mk(r,s,"ld0",v))*(1+tl(r,s))/y0(r,s,v));
    chk_afvt(r,oev,v,t,"k")    = sum(mapoev(oev,s),sum(k,(kd0(r,k,s,v)*mk(r,s,"kd0",v))*(1+tk(r,k,s))/y0(r,s,v)));
    chk_afvt(r,oev,v,t,"hk")   = sum(mapoev(oev,s),(hkd0(r,s,v)*mk(r,s,"hkd0",v))*(1+thk(r,s))/y0(r,s,v));
    chk_afvt(r,oev,v,t,"a")    = sum(mapoev(oev,s),sum(g,(id0(r,g,s,v)*mk(r,s,"id0",v))*(1+ti(r,g,s))/y0(r,s,v)));
    chk_afvt(r,oev,v,t,"e")    = sum(mapoev(oev,s),sum(e$(not ob(e)),(ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v))/y0(r,s,v)));
    chk_afvt(r,oev,v,t,"oev")  = sum(mapoev(oev,s),(sum(e$ob(e),ed0(r,e,"fuel",s,v))*mk(r,s,"ed0",v))/y0(r,s,v)) ;
    chk_afvt(r,oev,v,t,"ed")   = chk_afvt(r,oev,v,t,"e")
                                 +chk_afvt(r,oev,v,t,"oev");
    chk_afvt(r,oev,v,t,"ed_btu")= sum(mapoev(oev,s), ( sum(e$(not ob(e)),(ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v)*btu_conv(r,e,"fuel",s))/y0(r,s,v))
                                                    +(sum(e$ob(e),ed0(r,e,"fuel",s,v)*mk(r,s,"ed0",v)*btu_conv(r,e,"fuel",s)))/y0(r,s,v)));

    chk_afvt(r,oev,v,t,"in_fes")$new(v)  = sum(mapoev(oev,s),chk_mpg(r,s,"in")) ;
    chk_afvt(r,oev,v,t,"in")      =    chk_afvt(r,oev,v,t,"l")
                                      + chk_afvt(r,oev,v,t,"k")
                                      + chk_afvt(r,oev,v,t,"hk")
                                      + chk_afvt(r,oev,v,t,"a")
                                      + chk_afvt(r,oev,v,t,"ff")
                                      + chk_afvt(r,oev,v,t,"e")
                                      + chk_afvt(r,oev,v,t,"oev")
                                      + chk_afvt(r,oev,v,t,"in_fes")  ;

* Check OEV and AFV production - input and output in value term
    chk_afvtV(r,i,v,"y0",t)$oev(i)     = sum(mapoev(i,j),py.L(r,j)*(1-ty(r,j))*y0_.L(r,j,v));
    chk_afvtV(r,i,v,"mpge0",t)$(oev(i) and new(v))= sum(mapoev(i,j),pmpge.L(r,j)*(mpgeIn_.L(r,j,v)-mpgeOut_.L(r,j,v)));

    chk_afvtV(r,i,v,"ld0",t)$oev(i)    = sum((mapoev(i,j)),pl.L(r)*(1+tl(r,j))*ld0_.L(r,j,v));
    chk_afvtV(r,i,v,"id0",t)$oev(i)    = sum((mapoev(i,j),g),pa.L(r,g)*(1+ti(r,g,j))*id0_.L(r,g,j,v));
    chk_afvtV(r,i,v,"kd0",t)$(oev(i) and new(v))     = sum((mapoev(i,j),k),rk.L(r,k)*(1+tk(r,k,j))*kd0_.L(r,k,j,v));
    chk_afvtV(r,i,v,"kd0",t)$(oev(i) and extant(v))  = sum((mapoev(i,j),k),rkx.L(r,k,j)*(1+tk(r,k,j))*kd0_.L(r,k,j,v));
    chk_afvtV(r,i,v,"hkd0",t)$(oev(i))               = sum(mapoev(i,j),phk.L(r)*(1+thk(r,j))*hkd0_.L(r,j,v));

    chk_afvtV(r,i,v,"ob0",t)$(oev(i) )               = sum(mapoev(i,j),poev.l(r,j))*oev_valuS0_.L(r,"fuel",i,v);
    chk_afvtV(r,i,v,e,t)$(oev(i) and not ob(e))      = sum(mapoev(i,j),ped.l(r,e,"fuel",j)*ed0_.L(r,e,"fuel",j,v));
    chk_afvtV(r,i,v,"ff0",t)$(oev(i) and new(v))     = sum(mapoev(i,j),ptrnff.L(r,j)*trnff_.L(r,j,v));


* Check inputs to AFV production
    chk_afvtV(r,i,v,"y0",t)$afv(i)     = sum(maptrn(j,i),py.L(r,j))*(1-ty(r,i))*y0_.L(r,i,v);
    chk_afvtV(r,i,v,"mpge0",t)$(afv(i) and new(v))= sum(maptrn(j,i),pmpge.L(r,j))*(mpgeIn_.L(r,i,v)-mpgeOut_.L(r,i,v));

    chk_afvtV(r,i,v,"ld0",t)$afv(i)    = pl.L(r)*(1+tl(r,i))*ld0_.L(r,i,v);
    chk_afvtV(r,i,v,"id0",t)$afv(i)    = sum(g,pa.L(r,g)*(1+ti(r,g,i))*id0_.L(r,g,i,v));
    chk_afvtV(r,i,v,"kd0",t)$(afv(i) and new(v))     = sum(k,rk.L(r,k)*(1+tk(r,k,i))*kd0_.L(r,k,i,v));
    chk_afvtV(r,i,v,"kd0",t)$(afv(i) and extant(v))  = sum(k,rkx.L(r,k,i)*(1+tk(r,k,i))*kd0_.L(r,k,i,v));
    chk_afvtV(r,i,v,"hkd0",t)$(afv(i))               = phk.L(r)*(1+thk(r,i))*hkd0_.L(r,i,v);

    chk_afvtV(r,i,v,"ob0",t)$(afv(i) )               = sum(maptrn(j,i),poev.l(r,j))*oev_valuS0_.L(r,"fuel",i,v);
    chk_afvtV(r,i,v,e,t)$(afv(i) and not ob(e))      = pa.l(r,e)*ed0_.L(r,e,"fuel",i,v);
    chk_afvtV(r,i,v,"ff0",t)$(afv(i) and new(v))     = pafvff.L(r,i)*afvff0_.L(r,i,v);

    chk_afvtV(r,i,v,"Out-In",t) =      chk_afvtV(r,i,v,"y0",t)
                                    -  chk_afvtV(r,i,v,"mpge0",t)
                                    -  chk_afvtV(r,i,v,"ld0",t)
                                    -  chk_afvtV(r,i,v,"id0",t)
                                    -  chk_afvtV(r,i,v,"kd0",t)
                                    -  chk_afvtV(r,i,v,"hkd0",t)
                                    -  chk_afvtV(r,i,v,"ob0",t)
                                    -  sum(e, chk_afvtV(r,i,v,e,t))
                                    -  chk_afvtV(r,i,v,"ff0",t);

* Check OEV and AFV production - input and output in quantity term
    chk_afvtQ(r,i,v,"y0",t)$oev(i)     = sum(mapoev(i,j),y0_.L(r,j,v));
    chk_afvtQ(r,i,v,"mpge0",t)$(oev(i) and new(v))= sum(mapoev(i,j),(mpgeIn_.L(r,j,v)-mpgeOut_.L(r,j,v)));

    chk_afvtQ(r,i,v,"ld0",t)$oev(i)    = sum(mapoev(i,j),ld0_.L(r,j,v));
    chk_afvtQ(r,i,v,"id0",t)$oev(i)    = sum((mapoev(i,j),g),id0_.L(r,g,j,v));
    chk_afvtQ(r,i,v,"kd0",t)$(oev(i) and new(v))     = sum((mapoev(i,j),k),kd0_.L(r,k,j,v));
    chk_afvtQ(r,i,v,"kd0",t)$(oev(i) and extant(v))  = sum((mapoev(i,j),k),kd0_.L(r,k,j,v));
    chk_afvtQ(r,i,v,"hkd0",t)$(oev(i))               = sum(mapoev(i,j),hkd0_.L(r,j,v));

    chk_afvtQ(r,i,v,"ob0",t)$(oev(i) )               = oev_valuS0_.L(r,"fuel",i,v);
    chk_afvtQ(r,i,v,e,t)$(oev(i) and not ob(e))      = sum(mapoev(i,j),ed0_.L(r,e,"fuel",j,v));
    chk_afvtQ(r,i,v,"ff0",t)$(oev(i) and new(v))     = sum(mapoev(i,j),trnff_.L(r,j,v));


    chk_afvtQ(r,i,v,"y0",t)$afv(i)     = y0_.L(r,i,v);
    chk_afvtQ(r,i,v,"mpge0",t)$(afv(i) and new(v))= (mpgeIn_.L(r,i,v)-mpgeOut_.L(r,i,v));

    chk_afvtQ(r,i,v,"ld0",t)$afv(i)    =ld0_.L(r,i,v);
    chk_afvtQ(r,i,v,"id0",t)$afv(i)    = sum(g,id0_.L(r,g,i,v));
    chk_afvtQ(r,i,v,"kd0",t)$(afv(i) and new(v))     = sum(k,kd0_.L(r,k,i,v));
    chk_afvtQ(r,i,v,"kd0",t)$(afv(i) and extant(v))  = sum(k,kd0_.L(r,k,i,v));
    chk_afvtQ(r,i,v,"hkd0",t)$(afv(i))               = hkd0_.L(r,i,v);

    chk_afvtQ(r,i,v,"ob0",t)$(afv(i) )               = oev_valuS0_.L(r,"fuel",i,v);
    chk_afvtQ(r,i,v,e,t)$(afv(i) and not ob(e))      = ed0_.L(r,e,"fuel",i,v);
    chk_afvtQ(r,i,v,"ff0",t)$(afv(i) and new(v))     = afvff0_.L(r,i,v);

* Check OEV and AFV production - input and output in price term
    chk_afvtP(r,i,v,item1,t)$(chk_afvtQ(r,i,v,item1,t)<>0) =chk_afvtV(r,i,v,item1,t)/chk_afvtQ(r,i,v,item1,t);

* Combine OEV and AFV production - input and output for all terms
    chk_afvtall(r,i,v,"V",item1,t)$chk_afvtv(r,i,v,"y0",t)
                                                           =  chk_afvtV(r,i,v,item1,t)
                                                             /chk_afvtv(r,i,v,"y0",t)
                                                             *  sum(maptrn(j,i),py.L(r,j))
                                                             * sum(maptrn3(jj,i),afv_costT0(r,jj,"y0","2010"));

    chk_afvtall(r,i,v,"Q",item1,t)$chk_afvtQ(r,i,v,"y0",t) = chk_afvtQ(r,i,v,item1,t)/chk_afvtQ(r,i,v,"y0",t);
    chk_afvtall(r,i,v,"P",item1,t) = chk_afvtP(r,i,v,item1,t);
