<CODEGEN_FILENAME>GenerateTestValues.dbl</CODEGEN_FILENAME>
<REQUIRES_CODEGEN_VERSION>5.6.5</REQUIRES_CODEGEN_VERSION>
<REQUIRES_USERTOKEN>UNIT_TESTS_NAMESPACE</REQUIRES_USERTOKEN>

import System
import System.Text.Json
import System.Text.Json.Serialization
import System.IO
import Harmony.Core.FileIO
import <UNIT_TESTS_NAMESPACE>

main GenerateTestValues
proc
    <UNIT_TESTS_NAMESPACE>.UnitTestEnvironment.AssemblyInitialize(^null)
    new GenerateTestValues().SerializeValues()
endmain

namespace <NAMESPACE>

    public partial class GenerateTestValues

    <STRUCTURE_LOOP>
        <IF STRUCTURE_ISAM>
        .include "<STRUCTURE_NOALIAS>" repository, record="<structureNoplural>Rec", end
        </IF STRUCTURE_ISAM>
    </STRUCTURE_LOOP>

        private ChannelManager, @IFileChannelManager
        
        public method GenerateTestValues
        proc
            CustomServiceInit()
            if(ChannelManager == ^null)
                ChannelManager = new FileChannelManager()
        endmethod

        partial method GetCustomFileSpec, void
            required inout aFileSpec, string
        endmethod

        public method SerializeValues, void
            endparams
        proc
            data chin, int
            data count, int
            data fileSpec, string

<STRUCTURE_LOOP>
  <IF STRUCTURE_ISAM>
            ;------------------------------------------------------------
            ;Test data for <StructureNoplural>

            fileSpec = "<FILE_NAME>"

            ;If there is a GetCustomFileSpec method, call it
            GetCustomFileSpec(fileSpec)

            Console.WriteLine("Processing <StructureNoplural>")
            Console.WriteLine(" - Opening {0}",fileSpec)

            try
            begin
                chin = ChannelManager.GetChannel(fileSpec,FileOpenMode.InputIndexed)

;//
;// ENABLE_GET_ALL
;//
    <IF DEFINED_ENABLE_GET_ALL>
                ;Total number of records
                Console.WriteLine(" - Record count: {0}",count=%isinfo(chin,"NUMRECS"))
                TestConstants.Instance.Get<StructurePlural>_Count = count

;//
;//RELATION LOGIC MISSING
    </IF DEFINED_ENABLE_GET_ALL>
;//
;// ENABLE_GET_ONE
;//
    <IF DEFINED_ENABLE_GET_ONE>
                ;Get by primary key
                Console.WriteLine(" - Determining parameters for read by primary key...")

                if (count) then
                begin
                    try
                    begin
                        read(chin,<structureNoplural>Rec,^LAST)
      <PRIMARY_KEY>
        <SEGMENT_LOOP>
                        TestConstants.Instance.Get<StructureNoplural>_<SegmentName> = <IF DATEORTIME>DecToDateTime(<structureNoplural>Rec.<segment_name>, "<FIELD_CLASS>")<ELSE SEG_TYPE_FIELD><structureNoplural>Rec.<segment_name><ELSE SEG_TYPE_LITERAL>"<SEGMENT_LITVAL>"</IF DATEORTIME>
        </SEGMENT_LOOP>
      </PRIMARY_KEY>
                    end
                    catch (e, @Exception)
                    begin
                        Console.WriteLine(" - ERROR: Failed to read last record!")
                    end
                    endtry
                end
                else
                begin
                    Console.WriteLine(" - ERROR: Can't read by primary key because file is empty!")
                end

      <IF DEFINED_ENABLE_RELATIONS>
        <IF STRUCTURE_RELATIONS>
          <RELATION_LOOP_RESTRICTED>
            <PRIMARY_KEY>
              <SEGMENT_LOOP>
                <IF DATEORTIME>
                TestConstants.Instance.Get<StructureNoplural>_Expand_<HARMONYCORE_RELATION_NAME>_<SegmentName> = DecToDateTime(<structureNoplural>Rec.<segment_name>, "<FIELD_CLASS>")
                <ELSE SEG_TYPE_FIELD>
                TestConstants.Instance.Get<StructureNoplural>_Expand_<HARMONYCORE_RELATION_NAME>_<SegmentName> = <structureNoplural>Rec.<segment_name>
                <ELSE SEG_TYPE_LITERAL>
                TestConstants.Instance.Get<StructureNoplural>_Expand_<HARMONYCORE_RELATION_NAME>_<SegmentName> = "<SEGMENT_LITVAL>"
                </IF>
              </SEGMENT_LOOP>
            </PRIMARY_KEY>
          </RELATION_LOOP_RESTRICTED>
