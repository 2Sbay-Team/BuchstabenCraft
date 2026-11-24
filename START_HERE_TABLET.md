# BuchstabenCraft: Android build using only Xiaomi tablet

1. Create or sign in to a GitHub account in Chrome on your tablet.
2. Create a **private** repository called `BuchstabenCraft`.
3. Upload **the contents inside this ZIP** to the repository root. The `.github` folder must be uploaded too. GitHub mobile web may hide dot-folders; using the browser's **Desktop site** option can help. For large projects with 1,000 MP3s, uploading files individually in the browser is impractical. A Git client or a repository import/upload tool may be required. Do not claim this is a one-tap tablet workflow.
4. Open the **Actions** tab, select **Build Android APK (Godot 4.4.1)**, then **Run workflow**.
5. If successful, open the run and download the **BuchstabenCraft-Android-debug** artifact ZIP. Extract the APK and install it on Xiaomi, allowing installation from your browser/files app when prompted.
6. If the build fails, copy the error lines from **Import and parse**, **Godot smoke test**, or **Export APK** and share them for a source fix.

This workflow has been prepared but NOT executed here. A debug APK is not a final signed release. Godot source may contain compiler errors. The visual game is still a prototype.
