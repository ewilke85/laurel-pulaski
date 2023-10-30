macro "Regional Model Structure Version"
    model_version = 20240101 // Anticipated completion date
	// EW HDR revisions made as part of Laurel-Pulaski regional model update
    // Original script borrowed from the Owensboro model, which was developed by Ken Kaltenbach & Johnny Han, Corradino Group - 20201103
	// various updates to script made by MB Stantec as listed below

    required_tc_build = 22450
    required_tc_version = 8.0
    return({model_version, required_tc_build, required_tc_version})
    // create script from model table with 'RunMacro("TCP Create Model Script")'
endmacro

dbox "Regional Model Structure"
    right, center toolbox nokeyboard
    title: "Laurel-Pulaski Regional Planning Model"

    init do
        shared  project_dbox, ui_file, ScenArr, ScenSel

        ui_file = GetInterface()
        model_title = "Regional Model Structure"
        runmacro("load model")
        project_dbox = 1
      enditem

    macro "load model" do
        global cname,cnum, model_name
	   //cname={"DAVIESS","HANCOCK","HENDERSON","MCLEAN","OHIO"} // Daviess Model - EW HDR commented out
        cname={"CASEY","CLAY","JACKSON","KNOX","LAUREL","LINCOLN","MCCREARY","PULASKI","ROCKCASTLE","RUSSELL","WAYNE","WHITLEY"}	// EW HDR LP model counties
        cnum={23,26,55,61,63,69,74,100,102,104,116,118}
        global model_table,ModelDir,sellink, model_title
        {ModelInfo, StageInfo, MacroInfo,} = RunMacro("TCP Load Model", model_title)
        if ModelInfo = null then return()

        {model_table,,,model_version,} = ModelInfo
        {StepMacro, StepTitle, StepFlag, StepAcce} = MacroInfo
        StageName = StageInfo[1]
        stages = StageName.length

 	pparts=SplitPath(model_table)
	ModelDir=pparts[1]+pparts[2] //
	model_name = pparts[3] //EW HDR - get name of model to use later in script

        single_stage = 0
        sellink      = 0
        StepFlag = RunMacro("TCP Process Step Flags", StepFlag,, 0)

        if !RunMacro("TCP Update Project Dbox", model_title, stages, &ScenNames) then
            runmacro("closing")
      enditem

    update do
        if project_dbox = -99 then
            runmacro("closing")
        else do
            if !RunMacro("TCP Update Project Dbox", model_title, stages, &ScenNames) then
                runmacro("closing")
          end
      enditem

    close do runmacro("closing") enditem

    button  0,0
    icons: ModelDir+"GISDK\\BMP\\KYTC.bmp"

    frame 0.5, 6, 39.0, 7.7 prompt: "Scenarios"
    scroll list 1.5, 7.0, 37.0, 3.5 multiple list: ScenNames variable: ScenSel do
        RunMacro("TCP Update Scenarios", model_title, stages, model_table)
      enditem

    checkbox    2, 10.8, 15  prompt: "Stop after stage"  variable: single_stage
    checkbox same, 12.2, 15  prompt: "Selected Lnk run"  variable: sellink
    button   20, 10.8, 18, 1.0 prompt: "Model Table" do
        RunMacro("TCP Choose Model Table", model_title, model_table)
      enditem
    button same, 12.4, 18, 1.0 prompt: "Setup" do
        RunDbox("TCP Scenario Manager", model_title, model_table)
      enditem

    button "Regional_A1" 1, 14.5 icons: "bmp\\plannetwork.bmp" do cur_stage = 1  Runmacro("set steps") enditem		//EW HDR - Regional
    button "Regional_B1" after, same, 19.0, 1.6 disabled prompt:StageName[1]  do cur_stage = 1  Runmacro("run stages") enditem
    button "Regional_C1" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 1) enditem

    button "Regional_A2" 1, 16.8 icons: "bmp\\plantripgen.bmp" do cur_stage = 2  Runmacro("set steps") enditem
    button "Regional_B2" after, same, 19.0, 1.6 disabled prompt:StageName[2]  do cur_stage = 2  Runmacro("run stages") enditem
    button "Regional_C2" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 2) enditem

    button "Regional_A3" 1, 19.1 icons: "bmp\\planassign.bmp" do cur_stage = 3  Runmacro("set steps") enditem
    button "Regional_B3" after, same, 19.0, 1.6 disabled prompt:StageName[3]  do cur_stage = 3  Runmacro("run stages") enditem
    button "Regional_C3" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 3) enditem

    button "Regional_A4" 1, 21.4 icons: "bmp\\planmatrix.bmp" do cur_stage = 4  Runmacro("set steps") enditem
    button "Regional_B4" after, same, 19.0, 1.6 disabled prompt:StageName[4]  do cur_stage = 4  Runmacro("run stages") enditem
    button "Regional_C4" after, same icons: "bmp\\ViewButton.bmp", "bmp\\ViewButton.bmp", "bmp\\ViewButton2.bmp" do RunMacro("TCP Model Show", ScenArr, 4) enditem

    button     1,  26.6, 33, 1.6  prompt: "Quit"      do Runmacro("closing") enditem

    text  25, after variable: "v " + i2s(model_version)

    macro "set steps" do
        global idir,odir
        SetAlternateInterface()
        RunDbox("TCP Set Step Flags", StepTitle[cur_stage], &StepFlag[cur_stage], StepAcce[cur_stage])
      enditem

    macro "run stages" do
            global idir,odir
            scen_data_dir = ScenArr[ScenSel[1]][3]

            // - Create output and report folders if they do not exist already
            on error do
              goto lab1
            end
            CreateDirectory(scen_data_dir+"output")
            lab1:
            on error default
            on error do
              goto lab2
            end
            CreateDirectory(scen_data_dir+"Reports")
            lab2:
            on error default
            //

            repfile=scen_data_dir+"Reports\\SRMSModel.xml"
            logfile=scen_data_dir+"Reports\\SRMSLog.xml"
            idir=scen_data_dir+"input\\"
			odir=scen_data_dir+"output\\"

            oldrepfile=GetReportFileName()
            oldlogfile=GetLogFileName()
            SetReportFileName(repfile)
            SetLogFileName(logfile)
            shared d_LogInfo
            d_LogInfo.[Report File] = repfile
            d_LogInfo.[Log File]    = logfile

        if RunMacro("TCP Check Stage Files", cur_stage, single_stage, StepFlag, ScenArr, ScenSel) then
            RunMacro("TCP Run Stages", cur_stage, single_stage, StepMacro, StepFlag, ScenArr, ScenSel,, {{"Title", StepTitle}})
//
            if oldrepfile <> null then SetReportFileName(oldrepfile)
            if oldlogfile <> null then SetLogFileName(oldlogfile)
            shared d_LogInfo
            d_LogInfo.[Report File] = oldrepfile
            d_LogInfo.[Log File]    = oldlogfile
            vws = GetViewNames()
            for i = 1 to vws.length do
               CloseView(vws[i])
            end


      enditem

    macro "closing" do
        if RunMacro("TCP Close Model Dbox") = 1 then
            return()
      enditem

enddbox

// ------ BldNet -- Build Highway Network -------------------------
macro "BldNet" (Args)    // Build Highway Network
    //shared prj_dry_run  if prj_dry_run then return(1)
//    global nfile 
//    nfile   = Args.[Highway Layer]
//    db_file = Args.[Highway Layer]
    netfAM  = Args.[NET AM]
    netfMD  = Args.[NET MD]
    netfPM  = Args.[NET PM]
    netfNT  = Args.[NET NT]

    mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR

//    {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", db_file)
    {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file) // Changed to master network file EW HDR

   //  +++++++ ADD REQUIRED OUTPUT FIELDS TO THE NETWORK DATABASE ++++++++++++++++++
      flds={"AB_AM_CAP",        "BA_AM_CAP",
            "AB_MD_CAP",        "BA_MD_CAP",
            "AB_PM_CAP",        "BA_PM_CAP",
            "AB_NT_CAP",        "BA_NT_CAP",
            "BPRA"      ,       "BPRB",
            "AB_AM_LANES",      "BA_AM_LANES",
            "AB_MD_LANES",      "BA_MD_LANES",
            "AB_PM_LANES",      "BA_PM_LANES",
            "AB_NT_LANES",      "BA_NT_LANES"
            }
      RunMacro("addfields",{flds,link_lyr})

   // populate time-period-specific capacities, use reasonable values
    vabhcap = GetDataVector(link_lyr+"|", "AB_HourlyCap", )      // Changes are made by Johnny Han, 4/29/2015
    vbahcap = GetDataVector(link_lyr+"|", "BA_HourlyCap", )      // Changes are made by Johnny Han, 4/29/2015

    vDL   = GetDataVector(link_lyr+"|", "DIR_LANES", )
    vDL = if(nz(vDL)=0) then 1 else vDL        // for external station connectors

    vAMAL = GetDataVector(link_lyr+"|", "AB_AM_LANES", )
    vAMBL = GetDataVector(link_lyr+"|", "BA_AM_LANES", )

    vMDAL = GetDataVector(link_lyr+"|", "AB_MD_LANES", )
    vMDBL = GetDataVector(link_lyr+"|", "BA_MD_LANES", )

    vPMAL = GetDataVector(link_lyr+"|", "AB_PM_LANES", )
    vPMBL = GetDataVector(link_lyr+"|", "BA_PM_LANES", )

    vNTAL = GetDataVector(link_lyr+"|", "AB_NT_LANES", )
    vNTBL = GetDataVector(link_lyr+"|", "BA_NT_LANES", )

// check for period-specific lanes. If none, use DIR_LANES

    vAMAL = if(nz(vAMAL)=0) then vDL else vAMAL
    vAMBL = if(nz(vAMBL)=0) then vDL else vAMBL

    vMDAL = if(nz(vMDAL)=0) then vDL else vMDAL
    vMDBL = if(nz(vMDBL)=0) then vDL else vMDBL

    vPMAL = if(nz(vPMAL)=0) then vDL else vPMAL
    vPMBL = if(nz(vPMBL)=0) then vDL else vPMBL

    vNTAL = if(nz(vNTAL)=0) then vDL else vNTAL
    vNTBL = if(nz(vNTBL)=0) then vDL else vNTBL


// set directional capacities by direction and time period -- make these are in the assignment

//   Day-part capacity factors   <<--- These factors go to input\DayPart_Cap.bin as required by KYTC
//   AM = 2.5
//   MD = 5.0
//   PM = 2.9
//   NT = 4.3

// Get day-part capacity conversion factors
    dpf = Args.DayPart_Cap
    dpc_tab = OpenTable("DP_Cap", "FFB", {dpf,})
    SetView(dpc_tab)
    vr  = nz(GetDataVector(dpc_tab+"|", "Factor",  ))
    dp  = V2A(vr)
    //         1         2        3       4
    timep={"AM_Peak","Midday","PM_Peak","Night"}
    dim dpc[4]       // day-part capacity factors by period
    for p = 1 to timep.length do       // time period loop
        dpc[p] = dp[p]
    end

    // Change vhcap to vabhcap or vbahcap, by Johnny Han, 4/29/2015
    vamcapa = vAMAL*vabhcap*dpc[1]/vDL
    vamcapb = vAMBL*vbahcap*dpc[1]/vDL
    vmdcapa = vMDAL*vabhcap*dpc[2]/vDL
    vmdcapb = vMDBL*vbahcap*dpc[2]/vDL
    vpmcapa = vPMAL*vabhcap*dpc[3]/vDL
    vpmcapb = vPMBL*vbahcap*dpc[3]/vDL
    vntcapa = vNTAL*vabhcap*dpc[4]/vDL
    vntcapb = vNTBL*vbahcap*dpc[4]/vDL


    SetDataVector(link_lyr+"|", "AB_AM_CAP", vamcapa, )
    SetDataVector(link_lyr+"|", "BA_AM_CAP", vamcapb, )
    SetDataVector(link_lyr+"|", "AB_MD_CAP", vmdcapa, )
    SetDataVector(link_lyr+"|", "BA_MD_CAP", vmdcapb, )
    SetDataVector(link_lyr+"|", "AB_PM_CAP", vpmcapa, )
    SetDataVector(link_lyr+"|", "BA_PM_CAP", vpmcapb, )
    SetDataVector(link_lyr+"|", "AB_NT_CAP", vntcapa, )
    SetDataVector(link_lyr+"|", "BA_NT_CAP", vntcapb, )

   //////////////////////////////////////////////////////////////////
   // Build Highway Network
   //////////////////////////////////////////////////////////////////

   SetStatus(2,"Building Highway Network",)

   //////////////////////////////////////////////////////////////////
   // Adding fields to the highway network
   //////////////////////////////////////////////////////////////////

	llyr="["+link_lyr+"]"
	nlyr="["+node_lyr+"]"
	tp=Args.Turnpens

// STEP 1: Build Highway Network
     // In_Network codes: 0 or null=not used, 1=autos and trucks, 2=autos only, 3=trucks only
     qryH = "Select * where In_Network=1 | In_Network=2"
     Opts = null
//     Opts.Input.[Link Set] = {db_file+"|"+link_lyr, link_lyr,"hwy",qryH}
     Opts.Input.[Link Set] = {mn_file+"|"+link_lyr, link_lyr,"hwy",qryH} // changed to master network file EW HDR
     Opts.Global.[Network Options].[Node ID] = node_lyr+".ID"
     Opts.Global.[Network Options].[Link ID] = llyr+".ID"
     Opts.Global.[Network Options].[Turn Penalties] = "Yes"
     Opts.Global.[Network Options].[Keep Duplicate Links] = "FALSE"
     Opts.Global.[Network Options].[Ignore Link Direction] = "FALSE"
     Opts.Global.[Link Options] = {{"Length", llyr+".Length", llyr+".Length"},
	                           {"ID", llyr+".ID", llyr+".ID"},
				   {"Dir", llyr+".Dir", llyr+".Dir"},
				   {"[Facil Type]", llyr+".FClass", llyr+".FClass"},
				   {"[Area Type]", llyr+".AREATYPE", llyr+".AREATYPE"},
				   {"BPRA", llyr+".BPRA", llyr+".BPRA"},
				   {"BPRB", llyr+".BPRB", llyr+".BPRB"},
				   {"Time", llyr+".AutoTime", llyr+".AutoTime"},
           {"DailyCapacity", llyr+".AB_DailyCap", llyr+".BA_DailyCap"},          // Changes are made by Johnny Han, 4/29/2015
           {"HourlyCapacity", llyr+".AB_HourlyCap", llyr+".BA_HourlyCap"},       // Changes are made by Johnny Han, 4/29/2015
				   {"AMCapacity", llyr+".AB_AM_CAP", llyr+".BA_AM_CAP"},
				   {"MDCapacity", llyr+".AB_MD_CAP", llyr+".BA_MD_CAP"},
				   {"PMCapacity", llyr+".AB_PM_CAP", llyr+".BA_PM_CAP"},
				   {"NTCapacity", llyr+".AB_NT_CAP", llyr+".BA_NT_CAP"},
				   {"FF_AutoTime", llyr+".AutoTime", llyr+".AutoTime"},
				   {"FF_TruckTime", llyr+".TruckTime", llyr+".TruckTime"}}
     Opts.Output.[Network File] = netfAM

     ret_value = RunMacro("TCB Run Operation", 1, "Build Highway Network", Opts)

     if !ret_value then do
        ShowMessage("Build Highway Network failed")
        goto quit
     end

// STEP 1: Highway Network Setting
     SetStatus(2,"Highway Network Settings",)
     Opts = null
//     Opts.Input.Database = db_file
     Opts.Input.Database = mn_file  // Changed to master network file EW HDR
     Opts.Input.Network = netfAM
     Opts.Input.[Spc Turn Pen Table] = {tp}
//     Opts.Input.[Centroids Set] = {db_file+"|"+node_lyr, node_lyr, "Centroids", "Select * where IsCentroid<>null"}
     Opts.Input.[Centroids Set] = {mn_file+"|"+node_lyr, node_lyr, "Centroids", "Select * where IsCentroid<>null"} // Changed to master network file EW HDR
     Opts.Field.[Link type] = "[Facil Type]"
     Opts.Global.[Global Turn Penalties] = {0, 0, 0, -1}
     Opts.Flag.[Use Link Types] = "True"

     ret_value = RunMacro("TCB Run Operation", 1, "Highway Network Setting", Opts)

     if !ret_value then do
        ShowMessage("Highway Network Setting failed")
        goto quit
     end

// create MD, PM and night night networks, which are the same as AM at this point
     copyfile(netfAM,netfMD)
     copyfile(netfAM,netfPM)
     copyfile(netfAM,netfNT)

    quit:

    RunMacro("CloseAllViews")
    return(ret_value)
endMacro
// --------- End BldNet ----------------------------------------------


// =================== Add Future Road Projects ===========================
Macro "MasterNetwork" (Args)
    Scenario_Network = Args.[Network Set]
    proj_file   = Args.[Project Table]

  nfile = Args.[Highway Layer]
  // Copy master network over to scenario folder - EW HDR
  //Check if a Scenario master network file is in the scenario folder. If so, delete and copy over a new one
    if Getdbfiles(odir+"\\Scn_network.dbd")<> null then do
	    deletefile(odir+"\\Scn_network.dbd")
    end
    CopyDatabase(nfile, odir+"\\Scn_network.dbd")
    
        mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR

//    {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", db_file)
    {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file) // Changed to master network file EW HDR

  // Copy project table over to scenario folder - EW HDR
  //Check if a Scenario project table is in the scenario folder. If so, delete and copy over a new one
	    prj_file = odir+"\\projects.bin"
	    prj_dfile = odir+"\\projects.dcb"
	    if GetFileInfo(prj_file) <> null then DeleteFile(prj_file)	
	    if GetFileInfo(prj_dfile) <> null then DeleteFile(prj_dfile)
      tmp = SplitPath(proj_file)
      dcbfile=tmp[1]+tmp[2]+tmp[3]+".dcb"
      CopyFile(dcbfile, prj_dfile)
      CopyFile(proj_file, prj_file)
    
      prj_file = odir+"\\projects.bin"  // Changed to scenario project file EW HDR

   // Add future road project changes to the output network - EW HDR
  if Scenario_Network = "Existing" then goto base    //Skip if Base Year

    //Open the project database table
    prj_vw = OpenTable("projects", "FFB", {prj_file,})
	
	//join project table to links with projects
   	jvw = JoinViews("JV", link_lyr+".ProjNum1", prj_vw+".ProjNum",)
   	SetView(jvw)

    projarr = {"Illustrative","Planned","Committed"}
    projflds = {"IN_NETWORK","DIR","FCLASS","PostedSpeed","Speed_Override","HCMTYPE","TLCLASS","RAMP","DIR_LANES","AB_LANES","BA_LANES","MEDTYPE","MEDWID","CR_SHLDWID","CR_SHLDTYP","CL_SHLDWID","CL_SHLDTYP",
                "NR_SHLDWID","NR_SHLDTYP","AB_HourlyCap_Override","TruckNet","PCE_Override","AREATYPE"}

    for p = 1 to projarr.length do
      for f = 1 to projflds.length do
	//query if any project upgrades are coded
	  query = "Select * where "+projarr[p]+">0 and "+prj_vw+"."+projflds[f]+"<>null"   // include projects. Do not worry about year - EW HDR
//	query = "Select * where "+Scenario_Network+"<="+year_string
	  link_have_projects = "Project_links"
	  nlinks= SelectByQuery(link_have_projects, "Several", query,)

    //If project upgrades are coded then fill the Year1 field 
	  if (nlinks > 0) then do
      Opts = null
      Opts.Input.[Dataview Set] = {{mn_file + "|" + link_lyr,  prj_file, {"ProjNum1"}, {"ProjNum"}}, "Network+Project", "Selection", "Select * where "+projarr[p]+">0 and "+prj_vw+"."+projflds[f]+"<>null"}
//      Opts.Input.[Dataview Set] = {{mn_file + "|" + link_lyr,  prj_file, {"ProjNum1"}, {"ProjNum"}}, "Network+Project", "Selection", "Select * where "+Scenario_Network+" <="+year_string}
      Opts.Global.Fields = {link_lyr+"."+projflds[f]}
      Opts.Global.Method  = "Formula" 
      Opts.Global.Parameter  = {prj_vw+"."+projflds[f]}
      ret_value = RunMacro("TCB Run Operation", "Fill Dataview", Opts, &Ret)
    if !ret_value then goto quit
    end
      end // projflds loop
    end // projarr loop

	  CloseView(jvw)

  base: // skip to here if running Existing road network

    quit:

    RunMacro("CloseAllViews")
    return(ret_value)
endMacro


//====== Trip Generation ======//       (Perform Trip Generation)

macro "Household Model" (Args)    // Trip Generation
// Household Model
   SetStatus(2,"Household Model",)
   //--------
    tazpoly  = Args.[TAZ Layer]
       //////Open File TAZ file
   //db_file=Args.[Highway Layer]
     mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR

    {taz_in} = RunMacro("TCB Add DB Layers", tazpoly)

    taz_no = RunMacro("GetIZONES",tazpoly)
    maxz = taz_no

// Error Trapping Steps - EW HDR
// Check node ID vs. Model_Zone
//  {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", db_file)
  {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file)  // Changed to master network file EW HDR
  SetLayer(node_lyr)
  qry = "Select * where IsCentroid=1"    // centroids
  n = SelectByQuery("Centroids", "Several", qry,)

  excenzoneid = nz(GetDataVector(node_lyr+"|Centroids", "ID", {{"Sort Order",{{"ID","Ascending"}}}} ))
  excenzonenum = nz(GetDataVector(node_lyr+"|Centroids", "Model_Zone", {{"Sort Order",{{"ID","Ascending"}}}} ))

  for i = 1 to excenzoneid.length do
    if excenzoneid[i] <> excenzonenum[i] then do
          ShowMessage("** Node centroid Model_Zone numbers do not align with node ID numbers. Please ensure Model_Zone numbers match IDs. Also ensure the numbers match TAZ ID numbers.")
          return(null)
    end
  end

// Compare number of TAZs vs. number of Centroids (internal & external)
   SetLayer(taz_in)
   qry = "Select * where nz(ExSta)=0"
   n = SelectByQuery("Internal", "Several", qry,)
   
  inttazid  = nz(GetDataVector(taz_in+"|Internal", "ID", {{"Sort Order",{{"ID","Ascending"}}}} ))

//  {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", db_file)
  SetLayer(node_lyr)
  qry = "Select * where IsCentroid=1 and EXSTA<>1"    // internal centroids
  n = SelectByQuery("Centroids", "Several", qry,)

  intcenzone = nz(GetDataVector(node_lyr+"|Centroids", "ID", {{"Sort Order",{{"ID","Ascending"}}}} ))

  for i = 1 to intcenzone.length do
    if intcenzone[i] <> inttazid[i] then do
          ShowMessage("** Internal Centroid and TAZ ID numbers do not align. Compare internal Centroid IDs with internal TAZ IDs and re-run model after cleanding up.")
          return(null)
    end
  end

  qry = "Select * where IsCentroid=1 & EXSTA=1"    // external centroids
  n = SelectByQuery("External Centroids", "Several", qry,)

  excenzone = nz(GetDataVector(node_lyr+"|External Centroids", "ID", {{"Sort Order",{{"ID","Ascending"}}}} ))

   SetLayer(taz_in)
   qry = "Select * where nz(ExSta)>0"
   n = SelectByQuery("External", "Several", qry,)
   
  extazid  = nz(GetDataVector(taz_in+"|External", "ID", {{"Sort Order",{{"ID","Ascending"}}}} ))

  for i = 1 to extazid.length do
    if extazid[i] <> excenzone[i] then do
          ShowMessage("** External Centroid and TAZ ID numbers do not align. Compare external Centroid IDs with internal TAZ IDs and re-run model after cleanding up.")
          return(null)
    end
  end

// NEW HOUSEHOLD MODEL ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
// store disggregation fractions on the TAZ file - create fields
      hstratf ={{"pph1","Real",9,7},{"pph2","Real",9,7},{"pph3","Real",9,7},{"pph4","Real",9,7},
                {"wrk0","Real",9,7},{"wrk1","Real",9,7},{"wrk2","Real",9,7},{"wrk3","Real",9,7},
                {"aut0","Real",9,7},{"aut1","Real",9,7},{"aut2","Real",9,7},{"aut3","Real",9,7},
                {"mixempintden","Real",12,4},       // dchoice variable
                {"inc_Q","Integer",6,0}}            // income quartile

      RunMacro("TCB Add View Fields",{taz_in,hstratf})

/*
// Household size logit contants   <<--- These constants go to input\HHModel_Constants.bin file as required by KYTC
//  recalib for Daviess Henderson +
      Chhsz  = {-0.9082, 0.4153, 0.0949,
                -0.0224, 0.3838,-1.6516,
                 0.7609, 0.7250,-5.1667,
                 1.3667, 0.3416,-5.6636}

// Household workers logit contants
//  recalib for Daviess Henderson +
     Chhwrk = { -5.1175, -46.2809, 0.0000,
                -3.9589, -46.1147, -1.9149,
                -2.8831, -46.4298, -2.2513,
                -1.4746, -46.0720, -6.2661}

// Household autos logit contants
//  recalib for Daviess Henderson +
      Chhaut = {5.7025,	 0.0021,  0.0000,
                0.5451,	10.1230, 11.2221,
                0.8858,	14.5587,  1.3816,
                0.4898,	15.7542,  0.0000}
*/

// select internal TAZs, non-group quarters
   SetLayer(taz_in)
   qry = "Select * where nz(ExSta)=0"
   n = SelectByQuery("Internal", "Several", qry,)

// Establish income quartiles: 1 - 4, low - high
    vQ   = Vector(n, "Short", {{"Constant",1},{"Row Based","True"}})
    vI = GetDataVector(taz_in+"|Internal", "inc_Q",{{"Sort Order",{{"Income_Median","A"}}}})
    recs=vI.length
    q1=0
    q2=recs/4
    q3=recs/2
    q4=q2+q3
    for inc=1 to vI.length do
      quart=1
      if(inc>q2) then quart=2
      if(inc>q3) then quart=3
      if(inc>q4) then quart=4
      vQ[inc]=quart
    end
    SetDataVector(taz_in+"|Internal", "inc_Q", vQ, {{"Sort Order",{{"Income_Median","A"}}}} )

// get data vectors for HH, POP, AUTOS, Workers
   global vhh
   vhh  = nz(GetDataVector(taz_in+"|Internal", "House_Occ",  ))
   vpop = nz(GetDataVector(taz_in+"|Internal", "Est_POP",  ))
   vaut = nz(GetDataVector(taz_in+"|Internal", "Vehicles",  ))
   vwrk = nz(GetDataVector(taz_in+"|Internal", "WORKERS",  ))

   vwph   = if(vhh<>0) then vwrk/vhh else 0    // average workers per household
   vpph   = if(vhh<>0) then vpop/vhh else 0    // average persons per household
   vauthh = if(vhh<>0) then vaut/vhh else 0    // average autos per household
// Trap bad data ------------------
   vauthh = min(vauthh,6)
   vpph   = min(vpph,6)
   vwrk   = min(vwrk,6)
// --------------------------------

// HH Classification Vectors
   global vHC,vAXP,vAXW
   Dim vHC[3,4]   // vHC[var,level]
   Dim vAXP[4,4]  // vAXP[autos,persons]
   Dim vAXW[4,4]  // vAXW[autos,workers]


// Get Household Model Constants
// 1_Var is coefficient for person/HH in household size & auto models, and coefficient for worker/HH in worker modele
// 2_Var is coefficient for auto/HH in all models
// 3_Var is the constant term in all models
   term = {"1_Var","2_Var","3_Var"}
   HHConst = Args.[HH Model Constants]
   HHM_const = OpenTable("HH Model Const", "FFB", {HHConst,})
   SetView(HHM_const)
   Dim Coeff[3,4,3]   // coefficients by models, classes, terms
   for m = 1 to 3 do     // household model loop
     qry = "Select * where Model="+i2s(m)
     sset="Model_"+i2s(m)
     n = SelectByQuery(sset, "Several", qry,)
     for t = 1 to 3 do       // term loop
        vr = nz(GetDataVector(HHM_const+"|"+sset, term[t],  ))
        ra = v2a(vr)
        for class = 1 to 4 do       // class loop
           Coeff[m][class][t] = ra[class]
        end
     end
   end

//  Household size model
    vU1 = exp(Coeff[1][1][1]  * vpph + Coeff[1][1][2]  * vauthh + Coeff[1][1][3] )
    vU2 = exp(Coeff[1][2][1]  * vpph + Coeff[1][2][2]  * vauthh + Coeff[1][2][3] )
    vU3 = exp(Coeff[1][3][1]  * vpph + Coeff[1][3][2]  * vauthh + Coeff[1][3][3] )
    vU4 = exp(Coeff[1][4][1]  * vpph + Coeff[1][4][2]  * vauthh + Coeff[1][4][3] )
    vDenom = vU1 + vU2 + vU3 + vU4
    vHC[1][1] = vU1/vDenom
    vHC[1][2] = vU2/vDenom
    vHC[1][3] = vU3/vDenom
    vHC[1][4] = vU4/vDenom
    SetDataVector(taz_in+"|Internal", "pph1", vHC[1][1], )
    SetDataVector(taz_in+"|Internal", "pph2", vHC[1][2], )
    SetDataVector(taz_in+"|Internal", "pph3", vHC[1][3], )
    SetDataVector(taz_in+"|Internal", "pph4", vHC[1][4], )

//  Workers model
    vU1 = exp(Coeff[2][1][1]  * vwph + Coeff[2][1][2]  * vauthh + Coeff[2][1][3] )
    vU2 = exp(Coeff[2][2][1]  * vwph + Coeff[2][2][2]  * vauthh + Coeff[2][2][3] )
    vU3 = exp(Coeff[2][3][1]  * vwph + Coeff[2][3][2]  * vauthh + Coeff[2][3][3] )
    vU4 = exp(Coeff[2][4][1]  * vwph + Coeff[2][4][2]  * vauthh + Coeff[2][4][3] )
    vDenom = vU1 + vU2 + vU3 + vU4
    vHC[2][1] = vU1/vDenom
    vHC[2][2] = vU2/vDenom
    vHC[2][3] = vU3/vDenom
    vHC[2][4] = vU4/vDenom
    SetDataVector(taz_in+"|Internal", "wrk0", vHC[2][1], )
    SetDataVector(taz_in+"|Internal", "wrk1", vHC[2][2], )
    SetDataVector(taz_in+"|Internal", "wrk2", vHC[2][3], )
    SetDataVector(taz_in+"|Internal", "wrk3", vHC[2][4], )

//  Autos model
    vU1 = exp(Coeff[3][1][1]  * vpph + Coeff[3][1][2]  * vauthh + Coeff[3][1][3] )
    vU2 = exp(Coeff[3][2][1]  * vpph + Coeff[3][2][2]  * vauthh + Coeff[3][2][3] )
    vU3 = exp(Coeff[3][3][1]  * vpph + Coeff[3][3][2]  * vauthh + Coeff[3][3][3] )
    vU4 = exp(Coeff[3][4][1]  * vpph + Coeff[3][4][2]  * vauthh + Coeff[3][4][3] )
    vDenom = vU1 + vU2 + vU3 + vU4
    vHC[3][1] = vU1/vDenom
    vHC[3][2] = vU2/vDenom
    vHC[3][3] = vU3/vDenom
    vHC[3][4] = vU4/vDenom
    SetDataVector(taz_in+"|Internal", "aut0", vHC[3][1], )
    SetDataVector(taz_in+"|Internal", "aut1", vHC[3][2], )
    SetDataVector(taz_in+"|Internal", "aut2", vHC[3][3], )
    SetDataVector(taz_in+"|Internal", "aut3", vHC[3][4], )
    
// Populate household classification vectors
   for autos = 1 to 4 do
      for persons = 1 to 4 do
         vAXP[autos][persons] = vHC[3][autos] * vHC[1][persons]
      end
      for workers = 1 to 4 do
         vAXW[autos][workers] = vHC[3][autos] * vHC[2][workers]
      end
   end
    SetStatus(2, "@System1", )
    quit:
    RunMacro("CloseAllViews")
    return(1)

endmacro
// ----------------------------------------------------------------------------------------------------------

// TRIP GENERATION MODEL
macro "Trip Generation" (Args)
    // shared prj_dry_run  if prj_dry_run then return(1)

   SetStatus(2,"Trip Generation: Ps and As",)
    triprate = Args.[Production Rates]
    tazpoly  = Args.[TAZ Layer]
    {taz_in} = RunMacro("TCB Add DB Layers", tazpoly)
// select internal TAZs, non-group quarters
   SetLayer(taz_in)
   qry = "Select * where nz(ExSta)=0"
   n = SelectByQuery("Internal", "Several", qry,)

//    Make sure P & A fields are present
  flist ={"HBW","HBW_bal","HBO","HBO_bal","NHB","NHB_bal","HBsc","HBsc_bal","HBU","HBU_bal","LIGHT","MED","HEAVY",
          "ATTHBW","ATTHBW_bal","ATTHBO","ATTHBO_bal","ATTNHB","ATTNHB_bal","ATTHBsc","ATTHBsc_bal","ATTHBU","ATTHBU_bal","ATTLIGHT","ATTMED","ATTHEAVY"}

  for k=1 to flist.length do
     Field=Field+{ {flist[k], "Real",10,3} }
  end

  RunMacro("TCB Add View Fields",{taz_in,Field})

// Error Trap steps for critical TAZ fields - EW HDR
// Loop through internal zones
        vset = taz_in+"|Internal"

        arec = GetFirstRecord(vset,)
             while arec <> null do

        coset = taz_in.[COUNTY]
        conameset = taz_in.[COUNTY_NAME]
        atset = taz_in.[AreaType]
        pop = taz_in.[Est_POP]
        hh  = taz_in.[House_Occ]
        aut = taz_in.[Vehicles] 
        wrk = taz_in.[WORKERS] 
        RET  = taz_in.[EMP_RET] 
        SERV = taz_in.[EMP_SERV]
        TOTE = taz_in.[EMP_TOT]
        ColEnrol = taz_in.[College_Enrollment]
        K12Enrol = taz_in.[K12_Enrollment]
        K12H = taz_in.[K12_Home]
        CollegeH = taz_in.[College_Home]
        Inc = taz_in.[Income_Median] 

// County
    if coset = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing COUNTY value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// County Name
    if conameset = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing COUNTY_NAME value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// AreaType
    if atset = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing AreaType value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// Population
    if pop = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing EST_POP value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// Occupied Households
    if hh = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing HOUSE_OCC value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// Vehicles
    if aut = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing VEHICLES value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// Workers
    if wrk = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing WORKERS value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// Retail Employment
    if RET = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing EMP_RET value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// Service Employment
    if SERV = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing EMP_SERV value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// Total Employment
    if TOTE = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing EMP_TOT value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// College Enrollment
    if ColEnrol = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing College_Enrollment value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// K12 Enrollment
    if K12Enrol = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing K12_Enrollment value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// K12 Home Locations
    if K12H = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing K12_Home value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// College Home Locations
    if CollegeH = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing College_Home value for TAZ ID "+i2s(tid)+"")
          return(null)
    end
// Median Income
    if Inc = null then do
          tid  =taz_in.ID
          ShowMessage("** Missing Income_Median value for TAZ ID "+i2s(tid)+"")
          return(null)
    end

        arec = GetNextRecord(vset, null,)

            end

// PFAC = {1.00, 1.00, 1.00, 1.00, 1.00}  <<--- Trip production adjusting factors go to LaurelPulaski_mod.bin as required by KYTC
// Get trip production adjusting factors
    Dim PFAC[5]
    PFAC[1] = Args.[HBW P Factor]
    PFAC[2] = Args.[HBO P Factor]
    PFAC[3] = Args.[NHB P Factor]
    PFAC[4] = Args.[HBSch P Factor]
    PFAC[5] = Args.[HBU P Factor]

// Trip Productions
    pern = {"1_Var","2_Var","3_Var","4_Var"}        // var is workers for HBW and persons for all others
    Rate_mat = OpenTable("Prates", "FFB", {triprate,})
    SetView(Rate_mat)
    //  get production rates
    Dim Prat[6,4,4] // production rates by Purpose, Autos, Persons
    for pur = 1 to 5 do       //trip purpose loop
      qry = "Select * where Pur="+i2s(pur)
      sset="Pur_"+i2s(pur)
      n = SelectByQuery(sset, "Several", qry,)
      for per = 1 to 4 do
         vr  = nz(GetDataVector(Rate_mat+"|"+sset, pern[per],  ))
         ra  = V2A(vr)
         for autos = 1 to 4 do
           Prat[pur][autos][per] = ra[autos] * PFAC[pur]
         end
      end
    end
    // HBW Productions -- not using income quartile now
       for autos = 1 to 4 do
          for workers = 1 to 4 do
              vProds = vhh * vAXW[autos][workers] * Prat[1][autos][workers]
              vPT = if(autos=1 && workers=1) then vProds+0 else vPT + vProds    // accumulate
          end
       end
       SetDataVector(taz_in+"|Internal", "HBW", vPT, )
    // Remaining Productions
    iname={"HBW","HBO","NHB","HBsc","HBU"}

//  HBO & NHB
    for pur = 2 to 3 do
       for autos = 1 to 4 do
          for persons = 1 to 4 do
              vProds = vhh * vAXP[autos][persons] * Prat[pur][autos][persons]
              vPT = if(autos=1 && persons=1) then vProds+0 else vPT + vProds    // accumulate
          end
       end
       if(pur=3) then vPNHB=vPT
       SetDataVector(taz_in+"|Internal", iname[pur], vPT, )
    end
//  School and college
   SetLayer(taz_in)
    v_K12H     = GetDataVector(taz_in+"|Internal", "K12_Home",  )
    v_CollegeH = GetDataVector(taz_in+"|Internal", "College_Home",  )
    pur=4   // school
    vPT = v_K12H * Prat[pur][1][1]
    SetDataVector(taz_in+"|Internal", iname[pur], vPT, )

    pur=5   // college
    vPT = v_CollegeH * Prat[pur][1][1]
    SetDataVector(taz_in+"|Internal", iname[pur], vPT, )

// ----------------------------------------------------------------------------------------------------------
// for empty and group quarters TAZs
   qry = "Select * where nz(ID)<>null & (Est_POP/(House_Occ+0.1)>=20 | nz(House_Occ)=0)"    // "Select * where EXT=null"   -- for now, all zones
   n = SelectByQuery("EmptyGQ", "Several", qry,)
   vGQ   = Vector(n, "Float", {{"Constant",0.0},{"Row Based","True"}})
    iname={"HBW","HBO","NHB","HBsc","HBU"}
    for pur = 1 to 5 do
       SetDataVector(taz_in+"|EmptyGQ", iname[pur], vGQ, )
    end
// ----------------------------------------------------------------------------------------------------------

// Establish income quartiles: 1 - 4, low - high
    vQ   = Vector(n, "Short", {{"Constant",1},{"Row Based","True"}})
    ret_value = 1

/*
// count links at each node in the street layer (use later in Dest.Choice Model)   <<--- This is in case we want to do a destination choice model later
    SetStatus(2,"Mixed Use Indicator",)
    nfile=Args.[Highway Layer]
    RunMacro("countlinks",nfile)
    RunMacro("mix",nfile,tazpoly)
*/

// ATTRACTION MODEL =============================================================================
    //  get attraction rates
    SetStatus(2,"Trip Attractions",)
    arates=Args.[Attraction Rates]
    //       1      2        3          4        5         6           7
    avars={"HH", "Basic", "Retail", "Service", "Total","k_uenroll","k_students"}
    aRate_mat = OpenTable("Arates", "FFB", {arates,})
    SetView(aRate_mat)
    Dim AR[8,7] // attraction rates by Purpose(8), variable(7)
    for avar = 1 to avars.length do       //trip purpose loop
         vr  = nz(GetDataVector(aRate_mat+"|", avars[avar],  ))
         ra  = V2A(vr)
         for pur = 1 to 8 do
           AR[pur][avar] = ra[pur]
         end
    end

   v_RET      = nz(GetDataVector(taz_in+"|Internal", "EMP_RET",   ))
   v_SERV     = nz(GetDataVector(taz_in+"|Internal", "EMP_SERV",  ))
   v_TOTE     = nz(GetDataVector(taz_in+"|Internal", "EMP_TOT",   ))
   v_ColEnrol = nz(GetDataVector(taz_in+"|Internal", "College_Enrollment",  ))
   v_K12Enrol = nz(GetDataVector(taz_in+"|Internal", "K12_Enrollment",  ))

   v_NRET     = v_TOTE-v_RET-v_SERV // no-retail
   
   iname={"ATTHBW","ATTHBO","ATTNHB","ATTHBsc","ATTHBU","ATTLIGHT","ATTMED","ATTHEAVY"}
   dim v_atract[iname.length]
   for pur=1 to iname.length do
    if pur=1 then v_atract[pur] = (AR[pur][1]*vhh + AR[pur][2]*v_NRET + AR[pur][3]*v_RET + AR[pur][4]*v_SERV + AR[pur][5]*v_TOTE + AR[pur][6]*v_ColEnrol + AR[pur][7]*v_K12Enrol)*1.65    // HBW A's adjusted
    if pur=2 then v_atract[pur] = (AR[pur][1]*vhh + AR[pur][2]*v_NRET + AR[pur][3]*v_RET + AR[pur][4]*v_SERV + AR[pur][5]*v_TOTE + AR[pur][6]*v_ColEnrol + AR[pur][7]*v_K12Enrol)*1.34    // HBO A's adjusted
    if pur=3 then v_atract[pur] = (AR[pur][1]*vhh + AR[pur][2]*v_NRET + AR[pur][3]*v_RET + AR[pur][4]*v_SERV + AR[pur][5]*v_TOTE + AR[pur][6]*v_ColEnrol + AR[pur][7]*v_K12Enrol)*1.52    // NHB A's adjusted
    if (pur>3 and pur<7) then  v_atract[pur] = AR[pur][1]*vhh + AR[pur][2]*v_NRET + AR[pur][3]*v_RET + AR[pur][4]*v_SERV + AR[pur][5]*v_TOTE + AR[pur][6]*v_ColEnrol + AR[pur][7]*v_K12Enrol
    if pur=7 then v_atract[pur] = (AR[pur][1]*vhh + AR[pur][2]*v_NRET + AR[pur][3]*v_RET + AR[pur][4]*v_SERV + AR[pur][5]*v_TOTE + AR[pur][6]*v_ColEnrol + AR[pur][7]*v_K12Enrol)*1.70    // Medium truck's adjusted to meet ODME target
    if pur=8 then v_atract[pur] = (AR[pur][1]*vhh + AR[pur][2]*v_NRET + AR[pur][3]*v_RET + AR[pur][4]*v_SERV + AR[pur][5]*v_TOTE + AR[pur][6]*v_ColEnrol + AR[pur][7]*v_K12Enrol)*2.27    // Heavy truck's adjusted to meet ODME target
     SetDataVector(taz_in+"|Internal", iname[pur], v_atract[pur], )
   end

// ----  Balance school productions to school attractions, by county =============
    coset=taz_in+"|County"
    setlayer(taz_in)
//    for c= 1 to cname.length do   -MB edit due to "Total" added in line 1062 County Summaries"
//    for c= 1 to 5 do 
    for c= 1 to 12 do // EW HDR updated to new number of counties
      qry = 'Select * where County_Name="'+cname[c]+'"'
      n = SelectByQuery("County", "Several", qry,)
      v_scp  =GetDataVector(coset, "HBSc",  )
      v_sca  =GetDataVector(coset, "ATTHBSc",  )
      sump  =  VectorStatistic(v_scp, "Sum", )
      suma  =  VectorStatistic(v_sca, "Sum", )
      facsc = suma/sump
      v_scp = v_scp*facsc
      SetDataVector(coset, "HBSc", v_scp, )
    end
// APPLY Special Generators----------------------------------------------
   v_HBW     = nz(GetDataVector(taz_in+"|Internal", "ATTHBW",  ))
   v_HBO     = nz(GetDataVector(taz_in+"|Internal", "ATTHBO",  ))
   v_NHB     = nz(GetDataVector(taz_in+"|Internal", "ATTNHB",  ))
   v_sHBW     = GetDataVector(taz_in+"|Internal", "SG_HBW",  )
   v_sHBO     = GetDataVector(taz_in+"|Internal", "SG_HBO",  )
   v_sNHB     = GetDataVector(taz_in+"|Internal", "SG_NHB",  )
   
   v_HBW=if(v_sHBW<>null) then  v_sHBW else v_HBW
   v_HBO=if(v_sHBO<>null) then  v_sHBO else v_HBO
   v_NHB=if(v_sNHB<>null) then  v_sNHB else v_NHB

   SetDataVector(taz_in+"|Internal", "ATTHBW",  v_HBW,)
   SetDataVector(taz_in+"|Internal", "ATTHBO",  v_HBO,)
   SetDataVector(taz_in+"|Internal", "ATTNHB",  v_NHB,)

// ----------------------------------------------------------------------


// ---------------------------------------- EXTERNAL-INTERNAL MODEL ------------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //db_file  = Args.[Highway Layer]
    mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR
  netf     = Args.[NET AM]
  tazpoly  = Args.[TAZ Layer]
  xfile    = Args.[External Data]
  
//create fields in TAZ file for external trips
  flist ={"EE_Auto_P","EE_SU_P","EE_Comb_P","EI_Auto_P","EI_SU_P","EI_Comb_P","EI_Auto_A1","EI_Auto_A2","EI_Auto_A3","EI_Auto_A4",
          "EI_Auto_A","EI_SU_A1","EI_SU_A2","EI_SU_A3","EI_SU_A4","EI_SU_A","EI_Comb_A1","EI_Comb_A2","EI_Comb_A3","EI_Comb_A4",
          "EI_Comb_A","EI_Auto_A_bal","EI_SU_A_bal","EI_Comb_A_bal","ST1Dist","ST2Dist","ST3Dist","ST4Dist","Tot Int Ps","Tot Int As"}

  for k=1 to flist.length do
     Field=Field+{ {flist[k], "Real",10,3} }
  end

  RunMacro("TCB Add View Fields",{taz_in,Field})

  xd = OpenTable("ExData", "FFB", {xfile,})
  //SetLayer(taz_in)
  // qry = "Select * where ExSta>0"
  //n = SelectByQuery("xstations", "Several", qry,)
  vw2 = JoinViews("jv",taz_in+".ID", xd+".ID",)
  v_ADT  = nz(GetDataVector(vw2+"|", "ADT",  ))
  v_EE   = nz(GetDataVector(vw2+"|", "EE",   ))
  v_EI   = 1-v_EE
  v_EE_a = nz(GetDataVector(vw2+"|", "EE_Auto",))
  v_EE_s = nz(GetDataVector(vw2+"|", "EE_SU",  ))
  v_EE_c = nz(GetDataVector(vw2+"|", "EE_COMB",))
  v_EI_a = nz(GetDataVector(vw2+"|", "EI_Auto",))
  v_EI_s = nz(GetDataVector(vw2+"|", "EI_SU",  ))
  v_EI_c = nz(GetDataVector(vw2+"|", "EI_COMB",))
  v_EE_Auto_P = 0.5*v_ADT*v_EE*v_EE_a
  v_EE_SU_P =   0.5*v_ADT*v_EE*v_EE_s
  v_EE_Comb_P = 0.5*v_ADT*v_EE*v_EE_c
  v_EI_Auto_P = v_ADT*v_EI*v_EI_a
  v_EI_SU_P =   v_ADT*v_EI*v_EI_s
  v_EI_Comb_P = v_ADT*v_EI*v_EI_c

  SetDataVector(vw2+"|", "EE_Auto_P",  v_EE_Auto_P,)
  SetDataVector(vw2+"|", "EE_SU_P",    v_EE_SU_P,)
  SetDataVector(vw2+"|", "EE_Comb_P",  v_EE_Comb_P,)
  SetDataVector(vw2+"|", "EI_Auto_P",  v_EI_Auto_P,)
  SetDataVector(vw2+"|", "EI_SU_P",    v_EI_SU_P,)
  SetDataVector(vw2+"|", "EI_Comb_P",  v_EI_Comb_P,)

//  {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", db_file)
  {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file)  // Changed to master network file EW HDR
  SetLayer(node_lyr)
  qry = "Select * where nz(IsCentroid)>0"    // centroids for AirSage Analysis
  n = SelectByQuery("Centroids", "Several", qry,)

// Error Trap for missing Sta_Type information
  qry = "Select * where nz(ExSta)>0"    // External Stations
  ext = SelectByQuery("External", "Several", qry,)   

  statype  = nz(GetDataVector(node_lyr+"|External", "Sta_Type", {{"Sort Order",{{"ID","Ascending"}}}} ))
  extid  = nz(GetDataVector(node_lyr+"|External", "ID", {{"Sort Order",{{"ID","Ascending"}}}} ))

  for i = 1 to extid.length do
    if nz(statype[i])=0 or statype[i]>4 then do
          ShowMessage("** Sta_Type value for node ID "+i2s(extid[i])+" is missing or greater than 4. Correct node Sta_Type field and Re-run")
          return(null)
    end
  end

// Distance to External Station for use in EI % calculation
   for k= 1 to 4 do
     tf=GetTempFileName(".mtx")
     fld="ST"+i2s(k)+"Dist"
     qry = "Select * where nz(Sta_Type)="+i2s(k)    // external nodes
     /*    NCHRP 716 Station Types
             1   - Fwy/Exway
             2   - Arterial Near Xway
             3   - Arterial Not Near Xway
             4   - Collector/Local
     */
     n = SelectByQuery("Xnode", "Several", qry,)
     if(n>0) then do  // skip if there are no stations of this type
       Opts = null
       Opts.Input.Network = netf
//       Opts.Input.[Origin Set]      = {db_file+"|"+node_lyr, node_lyr,"Centroids"}
       Opts.Input.[Origin Set]      = {mn_file+"|"+node_lyr, node_lyr,"Centroids"}  // Changed to master network file EW HDR
//       Opts.Input.[Destination Set] = {db_file+"|"+node_lyr, node_lyr,"Xnode"}
       Opts.Input.[Destination Set] = {mn_file+"|"+node_lyr, node_lyr,"Xnode"}  // Changed to master network file EW HDR
       Opts.Field.Minimize = "Length"
       Opts.Field.Nodes = "Node.ID"
       Opts.Output.[Output Matrix].Label = "Dist"
       Opts.Output.[Output Matrix].[File Name] = tf
       ret_value = RunMacro("TCB Run Procedure", "TCSPMAT", Opts, &Ret)
       if !ret_value then goto quit
       m = OpenMatrix(tf, "True")
//       mc = CreateMatrixCurrency(m, "Dist - Length", , , )
       mc = CreateMatrixCurrency(m, "Length", , , )		//EW HDR - A core named "Length" exists but not one named "Dist - Length"
       mvec = GetMatrixVector(mc, {{"Marginal", "Row Minimum"}})
       SetDataVector(taz_in+"|", fld, mvec, {{"Sort Order",{{"ID","A"}}}} )
     end
     m=null
     mc=null
   end

// EI model from NCHRP 716
    //ak={ 0.071, 0.118, 0.435, 0.153}     // original values
    //bk={{ -0.599, -1.285, -1.517, -1.482}, { -0.599, -1.285, -1.517, -1.482}, { -0.599, -1.285, -1.517, -1.482}}  // ORIGINAL
    
    // exponents held constants, coefficients adjusted to hit targets by station type  <<--- These constants go to input\EI_Coefficient.bin as required by KYTC
    // ak={{ 0.2061, 0.5636, 1.5246, 0.3658}, { 0.1877, 0.5452, 1.5396, 0.3329}, { 1.4680, 1.7974, 1.7796, 0.4598}}
    // bk={{ -1.000, -1.285, -1.517, -1.482}, {  -1.000, -1.1565, -1.3653, -1.3338}, {  -1.000, -1.0280, -1.2136, -1.1856}}    // tweak to allow longer truck trips

   // Get EI Model Coefficients
   Stype = {"1_Var","2_Var","3_Var", "4_Var"}           // var is external station type
   EICoeff = Args.[EI Model Coefficients]
   EI_Coeff = OpenTable("EI Model Coeff", "FFB", {EICoeff,})
   SetView(EI_Coeff)
   Dim ak[3,4]   // coefficient A by purpose, station type
   Dim bk[3,4]   // coefficient B by purpose, station type
   for c = 1 to 2 do     // coefficient loop
     qry = "Select * where Coeff="+i2s(c)
     sset="Coeff_"+i2s(c)
     n = SelectByQuery(sset, "Several", qry,)
     if c = 1 then do       // coefficient A
        for k = 1 to 4 do   // station type loop
           vr = nz(GetDataVector(EI_Coeff+"|"+sset, Stype[k],  ))
           ra = v2a(vr)
           for m = 1 to 3 do    // purpose loop
              ak[m][k] = ra[m]
           end
        end
     end
     if c = 2 then do       // coefficient B
        for k = 1 to 4 do   // station type loop
           vr = nz(GetDataVector(EI_Coeff+"|"+sset, Stype[k],  ))
           ra = v2a(vr)
           for m = 1 to 3 do    // purpose loop
              bk[m][k] = ra[m]
           end
        end
     end
   end

   // time permitting, revisit this to calibrate from the KYSTM extract ---
   va_hbw =GetDataVector(taz_in+"|", "ATTHBW",  )
   va_hbo =GetDataVector(taz_in+"|", "ATTHBO",  )
   va_nhb =GetDataVector(taz_in+"|", "ATTNHB",  )
   //va_hbsc=GetDataVector(taz_in+"|", "ATTHBsc",  )      // assume no EI/IE school trips
   va_hbu =GetDataVector(taz_in+"|", "ATTHBU",  )
   va_tot = va_hbw + va_hbo + va_nhb + va_hbu
   va_su  =GetDataVector(taz_in+"|", "ATTMED",  )         // map medium trucks to SU
   va_com =GetDataVector(taz_in+"|", "ATTHEAVY",  )       // map heavy trucks to combinations
// ------ EI Autos, Single Unit trucks, Combination trucks ------------
   typ={"EI_Auto_A","EI_SU_A","EI_Comb_A"}
   atts={va_tot,va_su,va_com}
   dim va_rat[3] // ratio of internal A's after trucks removed to original A's
   // EI trips are in vehicles, but when trips are removed from Internal Attractions, they must be converted to persons
   occ={1.72,1.00,1.00} // assumed EI persons per vehicle
   for m=1 to 3 do
      dim v_EIA[5]
      for k= 1 to 4 do
         df  = "ST"+i2s(k)+"Dist"
         eif = typ[m]+i2s(k)
         v_d    =GetDataVector(taz_in+"|", df,  )
         v_EIA[k] = ak[m][k]*atts[m]* pow(v_d,bk[m][k])
         SetDataVector(taz_in+"|", eif, v_EIA[k],  )
       end
       if m=1 then v_EIA[5] = min((v_EIA[1] + v_EIA[2] + v_EIA[3] + v_EIA[4])*0.90,atts[m]) // cap EI attractions a the total number of attractions, EI_Auto A's adjusted
       if m=2 then v_EIA[5] = min((v_EIA[1] + v_EIA[2] + v_EIA[3] + v_EIA[4])*0.90,atts[m]) // cap EI attractions a the total number of attractions  EI_SU A's adjusted
       if m=3 then v_EIA[5] = min((v_EIA[1] + v_EIA[2] + v_EIA[3] + v_EIA[4])*1.10,atts[m]) // cap EI attractions a the total number of attractions, EI_Comb A's adjusted
       SetDataVector(taz_in+"|", typ[m], v_EIA[5],  )
       v_sub=v_EIA[5]*occ[m]
       va_rat[m]=if atts[m]>v_sub then (atts[m]-v_EIA[5]*occ[m])/atts[m] else 1  // subtract EI's from I-I attractions
   end

// remove EI attractions internal attractions -----------
   va_hbw = va_hbw * va_rat[1]
   va_hbo = va_hbo * va_rat[1]
   va_nhb = va_nhb * va_rat[1]
   va_hbu = va_hbu * va_rat[1]
   va_su  = va_su  * va_rat[2]
   va_com = va_com * va_rat[3]
   SetDataVector(taz_in+"|", "ATTHBW",   va_hbw,  )
   SetDataVector(taz_in+"|", "ATTHBO",   va_hbo,  )
   SetDataVector(taz_in+"|", "ATTNHB",   va_nhb,  )
   SetDataVector(taz_in+"|", "ATTHBU",   va_hbu,  )
   SetDataVector(taz_in+"|", "ATTMED",   va_su,  )
   SetDataVector(taz_in+"|", "ATTHEAVY", va_com,  )

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

// set truck productions to truck attractions
   SetDataVector(taz_in+"|Internal", "LIGHT", v_atract[6], )  // at the external stations, these will be indistinguishable from autos
   SetDataVector(taz_in+"|", "MED",   va_su, )  // at the external stations, these will be SU
   SetDataVector(taz_in+"|", "HEAVY", va_com, )  // at the external stations, these will be COMB


// BALANCE P's and A's -------------------------
     eqry = "Select * where (nz(ExSta)>0) | (nz(SG_HBW)+nz(SG_HBO)+nz(SG_NHB)>0)"
     zone_set = tazpoly+"|"+taz_in
     balf=Args.[Balanced ATTR Table]
     Opts = null
     Opts.Input.[Data View Set] = {tazpoly+"|"+taz_in, taz_in}
     // even though we hold this, there are not EI attractions at external stations anyway.
     Opts.Input.[V2 Holding Sets] = {,,,,,{zone_set, taz_in, "External", eqry},{zone_set, taz_in, "External", eqry},{zone_set, taz_in, "External", eqry}}
     Opts.Field.[Vector 1] = {"HBW", "HBO", "NHB", "HBsc", "HBU","EI_Auto_P","EI_SU_P","EI_Comb_P"}
     Opts.Field.[Vector 2] = {"ATTHBW", "ATTHBO", "ATTNHB", "ATTHBsc", "ATTHBU","EI_Auto_A","EI_SU_A","EI_Comb_A"}
     Opts.Global.[Holding Method] = {"Hold Vector 1", "Hold Vector 1", "Hold Vector 1", "Hold Vector 2", "Hold Vector 2", "Hold Vector 1", "Hold Vector 1", "Hold Vector 1"}
     Opts.Global.[Percent Weight] = {, , , , , , ,}
     Opts.Global.[Store Type] = "Real"
     Opts.Output.[Output Table] = balf

     ret_value = RunMacro("TCB Run Procedure", "Balance", Opts, &Ret)

     if !ret_value then goto quit
// ---------------------------------------------
    bal_tab = OpenTable("balance", "FFB", {balf,})
    vw2 = JoinViews("jv",taz_in+".ID", bal_tab+".ID1",)

    vp_hbw =GetDataVector(vw2+"|", bal_tab+".HBW",  )
    vp_hbo =GetDataVector(vw2+"|", bal_tab+".HBO",  )
    vp_nhb =GetDataVector(vw2+"|", bal_tab+".NHB",  )
    vp_hbsc=GetDataVector(vw2+"|", bal_tab+".HBsc",  )
    vp_hbu =GetDataVector(vw2+"|", bal_tab+".HBU",  )

    va_hbw =GetDataVector(vw2+"|", bal_tab+".ATTHBW",  )
    va_hbo =GetDataVector(vw2+"|", bal_tab+".ATTHBO",  )
    va_nhb =GetDataVector(vw2+"|", bal_tab+".ATTNHB",  )
    va_hbsc=GetDataVector(vw2+"|", bal_tab+".ATTHBsc",  )
    va_hbu =GetDataVector(vw2+"|", bal_tab+".ATTHBU",  )
// truck vectors for summary
    va_light  =GetDataVector(vw2+"|", taz_in+".ATTLIGHT",  )
    va_medium =GetDataVector(vw2+"|", taz_in+".ATTMED",  )
    va_heavy  =GetDataVector(vw2+"|", taz_in+".ATTHEAVY",  )
    vp_light  =GetDataVector(vw2+"|", taz_in+".LIGHT",  )
    vp_medium =GetDataVector(vw2+"|", taz_in+".MED",  )
    vp_heavy  =GetDataVector(vw2+"|", taz_in+".HEAVY",  )

    va_EI_Auto =GetDataVector(vw2+"|", bal_tab+".EI_Auto_A",  )
    va_EI_SU   =GetDataVector(vw2+"|", bal_tab+".EI_SU_A",  )
    va_EI_Comb =GetDataVector(vw2+"|", bal_tab+".EI_Comb_A",  )

    vp_EI_Auto =GetDataVector(vw2+"|", bal_tab+".EI_Auto_P",  )
    vp_EI_SU   =GetDataVector(vw2+"|", bal_tab+".EI_SU_P",  )
    vp_EI_Comb =GetDataVector(vw2+"|", bal_tab+".EI_Comb_P",  )

    SetDataVector(vw2+"|", taz_in+".HBW_bal",  vp_hbw, )
    SetDataVector(vw2+"|", taz_in+".HBO_bal",  vp_hbo, )
    SetDataVector(vw2+"|", taz_in+".NHB_bal",  va_nhb, ) // note here that NHB P's are replaced by balanced NHB attractions
    SetDataVector(vw2+"|", taz_in+".HBsc_bal", vp_hbsc,)
    SetDataVector(vw2+"|", taz_in+".HBU_bal",  nz(vp_hbu), )

    SetDataVector(vw2+"|", taz_in+".ATTHBW_bal",  va_hbw, )
    SetDataVector(vw2+"|", taz_in+".ATTHBO_bal",  va_hbo, )
    SetDataVector(vw2+"|", taz_in+".ATTNHB_bal",  va_nhb, )
    SetDataVector(vw2+"|", taz_in+".ATTHBsc_bal", va_hbsc,)
    SetDataVector(vw2+"|", taz_in+".ATTHBU_bal",  nz(va_hbu), )

    SetDataVector(vw2+"|", taz_in+".EI_Auto_A_bal", nz(va_EI_Auto),)
    SetDataVector(vw2+"|", taz_in+".EI_SU_A_bal",   nz(va_EI_SU),)
    SetDataVector(vw2+"|", taz_in+".EI_Comb_A_bal", nz(va_EI_Comb),)

    SetDataVector(vw2+"|", taz_in+".EI_Auto_P", nz(vp_EI_Auto),)
    SetDataVector(vw2+"|", taz_in+".EI_SU_P",   nz(vp_EI_SU),)
    SetDataVector(vw2+"|", taz_in+".EI_Comb_P", nz(vp_EI_Comb),)
// total internal p's and a's    
    vp_itot = nz(vp_hbw) +nz(vp_hbo) +nz(va_nhb) +nz(vp_hbsc) +nz(vp_hbu)+ nz(vp_light) +nz(vp_medium)+ nz(vp_heavy)
    va_itot = nz(va_hbw) +nz(va_hbo) +nz(va_nhb) +nz(va_hbsc) +nz(va_hbu)+ nz(va_light) +nz(va_medium)+ nz(va_heavy)
    SetDataVector(vw2+"|", taz_in+".Tot Int Ps", nz(vp_itot),)
    SetDataVector(vw2+"|", taz_in+".Tot Int As", nz(va_itot),)
    
// summaries by County +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   cc=cname.length+1
   dim pop_c[cc],hh_c[cc],wk_c[cc],aut_c[cc],K12_c[cc],coll_c[cc],K12H_c[cc],CollegeH_c[cc],TEmp_c[cc]
   dim hbwp_c[cc],hbwa_c[cc],hbop_c[cc],hboa_c[cc],nhbp_c[cc],nhba_c[cc],hbscp_c[cc],hbsca_c[cc],hbup_c[cc],hbua_c[cc]
    SetLayer(taz_in)
    coset=taz_in+"|County"
    for c= 1 to cname.length do
      qry = "Select * where County_Name='"+cname[c]+"'"
      n = SelectByQuery("County", "Several", qry,)
      v_pop  =GetDataVector(coset, "Est_POP",  )
      v_hh   =GetDataVector(coset, "House_Occ",  )
      v_wk   =GetDataVector(coset, "Workers",  )
      v_aut  =GetDataVector(coset, "Vehicles",  )
      v_K12  =GetDataVector(coset, "K12_Enrollment",  )
      v_coll =GetDataVector(coset, "College_Enrollment",  )
      v_K12H =GetDataVector(coset, "K12_Home",  )
      v_CollegeH=GetDataVector(coset, "College_Home",  )
      v_temp=GetDataVector(coset, "EMP_TOT",  )

      v_hbwp =GetDataVector(coset, "HBW",  )
      v_hbop =GetDataVector(coset, "HBO",  )
      v_nhbp =GetDataVector(coset, "NHB",  )
      v_hbscp=GetDataVector(coset, "HBsc",  )
      v_hbup =GetDataVector(coset, "HBU",  )

      v_hbwa =GetDataVector(coset, "ATTHBW",  )
      v_hboa =GetDataVector(coset, "ATTHBO",  )
      v_nhba =GetDataVector(coset, "ATTNHB",  )
      v_hbsca=GetDataVector(coset, "ATTHBsc",  )
      v_hbua =GetDataVector(coset, "ATTHBU",  )

      pop_c[c]  =  VectorStatistic(v_pop, "Sum", )
      pop_c[cc] =  nz(pop_c[cc])+pop_c[c]
      hh_c[c]   =  VectorStatistic(v_hh, "Sum", )
      hh_c[cc]  =  nz(hh_c[cc])+hh_c[c]
      wk_c[c]   =  VectorStatistic(v_wk, "Sum", )
      wk_c[cc]  =  nz(wk_c[cc])+wk_c[c]
      aut_c[c]  =  VectorStatistic(v_aut, "Sum", )
      aut_c[cc] =  nz(aut_c[cc])+aut_c[c]
      K12_c[c]  =  VectorStatistic(v_K12, "Sum", )
      K12_c[cc] =  nz(K12_c[cc])+K12_c[c]
      coll_c[c] =  VectorStatistic(v_coll, "Sum", )
      coll_c[cc]=  nz(coll_c[cc])+coll_c[c]
      K12H_c[c] =  VectorStatistic(v_K12H, "Sum", )
      K12H_c[cc]=  nz(K12H_c[cc])+K12H_c[c]
      CollegeH_c[c] =  VectorStatistic(v_CollegeH, "Sum", )
      CollegeH_c[cc]=  nz(CollegeH_c[cc])+CollegeH_c[c]
      TEmp_c[c] =  VectorStatistic(v_temp, "Sum", )
      TEmp_c[cc]=  nz(TEmp_c[cc])+TEmp_c[c]

      hbwp_c[c] =  VectorStatistic(v_hbwp, "Sum", )
      hbwp_c[cc]=  nz(hbwp_c[cc])+hbwp_c[c]
      hbwa_c[c] =  VectorStatistic(v_hbwa, "Sum", )
      hbwa_c[cc]=  nz(hbwa_c[cc])+hbwa_c[c]

      hbop_c[c] =  VectorStatistic(v_hbop, "Sum", )
      hbop_c[cc]=  nz(hbop_c[cc])+hbop_c[c]
      hboa_c[c] =  VectorStatistic(v_hboa, "Sum", )
      hboa_c[cc]=  nz(hboa_c[cc])+hboa_c[c]

      nhbp_c[c] =  VectorStatistic(v_nhbp, "Sum", )
      nhbp_c[cc]=  nz(nhbp_c[cc])+nhbp_c[c]
      nhba_c[c] =  VectorStatistic(v_nhba, "Sum", )
      nhba_c[cc]=  nz(nhba_c[cc])+nhba_c[c]

      hbscp_c[c] =  VectorStatistic(v_hbscp, "Sum", )
      hbscp_c[cc]=  nz(hbscp_c[cc])+hbscp_c[c]
      hbsca_c[c] =  VectorStatistic(v_hbsca, "Sum", )
      hbsca_c[cc]=  nz(hbsca_c[cc])+hbsca_c[c]

      hbup_c[c] =  VectorStatistic(v_hbup, "Sum", )
      hbup_c[cc]=  nz(hbup_c[cc])+hbup_c[c]
      hbua_c[c] =  VectorStatistic(v_hbua, "Sum", )
      hbua_c[cc]=  nz(hbua_c[cc])+hbua_c[c]
    end
    cname=cname+{"Total"}
    
    ww=7 // column width

AppendToReportFile(0, "Owensboro MODEL TRIP ZONAL DATA SUMMARY: "+GetDateAndTime(), {{"Section", "True"}})

AppendTableToReportFile({{{"Name", "County"},         {"Percentage Width",  ww}, {"Alignment", "Left"}},
                         {{"Name", "Est_POP"},     {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "Households"},     {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "Per/HH"},         {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "Workers"},        {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "Work/HH"},        {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "Vehicles"},       {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "Veh/HH"},         {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "K12 Enroll"},     {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "College Enroll"}, {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "K12_Home"},       {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "College Home"},   {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "Total Employ"},   {"Percentage Width",  ww}, {"Alignment", "Right"}}},
   {{"Title", "Zonal Data"}})
for c = 1 to cc do
  AppendRowToReportFile({cname[c],format(pop_c[c],",*0"),format(hh_c[c],",*0"),format(pop_c[c]/hh_c[c],",*0.000"),format(wk_c[c],",*0"),format(wk_c[c]/hh_c[c],",*0.000"),
           format(aut_c[c],",*0"),format(aut_c[c]/hh_c[c],",*0.000"),format(K12_c[c],",*0"),format(coll_c[c],",*0"),format(K12H_c[c],",*0"),format(CollegeH_c[c],",*0"),format(TEmp_c[c],",*0")}, )
end

    ww=9 // column width

