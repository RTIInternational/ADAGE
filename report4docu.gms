$Title ADAGE - Report for BAU Case for Model Documentation


$set  outf   '.\output\%vsn%\ADAGE_doc0'

Table pop(reg,t)  population projection from 2010 to 2050 in UN2017 (million)

           2010        2015        2020        2025        2030        2035        2040        2045        2050

USA     317.641     319.929     331.432     343.256     354.712     365.034     374.069     382.059     389.592
BRA     195.423     205.962     213.863     220.371     225.472     229.203     231.602     232.724     232.688
CHN    1361.763    1404.274    1432.096    1446.604    1449.169    1441.636    1425.672    1402.595    1372.710
EUR     497.763     503.340     506.916     508.346     508.710     507.904     506.101     503.288     499.400
XLM     282.707     300.628     316.838     331.877     345.566     357.566     367.827     376.302     382.958
XAS    2471.685    2648.977    2794.951    2930.300    3050.744    3153.855    3238.509    3305.941    3356.795
AFR    1033.043    1194.370    1352.622    1522.250    1703.538    1896.704    2100.302    2311.561    2527.557
ROW     738.178     805.340     846.570     882.412     913.085     940.596     966.049     989.531    1009.913
;
pop("Total",t)=sum(r,pop(r,t));

parameter
           whlprc0         Wholesale price ($ per mbbtu)
*          price0         Retail price ($ per mbbtu)
           bio_convert     Biofuel converter (gallon per dry tonne)
           btu_conv        Quad Btu (10**15 btu) per billion dollars in energy retail market
           btuprod_conv    Energy conversion between dolloar to btu in production side (quad btu per billion dollars)
           btuim_conv      Energy conversion between dolloar to btu in import side (quad btu per billion dollars)
           btuex_conv      Energy conversion between dolloar to btu in export side (quad btu per billion dollars)
           btuen_conv      Energy conversion between dolloar to btu in bilateral trade side (quad btu per billion dollars)

           gal_conv        Gallons per dollar of fuel at retail market
           btu_gal         Million btu and gallon conversion (quad btu per billion gallon = million btu per gal)

           p_land0         Final land rent for the model in 2010 ($billion per mha)
*          ag_pric0        Producer price for ag related goods ($1000 per ton)
           tx, tm,tc,ty    Tax for export & import & consumption &production;

$gdxin 'data\dataout4merge.gdx'
$load  whlprc0     bio_convert   btu_conv  gal_conv btu_gal btuprod_conv btuim_conv btuex_conv btuen_conv  p_land0    tx tm  tc ty
*$load ag_pric0
$gdxin

display  whlprc0, p_land0 ;
display prices_pc,en_btu,auto_btu;

table price0(r,*)      Retail price ($ per mbbtu)
            Col         Cru         Ele         Gas         Oil        Ceth        Weth        Scet        Sbet        Sybd        Rpbd        Plbd
USA       3.456      12.918      26.251      10.350      20.223      22.628      22.628      22.628      22.628      22.628                  22.628
BRA       2.256      12.918      65.426       6.925      25.188                              22.965                  22.965
CHN       5.026      12.918      23.262      14.394      23.549      24.358                                          24.358
EUR       7.010      12.918      40.699      15.305      35.368                  45.565      45.565      45.565      45.565      45.565      45.565
XLM       2.554      12.918      53.240       8.400      18.841                              24.130                  22.965
XAS       4.663      12.918      37.239      14.201      25.685                  36.208      22.968                  38.478      36.208      23.006
AFR       6.149      12.918      37.230       8.578      25.595
ROW       2.864      12.918      27.045       5.978      25.339      30.961      31.553      30.961                              46.848
;

    price0(r,"ethl")$sum(ethl$price0(r,ethl),1) = sum(ethl, price0(r,ethl))/sum(ethl$price0(r,ethl),1) ;
    price0(r,"biod")$sum(biod$price0(r,biod),1) = sum(biod, price0(r,biod))/sum(biod$price0(r,biod),1) ;

