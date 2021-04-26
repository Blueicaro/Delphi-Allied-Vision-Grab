# Delphi-Allied-Vision-Grab
Delphi port of the Vimba Asynchronousgrab_C example.

Allied Vision provides a VIMBA 3 and 4 ANSI-C library. I have ported those calls to Delphi (Rad Studio 10.2.3) and included an example project.

# Fork of Delphi-Allied-Vision-Grab
I modified VimbaC to add linux compile directive, to use library VimbaC.so insted VimbaC.dll.

I modified 

    Function VmbFeaturesList(handl: VmbHandle_t;

                           pFeatureInfoList : pVmbFeatureInfo_t;

                          listLength        : VmbUint32_t;

                          var pNumFound     : VmbUint32_t;

                         const sizeofFeatureInfo: VmbUint32_t): 
                         VmbError_t;

                         {$ifdef Win64} cdecl; {$else} stdcall; {$endif}         

pFeatureInfoList is declared as pVmbFeatureInfo_t, which is a pointet to ^VmbFeatureInfo_t. Now the declaration is the same as the original. 





