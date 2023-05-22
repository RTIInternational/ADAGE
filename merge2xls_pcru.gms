$set  outf    '.\output\%vsn%\Adage_oilprice4tableau0'

alias (iii,*);
parameter   carbemis2;
carbemis2(merged_set_1, r,"land","CO2",t)   = carbemis(merged_set_1, r,"land",t);
carbemis2(merged_set_1, r,iii,ghg,t)$(not sameas(iii,"land"))
        =   ghgt(merged_set_1,r,iii,ghg,t)  + sum((e,use),co2t_ff(merged_set_1,r,e,use,iii,t))$sameas(ghg,"CO2");

display carbemis,carbemis2;
display   tran_vmtV,prices_fuel;

execute_unload '%outf%.gdx',
               modelstats, macro,gdp_sec,output,
               en_valu,en_btu,entrd_valu,entrd_btu,entrd_gal, enprod_valu,enprod_btu,ele_valu,ele_btu,elesource,
               prices,price,prices_kt_pc, cons,cons_tonn,  cons_p,cons_all,cons_all_tonn, cons_allp,cons_alls,cons_alls_tonn,
               agbio_macro,land_valu,land_area,
               emis_rep,co2t_ff,co2tot_ff,co2tott_ff,ghgt,ghgtot,ghgtott,carbemis,carbemis2,carbemist, co2elet,
               trade,bi_trade,
               auto_valu,auto_gal,auto_btu,auto_pric,auto_pric_pc,prices_fuel,prices_fuel_pc,
               OEV_valu,OEV_gal,OEV_btu,OEV_pric,OEV_pric_pc,
               ag_valu,ag_tonn,ag_pric,ag_lndh,ag_lndv,chk_macro,chk_shr,oev_shr_btu
               tran_vmt, tran_vmtV,tran_valu,tran_prod_pmt,tran_prod_tmt, tran_enbtu, tran_emis, tran_mpge, tran_mpgeV, tran_mpgeAFV,tran_surratio, USA_auto_stockV,USA_auto_stock,
               ag_tonn_trad, ag_tonn_cons, ag_pric_cons
               chk_afvtV,chk_afvtP,chk_afvtQ, chk_afvtall,chk_gdp
               ;

execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=macro             rng=macro!a2           cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=gdp_sec           rng=gdp_sec!a2        cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=output            rng=output!a2          cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=price             rng=price!a2           cdim=0'

execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=cons              rng=cons!a2            cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=cons_tonn        rng=cons_tonn!a2       cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=cons_p           rng=cons_p!a2          cdim=0'

*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=cons_all         rng=cons_all!a2        cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=cons_all_tonn    rng=cons_all_tonn!a2   cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=cons_allp        rng=cons_allp!a2       cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=cons_alls         rng=cons_alls!a2       cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=cons_alls_tonn   rng=cons_alls_tonn!a2  cdim=0'

execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=trade             rng=trade!a2           cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=bi_trade          rng=bi_trade!a2        cdim=0'

*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=agbio_macro      rng=agbio_macro!a2     cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=land_valu        rng=land_valu!a2       cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=land_area         rng=land_area!a2       cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=emis_rep         rng=emis_rep!a2        cdim=0'

*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ag_valu          rng=ag_valu!a2         cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ag_tonn           rng=ag_tonn!a2         cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ag_pric           rng=ag_pric!a2         cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ag_lndh           rng=ag_lndh!a2         cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ag_lndv          rng=ag_lndv!a2         cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ag_tonn_trad     rng=ag_tonn_trad!a2    cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ag_tonn_cons     rng=ag_tonn_cons!a2    cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ag_pric_cons     rng=ag_pric_cons!a2    cdim=0'

*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=enprod_valu      rng=enprod_valu!a2     cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=enprod_btu        rng=enprod_btu!a2      cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ele_valu         rng=ele_valu!a2        cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ele_btu           rng=ele_btu!a2         cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=elesource         rng=elesource!a2       cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=en_valu          rng=en_valu!a2         cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=en_btu            rng=en_btu!a2          cdim=0'

*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=entrd_valu       rng=entrd_valu!a2      cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=entrd_btu        rng=entrd_btu!a2       cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=entrd_gal        rng=entrd_gal!a2       cdim=0'

execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_vmt          rng=tran_vmt!a2        cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_vmtV         rng=tran_vmtV!a2       cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_valu         rng=tran_valu!a2       cdim=0'

execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_prod_pmt     rng=tran_prod_pmt!a2   cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_prod_tmt     rng=tran_prod_tmt!a2   cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_enbtu        rng=tran_enbtu!a2      cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_emis         rng=tran_emis!a2       cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_mpge         rng=tran_mpge!a2       cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_mpgeV        rng=tran_mpgeV!a2      cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_mpgeAFV      rng=tran_mpgeafv!a2    cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=tran_surratio     rng=tran_surratio!a2   cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=USA_auto_stockV  rng=USA_auto_stockV!a2 cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=USA_auto_stock   rng=USA_auto_stock!a2  cdim=0'

execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=prices_fuel      rng=prices_fuel!a2      cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=prices_kt_pc     rng=prices_kt_pc!a2     cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx par=prices_fuel_pc   rng=prices_fuel_pc!a2   cdim=0'

execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=oev_shr_btu      rng=oevshr_btu!a2       cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=OEV_valu        rng=OEV_valu!a2         cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=OEV_gal         rng=OEV_gal!a2          cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=OEV_btu         rng=OEV_btu!a2          cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=OEV_pric        rng=OEV_pric!a2         cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=OEV_pric_pc     rng=OEV_pric_pc!a2      cdim=0'


execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=carbemis         rng=carbemis!a2         cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=carbemis2        rng=carbemis2!a2        cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=carbemist       rng=carbemist!a2        cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ghgt             rng=ghgt!a2             cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ghgtot          rng=ghgtot!a2           cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=ghgtott         rng=ghgtott!a2          cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=co2t_ff          rng=co2t_ff!a2          cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=co2tot_ff        rng=co2tot_ff!a2        cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=co2tott_ff      rng=co2tott_ff!a2       cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=co2elet          rng=co2elet!a2          cdim=0'

execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=modelstats        rng=modelstats!a2      cdim=0'
execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=chk_afvtall       rng=chk_afvtall!a2     cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=chk_macro       rng=chk_macro!a2        cdim=0'
*execute 'gdxxrw.exe %outf%.gdx o=%outf%.xlsx  par=chk_shr         rng=chk_shr!a2          cdim=0'