parameter price0_gal(r,*)   Retail prices for biofuels ($per gal);
    price0_gal(r,e)$btu_gal(e)= price0(r,e)*btu_gal(e);
    price0_gal(r,"ethl")$sum(ethl$price0_gal(r,ethl),1) = sum(ethl, price0_gal(r,ethl))/sum(ethl$price0_gal(r,ethl),1) ;
    price0_gal(r,"biod")$sum(biod$price0_gal(r,biod),1) = sum(biod, price0_gal(r,biod))/sum(biod$price0_gal(r,biod),1) ;

display price0,price0_gal;

    ag_tonn(merged_set_1,"Total",i,t) =sum(r, ag_tonn(merged_set_1,r,i,t));
    ag_tonn(merged_set_1,reg,"crop",t)=sum(crp, ag_tonn(merged_set_1,reg,crp,t));

    ag_pric(merged_set_1,r,"crop",t)= sum(crp,ag_pric(merged_set_1,r,crp,t)*ag_tonn(merged_set_1,r,crp,t))/sum(crp,ag_tonn(merged_set_1,r,crp,t));
    ag_pric(merged_set_1,"Total",i,t)$sum(r,ag_tonn(merged_set_1,r,i,t))
         = sum(r,ag_pric(merged_set_1,r,i,t)*ag_tonn(merged_set_1,r,i,t))/sum(r,ag_tonn(merged_set_1,r,i,t));

    ag_pric(merged_set_1,"Total","crop",t)= sum((r,crp),ag_pric(merged_set_1,r,crp,t)*ag_tonn(merged_set_1,r,crp,t))/sum((r,crp),ag_tonn(merged_set_1,r,crp,t));
    ag_pric(merged_set_1,r,i,t)$ag_pric(merged_set_1,r,i,t) =  ag_pric(merged_set_1,r,i,t)/ag_pric(merged_set_1,r,i,"2010");

parameter en_pric     Energy price ($ per mmbtu);

    en_pric(merged_set_1,r,"Ele",t) = price0(r,"ele")*prices_pc(merged_set_1,r,"ele","ped",t);
    en_pric(merged_set_1,r,"Col",t) = whlprc0(r,"col")*prices_pc(merged_set_1,r,"col","py",t);
    en_pric(merged_set_1,r,"Cru",t) = whlprc0(r,"cru")*prices_pc(merged_set_1,r,"CRU","py",t) ;
    en_pric(merged_set_1,r,"Gas",t) = whlprc0(r,"gas")*prices_pc(merged_set_1,r,"gas","py",t);
    en_pric(merged_set_1,r,"Oil",t) = whlprc0(r,"oil")*prices_pc(merged_set_1,r,"oil","py",t);

    en_pric(merged_set_1,"Total",e,t)$sum(r$en_pric(merged_set_1,r,e,t), enprod_btu(merged_set_1,r,e,t))
         = sum(r, en_pric(merged_set_1,r,e,t)*enprod_btu(merged_set_1,r,e,t))
          /sum(r$en_pric(merged_set_1,r,e,t), enprod_btu(merged_set_1,r,e,t))    ;

*   en_pric(merged_set_1,r,e,t)$en_pric(merged_set_1,r,e,"2010")=en_pric(merged_set_1,r,e,t)/en_pric(merged_set_1,r,e,"2010");
display  ag_pric,en_pric ;

parameter ag_pricindex   Ag price indx for the world (1 in 2010)
          en_pricindex   Energy price indx for the world (1 in 2010)   ;

    ag_pricindex(merged_set_1,i,t)$ag_pric(merged_set_1,"Total",i,"2010")
        =  ag_pric(merged_set_1,"Total",i,t)/ ag_pric(merged_set_1,"Total",i,"2010");

    en_pricindex(merged_set_1,e,t)$en_pric(merged_set_1,"Total",e,"2010")   = en_pric(merged_set_1,"Total",e,t)/en_pric(merged_set_1,"Total",e,"2010");
display ag_tonn,ag_pric,ag_pricindex,en_pricindex;

set t0 /1980*2019/;
table   Intensity(*,*)     Historical energy intensity with respect to population (mmbtu per person) and GDP PPP (btu per $2010 GDP ppp)
*https://www.eia.gov/international/data/world/other-statistics/energy-intensity-by-gdp-and-population?pd=47&p=000000000000000000000000000000000000000000000000000000002g&u=0&f=A&v=mapbubble&a=-&i=none&vo=value&t=C&g=00000000000000000000000000000000000000000000000001&l=249-ruvvvvvfvtvnvv1vrvvvvfvvvvvvfvvvou20evvvvvvvvvvnvvvs0008&s=315532800000&e=1546300800000&
* data is converted to $2010 value
      1980        1985        1990        1995        2000        2005        2010        2015        2019
