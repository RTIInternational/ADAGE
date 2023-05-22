::  ADAGE Model - Script to Run the model

:: CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
::                               Oil Price Analysis
:: Scenarios conducted for:
:: Cai, Y., J. Woollacott, R.H. Beach, L. Rafelski, C. Ramig, and M. Shelby. 
:: Insights from Adding Transportation Sector Detail into an Economy-Wide Model: The Case of the ADAGE CGE Model. 
:: Energy Economics, 2023. 
:: CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

:: Set up directory for list and output file
::   \DA\: directory for version results with disaggregated transportation sector
if not exist ".\lst\DA\" mkdir  .\lst\DA\   .\output\DA\
if not exist ".\chk\"    mkdir  .\chk\

:: Define parameters relating growth of Alternative Fuel and Original Equipment Vehicles (AFV, OEV)
::   in heavy duty sector relative to light duty sector
::   s: AFV-to-OEV fixed factor (FF) ratio in 2020 for HDVs (HDV-AFV / HDV-OEV)
::   g: annual growth rate for HDV-AFV / HDV-OEV ratio
::   eafv: HDV-AFVs FF elasticity / LDV-AFVs FF elasticity
:: Specify GAMS save file location
::   s: save gams file memory
gams data       --s=0.04  --g=0.08 --eafv=0.25  s=.\lst\DA\a1

:: Run model structure
::   r: restart from saved GAMS file memory
gams model.gms  r=.\lst\DA\a1  s=.\lst\DA\a2

:: Define scenario, time periods, and gdx output file location
::   scn: scenario to run
::   nt:  number of time periods to run (1-9; 2010-2050)
::   gdx: location of gdx output file with all parameters and variables for each scenario

::   ref: reference scenario 
gams loop.gms --scn=ref --nt=9  r=.\lst\DA\a2   s=.\lst\DA\ref50   pw=500   gdx=.\output\DA\DA_REF
::   hop: high oil price scenario
gams loop.gms --scn=hop --nt=9  r=.\lst\DA\a2   s=.\lst\DA\hop50   pw=500   gdx=.\output\DA\DA_HOP
::   lop: low oil price scenario
gams loop.gms --scn=lop --nt=9  r=.\lst\DA\a2   s=.\lst\DA\lop50   pw=500   gdx=.\output\DA\DA_LOP

:: Merge results from scenarios
gams merge  s=.\lst\DA\merge     --vsn=DA   pw=500

:: CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC


