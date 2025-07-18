<CODEGEN_FILENAME>SelfHostEnvironment.dbl</CODEGEN_FILENAME>
<REQUIRES_CODEGEN_VERSION>5.4.6</REQUIRES_CODEGEN_VERSION>
<REQUIRES_USERTOKEN>DATA_FOLDER</REQUIRES_USERTOKEN>
<REQUIRES_USERTOKEN>SERVICES_NAMESPACE</REQUIRES_USERTOKEN>
<REQUIRES_USERTOKEN>MODELS_NAMESPACE</REQUIRES_USERTOKEN>
;//****************************************************************************
;//
;// Title:       ODataSelfHostEnvironment.tpl
;//
;// Type:        CodeGen Template
;//
;// Description: Generates an environment setup class for a self host program
;//
;// Copyright (c) 2018, Synergex International, Inc. All rights reserved.
;//
;// Redistribution and use in source and binary forms, with or without
;// modification, are permitted provided that the following conditions are met:
;//
;// * Redistributions of source code must retain the above copyright notice,
;//   this list of conditions and the following disclaimer.
;//
;// * Redistributions in binary form must reproduce the above copyright notice,
;//   this list of conditions and the following disclaimer in the documentation
;//   and/or other materials provided with the distribution.
;//
;// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;// POSSIBILITY OF SUCH DAMAGE.
;//
;;*****************************************************************************
;;
;; Title:       SelfHostEnvironment.dbl
;;
;; Description: Environment setup class for a Harmony Core self host program
;;
;;*****************************************************************************
;; WARNING: GENERATED CODE!
;; This file was generated by CodeGen. Avoid editing the file if possible.
;; Any changes you make will be lost of the file is re-generated.
;;*****************************************************************************

import Microsoft.AspNetCore
import Microsoft.AspNetCore.Hosting
import System.Collections.Generic
import System.IO
import System.Text
import <SERVICES_NAMESPACE>
import <MODELS_NAMESPACE>

namespace <NAMESPACE>

    public partial static class SelfHostEnvironment

        ;;Declare the InitializeCustom partial method
        ;;This method can be implemented in a partial class to provide custom code to initialize the self hosting environment
        partial static method InitializeCustom, void

        endmethod

        public static method Initialize, void

        proc
<IF NOT DEFINED_EF_PROVIDER_MYSQL>
            ;;Allows select to join when the keys in the file are not the same type as the keys in the code
            data status, int
            xcall setlog("SYNSEL_NUMALPHA_KEYS", 1, status) 

            ;;Configure the test environment (set logicals, create files in a known state, etc.)
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance)
            setLogicals()
  <IF DEFINED_ENABLE_CREATE_TEST_FILES>
            deleteFiles()
            createFiles()

  </IF>
</IF>
            ;;If we have an InitializeCustom method, call it
            InitializeCustom()

        endmethod

        ;;Declare the CleanupCustom partial method
        ;;This method can be implemented in a partial class to provide custom code to cleanup the self hosting environment before close
        partial static method CleanupCustom, void

        endmethod

        public static method Cleanup, void

        proc
<IF NOT DEFINED_EF_PROVIDER_MYSQL AND DEFINED_ENABLE_CREATE_TEST_FILES>
            ;;Delete the data files
            deleteFiles()

</IF>
            ;;If we have a CleanupCustom method, call it
            CleanupCustom()

        endmethod