pop  343.53      320.89     338.39      341.61      349.94      338.83      315.31      303.64      305.48
gdp  12.01        9.99        9.38        8.90        7.82        6.98        6.50        5.81        5.47
;
Parameter  En_prim      Primary energy production (quad btu)
           En_Inten     Energy Intensity with respect to GDP (quad per $billion)
           ELE_source   Electricity generation by source (quad) ;

    En_Prim(merged_set_1,reg,cgo,t)$(not sameas(cgo,"oil"))   = enprod_btu(merged_set_1,reg,cgo,t);
    En_Prim(merged_set_1,reg,"cru",t) = enprod_btu(merged_set_1,reg,"cru",t);
    En_Prim(merged_set_1,reg,rnw,t) = ele_btu(merged_set_1,reg,rnw,t);
    En_Prim(merged_set_1,reg,"Biof_f",t) = sum(bio,enprod_btu(merged_set_1,reg,bio,t));
    En_Prim(merged_set_1,reg,"Biof_c",t) = sum(advbio,enprod_btu(merged_set_1,reg,advbio,t));
    En_Prim(merged_set_1,reg,"Total",t)  =   sum(cgo$(not sameas(cgo,"oil")),enprod_btu(merged_set_1,reg,cgo,t))
                                           + enprod_btu(merged_set_1,reg,"cru",t)
                                           + sum(rnw,ele_btu(merged_set_1,reg,rnw,t))
                                           + sum(bio,enprod_btu(merged_set_1,reg,bio,t))
                                           + sum(advbio,enprod_btu(merged_set_1,reg,advbio,t));

    En_Inten(merged_set_1,reg,t)         =1000* En_Prim(merged_set_1,reg,"Total",t)
                                          /GDP_(merged_set_1,reg,t);
    En_Inten(merged_set_1,"USA",t0)      =intensity("GDP",t0);

display en_prim,En_Inten;

parameter   carbemis2;
carbemis2(merged_set_1, r,"land","CO2",t)   = carbemis(merged_set_1, r,"land",t);
carbemis2(merged_set_1, r,iii,ghg,t)$(not sameas(iii,"land"))
        =   ghgt(merged_set_1,r,iii,ghg,t)  + sum((e,use),co2t_ff(merged_set_1,r,e,use,iii,t))$sameas(ghg,"CO2");


parameter GHG_gas(merged_set_1,r,*,t)    Total ghg emissions by ghg gas;
GHG_gas(merged_set_1,r,ghg,t)=   sum(i$(not trnv(i)),carbemis2(merged_set_1,r,i,ghg,t))
                               +  carbemis2(merged_set_1, r,"land",ghg,t) ;
*GHGworld(merged_set_1,r,"all",t)=sum((i,ghg)$(not trnv(i)),carbemis2(merged_set_1,r,i,ghg,t))
*                                 +sum(ghg,carbemis2(merged_set_1, r,"land",ghg,t));

display carbemis,GHG_gas;


execute_unload '%outf%.gdx', pop, gdp_,En_prim,En_Inten,ELE_btu,en_pricindex,ag_pricindex,Land_area,ag_tonn,tran_valu,ghg_gas;
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=pop            rng=Tab1_pop!a3          cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=GDP_           rng=Fig1_gdp!a3          cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=en_pricindex   rng=Fig2_enpric!a3       cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=En_prim        rng=Fig3_Enprim!a3       cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=ELE_btu        rng=Fig4_ELE!a3          cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=ag_pricindex   rng=Fig5_agpric!a3       cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=ag_tonn        rng=Fig6_agtonn!a3       cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=Land_area      rng=Fig7&8_Land_Land!a3  cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=tran_valu      rng=Fig9_tran!a2         cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=En_Inten       rng=Fig10_EnInten!a3     cdim=0'
execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=ghg_gas        rng=Tab2_ghg!a3          cdim=0'

*execute 'gdxxrw.exe %outf%.gdx   o=%outf%.xlsx     par=emistargetT    rng=emistargetT!a3       cdim=0'



