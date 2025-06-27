<CODEGEN_FILENAME><STRUCTURE_NAME>_KEYS_REPORT.TXT</CODEGEN_FILENAME>

==============================================================================
Keys report for structure <STRUCTURE_NAME>
==============================================================================

<KEY_LOOP>
KEY <KEY_NUMBER>
    START             <SEGMENT_LOOP><SEGMENT_POSITION><:></SEGMENT_LOOP>
    LENGTH            <SEGMENT_LOOP><SEGMENT_LENGTH><:></SEGMENT_LOOP><IF MULTIPLE_SEGMENTS> (total <KEY_LENGTH>)</IF>
    TYPE              <SEGMENT_LOOP><segment_idxtype><:></SEGMENT_LOOP>
    ORDER             <SEGMENT_LOOP><segment_sequence><:></SEGMENT_LOOP>
    DUPLICATES        <IF DUPLICATES>yes<ELSE>no</IF>
  <IF DUPLICATES>
    DUPLICATE_ORDER   <IF DUPLICATESATEND>fifo<ELSE>lifo</IF>
  </IF DUPLICATES>
    MODIFIABLE        <IF CHANGES>yes<ELSE>no</IF>

</KEY_LOOP>
