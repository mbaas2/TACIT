:Namespace Tacit
   ⍝ UCMD-File for TACIT. This just makes API-Functions available as UCMDs.
   ⍝ The syntax of the fns etc. is determined in the fn-header (StartupSession/TACIT/API.apln > ExecuteLocalTest)

    :section UCMD

    ∇ r←List;findLine;nr;fn;ns;hd;maxH
      FetchAPI
      r←⎕JSON ⎕SE.TACIT.UCMD._List
    ∇

    ∇ r←level Help cmd
      ⍝FetchAPI
      r←⎕SE.TACIT.UCMD._Help{(⍺[;⍳2]∧.≡⍵)⌿⍺[;3]}cmd level
      :If ∨/⎕SE.TACIT.UCMD._Help[;⍳2]∧.≡cmd(level+1)
          r,←(⊂''),(⊂']TACIT.',cmd,' -',((level+2)⍴'?'),'    ⍝ for more details')
      :EndIf
    ∇

    ∇ {r}←Run(cmd args);res;⎕ML
      ⎕ML←1
      :If 3=⎕NC'⎕SE.TACIT.API.',cmd        ⍝ if function exists in ⎕SE.TACIT...
          res←⍎'⎕SE.TACIT.API.',cmd,' args' ⍝ execute it...
          r←cmd,': ',{⍵=0:'success' ⋄ ('*** '/⍨0≠1⊃res),'FAILURE (return code=',(⍕⍵),')'},1⊃res
          r←{l ⍵(l←(⌈/(≢r),≢¨2⊃res)⍴'-─'[1+0=1⊃res])}r
          r←(⊂''),r,⊆2⊃res
          r←∊r,¨⊂⎕UCS 13 10
      :Else
          ⎕←↑⎕DMX
          r←''
      :EndIf
    ∇
    :endsection

    :section SecretSauce
    ∇ FetchAPI;findLine;quote;j;maxH;nr;hd;r
      :If 0=⎕NC'⎕SE.TACIT'
      :OrIf 0=⎕NC'⎕SE.TACIT.UCMD'
          ⍝ the bad news is that this needs the API-ns which will be brought in later (during regular boot)
          ⍝ so we do it now...
          'TACIT'⎕SE.⎕NS''
          'API'⎕SE.TACIT.⎕NS''
          'UCMD'⎕SE.TACIT.⎕NS''
          {}⎕SE.Link.Import ⎕SE.TACIT.API(FindTACIT,'/API.apln')
          ⍝ Build list & help and construct stub-fns in ⎕SE.TACIT
          ⍝ based on fns we find in ⎕SE.TACIT.API
          ⎕SE.TACIT.UCMD._List←'['
          ⎕SE.TACIT.UCMD._Help←0 3⍴0  ⍝ [;1]=name, [;2]=Level, [;3]=line
          findLine←{{(+/∧\⍵=' ')↓⍵}¨l↓¨(((l←2+≢⍵)↑¨⍺)≡¨⊂'⍝',⍵,':')/⍺}
          quote←{'"',⍵,'"'}
          :For fn :In {('_'≠1⊃¨⍵)/⍵}⎕SE.TACIT.API.⎕NL-3  ⍝ only for fns NOT starting with '_'
              nr←⎕SE.TACIT.API.⎕NR fn
              'ns'⎕NS''
              j←'{'
              j,←'"Name":',quote fn
              j,←',"Desc":',quote∊nr findLine':'
              j,←',"Parse":',quote∊nr findLine'Parse'
              j,←',"Group":"TACIT"'
              j,←'}'
              ⎕SE.TACIT.UCMD._List,←j,','
              maxH←⌈/0,∊('⍝(\?*):'⎕S{¯1↑⍵.Lengths})nr
              :For h :In ⍳maxH
                  ⎕SE.TACIT.UCMD._Help⍪←(⊂fn),(h-1),[1.5]nr findLine h⍴'?'
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
              hd←(⊂hd),⊂':if 2=⎕nc''larg''⋄',(r/'R←'),'larg _getAPI ''',fn,''' rarg'
              hd,←⊂':else⋄',(r/'R←'),'_getAPI ''',fn,''' rarg'
              hd,←⊂':endif'
              {}⎕SE.TACIT.⎕FX hd
          :EndFor
          ⎕SE.TACIT.UCMD._List←(¯1↓⎕SE.TACIT.UCMD._List),']'
          :If 0  ⍝ MB
              'Fetched API!'
              ⎕←⎕SI,[1.5]⎕LC
          :EndIf
      :Else
          :If 0  ⍝ MB
              ⎕←'API not loaded because present!'
              ⎕←⎕SI,[1.5]⎕LC
          :EndIf
      :EndIf
    ∇

    ∇ R←FindTACIT
    ⍝ I had expected this would turn out to be more complicated...
    ⍝ but doing it this way we don't even need the environment variable!
      R←∊1 ⎕NPARTS(##.t~'"'),'/../../../StartupSession/TACIT'
    ∇
    :endsection
:EndNamespace
