# Fix Windows Names Batch

Small Windows helper for sanitizing file and folder names before creating ZIP archives with Windows compressed folders.

## What It Fixes

- `—` em dash
- `–` en dash
- `−` mathematical minus sign
- Windows-forbidden characters: `< > : " / \ | ? *`
- ASCII control characters
- names ending with a dot or a space
- duplicated dots before an extension, for example `Алексеев И.И..doc`
- reserved Windows device names: `CON`, `PRN`, `AUX`, `NUL`, `COM1`-`COM9`, `LPT1`-`LPT9`

Dash-like characters are replaced with the normal ASCII hyphen:

```text
-
```

Forbidden characters are replaced with `_`.

Example:

```text
Алексеев И.И..doc -> Алексеев И.И.doc
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

The batch wrapper removes a trailing backslash from the target path before passing it to PowerShell. This avoids `Resolve-Path: Illegal characters in path` errors on older Windows/PowerShell argument parsing.

## Safety

- Files are renamed before folders.
- Folders are renamed deepest first.
- Existing names are not overwritten.
- If a fixed name already exists, the script appends `__2`, `__3`, etc.
- If a name becomes empty after cleanup, it becomes `unnamed`.

Run this only on a local copy/result folder, not on the clinic network source.