AppendTableToReportFile({{{"Name", "County"},         {"Percentage Width",  ww}, {"Alignment", "Left"}},
                         {{"Name", "HBW P"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBW A"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBO P"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBO A"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "NHB P"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "NHB A"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBsc P"},         {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBsc A"},         {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBU P"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBU A"},          {"Percentage Width",  ww}, {"Alignment", "Right"}}},
   {{"Title", "Productions and Attractions - unbalanced"}})
for c = 1 to cc do
  AppendRowToReportFile({cname[c],format(hbwp_c[c],",*0"),format(hbwa_c[c],",*0"),format(hbop_c[c],",*0"),format(hboa_c[c],",*0"),format(nhbp_c[c],",*0"),format(nhba_c[c],",*0"),
                                  format(hbscp_c[c],",*0"),format(hbsca_c[c],",*0"),format(hbup_c[c],",*0"),format(hbua_c[c],",*0")}, )
end

//   cname={"DAVIESS","HANCOCK","HENDERSON","MCLEAN","OHIO"} // Daviess Model - EW HDR commented out
   cname={"CASEY","CLAY","JACKSON","KNOX","LAUREL","LINCOLN","MCCREARY","PULASKI","ROCKCASTLE","RUSSELL","WAYNE","WHITLEY"}	// EW HDR LP model counties
   cc=cname.length+1
   dim pop_c[cc],hh_c[cc],wk_c[cc],aut_c[cc],K12_c[cc],coll_c[cc]
   dim hbwp_c[cc],hbwa_c[cc],hbop_c[cc],hboa_c[cc],nhbp_c[cc],nhba_c[cc],hbscp_c[cc],hbsca_c[cc],hbup_c[cc],hbua_c[cc]
    SetLayer(taz_in)
    coset=taz_in+"|County"
    for c= 1 to cname.length do
      qry = "Select * where County_Name='"+cname[c]+"'"
      n = SelectByQuery("County", "Several", qry,)
      v_pop  =GetDataVector(coset, "Est_POP",  )
      v_hh   =GetDataVector(coset, "House_Occ",  )
      v_wk   =GetDataVector(coset, "Workers",  )
      v_aut  =GetDataVector(coset, "Vehicles",  )
      v_K12  =GetDataVector(coset, "K12_Enrollment",  )
      v_coll =GetDataVector(coset, "College_Enrollment",  )

      v_hbwp =GetDataVector(coset, "HBW_bal",  )
      v_hbop =GetDataVector(coset, "HBO_bal",  )
      v_nhbp =GetDataVector(coset, "NHB_bal",  )
      v_hbscp=GetDataVector(coset, "HBsc_bal",  )
      v_hbup =GetDataVector(coset, "HBU_bal",  )

      v_hbwa =GetDataVector(coset, "ATTHBW_bal",  )
      v_hboa =GetDataVector(coset, "ATTHBO_bal",  )
      v_nhba =GetDataVector(coset, "ATTNHB_bal",  )
      v_hbsca=GetDataVector(coset, "ATTHBsc_bal",  )
      v_hbua =GetDataVector(coset, "ATTHBU_bal",  )

      pop_c[c]  =  VectorStatistic(v_pop, "Sum", )
      pop_c[cc] =  nz(pop_c[cc])+pop_c[c]
      hh_c[c]   =  VectorStatistic(v_hh, "Sum", )
      hh_c[cc]  =  nz(hh_c[cc])+hh_c[c]
      wk_c[c]   =  VectorStatistic(v_wk, "Sum", )
      wk_c[cc]  =  nz(wk_c[cc])+wk_c[c]
      aut_c[c]  =  VectorStatistic(v_aut, "Sum", )
      aut_c[cc] =  nz(aut_c[cc])+aut_c[c]
      K12_c[c]  =  VectorStatistic(v_K12, "Sum", )
      K12_c[cc] =  nz(K12_c[cc])+K12_c[c]
      coll_c[c] =  VectorStatistic(v_coll, "Sum", )
      coll_c[cc]=  nz(coll_c[cc])+coll_c[c]

      hbwp_c[c] =  VectorStatistic(v_hbwp, "Sum", )
      hbwp_c[cc]=  nz(hbwp_c[cc])+hbwp_c[c]
      hbwa_c[c] =  VectorStatistic(v_hbwa, "Sum", )
      hbwa_c[cc]=  nz(hbwa_c[cc])+hbwa_c[c]

      hbop_c[c] =  VectorStatistic(v_hbop, "Sum", )
      hbop_c[cc]=  nz(hbop_c[cc])+hbop_c[c]
      hboa_c[c] =  VectorStatistic(v_hboa, "Sum", )
      hboa_c[cc]=  nz(hboa_c[cc])+hboa_c[c]

      nhbp_c[c] =  VectorStatistic(v_nhbp, "Sum", )
      nhbp_c[cc]=  nz(nhbp_c[cc])+nhbp_c[c]
      nhba_c[c] =  VectorStatistic(v_nhba, "Sum", )
      nhba_c[cc]=  nz(nhba_c[cc])+nhba_c[c]

      hbscp_c[c] =  VectorStatistic(v_hbscp, "Sum", )
      hbscp_c[cc]=  nz(hbscp_c[cc])+hbscp_c[c]
      hbsca_c[c] =  VectorStatistic(v_hbsca, "Sum", )
      hbsca_c[cc]=  nz(hbsca_c[cc])+hbsca_c[c]

      hbup_c[c] =  VectorStatistic(v_hbup, "Sum", )
      hbup_c[cc]=  nz(hbup_c[cc])+hbup_c[c]
      hbua_c[c] =  VectorStatistic(v_hbua, "Sum", )
      hbua_c[cc]=  nz(hbua_c[cc])+hbua_c[c]
    end
      cname=cname+{"Total"}
    ww=5 // column width

AppendTableToReportFile({{{"Name", "County"},         {"Percentage Width",  ww}, {"Alignment", "Left"}},
                         {{"Name", "HBW P"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBW A"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBO P"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBO A"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "NHB P"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "NHB A"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBsc P"},         {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBsc A"},         {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBU P"},          {"Percentage Width",  ww}, {"Alignment", "Right"}},
                         {{"Name", "HBU A"},          {"Percentage Width",  ww}, {"Alignment", "Right"}}},
   {{"Title", "Productions and Attractions - balanced"}})
for c = 1 to cc do
  AppendRowToReportFile({cname[c],format(hbwp_c[c],",*0"),format(hbwa_c[c],",*0"),format(hbop_c[c],",*0"),format(hboa_c[c],",*0"),format(nhbp_c[c],",*0"),format(nhba_c[c],",*0"),
                                  format(hbscp_c[c],",*0"),format(hbsca_c[c],",*0"),format(hbup_c[c],",*0"),format(hbua_c[c],",*0")}, )
end
//   cname={"DAVIESS","HANCOCK","HENDERSON","MCLEAN","OHIO"} // Daviess Model - EW HDR commented out
   cname={"CASEY","CLAY","JACKSON","KNOX","LAUREL","LINCOLN","MCCREARY","PULASKI","ROCKCASTLE","RUSSELL","WAYNE","WHITLEY"}	// EW HDR LP model counties
   
    SetStatus(2, "@System1", )
    quit:
    RunMacro("CloseAllViews")
    return(ret_value)

endmacro

//--------

// Compute Shortest Paths - FEEDBACK WILL BEGIN HERE
macro "Network Skimming" (Args)    // Network Skims

  //db_file = Args.[Highway Layer]
    mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR
  netfAM  = Args.[NET AM]
  netfMD  = Args.[NET MD]
  netfPM  = Args.[NET PM]
  netfNT  = Args.[NET NT]
  netf={netfAM,netfMD,netfPM,netfNT}

//  {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", db_file)
  {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file)  // Changed to master network file EW HDR

  SetLayer(node_lyr)
  qry = "Select * where nz(IsCentroid)>0"    // centroids for AirSage Analysis
  n = SelectByQuery("Centroids", "Several", qry,)

// this this for each time period, and add the feedback iteration variable
pnams={"AM","MD","PM","NT"}

for period = 1 to 4 do

     SetStatus(2,pnams[period]+"_Skim",)

     skimf=odir+"skim_"+pnams[period]+i2s(feedback_iteration)+".mtx"
//     if feedback_iteration=1 then
          SkimField="Time"

// Time and Distance Skims
     Opts = null
     Opts.Input.Network = netf[period]
//     Opts.Input.[Origin Set]      = {db_file+"|"+node_lyr, node_lyr,"Centroids"}
     Opts.Input.[Origin Set]      = {mn_file+"|"+node_lyr, node_lyr,"Centroids"}  // Changed to master network file EW HDR
//     Opts.Input.[Destination Set] = {db_file+"|"+node_lyr, node_lyr,"Centroids"}
     Opts.Input.[Destination Set] = {mn_file+"|"+node_lyr, node_lyr,"Centroids"}  // Changed to master network file EW HDR
     Opts.Field.Minimize = SkimField
     Opts.Field.[Skim Fields].LENGTH = "All"
     Opts.Field.Nodes = "Node.ID"
     Opts.Output.[Output Matrix].Compression = 1
     Opts.Output.[Output Matrix].Label = "Shortest Path"
     Opts.Output.[Output Matrix].[File Name] = skimf
     ret_value = RunMacro("TCB Run Procedure", "TCSPMAT", Opts, &Ret)
     if !ret_value then goto quit

// Error Trap - EW HDR
// Find Centroids that are not connected to the rest of the network
      skimerrorfile=odir+"skimerrorfile_"+pnams[period]+i2s(feedback_iteration)+".bin"
      skimerrordcb=odir+"skimerrorfile_"+pnams[period]+i2s(feedback_iteration)+".dcb"
      m = OpenMatrix(skimf, "True")
      CreateTableFromMatrix(m, skimerrorfile, "FFB", {{"Complete", "Yes"}})
      
      errtbl_vw = OpenTable("skimerrorfile_"+pnams[period]+i2s(feedback_iteration)+"", "FFB", {skimerrorfile,})
      SetView(errtbl_vw)
      
      qry = "Select * where Time = null and Origin <> Destination"   
      n = SelectByQuery("Selection", "Several", qry,)

      if n > 0 then do     
        rh = LocateRecord(errtbl_vw+"|Selection", "Time", {NULL}, )
        vals = GetRecordsValues(errtbl_vw+"|Selection", rh, {"Origin"}, {{"Origin", "Ascending"}}, 25, "Row", null)
          for v = 1 to vals.length do
            vals[v] = vals[v][1]
            if vals[v] > 1 then do
              ShowMessage("Centroid ID="+i2s(vals[v])+" may not be connected to the "+pnams[period]+i2s(feedback_iteration)+" network. Please review network near Centroid ID="+i2s(vals[v]))
            end
            if vals[v] = 1 then do
              ShowMessage("Check skimerrorfile_"+pnams[period]+i2s(feedback_iteration)+" in outputs for errors")
            end
          end
        goto quit
      end

      closeview(errtbl_vw)
      deletefile(skimerrorfile)
      deletefile(skimerrordcb)

// compute composite impedance as distance+time
     m = OpenMatrix(skimf, )
     AddMatrixCore(m, "Composite")
     //mt = CreateMatrixCurrency(m, "Time", , , )
     mt = CreateMatrixCurrency(m, SkimField, , , )
     ml = CreateMatrixCurrency(m, "Length (Skim)", , , )
     mc = CreateMatrixCurrency(m, "Composite", , , )
     mc:=mt+ml      // time+distance  <<<<<<-------------------------------------------        This is the original method -- time+distance
    
    ret_value=RunMacro("IZ",skimf,SkimField)
     if !ret_value then goto quit
    ret_value=RunMacro("Add_TermT",Args,skimf,SkimField)
     if !ret_value then goto quit

end

    quit:
    RunMacro("CloseAllViews")
    SetStatus(2, "@System1", )

    return(ret_value)
endmacro

// Evaluate the gravity model
macro "Gravity Model" (Args)    // Gravity Model -----

dim pamf[4]
pamf[1]=Args.PA_Matrix_AM
pamf[2]=Args.PA_Matrix_MD
pamf[3]=Args.PA_Matrix_PM
pamf[4]=Args.PA_Matrix_NT
pnams={"AM","MD","PM","NT"}

tazf     = Args.[TAZ Layer]
{taz_in} = RunMacro("TCB Add DB Layers", tazf)
fff      = Args.[Friction Factors]
ffv      = OpenTable("ffac", "FFB", {fff,})
bins     = ffv+".[Bins]"
giter=Args.[Gravity Iterations]
kfile=Args.K_factors
mh = OpenMatrix(kfile, )
mk1 = CreateMatrixCurrency(mh, "Prohib", , , )
//mk2 = CreateMatrixCurrency(mh, "Penalty", , , )     // << ---- now we are not penalizing inter-county NHB. If we do, we must create a new Kfactor core of Penalties

// Get Gamma & Exponential parameters
     Gamma = Args.[Gamma Parameter]
     purn = {"HBW","HBO","NHB","HBSc","HBU","LIGHT","MED","HEAVY","EI_Auto","EI_SU","EI_Comb"}
     Gamma_par = OpenTable("Gamma Parameter", "FFB", {Gamma,})
     SetView(Gamma_par)
     Dim Ga[3,11]  // gamma parameters by (A,B,C), purpose
     for p = 1 to 11 do
        vr  = nz(GetDataVector(Gamma_par+"|", purn[p],  ))
        ra  = v2a(vr)
        for c = 1 to 3 do
           Ga[c][p] = ra[c]
        end
     end

// apply for each time period

for period = 1 to 4 do
     SetStatus(2,pnams[period]+"_GM",)

// GM for HBW, HBO, NHB, HBSc, HBU, LIGHT, MED, HEAVY, EI_Auto, EI_SU, EI_Comb
     skimf=odir+"skim_"+pnams[period]+i2s(feedback_iteration)+".mtx"
     impC={skimf, "Composite", "Origin", "Destination"}
     Opts = null
     Opts.Input.[PA View Set] = {tazf+"|"+taz_in, taz_in}
     Opts.Input.[FF Matrix Currencies] = {, , , , , , , , , ,}
     Opts.Input.[Imp Matrix Currencies] = {impC, impC, impC, impC, impC, impC, impC, impC, impC, impC, impC}
     Opts.Input.[FF Tables] = {{fff}, {fff}, {fff}, {fff}, {fff}, {fff}, {fff}, {fff}, {fff}, {fff}, {fff}}
     Opts.Input.[KF Matrix Currencies] = {,,,mk1,,,,, , ,}
     Opts.Field.[Prod Fields] = {taz_in+".HBW_bal", taz_in+".HBO_bal", taz_in+".NHB_bal",
                                 taz_in+".HBsc_bal", taz_in+".HBU_bal",
                                 taz_in+".LIGHT", taz_in+".MED", taz_in+".HEAVY",
                                 taz_in+".EI_Auto_P", taz_in+".EI_SU_P", taz_in+".EI_Comb_P"}
     Opts.Field.[Attr Fields] = {taz_in+".ATTHBW_bal", taz_in+".ATTHBO_bal", taz_in+".ATTNHB_bal",
                                 taz_in+".ATTHBsc_bal", taz_in+".ATTHBU_bal", 
                                 taz_in+".ATTLIGHT", taz_in+".ATTMED", taz_in+".ATTHEAVY",
                                 taz_in+".EI_Auto_A_bal", taz_in+".EI_SU_A_bal", taz_in+".EI_Comb_A_bal"}
     Opts.Field.[FF Table Fields] = {ffv+".[HBW]", ffv+".[HBO]", ffv+".[NHB]",,,,,, ffv+".[HBO]",,}
     Opts.Field.[FF Table Times] = {bins, bins, bins, bins, bins, bins, bins, bins, bins, bins, bins}
     Opts.Global.[Purpose Names] = {"HBW", "HBO", "NHB", "HBsc", "HBU","Light trk","Med trk","Heavy trk","EI_Auto","EI_SU","EI_Comb"}
     Opts.Global.Iterations = {giter, 1, 1,    1,    1,giter,giter,giter,    1,    1,    1}
     Opts.Global.Convergence = {0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001, 0.001}
     Opts.Global.[Constraint Type] = {"Doubly", "Rows", "Rows", "Columns", "Columns", "Rows", "Rows", "Rows", "Rows", "Rows", "Rows"}
     //                                 HBW,     HBO,     NHB,      HBSc,    HBU,     LIGHT,          MED,           HEAVY,      EI_Auto,     EI_SU,        EI_Comb
     Opts.Flag.[Use K Factors] = {      0,        0,       0,         1,      0,        0,             0,               0,         0,           0,              0}
     Opts.Global.[Fric Factor Type] = {"Table", "Table", "Table", "Gamma", "Gamma", "Exponential", "Exponential", "Exponential", "Gamma", "Exponential", "Exponential"}
//   The following A,B,C coefficients go to input\Gamma.bin as required by KYTC
//   Opts.Global.[A List] = {              930,  585445,   22553,   42160,   42160,             1,             1,             1,    8702,             1,             1}
//   Opts.Global.[B List] = {           -1.333,   2.665,   1.560,   .5200,   .5200,              ,              ,              ,  -0.019,              ,              }
//   Opts.Global.[C List] = {            0.130,   0.010,   0.028,     .11,     .11,         0.125,         0.130,         0.050,     .11,         0.168,         0.067}        // Decrease parameters for MED & HEAVY to increase trip length (old MED=0.168, HEAVY=0.067)
     Opts.Global.[A List] = {         Ga[1][1], Ga[1][2], Ga[1][3], Ga[1][4], Ga[1][5],   Ga[1][6],      Ga[1][7],     Ga[1][8], Ga[1][9],    Ga[1][10],     Ga[1][11]}
     Opts.Global.[B List] = {         Ga[2][1], Ga[2][2], Ga[2][3], Ga[2][4], Ga[2][5],           ,              ,             , Ga[2][9],             ,              }
     Opts.Global.[C List] = {         Ga[3][1], Ga[3][2], Ga[3][3], Ga[3][4], Ga[3][5],   Ga[3][6],      Ga[3][7],     Ga[3][8], Ga[3][9],    Ga[3][10],     Ga[3][11]}        // Decrease parameters for MED & HEAVY to increase trip length (old MED=0.168, HEAVY=0.067)
     Opts.Output.[Output Matrix].Label = "Gravity Matrix"
     Opts.Output.[Output Matrix].Type = "Float"
     Opts.Output.[Output Matrix].[File based] = "FALSE"
     Opts.Output.[Output Matrix].Sparse = "False"
     Opts.Output.[Output Matrix].[Column Major] = "False"
     Opts.Output.[Output Matrix].Compression = 1
     Opts.Output.[Output Matrix].[File Name] = pamf[period]   // note that these are daily trips, distriubted with TOD skims. Diurnals must be applied later.

     ret_value = RunMacro("TCB Run Procedure", "Gravity", Opts, &Ret)

     if !ret_value then do
        ShowMessage("GM failed")
        goto quit
     end

end     // end gravity


// External-External Fratar Model
// Growth Factor
if(feedback_iteration=1)  then do
     SetStatus(2,"EE Fratar",)
     intab=Args.EE_Seed
     outab=Args.[EE Trip Table]
     Opts = null
     Opts.Input.[Base Matrix Currency] = {intab, "Autos",  ,  }
     Opts.Input.[PA View Set] = {tazf+"|"+taz_in, taz_in, "Selection", "Select * where nz(ExSta)>0"}
     Opts.Global.[Constraint Type] = "Doubly"
     Opts.Global.Iterations = 500
     Opts.Global.Convergence = 0.001
     Opts.Field.[Core Names Used] = {"Autos", "Single Unit Trucks", "Combination Trucks"}
     Opts.Field.[P Core Fields] = {taz_in+".EE_Auto_P", taz_in+".EE_SU_P", taz_in+".EE_Comb_P"}
     Opts.Field.[A Core Fields] = {taz_in+".EE_Auto_P", taz_in+".EE_SU_P", taz_in+".EE_Comb_P"}
     Opts.Output.[Output Matrix].Label = "EE Trips Matrix"
     Opts.Output.[Output Matrix].[File Name] = outab // These are daily EE trips

     ret_value = RunMacro("TCB Run Procedure", "Growth Factor", Opts, &Ret)

     if !ret_value then do
        ShowMessage("EE Fratar failed")
        goto quit
     end
end
    quit:
    SetStatus(2, "@System1", )
    return(ret_value)
endmacro

// Time of Day model
macro "Time of Day" (Args)    // Time of Day model

dim pamf[4]
pamf[1]=Args.PA_Matrix_AM
pamf[2]=Args.PA_Matrix_MD
pamf[3]=Args.PA_Matrix_PM
pamf[4]=Args.PA_Matrix_NT
pnams={"AM","MD","PM","NT"}

amodf  = Args.[OD AM]
mdodf  = Args.[OD MD]
pmodf  = Args.[OD PM]
ntodf  = Args.[OD NT]
dayodf = Args.[OD Daily]
odfiles= {amodf,mdodf,pmodf,ntodf,dayodf}

// read TOD table
    todf = Args.TODrates
    tod_tab = OpenTable("TOD", "FFB", {todf,})
    SetView(tod_tab)
    //         1                 2              3            4            5         6                7       8               9         10
    timep={"AM_Peak_frac","Midday_frac","PM_Peak_frac","Night_frac","Daily_frac","AM_Peak_PA","Midday_PA","PM_Peak_PA","Night_PA","Daily_PA"}
    dim diur[5,12],pafac[5,12] // factors by period and purpose
    for p = 1 to 5 do       // time period loop
         vr  = nz(GetDataVector(tod_tab+"|", timep[p],  ))
         oa  = V2A(vr)
         for pur = 1 to 12 do          // purpose loop
           diur[p][pur] = oa[pur]
         end
         vr  = nz(GetDataVector(tod_tab+"|", timep[p+5],  ))
         oa  = V2A(vr)
         for pur = 1 to 12 do          // purpose loop
           pafac[p][pur] = oa[pur]
         end
    end

dim tf[4],tmh[5],mi[4]     // temporary files for transposed matrices
// transpose trip tables
for period=1 to 4 do
  pafil=pamf[period]
  tf[period]=GetTempFileName(".mtx")
  mi[period] = OpenMatrix(pafil, )
  mcs = GetMatrixCoreNames(mi[period])
  mc = CreateMatrixCurrency(mi[period], mcs[1], , , )
  tmh[period] = TransposeMatrix(mi[period], {{"File Name", tf[period]}, {"Label", "Transposed Matrix"}, , , , })
  if(tmh[period]<>null) then
     ret_value=1
  else do
     ret_value=0
     goto quit
  end
end

// ============= Create OD trip tables for 5 time periods =====================================================
dim mpa[20],map[20],mod[20]
for period=1 to 4 do
  odfil=odfiles[period]
  // create empty output matrix
  omh=CopyMatrixStructure({mc}, {{"File Name", odfil}, , ,  {"Tables", mcs},{"Compression", 1} })
  // populate period matrix
  // get currencies for PA table AP table and output OD table and populate cores
  for k=1 to mcs.length do
    mpa[k] = CreateMatrixCurrency(mi[period],  mcs[k], , , )
    map[k] = CreateMatrixCurrency(tmh[period], mcs[k], , , )
    mod[k] = CreateMatrixCurrency(omh, mcs[k], , , )
    mod[k]:= diur[period][k]*(pafac[period][k]*mpa[k] + (1-pafac[period][k])*map[k]) // period matrices
  end
end
// =============================================================================================================

  quit:
  return(ret_value)
endmacro

// Auto Occupancy Model
macro "Occupancy" (Args)    // Auto Occupancy Model

amHTf  = Args.AM_HWY_Trips
mdHTf  = Args.MD_HWY_Trips
pmHTf  = Args.PM_HWY_Trips
ntHTf  = Args.NT_HWY_Trips
dayHTf = Args.Daily_HWY_Trips
HTfiles= {amHTf,mdHTf,pmHTf,ntHTf,dayHTf}

amodf  = Args.[OD AM]
mdodf  = Args.[OD MD]
pmodf  = Args.[OD PM]
ntodf  = Args.[OD NT]
dayodf = Args.[OD Daily]
odfiles= {amodf,mdodf,pmodf,ntodf,dayodf}

// read TOD table
    todf = Args.TODrates
    tod_tab = OpenTable("TOD", "FFB", {todf,})
    SetView(tod_tab)
    //         1                 2              3            4            5         6                7       8               9         10
    timep={"AM_Peak_frac","Midday_frac","PM_Peak_frac","Night_frac","Daily_frac","AM_Peak_PA","Midday_PA","PM_Peak_PA","Night_PA","Daily_PA"}
    dim diur[5,12],pafac[5,12] // factors by period and purpose
    for p = 1 to 5 do       // time period loop
         vr  = nz(GetDataVector(tod_tab+"|", timep[p],  ))
         oa  = V2A(vr)
         for pur = 1 to 12 do          // purpose loop
           diur[p][pur] = oa[pur]
         end
         vr  = nz(GetDataVector(tod_tab+"|", timep[p+5],  ))
         oa  = V2A(vr)
         for pur = 1 to 12 do          // purpose loop
           pafac[p][pur] = oa[pur]
         end
    end
    closeview(tod_tab)

// read occupancy level table
    ocf = Args.OCCrates
    ocr_tab = OpenTable("OCC", "FFB", {ocf,})
    SetView(ocr_tab)
    //         1        2         3        4       5
    timep={"AM_Peak","Midday","PM_Peak","Night","Daily"}
    dim occ[5,12] // vehicle occupancy by period and purpose
    for p = 1 to timep.length do       // time period loop
         vr  = nz(GetDataVector(ocr_tab+"|", timep[p],  ))
         oa  = V2A(vr)
         for pur = 1 to 12 do          // purpose loop
           occ[p][pur] = oa[pur]
         end
    end

// ============= Create HWY trip tables for 4 time periods =====================================================
    dim mod[12],mhv[12],hlodc[6],eecs[3]
    pnams={"AM","MD","PM","NT"}
for period=1 to 4 do
    odfil=odfiles[period]
    HTfil=HTfiles[period]
// combine tables and apply rates for the period assignment
    mi  = OpenMatrix(odfil, )
    mcs = GetMatrixCoreNames(mi)  // get core names
// create empty output highway vehicle matrix and populate
    mc = CreateMatrixCurrency(mi, mcs[1], , , )
    hv=CopyMatrixStructure({mc}, {{"File Name", HTfil}, , ,  {"Tables", mcs},{"Compression", 1} })
    for k=1 to mcs.length do
      mod[k] = CreateMatrixCurrency(mi, mcs[k], , , )     // OD person trips
      mhv[k] = CreateMatrixCurrency(hv, mcs[k], , , )     // highway vehicles
      mhv[k]:=mod[k]/occ[period][k]                       // apply occupancy rates
    end

    hee = openmatrix(Args.[EE Trip Table], )
  if(feedback_iteration=1) then do
    //create tod ee cores
    ecores={"EE_autos_","EE_SU_","EE_Comb_"}
    for k=1 to ecores.length do
      cn=ecores[k]+pnams[period]
      AddMatrixCore(hee, cn)                           // add matrice cores ee time periods
      thiscore[k][period] = CreateMatrixCurrency(hee, cn, , , )
    end
    eecn = GetMatrixCoreNames(hee)  // get core names
    for k=1 to ecores.length do
      eecs[k] = CreateMatrixCurrency(hee, eecn[k], , , )     // OD external vehicle trips
      thiscore[k][period]:=diur[period][12]*eecs[k]                      // OD external vehicle trips for this time period
    end
  end

    acores={"EE_autos","EE_SU","EE_Comb","all_autos","SU_truck","Comb_truck"}
    for k=1 to acores.length do
      AddMatrixCore(hv, acores[k])                           // add matrice cores for highway loads
      hlodc[k] = CreateMatrixCurrency(hv, acores[k], , , )   // higway load currencies
    end
    if period=1 then do      // create matrices for daily summary
       CopyFile(amHTf, dayHTf)
       dayh = OpenMatrix(dayHTf, )
       daycA =    CreateMatrixCurrency(dayh, "all_autos", , , )
       daycSU =   CreateMatrixCurrency(dayh, "SU_truck", , , )
       daycCOMB = CreateMatrixCurrency(dayh, "Comb_truck", , , )
       daycA:=0
       daycSU:=0
       daycCOMB:=0
    end
// ----  Populate cores for period highway loads ----
// Matrix merge required because EE matrices did not include internal zones --> put small matrices into full 1052 x 1052 matrices
    MergeMatrixElements(hlodc[1], {thiscore[1][period]}, null, null, {{"Force Missing", "Yes"}})      // ee autos
    MergeMatrixElements(hlodc[2], {thiscore[2][period]}, null, null, {{"Force Missing", "Yes"}})      // ee su
    MergeMatrixElements(hlodc[3], {thiscore[3][period]}, null, null, {{"Force Missing", "Yes"}})      // ee comb
// Matrix expressions OK here, nz required because of nulls
// These are the matrices that will be assigned
    hlodc[4]:=nz(mhv[1]) + nz(mhv[2])  + nz(mhv[3])  + nz(mhv[4]) + nz(mhv[5]) + nz(mhv[6]) + nz(mhv[9]) + nz(hlodc[1]) // autos
    hlodc[5]:=nz(mhv[7]) + nz(mhv[10])+ nz(hlodc[2])                                                                    // SU Trucks
    hlodc[6]:=nz(mhv[8]) + nz(mhv[11])  + nz(hlodc[3])                                                                  // Comb trucks
    daycA:=   daycA    + hlodc[4]      // daily autos
    daycSU:=  daycSU   + hlodc[5]      // daily SU Trucks
    daycCOMB:=daycCOMB + hlodc[6]      // daily Comb Trucks
end
// =============================================================================================================
    RunMacro("CloseAllViews")
    eecs=null // close EE Trip Table
    ret_value = 1
    quit:
    return(ret_value)
endmacro
// =============================================================================================================


// =============================================================================================================
// Highway Traffic Assignment
macro "Trip Assignment" (Args)    // Trip Generation

    AM_trk_lod    =Args.AM_trk_lod
    AM_car_lod    =Args.AM_car_lod
    MD_trk_lod    =Args.MD_trk_lod
    MD_car_lod    =Args.MD_car_lod
    PM_trk_lod    =Args.PM_trk_lod
    PM_car_lod    =Args.PM_car_lod
    NT_trk_lod    =Args.NT_trk_lod
    NT_car_lod    =Args.NT_car_lod
    Daily_trk_lod =Args.Daily_trk_lod
    Daily_car_lod =Args.Daily_car_lod
    lodfiles      ={AM_trk_lod,AM_car_lod,MD_trk_lod,MD_car_lod,PM_trk_lod,PM_car_lod,NT_trk_lod,NT_car_lod,Daily_trk_lod,Daily_car_lod}

    amHTf  = Args.AM_HWY_Trips
    mdHTf  = Args.MD_HWY_Trips
    pmHTf  = Args.PM_HWY_Trips
    ntHTf  = Args.NT_HWY_Trips
    dayHTf = Args.Daily_HWY_Trips
    HTfiles= {amHTf,mdHTf,pmHTf,ntHTf,dayHTf}
    
    pnames ={"AMPK","MD","PMPK","NT","Daily"} // period names
    tflds  ={"FF_TruckTime","FF_AutoTime","FF_TruckTime","FF_AutoTime","FF_TruckTime","FF_AutoTime","FF_TruckTime","FF_AutoTime","FF_TruckTime","FF_AutoTime"}
    cflds  ={"AMCapacity","MDCapacity","PMCapacity","NTCapacity","DailyCapacity"}

    netfAM  = Args.[NET AM]
    netfMD  = Args.[NET MD]
    netfPM  = Args.[NET PM]
    netfNT  = Args.[NET NT]
    netf={netfAM,netfMD,netfPM,netfNT}
    //roads    = Args.[Highway Layer]
      mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR

for k = 1 to 4 do   // do 4 not 5 for now
   
    kk  = 2*k-1
    kk1 = 2*k

    tripf    = HTfiles[k]
    flowtabf = lodfiles[kk]
    timefld  = tflds[kk]
    capfld   = cflds[k]
    // need to load trucks only once
    if(feedback_iteration=1) then do
//       myargs={flowtabf,timefld,capfld,tripf,netf[k],roads,Args}
       myargs={flowtabf,timefld,capfld,tripf,netf[k],mn_file,Args}  // Changed to master network EW HDR
       ret_value  =RunMacro("trk_assign",myargs)
       if !ret_value then goto quit
    end
    flowtabf = lodfiles[kk1]
    timefld  = tflds[kk1]
//    myargs={flowtabf,timefld,capfld,tripf,netf[k],roads,k,Args}
    myargs={flowtabf,timefld,capfld,tripf,netf[k],mn_file,k,Args} // Changed to master network EW HDR
    ret_value  =RunMacro("auto_assign",myargs)
    if !ret_value then goto quit
end

    quit:
    return(ret_value)
endmacro
// =============================================================================================================

Macro "auto_assign" (myargs)

//  {flowtabf,timefld,capfld,tripf,netf,roads,period,Args}=myargs
  {flowtabf,timefld,capfld,tripf,netf,mn_file,period,Args}=myargs // Changed to master network EW HDR
  pnams={"AM","MD","PM","NT"}  // for feedback

     Opts = null
//     Opts.Input.Database = roads
     Opts.Input.Database = mn_file  // Changed to master network EW HDR
     Opts.Input.Network = netf
     Opts.Input.[OD Matrix Currency] = {tripf, "HBW", , }
     Opts.Input.[Exclusion Link Sets] = {}
     Opts.Field.[Vehicle Classes] = {15}
     Opts.Field.[Fixed Toll Fields] = {"n/a"}
     Opts.Field.[PCE Fields] = {"None"}
     Opts.Field.[VDF Fld Names] = {timefld, capfld, "None", "None", "Trk_preload"}
     Opts.Global.[Load Method] = "UE"
     Opts.Global.[Loading Multiplier] = 1
     If(sellink<>0) then do
        Opts.Global.[Critical Query File] = Args.SelectQ
      	Opts.Output.[Critical Matrix].Label = "Select Link Trip Table"//Critical
     	Opts.Output.[Critical Matrix].Compression = 1//Critical
     	Opts.Output.[Critical Matrix].[File Name] = odir + "critaut_" + per + ".mtx"//Critical
     end
//
     Opts.Global.Convergence = 0.0001      // convergence tightened by KDK 6-12-2013 to 0.0001 and 200 iters
     Opts.Global.Iterations = 200 // why isn't this read???? Args.[Assignment Iterations]    // required for MSA calculation in feedback
     Opts.Global.[Number of Classes] = 1
     Opts.Global.[Class PCEs] = {1}
     Opts.Global.[Class VOIs] = {1}
     Opts.Global.[Cost Function File] = "bpr.vdf"
     Opts.Global.[VDF Defaults] = {, , 0.15, 4, 0}
     Opts.Output.[Flow Table] = flowtabf

     ret_value = RunMacro("TCB Run Procedure", "MMA", Opts, &Ret)

     if !ret_value then ShowMessage("Auto Assignment failed")

    return(ret_value)

endMacro


// =================================================================================================
Macro "trk_assign" (myargs)

//  {flowtabf,timefld,capfld,tripf,netf,roads,Args}=myargs
  {flowtabf,timefld,capfld,tripf,netf,mn_file,Args}=myargs  // Changed to master network EW HDR

  	tp=Args.Turnpens
        //db_file = Args.[Highway Layer]
          mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR

     Opts = null
//     Opts.Input.Database = roads
     Opts.Input.Database = mn_file  // Chnaged to master network EW HDR
     Opts.Input.Network = netf
     Opts.Input.[OD Matrix Currency] = {tripf, "HBW", , }
     Opts.Input.[Exclusion Link Sets] = {, }
     Opts.Field.[Vehicle Classes] = {16, 17}
     Opts.Field.[Fixed Toll Fields] = {"n/a", "n/a"}
     Opts.Field.[PCE Fields] = {"None", "None"}
     Opts.Field.[VDF Fld Names] = {timefld, capfld, "Length", "None", "None"}
     Opts.Global.[Load Method] = "UE"
     Opts.Global.[Loading Multiplier] = 1
     Opts.Global.Convergence = 0.01
     Opts.Global.Iterations = 1
     Opts.Global.[Number of Classes] = 2
     Opts.Global.[Class PCEs] = {1.5, 1.5}
     Opts.Global.[Class VOIs] = {1, 1}
     Opts.Global.[Cost Function File] = "bpr.vdf"
     Opts.Global.[VDF Defaults] = {, , 0.15, 4, 0}
     Opts.Output.[Flow Table] = flowtabf
//
     //If(Args.RunSelectedLink<>0) then do
     If(sellink<>0) then do
        Opts.Global.[Critical Query File] = Args.SelectQ
      	Opts.Output.[Critical Matrix].Label = "Select Link Trip Table"//Critical
     	Opts.Output.[Critical Matrix].Compression = 1//Critical
     	Opts.Output.[Critical Matrix].[File Name] = odir + "crittrk_" + per + ".mtx"//Critical
     end
//
     ret_value = RunMacro("TCB Run Procedure", "MMA", Opts, &Ret)
     if !ret_value then do
        ShowMessage("Truck Assignment failed")
        goto quit
     end

  // put truck pcs's in network file to use in auto assignment
//    {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", roads)
    {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file)  // Changed to master network EW HDR

      preflds ={{"AB_trk_PCE","Real",9,2},{"BA_trk_PCE","Real",9,2}}            // truck preload
      RunMacro("TCB Add View Fields",{link_lyr,preflds})

      lod_tab = OpenTable("pre", "FFB", {flowtabf,})
      vw2 = JoinViews("jv",link_lyr+".ID", lod_tab+".ID1",)

      vabl = GetDataVector(vw2+"|", "AB_FLOW_PCE", )
      vbal = GetDataVector(vw2+"|", "BA_FLOW_PCE", )
      SetDataVector(vw2+"|", "AB_trk_PCE", vabl,  )
      SetDataVector(vw2+"|", "BA_trk_PCE", vbal,  )
      RunMacro("CloseAllViews")

// STEP 1: Build Highway Network
     // In_Network codes: 0 or null=not used, 1=autos and trucks, 2=autos only, 3=trucks only
     qryH = "Select * where In_Network=1 | In_Network=3"
     Opts = null
//     Opts.Input.[Link Set] = {roads+"|"+link_lyr, link_lyr,"hwy",qryH}
     Opts.Input.[Link Set] = {mn_file+"|"+link_lyr, link_lyr,"hwy",qryH}  // Changed to master network EW HDR
     Opts.Global.[Network Options].[Node ID] = node_lyr+".ID"
     Opts.Global.[Network Options].[Link ID] = link_lyr+".ID"
     Opts.Global.[Network Options].[Turn Penalties] = "Yes"
     Opts.Global.[Network Options].[Keep Duplicate Links] = "FALSE"
     Opts.Global.[Network Options].[Ignore Link Direction] = "FALSE"
     Opts.Global.[Link Options] = {{"Length", link_lyr+".Length", link_lyr+".Length"},
	                           {"ID", link_lyr+".ID", link_lyr+".ID"},
				   {"Dir", link_lyr+".Dir", link_lyr+".Dir"},
				   {"[Facil Type]", link_lyr+".FClass", link_lyr+".FClass"},
				   {"[Area Type]", link_lyr+".AREATYPE", link_lyr+".AREATYPE"},
				   {"BPRA", link_lyr+".BPRA", link_lyr+".BPRA"},
				   {"BPRB", link_lyr+".BPRB", link_lyr+".BPRB"},
				   {"Time", link_lyr+".AutoTime", link_lyr+".AutoTime"},
           {"DailyCapacity", link_lyr+".AB_DailyCap", link_lyr+".BA_DailyCap"},         // Changes are made by Johnny Han, 4/29/2015
           {"HourlyCapacity", link_lyr+".AB_HourlyCap", link_lyr+".BA_HourlyCap"},      // Changes are made by Johnny Han, 4/29/2015
				   {"AMCapacity", link_lyr+".AB_AM_CAP", link_lyr+".BA_AM_CAP"},
				   {"MDCapacity", link_lyr+".AB_MD_CAP", link_lyr+".BA_MD_CAP"},
				   {"PMCapacity", link_lyr+".AB_PM_CAP", link_lyr+".BA_PM_CAP"},
				   {"NTCapacity", link_lyr+".AB_NT_CAP", link_lyr+".BA_NT_CAP"},
				   {"FF_AutoTime", link_lyr+".AutoTime", link_lyr+".AutoTime"},
				   {"FF_TruckTime", link_lyr+".TruckTime", link_lyr+".TruckTime"},
				   {"Trk_preload", link_lyr+".AB_trk_PCE", link_lyr+".BA_trk_PCE"}}
     Opts.Output.[Network File] = netf

     ret_value = RunMacro("TCB Run Operation", 1, "Build Highway Network", Opts)

    if !ret_value then do
       ShowMessage("Truck Network failed")
    end

// STEP 1: Highway Network Setting
     SetStatus(2,"Highway Network Settings",)
     Opts = null
//     Opts.Input.Database = db_file
     Opts.Input.Database = mn_file  // Changed to master network EW HDR
     Opts.Input.Network = netf
     Opts.Input.[Spc Turn Pen Table] = {tp}
//     Opts.Input.[Centroids Set] = {db_file+"|"+node_lyr, node_lyr, "Centroids", "Select * where IsCentroid<>null"}
     Opts.Input.[Centroids Set] = {mn_file+"|"+node_lyr, node_lyr, "Centroids", "Select * where IsCentroid<>null"}  // Changed to master network EW HDR
     Opts.Field.[Link type] = "[Facil Type]"
     Opts.Global.[Global Turn Penalties] = {0, 0, 0, -1}
     Opts.Flag.[Use Link Types] = "True"

     ret_value = RunMacro("TCB Run Operation", 1, "Highway Network Setting", Opts)

     if !ret_value then do
        ShowMessage("Highway Network Setting failed")
        goto quit
     end

    quit:
    return(ret_value)
endMacro
// =============================================================================================================

Macro "Feedback" (Args)
// This macro encompasses skims, distrib, occupancy & TOD, and HWY assignment per TransCAD method <<<------------------
global feedback_iteration,converged,thiscore
dim thiscore[3,4] // hold ee currencies by vehicle type and period
pnams={"AM","MD","PM","NT"}

on error goto ok
fcheck=getfileinfo(odir+"feedback.txt")
if fcheck<>null then DeleteFile(odir+"feedback.txt") 
ok:
on error default
ptr = OpenFile(odir+"feedback.txt", "a")
now= GetDateAndTime()
WriteLine(ptr, "Feedback report "+now)


feedback_iteration = 1
converged = 0
while (converged < 4)  and (feedback_iteration<=20)do
converged = 0
SetStatus(1, "FB iter= "+i2s(feedback_iteration), )
WriteLine(ptr, "Iter "+i2s(feedback_iteration))
// <<<----- Macro calls here ---------------
    ret_value  =RunMacro("Network Skimming",Args)
    if !ret_value then goto quit
    ret_value  =RunMacro("Gravity Model",Args)
    if !ret_value then goto quit
    ret_value  =RunMacro("Time of Day",Args)
    if !ret_value then goto quit
    ret_value  =RunMacro("Occupancy",Args)
    if !ret_value then goto quit
    ret_value  =RunMacro("Trip Assignment",Args)
    if !ret_value then goto quit

climit=1.0 //
// Check Convergence
//  must loop on periods. if all 4 periods are not converged, then the model continues
  for k=1 to 4 do
    If feedback_iteration > 1 then do  // we need to run at least 2 loops to check convergence
        previous_skim_matrix = odir+"skim_"+pnams[k]+i2s(feedback_iteration - 1)+".mtx"
        current_skim_matrix =  odir+"skim_"+pnams[k]+i2s(feedback_iteration)+".mtx"
        m_prev_skim = OpenMatrix(previous_skim_matrix,)
        m_curr_skim = OpenMatrix(current_skim_matrix,)
        mc_prev_skim = CreateMatrixCurrency(m_prev_skim, "Composite",,,)
        mc_curr_skim = CreateMatrixCurrency(m_curr_skim, "Composite",,,)
        rmse_array = MatrixRMSE(mc_prev_skim, mc_curr_skim)   //  <<--- note error in Caliper Manual and Help File on this line!!!
        rmse = rmse_array.RMSE
        percent_rmse = rmse_array.RelRMSE
        WriteLine(ptr, "     "+pnams[k]+"  %RMSE= "+r2s(percent_rmse))
        if percent_rmse < climit then  converged = converged+1
    end // feedback
  end // purpose loop
  feedback_iteration=feedback_iteration+1
end // of while loop

todelete_iter=feedback_iteration-1

// cleanup all but the last skim file
m_prev_skim = null
m_curr_skim = null
mc_prev_skim = null
mc_curr_skim = null
for n=1 to todelete_iter do
  for period=1 to 4 do
     skimf=odir+"skim_"+pnams[period]+i2s(n)+".mtx"
     if(n=todelete_iter) then do
       savf=odir+"skim_"+pnams[period]+".mtx"
       copyfile(skimf,savf)
     end
     deletefile(skimf)
  end
end
// end cleanup

now= GetDateAndTime()
WriteLine(ptr, "Feedback complete "+now)
SetStatus(1, "@system0", )
    quit:
    return(ret_value)

endMacro


// =============================================================================================================

Macro "Evaluation" (Args)	
    RunMacro("tlsum",Args)
    //return(1)
    RunMacro("filload",Args)

// +++++++++++++++++++++++++++++++++++++++++
       ret_value  =RunMacro("RPTTLFD",Args)
       if(ret_value=0) then return(0)
// +++++++++++++++++++++++++++++++++++++++++

    for prd=1 to 5 do
      RunMacro("XMLHEVAL", Args,prd,1)     // all counties
    end
    for prd=1 to 5 do
      RunMacro("XMLHEVAL", Args,prd,2)     // Daviess County only
    end
    return(1)
endMacro

// =============================================================================================================
Macro "tlsum" (Args)
  dim pamf[4]
  pamf[1]=Args.PA_Matrix_AM
  pamf[2]=Args.PA_Matrix_MD
  pamf[3]=Args.PA_Matrix_PM
  pamf[4]=Args.PA_Matrix_NT
  pnams={"AM","MD","PM","NT","Daily"}
  purps={"HBW", "HBO", "NHB", "HBsc", "HBU","Light trk","Med trk","Heavy trk","EI_Auto","EI_SU","EI_Comb"}   // 11 of these

  todf = Args.TODrates
  tod_tab = OpenTable("TOD", "FFB", {todf,})
  SetView(tod_tab)
  Dim pATL[11,4],dATL[11,4],pTR[11,4],pINTRA[11,4],tTR[12]
    timep={"AM_Peak_frac","Midday_frac","PM_Peak_frac","Night_frac","Daily_frac","AM_Peak_PA","Midday_PA","PM_Peak_PA","Night_PA","Daily_PA"}
    dim diur[5,12],pafac[5,12] // factors by period and purpose
    for p = 1 to 5 do       // time period loop
         vr  = nz(GetDataVector(tod_tab+"|", timep[p],  ))
         oa  = V2A(vr)
         for pur = 1 to 12 do          // purpose loop
           diur[p][pur] = oa[pur]
           tTR[pur] = 0
         end
    end
  CloseView(tod_tab)


  for  p= 1 to 4 do
    period=pnams[p]
//--
    For i = 1 to 11 do


// Calculate Average Trip Length (ATL) in minutes -- put vmt in skim matrix
     skimf=odir+"skim_"+period+".mtx"
     hsk  = OpenMatrix(skimf,)
     mctime = CreateMatrixCurrency(hsk,"Time",,,)
     mcdist = CreateMatrixCurrency(hsk,"Length (Skim)",,,)

     kscore=0
     mm=GetMatrixCoreNames(hsk)
     for j=1 to mm.length do
       if(mm[j]=purps[i]+"_VMT") then kscore=1
     end
     if(kscore=0) then AddMatrixCore(hsk,purps[i]+"_VMT")
     mcvmt = CreateMatrixCurrency (hsk,purps[i]+"_VMT",,,)

     jscore=0
     mm=GetMatrixCoreNames(hsk)
     for j=1 to mm.length do
       if(mm[j]=purps[i]+"_VHT") then jscore=1
     end
     if(jscore=0) then AddMatrixCore(hsk,purps[i]+"_VHT")
     mcvht = CreateMatrixCurrency (hsk,purps[i]+"_VHT",,,)

     htr  = OpenMatrix(pamf[p],)
     mctrips = CreateMatrixCurrency(htr,purps[i],,,)

     iscore=0
     mm=GetMatrixCoreNames(htr)
     for j=1 to mm.length do
       if(mm[j]="tem") then iscore=1
     end
     if(iscore=0) then AddMatrixCore(htr,"tem")
     mtemp = CreateMatrixCurrency (htr,"tem",,,)

     mtemp := mctrips*diur[p][i]
     mcvht := nz(mctime) * nz(mtemp)
     mcvmt := nz(mcdist) * nz(mtemp)
     stat_array_trips = MatrixStatistics(htr, )
     stat_array_time  = MatrixStatistics(hsk, )
     ttrips=stat_array_trips.("tem").Sum
     pINTRA[i][p]=stat_array_trips.("tem").[PctDiag] // note NOT Pct_Diag like help file says
     ttime=stat_array_time.(purps[i]+"_VHT").Sum
     tdist=stat_array_time.(purps[i]+"_VMT").Sum
     if(ttrips>0) then do
       pATL[i][p]=ttime/ttrips
       dATL[i][p]=tdist/ttrips
     end
     else do
       pATL[i][p]=0
       dATL[i][p]=0
     end
     pTR[i][p]=ttrips
     tTR[i]=tTR[i]+ttrips
    end
     //clean up
     hsk=null
     mctime=null
     mcvht=null
  end
//          Report Average trip lengths
//AppendToReportFile(0, "DAVIESS COUNTY AREA MODEL TRIP DISTRIBUTION SUMMARY: "+GetDateAndTime(), {{"Section", "True"}})
AppendToReportFile(0, "REGIONAL MODEL TRIP DISTRIBUTION SUMMARY: "+GetDateAndTime(), {{"Section", "True"}})

AppendTableToReportFile({{{"Name", "Purpose"},     {"Percentage Width", 8}, {"Alignment", "Left"}},
                         {{"Name", "AM Trips"},    {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "AM ATL(min)"}, {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "AM ATL(mi)"},  {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "AM %Intra"},   {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "MD Trips"},    {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "MD ATL(min)"}, {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "MD ATL(mi)"},  {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "MD %Intra"},   {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "PM Trips"},    {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "PM ATL(min)"}, {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "PM ATL(mi)"},  {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "PM %Intra"},   {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "NT Trips"},    {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "NT ATL(min)"}, {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "NT ATL(mi)"},  {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "NT %Intra"},   {"Percentage Width", 5.4}, {"Alignment", "Right"}},
                         {{"Name", "Daily Trips"}, {"Percentage Width", 5.4}, {"Alignment", "Right"}}},
   {{"Title", "Trip Distribution Report (TIME & DISTANCE)"}})
for i = 1 to 11 do
  AppendRowToReportFile({purps[i],
                         format(pTR[i][1],",*0"),format(pATL[i][1],",*0.000"),format(dATL[i][1],",*0.000"),format(pINTRA[i][1],",*0.000"),
                         format(pTR[i][2],",*0"),format(pATL[i][2],",*0.000"),format(dATL[i][2],",*0.000"),format(pINTRA[i][2],",*0.000"),
                         format(pTR[i][3],",*0"),format(pATL[i][3],",*0.000"),format(dATL[i][3],",*0.000"),format(pINTRA[i][3],",*0.000"),
                         format(pTR[i][4],",*0"),format(pATL[i][4],",*0.000"),format(dATL[i][4],",*0.000"),format(pINTRA[i][4],",*0.000"),
                         format(tTR[i],",*0")}, )
end
AppendToReportFile(1, "Note: Final after feedback iteration "+i2s(feedback_iteration)+".", {{"Section", "False"}})
CloseReportFileSection()


  return(1)
endMacro

// =============================================================================================================
Macro "filload" (Args)

    pnams={"AM","MD","PM","NT","Daily"}
    vehsets={{"car","Flow_all_autos"},{"trk","Flow_SU_truck"},{"trk","Flow_Comb_truck"},{"car","Flow_Vehs"}}
    selsets={{"car","Flow_Query1_all_autos"},{"trk","Flow_Query1_SU_truck"},{"trk","Flow_Query1_Comb_truck"},{"car","Flow_Query1_Vehs"}}
    //roads  = Args.[Highway Layer]
      mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR
//    {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", roads)
    {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file)  // Changed to master network EW HDR
    
    dim flowa[5,4],flowb[5,4] //period,vehtype

// REGULAR LOADS
for  p= 1 to 4 do
  period=pnams[p]
  for vs = 1 to 3 do
    typ= vehsets[vs][1]
    fld= vehsets[vs][2]
    fa     = "AB_"+fld
    fb     = "BA_"+fld
    lodf   = odir+period+"_"+typ+"_lod.bin"
    addab  = "AB_"+fld+"_"+period
    addba  = "BA_"+fld+"_"+period

    fields ={{addab,"Real",15,4},{addba,"Real",15,4}}
    RunMacro("TCB Add View Fields",{link_lyr,fields})
    loads = OpenTable("Loads", "FFB", {lodf,})

    jv = JoinViews("jv",link_lyr+".ID", loads+".ID1",)

    flowa[p][vs] =GetDataVector(jv+"|", loads+"."+fa,  )
    SetDataVector(jv+"|", addab, flowa[p][vs], )
    flowb[p][vs] =GetDataVector(jv+"|", loads+"."+fb,  )
    SetDataVector(jv+"|", addba, flowb[p][vs], )

    closeview(jv)
    closeview(loads)
  end
  // vehicles
    vs=4
    fld= vehsets[4][2]
    addab  = "AB_"+fld+"_"+period
    addba  = "BA_"+fld+"_"+period
    add2   = "Twoway_veh_"+period

    fields ={{addab,"Real",15,4},{addba,"Real",15,4},{add2,"Real",15,4}}
    RunMacro("TCB Add View Fields",{link_lyr,fields})

    flowa[p][vs] = flowa[p][1]+flowa[p][2]+flowa[p][3]
    SetDataVector(link_lyr+"|", addab, flowa[p][vs], )
    flowb[p][vs] = flowb[p][1]+flowb[p][2]+flowb[p][3]
    SetDataVector(link_lyr+"|", addba, flowb[p][vs], )
    fl2=nz(flowa[p][vs])+nz(flowb[p][vs])      // 2-way loads by period
    SetDataVector(link_lyr+"|", add2, fl2, )
end

// DAILY
  p=5
  period=pnams[p]
  for vs = 1 to 4 do
    fld= vehsets[vs][2]
    addab  = "AB_"+fld+"_"+period
    addba  = "BA_"+fld+"_"+period

    fields ={{addab,"Real",15,4},{addba,"Real",15,4}}
    RunMacro("TCB Add View Fields",{link_lyr,fields})

    flowa[p][vs] = flowa[1][vs]+flowa[2][vs]+flowa[3][vs]+flowa[4][vs]
    SetDataVector(link_lyr+"|", addab, flowa[p][vs], )
    flowb[p][vs] = flowb[1][vs]+flowb[2][vs]+flowb[3][vs]+flowb[4][vs]
    SetDataVector(link_lyr+"|", addba, flowb[p][vs], )
  end
// daily 2-way volume and count comparison
    f2="Daily 2-way Vehs"
    fvc="Daily vol_cnt"
    fields ={{f2,"Real",15,4},{fvc,"Real",15,4}}
    RunMacro("TCB Add View Fields",{link_lyr,fields})
    v2 = nz(flowa[5][4])+nz(flowb[5][4])
    SetDataVector(link_lyr+"|", f2, v2, )
    count_v=GetDataVector(link_lyr+"|","CNT_CMP",  )
    vvc=if(nz(count_v) > 0) then v2/count_v else null
    SetDataVector(link_lyr+"|", fvc, vvc, )
// Fill Time of day count fields from daily counts and TOD percentages
/*
    dacnt =GetDataVector(link_lyr+"|", "CNT_CMP",  )
    ampct =GetDataVector(link_lyr+"|", "TOD_AM_PCT",  )
    mdpct =GetDataVector(link_lyr+"|", "TOD_MD_PCT",  )
    pmpct =GetDataVector(link_lyr+"|", "TOD_PM_PCT",  )
    ntpct =GetDataVector(link_lyr+"|", "TOD_NT_PCT",  )
    vam = nz(dacnt*ampct)
    vmd = nz(dacnt*mdpct)
    vpm = nz(dacnt*pmpct)
    vnt = nz(dacnt*ntpct)
    SetDataVector(link_lyr+"|", "AM_CNT", vam, )
    SetDataVector(link_lyr+"|", "MD_CNT", vmd, )
    SetDataVector(link_lyr+"|", "PM_CNT", vpm, )
    SetDataVector(link_lyr+"|", "NT_CNT", vnt, )
*/

// Congested Travel Time
vehsets2={{"car","Time"},{"trk","Time"}}
for  p= 1 to 4 do
  period=pnams[p]
  for vs = 1 to 2 do
    typ= vehsets2[vs][1]
    fld= vehsets2[vs][2]
    fa     = "AB_"+fld
    fb     = "BA_"+fld
    lodf   = odir+period+"_"+typ+"_lod.bin"
    addab  = "AB_"+typ+"_CngstTime_"+period
    addba  = "BA_"+typ+"_CngstTime_"+period

    fields ={{addab,"Real",10,2},{addba,"Real",10,2}}
    RunMacro("TCB Add View Fields",{link_lyr,fields})
    loads = OpenTable("Loads", "FFB", {lodf,})

    jv = JoinViews("jv",link_lyr+".ID", loads+".ID1",)

    flowa[p][vs] =GetDataVector(jv+"|", loads+"."+fa,  )
    SetDataVector(jv+"|", addab, flowa[p][vs], )
    flowb[p][vs] =GetDataVector(jv+"|", loads+"."+fb,  )
    SetDataVector(jv+"|", addba, flowb[p][vs], )

    closeview(jv)
    closeview(loads)
  end
end

// END REGULAR LINK LOADS

// SELECTED LINK LOADS
If(sellink<>0) then do
for  p= 1 to 4 do
  period=pnams[p]
  for vs = 1 to 3 do
    typ= selsets[vs][1]
    fld= selsets[vs][2]
    fa     = "AB_"+fld
    fb     = "BA_"+fld
    lodf   = odir+period+"_"+typ+"_lod.bin"
    addab  = "AB_"+fld+"_"+period
    addba  = "BA_"+fld+"_"+period

    fields ={{addab,"Real",15,4},{addba,"Real",15,4}}
    RunMacro("TCB Add View Fields",{link_lyr,fields})
    loads = OpenTable("Loads", "FFB", {lodf,})

    jv = JoinViews("jv",link_lyr+".ID", loads+".ID1",)

    flowa[p][vs] =GetDataVector(jv+"|", loads+"."+fa,  )
    SetDataVector(jv+"|", addab, flowa[p][vs], )
    flowb[p][vs] =GetDataVector(jv+"|", loads+"."+fb,  )
    SetDataVector(jv+"|", addba, flowb[p][vs], )

    closeview(jv)
    closeview(loads)
  end
  // vehicles
    vs=4
    fld= selsets[4][2]
    addab  = "AB_"+fld+"_"+period
    addba  = "BA_"+fld+"_"+period
    add2   = "Twoway_selveh_"+period

    fields ={{addab,"Real",15,4},{addba,"Real",15,4},{add2,"Real",15,4}}
    RunMacro("TCB Add View Fields",{link_lyr,fields})

    flowa[p][vs] = flowa[p][1]+flowa[p][2]+flowa[p][3]
    SetDataVector(link_lyr+"|", addab, flowa[p][vs], )
    flowb[p][vs] = flowb[p][1]+flowb[p][2]+flowb[p][3]
    SetDataVector(link_lyr+"|", addba, flowb[p][vs], )
    fl2=nz(flowa[p][vs])+nz(flowb[p][vs])      // 2-way loads by period
    SetDataVector(link_lyr+"|", add2, fl2, )
end

// DAILY
  p=5
  period=pnams[p]
  for vs = 1 to 4 do
    fld= selsets[vs][2]
    addab  = "AB_"+fld+"_"+period
    addba  = "BA_"+fld+"_"+period

    fields ={{addab,"Real",15,4},{addba,"Real",15,4}}
    RunMacro("TCB Add View Fields",{link_lyr,fields})

    flowa[p][vs] = flowa[1][vs]+flowa[2][vs]+flowa[3][vs]+flowa[4][vs]
    SetDataVector(link_lyr+"|", addab, flowa[p][vs], )
    flowb[p][vs] = flowb[1][vs]+flowb[2][vs]+flowb[3][vs]+flowb[4][vs]
    SetDataVector(link_lyr+"|", addba, flowb[p][vs], )
  end

end // if (Args.RunSelectedLink<>0)

// END SLECTED LINK LOADS

closeview(link_lyr)

endMacro

// =================== MASTER MACRO SPEEDCAP ===========================
Macro "SpeedCap" (Args)
  //RunMacro("TCB Init")
    //shared prj_dry_run  if prj_dry_run then return(1)

    RunMacro("CloseAllViews")

  EnableProgressBar("Status",4)
  CreateProgressBar("Setting Network Speeds and Capacities", "False")

  // Identifies location of input files
    
        mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR

  scDIR=ModelDir+"SpeedCap\\"

  fwydef_file=     scDIR+"fwy_defaults.bin"
  fwycap_file=     scDIR+"fwy_cap.bin"
  kfac_file=       scDIR+"K_factors.bin"
  mhflw_file=	   scDIR+"mh_flw.bin"
  mhtlc_file=      scDIR+"mh_tlc.bin"
  mhmed_file=      scDIR+"mh_medtype.bin"
  mhacc_file=      scDIR+"mh_acc.bin"
  mhcap_file=      scDIR+"mh_cap.bin"
  tlbffs_file=	   scDIR+"tl_bffsadj.bin"
  tllsw_file=	   scDIR+"tl_lsw.bin"
  tlacc_file=	   scDIR+"tl_acc.bin"
  usso_file=       scDIR+"us_so.bin"
  usfcs_file=      scDIR+"us_fcs.bin"
  usda_file=       scDIR+"us_da.bin"
  usfa_file=       scDIR+"us_fa.bin"
  usfl_file=       scDIR+"us_fl.bin"
  ussatflo_file =  scDIR+"us_satflow.bin"
  usflw_file=	   scDIR+"us_flw.bin"
  usat_file=       scDIR+"us_at.bin"
  usgc_file=       scDIR+"us_gc.bin"
  ramp_file=       scDIR+"ramp_cap.bin"



  // Link and node layers are contained in the input file (nfile)
//  {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", nfile,,)
  {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file,,)  // Changed to master network EW HDR



  // subargs are arrays of input files that are called by the sub macros below.
  subargs01={link_lyr,fwydef_file}
  subargs02={link_lyr,fwycap_file,kfac_file}
  subargs03={link_lyr,mhflw_file,mhtlc_file,mhmed_file,mhacc_file}
  subargs04={link_lyr,mhcap_file, kfac_file}
  subargs05={link_lyr,tlbffs_file,tllsw_file,tlacc_file}
  subargs06={link_lyr,usfcs_file,usso_file,usda_file,usfa_file, usfl_file,ussatflo_file,usflw_file,usat_file,usgc_file}
  subargs07={link_lyr,ramp_file}

  // Add fields to link layer if not already present.



  fields = {{"CalcSpeed","Real",8,2,"No"},    // Estimated speed estimated using methods prescribed in the 2010 Highway Capacity Manual
            {"Speed_Override","Real",8,2,"No"},       // Free-flow speed override
            {"AB_HourlyCap_Override","Real",8,2,"No"}, {"BA_HourlyCap_Override","Real",8,2,"No"},  // Hourly capacity override
            {"AutoTime","Real",8,2,"No"},       //
            {"TruckTime","Real",8,2,"No"},      //
            {"AB_HourlyCap","Real",8,2,"No"}, {"BA_HourlyCap","Real",8,2,"No"},      //
            {"AB_DailyCap","Real",8,2,"No"},  {"BA_DailyCap","Real",8,2,"No"},
            {"AB_AM_CAP","Integer",8,2,"No"},{"BA_AM_CAP","Integer",8,2,"No"},      //
            {"AB_MD_CAP","Integer",8,2,"No"},{"BA_MD_CAP","Integer",8,2,"No"},      //
            {"AB_PM_CAP","Integer",8,2,"No"},{"BA_PM_CAP","Integer",8,2,"No"},      //
            {"AB_NT_CAP","Integer",8,2,"No"},{"BA_NT_CAP","Integer",8,2,"No"},      //
            {"AB_AM_LANES","Integer",8,2,"No"},{"BA_AM_LANES","Integer",8,2,"No"},      //
            {"AB_MD_LANES","Integer",8,2,"No"},{"BA_MD_LANES","Integer",8,2,"No"},      //
            {"AB_PM_LANES","Integer",8,2,"No"},{"BA_PM_LANES","Integer",8,2,"No"},      //
            {"AB_NT_LANES","Integer",8,2,"No"},{"BA_NT_LANES","Integer",8,2,"No"},    //
            {"BPRA","Real",8,2,"No"}, {"BPRB","Real",8,2,"No"},
            {"AutoSpeed","Real",8,2,"No"},       // Base free-flow auto speed
            {"TruckSpeed","Real",8,2,"No"},      // Base free-flow truck speed
            {"FFS","Real",8,2,"No"},       // Free-flow speed used in traffic assignment
            {"BFFS","Real",8,2,"No"},      // Base free-flow speed computed using methods prescribed in the 2010 Highway Capacity Manual
            {"TRKSP","Real",8,2,"No"}//,      Truck free-flow speed used in traffic assignment
             }

  RunMacro("TCB Add View Fields",{link_lyr,fields})    //comment out- why does this generate duplicate fields?


// Set minimum BFFS speed.
          SetView(link_lyr)
          qry = "Select * where (In_Network=1 and HCMType<>null and [PostedSpeed]<15)"
          hlinks = SelectByQuery("links", "Several", qry,)
          vset = link_lyr+"|links"
             arec = GetFirstRecord(vset,)
             while arec <> null do
                     link_lyr.[PostedSpeed] = 15
                     arec = GetNextRecord(vset, null,)
             end

// RUN ERROR TRAPS FOR CRITICAL NETWORK FIELDS FOR ALL SPEED AND CAPACITY MACROS FIRST  - ADDED by MHB 09/01/18 - updated by EW HDR. These error traps were moved here rather than scattered in each individual speed/cap macro
          SetView(link_lyr)
          qry = "Select * where (In_Network=1 and HCMType<>null)"
          hlinks = SelectByQuery("links", "Several", qry,)
          vset = link_lyr+"|links"

            arec = GetFirstRecord(vset,)
            while arec <> null do
             HCM = nz(link_lyr.HCMType)
             TLC = nz(link_lyr.TLCLASS)
             Dir = link_lyr.Dir
             SL = nz(link_lyr.[PostedSpeed])
             SOR = nz(link_lyr.[Speed_Override])
             AB_DL = nz(link_lyr.[AB_LANES])
             BA_DL = nz(link_lyr.[BA_LANES])
             at = nz(link_lyr.[AreaType])
             fct = nz(link_lyr.FClass)
             rv = nz(link_lyr.RAMP)  
             sig = nz(link_lyr.Signal)  // EW HDR - signal field added for error trap

//              ERROR TRAP FOR missing HCMType
             if (nz(HCM=0) and (fct<>10)) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error  ** : HCMType for link "+i2s(lid)+" is out of range (1-6)")
                return(null)
             end              
//              ERROR TRAP FOR HCMType within range
             if ((HCM<1 or HCM>6)) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error  ** : HCMType for link "+i2s(lid)+" is out of range (1-6)")
                return(null)
             end                        
//              ERROR TRAP FOR TWO WAY LINKS ON INTERSTATES AND FREEWAYS
             if ((HCM = 1 or HCM = 2) and (Dir = 0 ) and (fct <> 10)) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error fwycap ** : Interstate or Freeway link "+i2s(lid)+" has Dir=0, should be 1 or -1.")
                return(null)
             end
//              ERROR TRAP FOR TLCLASS
             if ((HCM = 4) and ((TLC < 1) or (TLC > 7 ))) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error tl_spdcap ** : Two Lane Hwy link "+i2s(lid)+" TLCLASS is out of range (1-7).")
                return(null)
             end
//              ERROR TRAP FOR 0 LANES ON TWO WAY LINKS
             if(Dir = 0 and (AB_DL=0 or BA_DL = 0 or AB_DL=Null or BA_DL=Null)) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error: link "+i2s(lid)+" has null or 0 AB_Lanes / BA_Lanes, value must be =>1")
                return(null)
             end
//              ERROR TRAP FOR 0 LANES ON ONE WAY LINKS
             if(Dir = 1 and (AB_DL=0)) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error: link "+i2s(lid)+" has null or 0 AB_Lanes, value must be =>1")
                return(null)
             end
             if(Dir = -1 and (BA_DL = 0)) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error: link "+i2s(lid)+" has null or 0 BA_Lanes, value must be =>1")
                return(null)
             end
//              Error Trap for SL and SOR
             if (Nz(SL=0) and Nz(SOR=0)) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error: link "+i2s(lid)+" has null or '0' PostedSpeed and SpeedOverride fields. Correct speed fields")
                return(null)
             end
//              ERROR TRAP FOR MISSING AREA TYPE
             if (Nz(at=0) or Nz(at>5)) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error: link "+i2s(lid)+" has invalid AreaType value, Correct values: 1-Rural, 2-Suburban, 3-Second City, 4-Urban/Town, 5-High Density Urban/CBD" )
                return(null)
             end
//              ERROR TRAP FOR MISSING FUNCTIONAL CLASS
             if (Nz(fct=0) or ((fct>7) and (fct<>10))) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error: link "+i2s(lid)+" has invalid FC (functional class) value. Values must be within new HPMS classes 1-7. Connectors are FClass=10" )
                return(null)
             end
//              ERROR TRAP FOR MISSING FUNCTIONAL CLASS
             if ((HCM=6) and (rv<>2) and (rv<>21) and (rv<>22)) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error: Ramp link "+i2s(lid)+" has invalid Ramp class for HCMType=6. Correct values: 21-on ramp, 22-off ramp, or 2-system ramp")
                return(null)
             end
//              ERROR TRAP FOR MISSING Signal information // EW HDR
             if (sig=Null and HCMType=5) then do
                lid  =link_lyr.ID
                ShowMessage("** Link Attribute Error: Urban link "+i2s(lid)+" has no signal information. Correct values: 0-No speed reduction because of signals, 1-Speed reduction because of signals")
                return(null)
             end
              arec = GetNextRecord(vset, null,)
            end



// Begin calling individual submacros----------------------------------------------------------------------------------

  stat = UpdateProgressBar("Freeways", 50)

  // Run sub macro  01 "fwy_spd" using the input files defined by subargs01
  sub01=RunMacro("fwy_spd",subargs01)

  // warn if sub macro is unsuccessful
  if sub01=null then do
   ShowMessage("fwy_spd macro failed")
   goto final
  end

  // Run sub macro 02 "fwy_cap" using the input files defined by subargs02
  sub02=RunMacro ("fwy_cap",subargs02)

  // warn if sub macro is unsuccessful
  if sub02=null then do
   ShowMessage("fwy_cap macro failed")
   goto final
  end

  stat = UpdateProgressBar("Multi-lane Highways", 50)

  // Run sub macro 03 "mh_spd" using the input files defined by subargs03
  sub03=RunMacro("mh_spd",subargs03)

  // warn if sub macro is unsuccessful
  if sub03=null then do
	ShowMessage("mh_spd macro failed")
	goto final
  end

 // Run sub macro 04 "mh_cap" using the input files defined by subargs04
  sub04=RunMacro("mh_cap",subargs04)

  // warn if sub macro is unsuccessful
  if sub04=null then do
	ShowMessage("mh_cap macro failed")
	goto final
  end

 stat = UpdateProgressBar("Two-lane Highways", 50)

 // Run sub macro 05 "tl_spdcap" using the input files defined by subargs05
  sub05=RunMacro("tl_spdcap",subargs05)

  // warn if sub macro is unsuccessful
  if sub05=null then do
	ShowMessage("tl_spdcap macro failed")
	goto final
  end

   stat = UpdateProgressBar("Urban Streets", 50)

  // Run sub macro 06 "us_spdcap" using the input files defined by subargs06
  sub06=RunMacro("us_spdcap",subargs06)

  // warn if sub macro is unsuccessful
  if sub06=null then do
	ShowMessage("us_spdcap macro failed")
	goto final
  end

   stat = UpdateProgressBar("Ramps", 50)

  // Run sub macro 07 "us_spdcap" using the input files defined by subargs07
  sub07=RunMacro("rmp_spdcap",subargs07)

  // warn if sub macro is unsuccessful
  if sub07=null then do
	ShowMessage("rmp_spdcap macro failed")
	goto final
  end


  //  Insert calls for additional sub macros here:

  // end submacro calls------------------------------------------------------------------------------------------------

  // After all calls for sub macros, wrap up the master macro here.

stat = UpdateProgressBar("Final Speeds and Daily Capacities", 80)

  // Fill the final "Free Flow Speed" field (FFS) to be used by the model with either estimated or observed speeds.
  llset = link_lyr+"|"
  arec = GetFirstRecord(llset,)
  while arec <> null do
        link_lyr.FFS = link_lyr.CalcSpeed
	arec = GetNextRecord(llset, null,)
  end

//  Calculate daily capacities based on hourly capacities and K Factor Table
  kfac_tab = OpenTable("K_factors", "FFB", {kfac_file,})
  vw2 = JoinViews("jv2",link_lyr+".[FClass]", kfac_tab+".FUNCT",)
	jset2="jv2|"

  vkfac = nz(GetDataVector(jset2, vw2+".K",  ))     //    get vectors from joined view
	ABvdlycap = nz(GetDataVector(jset2,vw2+".AB_HourlyCap", ))
	BAvdlycap = nz(GetDataVector(jset2,vw2+".BA_HourlyCap", ))
	vcon    = nz(GetDataVector(jset2,vw2+".IsConnector", ))
	ABdcap = if(vcon=0) then ABvdlycap/vkfac else ABvdlycap*10                              //	Calculate DlyCap = HrlyCap/K
	BAdcap = if(vcon=0) then BAvdlycap/vkfac else BAvdlycap*10                              //	Calculate DlyCap = HrlyCap/K
//        SetDataVector(jset2, "DlyCap", dcap, )            //    write to links
        SetDataVector(jset2, "AB_DailyCap", ABdcap, )            //    write to links
        SetDataVector(jset2, "BA_DailyCap", BAdcap, )            //    write to links

        closeview(kfac_tab)

// KDK code to calculate truck speeds - based on truck/auto ratios and diffs in WSA model
//    for out-of-state and centroid connectors, truck is the same as auto
//
// Also, to encourage use of the HIS Truck Network (TruckNet), these links are assigned the same speed as autos
//     kdk 3/22/2012      ********************************************************************
//
/*  New FClass System
    1  Interstate
    2  Other fwy xway
    3  Other Principal arterial
    4  Minor arterial
    5  Major collector
    6  Minor collector
    7  Local
*/
   // Use FClass-based differences from KYSTM model (converted to new FCLASS)
   tfac={1.33,11.17,3.67,3.00,1.83,1.83,1.00}
   SetView(link_lyr)
   for dex = 1 to 7 do
     qry = "Select * where (nz(IsConnector)=0 and In_Network=1 and [FClass]="+i2s(dex)+")"
     hlinks = SelectByQuery("kyurb", "Several", qry,)
     if(hlinks>0) then do
       vset = link_lyr+"|kyurb"
       v_es  = nz(GetDataVector(vset, "CalcSpeed",  ))
       v_tn  = nz(GetDataVector(vset, "TruckNet",  ))
       v_es  = if(v_tn=1) then v_es+0.0 else v_es - tfac[dex]
       SetDataVector(vset, "TRKSP", v_es,)
     end
   end
// Calculate travel times and transfer all data to Scenario records ...
   SetView(link_lyr)
   vset = link_lyr+"|"
   v_es  = nz(GetDataVector(vset, "FFS", ))
   v_tr  = nz(GetDataVector(vset, "TRKSP",  ))
   v_hcAB  = nz(GetDataVector(vset, "AB_HourlyCap",  ))
   v_hcBA  = nz(GetDataVector(vset, "BA_HourlyCap",  ))
   v_dcAB  = nz(GetDataVector(vset, "AB_DailyCap", ))
   v_dcBA  = nz(GetDataVector(vset, "BA_DailyCap", ))
   v_len = nz(GetDataVector(vset, "Length", ))

// $$$$$$$$$$$ Calibration Speed Adjustments $$$$$$$$$$$$$$$$$$$$
   v_fcl = nz(GetDataVector(vset, "FClass", ))
   v_hcl = nz(GetDataVector(vset, "HCMType", ))
   v_sig = nz(GetDataVector(vset, "Signal", ))
   v_es = if(v_sig=1) then v_es-5 else v_es            // subtract 5 mph from urban streets speeds because of signals
   v_tr = if(v_sig=1) then v_tr-5 else v_tr

// +++++++++++++++++++++++++++++++++++++++ Apply speed & capacity overrides here ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   v_ors  = nz(GetDataVector(vset, "[Speed_Override]", ))
   v_orcAB =  nz(GetDataVector(vset, "[AB_HourlyCap_Override]", ))
   v_orcBA =  nz(GetDataVector(vset, "[BA_HourlyCap_Override]", ))

   v_tr = if(nz(v_ors)>0) then v_ors*v_tr/v_es else v_tr
   v_es = if(nz(v_ors)>0) then v_ors else v_es

   v_dcAB = if(nz(v_orcAB)>0) then v_dcAB*v_orcAB/v_hcAB else v_dcAB
   v_dcBA = if(nz(v_orcBA)>0) then v_dcBA*v_orcBA/v_hcBA else v_dcBA
   v_hcAB = if(nz(v_orcAB)>0) then v_orcAB else v_hcAB
   v_hcBA = if(nz(v_orcBA)>0) then v_orcBA else v_hcBA

// +++++++++++++++++++++++++++++++++++++++++++++++++ end overrides ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   SetDataVector(vset, "[AutoSpeed]", v_es,)
   SetDataVector(vset, "[TruckSpeed]", v_tr,)

   SetDataVector(vset, "[AB_HourlyCap]", v_hcAB,)
   SetDataVector(vset, "[BA_HourlyCap]", v_hcBA,)
   SetDataVector(vset, "[AB_DailyCap]",  v_dcAB,)
   SetDataVector(vset, "[BA_DailyCap]",  v_dcBA,)

   v_at  = if(v_es>0) then 60*v_len/v_es else 0.0
   v_tt  = if(v_tr>0) then 60*v_len/v_tr else 0.0
   SetDataVector(vset, "[AutoTime]",  v_at,)
   SetDataVector(vset, "[TruckTime]",  v_tt,)
//
// SET CENTROID CONNECTOR SPEEDS AND TIME AT 15 mph and capacity at 10000 vph
   SetView(link_lyr)
   qry = "Select * where (IsConnector=1 and In_Network=1)"
   hlinks = SelectByQuery("Cencon", "Several", qry,)
   if(hlinks>0) then do
     vset = link_lyr+"|Cencon"
     v_at  = nz(GetDataVector(vset, "AutoTime",  ))
     v_tt  = nz(GetDataVector(vset, "TruckTime",  ))
     v_area= nz(GetDataVector(vset, "AREATYPE",  ))
     v_as  = Vector( hlinks, "Float", {{"Constant",15.0},{"Row Based","True"}})
     v_ts  = Vector( hlinks, "Float", {{"Constant",15.0},{"Row Based","True"}})
     v_as  = if(v_area=1) then 25.0 else v_as+0.0
     v_as  = if(v_area=4) then 10.0 else v_as+0.0
     v_ts  = v_as
     v_len = nz(GetDataVector(vset, "Length", ))
     v_at  = 60*v_len/v_as  //15
     v_tt  = 60*v_len/v_ts  //15

     v_hc  = Vector( hlinks, "Float", {{"Constant", 10000.0},{"Row Based","True"}})
     v_dc  = Vector( hlinks, "Float", {{"Constant",100000.0},{"Row Based","True"}})

     SetDataVector(vset, "AutoSpeed",  v_as,)
     SetDataVector(vset, "TruckSpeed", v_ts,)
     SetDataVector(vset, "AutoTime",   v_at,)
     SetDataVector(vset, "TruckTime",  v_tt,)
     SetDataVector(vset, "AB_HourlyCap",  v_hc,)
     SetDataVector(vset, "BA_HourlyCap",  v_hc,)
     SetDataVector(vset, "AB_DailyCap",   v_dc,)
     SetDataVector(vset, "BA_DailyCap",   v_dc,)

     SetDataVector(vset, "AB_AM_CAP", v_hc, )
     SetDataVector(vset, "BA_AM_CAP", v_hc, )
     SetDataVector(vset, "AB_MD_CAP", v_hc, )
     SetDataVector(vset, "BA_MD_CAP", v_hc, )
     SetDataVector(vset, "AB_PM_CAP", v_hc, )
     SetDataVector(vset, "BA_PM_CAP", v_hc, )
     SetDataVector(vset, "AB_NT_CAP", v_hc, )
     SetDataVector(vset, "BA_NT_CAP", v_hc, )


   end
//
// end kdk code

    RunMacro("CloseAllViews")
    DestroyProgressBar()
    return(1)

// Close  SpeedCap Macro-----------------------------------------------------------------------------------------------
  final:

  closeview(link_lyr)

  DestroyProgressBar()
  //showmessage("Macro SpeedCap is finished.")

    RunMacro("CloseAllViews")
    return(0)

endMacro       // End of Master Macro "SpeedCap"-----------------------------------------------------------------------

// HCM 2010 Methods (for link_lyr field "HCMType")

// HCMType  Method
// =======  ==================
//   1      Basic Freeway Segments
//   2      Freeway Facilities (Not used; reserved for future use)
//   3      Multilane Highways
//   4      Two-Lane Highways
//   5      Urban Streets
//   6      Ramps


// ============= SUB MACRO #1: FREE-FLOW SPEEDS FOR BASIC FREEWAY SEGMENTS ================
//   For HCMType=1 (Basic Freeway Segments), will compute an estimated free-flow speed "CalcSpeed"	

//   Defines the macro "fwy_spd" using input data defined by in_vals
     Macro "fwy_spd" (in_vals01)

 //     The link_lyr from the network.dbd and fwy_defaults.bin input files are passed from subargs01 via in_vals01
        {link_lyr,fwydef_file} = in_vals01

//      open defaults table fwy_defaults.bin
        fwy_tab = OpenTable("fwy_defaults", "FFB", {fwydef_file,})

//      join to links on the field AREATYPE
        vw1 = JoinViews("jv1",link_lyr+".[AreaType]", fwy_tab+".AREATYPE",)

//      select Basic Freeway Segments (HCMType=1) for In_Network=1 links
        SetView("jv1")
        qry = "Select * where (In_Network=1 and (HCMType=1 | HCMType=2))"      // 2 is inactive, but this traps the wrong assumption
        hlinks = SelectByQuery("fwys", "Several", qry,)
        jset="jv1|fwys"

//      get vectors from joined view Lane Width Adjustment, fLW, Lateral Clearance Adjustment, fLC, and Total Ramp Density, TRD
        vflw = nz(GetDataVector(jset, vw1+".fLW",  ))
        vflc = nz(GetDataVector(jset, vw1+".fLC",  ))
        vtrd = nz(GetDataVector(jset, vw1+".TRD",  ))
/*
        //vAT = nz(GetDataVector(jset, vw1+".[AreaType]",  ))
        vAT = nz(GetDataVector(jset, link_lyr+".[AreaType]",  ))
        LOAT = VectorStatistic(vAT, "Min", )

//      Error Trap for no AreaType    // EW HDR - this error trap was moved to earlier to match KYSTM better
        if(LOAT=0) then do
          ShowMessage("** Link Attribute Error fwysp ** : some link has no AreaType, correct Master Network and Re-run")
          return(null)
        end
*/
//      Calculate Free-Flow Speed Using HCM 2010 Method
//      FFS = 75.4 ?fLW ?fLC ?3.22*TRD^0.84
        vspd = -vflw -vflc + 75.4 -3.22*pow(vtrd,0.84)

//      write to links
        SetDataVector(jset, "CalcSpeed", vspd, )
        vsum1 = VectorStatistic(nz(vspd)<>0, "Count", )

//      cleanup
      	closeview(vw1)
      	closeview(fwy_tab)
        return(vsum1)

     endMacro


// ============== SUB MACRO #2: CAPACITIES FOR BASIC FREEWAY SEGMENTS ===============
     Macro "fwy_cap" (in_vals02)
//	Variables from subargs02 are passed to in_vals02
        {link_lyr,fwycap_file,kfac_file}=in_vals02

//      Open freeway lane capacity table
	fwy_capf = OpenTable("fwy_cap", "FFB", {fwycap_file,})


//      Select FREEWAY links from network and begin loop through link layer records
        qry = "Select * where (In_Network=1 and (HCMType=1 | HCMType=2))"      // 2 is inactive, but this traps the wrong assumption
        hlinks = SelectByQuery("fwys", "Several", qry,)
        vset = link_lyr+"|fwys"

        vsum2 = 0

        arec = GetFirstRecord(vset,)
             while arec <> null do
                				   HCM = nz(link_lyr.HCMType)
                           DIR = link_lyr.Dir
                           ABL = (link_lyr.[AB_Lanes])
                           BAL = (link_lyr.[BA_Lanes])

////                        Error Trap for lanes // EW HDR - these error traps were moved to earlier in the script to match KYSTM better
//                          if DIR > (-1) and ABL=0 then do
//                            lid  =link_lyr.ID
//                            ShowMessage("** Link Attribute Error fwycap ** : link "+i2s(lid)+" has null or 0 AB_Lanes, correct Master Network and Re-run")
//                            return(null)
//                          end
//                          if DIR < 1 and BAL=0 then do
//                            lid  =link_lyr.ID
//                            ShowMessage("** Link Attribute Error fwycap ** : link "+i2s(lid)+" has null or 0 AB_Lanes, correct Master Network and Re-run")
//                            return(null)
//                          end
//
//                        ERROR TRAP FOR LOW SPEEDS ON INTERSTATES
                          if ((HCM=1 or HCM=2) and (SL <50)) then do
                            lid =link_lyr.ID
                            link_lyr.[PostedSpeed] = 55
                            ShowMessage("** Link Attribute Warning: interstate/freeway link "+i2s(lid)+" has unusually low [SpeedLimit]. Default set to 55mph")
                          end

                   // Rounds FFS to nearest 5 mph and sets capactiy according to FFS (HCM 2010 Ch. 11)
                   fwyffs = link_lyr.CalcSpeed
                   fwyspdv= LocateRecord(fwy_capf+"|","Upper",{fwyffs},)
                   fwycapv= GetRecordValues(fwy_capf,fwyspdv,{"Capacity"})
                   link_lyr.AB_HourlyCap = fwycapv[1][2] * ABL
                   link_lyr.BA_HourlyCap = fwycapv[1][2] * BAL

                   vsum2 = vsum2 + fwycapv[1][2]

                   arec = GetNextRecord(vset, null,)
             end

//      cleanup
	closeview(fwy_capf)
	return(vsum2)

    endMacro


// ============ SUB MACRO #3: FREE-FLOW SPEEDS FOR MULTILANE HIGHWAYS ==============
    Macro "mh_spd" (in_vals03)

//	Variables from subargs03 are passed to in_vals03
	{link_lyr,mhflw_file,mhtlc_file,mhmed_file,mhacc_file}=in_vals03

//      Open all bin files to be used in this macro here:
        mhflw = OpenTable("mhflw","FFB",{mhflw_file,})

//      Search Total Lateral Clearance (TCL) table to determine maximum value
        mhtlc = OpenTable("mhtlc","FFB",{mhtlc_file,})
        neg = CreateExpression("mhtlc", "NegTLC", "TLC*(-1)", )
        Dim flctbl[7,3]
        i=1
        tlcr = GetFirstRecord(mhtlc+"|",)
    	     while tlcr <> null do
                   tlcrv = GetRecordValues(mhtlc,tlcr,{"TLC","fLC"})
                     for j = 1 to 2 do
                         flctbl[i][j] = tlcrv[j][2]
                     end
                     flctbl[i][3] = flctbl[i][1] * (-1)
                   i = i+1
                   tlcr = GetNextRecord(mhtlc+"|",null,)
             end
        mx_tlc= SortArray(flctbl,{,{"Ascending","False"}})
        max_val = mx_tlc[1][1]

//      Open all other bin files to be used during loop calculations
        mhflw = OpenTable("mhflw","FFB",{mhflw_file,})
	mhfm  = OpenTable("mhfm","FFB",{mhmed_file,})
	mhfa  = OpenTable("mhfa","FFB",{mhacc_file,})

//      Select MULTILANE HIGHWAY links from network and begin loop through link layer records
        qry = "Select * where (In_Network=1 and HCMType=3)"
        hlinks = SelectByQuery("mh", "Several", qry,)
        vset = link_lyr+"|mh"

	vsum3 = 0

        arec = GetFirstRecord(vset,)
	while arec <> null do

//          SL = nz(link_lyr.[SpeedLimit])
            SL = nz(link_lyr.[PostedSpeed])
            lw = nz(link_lyr.LANEWID)

            if link_lyr.MEDWID <> null
               then MDW = link_lyr.MEDWID
               else MDW = 6
            if link_lyr.MEDTYPE <> null
               then MT = link_lyr.MEDTYPE
               else MT = 8 // EW HDR - MT default set to 8 to match KYSTM
//               else MT = 7
//            if link_lyr.SHLDWID <> null
//               then SW = link_lyr.SHLDWID
//               else SW = 6

//   All shoulder attributes are taken from cardinal direction
           if link_lyr.CR_ShldWid <> null      //set outside shoulder width default to 6 feet if null
                 then SW = link_lyr.CR_ShldWid
                 else SW = 6
           if link_lyr.CL_ShldWid <> null      //set insider shoulder width default to 2 feet if null
                 then LSW = link_lyr.CL_ShldWid
                 else LSW = 2
           if MT <= 3 and LSW >= 2  // set median width at 6 feet if there is a positive median barrier and inside shoulder at least 2 feet
                 then MW = 6
                 else MW = MDW + LSW   // Total Left Clearance is width of left side shoulder + median width
           if MT = 8  // if undivided median, set MW to 6 feet as this is subject to a specific adjustment
                 then MW = 6

            at = nz(link_lyr.[AreaType])
/*
//          Error Trap for SL // EW HDR - moved earlier to match KYSTM better
            if(SL=0) then do
               lid  =link_lyr.ID
               ShowMessage("** Link Attribute Error mhsp ** : link "+i2s(lid)+" has null or 0 PostedSpeed, correct Master Network and Re-run")
               return(null)
            end
*/
//          Error Trap for lw
//            if(lw=0) then do
            if(lw<8) then do // EW HDR - updated to match default in KYSTM
               lw=12
            end

//          Error Trap for mt
            if(mt=0) then do
               lid  =link_lyr.ID
               ShowMessage("** Link Attribute Error mhsp ** : link "+i2s(lid)+" has null or 0 MEDTYPE, correct Master Network and Re-run")
               return(null)
            end
/*
//          Error Trap for at // EW HDR - moved earlier to better match KYSTM
            if(at=0) then do
               lid  =link_lyr.ID
               ShowMessage("** Link Attribute Error mhsp ** : link "+i2s(lid)+" has null or 0 AreaType, correct Master Network and Re-run")
               return(null)
            end
*/
//          Computes Base Free-Flow Speed (BFFS)
            if SL >= 50 then
               link_lyr.BFFS = SL + 5
            else link_lyr.BFFS = SL + 7
            bffs = link_lyr.BFFS

//          Computes Speed Reduction for Lane Width, fLW   (see HCM 2010 Ex. 14-8)
            lw_rec = LocateRecord(mhflw+"|","upper",{lw},)
            lwh    = GetRecordValues(mhflw,lw_rec,{"fLW"})
            flw    = lwh[1][2]

//          Computes Speed Reduction for Total Lateral Clearance, fLC (see 2010 HCM Ex. 14-9)
            tlc_val = Min(MW, 6) + Min(SW, 6)
            if tlc_val > max_val then tlc_val = max_val
            tlc_neg = tlc_val*(-1)
            tlc_uprh= LocateRecord(mhtlc+"|","TLC",{tlc_val},)
            upr= GetRecordValues(mhtlc,tlc_uprh,{"TLC","fLC"})
            tlc_lwrh= LocateRecord(mhtlc+"|","NegTLC",{tlc_neg},)
            if tlc_neg = 0 then tlc_lwrh = tlc_uprh
            lwr= GetRecordValues(mhtlc,tlc_lwrh,{"TLC","fLC"})

//          Interpolate and assign speed reduction for total lateral clearance
            x0 = lwr[1][2]  // TLC
            x1 = upr[1][2]
            y0 = lwr[2][2]  // fLC
            y1 = upr[2][2]
            if x0 = x1 then ratio = 1
            else ratio = (y1 - y0)/(x1 - x0)
            flc = y0 + ratio*(tlc_val - x0)

//          Assign Speed Reduction for Median Type  (see HCM 2010 Ex. 14-10)
            mt_rec = LocateRecord(mhfm+"|","MEDTYPE",{mt},)
            fmh    = GetRecordValues(mhfm,mt_rec,{"fM"})
            fm     = fmh[1][2]

//          Assign Speed Reduction for Access Point Density  (see HCM 2010 Ex. 14-11)
            at_rec = LocateRecord(mhfa+"|","AREATYPE",{at},)
            fah    = GetRecordValues(mhfa,at_rec,{"fA"})
            fa     = fah[1][2]

//          Estimate FFS = BFFS -fLW - fLC - fM -fA and assign to link layer
            mhspd = -flw -flc -fa -fm +bffs
            link_lyr.CalcSpeed = mhspd

            vsum3 = vsum3 + mhspd

            arec = GetNextRecord(vset, null,)
        end

        return(vsum3)

    endMacro

// ============== SUB MACRO #4: CAPACITIES FOR MULTILANE HIGHWAYS ===============
    Macro "mh_cap" (in_vals04)

//	Variables from subargs04 are passed to in_vals04
        {link_lyr,mhcap_file,kfac_file}=in_vals04

	mh_capf = OpenTable("mh_cap", "FFB", {mhcap_file,})


//      Select MULTILANE HIGHWAY links from network and begin loop through link layer records
		qry = "Select * where (In_Network=1 and HCMType=3)"
		hlinks = SelectByQuery("mlhwys", "Several", qry,)
		vset = link_lyr+"|mlhwys"

		vsum4 = 0

		arec = GetFirstRecord(vset,)
		       while arec <> null do
                           DIR = link_lyr.Dir
                           ABL = (link_lyr.[AB_Lanes])
                           BAL = (link_lyr.[BA_Lanes])
/*
//                        Error Trap for lanes
                          if DIR > (-1) and ABL=0 then do
                            lid  =link_lyr.ID
                            ShowMessage("** Link Attribute Error fwycap ** : link "+i2s(lid)+" has null or 0 AB_Lanes, correct Master Network and Re-run")
                            return(null)
                          end
                          if DIR < 1 and BAL=0 then do
                            lid  =link_lyr.ID
                            ShowMessage("** Link Attribute Error fwycap ** : link "+i2s(lid)+" has null or 0 AB_Lanes, correct Master Network and Re-run")
                            return(null)
                          end
*/
                           mhffs = link_lyr.CalcSpeed
                           mhspdv= LocateRecord(mh_capf+"|","Upper",{mhffs},)
                           testtt=1
                           mhcapv= GetRecordValues(mh_capf,mhspdv,{"Capacity"})
                           link_lyr.AB_HourlyCap = mhcapv[1][2] * ABL
                           link_lyr.BA_HourlyCap = mhcapv[1][2] * BAL

                           vsum4 = vsum4 + mhcapv[1][2]
				arec = GetNextRecord(vset, null,)
		        end

	return(vsum4)

    endMacro

// ============== SUB MACRO #5: SPEEDS AND CAPACITIES FOR TWO-LANE HIGHWAYS ===============

    Macro "tl_spdcap" (in_vals05)
//	Variables from subargs05 are passed to in_vals05
        {link_lyr,tlbffs_file,tllsw_file,tlacc_file}=in_vals05


//      Open all *.bin files to be used in this macro here:
	tl_bffs = OpenTable("tl_bffs", "FFB", {tlbffs_file,}) //base free flow speed table
	tlfls =   OpenTable("lswtbl","FFB",{tllsw_file,})     //speed reduction table for lane and shoulder width
	tlfa =    OpenTable("tlfa","FFB",{tlacc_file,})       //speed reduction table for access point density

        shwlabel = {"Under2", "Under4", "Under6", "Over6"}    //This array will be used to label speed reduction columns for various shoulder widths in the tlbffs_file

//      Select two-lane highway links from network and begin loop through link layer records
        qry = "Select * where (In_Network=1 and HCMType=4)"
        hlinks = SelectByQuery("tlhwys", "Several", qry,)
        vset = link_lyr+"|tlhwys"

        vsum5 = 0

        arec = GetFirstRecord(vset,)
             while arec <> null do

                           tlcl   = nz(link_lyr.TLCLASS)
                           if link_lyr.CR_ShldWid <> null
                              then tlhshw = link_lyr.CR_ShldWid
                              else tlhshw = 6
                           tllnw  = nz(link_lyr.LANEWID)
                           at     = nz(link_lyr.[AreaType])


//          Error Trap for lane Width
            if(tllnw=0) then do
               tllnw=11 // EW HDR - default changed to 11 to match KYSTM
//               tllnw=11
            end
            
/*      
//          Error Trap for at // EW HDR - moved earlier to match KYSTM better
            if(at=0) then do
               lid  =link_lyr.ID
               ShowMessage("** Link Attribute Error 2 ln sp** : link "+i2s(lid)+" has null or 0 AreaType, correct Master Network and Re-run")
               return(null)
            end
*/
//          Error Trap for tlcl
//            if(tlcl=0) then do
            if((tlcl=0) or (tlcl>7)) then do
               lid  =link_lyr.ID
               ShowMessage("** Link Attribute Error 2 ln sp** : link "+i2s(lid)+" has null or 0 or value over 7 Two-Lane Highway Class, correct Master Network and Re-run")
               return(null)
            end


//                         Identify Two-Lane Highway Class and Posted Speed Limit and assign Base Free Flow Speed
                           tlclv= LocateRecord(tl_bffs+"|","TLCLASS",{tlcl},)
                           bffadj= GetRecordValues(tl_bffs,tlclv,{"BFFSAdj"})
                           link_lyr.BFFS = bffadj[1][2] + link_lyr.[PostedSpeed]    //This is the base free flow speed

//                         Determine shoulder width classes and create labels
                           if      tlhshw < 2 then shwln = 1
                           else if tlhshw < 4 then shwln = 2
                           else if tlhshw < 6 then shwln = 3
                           else                    shwln = 4
                           shwlv = shwlabel[shwln]           // This label corresponds to shoulder width field IDs in table "tlfls"

//                         Determine Speed Reduction based on lane width and shoulder width   (see HCM 2010 Ex. 15-7)
                           tllnc = LocateRecord(tlfls+"|","Upper",{tllnw},)
                           tllnr = GetRecordValues(tlfls,tllnc,{shwlv})    // This is the speed reduction for lane and shoulder width
                           fls = tllnr[1][2]

//			   Determine Speed Reduction based on Access Point Density (see HCM 2010 Ex. 15-8)
                           at_rec = LocateRecord(tlfa+"|","AREATYPE",{at},)
                           fah    = GetRecordValues(tlfa,at_rec,{"fA"})
                           fa     = fah[1][2]

//			   Compute Estimated Free-Flow Speed FFS = BFFS - fLS - fA
                           bffs = link_lyr.BFFS
                           tlspd = -fls -fa + bffs
                           link_lyr.CalcSpeed = tlspd

                           vsum5 = vsum5 + fls

// 			   Compute link capacities
//                           link_lyr.HrCap = 1700
                           link_lyr.AB_HourlyCap = 1700
                           link_lyr.BA_HourlyCap = 1700

                           arec = GetNextRecord(vset, null,)
             end

        return(vsum5)

    endMacro

// ============== SUB MACRO #6: SPEEDS AND CAPACITIES FOR URBAN STREETS ===============

    Macro "us_spdcap" (in_vals06)
//	Variables from subargs06 are passed to in_vals06
        {link_lyr,usfcs_file,usso_file,usda_file,usfa_file,usfl_file,ussatflo_file,usflw_file,usat_file,usgc_file}=in_vals06

//      Open all *.bin files to be used in this macro here:

        us_so = OpenTable("us_so", "FFB", {usso_file,}) // speed constant lookup table as a function of speed limit

	us_fcs = OpenTable("us_fcs", "FFB", {usfcs_file,}) //speed adjustment based on cross-section lookup table
	curblabel = {"NoCurb","Curb"} //This array will be used to label "No Curb" and "Curb" columns for cross-section speed adjustment

        usda = OpenTable("usda","FFB",{usda_file},) //Default access point density lookup table based on FUNCT and AREATYPE

        atlabel = {,"AREATYPE0","AREATYPE1","AREATYPE2","AREATYPE4"}  //This array will be used to label AREATYPE columns for default access densities, Da

        usfa = OpenTable("usfa","FFB",{usfa_file},) //Speed reduction table based on access point density and number of lanes
        lnlabel = {"1LANE","2LANES","3LANES","4LANES"}
        negda = CreateExpression("usfa", "NegDa","Da*(-1)", )

        usfl = OpenTable("us_fl","FFB",{usfl_file},) //Speed reduction table based on average signal spacing

        ussatflo = OpenTable("us_satflo","FFB",{ussatflo_file},)

        usflw = OpenTable("usflw","FFB",{usflw_file},)
        
        usat = OpenTable("usat","FFB",{usat_file},)
        
        usgc = OpenTable("usgc","FFB",{usgc_file},)

//      Select urban street links from network and begin loop through link layer records
        qry = "Select * where (In_Network=1 and HCMType=5)"
        hlinks = SelectByQuery("urbnstrts", "Several", qry,)
        vset = link_lyr+"|urbnstrts"

        vsum6 = 0

        arec = GetFirstRecord(vset,)
             while arec <> null do

                           DIR = nz(link_lyr.[Dir])
                           spdlmt =    nz(link_lyr.[PostedSpeed])
                           if link_lyr.MEDTYPE <> null
                              then usmedtype = link_lyr.MEDWID
                              else usmedtype = 8
                         //
                           ABL = nz(link_lyr.[AB_Lanes])
                           BAL = nz(link_lyr.[BA_Lanes])
                           dirln = max(ABL,BAL)
                           fct =       nz(link_lyr.[FClass])
                           at     =    nz(link_lyr.[AreaType])
                           lw     =    nz(link_lyr.LANEWID)
                           
                           if nz(link_lyr.PCE_Override) > 1    // Set Truck PCE's
                              then et = link_lyr.PCE_Override
                              else et = 2.5

                          // revisit this later, but for now default to 5 percent
                           pcthv = 5
                          // pcthv  =    nz(link_lyr.TRUCK_PCT)
/*
//                        Error Trap for spdlmt // EW HDR - these error traps were moved earlier to better match KYSTM
                          if(spdlmt=0) then do
                             lid  =link_lyr.ID
                             ShowMessage("** Link Attribute Error urban ** : link "+i2s(lid)+" has null or 0 PostedSpeed, correct Master Network and Re-run")
                             return(null)
                          end
//                        Error Trap for lanes
                          if DIR > (-1) and ABL=0 then do
                            lid  =link_lyr.ID
                            ShowMessage("** Link Attribute Error fwycap ** : link "+i2s(lid)+" has null or 0 AB_Lanes, correct Master Network and Re-run")
                            return(null)
                          end
                          if DIR < 1 and BAL=0 then do
                            lid  =link_lyr.ID
                            ShowMessage("** Link Attribute Error fwycap ** : link "+i2s(lid)+" has null or 0 AB_Lanes, correct Master Network and Re-run")
                            return(null)
                          end
//                        Error Trap for fct
                          if(fct=0) then do
                             lid  =link_lyr.ID
                             ShowMessage("** Link Attribute Error urban ** : link "+i2s(lid)+" has null or 0 FClass, correct Master Network and Re-run")
                             return(null)
                          end
//                        Error Trap for at
                          if(at=0) then do
                             lid  =link_lyr.ID
                             ShowMessage("** Link Attribute Error urban ** : link "+i2s(lid)+" has null or 0 AreaType, correct Master Network and Re-run")
                             return(null)
                          end
//                        Error Trap for lw
                          if(lw=0) then do
                             lw=12
                          end
*/
//                         Determine speed limit and select corresponding speed constant, So

                           if spdlmt >55 then spdlmt = 55
                           spdlmtv = LocateRecord(us_so+"|","SPEEDLIM",{spdlmt},)
                           sov = GetRecordValues(us_so,spdlmtv,{"So"})
                           so = sov[1][2]

//                         Determine speed adjustment for cross-section based on median type (Restrictive, Non-Restrictive, None) and presence or absence of a curb
                           usshldtypeS = link_lyr.CR_ShldTyp
                           usshldtype =nz(usshldtypeS)
                           if      usshldtype <> 8 then usfcs = 1
                           else                         usfcs = 2
                           usfcsv = curblabel[usfcs]           // This label corresponds to No Curb and Curb columns in table "us_fcs"

                           csadjv = LocateRecord(us_fcs+"|","MEDTYPE",{medtype},)
                           fcsv = GetRecordValues(us_fcs,csadjv,{usfcsv})
                           fcs = fcsv[1][2]

//                         Create labels for array of default access densities, Da, as a function of FUNCT and AREATYPE
                           if      at = 0 then lnkat = 1
                           else if at = 1 then lnkat = 2
                           else if at = 2 then lnkat = 3
                           else                lnkat = 4
                           atv = atlabel[lnkat]           // This label corresponds to area type fields in table "us_sofcs"

//                         Determine default access point density based on FUNCT and AREATYPE
                           fctl = LocateRecord(usda+"|","FUNCT",{fct},)
                           fctlv = GetRecordValues(usda,fctl,{atv})
                           dav = fctlv[1][2]
                           if dav > 60 then dav = 60 //Sets maximum Da value at 60, per HCM 2010 Ex. 17-10

//                         Create labels for array of speed adjustment, fA, based on access density Da
                           if      dirln = 1 then fa = 1
                           else if dirln = 2 then fa = 2
                           else if dirln = 3 then fa = 3
                           else                   fa = 4
                           fav = lnlabel[fa]           // This label corresponds to directional number of lanes fields in table "usfa"

                           dav_neg = dav*(-1)
                           dav_uprh= LocateRecord(usfa+"|","Da",{dav},)
                           upr= GetRecordValues(usfa,da_uprh,{"Da",fav})
                           tlc_lwrh= LocateRecord(usfa+"|","NegDa",{dav_neg},)
                           if dav_neg = 0 then dav_lwrh = dav_uprh
                           lwr= GetRecordValues(usfa,da_lwrh,{"Da",fav})

//                         Interpolate and assign speed reduction for total lateral clearance
                             x0 = lwr[1][2]
                             x1 = upr[1][2]
                             y0 = lwr[2][2]
                             y1 = upr[2][2]
                             if x0 = x1 then ratio = 1
                             else ratio = (y1 - y0)/(x1 - x0)
                             fa = y0 + ratio*(dav - x0)

//                         Look up average signal spacing, Ls, from table "us_fl.bin"
                           fctls = LocateRecord(usfl+"|","FUNCT",{fct},)
                           fctflv = GetRecordValues(usfl,fctls,{"Ls"})
                           ls = fctflv[1][2]

//                         Compute Base Free Flow Speed, Sfo =  So + fCS + fA
                           sfo = so + fcs + fa
                           link_lyr.BFFS = sfo
//                         Also sets the Estimated Speed (CalcSpeed) to be the same as the Base Free Flow Speed; EstSpeed is used in the assignment process

//                         Compute signal spacing adjustment factor, fL
                           fl = 1.02 - 4.7*((sfo - 19.5)/ls)
                           if fl > 1.00 then fl = 0.99999

//                         Computes the Estimated Free-Flow Speed (Sf) as the BFFS * fL
                           link_lyr.CalcSpeed = sfo * fl

//			   Determine Base Saturation Flow Rate based on AREATYPE (AREATYPE 1-3: 1750; AREATYPE 4,5: 1900); source: 2010 HCM
                           at_rec = LocateRecord(ussatflo+"|","AREATYPE",{at},)
                           sat    = GetRecordValues(ussatflo,at_rec,{"BaseSatFlow"})
                           bsf     = sat[1][2]

//                         Computes Speed Reduction for Lane Width, fLW   (see HCM 2010 Ex. 18-13)
                           lw_rec = LocateRecord(usflw+"|","upper",{lw},)
                           lwh    = GetRecordValues(usflw,lw_rec,{"fLW"})
                           flw    = lwh[1][2]

//                         Compute Heavy Vehicle adjustment, fHV
                           fhv = 100/(100+pcthv*(et-1))

//                         Adjust saturation flow based on AREATYPE
                           at_rec = LocateRecord(usat+"|","AREATYPE",{at},)
                           far    = GetRecordValues(usat,at_rec,{"fA"})
                           fa     = far[1][2]

//                         Compute Adjusted Saturation Flow Rate
//                         Note: Saturatuion Flow Rate (asf) was adjusted only for lane width, heavy vehicles and AREATYPE in this macro.
//                         All other adjustment factors were defaulted to 1.0.
                           asf = bsf * flw * fhv * fa

//                         Determine default g/C ratio based on FUNCT from table "us_gc.bin"
                           fctgc = LocateRecord(usgc+"|","FUNCT",{fct},)
                           fctgcv = GetRecordValues(usgc,fctgc,{"gC"})
                           gc = fctgcv[1][2]

//                         Compute link through movement hourly capacity c = Ns(g/C)
                           link_lyr.AB_HourlyCap = ABL * asf * gc
                           link_lyr.BA_HourlyCap = BAL * asf * gc

         vsum6 = vsum6 + fl

                        arec = GetNextRecord(vset, null,)
            end

         return(vsum6)

    endMacro


// ============== SUB MACRO #7: SPEEDS AMD CAPACITIES FOR FREEWAY RAMPS ===============

//      For computing ramp speeds and capacities, the link_lyr.RAMP field is populated with 1 of 3 possible (numeric) values:
//          2 - Freeway-to-Freeway Connecting Ramp
//          21- Arterial-to-Freeway On-Ramp
//          22 - Freeway-to-Arterial Off-Ramp

    Macro "rmp_spdcap" (in_vals07)
//      Sets capacity for RAMP = 22 at 1,330; c = 2 approach lanes (LT, RT) x 1900 (satflow) x 0.35 (assumed equivalent g/C)
//      Assumes signal control at off-ramp terminal with arterial; STOP-controlled treated same as a signal
        capr22 = 1330

//	Variables from subargs07 are passed to in_vals07
        {link_lyr,ramp_file}=in_vals07

//      Open all *.bin files to be used in this macro here:
        rampcap = OpenTable("rampcap", "FFB", {ramp_file,}) //ramp per-lane capacities based on HCM2010 Ex. 13-10

//      Select ramp links from network and begin loop through link layer records
//      For Ramp analysis, link_lyr.HCMType = 6
        qry = "Select * where (In_Network=1 and HCMType=6)"
        hlinks = SelectByQuery("ramps", "Several", qry,)
        vset = link_lyr+"|ramps"

        vsum7 = 0

        arec = GetFirstRecord(vset,)
             while arec <> null do

        DIR = nz(link_lyr.[Dir])
        SL = nz(link_lyr.[PostedSpeed])
//      DL = nz(link_lyr.[Dir_Lanes])
        ABL = nz(link_lyr.[AB_Lanes])
        BAL = nz(link_lyr.[BA_Lanes])
        rv = nz(link_lyr.RAMP)
/*
// error trap // EW HDR - these error traps were moved earlier to better match KYSTM
        if(SL=0)  then do
          lid = link_lyr.ID
          ShowMessage("** Link Attribute Error ** LINKID="+i2s(lid)+" [PostedSpeed] is null or 0, correct Master Network and Re-run")
          return(null)
        end
        if DIR > (-1) and ABL=0 then do
          lid  =link_lyr.ID
          ShowMessage("** Link Attribute Error ** : link "+i2s(lid)+" has null or 0 AB_Lanes, correct Master Network and Re-run")
          return(null)
        end
        if DIR < 1 and BAL=0 then do
          lid  =link_lyr.ID
          ShowMessage("** Link Attribute Error ** : link "+i2s(lid)+" has null or 0 AB_Lanes, correct Master Network and Re-run")
          return(null)
        end

        if(rv=null)  then do  // EW HDR changed from rv=0 to rv=null
          lid = link_lyr.ID
          ShowMessage("** Link Attribute Error ** LINKID="+i2s(lid)+" RAMP is null or 0, correct Master Network and Re-run")
          return(null)
        end
*/
//      Sets the base free flow speed to be the ramp speed limit (link_lyr.[PostedSpeed] attribute)
        link_lyr.CalcSpeed = SL

//      Sets the ramp capacity at 1,330 pc/h for RAMP = 22
        if rv = 22 then capr = capr22

//      Computes ramp capacities for Ramp Type = 2, 21 (see HCM 2010 Ex. 13-10)
        else do  sfr     = link_lyr.CalcSpeed
                 sfr_rec = LocateRecord(rampcap+"|","upper",{sfr},)
                 cap    = GetRecordValues(rampcap,sfr_rec,{"PerLnCap"})
                 if DIR < 0 
                 then capr    = cap[1][2] * BAL
                 else capr    = cap[1][2] * ABL
        end

//        link_lyr.HrCap = capr
           link_lyr.AB_HourlyCap = capr
           link_lyr.BA_HourlyCap = capr
           
           if DIR = 1 then  link_lyr.BA_HourlyCap = 0
           if DIR = (-1) then  link_lyr.AB_HourlyCap = 0

        vsum7 = vsum7 + capr

        arec = GetNextRecord(vset, null,)

            end

         return(vsum7)

    endMacro




//==== VARIOUS UTILITY MACROS =========================================================================//
Macro "GetIZONES" (tazpoly)

// get highest internal TAZ

   {taz_in} = RunMacro("TCB Add DB Layers", tazpoly)
   SetLayer(taz_in)
   TAZvw=getview()
   qry = "Select * where ExSta=null or ExSta=0" // "Select * where nz(ID)<>null" // EW HDR changed to ExSta
//   qry = "Select * where EXT=null or EXT=0" // "Select * where nz(ID)<>null" 
   n = SelectByQuery("Internal", "Several", qry,)
   internal_v = GetDataVector(TAZvw+"|Internal", TAZvw+".ID",)     // ID Contains TAZ number
   zonesi = VectorStatistic(internal_v, "Max", )                   // max internal TAZ number
   zonesi = R2I(zonesi)
   return(zonesi)
 endMacro

macro "addfields" (in_value)
// This macro adds permanent fields to a table if they are not present
 fldnames = in_value[1]
 struct = GetTableStructure(in_value[2])
 viewflds = getFields(in_value[2],numeric)

 for i=1 to struct.length do
  struct[i]=struct[i]+{struct[i][1]}
 end

 for i=1 to fldnames.length do
    pos = ArrayPosition(viewflds[1],{fldnames[i]},)
    if pos = 0 then do
       newstr = newstr + {{fldnames[i],"Real", 10, 3,"false",null,null,null,null}}
       modtab = 1
    end
 end

 if modtab = 1 then do
  newstr = struct+newstr
  ModifyTable(in_value[2],newstr)
 end
endMacro

Macro "CloseAllViews"
  on error, notfound do
    Return()
  end
  vws = GetViewNames()
  if(vws.length>0) then do
    for i = 1 to vws.length do
        CloseView(vws[i])
    end
  end
endMacro

Macro "countlinks"  (netf)
    {node_lyr,} = RunMacro("TCB Add DB Layers", netf)
    flds     = {{"linkcnt","Integer"},{"intbuf","Integer"},{"empbuf","Real",12,4},{"hhbuf","Real",12,4},{"mixempintden","Real",12,4}}
    RunMacro("TCB Add View Fields",{node_lyr,flds})
// put number of links at each node on the node record (linkcnt)
    knt=0
    SetView(node_lyr)
    sset = node_lyr+"|"
    arec = GetFirstRecord(sset,null)
    while (arec <> null) do
         knt=knt+1
         id = RH2ID(arec)
         link_list = GetNodeLinks(id)  
         nnodes=link_list.length
         if(nnodes>1) then node_lyr.linkcnt = 1 else node_lyr.linkcnt = 0
         arec = GetNextRecord(sset,null,null)
    end
    //ShowMessage(i2s(knt)+" nodes")
endMacro

///Macro "mix"  (netf,tazpoly) /// EW HDR - This macro is not used by main script
///// calculate the mixed employment intersection density indicator used by the destination choice model
///// results are placed in both node and TAZ layers
///// this variable is used in the calcuation of the propensity to make intrazonal trips
///
///  {node_lyr,} = RunMacro("TCB Add DB Layers", netf)
///  SetLayer(node_lyr)
///  qry = "Select * where IsCentroid=1 & EXSTA<>1"    // centroids
///  n = SelectByQuery("Centroids", "Several", qry,)
///  censet=node_lyr+"|Centroids"
///  {oboro_in} = RunMacro("TCB Add DB Layers", tazpoly)
///
///  ColumnAggregate(censet, 0.5, node_lyr+"|", {{"intbuf", "Sum", "linkcnt", }}, null)
///  ColumnAggregate(censet, 0.5, oboro_in+"|",   {{"hhbuf",  "Sum", "House_Occ", }}, null)
///  ColumnAggregate(censet, 0.5, oboro_in+"|",   {{"empbuf", "Sum", "EMP_TOT", }}, null)
///  
///  v_int = GetDataVector(censet, "intbuf",{{"Sort Order",{{"DAVIESS_Zone","A"}}}})
///  v_hh  = GetDataVector(censet, "hhbuf",{{"Sort Order",{{"DAVIESS_Zone","A"}}}})
///  v_emp = nz(GetDataVector(censet, "empbuf",{{"Sort Order",{{"DAVIESS_Zone","A"}}}}))
///  a_int = VectorStatistic(v_int, "Mean", )
///  a_hh  = VectorStatistic(v_hh , "Mean", )
///  a_emp = VectorStatistic(v_emp, "Mean", )
///  ak= a_int/a_emp
///  bk= a_int/a_hh
///  v_numer=max(v_int*v_emp*ak * v_hh*bk,  0.0001)
///  v_denom=max(v_int + v_emp*ak + v_hh*bk,0.0001)
///  v_mix=nz(Log(v_numer/v_denom))
///  SetDataVector(censet, "mixempintden", v_mix,{{"Sort Order",{{"DAVIESS_Zone","A"}}}} )
///  SetDataVector(oboro_in+"|", "mixempintden", v_mix,{{"Sort Order",{{"ID","A"}}}} )  // make sure these vectors are the same length
///
///endMacro

Macro "IZ" (skimf,SkimField)
   ///////////////////////////////////////////////////////////////////
   // Intrazonal Travel Time & Distance
   ///////////////////////////////////////////////////////////////////
    Opts = null
    Opts.Input.[Matrix Currency] = {skimf,SkimField,"Origin" ,"Destination" }
    Opts.Global.Factor = 0.5
    Opts.Global.Neighbors = 3
    Opts.Global.Operation = 1
    Opts.Global.[Treat Missing] = 1
    ret_value = RunMacro("TCB Run Procedure", 1, "Intrazonal", Opts, &Ret)
    if !ret_value then do
        ShowMessage("Intrazonal time failed")
        goto quit
    end

    Opts.Input.[Matrix Currency] = {skimf,"Length (Skim)","Origin" ,"Destination" }
    ret_value = RunMacro("TCB Run Procedure", 1, "Intrazonal", Opts, &Ret)
    if !ret_value then do
        ShowMessage("Intrazonal length failed")
        goto quit
    end

    Opts.Input.[Matrix Currency] = {skimf,"Composite","Origin" ,"Destination" }
    ret_value = RunMacro("TCB Run Procedure", 1, "Intrazonal", Opts, &Ret)
    if !ret_value then do
        ShowMessage("Intrazonal Composite failed")
        goto quit
    end

    quit:
    return(ret_value)
endMacro

Macro "Add_TermT" (Args,skimf,SkimField)
   ///////////////////////////////////////////////////////////////////
   // Adding TermTs to FF travel time
   ///////////////////////////////////////////////////////////////////
   tazpoly  = Args.[TAZ Layer]
//   db_file=Args.[Highway Layer]
     mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR
//   {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", db_file)
   {node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file) // Changed to master network file EW HDR

   Field1 ={{"TermT","Integer"}}

   {taz_lyr} = RunMacro("TCB Add DB Layers", tazpoly)
   ret_value=RunMacro("TCB Add View Fields",{taz_lyr,Field1})

   tt = GetFirstRecord(taz_lyr+"|", )
     while tt <> null do

        taz_lyr.TermT = 0
        if taz_lyr.AreaType = 1 then taz_lyr.TermT = 1
        if taz_lyr.AreaType = 2 then taz_lyr.TermT = 2
        if taz_lyr.AreaType = 3 then taz_lyr.TermT = 2
        if taz_lyr.AreaType = 4 then taz_lyr.TermT = 3

      tt = GetNextRecord(taz_lyr+"|", null, )
     end

// join TAZ data to nodes
// get vector from node layer|Centroids
    vw2 = JoinViews("jv",node_lyr+".ID", taz_lyr+".ID",)
    
    SetView(vw2)
    qry = "Select * where IsCentroid=1"    // Centroids
    n = SelectByQuery("mycen", "Several", qry,)
    jset2=vw2+"|mycen"


    rowvec = GetdataVector(jset2,"TermT",{{"Sort Order", {{node_lyr+".ID", "Ascending"}}}})
    rowvec.rowbased=True
    colvec = rowvec
    colvec.columnbased=True
    matff = OpenMatrix(skimf, )

    mtt = CreateMatrixCurrency(matff,SkimField, , ,)
    mtt := mtt+rowvec+colvec

    mcc = CreateMatrixCurrency(matff,"Composite", , ,)
    mcc := mcc+rowvec+colvec

    if(matff=null| mtt=null| mcc=null) then ret_value=0
    CloseView(vw2)

    return(ret_value)
endMacro


// =============================================================================================================
//
// HIGHWAY EVALUATION *****************************************************************
Macro "XMLHEVAL"  (Args,prd,myselect)	


cfldx={"CNT_CMP", "AM_CNT","MD_CNT","PM_CNT","NT_CNT"}
vfldx={"Daily 2-way Vehs","Twoway_veh_AM","Twoway_veh_MD","Twoway_veh_PM","Twoway_veh_NT"}
pnam={"Daily","AM","MD","PM","NT"}

scen_data_dir=  idir

//db_file = Args.[Highway Layer]
  mn_file = odir+"\\Scn_network.dbd"  // Changed to scenario network EW HDR

//studyn ="DAVIESS MODEL 2010: "
studyn ="REGIONAL MODEL : "

place= model_name+"  "+scen_data_dir

//selectnam={"  5 Counties  ","  Daviess Only  "}
countycount = cnum.length
countycountstr = i2s(countycount)
selectnam={"   "+countycountstr+" Counties  ","  Selected County Only  "}		//EW HDR - changed to make name more generic and automatically determine the number of counties in the model

AppendToReportFile(0, studyn+place+selectnam[myselect]+"  "+pnam[prd]+"  "+GetDateAndTime(), {{"Section", "True"}})

// ++++++++++++++++++++++++++++++++
// Volume and count fields
cfld=cfldx[prd]
ffld=vfldx[prd]
// ++++++++++++++++++++++++++++++++

// Counties, alphabetically

// VMT RATIO
//{node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", db_file)
{node_lyr,link_lyr} = RunMacro("TCB Add DB Layers", mn_file)  // Changed to master network EW HDR
SetLayer(link_lyr)

 if(myselect=1) then do
    qry1 = "Select * where nz("+cfld+") >0 & (In_Network=1)"
 end
 else do
    qry1 = "Select * where nz("+cfld+") >0 & (In_Network=1) & (CO_NUMBER=63 or CO_NUMBER=100)"  // EW HDR - changed myselect to Laurel and Pulaski counties
 end
N = SelectByQuery("WithCounts", "Several", qry1,)
vs=link_lyr+"|WithCounts"
vlen   = GetDataVector(vs, "Length",  )
vcount = GetDataVector(vs, cfld,  )
vflow  = GetDataVector(vs, ffld,  )
vmtc=vlen*vcount
vmtf=vlen*vflow
C_VMT=VectorStatistic(vmtc, "Sum", )
F_VMT=VectorStatistic(vmtf, "Sum", )
R_VMT = F_VMT/C_VMT

//RMSE
vdiff=vcount-vflow
vdiff2=vdiff*vdiff
svdiff2=VectorStatistic(vdiff2, "Sum", )
RMSE=sqrt(svdiff2/N)
AVGC=VectorStatistic(vcount, "Mean", )
PRMSE=100*RMSE/AVGC

vs=link_lyr+"|"
vlen   = GetDataVector(vs, "Length",  )
vflow  = GetDataVector(vs, ffld,  )
vmtf=vlen*vflow
FA_VMT=VectorStatistic(vmtf, "Sum", )


AppendTableToReportFile({{{"Name", "Name"},  {"Percentage Width", 20}, {"Alignment", "Left"}},
                         {{"Name", "Value"}, {"Percentage Width", 50}, {"Alignment", "Left"}}},
   {{"Title", "SUMMARY METRICS "+pnam[prd]}})
AppendRowToReportFile({"COUNT VMT =",            Format(C_VMT, ",*0")}, )
AppendRowToReportFile({"FLOW VMT =",             Format(F_VMT, ",*0")}, )
AppendRowToReportFile({"FLOW VMT/COUNT VMT =",   Format(R_VMT, ",*0.000")}, )
AppendRowToReportFile({"%RSME =",                Format(PRMSE,"##0.00")}, )
AppendRowToReportFile({"FLOW VMT (all links) =", Format(FA_VMT, ",*0")}, )
AppendRowToReportFile({"Flow Field =", ffld}, )
AppendRowToReportFile({"Count Field =", cfld}, )

// RMSE BY VOLUME GROUP
   dim drange[13]
   drange[1]="55 plus"
   drange[2]="45 - 55"
   drange[3]="35 - 45"
   drange[4]="27 - 35"
   drange[5]="24 - 27"
   drange[6]="22 - 24"
   drange[7]="20 - 22"
   drange[8]="18 - 20"
   drange[9]="17 - 18"
   drange[10]="16 - 17"
   drange[11]="15 - 16"
   drange[12]="14 - 15"
   drange[13]="LT 14"
lim = {0,2000,5000,10000,20000,30000,40000,50000,60000,70000,80000,90000,100000,500000}
dim alim[14]
for i = 1 to 14 do
  alim[i]=i2s(lim[i])
end
// Header
AppendTableToReportFile({
   {{"Name", "Count Range"},   {"Percentage Width", 10}, {"Alignment", "Left"}},
   {{"Name", "% RMSE"},        {"Percentage Width", 10}, {"Alignment", "Right"}},
   {{"Name", "Desired Range"}, {"Percentage Width", 10}, {"Alignment", "Right"}},
   {{"Name", "Count VMT"},     {"Percentage Width", 10}, {"Alignment", "Right"}},
   {{"Name", "Flow VMT"},      {"Percentage Width", 10}, {"Alignment", "Right"}},
   {{"Name", "VMT Ratio"},     {"Percentage Width", 10}, {"Alignment", "Right"}},
   {{"Name", "Count"},         {"Percentage Width", 10}, {"Alignment", "Right"}},
   {{"Name", "Flow"},          {"Percentage Width", 10}, {"Alignment", "Right"}},
   {{"Name", "Count Ratio"},   {"Percentage Width", 10}, {"Alignment", "Right"}},
   {{"Name", "#Links"},        {"Percentage Width", 10}, {"Alignment", "Right"}}},
 {{"Title", "RMSE BY VOLUME GROUP"}})

for i = 1 to 13 do
  qry2 = "Select * where (nz("+cfld+") >0) & (nz("+cfld+") > " + alim[i] +
                    ") & (nz("+cfld+") <= " + alim[i+1] + ") & (In_Network=1)"
  N = SelectByQuery("WithCounts", "Several", qry2,)
  if(N>0) then do
    vs=link_lyr+"|WithCounts"
    vlen   = GetDataVector(vs, "Length",  )
    vcount = GetDataVector(vs, cfld,  )
    vflow  = GetDataVector(vs, ffld,  )
    vmtc=vlen*vcount
    vmtf=vlen*vflow
    C_VMT=VectorStatistic(vmtc, "Sum", )
    F_VMT=VectorStatistic(vmtf, "Sum", )
    R_VMT = F_VMT/C_VMT
    C_sum=VectorStatistic(vcount, "Sum", )
    F_sum=VectorStatistic(vflow,  "Sum", )
    R_c = F_sum/C_sum
    vdiff=vcount-vflow
    vdiff2=vdiff*vdiff
    svdiff2=VectorStatistic(vdiff2, "Sum", )
    RMSE=sqrt(svdiff2/N)
    AVGC=VectorStatistic(vcount, "Mean", )
    PRMSE=100*RMSE/AVGC
    AppendRowToReportFile({alim[i]+"-"+alim[i+1],
                           format(PRMSE,"##0.00"),
                           drange[i],
                           Format(C_VMT, ",*0"),
                           Format(F_VMT, ",*0"),
                           Format(R_VMT, ",*0.000"),
                           Format(C_sum, ",*0"),
                           Format(F_sum, ",*0"),
                           Format(R_c, ",*0.000"),
                           Format(N, ",*0")}, )
  end
end

// RMSE BY FACILITY TYPE

aft={1,2,3,4,5,6,7}

ftype={ "Interstate (1)",
        "Other fwy xway (2)",
        "Other Principal arterial (3)",
        "Minor arterial (4)",          
        "Major collector (5)",         
        "Minor collector (6)",         
        "Local (7)"
      }

// Header
AppendTableToReportFile({
   {{"Name", "Facility Type"}, {"Percentage Width", 12}, {"Alignment", "Left"}},
   {{"Name", "% RMSE"},        {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Count VMT"},     {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Flow VMT"},      {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "VMT Ratio"},     {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Count"},         {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Flow"},          {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Count Ratio"},   {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "#Links"},        {"Percentage Width", 11}, {"Alignment", "Right"}}},
 {{"Title", "RMSE BY FACILITY TYPE"}})
for i = 1 to ftype.length do
  qry2 = "Select * where (nz("+cfld+") >0) & ([FClass]= "+i2s(aft[i])+") & (In_Network=1)"
  N = SelectByQuery("WithCounts", "Several", qry2,)
  if(N>2) then do
    vs=link_lyr+"|WithCounts"
    vlen   = GetDataVector(vs, "Length",  )
    vcount = GetDataVector(vs, cfld,  )
    vflow  = GetDataVector(vs, ffld,  )
    vmtc=vlen*vcount
    vmtf=vlen*vflow
    C_VMT=VectorStatistic(vmtc, "Sum", )
    F_VMT=VectorStatistic(vmtf, "Sum", )
    R_VMT = F_VMT/C_VMT
    C_sum=VectorStatistic(vcount, "Sum", )
    F_sum=VectorStatistic(vflow,  "Sum", )
    R_c = F_sum/C_sum
    vdiff=vcount-vflow
    vdiff2=vdiff*vdiff
    svdiff2=VectorStatistic(vdiff2, "Sum", )
    RMSE=sqrt(svdiff2/N)
    AVGC=VectorStatistic(vcount, "Mean", )
    PRMSE=100*RMSE/AVGC
    AppendRowToReportFile({ftype[i],
                           format(PRMSE,"##0.00"),
                           Format(C_VMT, ",*0"),
                           Format(F_VMT, ",*0"),
                           Format(R_VMT, ",*0.000"),
                           Format(C_sum, ",*0"),
                           Format(F_sum, ",*0"),
                           Format(R_c, ",*0.000"),
                           Format(N, ",*0")}, )
  end
end

// RMSE BY AREA TYPE
dim fft[7]
for i = 1 to 7 do
  fft[i]=i2s(i)
end

atype={"Rural (1)","Town (2)","Suburban (3)","Second City (4)","Urban (5)"}
// Header
AppendTableToReportFile({
   {{"Name", "Area Type"},     {"Percentage Width", 12}, {"Alignment", "Left"}},
   {{"Name", "% RMSE"},        {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Count VMT"},     {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Flow VMT"},      {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "VMT Ratio"},     {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Count"},         {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Flow"},          {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Count Ratio"},   {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "#Links"},        {"Percentage Width", 11}, {"Alignment", "Right"}}},
 {{"Title", "RMSE BY AREA TYPE"}})
for i = 1 to 7 do
  qry2 = "Select * where (nz("+cfld+") >0) & ([AREATYPE]= "+fft[i]+") & (In_Network=1)"
  N = SelectByQuery("WithCounts", "Several", qry2,)
  if(N>2) then do
    vs=link_lyr+"|WithCounts"
    vlen   = GetDataVector(vs, "Length",  )
    vcount = GetDataVector(vs, cfld,  )
    vflow  = GetDataVector(vs, ffld,  )
    vmtc=vlen*vcount
    vmtf=vlen*vflow
    C_VMT=VectorStatistic(vmtc, "Sum", )
    F_VMT=VectorStatistic(vmtf, "Sum", )
    R_VMT = F_VMT/C_VMT
    C_sum=VectorStatistic(vcount, "Sum", )
    F_sum=VectorStatistic(vflow,  "Sum", )
    R_c = F_sum/C_sum
    vdiff=vcount-vflow
    vdiff2=vdiff*vdiff
    svdiff2=VectorStatistic(vdiff2, "Sum", )
    RMSE=sqrt(svdiff2/N)
    AVGC=VectorStatistic(vcount, "Mean", )
    PRMSE=100*RMSE/AVGC
    AppendRowToReportFile({atype[i],
                           format(PRMSE,"##0.00"),
                           Format(C_VMT, ",*0"),
                           Format(F_VMT, ",*0"),
                           Format(R_VMT, ",*0.000"),
                           Format(C_sum, ",*0"),
                           Format(F_sum, ",*0"),
                           Format(R_c, ",*0.000"),
                           Format(N, ",*0")}, )
  end
end

// RMSE BY County
// Header
if(myselect=1) then do  // ................................................. myselect
AppendTableToReportFile({
   {{"Name", "County"},     {"Percentage Width", 12}, {"Alignment", "Left"}},
   {{"Name", "% RMSE"},        {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Count VMT"},     {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Flow VMT"},      {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "VMT Ratio"},     {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Count"},         {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Flow"},          {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "Count Ratio"},   {"Percentage Width", 11}, {"Alignment", "Right"}},
   {{"Name", "#Links"},        {"Percentage Width", 11}, {"Alignment", "Right"}}},
 {{"Title", "RMSE BY County"}})
//for icc = 1 to 5 do //cname.length do
for icc = 1 to 12 do //cname.length do // EW HDR updated for LP number of TAZs
  i=cnum[icc]
  icnty = i2s(i)
  qry2 = "Select * where (nz("+cfld+") >0) & (CO_NUMBER = "+icnty+") & (In_Network=1)"
  N = SelectByQuery("WithCounts", "Several", qry2,)
  if(N>2) then do
    vs=link_lyr+"|WithCounts"
    vlen   = GetDataVector(vs, "Length",  )
    vcount = GetDataVector(vs, cfld,  )
    vflow  = GetDataVector(vs, ffld,  )
    vmtc=vlen*vcount
    vmtf=vlen*vflow
    C_VMT=VectorStatistic(vmtc, "Sum", )
    F_VMT=VectorStatistic(vmtf, "Sum", )
    R_VMT = F_VMT/C_VMT
    C_sum=VectorStatistic(vcount, "Sum", )
    F_sum=VectorStatistic(vflow,  "Sum", )
    R_c = F_sum/C_sum
    vdiff=vcount-vflow
    vdiff2=vdiff*vdiff
    svdiff2=VectorStatistic(vdiff2, "Sum", )
    RMSE=sqrt(svdiff2/N)
    AVGC=VectorStatistic(vcount, "Mean", )
    PRMSE=100*RMSE/AVGC
    AppendRowToReportFile({cname[icc],
                           format(PRMSE,"##0.00"),
                           Format(C_VMT, ",*0"),
                           Format(F_VMT, ",*0"),
                           Format(R_VMT, ",*0.000"),
                           Format(C_sum, ",*0"),
                           Format(F_sum, ",*0"),
                           Format(R_c, ",*0.000"),
                           Format(N, ",*0")}, )
  end
end

// Screenline tabulations
CloseReportFileSection()
//
AppendToReportFile(0, "SCREENLINE SUMMARIES: "+place+"  "+GetDateAndTime(), {{"Section", "True"}})


// ???????? Code and name screenlines ???????????????????????????????????????????????????????????
//scrnam = { "1-Regional Cordon",
//           "2-Daviess County Cordon",
//           "3-Owensboro US 60 ByPass Cutline",
//           "4-Audubon Pkwy",
//           "5-Parrish Ave Cutline",
//           "6-JR Miller Blvd Cutline",
//           "7-Owensboro-Hancock Co. US 60 Corridor",
//           "8-US 431 Cutline",
//           "9-Henderson Downtown Cordon"  }
scrnam = { "1-Regional Cordon",			//EW HDR - removed screenline names to make more generic
           "2",
           "3",
           "4",
           "5",
           "6",
           "7",
           "8",
           "9"  }
		   
for scl=1 to scrnam.length do // EW HDR changed from 20 to number of items in scrnam array
   N=0
   scls=i2s(scl)

   qryx = "Select * where  (Screenline = "+ scls +") & (In_Network=1)"
   N = SelectByQuery("ThisScrn", "Several", qryx,)
  if(nz(N)>0) then do
     sset = link_lyr+"|ThisScrn"
     sln=lpad(Format(scl,"00")+" ",4)
     AppendTableToReportFile({
        {{"Name", "Screenline"}, {"Percentage Width", 20}, {"Alignment", "Right"}},
        {{"Name", "LINK ID"},    {"Percentage Width", 20}, {"Alignment", "Right"}},
        {{"Name", "Volume"},     {"Percentage Width", 20}, {"Alignment", "Right"}},
        {{"Name", "Count"},      {"Percentage Width", 20}, {"Alignment", "Right"}},
        {{"Name", "Ratio"},      {"Percentage Width", 20}, {"Alignment", "Right"}}},
      {{"Title", " >> SCREENLINE: "+scrnam[scl]}})

     tcnt=0
     tvol=0

     arec = GetFirstRecord(sset,null)
     while (arec <> null) do
       idv=link_lyr.ID
       countv=nz(link_lyr.(cfld))
       volv=nz(link_lyr.(ffld))
       if((countv>0) & (volv>0)) then do
         tcnt=tcnt+countv
         tvol=tvol+volv
       end
       if(countv>0) then do
          rat=volv/countv
          rats=Format(rat, ",*0.00")
       end
       else rats="      --"
       if(countv>0) then AppendRowToReportFile({sln,
                              i2s(idv),
                              Format(volv,   ",*0"),
                              Format(countv, ",*0"),
                              rats}, )
       arec = GetNextRecord(sset,null,null)
     end
     if(tcnt>0) then do
        rat=tvol/tcnt
        rats=Format(rat, ",*0.00")
     end
     else rats="      --"
     AppendRowToReportFile({sln,
                            "Total"+sln,
                            Format(tvol, ",*0"),
                            Format(tcnt, ",*0"),
                            rats}, )
  end
end

CloseReportFileSection()
end // ................................................... myselect
//
endMacro

Macro "RPTTLFD" (Args) // calculate TLFD for Model Trip Tables
    dim pamf[4] // output trip tables

    pamf[1]=odir+"odam.mtx"
    pamf[2]=odir+"odmd.mtx"
    pamf[3]=odir+"odpm.mtx"
    pamf[4]=odir+"odnt.mtx"

    pnams={"AM","MD","PM","NT"}
    tcores={"HBW", "HBO", "NHB", "HBsc", "HBU","Light trk","Med trk","Heavy trk"}
    omat=Args.TLFD // all TLFD matrices

// STEP 1: TLD
     Opts = null
     Opts.Global.[Start Value] = 0
     Opts.Global.Size = 1
     Opts.Global.[Min Value] = 0
     Opts.Global.[Number of Bins] = 120
     Opts.Global.[Max Value] = 120
     Opts.Global.Method = 1
     Opts.Global.[End Option] = 1
     Opts.Global.[End Value] = 120
     Opts.Global.[Create Chart] = 1
     Opts.Global.[Statistics Option] = 1
     idex=0
for pur=1 to tcores.length do
  for prd=1 to pnams.length do
     idex=idex+1
     skimf=odir+"skim_"+pnams[prd]+".mtx"
     impC={skimf, "Time", "Origin", "Destination"}
     Opts.Input.[Base Currency] = {pamf[prd], tcores[pur],  ,  }  // trip tables
     Opts.Input.[Impedance Currency] = impC
     Opts.Output.[Output Matrix].[File Name] = odir+"TLFD_"+tcores[pur]+"_"+pnams[prd]+".mtx"
     Opts.Output.[Output Matrix].Label = "TLD_" + tcores[pur]+"_"+pnams[prd]
     ret_value = RunMacro("TCB Run Procedure", "TLD", Opts, &Ret)
     if !ret_value then goto quit
     // create summary matrix
     if(idex=1) then do
       m = OpenMatrix(odir+"TLFD_"+tcores[pur]+"_"+pnams[prd]+".mtx", )
       mc = CreateMatrixCurrency(m, "TLD", , , )
       new_mat = CopyMatrix(mc, {{"File Name", omat},
            {"Label", "TLFD"},
            {"File Based", "Yes"}})
       // call the first core by the correct name
       xpts = null
       xpts.Input.[Input Matrix] = omat
       xpts.Input.[Target Core] = "TLD"
       xpts.Input.[Core Name] = "TLD_" + tcores[pur]+"_"+pnams[prd]
       RunMacro("TCB Run Operation", "Rename Matrix Core", xpts)
     end
     else do
       // insert tables
       xpts = null
       xpts.Input.[Input Matrix] = omat
       xpts.Input.[New Core] = "TLD_" + tcores[pur]+"_"+pnams[prd]
       RunMacro("TCB Run Operation", "Add Matrix Core", xpts)
       m = OpenMatrix(odir+"TLFD_"+tcores[pur]+"_"+pnams[prd]+".mtx", )
       mc = CreateMatrixCurrency(m, "TLD", , , )
       m2 = OpenMatrix(omat, )
       mc2= CreateMatrixCurrency(m2, "TLD_" + tcores[pur]+"_"+pnams[prd], , , )
       mc2:=mc
       m=null
      
     end
//     DeleteFile(odir+"TLFD_"+tcores[pur]+"_"+pnams[prd]+".mtx")
  end
end

m2 =null
mc2=null
mc=null
m=null

for pur=1 to 7 do
  for prd=1 to pnams.length do
      DeleteFile(odir+"TLFD_"+tcores[pur]+"_"+pnams[prd]+".mtx")  // Delete individual TFD files - MB 
  end
end

pur=8
  for prd=1 to 3 do
      DeleteFile(odir+"TLFD_"+tcores[pur]+"_"+pnams[prd]+".mtx")
  end

thiscore=null // close EE Trip Table
return(1)             // success
    quit:
         Return(0)    // failure
endMacro


// ---- All macros below are not used by the Owensboro Model, but they may be useful for future data analysis ----

// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
//  -----------------  Utilities ONLY for Model Calibration ---------------------------------------------------------------
// &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Macro "TLFD"  // calculate TLFD for AirSage Trip Tables
    RunMacro("TCB Init")
    tcores={"DP1_HW_WD_AVG","DP2_HW_WD_AVG","DP3_HW_WD_AVG","DP4_HW_WD_AVG",
            "DP1_WH_WD_AVG","DP2_WH_WD_AVG","DP3_WH_WD_AVG","DP4_WH_WD_AVG",
            "DP1_WW_WD_AVG","DP2_WW_WD_AVG","DP3_WW_WD_AVG","DP4_WW_WD_AVG",
            "DP1_WO_WD_AVG","DP2_WO_WD_AVG","DP3_WO_WD_AVG","DP4_WO_WD_AVG",
            "DP1_OW_WD_AVG","DP2_OW_WD_AVG","DP3_OW_WD_AVG","DP4_OW_WD_AVG",
            "DP1_HO_WD_AVG","DP2_HO_WD_AVG","DP3_HO_WD_AVG","DP4_HO_WD_AVG",
            "DP1_HH_WD_AVG","DP2_HH_WD_AVG","DP3_HH_WD_AVG","DP4_HH_WD_AVG",
            "DP1_OH_WD_AVG","DP2_OH_WD_AVG","DP3_OH_WD_AVG","DP4_OH_WD_AVG",
            "DP1_OO_WD_AVG","DP2_OO_WD_AVG","DP3_OO_WD_AVG","DP4_OO_WD_AVG"
            }

// STEP 1: TLD
     Opts = null
     Opts.Input.[Impedance Currency] = {"C:\\LAMPO2012\\output\\skim.mtx", "Time", "Origin", "Destination"}
     Opts.Global.[Start Value] = 0
     Opts.Global.Size = 1
     Opts.Global.[Min Value] = 1
     Opts.Global.[Create Chart] = 1
     Opts.Output.[Output Matrix].Label = "TLD Output Matrix"
for k=1 to tcores.length do
     Opts.Input.[Base Currency] = {"D:\\LAMPO2012\\Work\\AirSage\\ALL.mtx", tcores[k], "Rows", "Columns"}
     Opts.Output.[Output Matrix].[File Name] = "D:\\LAMPO2012\\Work\\AirSage\\"+tcores[k]+".mtx"
     ret_value = RunMacro("TCB Run Procedure", "TLD", Opts, &Ret)
     if !ret_value then goto quit
end

    quit:
         Return( RunMacro("TCB Closing", ret_value, True ) )
endMacro

/* old - not used
Macro "combine"  // agrregate AirSage trips by TOD to Daily
    tcores={{"DP1_HW_WD_AVG","DP2_HW_WD_AVG","DP3_HW_WD_AVG","DP4_HW_WD_AVG"},
            {"DP1_WH_WD_AVG","DP2_WH_WD_AVG","DP3_WH_WD_AVG","DP4_WH_WD_AVG"},
            {"DP1_WW_WD_AVG","DP2_WW_WD_AVG","DP3_WW_WD_AVG","DP4_WW_WD_AVG"},
            {"DP1_WO_WD_AVG","DP2_WO_WD_AVG","DP3_WO_WD_AVG","DP4_WO_WD_AVG"},
            {"DP1_OW_WD_AVG","DP2_OW_WD_AVG","DP3_OW_WD_AVG","DP4_OW_WD_AVG"},
            {"DP1_HO_WD_AVG","DP2_HO_WD_AVG","DP3_HO_WD_AVG","DP4_HO_WD_AVG"},
            {"DP1_HH_WD_AVG","DP2_HH_WD_AVG","DP3_HH_WD_AVG","DP4_HH_WD_AVG"},
            {"DP1_OH_WD_AVG","DP2_OH_WD_AVG","DP3_OH_WD_AVG","DP4_OH_WD_AVG"},
            {"DP1_OO_WD_AVG","DP2_OO_WD_AVG","DP3_OO_WD_AVG","DP4_OO_WD_AVG"}
            }
    dcores={"HW","WH","WW","WO","OW","HO","HH","OH","OO"}
    dim imat[9,4],omat[9]

     m = OpenMatrix("D:\\LAMPO2012\\Work\\AirSage\\all.mtx", )

     for i=1 to 9 do
        AddMatrixCore(m, dcores[i])
        m1 = CreateMatrixCurrency(m, tcores[i][1], , , )
        m2 = CreateMatrixCurrency(m, tcores[i][2], , , )
        m3 = CreateMatrixCurrency(m, tcores[i][3], , , )
        m4 = CreateMatrixCurrency(m, tcores[i][4], , , )
        mo = CreateMatrixCurrency(m, dcores[i]   , , , )
        mo:=m1+m2+m3+m4
     end
endMacro

Macro "purp3"  // aggregate AirSage Trip Tables to 3 purposes, transposing "to Home" trips
    dcores={"HW","WH","WW","WO","OW","HO","HH","OH","OO"}
    trc   ={"WH","OH"}
    dim cc[9]

    m = OpenMatrix("D:\\LAMPO2012\\Work\\AirSage\\all.mtx", )
    //AddMatrixCore(m, "HBW")
    //AddMatrixCore(m, "HBO")
    //AddMatrixCore(m, "NHB")
    mHBW = CreateMatrixCurrency(m, "HBW", , , )
    mHBO = CreateMatrixCurrency(m, "HBO", , , )
    mNHB = CreateMatrixCurrency(m, "NHB", , , )

    WHtrH = TransposeMatrix(m, {{"File Name", "D:\\LAMPO2012\\Work\\AirSage\\transposed.mtx"}, {"Label", "transposed"}, , , ,  })
    mWHtr = CreateMatrixCurrency(WHtrH, "WH", , , )
    mOHtr = CreateMatrixCurrency(WHtrH, "OH", , , )

    for i=1 to 9 do
       cc[i] = CreateMatrixCurrency(m, dcores[i], , , )
    end

    mHBW:=cc[1]+mWHtr
    mHBO:=cc[6]+cc[7]+mOHtr
    mNHB:=cc[9]+cc[5]+cc[4]+cc[3]


endMacro
*/
///Macro "purp9t4"  // aggregate AirSage Trip Tables to 9 purposes and 4 time periods: AM, MD, PM NT			/// EW HDR - this macro is not used by the main script
///  // create empty output matrix
///  ifnam="D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\DAVIESS_AirSage.mtx"
///  ofnam="D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\DAVIESS_AirSage_OD9x4.mtx"
///  m = OpenMatrix(ifnam, )
///  mALL = CreateMatrixCurrency(m, "ALL", , , )
///  omh=CopyMatrixStructure({mALL}, {{"File Name", ofnam}, , ,  {"Tables", {"ALL"}},{"Compression", 1} })
///  // populate total O-D trip matrix
///  mALL1 = CreateMatrixCurrency(omh, "ALL", , , )
///  mALL1:=nz(mALL)
///
///  p9={"HW","WH","WW","WO","OW","HO","HH","OH","OO","WH","OH"}
///  t5={"AM","MD","PM","EV","EA"}
///  t4={"AM","MD","PM","NT"}
///  for p=1 to 9 do
///    for t=1 to 5 do
///      acore45=p9[p]+"_"+t5[t]
///      mci = CreateMatrixCurrency(m, acore45 , , , )
///      if(t<5) then do
///        tt=t
///        acore36=p9[p]+"_"+t4[tt]
///        AddMatrixCore(omh, acore36)
///        mco = CreateMatrixCurrency(omh, acore36 , , , )
///        mco:=nz(mci)
///      end
///      else do
///        mco:=mco + nz(mci)
///      end
///    end
///  end
///endMacro


///Macro "purp3t4"  // aggregate AirSage Trip Tables to 3 purposes and 4 time periods: AM, MD, PM NT, in the P-A Direction		///EW HDR - This macro is not used by the main script
///  // create empty output matrix
///  ifnam="D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\DAVIESS_AirSage_OD9x4.mtx"
///  tfnam="D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\transposed.mtx"
///  ofnam="D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\DAVIESS_AirSage_PA3x4.mtx"
///  m = OpenMatrix(ifnam, )
///  mALL = CreateMatrixCurrency(m, "ALL", , , )
///  omh=CopyMatrixStructure({mALL}, {{"File Name", ofnam}, , ,  {"Tables", {"ALL"}},{"Compression", 1} })
///  mALL1 = CreateMatrixCurrency(omh, "ALL", , , )
///  // transpose input matrix
///  mt = TransposeMatrix(m, {{"File Name", tfnam}, {"Label", "transposed"}, , , ,  })
///
///    dcores={"HW","WH","WW","WO","OW","HO","HH","OH","OO"}
///    pa    ={  1,   0,   1,   1,   1,   1,   1,   0,   1 }
///    po    ={  1,   1,   3,   3,   3,   2,   2,   2,   3 }
///    ocores={"HBW","HBO","NHB"}
///    t5={"AM","MD","PM","NT","Day"}
///    dim cnam[3,5],omc[3,5]
///
///  // create output cores & currencies
///  for p=1 to 3 do
///    for t=1 to 5 do
///      cnam[p][t]=ocores[p]+"_"+t5[t]
///      AddMatrixCore(omh, cnam[p][t])
///      omc[p][t] = CreateMatrixCurrency(omh, cnam[p][t], , , )
///    end
///  end
///  
///  //process input matrices
///  for p=1 to 9 do
///    op=po[p]
///    for t=1 to 4 do
///      icnam=dcores[p]+"_"+t5[t]
///      if(pa[p]=1) then icore=CreateMatrixCurrency(m, icnam, , , )
///      else icore=CreateMatrixCurrency(mt, icnam, , , )
///      omc[op][t]:=nz(omc[op][t])+nz(icore)
///      omc[op][5]:=nz(omc[op][5])+nz(icore)
///      mALL1:=nz(mALL1)+nz(icore)
///    end
///  end
///endMacro

///Macro "TLFD2"  // calculate TLFD for AirSage Trip Tables		//EW HDR - this macro is not used by the script
///    RunMacro("TCB Init")
///    ocores={"HBW","HBO","NHB"}
///    t5={"AM","MD","PM","NT","Day"}
///
///  tcores={"ALL"}
///  for p=1 to 3 do
///    for t=1 to 5 do
///      cnam=ocores[p]+"_"+t5[t]
///      tcores=tcores+{cnam}
///    end
///  end
///
///
///// STEP 1: TLD- pk times
///     Opts = null
///     Opts.Input.[Impedance Currency] = {"D:\\LAMPO2012\\output\\skim_AM.mtx", "Time", "Origin", "Destination"}
///     Opts.Global.[Start Value] = 0
///     Opts.Global.Size = 1
///     Opts.Global.[Min Value] = 1
///     Opts.Global.[Create Chart] = 1
///     Opts.Output.[Output Matrix].Label = "TLD Output Matrix"
///for k=1 to tcores.length do
///     Opts.Input.[Base Currency] = {"D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\DAVIESS_AirSage_PA3x4.mtx", tcores[k], "Rows", "Columns"}
///     Opts.Output.[Output Matrix].[File Name] = "D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\pktime_"+tcores[k]+".mtx"
///     ret_value = RunMacro("TCB Run Procedure", "TLD", Opts, &Ret)
///     if !ret_value then goto quit
///end
///
///
///// STEP 1: TLD- pk distance
///     Opts = null
///     Opts.Input.[Impedance Currency] = {"D:\\LAMPO2012\\output\\skim_AM.mtx", "Length (Skim)", "Origin", "Destination"}
///     Opts.Global.[Start Value] = 0
///     Opts.Global.Size = 1
///     Opts.Global.[Min Value] = 1
///     Opts.Global.[Create Chart] = 1
///     Opts.Output.[Output Matrix].Label = "TLD Output Matrix"
///for k=1 to tcores.length do
///     Opts.Input.[Base Currency] = {"D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\DAVIESS_AirSage_OD3x4.mtx", tcores[k], "Rows", "Columns"}
///     Opts.Output.[Output Matrix].[File Name] = "D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\miles_"+tcores[k]+".mtx"
///     ret_value = RunMacro("TCB Run Procedure", "TLD", Opts, &Ret)
///     if !ret_value then goto quit
///end
///
///    quit:
///         Return( RunMacro("TCB Closing", ret_value, True ) )
///endMacro



///Macro "gmcal"       // calibrate GM's using both gammas and FF methods		///EW HDR - This macro is not used by the main script
///    RunMacro("TCB Init")
///    amskf="D:\\LAMPO2012\\output\\skim_AM.mtx"     // USE FOR PEAK
///    pmskf="D:\\LAMPO2012\\output\\skim_PM.mtx"
///    mdskf="D:\\LAMPO2012\\output\\skim_MD.mtx"     // USE FOR OFF-PEAK
///    ntskf="D:\\LAMPO2012\\output\\skim_NT.mtx"
///    ttabf="D:\\4079 KYTC LAMPO\\Model Data\\Airsage 5-28-2013\\Lexington_OD_Matrix\\DAVIESS_AirSage_OD3x4.mtx"
///    
///    //generate pk and op ff's !!!!!!!!!!!!!!!!!! <<<<<<<<<<<<<<<<<<<___________________________
///
///// STEP 1: Gravity Calibration
///     Opts = null
///     Opts.Input.[Impedance Matrix Currency] = {"D:\\LAMPO2012\\output\\skim.mtx", "Composite", "Origin", "Destination"}
///     Opts.Global.[TLD Maximum] = 100
///     Opts.Global.[Gravity Iterations] = 100
///     Opts.Global.[Gravity Convergence] = 0.01
///     Opts.Global.[Calibration Iterations] = 400
///     Opts.Global.[Calibration Convergence] = 0.0001
///
///     // HBW
///     Opts.Global.[Constraint Type] = "Doubly"
///     Opts.Input.[Base Matrix Currency] = {"D:\\LAMPO2012\\Work\\AirSage\\ALL.mtx", "HBW", "Rows", "Columns"}
///     Opts.Global.[Impedance Method] = "Friction Factor"
///     Opts.Output.[FF Table] = "D:\\LAMPO2012\\Work\\AirSage\\GMCAL\\ffactorHBW.bin"
///     Opts.Output.[Summary Table] = "D:\\LAMPO2012\\Work\\AirSage\\GMCAL\\dummy.bin"
///     ret_value = RunMacro("TCB Run Procedure", "Gravity Calibration", Opts, &Ret)
///     if !ret_value then goto quit
///
///     Opts.Global.[Impedance Method] = "Gamma"
///     Opts.Output.[Summary Table] = "D:\\LAMPO2012\\Work\\AirSage\\GMCAL\\HBWsummaryGamma.bin"
///     ret_value = RunMacro("TCB Run Procedure", "Gravity Calibration", Opts, &Ret)
///     if !ret_value then goto quit
///
///     // HBO
///     Opts.Global.[Constraint Type] = "Production"
///     Opts.Input.[Base Matrix Currency] = {"D:\\LAMPO2012\\Work\\AirSage\\ALL.mtx", "HBO", "Rows", "Columns"}
///     Opts.Global.[Impedance Method] = "Friction Factor"
///     Opts.Output.[FF Table] = "D:\\LAMPO2012\\Work\\AirSage\\GMCAL\\ffactorHBO.bin"
///     Opts.Output.[Summary Table] = "D:\\LAMPO2012\\Work\\AirSage\\GMCAL\\dummy.bin"
///     ret_value = RunMacro("TCB Run Procedure", "Gravity Calibration", Opts, &Ret)
///     if !ret_value then goto quit
///
///     Opts.Global.[Impedance Method] = "Gamma"
///     Opts.Output.[Summary Table] = "D:\\LAMPO2012\\Work\\AirSage\\GMCAL\\HBOsummaryGamma.bin"
///     ret_value = RunMacro("TCB Run Procedure", "Gravity Calibration", Opts, &Ret)
///     if !ret_value then goto quit
///
///     // NHB
///     Opts.Global.[Constraint Type] = "Production"
///     Opts.Input.[Base Matrix Currency] = {"D:\\LAMPO2012\\Work\\AirSage\\ALL.mtx", "NHB", "Rows", "Columns"}
///     Opts.Global.[Impedance Method] = "Friction Factor"
///     Opts.Output.[FF Table] = "D:\\LAMPO2012\\Work\\AirSage\\GMCAL\\ffactorNHB.bin"
///     Opts.Output.[Summary Table] = "D:\\LAMPO2012\\Work\\AirSage\\GMCAL\\dummy.bin"
///     ret_value = RunMacro("TCB Run Procedure", "Gravity Calibration", Opts, &Ret)
///     if !ret_value then goto quit
///
///     Opts.Global.[Impedance Method] = "Gamma"
///     Opts.Output.[Summary Table] = "D:\\LAMPO2012\\Work\\AirSage\\GMCAL\\NHBsummaryGamma.bin"
///     ret_value = RunMacro("TCB Run Procedure", "Gravity Calibration", Opts, &Ret)
///     if !ret_value then goto quit
///
///    quit:
///         Return( RunMacro("TCB Closing", ret_value, True ) )
///endMacro
