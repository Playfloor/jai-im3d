call vcvars64
call cl /LD ../cpp/im3d.cpp /link /DLL /OUT:Im3d.dll
del im3d.obj
