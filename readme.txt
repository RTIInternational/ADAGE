$title  ADAGE Model - Script to Run the model
* Date: 4-6-2023


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                         Version 1:  Oil Price Analysis
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*This is the run for the oil price paper:
*Scenarios conducted for:
*  Cai, Y., J. Woollacott, R.H. Beach, L. Rafelski, C. Ramig, and M. Shelby.
*         Insights from Adding Transportation Sector Detail into an Economy-Wide Model: The Case of the ADAGE CGE Model.
*   It is under review&revision at Energy Economics.
*
*1) Model version:
*     "Model version"          "name in the model"     Definition
*      YesAFV                        DA                Disaggregagetd transportation (eight modes) with AFV  for on-road
*       NoAFV                        DN                Disaggregagetd transportation (eight modes) without AFV  for on-road
*       Agg                          AN                Aggregated transportation (LDV and Other Trn) without AFV  for on-road
*   Model version is defined in setglobal DA, DN, AN in data.gms. Only one can be activated
*2) Oil price scenario:
*    "Oil Price scenario"      Definition
*        REF                    AEO2018 reference crude oil price
*        LOP                    AEO2018 low crude oil price
*        HOP                    AEO2018 high crude oil price
*    Oil price scenario is set through command  --scn=### (see below)
*
*a) DA: disaggregated with eight transportation sectors and 5 types of technologies in onroad transportation
**  Important:   data.gms:  make sure $setglobal DA is on
mkdir  .\lst\DA   .\output\DA
gams data.gms    s=.\lst\DA\a1
gams model.gms   r=.\lst\DA\a1 s=.\lst\DA\a2
gams loop.gms    --scn=ref --nt=9  r=.\lst\DA\a2   s=.\lst\DA\ref50   gdx=.\output\DA\DA_REF
gams loop.gms    --scn=hop --nt=9  r=.\lst\DA\a2   s=.\lst\DA\hop50   gdx=.\output\DA\DA_HOP
gams loop.gms    --scn=lop --nt=9  r=.\lst\DA\a2   s=.\lst\DA\lop50   gdx=.\output\DA\DA_LOP


*b) DN: disaggregated with eight transportation sectors and only 1 type of conventional technology in onroad transportation
*  Important:   data.gms:  make sure $setglobal DN is on
mkdir  .\lst\DN\   .\output\DN\
gams data.gms    s=.\lst\DN\a1
gams model.gms   r=.\lst\DN\a1  s=.\lst\DN\a2
gams loop.gms    --scn=ref --nt=9  r=.\lst\DN\a2   s=.\lst\DN\ref50   gdx=.\output\DN\DN_REF
gams loop.gms    --scn=hop --nt=9  r=.\lst\DN\a2   s=.\lst\DN\hop50   gdx=.\output\DN\DN_HOP
gams loop.gms    --scn=lop --nt=9  r=.\lst\DN\a2   s=.\lst\DN\lop50   gdx=.\output\DN\DN_LOP

*c) AN: disaggregated with auto and otrn in transportation sectors and only 1 type of conventional technology in onroad transportation
*   Important:   data.gms:  make sure $setglobal AN is on

mkdir  .\lst\AN\   .\output\AN\
gams data.gms    s=.\lst\AN\a1
gams model.gms   r=.\lst\AN\a1  s=.\lst\AN\a2
gams loop.gms    --scn=ref --nt=9  r=.\lst\AN\a2   s=.\lst\AN\ref50   gdx=.\output\AN\AN_REF
gams loop.gms    --scn=hop --nt=9  r=.\lst\AN\a2   s=.\lst\AN\hop50   gdx=.\output\AN\AN_HOP
gams loop.gms    --scn=lop --nt=9  r=.\lst\AN\a2   s=.\lst\AN\lop50   gdx=.\output\AN\AN_LOP

*d) merge scenarios and export to excel
*   Important: make sure the default file Adage_oilprice4tableau0.xlsx is located in .\output\all
*              make sure setglobal pcru is turned on and setglobal doc is off in merge.gms

mkdir   .\lst\all     .\output\all
gams merge            s=.\lst\all\merge   pw=500
gams merge2xls_pcru   r=.\lst\all\merge  --vsn=all    pw=500


*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
*                         Version 2: Model documentation
*CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
* Important:   data.gms:  make sure $setglobal DA is on and --scn=Ref is in the loop.gms command line

mkdir  .\lst\DA\Doc   .\output\DA\Doc
gams data.gms    s=.\lst\DA\Doc\a1
gams model.gms   r=.\lst\DA\Doc\a1 s=.\lst\DA\Doc\a2
gams loop.gms    --scn=ref --nt=9  r=.\lst\DA\Doc\a2   s=.\lst\DA\Doc\ref50   gdx=.\output\DA\Doc\Doc_REF

* make sure setglobal doc is activated on and setglobal pcru is off in merge
gams merge            s=.\lst\DA\Doc\merge   pw=500
gams merge2xls_pcru   r=.\lst\DA\Doc\merge  --vsn=DA\Doc    pw=500
gams report4docu      r=.\lst\DA\Doc\merge  --vsn=DA\Doc    pw=500

