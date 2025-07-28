# How to fork the LongLiveRosa repository and make pull requests

## Why Forking is Necessary

Because contributors don’t have direct write access to our organization’s repository, the standard workflow is:

1. **Fork** the repository (create a personal copy).
2. **Clone** your fork locally.
3. **Create a new branch** for your changes.
4. **Commit and push** changes to your fork.
5. **Submit a pull request** to our main repository.

This process helps maintain a clean and secure codebase.

---

## Prerequisites

- A GitHub account
- Git installed locally
- (Optional) SSH set up with GitHub

---

## Step-by-Step Guide

### 1. Fork the Repository

1. Go to: `https://github.com/Longliverosa/longliverosa-game`
2. Click the **“Fork”** button in the top-right corner.
3. Select your personal GitHub account.
4. Your fork will be created at:  
   `https://github.com/YourUsername/YourRepo`

---

### 2. Clone Your Fork Locally

Using HTTPS:

```bash
git clone https://github.com/YourUsername/YourRepo.git
cd YourRepo
```

Using SSH:

```bash
git clone git@github.com:YourUsername/YourRepo.git
cd YourRepo
```

---

### 3. Add the Original Repository as a Remote

To keep your fork in sync with the original repository:

```bash
git remote add upstream https://github.com/Longliverosa/longliverosa-game
```

Verify the remotes:

```bash
git remote -v
```

Expected output:
```bash
origin    https://github.com/YourUsername/YourRepo.git (fetch)
upstream  https://github.com/Longliverosa/longliverosa-game (fetch)
```

---

### 4. Create a New Branch

Never work on the main branch directly. Create a descriptive feature branch:

```bash
git checkout -b feature/my-new-feature
```

as per convention and to keep the repository clear, we will only accept pullrequests from branches that start with 'feature/'

---

### 5. Make Your Changes and Commit

Make your changes using godot. Once done:

```bash
git add .
git commit -m "Add: Implemented my new feature"
```

---

### 6. Push Your Branch to Your Fork

```bash
git push origin feature/my-new-feature
```

---

### 7. Open a Pull Request

1. Go to your fork on GitHub: https://github.com/YourUsername/YourRepo
2. Click the **"Compare & pull request"** button.
3. Ensure the base repository is Longliverosa/longliverosa-game and the base branch is main.
4. Provide a clear title and description. Include all changes you have made and why.
5. Click **"Create pull request"**.

--- 

### 8. Respond to Feedback

If reviewers suggest changes:
1. Make the edits locally.
2. Commit and push to the same feature branch.
3. The pull request will update automatically.

## Keeping Your Fork Updated

To sync your fork with the latest changes from the upstream repository:

```bash
git checkout main
git pull upstream main
git push origin main
```
