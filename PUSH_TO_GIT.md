# Pushing to Git Repository

## Option 1: Create New Repository on GitHub

1. Go to https://github.com/new
2. Create a new repository (e.g., `rke2-monitoring-stack`)
3. **DO NOT** initialize with README, .gitignore, or license
4. Run these commands:

```bash
cd /tmp/monitoring-deployment

# Add remote (replace YOUR_USERNAME and REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Option 2: Create New Repository on GitLab

1. Go to https://gitlab.com/projects/new
2. Create a new project
3. Run these commands:

```bash
cd /tmp/monitoring-deployment

# Add remote (replace YOUR_USERNAME and REPO_NAME)
git remote add origin https://gitlab.com/YOUR_USERNAME/REPO_NAME.git

# Push to GitLab
git branch -M main
git push -u origin main
```

## Option 3: Use Existing Remote

If you already have a remote repository:

```bash
cd /tmp/monitoring-deployment

# Add your existing remote
git remote add origin <your-repo-url>

# Push
git branch -M main
git push -u origin main
```

## Using SSH (Recommended)

If you have SSH keys set up:

```bash
# GitHub
git remote add origin git@github.com:YOUR_USERNAME/REPO_NAME.git

# GitLab
git remote add origin git@gitlab.com:YOUR_USERNAME/REPO_NAME.git

# Push
git branch -M main
git push -u origin main
```

## Current Repository Info

- **Location**: `/tmp/monitoring-deployment`
- **Commits**: 3 commits ready to push
- **Branch**: main (will be created on first push)
