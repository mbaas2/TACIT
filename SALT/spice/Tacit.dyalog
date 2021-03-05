:Namespace Tacit ⍝ V 2.13
   ⍝ UCMD-File for TACIT. This just makes API-Functions available as UCMDs.
   ⍝ The syntax of the fns etc. is determined in the fn-header (StartupSession/TACIT/API.apln > ExecuteLocalTest)

    ∇ r←List;findLine;nr;fn;ns;hd;maxH
      :If 0=⎕NC'⎕SE.TACIT.U'
      :orIf 0=⎕NC'⎕SE.TACIT.U.UCMD_List'
          ⍝ the bad news is that this needs the API-ns which will be brought in later (during regular boot)
          ⍝ so let's do it now...
          {}⎕SE.Link.Import ⎕SE.TACIT.API((2 ⎕NQ'.' 'GetEnvironment' 'TACIT_FOLDER_SE'),'/API.apln')
          ⍝ Build list & help and construct stub-fns in ⎕SE.TACIT
          ⍝ based on fns we find in ⎕SE.TACIT.API
          'U'⎕SE.TACIT.⎕NS''
          ⎕SE.TACIT.U.UCMD_List←'['
          ⎕SE.TACIT.U.UCMD_Help←0 3⍴0  ⍝ [;1]=name, [;2]=Level, [;3]=line
          findLine←{{(+/^\⍵=' ')↓⍵}¨l↓¨(((l←2+≢⍵)↑¨⍺)≡¨⊂'⍝',⍵,':')/⍺}
          :For fn :In {('_'≠1⊃¨⍵)/⍵}⎕SE.TACIT.API.⎕NL-3  ⍝ only for fns NOT starting with '_'
              nr←⎕SE.TACIT.API.⎕NR fn
              'ns'⎕NS''
              ns.Name←fn
              ns.Desc←∊nr findLine':'
              ns.Parse←∊nr findLine'Parse'
              ns.Group←'TACIT'
              ⎕SE.TACIT.U.UCMD_List,←(⎕JSON ns),','
              maxH←⌈/0,∊('⍝(\?*):'⎕S{¯1↑⍵.Lengths})nr
              :For h :In ⍳maxH
                  ⎕SE.TACIT.U.UCMD_Help⍪←(⊂fn),(h-1),[1.5]nr findLine h⍴'?'
              :EndFor
              :Select 1⊃1⊃AT←⎕SE.TACIT.API.⎕AT fn
              :Case 0 ⍝ niladic or not a fn
                  hd←fn
              :Case 1 ⍝ monadic
                  hd←fn,' rarg'
              :CaseList ¯2 2
                  hd←'larg ',fn,' rarg'
              :EndSelect
              :Select 2⊃1⊃⎕SE.TACIT.API.⎕AT fn
              :Case 1 ⋄ hd←'R←',hd
              :Case ¯1 ⋄ hd←'{R}←',hd
              :EndSelect
              r←'←'∊hd
              hd←(⊂hd),⊂':if 2=⎕nc''larg''⋄',(r/'R←'),'larg getAPI ''',fn,''' rarg'
              hd,←⊂':else⋄',(r/'R←'),'getAPI ''',fn,''' rarg'
              hd,←⊂':endif'
              {⎕←'Fixed ',⍵}⎕SE.TACIT.⎕FX hd
          :EndFor
          ⎕SE.TACIT.U.UCMD_List←(¯1↓⎕SE.TACIT.U.UCMD_List),']'
          r←⍬
      :EndIf

          r←⎕JSON ⎕SE.TACIT.U.UCMD_List
    ∇

    ∇ r←level Help cmd
      :If 0=⎕NC'⎕SE.TACIT.U'
      :OrIf 0=⎕NC'⎕SE.TACIT.U.UCMD_Help'
          {}List   ⍝ trigger building of variables...
      :EndIf
      r←⎕SE.TACIT.U.UCMD_Help{(⍺[;⍳2]∧.≡⍵)⌿⍺[;3]}cmd level
      :If ∨/⎕SE.TACIT.U.UCMD_Help[;⍳2]∧.≡cmd(level+1)
          r,←(⊂''),(⊂']',((level+2)⍴'?'),'TACIT.',cmd,' for more details')
      :EndIf
    ∇

    ∇ r←Run(cmd args)
      :If 3=⎕NC'⎕SE.TACIT.',cmd        ⍝ if function exists in ⎕SE.TACIT...
          r←⍎'⎕SE.TACIT.',cmd,' args' ⍝ execute it...
      :Else
          Error
          r←''
      :EndIf
    ∇

:EndNamespace