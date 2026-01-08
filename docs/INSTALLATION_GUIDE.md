# Installation Guide for Patched Casdoor Package

This guide explains how to install this patched `casdoor` package in other Python projects.

## Prerequisites

1. Build the package first:
   ```bash
   make dist
   ```
   This creates wheel and source distribution files in the `dist/` directory.

## Installation Methods

### Method 1: Install from Local Wheel File (Recommended for Production)

After building the package, you'll have a wheel file in `dist/` (e.g., `casdoor-1.17.0-py3-none-any.whl`).

**In your other project's `requirements.txt`:**
```txt
# Install from local wheel file
/path/to/casdoor-python-sdk/dist/casdoor-1.17.0-py3-none-any.whl

# Or use relative path if in same repository
../casdoor-python-sdk/dist/casdoor-1.17.0-py3-none-any.whl
```

**Install with pip:**
```bash
pip install /path/to/casdoor-python-sdk/dist/casdoor-1.17.0-py3-none-any.whl
```

**Or from requirements.txt:**
```bash
pip install -r requirements.txt
```

### Method 2: Install from Git Repository (Recommended for Teams)

If you push this repository to GitHub/GitLab, you can install directly from git.

**In your other project's `requirements.txt`:**
```txt
# Install from git repository (specific branch)
git+https://github.com/iHealthLab/casdoor-python-sdk.git@feature/patch-cves-20260107

# Or from a specific tag/commit
git+https://github.com/iHealthLab/casdoor-python-sdk.git@v1.17.0-patched

# Or from main/master branch
git+https://github.com/iHealthLab/casdoor-python-sdk.git@main
```

**Install with pip:**
```bash
pip install git+https://github.com/iHealthLab/casdoor-python-sdk.git@feature/patch-cves-20260107
```

### Method 3: Install from Local Directory (Editable/Development Mode)

For development when you need to make changes to both projects:

**In your other project's `requirements.txt`:**
```txt
# Editable install from local directory
-e /path/to/casdoor-python-sdk

# Or relative path
-e ../casdoor-python-sdk
```

**Install with pip:**
```bash
pip install -e /path/to/casdoor-python-sdk
```

**Note:** This creates an editable install, so changes to the casdoor package are immediately available.

### Method 4: Install from Private Package Index

If you set up a private PyPI server or use a service like GitHub Packages:

**In your other project's `requirements.txt`:**
```txt
# Install from private package index
--extra-index-url https://pypi.yourcompany.com/simple
casdoor==1.17.0
```

**Install with pip:**
```bash
pip install --extra-index-url https://pypi.yourcompany.com/simple casdoor==1.17.0
```

## Complete Example

Here's a complete example `requirements.txt` for another project:

```txt
# Your other project dependencies
flask==2.3.0
requests==2.31.0

# Install patched casdoor package
# Option 1: From local wheel (uncomment and adjust path)
# /path/to/casdoor-python-sdk/dist/casdoor-1.17.0-py3-none-any.whl

# Option 2: From git repository (uncomment and adjust)
# git+https://github.com/iHealthLab/casdoor-python-sdk.git@feature/patch-cves-20260107

# Option 3: Editable install for development (uncomment and adjust path)
# -e /path/to/casdoor-python-sdk
```

## Version Pinning

To ensure you get the exact patched version, you can:

1. **Pin the version in requirements.txt:**
   ```txt
   casdoor==1.17.0
   ```

2. **Use git with a specific commit hash:**
   ```txt
   git+https://github.com/iHealthLab/casdoor-python-sdk.git@abc123def456
   ```

3. **Use git with a tag:**
   ```txt
   git+https://github.com/iHealthLab/casdoor-python-sdk.git@v1.17.0-patched
   ```

## Verifying Installation

After installation, verify the package and version:

```python
import casdoor
print(casdoor.__version__)  # Should show 1.17.0

# Verify aiohttp version is patched
import aiohttp
print(aiohttp.__version__)  # Should show 3.12.14 or later
```

## Troubleshooting

### Issue: Package not found
- Ensure the path to the wheel file is correct
- If using git, ensure the repository is accessible
- Check that you've built the package with `make dist`

### Issue: Wrong version installed
- Clear pip cache: `pip cache purge`
- Uninstall existing version: `pip uninstall casdoor`
- Reinstall with the correct method

### Issue: Import errors
- Ensure all dependencies are installed: `pip install -r requirements.txt`
- Check that the package was installed correctly: `pip show casdoor`

## CI/CD Integration

For CI/CD pipelines, you can use environment variables:

```yaml
# Example GitHub Actions
- name: Install patched casdoor
  run: |
    pip install git+https://github.com/iHealthLab/casdoor-python-sdk.git@${{ env.CASDOOR_VERSION }}
```

Or download and install the wheel:

```yaml
- name: Install patched casdoor
  run: |
    wget https://your-artifact-server.com/casdoor-1.17.0-py3-none-any.whl
    pip install casdoor-1.17.0-py3-none-any.whl
```
