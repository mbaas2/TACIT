:namespace TACIT
⍝ ⎕SIGNAL-Codes uses: 
⍝ 200: File missing or empty
⍝ 201: no test required

    env←{2 ⎕NQ'.' 'GetEnvironment'⍵}     ⍝ get value from environment-variable or .dcfg
    split←(≠⊆⊢)

    cfgFILE←''   ⍝ fully qualified name of a TACIT.json-file

    ∇ Run sink
      ⍝ insert code here ;)
      :If 0=≢cfgFILE ⋄ :OrIf ~⎕NEXISTS cfgFile ⋄ 'TACIT_File missing'⎕SIGNAL 200 ⋄ :EndIf
      spec←⎕JSON 1⊃⎕NGET cfgFile
     
      :If ~⊃(z msg)←NeedsTest spec
      ('No test required: ',msg)⎕signal 201
      :EndIf

      ⍝ setup dcfg & execute test in folder
     
    ∇

    ∇ (z msg)←Needstest j
      z←1⋄msg←''
      :If 2=j.⎕NC'DyalogVersions'
          V←+/1 0.1×2⊃'.'⎕VFI 2⊃'.'⎕WG'aplversion'  ⍝ current version
          v←j.DyalogVersions
          plus←0  ⍝ did we see a +sign?
          :If (⎕DR' ')=⎕DR v  ⍝ , separated list or a single version, possibly with "+
              v←','split v
              (v plus)←↓⍉↑{p←'+'∊⍵ ⋄ (⊃2⊃⎕VFI ⍵),p}¨v
          :EndIf
          z∧←∨/(V∊v),(v<V)∧plus
          :if ~z ⋄⋄msg←'Versions did not match: ',(⍕V),' vs. ',j.DyalogVersions,' (',(⍕v),', plus=',(⍕plus),')'⋄:endif
      :EndIf
      :If z
      :andif 2=j.⎕NC'Bits'
          B←{⍵:64 ⋄ 32}∨/'64'⍷1⊃'.'⎕wg'APLVersion'
          b←j.Bits
          :If (⎕DR' ')=⎕DR b
              b←2⊃','⎕VFI b
          :EndIf
          z∧←B∊b
          :if ~z⋄msg←'Bits did not match: ',(⍕B),' vs. ',⍕b⋄:endif
      :EndIf
      ⍝ check j.Platforms, j.Environments
      :if z
      :andif 2=j.⎕nc'Editions'
        E←(1+80=⎕dr' ')⊃'UC'  ⍝ Unicode or Classic
        z^←E∊j.Editions
        :if ~z⋄msg←'Editions did not match: ',E,' vs. ',j.Editions⋄:endif
      :endif
    ∇


:endnamespace