;//
          <PRIMARY_KEY>
            <SEGMENT_LOOP>
              <IF DATEORTIME>
                TestConstants.Instance.Get<StructureNoplural>_Expand_All_<SegmentName> = DecToDateTime(<structureNoplural>Rec.<segment_name>, "<FIELD_CLASS>")
              <ELSE SEG_TYPE_FIELD>
                TestConstants.Instance.Get<StructureNoplural>_Expand_All_<SegmentName> = <structureNoplural>Rec.<segment_name>
              <ELSE SEG_TYPE_LITERAL>
                TestConstants.Instance.Get<StructureNoplural>_Expand_All_<SegmentName> = "<SEGMENT_LITVAL>"
              </IF>
            </SEGMENT_LOOP>
          </PRIMARY_KEY>
        </IF STRUCTURE_RELATIONS>
      </IF DEFINED_ENABLE_RELATIONS>
;//
;//
    </IF DEFINED_ENABLE_GET_ONE>
;//
;//
;//
;//
  <ALTERNATE_KEY_LOOP_UNIQUE>
  <IF DUPLICATES>
    <SEGMENT_LOOP>
      <IF DATEORTIME>
                TestConstants.Instance.Get<StructureNoplural>_ByAltKey_<KeyName>_<SegmentName> = DecToDateTime(<structureNoplural>Rec.<segment_name>, "<FIELD_CLASS>")
      <ELSE SEG_TYPE_FIELD>
                TestConstants.Instance.Get<StructureNoplural>_ByAltKey_<KeyName>_<SegmentName> = <structureNoplural>Rec.<segment_name>
      <ELSE SEG_TYPE_LITERAL>
                TestConstants.Instance.Get<StructureNoplural>_ByAltKey_<KeyName>_<SegmentName> = "<SEGMENT_LITVAL>"
      </IF>
    </SEGMENT_LOOP>
  </IF DUPLICATES>
  </ALTERNATE_KEY_LOOP_UNIQUE>
;//
;//
;//
  <PRIMARY_KEY>
    <SEGMENT_LOOP>
      <IF DATEORTIME>
                TestConstants.Instance.Update<StructureNoplural>_<SegmentName> = DecToDateTime(<structureNoplural>Rec.<segment_name>, "<FIELD_CLASS>").AddDays(1)
      <ELSE SEG_TYPE_FIELD>
                TestConstants.Instance.Update<StructureNoplural>_<SegmentName> = <structureNoplural>Rec.<segment_name> + <IF ALPHA OR USER>"A"<ELSE>1</IF>
      <ELSE SEG_TYPE_LITERAL>
                TestConstants.Instance.Update<StructureNoplural>_<SegmentName> = "<SEGMENT_LITVAL>" + <IF ALPHA OR USER>"A"<ELSE>1</IF>
      </IF>
    </SEGMENT_LOOP>
  </PRIMARY_KEY>

                ChannelManager.ReturnChannel(chin)

            end
            catch (e, @Exception)
            begin
                Console.WriteLine(" - ERROR: Failed to open file. Error was {0}",e.Message)
            end
            endtry

  </IF STRUCTURE_ISAM>
</STRUCTURE_LOOP>
            ;Determine where to create the output file
            data jsonFilePath = <UNIT_TESTS_NAMESPACE>.UnitTestEnvironment.FindRelativeFolderForAssembly("<UNIT_TESTS_NAMESPACE>")
            File.WriteAllText(Path.Combine(jsonFilePath, "TestConstants.Values.json"), JsonSerializer.Serialize(TestConstants.Instance, new JsonSerializerOptions(){ WriteIndented = true }))

            ;If there is a GenerateInterfaceTestRequests method, call it
            GenerateInterfaceTestRequests()

            ;Console.WriteLine()
            ;Console.Write("Press a key: ")
            ;Console.ReadKey()
            ;Console.WriteLine()

        endmethod

        ;;It may be useful to set MultiTenantProvider.TenantId to a predefined tenantid if this is used inside your custom ChannelManager
        ;;this is where ChannelManager should be set to a custom type
        partial method CustomServiceInit, void
        endmethod

        ;;This partial method is intended to allow you to call out to any <InterFaceName>TestReuests.MakeTestRequestFiles() methods
        partial method GenerateInterfaceTestRequests, void
        endmethod

    endclass

endnamespace
