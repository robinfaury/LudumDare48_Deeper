rgbds-0.4.2-win64\rgbasm.exe --verb -o deeperanddeeper.obj deeperanddeeper.asm&rgbds-0.4.2-win64\rgblink.exe --verb -o deeperanddeeper.gbc deeperanddeeper.obj&rgbds-0.4.2-win64\rgbfix.exe -v -p0 deeperanddeeper.gbc&rm deeperanddeeper.obj&bgbw64\bgb64.exe deeperanddeeper.gbc
