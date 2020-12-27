call vcvars64
call cl /LD ../im3d/im3d.cpp /link /DLL /OUT:Im3d.dll
del im3d.obj
