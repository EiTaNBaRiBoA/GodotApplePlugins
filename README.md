Plugins for some Apple-specific tasks, works on MacOS and iOS.

You can get a ready-to-use binary from the "releases" tab, just drag the contents 
into your addons directory.   You can start testing right away on a Mac project, 
and for iOS, export your iOS project and run.

The Makefile should produce a set of gdextensions that you can pick and choose.

* [GameCenter Integration Guide](Sources/GodotApplePlugins/GameCenter/GameCenterGuide.md)

Caveat: it currently defaults to dynamic libraries, which require manual steps in 
Godot to make them work.  Modifyt he Package.swift to force a static library instead
of a dynamic library as an alternative - or manually remove the registation in 
dummy.c, and force the linking and distribution of the frameworks (see the 
https://github.com/migueldeicaza/SwiftGodotAppleTemplate discussion for details)

