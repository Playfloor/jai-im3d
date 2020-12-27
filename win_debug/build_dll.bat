call vcvars64
call cl /LD /Zi /DEBUG ../im3d/im3d.cpp /link /DLL /OUT:Im3d.dll
rem call link /DEBUG /PDB:ImGui.pdb /DLL /OUT:ImGui.dll *.obj User32.lib
rem call lib /OUT:ImGui.lib *.obj
del im3d.obj
