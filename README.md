# Fix Windows Dashes Batch

Small Windows helper for replacing problematic dash characters in file and folder names before creating ZIP archives.

## What It Replaces

- `—` em dash
- `–` en dash
- `−` mathematical minus sign

All are replaced with the normal ASCII hyphen:

```text
-
```

## How To Use

Copy both files into the folder you want to fix:

```text
fix_dashes.bat
fix_dashes.ps1
```

Then double-click:

```text
fix_dashes.bat
```

By default, it processes the folder where the `.bat` file is located.

You can also run it from `cmd` with an explicit target:

```bat
fix_dashes.bat "C:\Users\...\Desktop\Выписки"
```

## Safety

- Files are renamed before folders.
- Folders are renamed deepest first.
- Existing names are not overwritten.
- If a fixed name already exists, the script appends `__2`, `__3`, etc.

Run this only on a local copy/result folder, not on the clinic network source.