<IF NOT DEFINED_EF_PROVIDER_MYSQL>
        ;;Declare the SetLogicalsCustom partial method
        ;;This method can be implemented in a partial class to provide custom code to define logical names
        partial static method SetLogicalsCustom, void
            required in logicals, @List<string>
        endmethod

        private static method setLogicals, void
        proc
            data sampleDataFolder = findRelativeFolderForAssembly("<DATA_FOLDER>")
            Startup.LogicalNames = new List<string>()
            data logical = String.Empty
            data fileSpec = String.Empty
  <STRUCTURE_LOOP>

            fileSpec = "<FILE_NAME>"
            if (fileSpec.Contains(":")) then
            begin
                logical = fileSpec.Split(":")[1].ToUpper()
                if (!Startup.LogicalNames.Contains(logical))
                    Startup.LogicalNames.Add(logical)
            end
            else if (!fileSpec.Contains("."))
            begin
                if (!Startup.LogicalNames.Contains(fileSpec))
                    Startup.LogicalNames.Add(fileSpec)
            end
  </STRUCTURE_LOOP>

            ;;If we have a SetLogicalsCustom method, call it
            SetLogicalsCustom(Startup.LogicalNames)

  <IF NOT DEFINED_DO_NOT_SET_FILE_LOGICALS>
            ;;Now we'll check each logical. If it already has a value we'll do nothing, otherwise
            ;;we'll set the logical to point to the local folder whose name is identified by the
            ;;user-defined token DATA_FOLDER
            foreach logical in Startup.LogicalNames
            begin
                data sts, int
                data translation, a80
                ;;Is it set?
                xcall getlog(logical,translation,sts)
                if (!sts)
                begin
                    ;;No, we'll set it to <DATA_FOLDER>
                    xcall setlog(logical,sampleDataFolder,sts)
                end
            end

  </IF>
        endmethod

  <IF DEFINED_ENABLE_CREATE_TEST_FILES>
        private static method createFiles, void
        proc
            data chout, int
            data dataFile, string
            data xdlFile, string

    <STRUCTURE_LOOP>
      <IF STRUCTURE_ISAM>
            data <structurePlural> = load<StructurePlural>()
      </IF>
    </STRUCTURE_LOOP>

    <STRUCTURE_LOOP>
            ;;Create and load the <structurePlural> file

            dataFile = "<FILE_NAME>"
      <IF STRUCTURE_ISAM>
            xdlFile = "@" + dataFile.ToLower().Replace(".ism",".xdl")

            data <structureNoplural>, @<StructureNoplural>
            open(chout=0,o:i,dataFile,FDL:xdlFile)
            foreach <structureNoplural> in <structurePlural>
                store(chout,<structureNoplural>.SynergyRecord)
            close chout

      </IF>
      <IF STRUCTURE_RELATIVE>
            data sourceFile = dataFile.ToLower().Replace(".ddf",".txt")
            xcall copy(sourceFile,dataFile,1)

      </IF>
    </STRUCTURE_LOOP>
        endmethod

        private static method deleteFiles, void
        proc
    <STRUCTURE_LOOP>
            ;;Delete the <structurePlural> file
            try
            begin
                xcall delet("<FILE_NAME>")
            end
            catch (e, @NoFileFoundException)
            begin
                nop
            end
            endtry

    </STRUCTURE_LOOP>
        endmethod

    <STRUCTURE_LOOP>
      <IF STRUCTURE_ISAM>
        public static method load<StructurePlural>, @List<<StructureNoplural>>
        proc
            data dataFile = "<FILE_NAME>"
            data textFile = dataFile.ToLower().Replace(".ism",".txt")
            data <structureNoplural>Ch, int, 0
            data <structureNoplural>Rec, str<StructureNoplural>
            data <structurePlural> = new List<<StructureNoplural>>()
            data grfa, a10
            open(<structureNoplural>Ch,i:s,textFile)
            repeat
            begin
                reads(<structureNoplural>Ch,<structureNoplural>Rec,eof)
                <structurePlural>.Add(new <StructureNoplural>(<structureNoplural>Rec, grfa))
            end
        eof,
            close <structureNoplural>Ch
            mreturn <structurePlural>
        endmethod

      </IF>
    </STRUCTURE_LOOP>
  </IF>
        private static method findRelativeFolderForAssembly, string
            folderName, string
        proc
            data assemblyLocation = ^typeof(SelfHostEnvironment).Assembly.Location
            data currentFolder = Path.GetDirectoryName(assemblyLocation)
            data rootPath = Path.GetPathRoot(currentFolder)
            while(currentFolder != rootPath)
            begin
                if(Directory.Exists(Path.Combine(currentFolder, folderName))) then
                    mreturn Path.Combine(currentFolder, folderName)
                else
                    currentFolder = Path.GetFullPath(currentFolder + "..\")
            end
            mreturn ^null
        endmethod

</IF>
    endclass

endnamespace