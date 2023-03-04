# maintain

1. Clean binaries and test

```PowerShell
.\tools\clean.ps1
```

2. Change `bin\source\README.md(i.e. this file)` to add a specific version to be released

3. Build binaries and test

```PowerShell
cd $env:RBENV_ROOT\rbenv
.\tools\build.ps1
```

<br>

## Binary version

### = v0.2.0
**Release time:** `<2023-03-04>`
**Release tag:**  rbenv for Windows tag v1.4.1

<br>

### = v0.1.0
**Release time:** `<2023-02-11>`
**Release tag:**  rbenv for Windows tag v1.3.0